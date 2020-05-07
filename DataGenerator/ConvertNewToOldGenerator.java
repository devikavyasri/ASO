//This program is used to convert the format of New generator rules(Devi) to old generator rules(Ying)

//Input: New GeneratorFileName
//Output: Creates file with rules in OldFormat/gen folder


//Compile: javac ConvertNewToOldGenerator.java
//Execute: java ConvertNewToOldGenerator gen/gen60_240_1.txt


import java.io.File;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;

public class ConvertNewToOldGenerator{
  public static void main(String[] args){
    String inputFile=args[0]; //New generator fileName
    //String fileName=inputFile.substring(4);
    String line=null;
    int numOfAtoms=0;
    int numOfClauses=0;
    String temp=null;
    Boolean flag=true;
    try{
      BufferedReader input=new BufferedReader(new FileReader(inputFile));
      File file=new File("OldFormat/"+inputFile);
      if(!file.exists()){
        file.createNewFile();
      }
      BufferedWriter out=new BufferedWriter(new FileWriter(file.getAbsoluteFile()));
      while((line=input.readLine())!=null)
      {
        if(line.contains("numOfAtoms"))
            numOfAtoms=Integer.parseInt(line.substring(20,line.length()-1));
        else{
            if(line.contains("clauses"))
            numOfClauses=Integer.parseInt(line.substring(11,line.length()-2));
        }
        if(numOfAtoms != 0 && numOfClauses != 0 && flag){
          out.write("p cnf "+numOfAtoms+" "+numOfClauses+"\n");
          flag=false;
        }
        if(line.contains("pos") || line.contains("neg"))
        {
          //System.out.println("line:"+line);
          temp="";
          for(String word:line.split("\\.")){
            //System.out.println("word:"+word);
            for(String subword : word.split("\\,")){
              if(subword.contains("neg")){
                temp=temp+"-";
                //System.out.println(temp);
              }
              else if(subword.contains("pos")){
                temp=temp+"";
                //System.out.println(temp);
              }
              else{
                temp=temp+subword.substring(0,subword.length()-1)+" ";
                //System.out.println(temp);
              }
            }//end of for
          }//end of for
          temp=temp+"0\n";
          //System.out.println(temp);
          out.write(temp);
        }
      }
      input.close();
      out.close();
    }
    catch(IOException e){
      e.printStackTrace();
    }
  }
}
