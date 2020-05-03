%This program changes format of answer set.
%Input: answer(1,2).answer(1,3).negAnswer(1,1).
%Output: answer(2).answer(3).negAnswer(1).

#const outcomeNumber=outcomeNumber.

answer(X):-answer(outcomeNumber,X).
negAnswer(X):-negAnswer(outcomeNumber,X).

#show answer/1.
#show negAnswer/1.
