#!/bin/sh
#This script is used to find K-diverse outcomes using StraightForward_SF method

#pseudo code
#1. Initialize outcomeNumber = i = 0.
#2. diverseOptimalOutcomes and avoidOutcomes_i are empty
#Loop
#3. Increment i by 1 i.e. i++
#4. Run FindOptDiffDissimSet and get result
#5. If result = outcome = M, add M to diverseOptimalOutcomes and avoidOutcomes_i
#6. If result = "unsatisfiable" and i==1, then return "Unsatisfiable or no solution"
#7. If result = "unsatisfiable" and i>1, then remove last solution from diverseOptimalOutcomes
#   and set avoidOutcomes_i = empty and set i= i-2;
#7. Repeat steps 3 to 7 till i == k



# findOptDiffDissimSet pseudo code
# Input: ASP Program P, distance d, diverseOptimalOutcomes, differentOutcomes
# diverseOptimalOutcomes = O; differentOutcomes = avoidOutcomes_i = Oi
#findOptDifSet
#1. Find an outcome S that is NotWorseDiffSet to differentOutcomes
#2. Find an optimal outcome M by using findBetter to S
  #2.5. If no solution for steps 1 or 2, return "unsatisfiable"
#checkDissimilarity
#3. Check if HD(M,A) >= distance for all A belongs to diverseOptimalOutcomes
#4. If true, M is solution and return M
#5. Otherwise, add M to differentOutcomes and repeat from step 1.


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
rm temp/temp.txt 2>temp/error.txt
rm temp/temp1.txt 2>temp/error.txt
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




##########Functions############
#Finding set of diverse Optimal outcomes
findOptDiffDissimSet()
{
  diverseOptimalOutcomes=$2  #$2 is "diverseOptimalOutcomes.txt"
  differentOutcomes=$3    #$3 is "avoidOutcomes_$outcome.txt"
  totalOutputsInAvoidOutcomesFile=$(cat $differentOutcomes | grep -o ':-' | wc -l) #xargs trims white spaces
  totalDivesrseOutcomesFound=$(cat $diverseOptimalOutcomes | sed '/^\s*$/d' | wc -l| xargs)
  touch temp/differentOutcomes.txt
  cat $differentOutcomes > temp/differentOutcomes.txt
  differentOutcomes="temp/differentOutcomes.txt"
  totalFailedOutcomesFound=$totalOutputsInAvoidOutcomesFile
  while :
  do
    findOptDiffSet $differentOutcomes
    lengthOfOutcome=$(echo -n $optDiffSetOutcome | wc -c)
    if [ $lengthOfOutcome -eq 3 ]
    then
      break
    fi
    /usr/bin/java PrintAnswerRemoveSdegree "1" $numOfAtoms $(echo $optDiffSetOutcome | awk '{for(i=1;i<=NF;i++) {print ""$i""}}') > temp/modifyOutputForDissimilarityCheck.txt
    checkDissimilarity $diverseOptimalOutcomes
    if [ $checkDissimilarityResult == true ] #dissimilariy check passed
    then
      echo $optDiffSetOutcome
      /usr/bin/java PrintAnswerRemoveSdegree "2" $numOfAtoms $(echo $optDiffSetOutcome | awk '{for(i=1;i<=NF;i++) {print ""$i""}}') >> $diverseOptimalOutcomes
      newOutputObtained=$(echo $optDiffSetOutcome | awk '{for(i=1;i<=NF;i++) {print "\""$i".\""}}')
      /usr/bin/java ModifyOptimalOutput $numOfAtoms $outcome $newOutputObtained >> temp/avoidOutcomes_$outcome.txt
      break
    else #failed dissimilariy check
      totalFailedOutcomesFound=$((totalFailedOutcomesFound+1))
      #If result=false, add optimalOutcome to differentOutcomes and repeat loop
      newOutputObtained=$(echo $optDiffSetOutcome | awk '{for(i=1;i<=NF;i++) {print "\""$i".\""}}')
      /usr/bin/java ModifyOptimalOutput $numOfAtoms $totalFailedOutcomesFound $newOutputObtained >> temp/differentOutcomes.txt
      maxOutcomes=500
      if [ "$totalFailedOutcomesFound" -ge "$maxOutcomes" ]
      then
        break
      fi
    fi
  done
}



