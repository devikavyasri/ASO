#!/bin/sh
#Script to find optimal outcome
#First find the outcome of ASO program arbitarily.
#Iteratively find better outcome than previous outcome until there doesn't exist better outcome

#Validating whether correct number of arguments given or not
if [ $# -ne 6 ]
  then
    echo "Six arguments are not supplied"
    echo "First Argument: number Of Atoms (Atoms shoud be >=3) "
    echo "Second Argument: number of generator Clauses "
    echo "Third Argument: number of preference Clauses "
    echo "Fourth Argument - PreferenceSet : 1 (unranked) or 2 (ranked) or 3 (TwoLPTrees) 4(FourLPTrees)"
    echo "Fifth Argument: Instance Number"
    echo "Sixth Argument: - Type of LP Trees:
                    if DataSet == 4: 0 (no split) or 1 (Split at root)
                    if DataSet != 4: -1 "
    exit
fi

#deleting temporary files
rm temp/tempAnswer.txt 2>temp/error.txt
rm temp/previousOutput.txt 2>temp/error.txt

#Assigning values to variables based on given input
numOfAtoms=$1
numOfGenClauses=$2
numOfPrefClauses=$3
PreferenceSet=$4
instanceNum=$5
split=$6

#Choosing input data set and required programs based on given "PreferenceSet"
if [ "$PreferenceSet" == "1" ] #If PreferenceSet == unranked
then
  dir="data/one/"
  calculateSatisfatctionDegree="calculateSatDegree.lp"
  findBetter="findBetter.lp"
elif [ "$PreferenceSet" == "2" ] #If PreferenceSet == ranked
then
  dir="data/two/"
  calculateSatisfatctionDegree="calculateSatDegree.lp"
  findBetter="findBetterRanked.lp"
elif [ "$PreferenceSet" == "3" ] #If PreferenceSet == TwoLPTRees
then
  dir="data/tree/"
  calculateSatisfatctionDegree="calculateSatDegree.lp"
  findBetter="findBetterRanked.lp"
elif [ "$PreferenceSet" == "4" ] #If PreferenceSet == FourLPTRees
then
  dir="data/fourTrees/"
  calculateSatisfatctionDegree="calculateSatDegree_FourLPTrees.lp"
  findBetter="findBetterRanked_FourLPtrees.lp"
fi

#Choosing input data files i.e. ASO program based on given numOfAtoms,numOfGenClauses,numOfPrefClauses,instanceNum
generatorInput=$dir"gen/gen"$numOfAtoms"_"$numOfGenClauses"_"$instanceNum".txt"
preferenceInput=$dir"pref/pref"$numOfAtoms"_"$numOfPrefClauses"_"$instanceNum".txt"

if [ "$PreferenceSet" == "4" ]
then
  preferenceInput=$dir"pref/pref"$numOfAtoms"_4_"$split"_"$instanceNum".txt"
fi

#Storing computation start time
MAIN_START=$(gdate +%s.%N)


#checking if input data files exists or not
if [ ! -f "$generatorInput" ]
then
    echo "GeneratorFileDoesNotExist" > temp/solution.txt
    MAIN_END=$(gdate +%s.%N) #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
    echo "timeTaken= "$timeTaken
    exit
elif [ ! -f "$preferenceInput" ]
then
    echo "PreferenceFileDoesNotExist" > temp/solution.txt
    MAIN_END=$(gdate +%s.%N) #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
    echo "timeTaken= "$timeTaken
    exit
fi

#Generate arbitary outcome
clingo $generatorInput generatorProgram.lp $preferenceInput $calculateSatisfatctionDegree > temp/tempAnswer.txt

#Store satisfaction degrees of previously obtained outcome in "previousOutput.txt" file
panswer=$(grep "nswer(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
echo $panswer > temp/previousOutput.txt
previousOutput="temp/previousOutput.txt"

#Checking whether ASO program has any outcome or not.
#If ASO program doesn't have outcome, we stop computation
unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
if [ "$unsatisfy" == "UNSATISFIABLE" ]
then
    MAIN_END=$(gdate +%s.%N) #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
    echo "timeTaken= "$timeTaken
    exit
fi
#If ASO program has outcome, store the "outcome" in "solution.txt" file
grep "nswer(" temp/tempAnswer.txt > temp/solution.txt


#Iteratively finding better outcome than the obtained "outcome"
while [ "$unsatisfy" != "UNSATISFIABLE" ]
do
  #Generate better outcome
  clingo $generatorInput generatorProgram.lp $preferenceInput $calculateSatisfatctionDegree $previousOutput $findBetter > temp/tempAnswer.txt
  #Store satisfaction degrees of previously obtained outcome in "previousOutput.txt" file
  panswer=$(grep "nswer(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
  echo $panswer > temp/previousOutput.txt
  #previousOutput="temp/previousOutput.txt"

  #Checking whether ASO program has better outcome or not.
  #If ASO program doesn't have better outcome, we stop computation
  unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
  if [ "$unsatisfy" == "UNSATISFIABLE" ]
  then
      MAIN_END=$(gdate +%s.%N) #Storing computation end time
      timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
      echo "timeTaken= "$timeTaken
      exit
  fi
  #If ASO program has better outcome, store it in "solution.txt" file
  grep "nswer(" temp/tempAnswer.txt > temp/solution.txt
done
