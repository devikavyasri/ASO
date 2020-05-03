%prefer(R,A,B) -> For rule1, option A is preferred to option B.
%sdegree(R,0):True if body(R) is not satisfied or none of options is satisfied.
%possibleOptions(rule,1..totalNumOfOptsOfRule).

{possibleOptions(R,O)}=1:-prules(R),O=1..maxNumOfOpts.

%program begins
prefer(R,A,B):-possibleOptions(R,A),possibleOptions(R,B),prules(R),A<B.

%irrSdegree(rule,1) is true if body of rule R is false or none of the options in a rule R is true 
irrSdegree(R,1):-not body(R),prules(R).
irrSdegree(R,1):-{option(R,1..maxNumOfOpts)}<1,body(R),prules(R).


%preferCount(R,A,X+1)-> For rule R, 'X' number of options are preferred to option A. Then degree(option A)<=(X+1).
preferCount(R,A,X+1):-X = #count {O:prefer(R,O,A)},A=1..maxNumOfOpts,prules(R).


%sdegree(R,X): Satisfaction degree of rule R = X, if sdegree(R,0) is false.
sdegree(R,X):-X=#min {Y:preferCount(R,A,Y),option(R,A)},prules(R),not irrSdegree(R,1).

sdegree(R,1):-irrSdegree(R,1).
:-not {sdegree(R,D): degrees(D)}=1, prules(R).


#show sdegree/2.
