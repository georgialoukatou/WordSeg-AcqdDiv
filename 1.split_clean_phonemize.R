#!/usr/bin/env Rscript

#Script by Georgia Loukatou
# Script to merge original acqdiv and phonemized database and extract language corpora, clean and save in folder as "utterances.csv"

args = commandArgs(trailingOnly=TRUE)
path_=args[1]
PHONEMIZED=args[2]
CORPUS=args[3]
LANGUAGE=args[4]

load(CORPUS)
load(PHONEMIZED) #load phonemized version


languages<-c( LANGUAGE) # languages to extract

for (lang in languages){ 
  
  utterances_lang=utterances[utterances$language==lang,]
  speakers_lang=speakers[speakers$language==lang,]
  morphemes_lang=morphemes[morphemes$language==lang,]
  words_lang=words[words$language==lang,]
  sessions_lang=sessions[sessions$language==lang,]
  uniquespeakers_lang=uniquespeakers[uniquespeakers$language==lang,]
  
  
colnames(utterances_lang)[colnames(utterances_lang)=="session_id_fk"] <- "session_id" #in case of name inconsistencies
utterances_lang->main_lang

merge(main_lang, segmented.utterances,by=c("utterance_id"))->main_lang_segmented  #merge main with phonemized 


selcol="segmented.utterance"
x=main_lang_segmented[selcol]
toremove=c(":","^","'","(",")","&","?",".",",","=","…","!","_","/","।","«","‡","§","™","•","�","Œ","£","±","-","ǃ", "&ADV","&CAUS","&COND","&CONN","&NEG","&IMP","&PAST","&POL","&PRES","&QUOT","&SGER","-HON_","_NEG", ".*FS_","FS_", "DELAY", "\340\245\207", "\314\265","\314\200") 
for(thiscar in toremove) x<-gsub(thiscar,"",x,fixed=T)  #clean, if any

main_lang_segmented[grep("NA",as.character(main_lang_segmented[,"segmented.utterance"]),invert=T),]->main_lang_segmented #remove NAs


names=c("segmented.utterance", "utterance",  "utterance_morphemes", "utterance_gloses_raw", "utterance_poses_raw", "utterance_id", "language", "session_id",  "speaker_id_fk", "sentence_type")

main_lang_segmented1<-main_lang_segmented[names] #keep only columns of interest

write.table(main_lang_segmented1, file=paste0(path_, lang, "/utterances.csv"), row.names=F, col.names=T, sep="#", quote=F) # write utterances in file
write.table(speakers_lang, file=paste0(path, lang, "/speakers.csv"), row.names=F, col.names=T, sep="#", quote=F) #write speakers in file (will be needed to remove child utterances)

}



