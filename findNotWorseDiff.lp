%givensdegree(R,D1) implies given answerSet's degree of rule R is D1.
%sdegree(R,D2) implies current degree of rule R is D2.

%worse if current degree is greater than previous degree for some rule.
%better if current degree is less than previous degree for some rule.

worse:-givensdegree(R,D1),sdegree(R,D2),D1<D2,prules(R).
better:-givensdegree(R,D1),sdegree(R,D2),D1>D2,prules(R).
:-worse,not better.


%#show better/0.
%#show worse/0.
