func load_gff_file(filename):
	print("Loading GFF file:", filename)
	var file = FileAccess.open(filename, FileAccess.READ)
	var lines = file.get_as_text().rstrip("\n").split("\n")
	var annotations = {}

	for line in lines:
		if line[0] == "#":
			continue

		var fields = line.rstrip("\r").split("\t")
		# example line:
		# g1.c1  .  gene  900  1400  .  +  .  ID=gene1;foo=bar;name=name1
		if fields[0] not in annotations:
			annotations[fields[0]] = []
		
		var tags = {}
		if len(fields) >= 9 and fields[8] != ".":
			var pairs = fields[8].split(";") 
			for x in pairs:
				var keyval = x.split("=")
				tags[keyval[0]] = keyval[1]

		annotations[fields[0]].append([
			int(fields[3]) - 1, # start position
			int(fields[4]) - 1, # end position
			fields[2], # type of feature
			fields[6] == "-", # is reverse
			tags, # dict of tags
		])

	for x in annotations:
		annotations[x].sort() # ie sorts by start position
	print("Loaded GFF file ok:", filename)
	return annotations
