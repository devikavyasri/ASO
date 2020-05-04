#!/bin/sh
#This script is used to find similar or dissimilar outcome to given outcome
#using VariantAlternative method

#pseudo code
#1. Convert givenOutput to the ASP readable format and store in givenAnswerSet.txt
#2. Consider givenOutput as outcome 0 and add to existingOutcomes.txt
#3. Initailly distance is n+1 for similar and -1 for dissimilar
#4. Loop (true if obtainedDistance > requiredDistance)
  #5. Find NotWorseDiffSet for existingOutcomes.txt
  #6. Find optimal solution (optimalAnswer) using NotWorseDiffSet as input
  #7. Calculate distance between optimalAnswer and givenOutput
  #8. If obtainedDistance > requiredDistance, then
    #9. Add obtained optimal answer to existingOutcomes.txt
    #10. Repeat loop from step 4.
  #11. If obtainedDistance <= requiredDistance, then print optimalAnswer and exit

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
  findNotWorseDiffSet="findNotWorseDiffSet.lp"
  findBetter="findBetter.lp"
elif [ "$PreferenceSet" == "2" ]
then
  dir="data/two/"
  findNotWorseDiffSet="findNotWorseDiffSetRanked.lp"
  findBetter="findBetterRanked.lp"
elif [ "$PreferenceSet" == "3" ]
then
  dir="data/tree/"
  findNotWorseDiffSet="findNotWorseDiffSetRanked.lp"
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
  #find outcome different and similar/Dissimilar to given outcome and not worse and different from existingOutcomes
  clingo $generatorInput generatorProgram.lp $givenOutput $simOrDissim $preferenceInput calculateSatDegree.lp $existingAnswers $findNotWorseDiffSet -c distance=$givenDistance >temp/tempAnswer.txt
  answer=$(grep "nswer(" temp/tempAnswer.txt | awk '{for(i=1;i<=NF;i++) {print "\""$i"\""}}')

  #obtained answer becomes optimal if findBetter.lp is unsatisfiable and so
  ##modify outome and store it in "previousOutput.txt"
  optimalAnswer=$(grep "nswer(" temp/tempAnswer.txt )
  panswer=$(grep "nswer(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
  echo $panswer >temp/previousOutput.txt
  previousOutput="temp/previousOutput.txt"

  #Checking whether ASO program has any outcome that is similar and notWorseDifferent to given outcome.
  #If ASO program doesn't have such outcome, we stop computation
  unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
  if [ "$unsatisfy" == "UNSATISFIABLE" ]
  then
      rm temp/solution.txt
      MAIN_END=$(gdate +%s.%N)  #Storing computation end time
      timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
      echo "timeTaken= "$timeTaken
      exit
  fi

  #Storing notworseDiff solution
  grep "nswer(" temp/tempAnswer.txt >temp/solution.txt

  optimalAnswer=$(grep "nswer(" temp/tempAnswer.txt )


  #find optimal outcome from the previousOutput(NotWorseDiff) obtained (new generator program)
  while [ "$unsatisfy" != "UNSATISFIABLE" ]
  do
    clingo $generatorInput generatorProgram.lp $givenOutput $simOrDissim $preferenceInput calculateSatDegree.lp $previousOutput $findBetter -c distance=$givenDistance > temp/tempAnswer.txt
    #modify outome and store it in "previousOutput.txt"
    panswer=$(grep "nswer(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
    echo $panswer > temp/previousOutput.txt

    #Checking whether previous outcome is optimal or not.
    #If optimal, check if it is optimal to real problem or not.
    unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
    if [ "$unsatisfy" == "UNSATISFIABLE" ]
    then
        #echo "UNSATISFIABLE"
        break
    fi

    #If not optimal, iteratively find better outcome
    grep "nswer(" temp/tempAnswer.txt >temp/solution.txt
    optimalAnswer=$(grep "nswer(" temp/tempAnswer.txt )
  done



  #Now we have optimal answer set for new generatorProgram
  #Find if this optimal is optimal to real problem
  panswer=$(echo $optimalAnswer |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
  echo $panswer > temp/midOptimalOutput.txt
  midOptimal="temp/midOptimalOutput.txt"

  clingo $generatorInput generatorProgram.lp $preferenceInput calculateSatDegree.lp $midOptimal $findBetter > temp/tempAnswer.txt

  #modify outome and store it in "previousOutput.txt"
  panswer=$(grep "nswer(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
  echo $panswer >temp/previousOutput.txt

  #Checking whether previous outcome is optimal to real problem or not.
  #If optimal, we stop computation
  unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
  if [ "$unsatisfy" == "UNSATISFIABLE" ]
  then
      MAIN_END=$(gdate +%s.%N) #Storing computation end time
      timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
      echo "timeTaken= "$timeTaken
      break
  fi

  #If not optimal, we repeat process
  outcome=$((outcome+1))
  if [ $outcome -gt 500 ]
  then
    echo "500OutcomesExceeded" > temp/solution.txt
    MAIN_END=$(gdate +%s.%N) #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
    echo "timeTaken= "$timeTaken
    exit
  fi

  #Since optimal outcome is not real optimal, add it  to existing outcomes
  #modify givenOutput format and add to existing Outcomes
  echo "\n" >>temp/existingOutcomes.txt
  newOutputObtained=$(echo $optimalAnswer | awk '{for(i=1;i<=NF;i++) {print "\""$i".\""}}')
  /usr/bin/java ModifyOptimalOutput $numOfAtoms $outcome $newOutputObtained  >>temp/existingOutcomes.txt


done
