%prefer(C,R,A,B) -> In outcome C for rule R, option A is preferred to option B.
%sdegree(R,0):True if body(R) is not satisfied or none of options is satisfied.
%possibleOptions(OutcomeNum, rule, 1..totalNumOfOptsOfRule).

#const totalDiverseOutcomes=totalDiverseOutcomes.


{possibleOptions(C,R,O)}=1:-prules(C,R),O=1..maxNumOfOpts,C=1..totalDiverseOutcomes.

%program begins
prefer(C,R,A,B):-possibleOptions(C,R,A),possibleOptions(C,R,B),prules(C,R),A<B.

%irrSdegree(outcomeNum,rule,1) is true in outcome C if body of rule R is false or none of the options in a rule R is true 
irrSdegree(C,R,1):-not body(C,R),prules(C,R),C=1..totalDiverseOutcomes.
irrSdegree(C,R,1):-{option(C,R,1..maxNumOfOpts)}<1,body(C,R),prules(C,R).


%preferCount(C,R,A,X+1)-> For rule R and outcomeNum C, 'X' number of options are preferred to option A. Then degree(option A)<=(X+1).
preferCount(C,R,A,X+1):-X = #count {O:prefer(C,R,O,A)},A=1..maxNumOfOpts,prules(C,R),C=1..totalDiverseOutcomes.


%sdegree(R,X): Satisfaction degree of rule R = X, if sdegree(R,0) is false.
sdegree(C,R,X):-X=#min {Y:preferCount(C,R,A,Y),option(C,R,A)},prules(C,R),not irrSdegree(C,R,1),C=1..totalDiverseOutcomes.

sdegree(C,R,1):-irrSdegree(C,R,1).
:-not {sdegree(C,R,D): degrees(C,D)}=1, prules(C,R).


#show sdegree/3.
