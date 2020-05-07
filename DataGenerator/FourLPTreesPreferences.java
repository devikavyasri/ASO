//This program generates preference rules representing four LPTrees of two types
//1. LPTrees with no split
//2. LPTrees with just one split at root

//Input: Takes 4 Arguments 
//First Argument: Number of atoms
//Second Argument: Number of LPTrees 
//Third Argument: 0 or any positive number (0 for NoSplit; 1 for split at root; other +ve numbers for split anywhere)
//Fourth Argument: InstanceNumber (Any number) This is used to name file of preference rules

//Output: Creates files with rules in FourLPTrees folder

//To compile javac FourLPTreesPreferences.java
// Eg1: java FourLPTreesPreferences 10 4 0 1
//10 Atoms, 4 trees, no split, instance is 1. So, creates file as pref_10_4_0_1.txt
// Eg2: java FourLPTreesPreferences 10 4 1 2
//10 Atoms, 4 trees, split at root, instance is 2. So, creates file as pref_10_4_1_2.txt
// Eg3: java FourLPTreesPreferences 10 4 2 4
//10 Atoms, 4 trees, split anywhere, instance is 4. So, creates file as pref_10_4_2_4.txt

//consitions:
//Each LP tree may have at most one node where it splits into two branches, and each
//node’s preferences depend on values in at most one ancestor node.


import java.util.ArrayList;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.List;
import java.util.Random;




public class FourLPTreesPreferences{
  public static List<String> finalList = new ArrayList<String>();
  //public static int ruleNo = 0; //Starting number for rule = 1+ruleNo
  public static Random rand = new Random();

  public static void main(String[] args){
    int numOfAtoms = Integer.parseInt(args[0]);
    int numberOfTrees = Integer.parseInt(args[1]);
    int splitInfo = Integer.parseInt(args[2]);
    Boolean split = true;
    if(splitInfo == 0){
      split = false;
    }
    Boolean splitAtRoot = false;
    if(splitInfo == 1){
      splitAtRoot = true;
    }
    int instanceNo = Integer.parseInt(args[3]);

    
    if(!split){
      for(int treeNum=1; treeNum<=numberOfTrees; treeNum++){
        noSplitTrees(numOfAtoms, treeNum);
      }
    }
    else if(splitAtRoot){
      for(int treeNum=1; treeNum<=numberOfTrees; treeNum++){
        splitAtRootTrees(numOfAtoms, treeNum);
      }
    }
    
    if(!split || splitAtRoot){
      try{
        File file = new File("FourLPTrees/pref"+numOfAtoms+"_"+numberOfTrees+"_"+splitInfo+"_"+instanceNo+".txt");
        if (!file.exists()) {
            file.createNewFile();
        }
        BufferedWriter bw = new BufferedWriter(new FileWriter(file));
        bw.write("%body(treeNumber,ruleNumber).\n");
        bw.write("%rank(treeNumber,ruleNumber, rank).\n");
        bw.write("%option(treeNumber,ruleNumber,preferenceNum). 1 is preferred to 2\n\n");

        bw.write("#const maxNumOfOpts = 2.\n");
        bw.write("degrees(0..maxNumOfOpts).\n\n");
        bw.write("trees(1.."+numberOfTrees+").\n\n");
        for(String str:finalList)
        {
          bw.write(str+"\n");
        }
        bw.close();
      }
      catch(IOException e){
        System.out.println("Unable to write to file");
      }
    }
    
  }//main()


  //No Split Trees
  public static void noSplitTrees(int numOfAtoms, int treeNum){
    int rank=0, ruleNo = 0, nodeNumber, ancestorNode;
    boolean preferenceSelectionPositive;
    boolean ancestorSelection;
    //Store atoms in order used in tree from root to leaf
    List<Integer> listOfAtoms = new ArrayList<Integer>(); //List to store atoms in order used in tree from root
    while(listOfAtoms.size()<numOfAtoms)
    {
          nodeNumber=rand.nextInt(numOfAtoms)+1;
          if(!listOfAtoms.contains(nodeNumber))
          listOfAtoms.add(nodeNumber);
    }

    for(int i=0;i<numOfAtoms;i++)
    {
      nodeNumber = listOfAtoms.get(i);
      ruleNo++;
      rank++;
      preferenceSelectionPositive=rand.nextBoolean(); //To find whether positive atom is preferred or negative atom
      ancestorSelection=rand.nextBoolean(); //To check if particular node(atom) depends on ancestor or not

      finalList.add("rank("+treeNum+","+ruleNo+","+rank+").");
      if(!ancestorSelection || i==0)
      {
        ancestorSelection = false;
        notSplitAncestorSelection(nodeNumber,ruleNo,treeNum,0,false,preferenceSelectionPositive,ancestorSelection);
      }
      
      else if(ancestorSelection && i>0)
      {
        int ancestorIndex=rand.nextInt(i);
        boolean ancestorPosOrNeg=rand.nextBoolean();
        ancestorNode = listOfAtoms.get(ancestorIndex);
        notSplitAncestorSelection(nodeNumber,ruleNo,treeNum,ancestorNode,ancestorPosOrNeg,preferenceSelectionPositive,ancestorSelection);
        ruleNo++;
        finalList.add("rank("+treeNum+","+ruleNo+","+rank+").");
        notSplitAncestorSelection(nodeNumber,ruleNo,treeNum,ancestorNode,!ancestorPosOrNeg,!preferenceSelectionPositive,ancestorSelection);
       }
    }//end of for
    finalList.add("prules("+treeNum+",1.."+ruleNo+").\n");
    finalList.add("\n");
  }//noSplitTrees()


