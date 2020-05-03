#!/bin/sh
#This program takes user input and executes the function (shell script) based
# on user user input.


#Verify whether user has entered correct number of input arguments.
#Arguments should be 4

#constants
TOTAL_INSTANCES=40 #Total instances to solve
TIME_OUT=500 #Timeout for each problem in seconds


printMenu(){
  echo "Info about arguments"
  echo "First Argument                 : Number Of Atoms (Atoms shoud be >=3)."
  echo "Second Argument                : Multiplier for generator Clauses."
  echo "Third Argument                 : Multiplier for preference Clauses (Enter 0 for LP trees)."
  echo "Fourth Argument - Problem      : 1 (optimal); 2 (diff-Optimal); 3 (sim/dissim); 4 (KDiverse) "
  echo "Fifth Argument - PreferenceSet : 1 (unranked) or 2 (ranked) or 3 (TwoLPTrees) 4(FourLPTrees)"
  echo "Sixth Argument - Type of LP Trees:
                  if DataSet == 4: 0 (no split) or 1 (Split at root)
                  if DataSet != 4: -1 "
  echo "Seventh Argument - method (if Problem == 3 or 4):
                    if problem == 3 (sim/dissim): 1(StraightForward - SF)
                                                  2 (Alternative - Alt)
                                                  3(VariantAlternative - Alt_V) \n
                    if problem == 4 (KDiverse)  : 1(StraightForward_SF)
                                                  2 (StraightForward_Alt)
                                                  3(StraightForward_VAlt)
                                                  4(Alternative)
                                                  5(VariantAlternative) "
  echo "Eighth Argument - distance (if Problem == 3 or 4)     : 0 to 1 "
  echo "Ninth Argument - Similar/dissimialar (if Problem == 3): 1(similar) or 2 (dissimilar)\n"
  echo "eg: For optimal unranked: sh main.sh 60 4 3 1 1"
  echo "eg: For sim,ranked,SF,Distance = 0.2: sh main.sh 60 4 3 3 2 -1 1 0.2 1 \n"
  exit
}


