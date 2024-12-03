class_name ProjectData

signal project_data_loaded

var fastaq_lib = preload("fastaq.gd").new()
var blast_lib = preload("blast.gd").new()
var gff_lib = preload("gff.gd").new()

var root_dir = ""
var genome_top_file_prefix = ""
var genome_bottom_file_prefix = ""
var genome_top_fa_file = ""
var genome_bottom_fa_file = ""
var genome_top_annot_file = ""
var genome_bottom_annot_file = ""
var blast_file = ""
var blast_db = ""
var genome_seqs = {"top": {}, "bottom": {}}
var blast_matches = []
var annotation = {"top": {}, "bottom": {}}
var data_loaded = false
var blast_program = "blastn"


func _init():
	# stick in some dummy data the user will never see, just to stop scene
	# initialization crashing everything. We don't need blast matches, just
	# the genomes
	genome_seqs = {
		"top": {"names": ["1"], "seqs": {"1":"ACGTA"}},
		"bottom": {"names": ["2"], "seqs": {"2":"ACGTAT"}},
	}
	data_loaded = false


func create(dir_path):
	root_dir = dir_path
	set_paths()
	delete_all_files()
	DirAccess.make_dir_absolute(dir_path)




func delete_all_files():
	if not DirAccess.dir_exists_absolute(root_dir):
		return
	
	var files = DirAccess.get_files_at(root_dir)
	for f in files:
		print("delete: ", root_dir.path_join(f))
		DirAccess.remove_absolute(root_dir.path_join(f))
	
	
func init_from_dir(dir_path):
	root_dir = dir_path
	if DirAccess.dir_exists_absolute(dir_path):
		set_paths()
		load_genomes()
		load_blast_matches()
		load_annotation_files()
	elif FileAccess.file_exists(dir_path):
		load_from_serialized_file(dir_path)
	set_data_loaded()


func set_paths():
	print("set paths. root_dir:", root_dir)
	genome_top_file_prefix = root_dir.path_join("g1")
	genome_bottom_file_prefix = root_dir.path_join("g2")
	genome_top_fa_file = genome_top_file_prefix + ".fa"
	genome_bottom_fa_file = genome_bottom_file_prefix + ".fa"
	genome_top_annot_file = genome_top_file_prefix + ".gff"
	genome_bottom_annot_file = genome_bottom_file_prefix + ".gff"
	blast_file = root_dir.path_join("blast")
	blast_db = root_dir.path_join("blast_db")


func get_genome(filename, file_type, outprefix):
	if file_type == "file":
		return fastaq_lib.to_fasta(filename, outprefix)
	elif file_type == "accession":
		return fastaq_lib.download_genome(filename, outprefix)
	else:
		return -1

func import_genomes(top_fasta, top_type, bottom_fasta, bottom_type):
	var err1 = get_genome(top_fasta, top_type, genome_top_file_prefix)
	var err2 = get_genome(bottom_fasta, bottom_type, genome_bottom_file_prefix)
	print("import_genomes END. going to return: ", [err1, err2])
	return [err1, err2]
	

func load_genomes():
	genome_seqs = {} # saves some ram if project already loaded
	genome_seqs["top"] = fastaq_lib.load_fasta_file(genome_top_fa_file)
	genome_seqs["bottom"] = fastaq_lib.load_fasta_file(genome_bottom_fa_file)


func load_blast_matches():
	blast_matches.clear() # saves some ram if project already loaded
	blast_matches = blast_lib.load_tsv_file(blast_file)


func load_annotation_files():
	annotation = {"top": {}, "bottom": {}}
	if FileAccess.file_exists(genome_top_annot_file):
		annotation["top"] = gff_lib.load_gff_file(genome_top_annot_file)
	if FileAccess.file_exists(genome_bottom_annot_file):
		annotation["bottom"] = gff_lib.load_gff_file(genome_bottom_annot_file)


func run_blast():
	return blast_lib.run_blast(root_dir, blast_program)


func save_as_serialized_file(outfile):
	print("Save project to file: ", outfile)
	if not data_loaded:
		OS.alert("Cannot save data because nothing loaded", "ERROR!")
	else:
		var file = FileAccess.open(outfile, FileAccess.WRITE)
		file.store_var(blast_matches, true)
		file.store_var(genome_seqs, true)
		file.store_var(annotation, true)


