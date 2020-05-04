#!/bin/sh
#This script is used to find K-diverse outcomes using StraightForward_Alt method

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
#1. Find an outcome S that is different from differentOutcomes and dissimilar to diverseOptimalOutcomes
#2. Check if it is optimal outcome or not using findBetter.lp
#3. If not optimal solution, add it to differentOutcomes and repeat
#4. If optimal, return it as solution.


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
findOptDiffDissimSet()
{
  diverseOptimalOutcomes=$2  #$2 is "diverseOptimalOutcomes.txt"
  differentOutcomes=$3    #$3 is "avoidOutcomes_$outcome.txt"
  cat $differentOutcomes > temp/differentOutcomes.txt
  differentOutcomes="temp/differentOutcomes.txt"
  while :
  do
    findDifferentDissimilarOutcome $diverseOptimalOutcomes $differentOutcomes
    lengthOfOutcome=$(echo -n $diffDissimilarOutcome | wc -c)
    #If no outcome for findDifferentDissimilarOutcome, break
    if [ $lengthOfOutcome -eq 3 ]  #no outcome
    then
      break
    fi
    checkOptimality
    if [ $checkOptimalityResult == true ] #optimality check passed
    then
      /usr/bin/java PrintAnswerRemoveSdegree "2" $numOfAtoms $(echo $diffDissimilarOutcome | awk '{for(i=1;i<=NF;i++) {print ""$i""}}') >> $diverseOptimalOutcomes
      newOutputObtained=$(echo $diffDissimilarOutcome | awk '{for(i=1;i<=NF;i++) {print "\""$i".\""}}')
      /usr/bin/java ModifyOptimalOutput $numOfAtoms $outcome $newOutputObtained >> temp/avoidOutcomes_$outcome.txt
      break
    else #failed optimality check
      totalFailedOutcomesFound=$((totalFailedOutcomesFound+1))
      #If result=false, add dissimilarOutcome to differentOutcomes and repeat loop
      newOutputObtained=$(echo $diffDissimilarOutcome | awk '{for(i=1;i<=NF;i++) {print "\""$i".\""}}')
      /usr/bin/java ModifyOptimalOutput $numOfAtoms $totalFailedOutcomesFound $newOutputObtained >> temp/differentOutcomes.txt
      differentOutcomes="temp/differentOutcomes.txt"
      maxOutcomes=500
      if [ "$totalFailedOutcomesFound" -ge "$maxOutcomes" ]
      then
        break
      fi
    fi
  done

}


findDifferentDissimilarOutcome()
{
  diverseOptimalOutcomes=$1
  differentOutcomes=$2
  totalDiverseOutcomesFound=$(cat $diverseOptimalOutcomes | sed '/^\s*$/d' | wc -l| xargs)
  diverseOutcomeNumber=1

  echo '\n' > temp/modifiedDiverseOutcomes.txt
  while [ $diverseOutcomeNumber -le $totalDiverseOutcomesFound ]
  do
    echo '\n' >> temp/modifiedDiverseOutcomes.txt
    head -$diverseOutcomeNumber temp/diverseOptimalOutcomes.txt| tail -1 |tr ',' '.' > temp/temp1.txt
    tempFile="temp/temp1.txt"
    clingo convertingOutputForDissimCheck.lp $tempFile -c outcome=$diverseOutcomeNumber > temp/temp.txt
    grep "nswer(" temp/temp.txt | tr ' ' '.' | tr '\n' '.'>> temp/modifiedDiverseOutcomes.txt
    diverseOutcomeNumber=$((diverseOutcomeNumber+1))
  done


  if [[ -z $(grep '[^[:space:]]' temp/modifiedDiverseOutcomes.txt) ]] #Zero diverse outcomes found till now
  then
    clingo $generatorInput generatorProgram.lp $differentOutcomes $preferenceInput calculateSatDegree.lp >temp/temp.txt
  else #diverse outcomes file is not empty
    #find outcome not worse and different from differentOutcomes
    clingo $generatorInput generatorProgram.lp $differentOutcomes $modifiedDiverseOutcomes findDissimilarToSetOutcomes.lp $preferenceInput calculateSatDegree.lp -c distance=$distance -c totalOutcomes=$totalDiverseOutcomesFound >temp/temp.txt
  fi
  diffDissimilarOutcome=$(grep "nswer(" temp/temp.txt ) #Dissimilar and Different Outcome


  #modify outome and store it in previous outcome
  panswer=$(grep "nswer(" temp/temp.txt |grep -o 'sdegree([^ ]*' |sed 's/sdegree/psdegree/g'|awk '{for(i=1;i<=NF;i++) {print ""$i"."}}')
  echo $panswer >temp/previousOutput.txt
  unsatisfy=$(grep "UNSATISFIABLE" temp/temp.txt)
}



checkOptimality(){
  clingo $generatorInput generatorProgram.lp $preferenceInput calculateSatDegree.lp $previousOutput $findBetter > temp/temp.txt
  unsatisfy=$(grep "UNSATISFIABLE" temp/temp.txt)
  if [ "$unsatisfy" == "UNSATISFIABLE" ] #Obtained dissimilar outcome is Optimal outcome
  then
      checkOptimalityResult="true"
  else #Obtained dissimilar outcome is not Optimal outcome
      checkOptimalityResult="false"
  fi
}






##########Start############
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


#globalVariables
diffDissimilarOutcome=""
checkOptimalityResult="false"
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
  if [ $requiredTotalDiverseOutcomes == $totalDiverseOutputsFound ] #Set of diverse Optimal Outcomes found
  then
    MAIN_END=$(gdate +%s.%N)   #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc)  #Finding actual computation time
    cat temp/diverseOptimalOutcomes.txt|tr ',' ' '|tr '.' ' ' >temp/solution.txt
    echo "timeTaken= "$timeTaken
    break
  elif [ $totalDiverseOutputsFound -lt 1 -a  $lengthOfOutcome == 3 ]  #No diverse set
  then
    MAIN_END=$(gdate +%s.%N)   #Storing computation end time
    timeTaken=$(echo "$MAIN_END - $MAIN_START"|bc)  #Finding actual computation time
    echo "No diverse set of Optimal Outcomes" > temp/diverseOptimalOutcomes.txt
    echo "NoDiverseSetOfOptimalOutcomes" > temp/solution.txt
    echo "timeTaken= "$timeTaken
    break
  #Since just 1 totalDiverseOutputsFound, Remove last outcome from diverseOptimalOutcomes file
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
