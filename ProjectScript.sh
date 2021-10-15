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
for proteome in proteomes/proteome_*.fasta
do
./hmmsearch BUILD_hsp70.hmm proteomes/$proteome_*.fasta >SEARCH_proteome_$.txt
echo "proteome_$.fasta searched"
done