func load_from_serialized_file(infile):
	print("Loading project from file: ", infile)
	var file = FileAccess.open(infile, FileAccess.READ)
	blast_matches.clear()
	genome_seqs.clear()
	blast_matches = file.get_var()
	genome_seqs = file.get_var()
	annotation = file.get_var()
	if annotation == null:
		annotation = {"top": {}, "bottom": {}}
	set_data_loaded()


func flip_all_blast_matches(top_or_bottom, contig_name=null):
	var len_key = ""
	var start_key = ""
	var end_key = ""
	if top_or_bottom == "top":
		len_key = "qry"
		start_key = "qstart"
		end_key  = "qend"
	else:
		len_key = "ref"
		start_key = "rstart"
		end_key = "rend"
		
	for d in blast_matches:
		if contig_name != null \
		and ((top_or_bottom == "top" and d["qry"] != contig_name) \
			 or (top_or_bottom == "bottom" and d["ref"] != contig_name)):
			continue
		d["rev"] = not d["rev"]
		var new_start = 1 + len(genome_seqs[top_or_bottom]["seqs"][d[len_key]]) - d[end_key]
		d[end_key] = 1 + len(genome_seqs[top_or_bottom]["seqs"][d[len_key]]) - d[start_key]
		d[start_key] = new_start
		if top_or_bottom == "top":
			d["aln_data"].reverse()
			for l in d["aln_data"]:
				new_start = d["qend"] - d["qstart"] - l[1]
				l[1] = d["qend"] - d["qstart"] - l[0]
				l[0] = new_start
				new_start = d["rend"] - d["rstart"] - l[3]
				l[3] = d["rend"] - d["rstart"] - l[2]
				l[2] = new_start


func reverse_complement_annotation_one_contig(top_or_bottom, contig_name):
	if contig_name not in annotation[top_or_bottom]:
		return
	var contig_length = len(genome_seqs[top_or_bottom]["seqs"][contig_name])
	for a in annotation[top_or_bottom][contig_name]:
		a[3] = not a[3] # flip the strand
		var start = contig_length - a[1]
		a[1] = contig_length - a[0]
		a[0] = start


func reverse_complement_annotation(top_or_bottom):
	for name in annotation[top_or_bottom]:
		reverse_complement_annotation_one_contig(top_or_bottom, name)


func reverse_complement_genome(top_or_bottom):
	flip_all_blast_matches(top_or_bottom)
	reverse_complement_annotation(top_or_bottom)
	for name in genome_seqs[top_or_bottom]["names"]:
		genome_seqs[top_or_bottom]["seqs"][name] = fastaq_lib.revcomp(genome_seqs[top_or_bottom]["seqs"][name])


func reverse_complement_one_contig(top_or_bottom, contig_name):
	flip_all_blast_matches(top_or_bottom, contig_name)
	reverse_complement_annotation_one_contig(top_or_bottom, contig_name)
	genome_seqs[top_or_bottom]["seqs"][contig_name] = fastaq_lib.revcomp(genome_seqs[top_or_bottom]["seqs"][contig_name])


func move_contig(top_or_bottom, from_i, to_i):
	if from_i == to_i \
	  or to_i < 0 or to_i > len(genome_seqs[top_or_bottom]["names"]) \
	  or from_i < 0 or from_i > len(genome_seqs[top_or_bottom]["names"]):
		return
	
	if abs(from_i - to_i) == 1:
		# no need to pop/insert, just swap the elements. More efficient
		var name = genome_seqs[top_or_bottom]["names"][from_i]
		genome_seqs[top_or_bottom]["names"][from_i] = genome_seqs[top_or_bottom]["names"][to_i]
		genome_seqs[top_or_bottom]["names"][to_i] = name
	else:
		var name = genome_seqs[top_or_bottom]["names"].pop_at(from_i)
		genome_seqs[top_or_bottom]["names"].insert(to_i, name)


func set_data_loaded():
	data_loaded = true
	project_data_loaded.emit()


func has_annotation():
	return len(annotation["top"]) > 0 or len(annotation["bottom"]) < 0



func get_match_text(match_id):
	var d = blast_matches[match_id]
	return d["qry"] + ":" + str(d["qstart"]) + "-" + str(d["qend"]) + " / " + d["ref"] + ":" + str(d["rstart"]) + "-" + str(d["rend"])  + " / pcid:" + str(d["pc"])
