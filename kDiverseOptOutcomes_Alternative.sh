#!/bin/sh
#This script is used to find K-diverse outcomes using Alternative method

#pseudo code
#1.Generate outcome for Pgen'
#2. Check if each outcome is optimal or not
#3. If not optimal, add it to failed outcomes and repeat from step 1
#4. Else return the outcome as result


#Validating whether correct number of arguments given or not
if [ $# -ne 6 ]
  then
    echo "Six arguments are not supplied"
    echo "First Argument: number Of Atoms (Atoms shoud be >=3) "
    echo "Second Argument: number of generator Clauses "
    echo "Third Argument: number of preference Clauses "
    echo "Fourth Argument: distance "
    echo "Fifth Argument: Instance Number"
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
  findBetterDiverse="findBetterForDiverse.lp"
elif [ "$preferenceSet" == "2" ]
then
  dir="data/two/"
  findNotWorseDiffSet="findNotWorseDiffSetRanked.lp"
  findBetter="findBetterRanked.lp"
  findBetterDiverse="findBetterForDiverseRanked.lp"
elif [ "$preferenceSet" == "3" ]
then
  dir="data/tree/"
  findNotWorseDiffSet="findNotWorseDiffSetRanked.lp"
  findBetter="findBetterRanked.lp"
  findBetterDiverse="findBetterForDiverseRanked.lp"
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
  if [ "$unsatisfy" == "UNSATISFIABLE" ] #Obtained dissimilar outcome is Optimal outcome
  then
      checkOptimalityResult="true"
  else        #Obtained dissimilar outcome is not Optimal outcome
      checkOptimalityResult="false"
  fi
}


#Storing computation start time
MAIN_START=$(gdate +%s.%N)

#generate copies of preferenceProgram
/usr/bin/java PreferenceProgramCopiesGenerator $preferenceInput $requiredTotalDiverseOutcomes

#Storing all names of files of copies of Preference program in variable "preferencePrograms"
preferencePrograms=""
outcomeNum=1
while [ $outcomeNum -le $requiredTotalDiverseOutcomes ]
do
  preferencePrograms=$preferencePrograms" "$dir"pref/pref"$numOfAtoms"_"$numOfPrefClauses"_"$instanceNum"_"$outcomeNum".txt"
  outcomeNum=$((outcomeNum+1))
done


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
  #Finding optimal diverse set
  clingo $generatorInput multipleGenratorProgram.lp $failedOutcomes $preferencePrograms multipleDiverseCalculateSatDegree.lp -c totalDiverseOutcomes=$requiredTotalDiverseOutcomes -c distance=$distance > temp/tempAnswer.txt
  optDiffSetOutcome=$(grep "nswer(" temp/tempAnswer.txt)

  #Storing previous obtained outcome in file "temp/previousOutput.txt"
  panswer=$(grep "nswer(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
  echo $panswer > temp/previousOutput.txt

  unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
  if [ "$unsatisfy" == "UNSATISFIABLE" ]
  then
      MAIN_END=$(gdate +%s.%N)
      timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc)
      echo "NoDiverseSetOfOptimalOutcomes" > temp/solution.txt
      echo "timeTaken= "$timeTaken
      outcomeNum=1
      while [ $outcomeNum -le $requiredTotalDiverseOutcomes ]
      do
        rm $dir"pref/pref"$numOfAtoms"_"$numOfPrefClauses"_"$instanceNum"_"$outcomeNum".txt" 2>temp/error.txt
        outcomeNum=$((outcomeNum+1))
      done
      break
  fi

  #Find optimal using findBetterForDiverse.lp
  while [ "$unsatisfy" != "UNSATISFIABLE" ]
  do
    clingo $generatorInput multipleGenratorProgram.lp $failedOutcomes $preferencePrograms multipleDiverseCalculateSatDegree.lp $previousOutput $findBetterDiverse -c totalDiverseOutcomes=$requiredTotalDiverseOutcomes -c distance=$distance > temp/tempAnswer.txt
    panswer=$(grep "nswer(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
    echo $panswer >temp/previousOutput.txt

    unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
    if [ "$unsatisfy" == "UNSATISFIABLE" ] #Latest answerSet is optimal
    then
        break
    fi
    optDiffSetOutcome=$(grep "nswer(" temp/tempAnswer.txt)
  done

  optDiffSetOutcomeWithSdegree=$optDiffSetOutcome

  # Removing sdegree for optDiffSetOutcome
  /usr/bin/java PrintAnswerRemoveSdegree "1" $totalAtoms $(echo $optDiffSetOutcome | awk '{for(i=1;i<=NF;i++) {print ""$i""}}') > temp/tempAnswer.txt

  optDiffSetOutcome=$(cat temp/tempAnswer.txt)

  #Checking if obtained optimal diverse outcomes are optimal to real problem
  diverseOutcomeNumber=1
  echo $optDiffSetOutcome  > temp/modifiedDiverseOutcomes.txt  #Adds "." at end of each answer() or negAnswer().

  echo "" >temp/diverseOptimalOutcomes.txt
  while [ $diverseOutcomeNumber -le $requiredTotalDiverseOutcomes ]
  do
    clingo $modifiedDiverseOutcomes desiredAnswerSetToTestOptimality.lp -c outcomeNumber=$diverseOutcomeNumber > temp/tempAnswer.txt
    grep "nswer(" temp/tempAnswer.txt | awk '{for(i=1;i<=NF;i++) {print ""$i"."}}' > temp/singleOutcomeToTest.txt
    clingo $singleOutcomeToTest $preferenceInput calculateSatDegree.lp > temp/tempAnswer.txt
    panswer=$(grep "sdegree(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
    echo $panswer >temp/previousOutput.txt
    checkOptimality
    #if checkOptimalityResult is false, add answerSet to failed Outcomes
    if [ $checkOptimalityResult == false ]
    then
      totalFailedOutcomesFound=$((totalFailedOutcomesFound+1))
      /usr/bin/java PrintAnswerRemoveSdegree "2" $totalAtoms $(echo $optDiffSetOutcomeWithSdegree | awk '{for(i=1;i<=NF;i++) {print ""$i""}}') > temp/constraintTemp.txt
      sed 's/^/:-/' temp/constraintTemp.txt >> temp/failedOutcomes.txt
      break
    else
      /usr/bin/java PrintAnswerRemoveSdegree "2" $numOfAtoms $(cat temp/singleOutcomeToTest.txt | tr '.' ' '| awk '{for(i=1;i<=NF;i++) {print ""$i""}}') >> temp/diverseOptimalOutcomes.txt
    fi
    diverseOutcomeNumber=$((diverseOutcomeNumber+1))
  done
  if [ $checkOptimalityResult == true ] #setof diverse optimal Found
  then
    MAIN_END=$(gdate +%s.%N)
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc)
    cat temp/diverseOptimalOutcomes.txt |tr ',' ' '|tr '.' ' ' >temp/solution.txt
    echo "timeTaken= "$timeTaken
    outcomeNum=1
    while [ $outcomeNum -le $requiredTotalDiverseOutcomes ]
    do
      rm $dir"pref/pref"$numOfAtoms"_"$numOfPrefClauses"_"$instanceNum"_"$outcomeNum".txt" 2>temp/error.txt
      outcomeNum=$((outcomeNum+1))
    done
    break
  fi
done
