%prefer(T,R,A,B) -> For LPtree T and rule R, option A is preferred to option B.
%sdegree(R,0):True if body(R) is not satisfied or none of options is satisfied.
%possibleOptions(TreeNumber,ruleNumber,1..totalNumOfOptsOfRule).

{possibleOptions(T,R,O)}=1:-prules(T,R),O=1..2.

%program begins
prefer(T,R,A,B):-possibleOptions(T,R,A),possibleOptions(T,R,B),prules(T,R),A<B.

%irrSdegree(T,R,1) is true if body of rule R in LPTree T is false or none of the options in a rule R of LPTree T is true 
irrSdegree(T,R,1):-not body(T,R),prules(T,R).
irrSdegree(T,R,1):-{option(T,R,1..2)}<1,body(T,R),prules(T,R).


%preferCount(T,R,A,X+1)-> For LPtree T,rule R, 'X' number of options are preferred to option A. Then degree(option A)<=(X+1).
preferCount(T,R,A,X+1):-X = #count {O:prefer(T,R,O,A)},A=1..2,prules(T,R).


%sdegree(R,X): Satisfaction degree of rule R = X, if sdegree(R,0) is false.
sdegree(T,R,X):-X=#min {Y:preferCount(T,R,A,Y),option(T,R,A)},prules(T,R),not irrSdegree(T,R,1).

sdegree(T,R,1):-irrSdegree(T,R,1).
:-not {sdegree(T,R,D): degrees(D)}=1, prules(T,R).
#show sdegree/3.
