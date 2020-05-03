%This program is used to create outcome similar to given outcome.

#const distance=distance.

%There should be at most "distance" differences.
{differences(1..numOfAtoms)}distance.

:-differences(A),given(A),answer(A).
:-differences(A),not given(A),not answer(A).
:-not differences(A),not given(A),answer(A).
:-not differences(A),given(A),not answer(A).
