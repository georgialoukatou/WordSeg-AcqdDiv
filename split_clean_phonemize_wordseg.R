#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)


load("/Users/user/Downloads/segmented_acqdiv_corpus_2018-08-27.Rdata")
load("/Users/user/Downloads/acqdiv_corpus_2018-08-27.rda")

head(segmented.utterances)

path=args[1]


languages<-c( "Japanese", "Turkish", "Yucatec", "Indonesian", "Chintang", "Inuktitut", "Russian", "Sesotho")

for (lang in languages){
  
  utterances_lang=utterances[utterances$language==lang,]
  speakers_lang=speakers[speakers$language==lang,]
  morphemes_lang=morphemes[morphemes$language==lang,]
  words_lang=words[words$language==lang,]
  sessions_lang=sessions[sessions$language==lang,]
  uniquespeakers_lang=uniquespeakers[uniquespeakers$language==lang,]
  
#need a folder created for each language in "path"
  
#write.table(speakers_lang, file=paste0(path, lang, "/speakers.csv"), row.names=F, col.names=T, sep="#", quote=F)
#write.table(morphemes_lang, file=paste0(path, lang, "/morphemes.csv"), row.names=F, col.names=T, sep="#", quote=F)
#write.table(words_lang, file=paste0(path, lang, "/words.csv"), row.names=F, col.names=T, sep="#", quote=F)
#write.table(sessions_lang, file=paste0(path, lang, "/sessions.csv"), row.names=F, col.names=T, sep="#", quote=F)
#write.table(uniquespeakers_lang, file=paste0(path, lang, "/uniquespeakers.csv"), row.names=F, col.names=T, sep="#", quote=F)


colnames(utterances_lang)[colnames(utterances_lang)=="session_id_fk"] <- "session_id"
utterances_lang->main_lang

main_lang$translation<-NULL
main_lang$comment<-NULL
main_lang$warning<-NULL

merge(main_lang, segmented.utterances,by=c("utterance_id"))->main_lang_segmented

selcol="segmented.utterance"
x=main_lang_segmented[selcol]

toremove=c(":","^","'","(",")","&","?",".",",","=","…","!","_","/","।","«","‡","§","™","•","�","Œ","£","±","-","ǃ", "&ADV","&CAUS","&COND","&CONN","&NEG","&IMP","&PAST","&POL","&PRES","&QUOT","&SGER","-HON_","_NEG", ".*FS_","FS_", "DELAY", "\340\245\207", "\314\265","\314\200") 
for(thiscar in toremove) x<-gsub(thiscar,"",x,fixed=T)

main_lang_segmented[grep("NA",as.character(main_lang_segmented[,"segmented.utterance"]),invert=T),]->main_lang_segmented 
names=c("utterance_id", "session_id", "language", "speaker_id_fk", "utterance_morphemes", "segmented.utterance")
main_lang_segmented1<-main_lang_segmented[names]

write.table(main_lang_segmented1, file=paste0(path, lang, "/utterances.csv"), row.names=F, col.names=T, sep="#", quote=F)

}



