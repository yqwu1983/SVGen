# download_and_format_database.sh
# C: Oct 23, 2015
# M: Jan 13, 2016
# A: Leandro Lima <leandrol@usc.edu>


if [ "$#" -ne 1 ]; then
    echo -e "\n\n\tYou have to pass a genome version as a parameter."
    echo -e "\tUsage: ./download_and_format_database.sh [genome_version]"
    echo -e "\n\tGenome versions accepted: hg19 and hg38\n\n"
    exit 1
fi


if [ "$1" != "hg19" ] && [ "$1" != "hg38" ]; then
    echo -e "\n\n\tUnknown genome. Accepted versions: hg19 and hg38\n\n"
    exit 1
fi


mkdir reference
cd reference

gv=$1 # genome version
zip_file=$gv""_1000g2015aug.zip

echo "Downloading frequencies of variants for" $gv.
wget http://www.openbioinformatics.org/annovar/download/$zip_file

unzip $zip_file
# mv $gv""_1000g2015aug/* .
rm $zip_file #$gv""_1000g2015aug

# Separating chromosomes in variant files
for pop in AFR ALL AMR EAS EUR SAS; do
    echo "Filtering variants for" $pop "population."
    echo -n "Chromosomes: "
    for chrom in {1..22} X Y; do
        echo -n $chrom" "
        grep -w ^$chrom $gv""_$pop.sites.2015_08.txt > $gv""_$pop.sites.2015_08.chrom$chrom.txt
    done
    echo -e "\nDone.\n"
done


# Download fasta references
echo "Downloading fasta files for "$gv
mkdir $gv
if [ "$gv" == "hg19" ]; then
    targz=chromFa.tar.gz
else
    targz=$gv.chromFa.tar.gz
fi

wget http://hgdownload.cse.ucsc.edu/goldenPath/$gv/bigZips/$targz
tar -xvzf $targz --directory=$gv

if [ "$gv" == "hg38" ]; then
    mv hg38/chroms/* hg38/
    rmdir hg38/chroms
fi


# Uncomment the lines below in case you want to create bwa indexes

# cd $gv
# 
# qsub 2> qsub_test.txt
# qsub_test=`grep -c 'not found' qsub_test.txt`
# 
# if [ "$qsub_test" eq "1" ]; then
#     for chrom in {1..22} X Y; do
#         echo "bwa index chr$chrom.fa" | qsub -cwd -V -N chr$chrom""_index
#     done
# else
#     for chrom in {1..22} X Y; do
#         echo "bwa index chr$chrom.fa" | sh
#     done
# fi
# 
# cd ..
