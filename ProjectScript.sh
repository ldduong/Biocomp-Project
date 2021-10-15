#Usage: bash ProjectScript.sh
#Fall 2021 Biocomputing class
#Group: Loan Duong, Samir El Idrissi

#Overall steps: 
#1) Create concatenated file of the reference sequences for each gene. 
#2) Use the muscle tool to make alignment files for each gene. 
#3) Use hmmbuild tool to generate search images for each gene. 
#4) Use hmmsearch to search for the previously generated search image within 
#   each of the provided proteomes for each gene. Results are redircted to .out files. 
#5) From the resultant files, pull out the number of matches for each gene within each proteome.
#   Results of this are redirected to a new file that consists of the proteome #, followed by the
#   number of matches. The number of matches is based on the "passed fwd filter" result of the
#   hmmsearch. 
#6) Final filtering. Filter the mcrA matches for only the proteomes with at least 1 match. 
#   Filter the hsp70 matches for only those with at least 3 matches. Send all this to a new text file,
#   and then sort and filter for those that have duplicates. These will be the proteomes that have passed
#   both filters. The results will be returned to stdout as well and sent to a text file. 


#concatenate ref_sequences into 1 file for each gene
cat ref_sequences/hsp* >REF_hsp70.fasta
echo "hsp70 reference sequences concatenated"
cat ref_sequences/mcr* >REF_mcrA.fasta
echo "mcrA reference sequences concatenated"

#muscle alignment for each gene
./muscle3.8.31_i86linux64 -in REF_hsp70.fasta -out ALIGN_hsp70.seqs
./muscle3.8.31_i86linux64 -in REF_mcrA.fasta -out ALIGN_mcrA.seqs

#hmmbuild for each gene
./hmmbuild BUILD_hsp70.hmm ALIGN_hsp70.seqs
./hmmbuild BUILD_mcrA.hmm ALIGN_mcrA.seqs

#hmmsearch in the provided proteomes, one by one, for each gene
cd proteomes
for proteome in *.fasta
do
../hmmsearch ../BUILD_hsp70.hmm $proteome >../SEARCH_proteomes/hsp70/$proteome.out
done
echo "All proteomes have been searched for hsp70."

for proteome in *.fasta
do
../hmmsearch ../BUILD_mcrA.hmm $proteome >../SEARCH_proteomes/mcrA/$proteome.out
done
echo "All proteomes have been searched for mcrA."

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
echo 'Number of matches for hsp70 within each proteome'>hsp70/MATCHES_hsp70.txt
paste temp_hsp70_proteomenumbers temp_hsp70_matchnumbers | column -s $'\t' -t >> hsp70/MATCHES_hsp70.txt
rm temp*
cp hsp70/MATCHES_hsp70.txt ../SummaryMatches_hsp70.txt
echo "See matches in proteomes for hsp70 in SummaryMatches_hsp70.txt"

cd mcrA

for searchedproteome in *.out
do
cat $searchedproteome | grep -E "target sequence database">>../tempMATCHES_mcrA.txt
cat $searchedproteome | grep -E "Passed Fwd filter:" >>../tempMATCHES_mcrA.txt
done
cd ..
grep -E -o "proteome_[0-9]*" tempMATCHES_mcrA.txt > temp_mcrA_proteomenumbers
grep -E -o " [0-9] " tempMATCHES_mcrA.txt > temp_mcrA_matchnumbers
echo 'Number of matches for mcrA within each proteome'>mcrA/MATCHES_mcrA.txt
paste temp_mcrA_proteomenumbers temp_mcrA_matchnumbers | column -s $'\t' -t >> mcrA/MATCHES_mcrA.txt
rm temp*
cp mcrA/MATCHES_mcrA.txt ../SummaryMatches_mcrA.txt
echo "See matches in proteomes for mcrA in SummaryMatches_mcrA.txt"


#filtering: return which proteomes have at least 1 mcrA and more than 3 hsp70 copies
grep -E " [1-9]" mcrA/MATCHES_mcrA.txt > mcrA/FILTER_mcrA.txt
grep -E " [3-9]" hsp70/MATCHES_hsp70.txt > hsp70/FILTER_hsp70.txt
cat mcrA/FILTER_mcrA.txt >tempFilter.txt
cat hsp70/FILTER_hsp70.txt >>tempFilter.txt
rm ../CandidateProteomes.txt
echo "******************************RESULTS******************************************
*************************************************************************************
These are the candidate pH-resistant methanogen proteomes we recommend the student 
move forward with. They are methanogens in that they have at least one copy of 
mcrA and they demonstrate pH resistance in that they have at least 3 copies of HSP70.
This result is also printed in CandidateProteomes.txt. The summary tables have
been generated into SummaryMatches_hsp70.txt and SummaryMatches_mcrA.txt."
cat tempFilter.txt | sort | cut -d ' ' -f 1 | uniq -d

echo 'These are the proteomes we recommend the student move forward with.
They are methanogens in that they have at least one copy of mcrA and
they demonstrate pH resistance in that they have at least 3 copies of HSP70.'>../CandidateProteomes.txt

cat tempFilter.txt | sort | cut -d ' ' -f 1 | uniq -d >> ../CandidateProteomes.txt
echo "******************************END RESULT****************************************
Biocomputing Fall 2021
Group members: Loan Duong, Samir El Idrissi"
rm temp*