  //notSplitAncestorSelection
  public static void notSplitAncestorSelection(int nodeNumber,int ruleNo, int treeNum,int ancestorNode,boolean ancestorPosOrNeg,boolean preferenceSelectionPositive, boolean ancestorSelection)
  {
    if(!ancestorSelection){
      finalList.add("body("+treeNum+","+ruleNo+").");
    }
    else {
      if(ancestorPosOrNeg)
      {
        finalList.add("body("+treeNum+","+ruleNo+"):-answer("+ancestorNode+").");
      }
      else
      {
        finalList.add("body("+treeNum+","+ruleNo+"):-negAnswer("+ancestorNode+").");
      }
    }
    
    if(preferenceSelectionPositive)
    {
      finalList.add("option("+treeNum+","+ruleNo+",1):-answer("+nodeNumber+").");
      finalList.add("option("+treeNum+","+ruleNo+",2):-negAnswer("+nodeNumber+").");
    }
    else
    {
      finalList.add("option("+treeNum+","+ruleNo+",1):-negAnswer("+nodeNumber+").");
      finalList.add("option("+treeNum+","+ruleNo+",2):-answer("+nodeNumber+").");
    }
  } //notSplitAncestorSelection()



  //Split at root Tree generation
  public static void splitAtRootTrees(int numOfAtoms, int treeNum){
    int rank=1, ruleNo = 1, leftNodeNumber, rightNodeNumber, rootNode;
    boolean preferenceSelectionPos;
    boolean leftAncestorSelection, rightAncestorSelection;
    int ancestorIndex, leftAncestorNode, rightAncestorNode;
    boolean ancestorPosOrNeg;
    
    //Store atoms in order used in tree from root to leaf
    List<Integer> leftTreeNodes = new ArrayList<Integer>(); //List to store atoms in order used in left subTree from root
    List<Integer> rightTreeNodes = new ArrayList<Integer>(); //List to store atoms in order used in right subTree from root
    //root is same in both left and right subTree
    rootNode = rand.nextInt(numOfAtoms)+1;
    leftTreeNodes.add(rootNode);
    rightTreeNodes.add(rootNode); 

    //left child and right child of tree should be different
    leftNodeNumber = rand.nextInt(numOfAtoms)+1;
    while(leftNodeNumber == rootNode){
      leftNodeNumber = rand.nextInt(numOfAtoms)+1;
    }
    leftTreeNodes.add(leftNodeNumber);
    
    rightNodeNumber = rand.nextInt(numOfAtoms)+1;
    while(rightNodeNumber == rootNode || rightNodeNumber == leftNodeNumber){
      rightNodeNumber = rand.nextInt(numOfAtoms)+1;
    }
    rightTreeNodes.add(rightNodeNumber);


    //Filling leftTreeNodes list with remaining nodes 
    while(leftTreeNodes.size()<numOfAtoms)
    {
      leftNodeNumber=rand.nextInt(numOfAtoms)+1;
      if(!leftTreeNodes.contains(leftNodeNumber))
        leftTreeNodes.add(leftNodeNumber);
    }
    //Filling rightTreeNodes list with remaining nodes 
    while(rightTreeNodes.size()<numOfAtoms)
    {
      rightNodeNumber=rand.nextInt(numOfAtoms)+1;
      if(!rightTreeNodes.contains(rightNodeNumber))
        rightTreeNodes.add(rightNodeNumber);
    }

    //root
    preferenceSelectionPos = rand.nextBoolean();
    finalList.add("rank("+treeNum+","+ruleNo+","+rank+").");
    notSplitAncestorSelection(rootNode,ruleNo,treeNum,0,false,preferenceSelectionPos,false);  

    //elements other than root
    for(int i=1;i<numOfAtoms;i++)
    {
      rightNodeNumber = rightTreeNodes.get(i);
      leftNodeNumber = leftTreeNodes.get(i);
      ruleNo++;
      rank++;

      if(i==1){
        leftAncestorSelection = false;
        rightAncestorSelection = false;
      }
      else{
        leftAncestorSelection = rand.nextBoolean();
        rightAncestorSelection = rand.nextBoolean();
      }


      //elements after splitIndex
      if(leftAncestorSelection){
        ancestorIndex = rand.nextInt(i-1)+1;
        leftAncestorNode = leftTreeNodes.get(ancestorIndex);
        ancestorPosOrNeg = rand.nextBoolean();
        preferenceSelectionPos = rand.nextBoolean();
        finalList.add("rank("+treeNum+","+ruleNo+","+rank+").");
        splitAncestorSelectionMethod(leftNodeNumber,ruleNo,treeNum,leftAncestorNode,rootNode,"left",ancestorPosOrNeg,preferenceSelectionPos);
        ruleNo++;
        finalList.add("rank("+treeNum+","+ruleNo+","+rank+").");
        splitAncestorSelectionMethod(leftNodeNumber,ruleNo,treeNum,leftAncestorNode,rootNode,"left",!ancestorPosOrNeg,!preferenceSelectionPos);
      }
      else{
        preferenceSelectionPos = rand.nextBoolean();
        finalList.add("rank("+treeNum+","+ruleNo+","+rank+").");
        splitAncestorSelectionMethod(leftNodeNumber,ruleNo,treeNum,0,rootNode,"left",false,preferenceSelectionPos);
      }
      if(rightAncestorSelection){
        ancestorIndex = rand.nextInt(i-1)+1;
        rightAncestorNode = rightTreeNodes.get(ancestorIndex);
        ancestorPosOrNeg = rand.nextBoolean();
        preferenceSelectionPos = rand.nextBoolean();
        ruleNo++;
        finalList.add("rank("+treeNum+","+ruleNo+","+rank+").");
        splitAncestorSelectionMethod(rightNodeNumber,ruleNo,treeNum,rightAncestorNode,rootNode,"right",ancestorPosOrNeg,preferenceSelectionPos);
        ruleNo++;
        finalList.add("rank("+treeNum+","+ruleNo+","+rank+").");
        splitAncestorSelectionMethod(rightNodeNumber,ruleNo,treeNum,rightAncestorNode,rootNode,"right",!ancestorPosOrNeg,!preferenceSelectionPos);
      }
      else{
        ruleNo++;
        preferenceSelectionPos = rand.nextBoolean();
        rightAncestorNode = 0;
        finalList.add("rank("+treeNum+","+ruleNo+","+rank+").");
        splitAncestorSelectionMethod(rightNodeNumber,ruleNo,treeNum,0,rootNode,"right",false,preferenceSelectionPos);
      }

      
    }
    finalList.add("prules("+treeNum+",1.."+ruleNo+").\n");
    finalList.add("\n");
  }//splitAtRootTrees()


