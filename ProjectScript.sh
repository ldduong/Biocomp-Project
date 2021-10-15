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
done
echo "all proteomes searched for hsp70"

for proteome in *.fasta
do
../hmmsearch ../BUILD_mcrA.hmm $proteome >../SEARCH_proteomes/mcrA/$proteome.out
done
echo "all proteomes searched for mcrA"

#search through previous resultant files for the number of matches that passed the fwd filter
cd ../SEARCH_proteomes/hsp70

for searchedproteome in *.out
do
cat $searchedproteome | grep -E "target sequence database">>../tempMATCHES_hsp70.txt
cat $searchedproteome | grep -E "Passed Fwd filter:" >>../tempMATCHES_hsp70.txt
done
cd ..
grep -E -o "proteome_[0-9]*" tempMATCHES_hsp70.txt > temp_hsp70_proteomenumbers
grep -E -o " [0-9] " tempMATCHES_hsp70.txt > temp_hsp70_matchnumbers
paste temp_hsp70_proteomenumbers temp_hsp70_matchnumbers | column -s $'\t' -t > MATCHES_hsp70.txt
rm temp*
echo "See matches in proteomes for hsp70 in SEARCH_proteomes/MATCHES_hsp70.txt"

cd mcrA

for searchedproteome in *.out
do
cat $searchedproteome | grep -E "target sequence database">>../tempMATCHES_mcrA.txt
cat $searchedproteome | grep -E "Passed Fwd filter:" >>../tempMATCHES_mcrA.txt
done
cd ..
grep -E -o "proteome_[0-9]*" tempMATCHES_mcrA.txt > temp_mcrA_proteomenumbers
grep -E -o " [0-9] " tempMATCHES_mcrA.txt > temp_mcrA_matchnumbers
paste temp_mcrA_proteomenumbers temp_mcrA_matchnumbers | column -s $'\t' -t > MATCHES_mcrA.txt
rm temp*

echo "See matches in proteomes for mcrA in SEARCH_proteomes/MATCHES_mcrA.txt"


