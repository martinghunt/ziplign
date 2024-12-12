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
var genome_seqs = {Globals.TOP: {}, Globals.BOTTOM: {}}
var blast_hits = []
var annotation = {Globals.TOP: {}, Globals.BOTTOM: {}}
var data_loaded = false
var blast_program = "blastn"


func _init():
	# stick in some dummy data the user will never see, just to stop scene
	# initialization crashing everything. We don't need blast matches, just
	# the genomes
	genome_seqs = {
		Globals.TOP: {"order": [0], "contigs": [{"name": "1", "descr": "foo", "seq": "ACGTA"}]},
		Globals.BOTTOM: {"order": [0], "contigs": [{"name": "2", "descr": "bar", "seq": "ACGTAT"}]},
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
		load_blast_hits()
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
	return [err1, err2]
	

func load_genomes():
	genome_seqs = {} # saves some ram if project already loaded
	genome_seqs[Globals.TOP] = fastaq_lib.load_fasta_file(genome_top_fa_file)
	genome_seqs[Globals.BOTTOM] = fastaq_lib.load_fasta_file(genome_bottom_fa_file)


func load_blast_hits():
	blast_hits.clear() # saves some ram if project already loaded
	blast_hits = blast_lib.load_tsv_file(blast_file, genome_seqs[Globals.TOP], genome_seqs[Globals.BOTTOM])


func load_annotation_files():
	annotation = {Globals.TOP: {}, Globals.BOTTOM: {}}
	if FileAccess.file_exists(genome_top_annot_file):
		annotation[Globals.TOP] = gff_lib.load_gff_file(genome_top_annot_file, genome_seqs[Globals.TOP])
	if FileAccess.file_exists(genome_bottom_annot_file):
		annotation[Globals.BOTTOM] = gff_lib.load_gff_file(genome_bottom_annot_file, genome_seqs[Globals.BOTTOM])


func run_blast():
	return blast_lib.run_blast(root_dir, blast_program)


func save_as_serialized_file(outfile):
	print("Save project to file: ", outfile)
	if not data_loaded:
		OS.alert("Cannot save data because nothing loaded", "ERROR!")
	else:
		var file = FileAccess.open(outfile, FileAccess.WRITE)
		var hits = []
		for x in blast_hits:
			hits.append(x.to_array())
		file.store_var(hits, true)
		file.store_var(genome_seqs, true)
		file.store_var(annotation, true)


func load_from_serialized_file(infile):
	print("Loading project from file: ", infile)
	var file = FileAccess.open(infile, FileAccess.READ)
	blast_hits.clear()
	genome_seqs.clear()
	blast_hits.clear()
	blast_hits = file.get_var()
	for i in range(len(blast_hits)):
		blast_hits[i] = blast_lib.BlastHitClass.new(
			blast_hits[i][0],
			blast_hits[i][1],
			blast_hits[i][2],
			blast_hits[i][3],
			blast_hits[i][4],
			blast_hits[i][5],
			blast_hits[i][6],
			blast_hits[i][7],
			blast_hits[i][8],
			false
		)
	genome_seqs = file.get_var()
	annotation = file.get_var()
	if annotation == null:
		annotation = {Globals.TOP: {}, Globals.BOTTOM: {}}
	set_data_loaded()


func flip_all_blast_hits(top_or_bottom, contig_index=null):
	for m in blast_hits:
		m.flip(top_or_bottom, contig_index)


func reverse_complement_annotation_one_contig(top_or_bottom, contig_index):
	if contig_index not in annotation[top_or_bottom]:
		return
	var ctg_length = contig_length(top_or_bottom, contig_index)
	for a in annotation[top_or_bottom][contig_index]:
		a[3] = not a[3] # flip the strand
		var start = ctg_length - a[1]
		a[1] = ctg_length - a[0]
		a[0] = start


func reverse_complement_annotation(top_or_bottom):
	for i in annotation[top_or_bottom]:
		reverse_complement_annotation_one_contig(top_or_bottom, i)


func reverse_complement_genome(top_or_bottom):
	flip_all_blast_hits(top_or_bottom)
	reverse_complement_annotation(top_or_bottom)
	for ctg in genome_seqs[top_or_bottom]["contigs"]:
		ctg["seq"] = fastaq_lib.revcomp(ctg["seq"])


func reverse_complement_one_contig(top_or_bottom, contig_index):
	flip_all_blast_hits(top_or_bottom, contig_index)
	reverse_complement_annotation_one_contig(top_or_bottom, contig_index)
	genome_seqs[top_or_bottom]["contigs"][contig_index]["seq"] = fastaq_lib.revcomp(genome_seqs[top_or_bottom]["contigs"][contig_index]["seq"])


func move_contig(top_or_bottom, ctg_index_to_move, move_type):
	var to_move_order_i = genome_seqs[top_or_bottom]["order"].find(ctg_index_to_move)
	var other_order_i
	if move_type == "left":
		other_order_i = to_move_order_i - 1
	elif move_type == "start":
		other_order_i = 0
	elif move_type == "right":
		other_order_i = to_move_order_i + 1
	elif move_type == "end":
		other_order_i = len(genome_seqs[top_or_bottom]["order"]) - 1
		
	if to_move_order_i == other_order_i \
	  or other_order_i < 0 or other_order_i > len(genome_seqs[top_or_bottom]["order"]) - 1:
		return

	if abs(to_move_order_i - other_order_i) == 1:
		# no need to pop/insert, just swap the elements. More efficient
		var tmp_i = genome_seqs[top_or_bottom]["order"][to_move_order_i]
		genome_seqs[top_or_bottom]["order"][to_move_order_i] = genome_seqs[top_or_bottom]["order"][other_order_i]
		genome_seqs[top_or_bottom]["order"][other_order_i] = tmp_i
	else:
		var i = genome_seqs[top_or_bottom]["order"].pop_at(to_move_order_i)
		genome_seqs[top_or_bottom]["order"].insert(other_order_i, i)


func set_data_loaded():
	data_loaded = true
	project_data_loaded.emit()


func has_annotation():
	return len(annotation[Globals.TOP]) > 0 or len(annotation[Globals.BOTTOM]) > 0


func get_match_text(i):
	var m = blast_hits[i]
	return m.qry_name() + ":" + str(m.qstart) + "-" + str(m.qend) + \
		" / " + m.ref_name() + ":" + str(m.rstart) + "-" + str(m.rend) + \
		" / pcid:" + str(m.pcid)


func contig_name(top_or_bottom, contig_id):
	return genome_seqs[top_or_bottom]["contigs"][contig_id]["name"]


func contig_length(top_or_bottom, contig_id):
	return len(genome_seqs[top_or_bottom]["contigs"][contig_id]["seq"])


func contig_fasta_subseq(top_or_bottom, contig_id, start, end, reverse=false):
	if reverse:
		var t = start
		start = end
		end = t
	var name
	var seq
	if start < end:
		name = ">" + contig_name(top_or_bottom, contig_id) + ":" + str(start + 1) + "-" + str(end + 1)
		seq = Globals.proj_data.genome_seqs[top_or_bottom]["contigs"][contig_id]["seq"].substr(start, 1 + end - start)
	else:
		name = ">" + contig_name(top_or_bottom, contig_id) + ":" + str(end + 1) + "-" + str(start + 1) + ":reverse_strand"
		seq = fastaq_lib.revcomp(
				Globals.proj_data.genome_seqs[top_or_bottom]["contigs"][contig_id]["seq"].substr(end, 1 + start - end)
		)

	var line_len = Globals.userdata.config.get_value("other", "fasta_line_length", 0)
	if line_len == 0:
		return [name, seq]
		
	var seq_lines = []
	var  i = 0
	while i < len(seq):
		seq_lines.append(seq.substr(i, line_len))
		i += line_len
	return [name] + seq_lines
	

func range_to_seq_lines(top_or_bottom, range_start, range_end):
	var is_rev = range_start[0] > range_end[0] or (range_start[0] == range_end[0] and range_start[1] > range_end[1])
	if range_start[0] == range_end[0]:
		var lines = contig_fasta_subseq(top_or_bottom, range_start[0], range_start[1], range_end[1])
		return lines
	
	if is_rev:
		var t = range_start
		range_start = range_end
		range_end = t
	
	var out = []
	for ctg_index in range(range_start[0], range_end[0] + 1):
		if ctg_index == range_start[0]:
			out.append_array(contig_fasta_subseq(top_or_bottom, ctg_index,
				range_start[1], contig_length(top_or_bottom, range_start[0])-1,
				is_rev))
		elif ctg_index < range_end[0]:
			out.append_array(contig_fasta_subseq(top_or_bottom, ctg_index,
				0, contig_length(top_or_bottom, ctg_index)-1, is_rev))
		else:
			out.append_array(contig_fasta_subseq(
				top_or_bottom, ctg_index, 0, range_end[1], is_rev))
	
	return out


func contig_fasta_lines(top_or_bottom, contig_id):
	return [">" + contig_name(top_or_bottom, contig_id),
		genome_seqs[top_or_bottom]["contigs"][contig_id]["seq"],
	]
