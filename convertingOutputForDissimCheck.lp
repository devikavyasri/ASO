%Modifying format of given answer set

#const outcome=outcome.

answer(outcome,A) :- answer(A).
negAnswer(outcome,A) :- negAnswer(A).

#show answer/2.
#show negAnswer/2.
