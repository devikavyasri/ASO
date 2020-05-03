%count of answer(O,X) : 0 to numOfAtoms.
%pos(C,X): indicates in clause C,  X is positive i.e. X.
%neg(C,X): indicates in clause C,  X is negative i.e. ~X.

#const totalDiverseOutcomes = totalDiverseOutcomes.
#const distance=distance.
outcomes(1..totalDiverseOutcomes).

%If "O" is outcomes, at most "numOfAtoms" of answer(O,X) should be obtained.
0{answer(O,X):atoms(X)}numOfAtoms :- outcomes(O).
negAnswer(O,X):-not answer(O,X),atoms(X),outcomes(O).


% clause(O,C): For outcome O, clause C is true if either its positive literal is true or its negative literal is true
clause(O,C):-pos(C,X),answer(O,X),clauses(C),atoms(X),outcomes(O).
clause(O,C):-neg(C,X),negAnswer(O,X),clauses(C),atoms(X),outcomes(O).

%all clauses should be true for each outcome obtained.
:-not clause(O,C),clauses(C),outcomes(O).



%diverse outcomes
distance{differences(I,J,1..numOfAtoms)}:-outcomes(I),outcomes(J),I!=J.


:-differences(I,J,A), answer(I,A), answer(J,A), outcomes(I), outcomes(J), I<J.
:-differences(I,J,A), not answer(I,A), not answer(J,A), outcomes(I), outcomes(J), I<J.
:-not differences(I,J,A), not answer(I,A), answer(J,A), outcomes(I), outcomes(J), I<J.
:-not differences(I,J,A), answer(I,A), not answer(J,A), outcomes(I), outcomes(J), I<J.


#show answer/2.
#show negAnswer/2.
