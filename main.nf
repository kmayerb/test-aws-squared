params.output_folder = "./pub"
params.batchfile = "./s3_files/manifest.csv"

Channel.from(file(params.batchfile))
         .splitCsv(header: true, sep: ",")
         .map { sample ->
         [sample.name, file(sample.filename)]}
         .set{ input_channel}


process REVERSE {
	tag "Reverse Sequences in a Fasta File"

	publishDir params.output_folder

	container "quay.io/kmayerb/aws-batch-conda-py3:0.0.1"

	input:
	set name, file(filename) from input_channel

	output:
	file("${name}.rev.fasta")

	script:
	"""
	reverse.py -i ${filename} -o ${name}.rev.fasta
	"""
	//python rev.py -i ${filename} -o ${name}.rev.fasta
	
}
