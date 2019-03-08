#!/bin/bash

module load anaconda/3
source activate fair_project

SCRIPT_PATH="/user/fair_project/char-lm-code-master/acqdiv_split/"
LANGUAGE="Japanese" # others are: Japanese Sesotho Yucatec, Russian, Inuktitut, Chintang, Turkish
RESULT_PATH="/user/fair_project/wordseg_whole_acqdiv/results_final"
CORPUS_PATH="/user/fair_project/wordseg_whole_acqdiv/acqdiv_final_data_test/" #need to create folder for each language inside

#####extract csv from Robject with R script
#Rscript  ${SCRIPT_PATH}split_clean_phonemize.r CORPUS_PATH


#####convert .csv to .tsv and remove all child speech
#python ${SCRIPT_PATH}prepareAcqdiv.py --language $LANGUAGE --corpusinit ${CORPUS_PATH} --corpusfinal ${CORPUS_PATH}

###segment
#bash pickandsegment.sh ${LANGUAGE} ${CORPUS_PATH} ${RESULT_PATH} $CURRENT


#####evaluate & stats 
bash collapse_results.sh $RESULT_PATH 
###!!check paths inside file
Rscript  ${SCRIPT_PATH}ACL_sub.R 




