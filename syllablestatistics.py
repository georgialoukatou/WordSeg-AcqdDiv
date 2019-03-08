from __future__ import division
import sys
import re

from collections import Counter



VOWELS = sys.argv[1] #list of vowels
INPUT = sys.argv[2]  #input text with space between phonemes and ;eword between words


l = open(VOWELS).readlines()
l = [item.split()[0] for item in l if len(item.split())>0]

for vow in l :
 print(vow) #list l has all vowels


#########################CODAS

coda=[]
nword=0
f = open(INPUT)
for line in f:
   lastvowel=""
   line=line.strip()
   line1=line.split(";eword")
   #print(line1) ####list of words per utterance
   for word in line1:
    if len(word)>0:
     i=0 
     nword=nword + 1
     word=word.rstrip()
     word=word.lstrip()
     word1=word.split(" ")
     #print(word1) ####list of phonemes per word
     for position, char in enumerate(word1):
      if char in l:		
       if position > i:
        i=position
        lastvowel=char   #find last vowel of word
     lenword=(len(word1)-1)
     if lenword-i == 0 : #when no consonant after vowel
      coda.append(int("0"))
     else: #when there is at least one final consonant append size to coda
      finalcons=(lenword-i)
      coda.append(finalcons)      
    

print("Number of words:", nword) 
print("Coda complexity:")
counts = Counter(coda)
print(counts.most_common())

for key,value in counts.iteritems():
 	if key==0:
		print("V", value/nword)
        if key==1:
		print("VC", value/nword)
	if key==2:
		print("VCC", value/nword)
        if key==3:
		print("VCCC", value/nword)

f.close()
###########################################ONSETS


totalvowels=0
totalcharacters=0

onset=[]
nword=0
f = open(INPUT)
wordprop=[] #list with proportion of vowels per total phonemes per word

for line in f:
   line=line.strip()
   line1=line.split(";eword")
   #print(line1)
   for word in line1:
    if len(word)>0:
     totalcharacters=0
     totalvowels=0
     i=30
     nword=nword + 1
     word=word.rstrip()
     word=word.lstrip()
     word1=word.split(" ")
     for position, char in enumerate(word1):
      if char !=" ":
       totalcharacters=totalcharacters+1
      if char in l:
       totalvowels=totalvowels + 1
       if position < i:
        i=position
        firstvowel=char
     if i == 0 : #if first vowel is first char in word
      onset.append(int("0"))
     else: #save the number of consonants before the first vowel
      firstcons=(i)
      onset.append(firstcons)
     prop=(totalvowels/totalcharacters)
     wordprop.append(prop) #add vowels/chars for this word in list

counts1 = Counter(onset)
print(counts1.most_common())
print("Onset complexity:")

for key,value in counts1.iteritems():
        if key==0:
                print("V", value/nword)
        if key==1:
                print("CV", value/nword)
        if key==2:
                print("CCV", value/nword)
        if key==3:
                print("CCCV", value/nword)

sumprop=sum(map(float, wordprop))
print("average number of vowels per word", sumprop/len(wordprop)) #average number of vowels per word
f.close()