#Finding single Optimal outcome
findOptDiffSet()
{
  differentOutcomes=$1
  findNotWorseDifferentOutcome $differentOutcomes ##Finding outcome that is different and not worse from other obtained outcomes.

  #Finding Optimal outcome using findOptDiffSet and notWorseDiffOutcome:"
  optDiffSetOutcome=$notWorseDiffOutcome
  #find optimal outcome from the previousOutput (i.e. NotWorseDiffOutcome) obtained
  while [ "$optDiffSetOutcome" != "UNSATISFIABLE" ]
  do
    clingo $generatorInput generatorProgram.lp $preferenceInput calculateSatDegree.lp $previousOutput $findBetter > temp/tempAnswer.txt
    previousAnswer=$(grep "nswer(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
    echo $previousAnswer >temp/previousOutput.txt
    unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
    if [ "$unsatisfy" == "UNSATISFIABLE" ]
    then
        break
    fi
    optDiffSetOutcome=$(grep "nswer(" temp/tempAnswer.txt )
  done
  #echo '\n'"optDiffSetOutcome: " $optDiffSetOutcome
}


#Find an outcome S that is NotWorseDiffSet to differentOutcomes
findNotWorseDifferentOutcome()
{
  differentOutcomes=$1
  #If differentOutcomes.txt is empty, then just find an outcome arbitarity
  if [[ -z $(grep '[^[:space:]]' $differentOutcomes) ]] #differentOutcomes file is empty
  then
    clingo $generatorInput generatorProgram.lp $preferenceInput calculateSatDegree.lp >temp/tempAnswer.txt
  else  #differentOutcomes file is not empty
    #find outcome not worse and different from differentOutcomes
    clingo $generatorInput generatorProgram.lp $preferenceInput calculateSatDegree.lp $differentOutcomes $findNotWorseDiffSet >temp/tempAnswer.txt
  fi
  notWorseDiffOutcome=$(grep "nswer(" temp/tempAnswer.txt )
  previousAnswer=$(grep "nswer(" temp/tempAnswer.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
  echo $previousAnswer >temp/previousOutput.txt
  unsatisfy=$(grep "UNSATISFIABLE" temp/tempAnswer.txt)
  if [ "$unsatisfy" == "UNSATISFIABLE" ]
  then
      #"No solution for findNotWorseDifferentOutcome"
      notWorseDiffOutcome=$(grep "UNSATISFIABLE" temp/tempAnswer.txt )
  fi
}



checkDissimilarity()
{
  diverseOptimalOutcomes=$1
  if [[ -z $(grep '[^[:space:]]' $diverseOptimalOutcomes) ]] #Zero diverseOptimalOutcomes found
  then
    checkDissimilarityResult=true
  else  #One or more diverseOptimalOutcomes found
    totalDivesrseOutcomesFound=$(cat $diverseOptimalOutcomes | sed '/^\s*$/d' | wc -l| xargs)
    diverseOutcomeNumber=1
    touch temp/checkTemp.txt
    /usr/bin/java PrintAnswerRemoveSdegree "2" $numOfAtoms $(echo $optDiffSetOutcome | awk '{for(i=1;i<=NF;i++) {print ""$i""}}') | tr ',' '.' > temp/checkTemp.txt
    while [ $diverseOutcomeNumber -le $totalDivesrseOutcomesFound ]
    do
      echo '\n' >> temp/checkTemp.txt
      head -$diverseOutcomeNumber temp/diverseOptimalOutcomes.txt| tail -1 |tr ',' '.' > temp/temp1.txt
      temp1File="temp/temp1.txt"
      clingo convertingOutputForDissimCheck.lp $temp1File -c outcome=$diverseOutcomeNumber > temp/temp.txt
      grep "nswer(" temp/temp.txt | tr ' ' '.' | tr '\n' '.'>> temp/checkTemp.txt
      checkTempFile="temp/checkTemp.txt"
      clingo checkingDistanceForKDiverse.lp $checkTempFile -c numOfAtoms=$numOfAtoms -c outputNumber=$diverseOutcomeNumber > temp/distance.txt
      obtainedDistance=$(grep "distanceCount" temp/distance.txt | cut -d '(' -f2 |rev|cut -c 2- |rev)
      if [ $obtainedDistance -ge $distance ]
      then
        checkDissimilarityResult=true
        diverseOutcomeNumber=$((diverseOutcomeNumber+1))
      else
        checkDissimilarityResult=false
        break
      fi
    done
  fi
}




##########Start############
#Storing computation start time
MAIN_START=$(gdate +%s.%N)


#globalVariables
optDiffSetOutcome=""
notWorseDiffOutcome=""
checkDissimilarityResult="false"
lengthOfOutcome=3
totalDiverseOutputsFound=0
totalFailedOutcomesFound=0
modifiedDiverseOutcomes="temp/modifiedDiverseOutcomes.txt"
previousOutput="temp/previousOutput.txt"


#Initialize outcomeNumber = i = 1
outcome=1
touch temp/diverseOptimalOutcomes.txt
touch temp/avoidOutcomes_$outcome.txt

#Loop begins
while [ $requiredTotalDiverseOutcomes -gt $totalDiverseOutputsFound ]
do
  outcome=$((totalDiverseOutputsFound+1))
  findOptDiffDissimSet $outcome temp/diverseOptimalOutcomes.txt temp/avoidOutcomes_$outcome.txt

  totalDiverseOutputsFound=$(cat temp/diverseOptimalOutcomes.txt | sed '/^\s*$/d' | wc -l| xargs) #xargs trims white spaces
  cat temp/avoidOutcomes_$outcome.txt > temp/avoidOutcomes_$((outcome+1)).txt

  #Maximum outcomes failed dissimilarity check
  if [ "$totalFailedOutcomesFound" -ge 500 ]
  then
    echo "500OutcomesExceeded" > temp/diverseOptimalOutcomes.txt
    echo "500OutcomesExceeded" > temp/solution.txt
    MAIN_END=$(gdate +%s.%N) #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc) #Finding actual computation time
    echo "timeTaken= "$timeTaken
    break
  fi

  #required cases
  if [ $requiredTotalDiverseOutcomes == $totalDiverseOutputsFound ] #Set of diverse Optimal Solutions Found
  then
    MAIN_END=$(gdate +%s.%N)
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc)
    cat temp/diverseOptimalOutcomes.txt|tr ',' ' '|tr '.' ' ' >temp/solution.txt
    echo "timeTaken= "$timeTaken
    break
  elif [ $totalDiverseOutputsFound -lt 1 -a  $lengthOfOutcome == 3 ] #No diverse set of Optimal Outcomes
  then
    MAIN_END=$(gdate +%s.%N)
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc)
    echo "No diverse set of Optimal Outcomes" > temp/diverseOptimalOutcomes.txt
    echo "NoDiverseSetOfOptimalOutcomes" > temp/solution.txt
    echo "timeTaken= "$timeTaken
    break
  #If just 1 totalDiverseOutputsFound, Remove last outcome from diverseOptimalOutcomes file
  elif [ $totalDiverseOutputsFound -ge 1 -a  $lengthOfOutcome == 3 ]
  then
    #remove last outcome from diverse outcomes
    if [ $totalDiverseOutputsFound -eq 1 ]
    then
      echo "" > temp/diverseOptimalOutcomes.txt
      sed '/^\s*$/d' temp/diverseOptimalOutcomes.txt > temp/temp.txt
      cat temp/temp.txt > temp/diverseOptimalOutcomes.txt
    else
      head -$((totalDiverseOutputsFound-1)) temp/diverseOptimalOutcomes.txt > temp/temp1.txt
      cat temp/temp1.txt > temp/diverseOptimalOutcomes.txt
    fi
  fi
done
