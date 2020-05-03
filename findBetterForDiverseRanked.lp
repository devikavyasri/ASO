%psdegree(C,R,D1) implies previous degree of rule R in outcome C is D1.
%sdegree(C,R,D2) implies current degree of rule R in outcome C is D2.

%betterAt(C,L) is true if current degree is less than previous degree for a rule of rank L in outcome C.
%failAt(C,L) is true if betterAt(L) is true and current degree is greater than previous degree for any rule of rank LO <= L in outcome C.


betterAt(C,L):-psdegree(C,R,D1),sdegree(C,R,D2),D1>D2,rank(C,R,L),C=1..totalDiverseOutcomes.
failAt(C,L):-betterAt(C,L),psdegree(C,R,D1),sdegree(C,R,D2),D1<D2,rank(C,R,LO),LO<=L,C=1..totalDiverseOutcomes.

better(C):-not failAt(C,L),betterAt(C,L).
:-not better(C),C=1..totalDiverseOutcomes.
