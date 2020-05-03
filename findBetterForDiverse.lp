%psdegree(C,R,D1) implies for outcome C, previous degree of rule R is D1.
%sdegree(C,R,D2) implies for outcome C, current degree of rule R is D2.

#const totalDiverseOutcomes=totalDiverseOutcomes.


%better if current degree is less than previous degree for all rules.
better:-psdegree(C,R,D1),sdegree(C,R,D2),prules(C,R),D1>D2,C=1..totalDiverseOutcomes.
:-psdegree(C,R,D1),sdegree(C,R,D2),D1<D2.
:-not better.
