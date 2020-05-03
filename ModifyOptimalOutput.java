//This program takes numOfAtoms, outcomeNumber, answer set as input and generates a constraint
//to exclude input answer set. It also changes format of satisfaction
//degrees of given input.

//Input: FileName containing answer set; outcomeNumber
//Output: Prints constraint to exclude input answer set and formats satisfaction degrees

//Example1 for number of atoms = 5 and number of preference rules = 5; outcomeNumber=2
//Input:
//answer(4) answer(1) answer(3) sdegree(1,2) sdegree(2,1) sdegree(3,2) sdegree(4,1) sdegree(5,1) 2


//Output
// :-answer(4), answer(1), answer(3).
//givensdegree(2,1,2). givensdegree(2,2,1). givensdegree(2,3,2). givensdegree(2,4,1). givensdegree(2,5,1).



import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.FileReader;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;


public class ModifyOptimalOutput{
  public static void main(String[] args){
    if(args.length>0){
      int numOfAtoms=Integer.parseInt(args[0]);
      int outcomeNumber=Integer.parseInt(args[1]);

      System.out.println("outcomes("+outcomeNumber+").");
      System.out.println("%outcome: "+outcomeNumber+".");
      for(int i=2; i<args.length;i++){
        if(args[i].contains("sdeg")){
          System.out.println("givensdegree("+outcomeNumber+","+args[i].substring(9,args[i].length()-1));
        }
      }
      int num=0;
      System.out.print(":-");
      for(int i=2; i<args.length;i++){
        if(args[i].contains("answer")){
          System.out.print(args[i].substring(1,args[i].length()-2));
          num++;
        }
        else if(args[i].contains("negAns")){
          System.out.print(args[i].substring(1,args[i].length()-2));
          num++;
        }
        if(num<numOfAtoms){
          System.out.print(",");
        }
        else{
          System.out.print(".");
          break;
        }
      }
      System.out.println();
      System.out.println();
    }
  }
}
