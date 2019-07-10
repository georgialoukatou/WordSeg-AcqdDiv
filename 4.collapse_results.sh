RESFOLDER=$1

#Script by Alex Cristia
#Modifications by Georgia Loukatou

for THISRES in $RESFOLDER/*eval* 
do

str=${THISRES}

if [[ $str != *summary* ]]; then  #discard summary files, keep only files with fscores

echo $THISRES
echo writing $THISRES into $RESFOLDER/results.txt
        # flip the column within each result into a comma-separated horizontal vector
        res=`cat $THISRES | awk '{print $2}' | tr '\n' ',' | sed 's/,$//'`
        echo "$THISRES,$res" >> "${RESFOLDER}/results.txt"
fi
done

header="folder \
       token_precision token_recall token_fscore \
        type_precision type_recall type_fscore \
        boundary_precision boundary_recall boundary_fscore \
       boundary_NE_precision boundary_NE_recall boundary_NE_fscore"
header=`echo $header | tr -s ' ' | tr ' ' ','`
sed -i "1s/^/$header\n/" $RESFOLDER/results.txt

for THISRES in $RESFOLDER/*stat* 
do

str=${THISRES}

echo writing $THISRES into $RESFOLDER/stats.txt
        # flip the column within each result into a comma-separated horizontal vector
        res=`cat $THISRES | awk '{print $3}' | tr '\n' ',' | sed 's/,$//'`
        echo "$THISRES,$res" >> $RESFOLDER/stats.txt

done

header="folder \
        corpus_nutts corpus_nutts_single_word \
        corpus_mattr corpus_entropy \
        words_tokens words_types words_hapaxes \
        syllables_tokens syllables_types syllables_hapaxes \
        phones_tokens phones_types phones_hapaxes"
header=`echo $header | tr -s ' ' | tr ' ' ','`
sed -i "1s/^/$header\n/" $RESFOLDER/stats.txt