  //splitAncestorSelectionMethod
  public static void splitAncestorSelectionMethod(int nodeNumber,int ruleNo, int treeNum, int ancestorNode, int rootNode, String leftOrRight, boolean ancestorPosOrNeg, boolean preferenceSelectionPos)
  {
    if(ancestorNode != 0){
      if(ancestorPosOrNeg && leftOrRight.equals("left"))
      {
        finalList.add("body("+treeNum+","+ruleNo+"):-answer("+rootNode+"),answer("+ancestorNode+").");
      }
      else if(!ancestorPosOrNeg && leftOrRight.equals("left"))
      {
        finalList.add("body("+treeNum+","+ruleNo+"):-answer("+rootNode+"),negAnswer("+ancestorNode+").");
      }
      else if(ancestorPosOrNeg && leftOrRight.equals("right"))
      {
        finalList.add("body("+treeNum+","+ruleNo+"):-negAnswer("+rootNode+"),answer("+ancestorNode+").");
      }
      else
      {
        finalList.add("body("+treeNum+","+ruleNo+"):-negAnswer("+rootNode+"),negAnswer("+ancestorNode+").");
      }
    }
    else{
      if(leftOrRight.equals("left")){
        finalList.add("body("+treeNum+","+ruleNo+"):-answer("+rootNode+").");
      }
      else{
        finalList.add("body("+treeNum+","+ruleNo+"):-negAnswer("+rootNode+").");
      }
    }
    
    if(preferenceSelectionPos)
    {
      finalList.add("option("+treeNum+","+ruleNo+",1):-answer("+nodeNumber+").");
      finalList.add("option("+treeNum+","+ruleNo+",2):-negAnswer("+nodeNumber+").");
    }
    else
    {
      finalList.add("option("+treeNum+","+ruleNo+",1):-negAnswer("+nodeNumber+").");
      finalList.add("option("+treeNum+","+ruleNo+",2):-answer("+nodeNumber+").");
    }
  } //end of splitAncestor


}//LPTreesPreferences class

