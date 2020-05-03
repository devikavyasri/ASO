%givensdegree(R,D1) implies given answerSet's degree of rule R is D1.
%sdegree(R,D2) implies current degree of rule R is D2.

%worseAt(L) if current degree is greater than previous degree for some rule of rank L.
%worseFailAt(T,L) is true if currentDegree is greater than previousDegree on some preference rule with rank L,
%and currentDegree is less than previousDegree for some preference rule with the same rank or a higher rank


worseAt(L):-givensdegree(R,D1),sdegree(R,D2),D1<D2,rank(R,L).
worseFailAt(L):-worseAt(L),givensdegree(R,D1),sdegree(R,D2),D1>D2,rank(R,LO),LO<=L.
:-worseAt(L),not worseFailAt(L).


%#show worseAt/1.
%#show worseFailAt/1.
