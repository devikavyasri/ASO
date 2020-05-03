//This program prints the answer set in different formats.

//Input: method, numOfAtoms, answerSet.
//Output: Prints the answer set in different format based on value of method.

//Example1 for number of atoms = 5 and number of preference rules = 5
//Input:  1 5 answer(4) answer(1) answer(3) negAnswer(2) negAnswer(5)
//sdegree(1,2) sdegree(2,1) sdegree(3,2) sdegree(4,1) sdegree(5,1)

//Output:  answer(4). answer(1). answer(3). negAnswer(2). negAnswer(5).

//Example2 for number of atoms = 5 and number of preference rules = 5
//Input:  2 5 answer(4) answer(1) answer(3) negAnswer(2) negAnswer(5)
//sdegree(1,2) sdegree(2,1) sdegree(3,2) sdegree(4,1) sdegree(5,1)

//Output:  answer(4), answer(1), answer(3),negAnswer(2),negAnswer(5).

public class PrintAnswerRemoveSdegree{
  public static void main(String[] args){
    int method = Integer.valueOf(args[0]);
    int numOfAtoms = Integer.valueOf(args[1]);
    //output: answer(1).answer(2).answer(3).
    if(method==1)
    {
      for(int i=2;i<args.length;i++)
      {
        if(args[i].contains("nswer"))
        {
          System.out.print(args[i]+".");
        }
      }
    }
    //output: answer(1),answer(2),answer(3).
    else if (method==2){
      int count=0;
      for(int i=2;i<args.length;i++)
      {
        if(args[i].contains("nswer"))
        {
          count++;
          if(count == numOfAtoms)
          {
            System.out.println(args[i]+".");
          }
          else{
            System.out.print(args[i]+",");
          }
        }
      }
    }
  }
}
