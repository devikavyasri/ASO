%Differences between two outcomes should be of given distance

#const distance=distance.
#const totalOutcomes=totalOutcomes.
distance{differences(O,1..numOfAtoms)}:-O=1..totalOutcomes.


:-differences(O,A),answer(O,A),answer(A),O=1..totalOutcomes.
:-differences(O,A),not answer(O,A),not answer(A),O=1..totalOutcomes.
:-not differences(O,A),not answer(O,A),answer(A),O=1..totalOutcomes.
:-not differences(O,A),answer(O,A),not answer(A),O=1..totalOutcomes.
