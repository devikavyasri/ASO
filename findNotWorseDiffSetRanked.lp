%givensdegree(O,R,D1) implies given Oth answerSet's degree of rule R is D1.
%sdegree(R,D2) implies current degree of rule R is D2.

%worseAt(O,L) if current degree is greater than previous degree for some rule of rank L when compared with outcome O.
%worseFailAt(O,L) if current degree is less than previous degree for some rule of rank LO<=L and worseAt(L) is true when compared with outcome O.


worseAt(O,L):-givensdegree(O,R,D1),sdegree(R,D2),D1<D2,rank(R,L),outcomes(O).
worseFailAt(O,L):-worseAt(O,L),givensdegree(O,R,D1),sdegree(R,D2),D1>D2,rank(R,LO),LO<=L,outcomes(O).
:-worseAt(O,L),not worseFailAt(O,L).



%#show worseAt/2.
%#show worseFailAt/2.
