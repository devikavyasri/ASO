%psdegree(R,D1) implies previous degree of rule R is D1.
%sdegree(R,D2) implies current degree of rule R is D2.

%betterAt(L) is true if current degree is less than previous degree for a rule of rank L.
%failAt(L) is true if betterAt(L) is true and current degree is greater than previous degree for any rule of rank LO <= L.


betterAt(L):-psdegree(R,D1),sdegree(R,D2),D1>D2,rank(R,L).
failAt(L):-betterAt(L),psdegree(R,D1),sdegree(R,D2),D1<D2,rank(R,LO),LO<=L.

better:-not failAt(L),betterAt(L).
:-not better.
