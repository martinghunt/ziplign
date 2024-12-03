func load_gff_file(filename):
	print("Loading GFF file:", filename)
	var file = FileAccess.open(filename, FileAccess.READ)
	var lines = file.get_as_text().rstrip("\n").split("\n")
	var to_dedup = {}
	var annotations = {}

	for line in lines:
		if line[0] == "#" or not "\t" in line:
			continue

		var fields = line.rstrip("\r").split("\t")
		# example line:
		# g1.c1  .  gene  900  1400  .  +  .  ID=gene1;foo=bar;name=name1
		if fields[0] not in to_dedup:
			to_dedup[fields[0]] = {}
			annotations[fields[0]] = []
		
		var tags = {}
		if len(fields) >= 9 and fields[8] != ".":
			var pairs = fields[8].split(";") 
			for x in pairs:
				var keyval = x.split("=")
				tags[keyval[0]] = keyval[1]

		var to_add = [
			int(fields[3]) - 1, # start position
			int(fields[4]) - 1, # end position
			fields[2], # type of feature
			fields[6] == "-", # is reverse
			tags, # dict of tags
		]
		
		if "ID" in tags:
			to_dedup[fields[0]][tags["ID"]] = to_add
		else:
			annotations[fields[0]].append(to_add)
	
	for contig_name in to_dedup:
		var to_delete = []
		for name in to_dedup[contig_name]:
			var record = to_dedup[contig_name][name]
			if "Parent" in record[4] and record[4]["Parent"] in to_dedup[contig_name]:
				var parent = to_dedup[contig_name][record[4]["Parent"]]
				if record[0] == parent[0] and record[1] == parent[1]:
					to_delete.append(record)
		
		for x in to_delete:
			to_dedup[contig_name].erase(x)
		
		if contig_name not in annotations:
			annotations[contig_name] = []
			
		annotations[contig_name].append_array(to_dedup[contig_name].values())

	for x in to_dedup:
		annotations[x].sort() # ie sorts by start position
	print("Loaded GFF file ok:", filename)
	return annotations
