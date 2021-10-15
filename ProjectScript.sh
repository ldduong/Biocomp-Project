#concatenate ref_sequences into 1 file for each gene
cat ref_sequences/hsp* >REF_hsp70.fasta
echo "hsp70 reference sequences concatenated"
cat ref_sequences/mcr* >REF_mcrA.fasta
echo "mcrA reference sequences concatenated"

#muscle alignment for each gene
./muscle3.8.31_i86linux64 -in REF_hsp70.fasta -out ALIGN_hsp70.seqs
./muscle3.8.31.i86linux64 -in REF_mcrA.fasta -out ALIGN_mcrA.fasta

#hmmbuild for each gene
./hmmbuild BUILD_hsp70.hmm ALIGN_hsp70.seqs
./hmmbuild BUILD_mcrA.hmm ALIGN_mcrA.seqs

#hmmsearch in the provided proteomes, one by one, for each gene
cd proteomes
for proteome in *.fasta
do
../hmmsearch ../BUILD_hsp70.hmm $proteome >../SEARCH_proteomes/hsp70/$proteome.out
echo "$proteome searched for hsp70"
done
for proteome in *.fasta
do
../hmmsearch ../BUILD_mcrA.hmm $proteome >../SEARCH_proteomes/mcrA/$proteome.out
echo "$proteome searched for mcrA"
done

