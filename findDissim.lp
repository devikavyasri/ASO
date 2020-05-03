%This program is used to create outcome dissimilar to given outcome.


#const distance=distance.

%There should be at least "distance" differences.
distance{differences(1..numOfAtoms)}.

:-differences(A),given(A),answer(A).
:-differences(A),not given(A),not answer(A).
:-not differences(A),not given(A),answer(A).
:-not differences(A),given(A),not answer(A).
