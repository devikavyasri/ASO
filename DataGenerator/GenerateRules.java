//This program is used to generate Generator rules and Ranked Preference Rules
//Input: numOfAtoms multiplierToGeneratorProgram  multiplierToPreferenceProgram InstanceNumber
//Output: creates files with rules in gen, pref_rank folders

//To generate rules with 60 atoms, 240 GeneratorRules, 180PreferenceRules, instanceNumber=1
//First compile : javac GenerateRules.java
//To Execute    : java GenerateRules 60 4 3 1


import java.util.*;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.lang.*;

public class GenerateRules{
  public static void main(String[] args){
    int numOfAtoms=Integer.parseInt(args[0]);
    double genMultilper=Double.parseDouble(args[1]);
    double prefMultilper=Double.parseDouble(args[2]);
    int instanceNo=Integer.parseInt(args[3]);
    createGeneratorRules(numOfAtoms,genMultilper,instanceNo);
    createPreferenceRulesRanked(numOfAtoms,prefMultilper,instanceNo);
    //createPreferenceRules(numOfAtoms,prefMultilper,instanceNo);
  }

    //finding factorial
  public static double factorial(double n)
  {
    if(n==0)
      return 1;
    else
      return n * factorial(n-1);
  }


  //Generating generator rules
  public static void createGeneratorRules(int numOfAtoms,double generatorMultiplier,int instanceNo)
  {
    int numOfGenRules=(int) (generatorMultiplier*numOfAtoms);
    double possibleGenRules=8*factorial(numOfAtoms)/(factorial(numOfAtoms-3)*factorial(3)); //possibleRules= 8*nc3
    int ruleNo;
    List<List<Integer>> generatorRulesList=new ArrayList<List<Integer>>();
    List<Integer> clause = new ArrayList<Integer>();
    List<Integer> tempList = new ArrayList<Integer>();

    //checking if numOfGenRules is less than possibleGenRules
    if(numOfGenRules>possibleGenRules){
      System.out.println("Number of generator rules should be less than "+possibleGenRules+" for given number of atoms");
      System.exit(0);
    }
    try
    {
      File file=new File("gen/gen"+numOfAtoms+"_"+numOfGenRules+"_"+instanceNo+".txt");
      if(!file.exists()){
        file.createNewFile();
      }

      FileWriter fw = new FileWriter(file.getAbsoluteFile());
      BufferedWriter out = new BufferedWriter(fw);
      out.write("#const numOfAtoms = "+numOfAtoms+".\n");
      out.write("atoms(1.."+numOfAtoms+").\n");
      out.write("clauses(1.."+numOfGenRules+").\n");

      ruleNo=1;
      while(ruleNo<=numOfGenRules)
      {
        clause=selectLiterals(numOfAtoms,3,"gen");
        tempList=clause;
        Collections.sort(tempList);
        if(!generatorRulesList.contains(tempList))
        {
          generatorRulesList.add(tempList);
          for(int literal:clause)
          {
            //System.out.print(literal);
            if(literal<0)
            {
              literal=literal*(-1);
              out.write("neg("+ruleNo+","+literal+").");
            }
            else
              out.write("pos("+ruleNo+","+literal+").");
          }
          ruleNo++;
          //System.out.println();
          out.write("\n");
        }
      }
      out.close();
    }
    catch(IOException e){
      e.printStackTrace();
    }
  }

  //select set of literals
  public static List<Integer> selectLiterals(int numOfAtoms,int numOfLiterals,String genOrPref)
  {
    List<Integer> list = new ArrayList<Integer>();
    List<Integer> checkList = new ArrayList<Integer>();
    Random rand = new Random();
    int literalNum=1;
    boolean posNeg;
    int literal;
    while(literalNum<=numOfLiterals)
    {
      posNeg = rand.nextBoolean();
      literal= rand.nextInt(numOfAtoms)+1;
      if(!posNeg)
        literal=literal*(-1);
      if(genOrPref.equals("gen")){
        //to select distinct literals
        if(!checkList.contains(Math.abs(literal)))
        {
          list.add(literal);
          checkList.add(Math.abs(literal));
          literalNum++;
        }
      }
      else if(genOrPref.equals("pref"))
      {
        if(!list.contains(literal))
        {
          list.add(literal);
          literalNum++;
        }
      }
    }
    return list;
  }

