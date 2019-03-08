#!/bin/bash

#to call using WRAP.sh
#SBATCH --job-name=seg_fair

module load anaconda/3
source activate wordseg


#######do

LANGUAGE=$1
CORPUS_PATH=$2
LANGUAGE_FOLDER="${CORPUS_PATH}${LANGUAGE}"
RESULT_PATH=$3
CURRENT=$4



##create file with train, test, dev corpus concatenated
#cat ${LANGUAGE_FOLDER}/utterances_*.tsv >> ${LANGUAGE_FOLDER}/utterances_all.tsv


##select and extract segmented.utterances column, prepare for wordseg
#WORD="segmented.utterance"; 
#NUMBER=$(head -n1 ${LANGUAGE_FOLDER}/utterances.tsv | tr "\t" "\n" | grep -n $WORD) 
#IFS=":" read -ra ADDR <<< "${NUMBER}"
#cut -f ${ADDR[0]} ${LANGUAGE_FOLDER}/utterances.tsv > ${RESULT_PATH}/${LANGUAGE}.txt


#bring to wordseg tags format with ;eword for word boundaries
#sed  -e '/^segmented.utterance/d'  -e 's/ ; / ;eword /g' -e 's/$/ ;eword/g'  ${RESULT_PATH}/${LANGUAGE}.txt > ${RESULT_PATH}/${LANGUAGE}1.tmp

#create gold and prepared file for segmentation
#mv ${RESULT_PATH}/${LANGUAGE}1.tmp ${RESULT_PATH}/${LANGUAGE}.txt
#cat ${RESULT_PATH}/${LANGUAGE}.txt | wordseg-prep -u phone --gold "${RESULT_PATH}/${LANGUAGE}-gold.txt" > "${RESULT_PATH}/${LANGUAGE}_p_prepared.txt"



TAGS="${RESULT_PATH}/${LANGUAGE}.txt" 
PREPARED_P="${RESULT_PATH}/${LANGUAGE}_p_prepared.txt"
GOLD="${RESULT_PATH}/${LANGUAGE}-gold.txt"
THISSTAT="${RESULT_PATH}/${LANGUAGE}-stats.txt"

##TP
#wordseg-tp -v -o ${RESULT_PATH}/${LANGUAGE}_p_ftpr.txt -t relative -d ftp ${PREPARED_P}
#cat ${RESULT_PATH}/${LANGUAGE}_p_ftpr.txt | wordseg-eval -o ${RESULT_PATH}/${LANGUAGE}_p_ftpr_eval.txt -v -s ${RESULT_PATH}/${LANGUAGE}_p_ftpr_eval_summary.txt ${GOLD}

#wordseg-tp -v -o ${RESULT_PATH}/${LANGUAGE}_p_btpr.txt -t relative -d btp ${PREPARED_P}
#cat ${RESULT_PATH}/${LANGUAGE}_p_btpr.txt | wordseg-eval -o ${RESULT_PATH}/${LANGUAGE}_p_btpr_eval.txt -v -s ${RESULT_PATH}/${LANGUAGE}_p_btpr_eval_summary.txt ${GOLD}

#wordseg-tp -v -o ${RESULT_PATH}/${LANGUAGE}_p_ftpa.txt -t absolute -d ftp ${PREPARED_P}
#cat ${RESULT_PATH}/${LANGUAGE}_p_ftpa.txt | wordseg-eval -o ${RESULT_PATH}/${LANGUAGE}_p_ftpa_eval.txt -v -s ${RESULT_PATH}/${LANGUAGE}_p_ftpa_eval_summary.txt ${GOLD}

#wordseg-tp -v -o ${RESULT_PATH}/${LANGUAGE}_p_btpa.txt -t absolute -d btp ${PREPARED_P}
#cat ${RESULT_PATH}/${LANGUAGE}_p_btpa.txt | wordseg-eval -o ${RESULT_PATH}/${LANGUAGE}_p_btpa_eval.txt -v -s ${RESULT_PATH}/${LANGUAGE}_p_btpa_eval_summary.txt ${GOLD}

