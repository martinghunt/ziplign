func load_gff_file(filename, genome):
	print("Loading GFF file:", filename)
	var file = FileAccess.open(filename, FileAccess.READ)
	var lines = file.get_as_text().rstrip("\n").split("\n")
	var to_dedup = {}
	var annotations = {}
	var ctg_name_lookup = {}
	for i in genome["order"]:
		ctg_name_lookup[genome["contigs"][i]["name"]] = i

	for line in lines:
		if line[0] == "#" or not "\t" in line:
			continue

		var fields = line.rstrip("\r").split("\t")
		# example line:
		# g1.c1  .  gene  900  1400  .  +  .  ID=gene1;foo=bar;name=name1
		var ctg_index = ctg_name_lookup[fields[0]]
		if ctg_index not in to_dedup:
			to_dedup[ctg_index] = {}
			annotations[ctg_index] = []
		
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
			to_dedup[ctg_index][tags["ID"]] = to_add
		else:
			annotations[ctg_index].append(to_add)
	
	for i in to_dedup:
		var to_delete = []
		for name in to_dedup[i]:
			var record = to_dedup[i][name]
			if "Parent" in record[4] and record[4]["Parent"] in to_dedup[i]:
				var parent = to_dedup[i][record[4]["Parent"]]
				if record[0] == parent[0] and record[1] == parent[1]:
					to_delete.append(record)
		
		for x in to_delete:
			to_dedup[i].erase(x)
		
		if i not in annotations:
			annotations[i] = []
			
		annotations[i].append_array(to_dedup[i].values())

	for i in to_dedup:
		annotations[i].sort() # ie sorts by start position
	print("Loaded GFF file ok:", filename)
	return annotations
