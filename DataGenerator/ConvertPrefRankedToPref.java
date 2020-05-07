//This program is used to convert preference Ranked Rules to preference unranked Rules
//Input: Name of file containing preference Ranked Rules 
// Output: Creates file with unranked Rules in pref folder.

//To compile: javac ConvertPrefRankedToPref.java
//Execute   : java ConvertPrefRankedToPref pref_rank/pref60_180_1.txt


import java.io.File;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;
import java.util.ArrayList;

public class ConvertPrefRankedToPref{
  public static void main(String[] args){
    String inputFile=args[0]; //Ranked preferences fileName
    //String numOfAtoms=args[1];
    //int numOfPrefClauses=Integer.parseInt(args[2]);
    //String instanceNumber=inputFile.substring(22,inputFile.length()-4);
    //System.out.println("instanceNumber: "+instanceNumber);
    String prefFile="pref/"+inputFile.substring(10);
    System.out.println("prefFile"+prefFile);
    String line=null;
    try{
      BufferedReader input=new BufferedReader(new FileReader(inputFile));
      File pref=new File(prefFile);
      if(!pref.exists()){
        pref.createNewFile();
      }

      //writing to pref file
      BufferedWriter prefOut=new BufferedWriter(new FileWriter(pref.getAbsoluteFile()));
      while((line=input.readLine())!=null)
      {
        if(!line.contains("rank"))
        {
          System.out.println("line"+line);
          prefOut.write(line+"\n");
        }//end of body if
      }//end of while()
      input.close();
      prefOut.close();
    }
    catch(IOException e){
      e.printStackTrace();
    }
  }
}
