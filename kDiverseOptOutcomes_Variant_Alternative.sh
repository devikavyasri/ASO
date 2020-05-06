#!/bin/sh
#This script is used to find K-diverse outcomes using VariantAlternative method

#pseudo code
#1.Generate outcome for Pgen'
#2. Check if each outcome is optimal or not
#3. If not optimal, add it to failed outcomes and repeat from step 1
#4. Else return the outcome as result


#Validating whether correct number of arguments given or not
if [ $# -ne 6 ]
  then
    echo "Six arguments are not supplied"
    echo "First Argument : number Of Atoms (Atoms shoud be >=3) "
    echo "Second Argument: number of generator Clauses "
    echo "Third Argument : number of preference Clauses "
    echo "Fourth Argument: distance "
    echo "Fifth Argument : Instance Number"
    echo "Sixth Argument is PreferenceSet : 1 (unranked) or 2 (ranked) or 3 (TwoLPTrees) "
    echo '\n'
    exit
fi

#deleting temporary files
rm temp/tempAnswer.txt 2>temp/error.txt
rm temp/previousOutput.txt 2>temp/error.txt
rm temp/givenAnswerSet.txt 2>temp/error.txt
rm temp/existingOutcomes.txt 2>temp/error.txt
rm temp/newOutputObtained.txt 2>temp/error.txt
rm temp/diverseOptimalOutcomes.txt 2>temp/error.txt
rm temp/avoidOutcomes_*.txt 2>temp/error.txt


#Assigning values to variables based on given input
numOfAtoms=$1
numOfGenClauses=$2
numOfPrefClauses=$3
distance=$4
instanceNum=$5
preferenceSet=$6

#Initializing "requiredTotalDiverseOutcomes" variable to 3
requiredTotalDiverseOutcomes=3

#Choosing input data set and required programs based on given "PreferenceSet"
if [ "$preferenceSet" == "1" ]
then
  dir="data/one/"
  findNotWorseDiffSet="findNotWorseDiffSet.lp"
  findBetter="findBetter.lp"
elif [ "$preferenceSet" == "2" ]
then
  dir="data/two/"
  findNotWorseDiffSet="findNotWorseDiffSetRanked.lp"
  findBetter="findBetterRanked.lp"
elif [ "$preferenceSet" == "3" ]
then
  dir="data/tree/"
  findNotWorseDiffSet="findNotWorseDiffSetRanked.lp"
  findBetter="findBetterRanked.lp"
fi

#Choosing input data files i.e. ASO program based on given numOfAtoms,numOfGenClauses,numOfPrefClauses,instanceNum
generatorInput=$dir"gen/gen"$numOfAtoms"_"$numOfGenClauses"_"$instanceNum".txt"
preferenceInput=$dir"pref/pref"$numOfAtoms"_"$numOfPrefClauses"_"$instanceNum".txt"

#Initializing some varaibles
checkOptimalityResult="false"
totalAtoms=$( expr "$requiredTotalDiverseOutcomes" '*' "$numOfAtoms" )
totalFailedOutcomesFound=0
previousOutput="temp/previousOutput.txt"
failedOutcomes="temp/failedOutcomes.txt"
modifiedDiverseOutcomes="temp/modifiedDiverseOutcomes.txt"
singleOutcomeToTest="temp/singleOutcomeToTest.txt"

echo "" > temp/failedOutcomes.txt

checkOptimality(){
  clingo $generatorInput generatorProgram.lp $preferenceInput calculateSatDegree.lp $previousOutput $findBetter > temp/tempAnswer.txt
  unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
  if [ "$unsatisfy" == "UNSATISFIABLE" ]
  then
      checkOptimalityResult="true" #"Obtained dissimilar outcome is Optimal outcome"
  else
      checkOptimalityResult="false" #Obtained dissimilar outcome is not Optimal outcome
  fi
}


#Storing computation start time
MAIN_START=$(gdate +%s.%N)

while :
do
  if [ "$totalFailedOutcomesFound" -ge 500 ]
  then
    echo "500OutcomesExceeded" > temp/diverseOptimalOutcomes.txt
    echo "500OutcomesExceeded" > temp/solution.txt
    MAIN_END=$(gdate +%s.%N) #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
    echo "timeTaken= "$timeTaken
    break
  fi
  clingo $generatorInput multipleGenratorProgram.lp $failedOutcomes -c totalDiverseOutcomes=$requiredTotalDiverseOutcomes -c distance=$distance > temp/tempAnswer.txt
  optDiffSetOutcome=$(grep "nswer(" temp/tempAnswer.txt)

  lengthOfOutcome=$(echo -n $optDiffSetOutcome | wc -c)
  if [ $lengthOfOutcome -eq 3 ]  #There is no diverse set of outcomes to ASO program
  then
    MAIN_END=$(gdate +%s.%N) #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
    echo "NoDiverseSetOfOptimalOutcomes" > temp/solution.txt
    echo "timeTaken= "$timeTaken
    break
  fi
  diverseOutcomeNumber=1
  echo $optDiffSetOutcome | awk '{for(i=1;i<=NF;i++) {print ""$i"."}}' > temp/modifiedDiverseOutcomes.txt  #Adds "." at end of each answer() or negAnswer().
  echo "" >temp/diverseOptimalOutcomes.txt

  while [ $diverseOutcomeNumber -le $requiredTotalDiverseOutcomes ]
  do
    clingo $modifiedDiverseOutcomes desiredAnswerSetToTestOptimality.lp -c outcomeNumber=$diverseOutcomeNumber > temp/tempAnswer.txt
    #Take single output from setOfDiverseOutcomes obtained
    grep "nswer(" temp/tempAnswer.txt | awk '{for(i=1;i<=NF;i++) {print ""$i"."}}' > temp/singleOutcomeToTest.txt
    clingo $singleOutcomeToTest $preferenceInput calculateSatDegree.lp > temp/tempAnswer.txt #Get satisfaction degrees of output
    panswer=$(grep "sdegree(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
    echo $panswer >temp/previousOutput.txt
    checkOptimality
    #if checkOptimalityResult is false, add answerSet to failed Outcomes
    if [ $checkOptimalityResult == false ]
    then
      totalFailedOutcomesFound=$((totalFailedOutcomesFound+1))

      /usr/bin/java PrintAnswerRemoveSdegree "2" $totalAtoms $(echo $optDiffSetOutcome | awk '{for(i=1;i<=NF;i++) {print ""$i""}}') > temp/constraintTemp.txt
      sed 's/^/:-/' temp/constraintTemp.txt >> temp/failedOutcomes.txt
      break
    else
      /usr/bin/java PrintAnswerRemoveSdegree "2" $numOfAtoms $(cat temp/singleOutcomeToTest.txt | tr '.' ' '| awk '{for(i=1;i<=NF;i++) {print ""$i""}}') >> temp/diverseOptimalOutcomes.txt
    fi
    diverseOutcomeNumber=$((diverseOutcomeNumber+1))
  done
  if [ $checkOptimalityResult == true ]
  then
    MAIN_END=$(gdate +%s.%N) #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
    cat temp/diverseOptimalOutcomes.txt |tr ',' ' '|tr '.' ' ' >temp/solution.txt
    echo "timeTaken= "$timeTaken
    break
  fi
done
