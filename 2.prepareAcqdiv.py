#Original script by Michael Hahn
#Modifications and comments by Georgia Loukatou


import os
import random
import sys
 

import csv

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--language", dest="language", type=str) #select language
parser.add_argument("--corpusinit", dest="corpusinit", type=str) #select initial path (same path as in split_clean_phonemize_wordseg.py)
parser.add_argument("--corpusfinal", dest="corpusfinal", type=str)
import random  
#select path where to save corpus after removing child utterances and converting to .tsv

args=parser.parse_args()
print(args)

# i.e. python prepareAcqdiv.py --language Japanese --corpusinit /scratch2/gloukatou/fair_project/ --corpusfinal  /scratch2/gloukatou/fair_project/


#example of .csv to be read by this function: segmented.utterance#utterance#utterance_morphemes#utterance_gloses_raw#utterance_poses_raw#utterance_id#language#session_id#speaker_id_fk#sentence_type
#i s ʃ o#issho#issho#together#n#1390478#Japanese#1602#12397#exclamation

def readCSV(paths):
   result = []
   header = None
   assert len(paths) < 10
   paths = sorted(paths)
   print(paths)
   for path in paths:
      print(path)
      with open(path, "r") as inFile:
         data = csv.reader(inFile, delimiter="#", quotechar='"') 
         if header is None:
            headerNew = next(data)
            header = headerNew
         for line in data:
             try:
              assert len(line) == len(header), (line, header)
              result.append(line)
             except:
              pass
         assert header == headerNew, (header, headerNew)
   return (header, result)


#function to convert to TSV
def printTSV(table, path):
   header, data = table
   with open(path, "w") as outFile:
       outFile.write("\t".join(header)+"\n")
       for line in data:
           outFile.write("\t".join(line)+"\n")


def mergeCSV(infiles, outfile):
   with open(outfile, "w") as outFile:
      for path in infiles:
          with open(path, "r") as inFile:
             outFile.write(inFile.read())


basePath = args.corpusinit + args.language + "/"
basePathOut =  args.corpusfinal + args.language + "/"
names = ["utterances", "speakers", "morphemes", "words", "uniquespeakers"] 
#names = ["utterances_train", "utterances_test", "utterances_dev"]


#select "utterances" and convert to .tsv
for name in names:
  infiles = [basePath+x for x in os.listdir(basePath) if x.startswith(name) and x.endswith(".csv")]
  if len(infiles) > 1:
    mergeCSV(infiles = infiles, outfile = basePath+name+".csv")
  dataset = readCSV([basePath+name+".csv"])
  printTSV(dataset, basePathOut+name+".tsv")

#function to find child lines
def find_child_lines(speakers_file):
        child_id=[]
        for line_ in speakers_file:
                if "Child" in line_: #find speakers with label "Child" or "Target_Child"
                        column=line_.split("\t")
                        if column[0] not in child_id:
                                child_id.append(column[0]) #append child ids to list
        return child_id


# use find_child_lines with speakers.tsv
speakers_file=open( (basePathOut + "speakers.tsv"), "r")
list_=(find_child_lines(speakers_file))
speakers_file.close()


utterances_file=open((basePathOut + "utterances.tsv"), "r")
lines_=utterances_file.readlines()
utterances_file.close()

#function to remove child utterances
def remove_child_lines(utterances_file, lines_):
        for line_ in lines_:
                 #if "NA" not in line_:
                 #if "#" in line_:
                 line_=line_.replace("#", "	")
                 column=line_.split("\t")
                 if column[8] not in list_ and column[3]!="NA": #column 8 has speaker_ids, remove line if speaker id corresponds to child id, or if id is "NA"
                        utterances_file.write(line_)
                        


utterances_file=open((basePathOut + "utterances.tsv"),"w")
remove_child_lines(utterances_file, lines_)
utterances_file.close()
