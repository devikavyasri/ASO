%Prints the total difference between two outcomes


#const numOfAtoms=numOfAtoms.
#const outputNumber=outputNumber.
totalAtoms(1..numOfAtoms).



difference(A):-answer(A),negAnswer(outputNumber,A),totalAtoms(A).
difference(A):-negAnswer(A),answer(outputNumber,A),totalAtoms(A).

distanceCount(S):-S=#count{A:difference(A)}.
%#show difference/1.
#show distanceCount/1.
