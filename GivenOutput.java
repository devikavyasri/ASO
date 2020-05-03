//This program takes answer set as input and generates a constraint
//to exclude input answer set. It also changes format of satisfaction
//degrees of given input.

//Input: FileName containing answer set.
//Output: Prints constraint to exclude input answer set and formats satisfaction degrees

//Example1 for number of atoms = 5 and number of preference rules = 5
//Input:
//answer(4) answer(1) answer(3) negAnswer(2) negAnswer(5)
//sdegree(1,2) sdegree(2,1) sdegree(3,2) sdegree(4,1) sdegree(5,1)

//Output
//:-answer(4), answer(1), answer(3),negAnswer(2),negAnswer(5).
//givensdegree(1,2). givensdegree(2,1). givensdegree(3,2). givensdegree(4,1). givensdegree(5,1).

//Example2: If there is no answer set, it prints "%No optimal outcome" and ":-"

import java.io.File;
import java.util.Scanner;
import java.io.IOException;

public class GivenOutput
{
  public static void main(String[] args)
  {
    String fileName=args[0];
    String word=null;
    String constraint=":-";
    Boolean first=true;
    try{
      Scanner scan=new Scanner(new File(fileName));
      while(scan.hasNext())
      {
        word=scan.next();
        if(word.contains("answer")||word.contains("negAnswer"))
        {
          if(first)
          {
            constraint=constraint+word;
            first=false;
          }
          else
            constraint=constraint+","+word;
        }
        else if(word.contains("sdegree"))
        {
          System.out.println("given"+word+".");
        }
      }
    }
    catch(IOException e){
      System.out.print("% No optimal outcome \n");
      //e.printStackTrace();
    }catch(Exception ex){
      ex.printStackTrace();
    }
    System.out.println(constraint+".");
  }
}