  //preference rules with rank
  public static void createPreferenceRulesRanked(int numOfAtoms,double prefMultilper,int instanceNo){
    int numOfPrules = (int) (prefMultilper*numOfAtoms);
    Random rand = new Random();
    int literalSelection,headSelection,condSelect1,condSelect2;
    int cliteral1=0,cliteral2;
    String head,condition;
    String rule="";
    String tempRule="";
    int condLiteral;

    List<Integer> rankList = new ArrayList<Integer>();
    List<String> checkList = new ArrayList<String>();
    List<String> addList = new ArrayList<String>();

    try{
      File file = new File("pref_rank/pref"+numOfAtoms+"_"+numOfPrules+"_"+instanceNo+".txt");
      if (!file.exists()) {
          file.createNewFile();
      }
      FileWriter fw = new FileWriter(file.getAbsoluteFile());
      BufferedWriter out = new BufferedWriter(fw);

      out.write("prules(1.."+numOfPrules+").\n");
      out.write("#const maxNumOfOpts = 2.\n");
      out.write("degrees(0..maxNumOfOpts).\n\n");

      //ranking rules
      int rankCount=1;
      //int rankAtom;
      while(rankCount<=numOfPrules){
        if(rankCount<=(numOfPrules/2))
          out.write("rank("+rankCount+",1).\n");
        else
          out.write("rank("+rankCount+",2).\n");
        rankCount++;
      }

      /*
      while(rankCount<numOfPrules){
        rankAtom = rand.nextInt(numOfPrules)+1;
        if(!rankList.contains(rankAtom)){
          rankList.add(rankAtom);
          if(rankCount<numOfPrules/2){
            out.write("rank("+rankAtom+",1).\n");
            rankCount++;
          }
          else{
            out.write("rank("+rankAtom+",2).\n");
            rankCount++;
          }
        }
      }
      */

      //System.out.println("numOfPrules "+numOfPrules);
      int i=1;
      while(i<=numOfPrules){
        rule="";
        tempRule="";
        addList.add("%rule "+i+".\n");

        literalSelection= rand.nextInt(numOfAtoms)+1;
        headSelection = rand.nextInt(2);
        condSelect1 = rand.nextInt(2);
        //body
        if(condSelect1==0){
          addList.add("body("+i+").\n");
          rule=rule+" : ";
          tempRule=tempRule+" : ";
        }
        else{
          condSelect2 = rand.nextInt(2);
          if(condSelect2==0){
              cliteral1=rand.nextInt(numOfAtoms)+1;
              while(cliteral1==literalSelection){
                cliteral1=rand.nextInt(numOfAtoms)+1;
              }
              condLiteral = rand.nextInt(2);
              if(condLiteral==0){
                addList.add("body("+i+"):-answer("+cliteral1+").\n");
                rule=rule+cliteral1+" : ";
                tempRule=tempRule+cliteral1+" : ";
              }
              else{
                addList.add("body("+i+"):-negAnswer("+cliteral1+").\n");
                rule=rule+"not "+cliteral1+" : ";
                tempRule=tempRule+"not "+cliteral1+" : ";
              }
          }
          else{
              cliteral1=rand.nextInt(numOfAtoms)+1;
              cliteral2=rand.nextInt(numOfAtoms)+1;
              while(cliteral1==literalSelection || cliteral2==literalSelection || cliteral1==cliteral2){
                cliteral1=rand.nextInt(numOfAtoms)+1;
                cliteral2=rand.nextInt(numOfAtoms)+1;
              }
              condLiteral = rand.nextInt(4);
              if(condLiteral==0){
                addList.add("body("+i+"):-answer("+cliteral1+"),answer("+cliteral2+").\n");
                rule=rule+cliteral1+","+cliteral2+" : ";
                tempRule=tempRule+cliteral1+","+cliteral2+" : ";
              }
              else if(condLiteral==1){
                addList.add("body("+i+"):-answer("+cliteral1+"),negAnswer("+cliteral2+").\n");
                rule=rule+cliteral1+",not "+cliteral2+" : ";
                tempRule=tempRule+cliteral1+",not "+cliteral2+" : ";
              }
              else if(condLiteral==2){
                addList.add("body("+i+"):-negAnswer("+cliteral1+"),answer("+cliteral2+").\n");
                rule=rule+"not "+cliteral1+","+cliteral2+" : ";
                tempRule=tempRule+"not "+cliteral1+","+cliteral2+" : ";
              }
              else{
                addList.add("body("+i+"):-negAnswer("+cliteral1+"),negAnswer("+cliteral2+").\n");
                rule=rule+"not "+cliteral1+",not "+cliteral2+" : ";
                tempRule=tempRule+"not "+cliteral1+",not "+cliteral2+" : ";
              }
          }
        }

        //head
        if(headSelection==0){
          addList.add("option("+i+",1):-answer("+literalSelection+").\n");
          addList.add("option("+i+",2):-negAnswer("+literalSelection+").\n");
          rule=rule+literalSelection+" > not "+literalSelection;
          tempRule=tempRule+"not "+literalSelection+" > "+literalSelection;
        }
        else{
          addList.add("option("+i+",1):-negAnswer("+literalSelection+").\n");
          addList.add("option("+i+",2):-answer("+literalSelection+").\n");
          rule=rule+"not "+literalSelection+" > "+literalSelection;
          tempRule=tempRule+literalSelection+" > not "+literalSelection;
        }
        if(!checkList.contains(rule) && !checkList.contains(tempRule)){
          checkList.add(rule);
          //System.out.println(rule);
          Iterator it = addList.iterator();
          while(it.hasNext()){
            String temp=it.next().toString();
            out.write(temp);
          }
          addList.clear();
          i++;
        }
        else{
          addList.clear();
        }
      }
      out.close();
    }
    catch(IOException e){
      e.printStackTrace();
    }
  }

