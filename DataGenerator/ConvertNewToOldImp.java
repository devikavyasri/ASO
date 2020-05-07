//This program is used to generates ranks of ranked preference rules (Required for old program-Ying's)

//Input: numOfAtoms numOfPreferenceClauses
//Output: Creates file with rules in OldFormat/imp folder


//Compile: javac ConvertNewToOldImp.java
//Execute: java ConvertNewToOldImp 60 180

import java.io.File;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;

public class ConvertNewToOldImp{
  public static void main(String[] args){
    String numOfAtoms=args[0];
    int numOfPrefClauses=Integer.parseInt(args[1]);
    String impFile="OldFormat/imp/imp"+numOfAtoms+"_"+numOfPrefClauses+"_"+2+".txt";
    try{
      //imp file
      File imp=new File(impFile);
      if(!imp.exists()){
        imp.createNewFile();
      }
      //writing to imp file

      BufferedWriter impOut=new BufferedWriter(new FileWriter(imp.getAbsoluteFile()));
      for(int i=1;i<=numOfPrefClauses;i++){
        if(i<=numOfPrefClauses/2)
          impOut.write("1\n");
        else
          impOut.write("2\n");
      }
      impOut.close();
    }
    catch(IOException e){
      e.printStackTrace();
    }
  }
}
