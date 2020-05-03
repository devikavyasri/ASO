%givensdegree(O,R,D1) implies given Oth answerSet's degree of rule R is D1.
%sdegree(R,D2) implies current degree of rule R is D2.

%worse(O) if current degree is greater than previous degree for some rule when compared with outcome O.
%better(O) if current degree is less than previous degree for some rule when compared with outcome O.


worse(O):-givensdegree(O,R,D1),sdegree(R,D2),D1<D2,prules(R),outcomes(O).
better(O):-givensdegree(O,R,D1),sdegree(R,D2),D1>D2,prules(R),outcomes(O).
:-worse(O),not better(O).


%#show better/1.
%#show worse/1.
