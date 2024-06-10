class_name ProjectData

var fastaq_lib = preload("fastaq.gd").new()
var blast_lib = preload("blast.gd").new()

var root_dir = ""
var genome_top_file = ""
var genome_bottom_file = ""
var blast_file = ""
var blast_db = ""
var genome_seqs = {"top": {}, "bottom": {}}
var blast_matches = []


func create(dir_path):
	DirAccess.make_dir_absolute(dir_path)
	root_dir = dir_path
	set_paths()


func _init():
	init_from_dir("res://example_data")
	

func init_from_dir(dir_path):
	root_dir = dir_path
	#TODO check root_dir exists
	set_paths()
	load_genomes()
	load_blast_matches()


func set_paths():
	print("set paths. root_dir:", root_dir)
	genome_top_file = root_dir + "/g1.fa"
	genome_bottom_file = root_dir + "/g2.fa"
	blast_file = root_dir + "/blast"
	blast_db = root_dir + "/blast_db"


func import_genomes(top_fasta, bottom_fasta):
	fastaq_lib.to_fasta(top_fasta, genome_top_file)
	fastaq_lib.to_fasta(bottom_fasta, genome_bottom_file)


func load_genomes():
	genome_seqs = {} # saves some ram if project already loaded
	genome_seqs["top"] = fastaq_lib.load_fasta_file(genome_top_file)
	genome_seqs["bottom"] = fastaq_lib.load_fasta_file(genome_bottom_file)


func load_blast_matches():
	blast_matches.clear() # saves some ram if proejct already loaded
	blast_matches = blast_lib.load_tsv_file(blast_file)


func run_blast():
	blast_lib.blast_index(genome_bottom_file, blast_db)
	blast_lib.blastn(genome_top_file, blast_db, blast_file)
