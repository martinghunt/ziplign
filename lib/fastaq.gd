func to_fasta(infile, outfile):
	var stderr = []
	var exit_code = OS.execute(Globals.ext_path.path_join("seqkit"), ["seq", "--only-id", "-w", "0", infile, "-o", outfile], stderr, true)
	#var exit_code = OS.execute("res://ext/seqkit", ["seq", "--only-id", "-w", "0", infile, "-o", outfile], stderr, true)
	if exit_code != 0:
		print("Error running seqkit")
		print(stderr)
	return exit_code


func load_fasta_file(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var lines = file.get_as_text().rstrip("\n").split("\n")
	var contigs = {"names": [], "seqs": {}}

	for line in lines:
		if line[0] == ">":
			contigs["names"].append(line.lstrip(">"))
		else:
			contigs["seqs"][contigs["names"][-1]] = line

	return contigs
