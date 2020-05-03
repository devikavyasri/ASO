%psdegree(R,D1) implies previous degree of rule R is D1.
%sdegree(R,D2) implies current degree of rule R is D2.

%better if current degree is less than previous degree for all rules.
better:-psdegree(R,D1),sdegree(R,D2),prules(R),D1>D2.
:-psdegree(R,D1),sdegree(R,D2),D1<D2.
:-not better.