#wordseg-tp -v -o ${RESULT_PATH}/${LANGUAGE}_p_mia.txt -t absolute -d mi ${PREPARED_P}
#cat ${RESULT_PATH}/${LANGUAGE}_p_mia.txt | wordseg-eval -o ${RESULT_PATH}/${LANGUAGE}_p_mia_eval.txt -v -s ${RESULT_PATH}/${LANGUAGE}_p_mia_eval_summary.txt ${GOLD}

#wordseg-tp -v -o ${RESULT_PATH}/${LANGUAGE}_p_mir.txt -t relative -d mi ${PREPARED_P}
#cat ${RESULT_PATH}/${LANGUAGE}_p_mir.txt | wordseg-eval -o ${RESULT_PATH}/${LANGUAGE}_p_mir_eval.txt -v -s ${RESULT_PATH}/${LANGUAGE}_p_mir_eval_summary.txt ${GOLD}


#Baselines
#cat $PREPARED_P | wordseg-baseline -P 1 > ${RESULT_PATH}/${LANGUAGE}_p_base1.txt
#wordseg-eval -o ${RESULT_PATH}/${LANGUAGE}_p_base1_eval.txt -s ${RESULT_PATH}/${LANGUAGE}_p_base1_eval_summary.txt ${RESULT_PATH}/${LANGUAGE}_p_base1.txt  $GOLD

#cat $PREPARED_P | wordseg-baseline -P 0 > ${RESULT_PATH}/${LANGUAGE}_p_base0.txt
#wordseg-eval -o ${RESULT_PATH}/${LANGUAGE}_p_base0_eval.txt -s ${RESULT_PATH}/${LANGUAGE}_p_base0_eval_summary.txt ${RESULT_PATH}/${LANGUAGE}_p_base0.txt  $GOLD

#cat $PREPARED_P | wordseg-baseline -P 0.167 > ${RESULT_PATH}/${LANGUAGE}_p_base6.txt
#wordseg-eval -o ${RESULT_PATH}/${LANGUAGE}_p_base6_eval.txt -s ${RESULT_PATH}/${LANGUAGE}_p_base6_eval_summary.txt ${RESULT_PATH}/${LANGUAGE}_p_base6.txt  $GOLD


#PUDDLE
#cat $PREPARED_P | wordseg-puddle > ${RESULT_PATH}/${LANGUAGE}_p_puddle.txt
#wordseg-eval -o ${RESULT_PATH}/${LANGUAGE}_p_puddle_eval.txt -s ${RESULT_PATH}/${LANGUAGE}_p_puddle_eval_summary.txt  ${RESULT_PATH}/${LANGUAGE}_p_puddle.txt $GOLD



##DiBS
#wordseg-dibs -t phrasal -o ${RESULT_PATH}/${LANGUAGE}_p_dibs.txt ${PREPARED_P}  ${TAGS}
#cat ${RESULT_PATH}/${LANGUAGE}_p_dibs.txt | wordseg-eval -o ${RESULT_PATH}/${LANGUAGE}_p_dibs_eval.txt -v -s ${RESULT_PATH}/${LANGUAGE}_p_dibs_eval_summary.txt ${GOLD}


#GOLD1="${RESULT_PATH}/${LANGUAGE}-gold1.txt"

##AG
AG_OPTIONS="--grammar ${CURRENT}Colloc0_${LANGUAGE}.lt --category Colloc0 -n 1000 -j 8 -vv -d 100"
cat $PREPARED_P | wordseg-ag $AG_OPTIONS -o ${RESULT_PATH}/${LANGUAGE}_p_ag.txt
wordseg-eval -v -o ${RESULT_PATH}/${LANGUAGE}_p_ag_eval.txt -s ${RESULT_PATH}/${LANGUAGE}_p_ag_eval_summary.txt  ${RESULT_PATH}/${LANGUAGE}_p_ag.txt  ${GOLD}



##stats

wordseg-stats $TAGS -o $THISSTAT

########done
