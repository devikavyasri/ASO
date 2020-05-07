//This program is used to convert the format of New preference rules(Devi) to old preference rules(Ying)

//Input: NewPreferenceRulesFileName 
//Output: Creates file with rules in OldFormat/pref folder


//Compile: javac ConvertNewToOldPrefRanked.java
//Execute: java ConvertNewToOldPrefRanked pref_rank/pref60_180_1.txt 

import java.io.File;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;
import java.util.ArrayList;

public class ConvertNewToOldPrefRanked{
  public static void main(String[] args){
    String inputFile=args[0]; //New preference fileName
    //String numOfAtoms=args[1];
    //int numOfPrefClauses=Integer.parseInt(args[2]);
    //String instanceNumber=inputFile.substring(22,inputFile.length()-4);
    //System.out.println("instanceNumber: "+instanceNumber);
    //String prefFile="Ying's/pref_rank/pref"+numOfAtoms+"_"+numOfPrefClauses+"_"+instanceNumber+".txt";
    String prefFile="OldFormat/pref/"+inputFile.substring(10);
    //String impFile="Ying's/imp/imp"+numOfAtoms+"_"+numOfPrefClauses+"_"+instanceNumber+".txt";
    String line=null;
    //String[] body=new array[numOfPrefClauses];
    //String[] head=new array[numOfPrefClauses];
    String option1=null;
    String option2=null;
    String option=null;
    String body=null;
    String selectOption=null;
    ArrayList<String> list=new ArrayList<String>();
    //Boolean flag=true;
    //int ruleNo=1;
    int temp;
    try{
      BufferedReader input=new BufferedReader(new FileReader(inputFile));
      //pref file
      File pref=new File(prefFile);
      if(!pref.exists()){
        pref.createNewFile();
      }

      //writing to pref file
      BufferedWriter prefOut=new BufferedWriter(new FileWriter(pref.getAbsoluteFile()));
      while((line=input.readLine())!=null)
      {
        if(line.contains("body"))
        {
          body="";
          for(String word:line.split(":-")){
            temp=1;
            for(String subword:word.split(",")){
              if(temp>1){
                body=body+", ";
              }
              if(subword.contains("answer")){
                if(temp==1){
                  body=body+" :- ";
                }
                if(subword.contains("."))
                  body=body+"atom"+subword.substring(7,subword.length()-2);
                else
                  body=body+"atom"+subword.substring(7,subword.length()-1);
                temp++;
              }
              if(subword.contains("negAnswer")){
                if(temp==1){
                  body=body+" :- ";
                }
                if(subword.contains("."))
                  body=body+"not atom"+subword.substring(10,subword.length()-2);
                else
                  body=body+"not atom"+subword.substring(10,subword.length()-1);
                temp++;
              }
            }
          }
          list.add(body);
        }//end of body if

        if(line.contains("option")){
          option1="";
          option2="";
          option="";
          for(String word:line.split(":-")){
            if(word.contains("option")){
              if(word.contains(",2"))
                selectOption="option2";
              else
                selectOption="option1";
            }
            else{
              if(word.contains("answer")){
                  option=option+"atom"+word.substring(7,word.length()-2);
              }
              else if(word.contains("negAnswer")){
                  option=option+"not atom"+word.substring(10,word.length()-2);
              }
            }
          }//end of for
          if(selectOption.equals("option2")){
            option2=option;
            list.add(option2);
          }
          else{
            option1=option;
            list.add(option1);
          }
        }//end of option if
        if(list.size()==3){
          //System.out.print(list.get(1)+" > "+list.get(2)+list.get(0)+".\n");
          prefOut.write(list.get(1)+" > "+list.get(2)+list.get(0)+".\n");
          list.clear();
        }
      }//end of while()
      input.close();
      prefOut.close();
    }
    catch(IOException e){
      e.printStackTrace();
    }
  }
}