  //preference rules without rank
  public static void createPreferenceRules(int numOfAtoms,double prefMultilper,int instanceNo){
    int numOfPrules = (int) (prefMultilper*numOfAtoms);
    Random rand = new Random();
    int literalSelection,headSelection,condSelect1,condSelect2;
    int cliteral1=0,cliteral2;
    String head,condition;
    String rule="";
    String tempRule="";
    int condLiteral;

    List<String> checkList = new ArrayList<String>();
    List<String> addList = new ArrayList<String>();

    try{
      File file = new File("pref/pref"+numOfAtoms+"_"+numOfPrules+"_"+instanceNo+".txt");
      if (!file.exists()) {
          file.createNewFile();
      }
      FileWriter fw = new FileWriter(file.getAbsoluteFile());
      BufferedWriter out = new BufferedWriter(fw);

      out.write("prules(1.."+numOfPrules+").\n");
      out.write("#const maxNumOfOpts = 2.\n");
      out.write("degrees(0..maxNumOfOpts).\n\n");
      //System.out.println("numOfPrules "+numOfPrules);
      int i=1;
      while(i<=numOfPrules){
        rule="";
        tempRule="";
        addList.add("%rule "+i+".\n");

        literalSelection= rand.nextInt(numOfAtoms)+1;
        headSelection = rand.nextInt(2);
        condSelect1 = rand.nextInt(2);
        //body
        if(condSelect1==0){
          addList.add("body("+i+").\n");
          rule=rule+" : ";
          tempRule=tempRule+" : ";
        }
        else{
          condSelect2 = rand.nextInt(2);
          if(condSelect2==0){
              cliteral1=rand.nextInt(numOfAtoms)+1;
              while(cliteral1==literalSelection){
                cliteral1=rand.nextInt(numOfAtoms)+1;
              }
              condLiteral = rand.nextInt(2);
              if(condLiteral==0){
                addList.add("body("+i+"):-answer("+cliteral1+").\n");
                rule=rule+cliteral1+" : ";
                tempRule=tempRule+cliteral1+" : ";
              }
              else{
                addList.add("body("+i+"):-negAnswer("+cliteral1+").\n");
                rule=rule+"not "+cliteral1+" : ";
                tempRule=tempRule+"not "+cliteral1+" : ";
              }
          }
          else{
              cliteral1=rand.nextInt(numOfAtoms)+1;
              cliteral2=rand.nextInt(numOfAtoms)+1;
              while(cliteral1==literalSelection || cliteral2==literalSelection || cliteral1==cliteral2){
                cliteral1=rand.nextInt(numOfAtoms)+1;
                cliteral2=rand.nextInt(numOfAtoms)+1;
              }
              condLiteral = rand.nextInt(4);
              if(condLiteral==0){
                addList.add("body("+i+"):-answer("+cliteral1+"),answer("+cliteral2+").\n");
                rule=rule+cliteral1+","+cliteral2+" : ";
                tempRule=tempRule+cliteral1+","+cliteral2+" : ";
              }
              else if(condLiteral==1){
                addList.add("body("+i+"):-answer("+cliteral1+"),negAnswer("+cliteral2+").\n");
                rule=rule+cliteral1+",not "+cliteral2+" : ";
                tempRule=tempRule+cliteral1+",not "+cliteral2+" : ";
              }
              else if(condLiteral==2){
                addList.add("body("+i+"):-negAnswer("+cliteral1+"),answer("+cliteral2+").\n");
                rule=rule+"not "+cliteral1+","+cliteral2+" : ";
                tempRule=tempRule+"not "+cliteral1+","+cliteral2+" : ";
              }
              else{
                addList.add("body("+i+"):-negAnswer("+cliteral1+"),negAnswer("+cliteral2+").\n");
                rule=rule+"not "+cliteral1+",not "+cliteral2+" : ";
                tempRule=tempRule+"not "+cliteral1+",not "+cliteral2+" : ";
              }
          }
        }

        //head
        if(headSelection==0){
          addList.add("option("+i+",1):-answer("+literalSelection+").\n");
          addList.add("option("+i+",2):-negAnswer("+literalSelection+").\n");
          rule=rule+literalSelection+" > not "+literalSelection;
          tempRule=tempRule+"not "+literalSelection+" > "+literalSelection;
        }
        else{
          addList.add("option("+i+",1):-negAnswer("+literalSelection+").\n");
          addList.add("option("+i+",2):-answer("+literalSelection+").\n");
          rule=rule+"not "+literalSelection+" > "+literalSelection;
          tempRule=tempRule+literalSelection+" > not "+literalSelection;
        }
        if(!checkList.contains(rule) && !checkList.contains(tempRule)){
          checkList.add(rule);
          //System.out.println(rule);
          Iterator it = addList.iterator();
          while(it.hasNext()){
            String temp=it.next().toString();
            out.write(temp);
          }
          addList.clear();
          i++;
        }
        else{
          addList.clear();
        }
      }
      out.close();
    }
    catch(IOException e){
      e.printStackTrace();
    }
  }
}
