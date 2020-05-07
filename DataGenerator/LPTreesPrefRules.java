//This program is used to generate Two LP Trees Preference Rules
//Input: numOfAtoms InstanceNumber
//Creates files in TwoLPTrees folder

//To generate rules with 60 atoms, instanceNumber=1
//First compile : javac LPTreesPrefRules.java
//To Execute    : java LPTreesPrefRules 60 1


import java.util.List;
import java.util.ArrayList;
import java.util.Random;
import java.util.Collections;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Iterator;


public class LPTreesPrefRules
{
  public static int ruleNo=0;
  public static List<String> finalList = new ArrayList<String>();
  public static void main(String[] args)
  {
    int numOfAtoms=Integer.parseInt(args[0]);
    int instanceNo=Integer.parseInt(args[1]);
    createLPtree(numOfAtoms,instanceNo);
  }
  public static void createLPtree(int numOfAtoms,int instanceNo)
  {
    Random rand = new Random();
    List<Integer> list=new ArrayList<Integer>();
    int node;
    int splitIndex;
    List<Integer> splitList=new ArrayList<Integer>();
    List<Integer> shuffledList=new ArrayList<Integer>();
    boolean preferenceSelection;
    boolean ancestorSelection;
    int ancestorIndex;
    boolean ancestorPosOrNeg;
    int rank=0;
    int randomTemp;
    int sizeCheck;
    boolean splitPreferenceSelection;
    boolean splitAncestorSelection;
    boolean shufflePreferenceSelection;
    boolean shuffleAncestorSelection;
    List<String> linearList = new ArrayList<String>();
    List<String> splitTreeList = new ArrayList<String>();
    //create a list of atoms in linear order which occurs if split is not present in LP tree
    while(list.size()<numOfAtoms)
    {
      node=rand.nextInt(numOfAtoms)+1;
      if(!list.contains(node))
        list.add(node);
    }

    //converting List to array
    Integer[] arr = list.toArray(new Integer[0]);
    //If split exists in LP tree or not
    //boolean split=rand.nextBoolean();
    String splitOrLinear="split";
    //If split exists in LP tree, find the atom at which split occurs
    if(splitOrLinear.equals("split"))
    {
      splitIndex=rand.nextInt(numOfAtoms-2); //split index can be any except last atom

      //add elements after splitIndex to list
      for(int i=splitIndex+1; i<arr.length; i++)
      {
        splitList.add(arr[i]);
      }

      while(shuffledList.size()<splitList.size())
      {
        if(shuffledList.size()==0)
        {
          randomTemp=rand.nextInt(splitList.size());
          while(randomTemp==0)
            randomTemp=rand.nextInt(splitList.size());
        }
        else
          randomTemp=rand.nextInt(splitList.size());
        if(!shuffledList.contains(splitList.get(randomTemp)))
          shuffledList.add(splitList.get(randomTemp));
      }

      Integer[] splitArr = splitList.toArray(new Integer[0]);
      Integer[] shuffledArr = shuffledList.toArray(new Integer[0]);

      if(shuffledList.equals(splitList))
        sizeCheck=arr.length-1;
      else
        sizeCheck=splitIndex;

      //elements before= to splitIndex
      for(int i=0;i<=sizeCheck;i++)
      {
        ruleNo++;
        rank++;
        preferenceSelection=rand.nextBoolean();
        ancestorSelection=rand.nextBoolean();

        if(!ancestorSelection || i==0)
        {
          finalList.add("rank("+ruleNo+","+rank+").");
          finalList.add("body("+ruleNo+").");
          if(preferenceSelection)
          {
            finalList.add("option("+ruleNo+",1):-answer("+arr[i]+").");
            finalList.add("option("+ruleNo+",2):-negAnswer("+arr[i]+").");
          }
          else
          {
            finalList.add("option("+ruleNo+",1):-negAnswer("+arr[i]+").");
            finalList.add("option("+ruleNo+",2):-answer("+arr[i]+").");
          }
        }
        if(ancestorSelection && i>0)
        {
          finalList.add("rank("+ruleNo+","+rank+").");
          ancestorIndex=rand.nextInt(i);
          ancestorPosOrNeg=rand.nextBoolean();
          notSplitAncestorSelection(arr,i,ruleNo,ancestorIndex,ancestorPosOrNeg,preferenceSelection,instanceNo);
          ruleNo++;
          finalList.add("rank("+ruleNo+","+rank+").");
          notSplitAncestorSelection(arr,i,ruleNo,ancestorIndex,!ancestorPosOrNeg,!preferenceSelection,instanceNo);
        }
      }//end of for()

      //elements after splitIndex
      if(sizeCheck!=arr.length-1)
      {
        finalList.add("%Tree splits from here.");
        for(int i=0;i<splitList.size();i++)
        {
          //finalList.add("i="+i);
          ruleNo++;
          rank++;
          splitPreferenceSelection=rand.nextBoolean();
          splitAncestorSelection=rand.nextBoolean();
          shufflePreferenceSelection=rand.nextBoolean();
          shuffleAncestorSelection=rand.nextBoolean();
          if((!splitAncestorSelection && !shuffleAncestorSelection) || i==0)
          {
            finalList.add("rank("+ruleNo+","+rank+").");
            finalList.add("body("+ruleNo+"):-answer("+arr[splitIndex]+").");
            if(splitPreferenceSelection)
            {
              finalList.add("option("+ruleNo+",1):-answer("+splitList.get(i)+").");
              finalList.add("option("+ruleNo+",2):-negAnswer("+splitList.get(i)+").");
            }
            else
            {
              finalList.add("option("+ruleNo+",1):-negAnswer("+splitList.get(i)+").");
              finalList.add("option("+ruleNo+",2):-answer("+splitList.get(i)+").");
            }
            ruleNo++;
            finalList.add("rank("+ruleNo+","+rank+").");
            finalList.add("body("+ruleNo+"):-negAnswer("+arr[splitIndex]+").");
            if(shufflePreferenceSelection)
            {
              finalList.add("option("+ruleNo+",1):-answer("+shuffledList.get(i)+").");
              finalList.add("option("+ruleNo+",2):-negAnswer("+shuffledList.get(i)+").");
            }
            else
            {
              finalList.add("option("+ruleNo+",1):-negAnswer("+shuffledList.get(i)+").");
              finalList.add("option("+ruleNo+",2):-answer("+shuffledList.get(i)+").");
            }
          }//end of if(!splitAncestorSelection)

          if(splitAncestorSelection && shuffleAncestorSelection && i>0)
          {
            finalList.add("rank("+ruleNo+","+rank+").");
            ancestorIndex=rand.nextInt(i);
            ancestorPosOrNeg=rand.nextBoolean();
            splitAncestorSelectionMethod(splitArr,i,ruleNo,ancestorIndex,ancestorPosOrNeg,splitPreferenceSelection,arr[splitIndex],"split",instanceNo);
            ruleNo++;
            finalList.add("rank("+ruleNo+","+rank+").");
            splitAncestorSelectionMethod(splitArr,i,ruleNo,ancestorIndex,!ancestorPosOrNeg,!splitPreferenceSelection,arr[splitIndex],"split",instanceNo);
            ruleNo++;
            finalList.add("rank("+ruleNo+","+rank+").");
            splitAncestorSelectionMethod(shuffledArr,i,ruleNo,ancestorIndex,ancestorPosOrNeg,shufflePreferenceSelection,arr[splitIndex],"shuffle",instanceNo);
            ruleNo++;
            finalList.add("rank("+ruleNo+","+rank+").");
            splitAncestorSelectionMethod(shuffledArr,i,ruleNo,ancestorIndex,!ancestorPosOrNeg,!shufflePreferenceSelection,arr[splitIndex],"shuffle",instanceNo);
          }//endof if(splitAncestorSelection && i>0)

          if(splitAncestorSelection && !shuffleAncestorSelection && i>0)
          {
            finalList.add("rank("+ruleNo+","+rank+").");
            ancestorIndex=rand.nextInt(i);
            ancestorPosOrNeg=rand.nextBoolean();
            splitAncestorSelectionMethod(splitArr,i,ruleNo,ancestorIndex,ancestorPosOrNeg,splitPreferenceSelection,arr[splitIndex],"split",instanceNo);
            ruleNo++;
            finalList.add("rank("+ruleNo+","+rank+").");
            splitAncestorSelectionMethod(splitArr,i,ruleNo,ancestorIndex,!ancestorPosOrNeg,!splitPreferenceSelection,arr[splitIndex],"split",instanceNo);
            ruleNo++;
            finalList.add("rank("+ruleNo+","+rank+").");
            finalList.add("body("+ruleNo+"):-negAnswer("+arr[splitIndex]+").");
            if(shufflePreferenceSelection)
            {
              finalList.add("option("+ruleNo+",1):-answer("+shuffledList.get(i)+").");
              finalList.add("option("+ruleNo+",2):-negAnswer("+shuffledList.get(i)+").");
            }
            else
            {
              finalList.add("option("+ruleNo+",1):-negAnswer("+shuffledList.get(i)+").");
              finalList.add("option("+ruleNo+",2):-answer("+shuffledList.get(i)+").");
            }
          }//endof if(splitAncestorSelection && !shuffle i>0)

          if(!splitAncestorSelection && shuffleAncestorSelection && i>0)
          {
            ancestorIndex=rand.nextInt(i);
            ancestorPosOrNeg=rand.nextBoolean();
            finalList.add("rank("+ruleNo+","+rank+").");
            finalList.add("body("+ruleNo+"):-answer("+arr[splitIndex]+").");
            if(splitPreferenceSelection)
            {
              finalList.add("option("+ruleNo+",1):-answer("+splitList.get(i)+").");
              finalList.add("option("+ruleNo+",2):-negAnswer("+splitList.get(i)+").");
            }
            else
            {
              finalList.add("option("+ruleNo+",1):-negAnswer("+splitList.get(i)+").");
              finalList.add("option("+ruleNo+",2):-answer("+splitList.get(i)+").");
            }
            ruleNo++;
            finalList.add("rank("+ruleNo+","+rank+").");
            splitAncestorSelectionMethod(shuffledArr,i,ruleNo,ancestorIndex,ancestorPosOrNeg,shufflePreferenceSelection,arr[splitIndex],"shuffle",instanceNo);
            ruleNo++;
            finalList.add("rank("+ruleNo+","+rank+").");
            splitAncestorSelectionMethod(shuffledArr,i,ruleNo,ancestorIndex,!ancestorPosOrNeg,!shufflePreferenceSelection,arr[splitIndex],"shuffle",instanceNo);
          }//endof if(splitAncestorSelection && i>0)


        }//end of for
      }//endof if(sizecheck)
    }//end of if(split)

    splitOrLinear="linear";
    finalList.add("%secondTree.");
    if(splitOrLinear.equals("linear"))
    {
      //ruleNo=0;
      rank=0;
      for(int i=0;i<arr.length;i++)
      {
        ruleNo++;
        rank++;
        preferenceSelection=rand.nextBoolean();
        ancestorSelection=rand.nextBoolean();

        if(!ancestorSelection || i==0)
        {
          finalList.add("rank("+ruleNo+","+rank+").");
          finalList.add("body("+ruleNo+").");
          if(preferenceSelection)
          {
            finalList.add("option("+ruleNo+",1):-answer("+arr[i]+").");
            finalList.add("option("+ruleNo+",2):-negAnswer("+arr[i]+").");
          }
          else
          {
            finalList.add("option("+ruleNo+",1):-negAnswer("+arr[i]+").");
            finalList.add("option("+ruleNo+",2):-answer("+arr[i]+").");
          }
        }
        if(ancestorSelection && i>0)
        {
          finalList.add("rank("+ruleNo+","+rank+").");
          ancestorIndex=rand.nextInt(i);
          ancestorPosOrNeg=rand.nextBoolean();
          notSplitAncestorSelection(arr,i,ruleNo,ancestorIndex,ancestorPosOrNeg,preferenceSelection,(instanceNo+100));
          ruleNo++;
          finalList.add("rank("+ruleNo+","+rank+").");
          notSplitAncestorSelection(arr,i,ruleNo,ancestorIndex,!ancestorPosOrNeg,!preferenceSelection,(instanceNo+100));
        }
      }//end of for
    } //end of if(!split)

    try{
        File file = new File("TwoLPTrees/pref"+numOfAtoms+"_2_"+instanceNo+".txt");
        if (!file.exists()) {
            file.createNewFile();
        }

        FileWriter fw = new FileWriter(file.getAbsoluteFile());
        BufferedWriter out = new BufferedWriter(fw);
        out.write("#const maxNumOfOpts = 2.\n");
        out.write("degrees(0..maxNumOfOpts).\n\n");
        for(String str:finalList)
        {
          out.write(str+"\n");
        }

       out.close();
    }
    catch(IOException e){
      e.printStackTrace();
    }
  } //endof createLPtree

