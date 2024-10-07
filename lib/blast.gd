func run_blast(proj_dir):
	var opts = ["blast", "-b", Globals.userdata.bin, "-o", proj_dir]
	print("opts: ", Globals.userdata.tnahelper, opts)
	var stderr = []
	var exit_code = OS.execute(Globals.userdata.tnahelper, opts, stderr, true)
	for x in stderr:
		print(x)
	if exit_code != 0:
		print("Error running blastn")
	return exit_code


func load_tsv_file(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var contents = file.get_as_text()
	contents = contents.rstrip("\n")

	# Split coordinates by newline
	var lines = contents.split("\n")
	var rows = []

	for line in lines:
		var fields = line.split("\t")
		var qcoords = [int(fields[3]), int(fields[4])]
		if qcoords[0] > qcoords[1]:
			print("Error qcoords not in order")
			return
			
		var refcoords = [int(fields[5]), int(fields[6])]
		var is_rev = (qcoords[0] < qcoords[1]) != (refcoords[0] < refcoords[1])
		qcoords.sort()
		refcoords.sort()
		if fields[0] == fields[1] and qcoords == refcoords:
			continue

		if len(fields[7]) != len(fields[8]):
			print("Error different aligned seq lengths from blast")
			return
			
		if fields[7][0] == "-" or fields[8][0] == "-":
			print("Error blast match seq starts with gap")
			return
		
		var rpos = 0
		var qpos = 0
		var aln_data = [[0, 0, 0, 0, 0]]
			
		for i in range(1, len(fields[7])):
			if fields[7][i] == "-":
				if fields[8][i] == "-":
					print("error both gaps")
					return
				rpos += 1
			elif fields[8][i] == "-":
				if fields[7][i] == "-":
					print("error both gaps")
					return
				qpos += 1
			elif fields[7][i] == fields[8][i]:
				if aln_data[-1][1] == qpos and aln_data[-1][3] == rpos and aln_data[-1][4] == 0:
					aln_data[-1][1] += 1
					aln_data[-1][3] += 1
				else:
					aln_data.append([qpos+1, qpos+1, rpos+1, rpos+1, 0])
				qpos += 1
				rpos += 1
			else:
				qpos += 1
				rpos += 1
				aln_data.append([qpos, qpos, rpos, rpos, 1])


		rows.append({
			"qry": fields[0],
			"ref": fields[1],
			"pc": float(fields[2]),
			"qstart": qcoords[0],
			"qend": qcoords[1],
			"rstart": refcoords[0],
			"rend": refcoords[1],
			"rev": is_rev,
			"aln_data": aln_data
		})

	return rows
