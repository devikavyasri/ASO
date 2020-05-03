//This file creates different copies of preferenceRules file
//Takes two input parameters: fileNameOf original Preference rules , totalCopies
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Scanner;

public class PreferenceProgramCopiesGenerator{
  public static void main(String[] args){
    String inputFileName = args[0];
    int totalCopies = Integer.parseInt(args[1]); //body(atomNumber) => body(fileNumber,atomNumber);
    for(int i=1;i<=totalCopies;i++){
      String replaceString = "("+i+",";
      String outputFileName = inputFileName.replace(".","_"+i+".");
      File outputFile = new File(outputFileName);
      try{
        BufferedWriter writer = new BufferedWriter(new FileWriter(outputFile));
        Scanner scanner1 = new Scanner(new File(inputFileName));
        while(scanner1.hasNextLine()){
          String line;
          line = scanner1.nextLine();
          if(line.contains("(")){
            line=line.replace("(",replaceString);
            //System.out.println(line);
            writer.write(line+"\n");
          }
          else if(i==1){
            writer.write(line+"\n");
          }
        }
        scanner1.close();
        writer.close();
      }catch(FileNotFoundException fileException){
        System.out.println(inputFileName + " not found");
      }catch(IOException e){
        System.out.println("Unable to write to output file: "+outputFile);
      }
    }
  }
}
