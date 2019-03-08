
library(ggplot2)
library(plotly)
library(plyr)
library(lme4)
library(car) 
library("ggpubr")
library(orca)
library(effects)


#######read stats file


stats<-read.csv("~/Documents/fair_project/resultsACL/stats.csv")
stats$language=gsub(".*chintang.*", "chintang", stats$folder)
stats$language=gsub(".*japanese.*", "japanese", stats$language)
stats$language=gsub(".*indonesian.*", "indonesian", stats$language)
stats$language=gsub(".*turkish.*", "turkish", stats$language)
#stats$language=gsub(".*cree.*", "cree", stats$language)
stats$language=gsub(".*inuktitut.*", "inuktitut", stats$language)
stats$language=gsub(".*russian.*", "russian", stats$language)
stats$language=gsub(".*yucatec.*", "yucatec", stats$language)
stats$language=gsub(".*sesotho.*", "sesotho", stats$language)

#add some basic stats
stats$utt_single_word<-(round(stats$corpus_nutts_single_word/stats$corpus_nutts,2))
stats$utt_length<-(round(stats$syllables_tokens/stats$corpus_nutts,2))
stats$word_length<-(round(stats$phones_tokens/stats$words_tokens,2))
stats$word_hapax_ratio<-(round(stats$words_hapaxes/stats$words_types,2))
statschintang=stats[stats$language=="chintang",]
statsjapanese=stats[stats$language=="japanese",]
statsindonesian=stats[stats$language=="indonesian",]
statsinuktitut=stats[stats$language=="inuktitut",]
statscree=stats[stats$language=="cree",]
statsrussian=stats[stats$language=="russian",]
statssesotho=stats[stats$language=="sesotho",]
statsturkish=stats[stats$language=="turkish",]
statsyucatec=stats[stats$language=="yucatec",]



#function counting correctly segmented, over, under and missegmentation word tokens
library("rjson")

words_<-setNames(data.frame(matrix(ncol = 3, nrow = 0)), c("name", "metric"))
overunder<-function(file, words_tokens){
  name<-file
  result <- fromJSON(file = name)
  
  over<-result$over
  freqover<- sapply(over, function(x) x[1])
  numbover<-Reduce("+", freqover)
  if (is.null(numbover)){numbover <-0}
  
  under<-result$under
  frequnder<- sapply(under, function(x) x[1])
  numbunder<-Reduce("+", frequnder)
  if (is.null(numbunder)){numbunder <-0}
  
  mis<-result$mis
  freqmis<- sapply(mis, function(x) x[1])
  numbmis<-Reduce("+", freqmis)
  if (is.null(numbmis)){numbmis <-0}
  
  correct<-result$correct
  freqcorrect<- sapply(correct, function(x) x[1])
  numbcorrect<-Reduce("+", freqcorrect)
  if (is.null(numbcorrect)){numbcorrect <-0}
  
  overpercentage<-numbover/words_tokens
  underpercentage<-numbunder/words_tokens
  mispercentage<-numbmis/words_tokens
  correctpercentage<-numbcorrect/words_tokens

  #create .csv file with correctly segmented, over, under and missegmentation
  words_=rbind(c(name, "over", overpercentage), c(name, "under", underpercentage), c(name, "mis", mispercentage), c(name, "correct", correctpercentage))
  write.table(words_, paste("/Users/lscpuser/Documents/fair_project/resultsACL/overunder.csv"), quote=FALSE,sep = ',', append=TRUE, col.names = FALSE )  
 
 }

#call function for each language, the path folder should contain all *summary* files
fileschintang<- list.files(path="/Users/lscpuser/Documents/fair_project/resultsACL/data_results1", pattern=c("chintang.*summary"), full.names=TRUE)
for (file in fileschintang){overunder(file,statschintang$words_tokens)}
filesjapanese<- list.files(path="/Users/lscpuser/Documents/fair_project/resultsACL/data_results1", pattern=c("japanese.*summary"), full.names=TRUE)
for (file in filesjapanese){overunder(file,statsjapanese$words_tokens)}
filesturkish<- list.files(path="/Users/lscpuser/Documents/fair_project/resultsACL/data_results1", pattern=c("turkish.*summary"), full.names=TRUE)
for (file in filesturkish){overunder(file,statsturkish$words_tokens)}
filescree<- list.files(path="/Users/lscpuser/Documents/fair_project/resultsACL/data_results1", pattern=c("cree.*summary"), full.names=TRUE)
for (file in filescree){overunder(file,statscree$words_tokens)}
filesindonesian<- list.files(path="/Users/lscpuser/Documents/fair_project/resultsACL/data_results1", pattern=c("indonesian.*summary"), full.names=TRUE)
for (file in filesindonesian){overunder(file,statsindonesian$words_tokens)}
filesrussian<- list.files(path="/Users/lscpuser/Documents/fair_project/resultsACL/data_results1", pattern=c("russian.*summary"), full.names=TRUE)
for (file in filesrussian){overunder(file,statsrussian$words_tokens)}
filesyucatec<- list.files(path="/Users/lscpuser/Documents/fair_project/resultsACL/data_results1", pattern=c("yucatec.*summary"), full.names=TRUE)
for (file in filesyucatec){overunder(file,statsyucatec$words_tokens)}
filesinuktitut<- list.files(path="/Users/lscpuser/Documents/fair_project/resultsACL/data_results1", pattern=c("inuktitut.*summary"), full.names=TRUE)
for (file in filesinuktitut){overunder(file,statsinuktitut$words_tokens)}
filessesotho<- list.files(path="/Users/lscpuser/Documents/fair_project/resultsACL/data_results1", pattern=c("sesotho.*summary"), full.names=TRUE)
for (file in filessesotho){overunder(file,statssesotho$words_tokens)}