if [ $# -le 4 ]
then
  echo "Invalid number of arguments \n"
  printMenu
elif [ $# -eq 5 ] #If four arguments, problem should be optimal or diff-Optimal
then
  if [ $4 -eq 3 -o $4 -eq 4 ] #If problem is sim/Dissim or Kdiverse, 8 or 9 arguments are required
  then
    echo "Eight, Nine arguments are required for sim/dissim, Kdiverse problems respectively \n"
    printMenu
  elif [ $5 -eq 4 ]
  then
    echo "If datatype is FourLPTrees, Type of LPTrees: 0(no split) or 1(Split at root) should be entered\n"
    printMenu
  else
    numOfAtoms=$1
    genMultiplier=$2
    prefMultiplier=$3
    problem=$4
    preferenceSet=$5
    givenDistance=0
    typeOfLPtrees=-1
  fi
elif [ $# -eq 6 -o $# -eq 7 ]
then
  if [ $4 -eq 3 -o $4 -eq 4 ] #If problem is sim/Dissim or Kdiverse, 8 or 9 arguments are required
  then
    echo "Eight, Nine arguments are required for sim/dissim, Kdiverse problems respectively \n"
    printMenu
  else
    numOfAtoms=$1
    genMultiplier=$2
    prefMultiplier=$3
    problem=$4
    preferenceSet=$5
    typeOfLPtrees=$6
    givenDistance=0
  fi
elif [ $# -eq 8 ]
then
  if [ $4 -eq 3 ] #If problem is sim/Dissim, 9 arguments are required
  then
    echo "Nine arguments are required for sim/dissim problem \n"
    printMenu
  else
    if [ $5 -eq 4 -a $4 -eq 4 ] #If problem is sim/Dissim, 9 arguments are required
    then
      echo "K-Diverse problem is not implemented for FourLPTrees\n"
      printMenu
    fi
    numOfAtoms=$1
    genMultiplier=$2
    prefMultiplier=$3
    problem=$4
    preferenceSet=$5
    typeOfLPtrees=$6
    method=$7
    givenDistance=$8
  fi
else
  if [ $5 -eq 4 -a $4 -eq 4 ] #If problem is sim/Dissim, 9 arguments are required
  then
    echo "K-Diverse problem is not implemented for FourLPTrees\n"
    printMenu
  elif [ $5 -eq 4 -a $4 -eq 3 ]
  then
    echo "sim/dissim problem is not implemented for FourLPTrees\n"
    printMenu
  fi
  numOfAtoms=$1
  genMultiplier=$2
  prefMultiplier=$3
  problem=$4
  preferenceSet=$5
  typeOfLPtrees=$6
  method=$7
  givenDistance=$8
  simOrDissim=$9
fi

#calculating clauses and distance
numOfGenClauses=$(echo "scale=2;$genMultiplier*$numOfAtoms" |bc| cut -f1 -d".")
numOfPrefClauses=$( expr "$prefMultiplier" '*' "$numOfAtoms" )
distance=$(echo "scale=2;$givenDistance*$numOfAtoms" |bc| cut -f1 -d".")

if [ $preferenceSet == "3" -o $preferenceSet == "4" ]
then
  numOfPrefClauses=2 #The preference file name for LPTrees contains "2"
fi


instanceNum=1
while [ $instanceNum -le $TOTAL_INSTANCES ]
#while [ $instanceNum -le 1 ]
do
  minTime=$TIMEOUT  #initialization
  echo $instanceNum
  #Solves the problem three times and prints the minimum time
  for j in 1 2 3
  do
    rm temp/* 2> temp/error.txt #Removing temporary files if any exists.
    #If problem is opt_outcome
    if [ "$problem" == "1" ]
    then
      timeout $TIME_OUT sh optimal.sh $numOfAtoms $numOfGenClauses $numOfPrefClauses $preferenceSet $instanceNum $typeOfLPtrees &>temp/time.txt

    #If problem is diff_opt_outcome
    #Find optimal outcome to ASO program and store it "givenOutput.txt" file and then solve diff_opt_outcome by passing "givenOutput.txt" as input
    elif [ "$problem" == "2" ]
    then
        timeout $TIME_OUT sh optimal.sh $numOfAtoms $numOfGenClauses $numOfPrefClauses $preferenceSet $instanceNum $typeOfLPtrees &>temp/time.txt
        /usr/bin/java GivenOutput temp/solution.txt &>temp/givenOutput.txt
        /usr/bin/java OrderedOutput temp/solution.txt
        rm temp/solution.txt 2>temp/error.txt
        timeout $TIME_OUT sh optimal_diff.sh temp/givenOutput.txt $numOfAtoms $numOfGenClauses $numOfPrefClauses $preferenceSet $instanceNum $typeOfLPtrees &>temp/time.txt

    #If problem is sim_opt_outcome/dissim_opt_outcome
    #Find optimal outcome to ASO program and store it "givenOutput.txt" file and then solve sim_opt_outcome by passing "givenOutput.txt" as input
    elif [ "$problem" == "3" ]
    then
        timeout $TIME_OUT sh optimal.sh $numOfAtoms $numOfGenClauses $numOfPrefClauses $preferenceSet $instanceNum $typeOfLPtrees &>temp/time.txt
        if [ "$method" == "1" ] #method is "StraightForward"
        then
            /usr/bin/java GivenOutput temp/solution.txt  &>temp/givenOutput.txt
            /usr/bin/java OrderedOutput temp/solution.txt
            rm temp/solution.txt 2>temp/error.txt
            if [ "$simOrDissim" == "1" ] #similar
            then
                timeout $TIME_OUT sh optimalSimilar.sh temp/givenOutput.txt $distance $numOfAtoms $numOfGenClauses $numOfPrefClauses $instanceNum $preferenceSet $simOrDissim &>temp/time.txt
            elif [ "$simOrDissim" == "2" ] #dissimilar
            then
                timeout $TIME_OUT sh optimalDissimilar.sh temp/givenOutput.txt $distance $numOfAtoms $numOfGenClauses $numOfPrefClauses $instanceNum $preferenceSet $simOrDissim &>temp/time.txt
            fi
        else
            /usr/bin/java GivenOutputForAlternate temp/solution.txt  &>temp/givenOutput.txt
            /usr/bin/java OrderedOutput temp/solution.txt
            rm temp/solution.txt 2>temp/error.txt
            if [ "$method" == "2" ] #method is "Alternative. Works for both similar and dissimilar"
            then
                timeout $TIME_OUT sh optimalSimilarAlternate.sh temp/givenOutput.txt $distance $numOfAtoms $numOfGenClauses $numOfPrefClauses $instanceNum $preferenceSet $simOrDissim &>temp/time.txt
            elif [ "$method" == "3" ] #method is "VariantAlternative. Works for both similar and dissimilar"
            then
                timeout $TIME_OUT sh optimalSimilarVariantAlternate.sh temp/givenOutput.txt $distance $numOfAtoms $numOfGenClauses $numOfPrefClauses $instanceNum $preferenceSet $simOrDissim &>temp/time.txt
            fi
        fi

    #If problem is KDiverse
    #Find optimal outcome to ASO program and store it "givenOutput.txt" file and then solve sim_opt_outcome by passing "givenOutput.txt" as input
    elif [ "$problem" == "4" ]
    then
      if [ "$method" == "1" ] #method is "StraightForward_SF"
      then
        timeout $TIME_OUT sh kDiverseOptOutcomes.sh $numOfAtoms $numOfGenClauses $numOfPrefClauses $distance $instanceNum $preferenceSet &>temp/time.txt
      elif [ "$method" == "2" ] #method is "StraightForward_Alt"
      then
        timeout $TIME_OUT sh kDiverseOptOutcomes_St_Alt.sh $numOfAtoms $numOfGenClauses $numOfPrefClauses $distance $instanceNum $preferenceSet &>temp/time.txt
      elif [ "$method" == "3" ] #method is "StraightForward_VAlt"
      then
        timeout $TIME_OUT sh kDiverseOptOutcomes_St_Variant_Alt.sh $numOfAtoms $numOfGenClauses $numOfPrefClauses $distance $instanceNum $preferenceSet &>temp/time.txt
      elif [ "$method" == "4" ] #method is "Alternative"
      then
        timeout $TIME_OUT sh kDiverseOptOutcomes_Alternative.sh $numOfAtoms $numOfGenClauses $numOfPrefClauses $distance $instanceNum $preferenceSet &>temp/time.txt
      elif [ "$method" == "5" ] #method is "VariantAlternative"
      then
        timeout $TIME_OUT sh kDiverseOptOutcomes_Variant_Alternative.sh $numOfAtoms $numOfGenClauses $numOfPrefClauses $distance $instanceNum $preferenceSet &>temp/time.txt
      fi
    fi



    #variable "time" stores the timeTaken for computation
    time=$(grep 'timeTaken' temp/time.txt|cut -d' ' -f2)
    #echo "time: "$time

    #Checks whether computation timeout or not
    #If timedOut, prints "Timed out". Otherwise, prints the solution
    if [ $time == $TIME_OUT ]
    then
      echo "Timed out \n"
    else
      /usr/bin/java OrderedOutput temp/solution.txt
    fi

    #Finds the minTime taken for computation (We solve problem three times)
    if (( $(echo "$minTime $time" | awk '{print ($1 > $2)}') ));
    then
       minTime=$time
    fi
  done

  #Incrementing instance number
  instanceNum=$((instanceNum+1))
  echo "minTime:" $minTime
  done
