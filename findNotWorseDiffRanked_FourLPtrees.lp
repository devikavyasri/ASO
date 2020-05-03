%givensdegree(T,R,D1) implies given answerSet's degree of rule R in tree T is D1.
%sdegree(T,R,D2) implies current degree of rule R in tree T is D2.

%worseAt(T,L) is true if current degree is greater than previous degree for some rule of rank L in Tree T.
worseAt(T,L):-givensdegree(T,R,D1),sdegree(T,R,D2),D1<D2,rank(T,R,L).

%worseFailAt(T,L) is true if currentDegree is greater than previousDegree on some preference rule with rank L in tree T,
%and currentDegree is less than previousDegree for some preference rule with the same rank or a higher rank than L
worseFailAt(T,L):-worseAt(T,L),givensdegree(T,R,D1),sdegree(T,R,D2),D1>D2,rank(T,R,LO),LO<=L.

%worseFailAt(T,L) is true if currentDegree is greater than previousDegree on some preference rule tree T1 (T1 is preferred than T),
%and currentDegree is less than previousDegree for some preference rule with the same rank or a higher rank than L
worseFailAt(T,L):-worseAt(T,L),givensdegree(T1,R,D1),sdegree(T1,R,D2),D1>D2,T1<T.

:-worseAt(T,L),not worseFailAt(T,L).



%#show worse/1.
#show worseFailAt/2.
#show worseAt/2.


























%*****-----------


%worseAt(L):-givensdegree(R,D1),sdegree(R,D2),D1<D2,rank(R,L).
%worseFailAt(L):-worseAt(L),givensdegree(R,D1),sdegree(R,D2),D1>D2,rank(R,LO),LO<=L.
%:-worseAt(L),not worseFailAt(L).




worseAt(T,L):-givensdegree(T,R,D1),sdegree(T,R,D2),D1<D2,rank(T,R,L).
worseFailAt(T,L):-worseAt(T,L),givensdegree(T,R,D1),sdegree(T,R,D2),D1>D2,rank(T,R,LO),LO<=L.
worseAt(T):-worseAt(T,L),not worseFailAt(T,L).
worseFailAt(T):-


givensdegree(1,1,1).givensdegree(1,2,2).givensdegree(1,3,1).givensdegree(1,4,1).givensdegree(1,5,2).
sdegree(1,1,2).sdegree(1,2,2).sdegree(1,3,1).sdegree(1,4,1).sdegree(1,5,2).

givensdegree(2,1,1).givensdegree(2,2,2).givensdegree(2,3,1).givensdegree(2,4,1).givensdegree(2,5,2).
sdegree(2,1,1).sdegree(2,2,2).sdegree(2,3,1).sdegree(2,4,1).sdegree(2,5,2).


rank(1,1,1).rank(1,2,2).rank(1,3,2).rank(1,4,3).rank(1,5,3).
rank(2,1,1).rank(2,2,2).rank(2,3,2).rank(2,4,3).rank(2,5,3).




%inEquality(T,L):-psdegree(T,R,D1),sdegree(T,R,D2),D1!=D2,rank(T,R,L).
%equality(T,L):-not inEquality(T,L),rank(T,R,L).
%failAt(T,L):-equality(T,L0),psdegree(T,R,D1),sdegree(T,R,D2),D1<D2,rank(T,R,L),L0<=L.

%betterAt(T):-not failAt(T,L),betterAt(T,L).
%failAt(T):- failAt(T,L).
%failAt(T):-betterAt(T), failAt(T0),T0<=T.

%better:-not failAt(T),betterAt(T).
%:-not better.

#show betterAt/2.
#show failAt/2.
#show failAt/1.
#show betterAt/1.
#show better/0.




*%
