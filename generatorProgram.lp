%count of answer(X) : 0 to numOfAtoms.
%pos(C,X): indicates in clause C,  X is positive i.e. X.
%neg(C,X): indicates in clause C,  X is negative i.e. ~X.

%In an outcome, at most five atoms should be true.
0{answer(X):atoms(X)}numOfAtoms.

%If an atom is not true in an outcome, then the atom is false in the outcome.
negAnswer(X):-not answer(X),atoms(X).


% clause(C): C is true if either its positive literal is true or its negative literal is true
clause(C):-pos(C,X),answer(X),clauses(C),atoms(X).
clause(C):-neg(C,X),negAnswer(X),clauses(C),atoms(X).

%all clauses should be true for obtained answer set(i.e. various values of atoms).
:-not clause(C),clauses(C).

#show answer/1.
#show negAnswer/1.
