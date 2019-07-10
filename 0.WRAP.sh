#!/bin/bash


######### User, fill in these variables:

SCRIPT_PATH="/scratch2/gloukatou/fair_project/char-lm-code-master/acqdiv_split/" #path for scripts
ACQDIV_PATH="/Users/lscpuser/Downloads/" #path for acqdiv data 
CSV_PATH="/scratch2/gloukatou/fair_project/wordseg_whole_acqdiv/acqdiv_final_data/" #path for utterances.csv files, as extracted from ACQDIV
LANGUAGE="Japanese" #language, others: Sesotho, Yucatec, Russian, Inuktitut, Chintang, Turkish, Indonesian
RESULT_PATH="/scratch2/gloukatou/fair_project/wordseg_whole_acqdiv/final_data/" #path for segmentation results




############################  User, you are done :)

mkdir ${CSV_PATH}/${LANGUAGE} #there must be a subfolder for each language

mkdir $RESULT_PATH/resultsACL #folder with ACL results 

#####extract csv from Robject with R script
Rscript  ${SCRIPT_PATH}1.split_clean_phonemize.R CSV_PATH ${ACQDIV_PATH}segmented_acqdiv_corpus_2018-08-27.Rdata ${ACQDIV_PATH}acqdiv_corpus_2018-08-27.rda $LANGUAGE

#####convert .csv to .tsv and remove child speech
python ${SCRIPT_PATH}2.prepareAcqdiv.py --language $LANGUAGE --corpusinit ${CSV_PATH} --corpusfinal ${CSV_PATH}

#####segment with wordseg
bash ${SCRIPT_PATH}3.segment.sh ${LANGUAGE} ${CSV_PATH} ${RESULT_PATH} $SCRIPT_PATH


#####evaluate & stats 
bash ${SCRIPT_PATH}4.collapse_results.sh $RESULT_PATH 

#####ACL results

# run markdown (!parameters in file)
# 5.ACL_markdown.Rmd

 




