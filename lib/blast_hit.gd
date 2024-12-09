class_name BlastHit


var qry_id: int
var ref_id: int
var qstart: int
var qend: int
var rstart: int
var rend: int
var pcid: float
var is_rev: bool
var aln_data: PackedInt32Array


func _init(qid, rid, pc, qs, qe, rs, re, rev, aln, aln_in_fives=true):
	qry_id = qid
	ref_id = rid
	qstart = qs
	qend = qe
	rstart = rs
	rend = re
	pcid = pc
	is_rev = rev
	if aln_in_fives:
		aln_data.resize(5 * len(aln_data))
		for a in aln:
			for x in a:
				aln_data.append(x)
	else:
		aln_data = aln


func qry_name():
	return Globals.proj_data.genome_seqs[Globals.TOP]["contigs"][qry_id]["name"]


func ref_name():
	return Globals.proj_data.genome_seqs[Globals.BOTTOM]["contigs"][ref_id]["name"]


func length():
	return 1 + max(qend - qstart, rend - rstart)


func flip(top_or_bottom, contig_index):
	if contig_index != null and \
		(
			(top_or_bottom == Globals.TOP and contig_index != qry_id) \
		 or (top_or_bottom == Globals.BOTTOM and contig_index != ref_id)
		):
		return

	is_rev = not is_rev
	if top_or_bottom == Globals.TOP:
		var new_start = 1 + len(Globals.proj_data.genome_seqs[Globals.TOP]["contigs"][qry_id]["seq"]) - qend
		qend = 1 + len(Globals.proj_data.genome_seqs[Globals.TOP]["contigs"][qry_id]["seq"]) - qstart
		qstart = new_start

		for i in range(0, len(aln_data), 5):
			var var_type = aln_data[i+4]
			var new_qstart = qend - qstart - aln_data[i+1]
			var new_qend = qend - qstart - aln_data[i]
			var new_rstart = rend - rstart - aln_data[i+3]
			var new_rend = rend - rstart - aln_data[i+2]
			aln_data[i] = var_type
			aln_data[i+1] = new_rend
			aln_data[i+2] = new_rstart
			aln_data[i+3] = new_qend
			aln_data[i+4] = new_qstart

		aln_data.reverse()
	else:
		var new_start = 1 + len(Globals.proj_data.genome_seqs[Globals.BOTTOM]["contigs"][ref_id]["seq"]) - rend
		rend = 1 + len(Globals.proj_data.genome_seqs[Globals.BOTTOM]["contigs"][ref_id]["seq"]) - rstart
		rstart = new_start


func to_array():
	return [qry_id, ref_id, pcid, qstart, qend, rstart, rend, is_rev, aln_data]
