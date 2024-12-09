func to_fasta(infile, outprefix):
	var stderr = []
	var exit_code = OS.execute(Globals.userdata.tnahelper, ["import_seqfile", "-i", infile, "-o", outprefix], stderr, true)
	if exit_code != 0:
		print("Error importing sequence file: ", infile)
		print(stderr)
	return exit_code


func download_genome(accession, outprefix):
	var stderr = []
	var exit_code = OS.execute(Globals.userdata.tnahelper, ["download_genome", "-a", accession, "-o", outprefix], stderr, true)
	if exit_code != 0:
		print("Error downloading sequence file: ", accession)
		print(stderr)
	return exit_code


func load_fasta_file(filename):
	print("Loading fasta file: ", filename)
	var file = FileAccess.open(filename, FileAccess.READ)
	var lines = file.get_as_text().rstrip("\n").split("\n")
	var contigs = {"order": [], "contigs": []}

	for line in lines:
		if line[0] == ">":
			var fields = line.trim_prefix(">").split(" ", false, 1)
			contigs["order"].append(len(contigs["order"]))
			var descr
			if len(fields) > 1:
				descr = fields[1]
			else:
				descr = ""
			contigs["contigs"].append({"name": fields[0], "descr": descr})
		else:
			contigs["contigs"][-1]["seq"] = line
	print("Loaded fasta file ok: ", filename)
	return contigs

func revcomp(seq_in):
	var seq_out = []
	for i in range(0, len(seq_in)):
		seq_out.append(Globals.complement_dict.get(seq_in[-i-1], "N"))
	return "".join(seq_out)
