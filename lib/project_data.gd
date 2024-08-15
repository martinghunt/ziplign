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
	#TODO check root_dir exists
	set_paths()
	load_genomes()
	load_blast_matches()


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