  public static void notSplitAncestorSelection(Integer[] arr,int i,int ruleNo,int ancestorIndex,boolean ancestorPosOrNeg,boolean preferenceSelection,int instanceNo)
  {
    if(ancestorPosOrNeg)
    {
      finalList.add("body("+ruleNo+"):-answer("+arr[ancestorIndex]+").");
    }
    else
    {
      finalList.add("body("+ruleNo+"):-negAnswer("+arr[ancestorIndex]+").");
    }
    if(preferenceSelection)
    {
      finalList.add("option("+ruleNo+",1):-answer("+arr[i]+").");
      finalList.add("option("+ruleNo+",2):-negAnswer("+arr[i]+").");
    }
    else
    {
      finalList.add("option("+ruleNo+",1):-negAnswer("+arr[i]+").");
      finalList.add("option("+ruleNo+",2):-answer("+arr[i]+").");
    }
  } //end of norSplit


  public static void splitAncestorSelectionMethod(Integer[] arr,int i,int ruleNo,int ancestorIndex,boolean ancestorPosOrNeg,boolean preferenceSelection,int splitElement,String shuffleOrsplit,int instanceNo)
  {
    if(ancestorPosOrNeg && shuffleOrsplit.equals("split"))
    {
      finalList.add("body("+ruleNo+"):-answer("+splitElement+"),answer("+arr[ancestorIndex]+").");
    }
    else if(!ancestorPosOrNeg && shuffleOrsplit.equals("split"))
    {
      finalList.add("body("+ruleNo+"):-answer("+splitElement+"),negAnswer("+arr[ancestorIndex]+").");
    }
    else if(ancestorPosOrNeg && shuffleOrsplit.equals("shuffle"))
    {
      finalList.add("body("+ruleNo+"):-negAnswer("+splitElement+"),answer("+arr[ancestorIndex]+").");
    }
    else
    {
      finalList.add("body("+ruleNo+"):-negAnswer("+splitElement+"),negAnswer("+arr[ancestorIndex]+").");
    }

    if(preferenceSelection)
    {
      finalList.add("option("+ruleNo+",1):-answer("+arr[i]+").");
      finalList.add("option("+ruleNo+",2):-negAnswer("+arr[i]+").");
    }
    else
    {
      finalList.add("option("+ruleNo+",1):-negAnswer("+arr[i]+").");
      finalList.add("option("+ruleNo+",2):-answer("+arr[i]+").");
    }
  } //end of splitAncestor
}//end of class
