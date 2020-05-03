//This program takes answer set as input and generates a constraint
//to exclude input answer set. It also changes format of given answer set, satisfaction
//degrees of given input.

//Input: FileName containing answer set.
//Output: Prints constraint to exclude input answer set and formats satisfaction degrees,answer set

//Example1 for number of atoms = 5 and number of preference rules = 5
//Input:
//answer(4) answer(1) answer(3) negAnswer(2) negAnswer(5)
//sdegree(1,2) sdegree(2,1) sdegree(3,2) sdegree(4,1) sdegree(5,1)

//Output
// :-answer(4), answer(1), answer(3),negAnswer(2),negAnswer(5).
//givensdegree(1,2). givensdegree(2,1). givensdegree(3,2). givensdegree(4,1). givensdegree(5,1).
//given(4). given(1). given(3).




import java.io.File;
import java.util.Scanner;
import java.io.IOException;
import java.io.FileNotFoundException;

public class GivenOutputForAlternate
{
  public static void main(String[] args)
  {
    String fileName = args[0];
    //String numOfAtoms = args[1];
    String word=null;
    String constraint=":-";
    Boolean first=true;
    String replaceString;

    //System.out.println("given(1.."+numOfAtoms+").");
    try{
      Scanner scan=new Scanner(new File(fileName));
      while(scan.hasNext())
      {
        word=scan.next();
        if(word.contains("no")||word.contains("outcome")||word.contains("no outcome"))
        {
          break;
        }

        if(word.contains("answer")||word.contains("negAnswer"))
        {
          //creates constraint
          if(first)
          {
            constraint=constraint+word;
            first=false;
          }
          else
          {
            constraint=constraint+","+word;
          }

          //creates given answerSet with word given
          if(word.contains("answer"))
          {
            replaceString=word.replace("answer","given");
            System.out.println(replaceString+".");
          }
        }
        else if(word.contains("sdegree"))
        {
          System.out.println("given"+word+".");
        }
      }
    }
    catch(IOException e){
      System.out.println("");
    }catch(Exception ex){
      ex.printStackTrace();
    }
    System.out.println(constraint+".");
  }
}