############################ read newly created .csv for statistics
test<- read.csv("/Users/lscpuser/Documents/fair_project/resultsACL/overunder.csv", header=FALSE, sep=",")
names(test)<-c("index", "name", "metric","percentage")
test$algo=gsub(".*_p_","",test$name)
test$algo=gsub("_eval.*","",test$algo)
test$lang=gsub(".*results1/","",test$name)
test$lang=gsub("_p_.*","",test$lang)
test$algo<-factor(test$algo, c("base0", "base1", "base6", "dibs", "mir", "ftpr", "btpr", "puddle", "ag" , "mia", "ftpa", "btpa"))
test$lang<-factor(test$lang, c("chintang", "turkish", "inuktitut", "cree", "yucatec", "russian", "indonesian", "japanese" , "sesotho"))
test$metric<-factor(test$metric, c("mis", "under", "over", "correct"))
languages<-c("inuktitut",  "chintang", "turkish",  "russian",  "cree", "yucatec", "japanese", "sesotho", "indonesian")







######################plot1
i<-0
plot.names <- paste("p", 1:9, sep="_") 

for (lang in languages){
i<-i +1 
print(i)
testlang<-test[which(test$lang==lang), ]
testlang$metric <- as.factor(c('mis', 'under', 'over', 'correct'))
langbase0<-testlang[testlang$algo=="base0",]
langbase0cor<-langbase0[langbase0$metric=="correct",]
langbase1<-testlang[testlang$algo=="base1",]
langbase1cor<-langbase1[langbase1$metric=="correct",]
langbase6<-testlang[testlang$algo=="base6",]
langbase6cor<-langbase6[langbase6$metric=="correct",]
testlang$algo<-factor(testlang$algo, c( "dibs", "mir", "btpr", "ftpr", "mia", "btpa", "ftpa", "puddle", "ag" ))
testlang_main<-testlang[which (testlang$algo !="base0" & testlang$algo !="base1" & testlang$algo !="base6"), ]
plot <-ggplot(testlang_main, aes(algo, percentage, fill=metric)) + geom_bar(stat="identity") +   geom_hline(yintercept=langbase0cor$percentage, linetype=1) +   geom_hline(yintercept=langbase1cor$percentage, linetype=2)  +   geom_hline(yintercept=langbase6cor$percentage, linetype=3) 
assign(plot.names[i], plot)
}

jpeg(file="~/Documents/fair_project/resultsACL/test2.jpg", width = 20, height = 5, units = 'in', res = 400)
plot_grid(p_1 + theme(legend.position="none"), p_2 + theme(legend.position="none"), p_3, labels = c('Inuktitut', 'Chintang', 'Turkish'), label_size = 12, label_fontfamily = "serif", ncol = 3, align = 'h')
dev.off()
jpeg(file="~/Documents/fair_project/resultsACL/test2.jpg", width = 20, height = 5, units = 'in', res = 400)
plot_grid(p_4 + theme(legend.position="none"), p_5 + theme(legend.position="none"), p_6, labels = c('Russian', 'Cree', 'Yucatec'), label_size = 12, label_fontfamily = "serif", ncol = 3, align = 'h')
dev.off()
jpeg(file="~/Documents/fair_project/resultsACL/test3.jpg", width = 20, height = 5, units = 'in', res = 400)
plot_grid(p_7 + theme(legend.position="none"), p_8 + theme(legend.position="none"), p_9, labels = c('Japanese', 'Sesotho', 'Indonesian'), label_size = 12, label_fontfamily = "serif", ncol = 3, align = 'h')
dev.off()






########################matrix correlation

A = matrix( c(
  2,	8,	1,	4,	6,	5,	7,	 3,	9,
  1,	2,	4,	3,	6,	8,	9,	7,	5, 
  1,	6,	2,	3,	5,	7,	 9,	8,	4,
  9,	7,	4,	1,  3,	5,	8,	6,	2, 
  1,	3,	4,	6,	5,	8,	7,	9,	2, 
  1,	2,	4,	3,	5,	8,	9,	7,  6, 
  1,	9,	4,	3,	5,	6,	7,	8,	2, 
  1,	2,	6,	5,	3,	9,	7,	8,	4), nrow=8,           ncol=9,  
  dimnames = list(c("Inuktitut","Chintang","Turkish", "Russian", "Yucatec", "Sesotho", "Indonesian", "Japanese"), 
                  c("AG","PUDDLE","DIBS", "FTPa", "FTPr", "BTPa", "BTPr", "MIa", "MIr")),     byrow = TRUE)

