//This program is used to convert the format of New LPTrees preference rules(Devi) to old LPTrees preference rules(Ying)

//Input: NewPreferenceRulesFileName numOfAtoms
//Output: Creates file with rules in OldFormat/pref, OldFormat/imp folder


//Compile: javac ConvertNewToOldLPTreesPref.java
//Execute: java ConvertNewToOldLPTreesPref TwoLPTrees/pref60_2_1.txt 60


import java.io.File;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;
import java.util.ArrayList;

public class ConvertNewToOldLPTreesPref{
  public static void main(String[] args){
    String inputFile=args[0]; //new preference fileName
    String numOfAtoms=args[1];
    String fileName=inputFile.substring(inputFile.lastIndexOf("/")+1);
    String instanceNumber=fileName.substring(fileName.lastIndexOf("_")+1,fileName.length()-4);
    //String prefFile="Ying's/pref_rank/pref"+numOfAtoms+"_2_"+instanceNumber+".txt";
    String prefFile="OldFormat/pref/"+inputFile.substring(11);
    String impFile="OldFormat/imp/imp"+numOfAtoms+"_2_"+instanceNumber+".txt";
    String line=null;
    String option1=null;
    String option2=null;
    String option=null;
    String body=null;
    String selectOption=null;
    ArrayList<String> list=new ArrayList<String>();
    ArrayList<String> impList=new ArrayList<String>();
    int temp;
    try{
      BufferedReader input=new BufferedReader(new FileReader(inputFile));
      //pref file
      File pref=new File(prefFile);
      if(!pref.exists()){
        pref.createNewFile();
      }
      File imp=new File(impFile);
      if(!imp.exists()){
        imp.createNewFile();
      }

      //writing to pref file
      BufferedWriter prefOut=new BufferedWriter(new FileWriter(pref.getAbsoluteFile()));
      BufferedWriter impOut=new BufferedWriter(new FileWriter(imp.getAbsoluteFile()));
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
          prefOut.write(list.get(1)+" > "+list.get(2)+list.get(0)+".\n");
          list.clear();
        }
        if(line.contains("rank")){
          String rank=line.substring(line.lastIndexOf(",")+1,line.length()-2);
          impOut.write(rank+"\n");
        }//end of rank if
      }//end of while()
      input.close();
      prefOut.close();
      impOut.close();
    }
    catch(IOException e){
      e.printStackTrace();
    }
  }
}
