func run_blast(proj_dir, blast_program):
	var opts = ["blast", "-t", blast_program, "-b", Globals.userdata.bin, "-o", proj_dir]
	if len(Globals.userdata.blast_options) > 0:
		opts.append("--")
		opts.append_array(Globals.userdata.blast_options.split(" ", false)) 
	print("opts: ", Globals.userdata.tnahelper, opts)
	var stderr = []
	var exit_code = OS.execute(Globals.userdata.tnahelper, opts, stderr, true)
	for x in stderr:
		print(x)
	if exit_code != 0:
		print("Error running blast")
	return exit_code


func load_tsv_file(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var contents = file.get_as_text()
	contents = contents.rstrip("\n")
	var lines = contents.split("\n")
	var rows = []
	var aln_json = JSON.new()

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
		if fields[0] == fields[1] and qcoords == refcoords:
			continue

		var error = aln_json.parse(fields[7])
		if error != OK:
			print("Error parsing final field of blast line: ", fields)
			continue

		rows.append({
			"qry": fields[0],
			"ref": fields[1],
			"pc": float(fields[2]),
			"qstart": qcoords[0],
			"qend": qcoords[1],
			"rstart": refcoords[0],
			"rend": refcoords[1],
			"rev": is_rev,
			"aln_data": aln_json.data
		})
		
	return rows