A<-t(A)
res<-cor(A, method='spearman')
library(corrplot)
jpeg(file="~/Documents/fair_project/resultsACL/cor.jpg", width = 7, height = 7, units = 'in', res = 400)
corrplot(res, type="upper", col=c( "red4", "royalblue4"), method="number", bg="snow", tl.col="black", tl.srt=45)
dev.off()







#########################plot2
# data loading and formatting
gedata<-read.csv(file.choose(),header=F)[-1,]
colnames(gedata)<-c("n","lg","type","p")
gedata$lg<-sapply(gedata$lg,function(x) gsub(".*results1/","",x))
gedata$algo<-sapply(gedata$lg,function(x) gsub(".*p_(.+)_eval.*","\\1",x))
gedata$lg<-sapply(gedata$lg,function(x) gsub("_.*","",x))
gedata$lgn<-sapply(gedata$lg,function(x) substr(x,1,3))
gedata$algogroup=gsub("ag","lexical",gedata$algo)
gedata$algogroup=gsub("puddle","lexical",gedata$algogroup)
gedata$algogroup=gsub("ftpr","sublexical",gedata$algogroup)
gedata$algogroup=gsub("btpr","sublexical",gedata$algogroup)
gedata$algogroup=gsub("ftpa","sublexical",gedata$algogroup)
gedata$algogroup=gsub("btpa","sublexical",gedata$algogroup)
gedata$algogroup=gsub("dibs","sublexical",gedata$algogroup)
gedata$algogroup=gsub("mia","sublexical",gedata$algogroup)
gedata$algogroup=gsub("mir","sublexical",gedata$algogroup)
gedata$algogroup=gsub("base0","baseline",gedata$algogroup)
gedata$algogroup=gsub("base6","baseline",gedata$algogroup)

gedata$lg=gsub("yucatec","Yucatec",gedata$lg)
gedata$lg=gsub("turkish","Turkish",gedata$lg)
gedata$lg=gsub("japanese","Japanese",gedata$lg)
gedata$lg=gsub("sesotho","Sesotho",gedata$lg)
gedata$lg=gsub("chintang","Chintang",gedata$lg)
gedata$lg=gsub("indonesian","Indonesian",gedata$lg)
gedata$lg=gsub("russian","Russian",gedata$lg)
gedata$lg=gsub("inuktitut","Inuktitut",gedata$lg)

# plot for q1
ggplot(gedata[gedata$type=="correct",],aes(x=reorder(algo, p, mean),y=p,color=lg))+
  geom_point(size=5,shape="|")+
  stat_summary(fun.y=mean,fun.ymin = min, fun.ymax = max,color="black")+
  coord_flip()+
  labs(color="Language")+
  ylab("Fraction of words correctly segmented")+
  xlab("Algorithm")
ggsave("ge_acl_q1.pdf")

# plot for q2
gedata1<-gedata[which(gedata$lg !="cree"),]
gedata1<-gedata1[which(gedata1$algo !="base1"),]
gedata1$algo<-factor(gedata1$algo, c("ag", "puddle", "dibs", "ftpa", "ftpr", "btpa", "btpr", "mia", "mir", "base0", "base6"))
#gedata1$algogroup<-factor(gedata1$algogroup, c("baseline", "sublexical", "lexical"))

jpeg(file="~/Documents/fair_project/resultsACL/plot.jpg", width = 9, height = 7, units = 'in', res = 400)

ggplot(gedata1[gedata1$type=="correct",],aes(x=reorder(lg, p, mean),y=p,color=algo))+
  # geom_point(aes(color=algo, shape=algogroup), size=4.5) +
  geom_point(aes(color=algo), size=4.5) +
  stat_summary(fun.y=mean, shape="|", fun.ymin = min, fun.ymax = max, color="black")+
  coord_flip()+
  labs(color="Algorithm")+
  labs(shape="Group") +
  ylab("Fraction of correctly segmented words")+
  xlab("Language") +
  scale_color_manual(values=c("red", "red4", "yellow2", "olivedrab2", "green4", "deepskyblue", "blue",  "plum1", "purple", "grey35", "seashell2"), 
                     labels = c("AG", "PUDDLE", "DiBS", "FTPa", "FTPr", "BTPa", "BTPr", "MIa", "MIr", "Basep=0", "Basep=1/6"))+
  #scale_shape_manual(values=c(15, 16, 17)) +
  scale_x_discrete(name ="Language")+ 
  theme(legend.text=element_text(size=12),legend.title=element_text(size=12) )
# guides(shape = guide_legend(override.aes = list(size = 3.8)))
dev.off()
#+
#  scale_x_discrete(breaks = levels(gedata$lg))
ggsave("ge_acl_q2.pdf")









