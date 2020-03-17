```
# Reverse filename 

```
import sys
import argparse

def reverse(s:str)->str:
	return s[::-1]

def main(input_filename, output_filename):
	with open(output_filename, "w") as oh:
		with open(input_filename, "r") as fh:
			for line in fh:
				line = line.strip()
				if line.startswith(">"):
					oh.write(line + "\n")
				else:
					line = reverse(line)
					oh.write(line + "\n")

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description='Reverse Sequences in Fasta Files.')
	parser.add_argument('-i', dest='input_filename', action='store',
	                    help='input_filename for a .fasta file')
	parser.add_argument('-o', dest='output_filename', action='store',
	                    help='output_filename for a .fasta file')
	args = parser.parse_args()
	main(args.input_filename, args.output_filename)
