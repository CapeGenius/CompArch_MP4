import sys

infilename = "traffic_test_hex.txt"
outfilename0 = "instruction/instruction_0.txt"
outfilename1 = "instruction/instruction_1.txt"
outfilename2 = "instruction/instruction_2.txt"
outfilename3 = "instruction/instruction_3.txt"

infile = open(infilename)
outfile0 = open(outfilename0, "w")
outfile1 = open(outfilename1, "w")
outfile2 = open(outfilename2, "w")
outfile3 = open(outfilename3, "w")

for line in infile:
    outfile3.write(f"{line[0:2]}\n")
    outfile2.write(f"{line[2:4]}\n")
    outfile1.write(f"{line[4:6]}\n")
    outfile0.write(f"{line[6:8]}\n")

infile.close()
outfile0.close()
outfile1.close()
outfile2.close()
outfile3.close()
