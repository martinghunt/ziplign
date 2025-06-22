const BlastHitClass = preload("blast_hit.gd")

func run_blast(proj_dir, blast_program):
	var opts = ["blast", "-t", blast_program, "-b", Globals.userdata.bin, "-o", proj_dir]
	if Globals.userdata.config.get_value("blast", "share_data"):
		opts.append("--send_usage_report")

	if len(Globals.userdata.blast_options) > 0:
		opts.append("--")
		opts.append_array(Globals.userdata.blast_options.split(" ", false))

	print("opts: ", Globals.userdata.zlhelper, opts)
	var stderr = []
	var exit_code = OS.execute(Globals.userdata.zlhelper, opts, stderr, true)
	for x in stderr:
		print(x)
	if exit_code != 0:
		print("Error running blast")
	return [exit_code, stderr]


func genome2name_lookup(gen):
	var lookup = {}
	for i in gen["order"]:
		lookup[gen["contigs"][i]["name"]] = i
	return lookup


func load_tsv_file(filename, qry_genome, ref_genome):
	var file = FileAccess.open(filename, FileAccess.READ)
	var contents = file.get_as_text()
	contents = contents.rstrip("\n")
	var lines = contents.split("\n")
	var rows = []
	var aln_json = JSON.new()
	var qry_lookup = genome2name_lookup(qry_genome)
	var ref_lookup = genome2name_lookup(ref_genome)

	for line in lines:
		# windows blast has an extra "\r" at the end of each line
		var fields = line.rstrip("\r").split("\t")
		var qcoords = [int(fields[3]), int(fields[4])]
		var refcoords = [int(fields[5]), int(fields[6])]
		if qcoords[0] > qcoords[1]:
			print("Error. query start > query end. Stopping. ", fields[0], "-", fields[1])
			return
		var is_rev = (qcoords[0] < qcoords[1]) != (refcoords[0] < refcoords[1])
		qcoords.sort()
		refcoords.sort()
		# Used to remove self-hits. But then sorted hits so shortest have
		# higher zindex, so that the biggest hit doesn't cover all the smaller
		# ones. Keep the self-hits for now. Can revisit if users raise issues
		#if fields[0] == fields[1] and qcoords == refcoords:
		#	continue

		var error = aln_json.parse(fields[7])
		if error != OK:
			print("Error parsing final field of blast line: ", fields)
			continue


		if int(qcoords[1]) - int(qcoords[0]) < 10:
			continue

		rows.append(BlastHitClass.new(
			qry_lookup[fields[0]],
			ref_lookup[fields[1]],
			float(fields[2]),
			qcoords[0],
			qcoords[1],
			refcoords[0],
			refcoords[1],
			is_rev,
			aln_json.data,
		))

	rows.sort_custom(func(a, b): return a.length() > b.length())
	return rows
