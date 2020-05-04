#!/bin/sh
#This script is used to find similar or dissimilar outcome to given outcome
#using Alternative method

#pseudo code
#1. Convert givenOutput to the ASP readable format and store in givenAnswerSet.txt
#2. Consider givenOutput as outcome 0 and add to existingOutcomes.txt
#3. Loop begins
  #4. Find similar outcome for given outcome and different from given and existingOutcomes.txt
  #5. Check if  similar outcome is optimal solution (optimalAnswer) using findBetter
  #6. If optimal, break the loop and obtained similar outcome is final answer
  #7. Else, add obtained similar outcome to existingOutcomes.txt


#Validating whether correct number of arguments given or not
if [ $# -ne 8 ]
  then
    echo "Eight arguments are not supplied"
    echo "First Argument: Given Output FileName"
    echo "Second Argument: distance "
    echo "Third Argument: number Of Atoms (Atoms shoud be >=3) "
    echo "Fourth Argument: number of generator Clauses "
    echo "Fifth Argument: number of preference Clauses "
    echo "Sixth Argument: Instance Number"
    echo "Seventh Argument is PreferenceSet : 1 (unranked) or 2 (ranked) or 3 (TwoLPTrees)"
    echo "Eighth Argument is sim/dis: 1 (similar) and 2 (dissimilar)"
    echo '\n'
    exit
fi

#deleting temporary files
rm temp/tempAnswer.txt 2>temp/error.txt
rm temp/previousOutput.txt 2>temp/error.txt
rm temp/givenAnswerSet.txt 2>temp/error.txt
rm temp/existingOutcomes.txt 2>temp/error.txt
rm temp/newOutputObtained.txt 2>temp/error.txt


#Assigning values to variables based on given input
givenOutput=$1
givenDistance=$2
numOfAtoms=$3
numOfGenClauses=$4
numOfPrefClauses=$5
instanceNum=$6
PreferenceSet=$7
SimilarOrDissimilar=$8

#Choosing input data set and required programs based on given "PreferenceSet"
if [ "$PreferenceSet" == "1" ]
then
  dir="data/one/"
  findBetter="findBetter.lp"
elif [ "$PreferenceSet" == "2" ]
then
  dir="data/two/"
  findBetter="findBetterRanked.lp"
elif [ "$PreferenceSet" == "3" ]
then
  dir="data/tree/"
  findBetter="findBetterRanked.lp"
fi


if [ "$SimilarOrDissimilar" == "1" ]
then
  simOrDissim="findSim.lp"
elif [ "$SimilarOrDissimilar" == "2" ]
then
  simOrDissim="findDissim.lp"
fi


#Choosing input data files i.e. ASO program based on given numOfAtoms,numOfGenClauses,numOfPrefClauses,instanceNum
generatorInput=$dir"gen/gen"$numOfAtoms"_"$numOfGenClauses"_"$instanceNum".txt"
preferenceInput=$dir"pref/pref"$numOfAtoms"_"$numOfPrefClauses"_"$instanceNum".txt"



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


# $givenOutput has constraint which prevents same givenAnswerSet and also has sdegrees of givenAnswerSet
#Below statement adds quote to each line in $givenOutput file
answer=$(cat $givenOutput | awk '{for(i=1;i<=NF;i++) {print "\""$i"\""}}')
# Add given output to givenAnswerSet.txt
cat $givenOutput >> temp/givenAnswerSet.txt


#Given outcome is considered as 0th outcome.
outcome=0

existingAnswers="temp/existingOutcomes.txt"

#modify givenOutput format and add to existing Outcomes
existingOutcome0=$(grep "nswer(" temp/givenAnswerSet.txt)
echo "outcomes(0).\n%outcome: 0." >>temp/existingOutcomes.txt
echo $existingOutcome0 >>temp/existingOutcomes.txt
existingOutcome0=$(grep -o 'givensdegree([^ ]*' temp/givenAnswerSet.txt |sed 's/givensdegree(/givensdegree(0,/g'|awk '{for(i=1;i<=NF;i++) {print ""$i""}}')
echo $existingOutcome0 >>temp/existingOutcomes.txt
existingOutcome0=$(grep "nswer(" temp/givenAnswerSet.txt |grep -o '[^ ]*nswer([^ ]*' |sed 's/)./),/g'| tr -d '\n'|sed 's/[,]*$/./')
echo $existingOutcome0 >>temp/existingOutcomes.txt


#loop begins
while :
do
  #find outcome different and similar to given outcome and different from existingOutcomes
  clingo $generatorInput generatorProgram.lp $givenOutput $simOrDissim $preferenceInput calculateSatDegree.lp $existingAnswers -c distance=$givenDistance >temp/tempAnswer.txt
  answer=$(grep "nswer(" temp/tempAnswer.txt | awk '{for(i=1;i<=NF;i++) {print "\""$i"\""}}')

  #obtained answer is similar outcome
  similarAnswer=$(grep "nswer(" temp/tempAnswer.txt )
  #modify outome and store it in "previousOutput.txt"
  panswer=$(grep "nswer(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
  echo $panswer > temp/previousOutput.txt
  previousOutput="temp/previousOutput.txt"

  #Checking whether ASO program has any outcome that is similar or dissimilar to given outcome.
  #If ASO program doesn't have such outcome, we stop computation
  unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
  if [ "$unsatisfy" == "UNSATISFIABLE" ]
  then
      rm temp/solution.txt 2>temp/error.txt
      MAIN_END=$(gdate +%s.%N) #Storing computation end time
      timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
      echo "timeTaken= "$timeTaken
      exit
  fi

  #Storing similar solution
  grep "nswer(" temp/tempAnswer.txt >temp/solution.txt

  similarAnswer=$(grep "nswer(" temp/tempAnswer.txt )

  echo '\n'"Checking if obtained similar outcome is Optimal or not:"

  #check if similar answer is optimal outcome or not
  clingo $generatorInput generatorProgram.lp $preferenceInput calculateSatDegree.lp $previousOutput $findBetter > temp/tempAnswer.txt
  #If Similar/Dissimilar outcome is optimal optimal, stop computation "
  unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
  if [ "$unsatisfy" == "UNSATISFIABLE" ]
  then
      MAIN_END=$(gdate +%s.%N) #Storing computation end time
      timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
      echo "timeTaken= "$timeTaken
      break
  fi

  #"If Similar/Dissimilar outcome is not optimal optimal, repeat process "
  outcome=$((outcome+1))
  #If 500 outcomes are added to "existing Outcomes", we stop proces
  if [ $outcome -gt 500 ]
  then
    echo "500OutcomesExceeded" > temp/solution.txt
    MAIN_END=$(gdate +%s.%N) #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
    echo "timeTaken= "$timeTaken
    exit
  fi

  #Since similar outcome is not optical optimal, add it  to existing outcomes
  #modify outcome format and add to existing Outcomes
  echo "\n" >>temp/existingOutcomes.txt
  newOutputObtained=$(echo $similarAnswer | awk '{for(i=1;i<=NF;i++) {print "\""$i".\""}}')
  /usr/bin/java ModifyOptimalOutput $numOfAtoms $outcome $newOutputObtained  >>temp/existingOutcomes.txt
done
