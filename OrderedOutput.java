//This program prints the true atoms in answer set in ordered way.

//Input: FileName containing answer set.
//Output: Prints the true atoms of answer set in ordered way.

//Example1 for number of atoms = 10,
//If the answer set is: answer(8), answer(1), answer(3)
//This program prints output as : atom1 atom3 atom8
//Example2: If there is no answer set, it prints "No answer set"

import java.io.File;
import java.util.Scanner;
import java.util.ArrayList;
import java.util.List;
import java.util.Collections;
import java.io.IOException;


public class OrderedOutput{
  public static void main(String[] args)
  {
    String inputFileName = args[0];
    String word = null;
    String line = null;
    ArrayList<Integer> list = new ArrayList<Integer>();
    Integer key = null;
    try{
      Scanner inputScan=new Scanner(new File(inputFileName));
        while(inputScan.hasNextLine()){
          line = inputScan.nextLine();
          ordering(line);
        }
      }
    catch(IOException e){ //If input file doesn't exist, this indicates no answer set.
      System.out.print("No answer set\n");
    }catch(Exception ex)
    {
      ex.printStackTrace();
    }
    System.out.println();
  }

  public static void ordering(String line)
  {
    String[] arrayOfWords=line.split(" ");
    ArrayList<Integer> list = new ArrayList<Integer>();
    Integer key = null;

    //If input file doesn't have answer set and contains "500OutcomesExceeded",
    //then print "500 Outcomes Exceeded".
    //If input file doesn't have answer set and contains "NoDiverseSetOfOptimalOutcomes",
    //then print "No Diverse Set Of Optimal Outcomes".
    //If input file has answer set, prints true atoms in ordered way
    for(String word : arrayOfWords){
      if(word.contains("500OutcomesExceeded")){
        System.out.println("500 Outcomes Exceeded");
        break;
      }
      else if(word.contains("NoDiverseSetOfOptimalOutcomes")){
        System.out.println("No Diverse Set Of Optimal Outcomes");
        break;
      }
      else if(word!=null && word.length()>7 && word.contains("answer("))
      {
        key=Integer.valueOf(word.substring(7,word.length()-1));
        list.add(key);
      }
    }
    Collections.sort(list);
    for(Integer i:list)
      System.out.print("atom"+i+" ");
    if(list.size() > 0){
      System.out.println();
    }
  }
}
