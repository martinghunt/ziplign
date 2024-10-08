class_name ProjectData

var fastaq_lib = preload("fastaq.gd").new()
var blast_lib = preload("blast.gd").new()

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



func _init():
	init_from_dir("res://example_data")


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
	elif FileAccess.file_exists(dir_path):
		load_from_serialized_file(dir_path)

func set_paths():
	print("set paths. root_dir:", root_dir)
	genome_top_file_prefix = root_dir.path_join("g1")
	genome_bottom_file_prefix = root_dir.path_join("g2")
	genome_top_fa_file = genome_top_file_prefix + ".fa"
	genome_bottom_fa_file = genome_bottom_file_prefix + ".fa"
	genome_top_annot_file = genome_top_file_prefix + ".annot"
	genome_bottom_annot_file = genome_bottom_file_prefix + ".annot"
	blast_file = root_dir.path_join("blast")
	blast_db = root_dir.path_join("blast_db")


func import_genomes(top_fasta, bottom_fasta):
	fastaq_lib.to_fasta(top_fasta, genome_top_file_prefix)
	fastaq_lib.to_fasta(bottom_fasta, genome_bottom_file_prefix)


func load_genomes():
	genome_seqs = {} # saves some ram if project already loaded
	genome_seqs["top"] = fastaq_lib.load_fasta_file(genome_top_fa_file)
	genome_seqs["bottom"] = fastaq_lib.load_fasta_file(genome_bottom_fa_file)


func load_blast_matches():
	blast_matches.clear() # saves some ram if proejct already loaded
	blast_matches = blast_lib.load_tsv_file(blast_file)


func run_blast():
	blast_lib.run_blast(root_dir)


func save_as_serialized_file(outfile):
	print("Save project to file: ", outfile)
	var file = FileAccess.open(outfile, FileAccess.WRITE)
	file.store_var(blast_matches, true)
	file.store_var(genome_seqs, true)


func load_from_serialized_file(infile):
	print("Loading project from file: ", infile)
	var file = FileAccess.open(infile, FileAccess.READ)
	blast_matches.clear()
	genome_seqs.clear()
	blast_matches = file.get_var()
	genome_seqs = file.get_var()


func flip_all_blast_matches(top_or_bottom):
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
		d["rev"] = not d["rev"]
		var new_start = len(genome_seqs[top_or_bottom]["seqs"][d[len_key]]) - d[end_key]
		d[end_key] = len(genome_seqs[top_or_bottom]["seqs"][d[len_key]]) - d[start_key]
		d[start_key] = new_start


func reverse_complement_genome(top_or_bottom):
	flip_all_blast_matches(top_or_bottom)
	for name in genome_seqs[top_or_bottom]["names"]:
		genome_seqs[top_or_bottom]["seqs"][name] = fastaq_lib.revcomp(genome_seqs[top_or_bottom]["seqs"][name])
