#Usage: bash ProjectScript.sh

#concatenate ref_sequences into 1 file for each gene
cat ref_sequences/hsp* >REF_hsp70.fasta
echo "hsp70 reference sequences concatenated"
sort tempFilter.txt | uniq -d
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

#filtering: return which proteomes have at least 1 mcrA and more than 3 hsp70 copies
grep -E " [1-9]" MATCHES_mcrA.txt > FILTER_mcrA.txt
echo "see FILTER_mcrA.txt for proteomes with at least copy of mcrA"
grep -E " [3-9]" MATCHES_hsp70.txt > FILTER_hsp70.txt
echo "see FILTER_hsp.txt for proteomes with at least 3 copies of hsp70"
cat FILTER_mcrA.txt >tempFilter.txt
cat FILTER_hsp70.txt >>tempFilter.txt
echo "*************************RESULTS****************************************
These are the proteomes we recommend the student move forward with. 
They are methanogenes in that they have at least one copy of mcrA and 
they demonstrate pH resistance in that they have at least 3 copies of HSP70.
This result is also printed in RecommendedProteomes.txt"
cat tempFilter.txt | sort | cut -d ' ' -f 1 | uniq -d
cat tempFilter.txt | sort | cut -d ' ' -f 1 | uniq -d > ../RecommendedProteomes.txt

