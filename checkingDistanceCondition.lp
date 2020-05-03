%Prints the total difference between two outcomes

#const numOfAtoms=numOfAtoms.
totalAtoms(1..numOfAtoms).

difference(A):-answer(A),optimalnegAnswer(A),totalAtoms(A).
difference(A):-negAnswer(A),optimalanswer(A),totalAtoms(A).

distanceCount(S):-S=#count{A:difference(A)}.
#show distanceCount/1.
