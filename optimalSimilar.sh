#!/bin/sh
#This script is used to find similar outcome to given outcome
#using StraightForward method

#pseudo code
#1. Convert givenOutput to the ASP readable format and store in givenAnswerSet.txt
#2. Consider givenOutput as outcome 0 and add to existingOutcomes.txt
#3. Initailly distance =n+1 for similar
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
rm temp/givenAnswerSetToCalculateDistance.txt 2>temp/error.txt
rm temp/distance.txt 2>temp/error.txt

#Assigning values to variables based on given input
givenOutput=$1
distance=$2
numOfAtoms=$3
numOfGenClauses=$4
numOfPrefClauses=$5
instanceNum=$6
PreferenceSet=$7
SimilarOrDissimilar=$8



#Choosing input data set and required programs based on given "PreferenceSet"
if [ "$PreferenceSet" == "1" ] #If PreferenceSet == unranked
then
  dir="data/one/"
  findBetter="findBetter.lp"
  findNotWorseDiffSet="findNotWorseDiffSet.lp"
elif [ "$PreferenceSet" == "2" ] #If PreferenceSet == ranked
then
  dir="data/two/"
  findBetter="findBetterRanked.lp"
  findNotWorseDiffSet="findNotWorseDiffSetRanked.lp"
elif [ "$PreferenceSet" == "3" ] #If PreferenceSet == TwoLPTRees
then
  dir="data/tree/"
  findBetter="findBetterRanked.lp"
  findNotWorseDiffSet="findNotWorseDiffSetRanked.lp"
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


answer=$(cat $givenOutput | awk '{for(i=1;i<=NF;i++) {print "\""$i"\""}}')
givenAnswerSet=$(cat $givenOutput | awk '{for(i=1;i<=NF;i++) {print ""$i""}}')
echo $givenAnswerSet >> temp/givenAnswerSet.txt
cat temp/givenAnswerSet.txt

#Given outcome is considered as 0th outcome.
outcome=0
existingAnswers="temp/existingOutcomes.txt"

#Initializing distance to higher value i.e n+1.
obtainedDistance=$((numOfAtoms+1))


#modify givenOutput format and add to existing Outcomes
existingOutcome0=$(grep "nswer(" temp/givenAnswerSet.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree(/givensdegree(0,/g'|awk '{for(i=1;i<=NF;i++) {print ""$i""}}')
echo "outcomes(0).\n%outcome: 0." >>temp/existingOutcomes.txt
echo $existingOutcome0 >>temp/existingOutcomes.txt
existingOutcome0=$(grep "nswer(" temp/givenAnswerSet.txt |grep -o '[^ ]*nswer([^ ]*' |sed 's/)./),/g'| tr -d '\n'|sed 's/[,]*$/./')
echo $existingOutcome0 >>temp/existingOutcomes.txt

cat temp/givenAnswerSet.txt | awk '{print $NF}'|sed -e 's/,/./g'| sed -e 's/:-//g' >temp/givenAnswerSetToCalculateDistance.txt
givenAnswerSetToCalculateDistance="temp/givenAnswerSetToCalculateDistance.txt"


#iteratively find similar optimal outcome
while [ $obtainedDistance -gt $distance ]
do
  #find outcome not worse and different from given outcome
  clingo $generatorInput generatorProgram.lp $preferenceInput calculateSatDegree.lp $existingAnswers $findNotWorseDiffSet >temp/tempAnswer.txt
  answer=$(grep "nswer(" temp/tempAnswer.txt | awk '{for(i=1;i<=NF;i++) {print "\""$i"\""}}')

  #obtained answer becomes optimal if findBetter.lp is unsatisfiable
  optimalAnswer=$(grep "nswer(" temp/tempAnswer.txt )
  #modify outome and store it in "previousOutput.txt"
  panswer=$(grep "nswer(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
  echo $panswer >temp/previousOutput.txt
  previousOutput="temp/previousOutput.txt"

  #Checking whether outcome not worse and different from given outcome exists or not.
  #If does not exist, stop computation.
  unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
  if [ "$unsatisfy" == "UNSATISFIABLE" ]
  then
      rm temp/solution.txt 2>temp/error.txt
      MAIN_END=$(gdate +%s.%N) #Storing computation end time
      timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
      echo "timeTaken= "$timeTaken
      exit
  fi

  #Storing notworseDiff solution
  grep "nswer(" temp/tempAnswer.txt >temp/solution.txt

  optimalAnswer=$(grep "nswer(" temp/tempAnswer.txt )


  #find optimal outcome from the previousOutput(NotWorseDiff) obtained
  while [ "$unsatisfy" != "UNSATISFIABLE" ]
  do
    clingo $generatorInput generatorProgram.lp $preferenceInput calculateSatDegree.lp $previousOutput $findBetter > temp/tempAnswer.txt
    #modify outome and store it in "previousOutput.txt"
    panswer=$(grep "nswer(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
    echo $panswer >temp/previousOutput.txt

    #If findBetter is unsatisfiable, then latest obtained outcome is optimal.
    #Break loop and then check for similarity/dissimilarity condition
    unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
    if [ "$unsatisfy" == "UNSATISFIABLE" ]
    then
        break
    fi

    #If findBetter is not unsatisfiable, then repeat finding better outcome
    grep "nswer(" temp/tempAnswer.txt >temp/solution.txt
    optimalAnswer=$(grep "nswer(" temp/tempAnswer.txt )
  done


  newOutputObtained=$(echo $optimalAnswer | awk '{for(i=1;i<=NF;i++) {print "\""$i".\""}}')
  optimalSolution=$(echo $optimalAnswer |awk '{for(i=1;i<=NF;i++) {print "optimal"$i"."}}')
  echo $optimalSolution >temp/optimal.txt
  currentOptimal="temp/optimal.txt"

  #find distance between optimal Outcome and given Outcome
  clingo checkingDistanceCondition.lp $currentOptimal $givenAnswerSetToCalculateDistance -c numOfAtoms=$numOfAtoms 2>temp/error.txt >temp/distance.txt
  obtainedDistance=$(grep "distanceCount" temp/distance.txt | cut -d '(' -f2 |rev|cut -c 2- |rev)
  echo $newOutputObtained >temp/newOutputObtained.txt

  #If total outcomes found until now  <= 500, stop process
  outcome=$((outcome+1))
  if [ $outcome -gt 500 ]
  then
    echo "500OutcomesExceeded" > temp/solution.txt
    MAIN_END=$(gdate +%s.%N) #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
    echo "timeTaken= "$timeTaken
    exit
  fi

  #check if obtained distance > given distance then repeat process
  if [ $obtainedDistance -gt $distance ]
  then
    /usr/bin/java ModifyOptimalOutput $numOfAtoms $outcome $newOutputObtained  >>temp/existingOutcomes.txt
  fi

  #check if obtained distance < given distance then print optimal answer
  if [ $obtainedDistance -le $distance ]
  then
    MAIN_END=$(gdate +%s.%N) #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
    echo "timeTaken= "$timeTaken
  fi
done
