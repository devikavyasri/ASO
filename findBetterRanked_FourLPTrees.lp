%psdegree(T,R,D1) implies previous degree of rule R in LPtree T is D1.
%sdegree(T,R,D2) implies current degree of rule R in LPtree T is D2.

%betterAt(T,L) is true if current degree is less than previous degree for some rule of rank L.
%failAt(T,L) is true if betterAt(T,L) is true and current degree is greater than previous degree for any rule of rank LO <= L.
%inEquality(T,L) is true if current degree is not equal to previous degree for some rule of rank L.
%equality(T,L) is true if current degree is equal to previous degree for all rules of rank L.

%failAt(T,L) is true if equality(T,L) is true and current degree is greater than previous degree for any rule of rank LO <= L.

%betterAt(T) is true if betterAt(T,L) is true and failAt(T,L) is false .
%failAt(T) is true if failAt(T,L) is true.
%failAt(T) is true if betterAt(T) is true and failed at Tree which is preferred to tree T.
%better is true if betterAt(T) is true and failAt(T) is false.


betterAt(T,L):-psdegree(T,R,D1),sdegree(T,R,D2),D1>D2,rank(T,R,L).
failAt(T,L):-betterAt(T,L),psdegree(T,R,D1),sdegree(T,R,D2),D1<D2,rank(T,R,L0),L0<=L.
inEquality(T,L):-psdegree(T,R,D1),sdegree(T,R,D2),D1!=D2,rank(T,R,L).
equality(T,L):-not inEquality(T,L),rank(T,R,L).
failAt(T,L):-equality(T,L0),psdegree(T,R,D1),sdegree(T,R,D2),D1<D2,rank(T,R,L),L0<=L.

betterAt(T):-not failAt(T,L),betterAt(T,L).
failAt(T):- failAt(T,L).
failAt(T):-betterAt(T), failAt(T0),T0<=T.

better:-not failAt(T),betterAt(T).
:-not better.


%*
betterAt(T,L):-psdegree(T,R,D1),sdegree(T,R,D2),D1>D2,rank(T,R,L).
failAt(T,L):-betterAt(T,L),psdegree(T,R,D1),sdegree(T,R,D2),D1<D2,rank(T,R,L0),L0<=L.
failAt(T,L):-betterAt(T,L),psdegree(T1,R,D1),sdegree(T1,R,D2),D1<D2,T1<T.


better:-not failAt(T,L),betterAt(T,L).
:-not better.
*%
:-answer(57),answer(46),answer(58),answer(18),answer(14),answer(23),answer(44),answer(47),answer(51),answer(39),answer(9),answer(35),answer(26),answer(3),answer(53),answer(5),answer(60),answer(52),answer(8),answer(19),answer(28),answer(24),answer(11),answer(37),answer(21),answer(45),answer(43),answer(16),negAnswer(1),negAnswer(2),negAnswer(4),negAnswer(6),negAnswer(7),negAnswer(10),negAnswer(12),negAnswer(13),negAnswer(15),negAnswer(17),negAnswer(20),negAnswer(22),negAnswer(25),negAnswer(27),negAnswer(29),negAnswer(30),negAnswer(31),negAnswer(32),negAnswer(33),negAnswer(34),negAnswer(36),negAnswer(38),negAnswer(40),negAnswer(41),negAnswer(42),negAnswer(48),negAnswer(49),negAnswer(50),negAnswer(54),negAnswer(55),negAnswer(56),negAnswer(59).




#show betterAt/2.
#show failAt/2.
%#show failAt/1.
%#show betterAt/1.
%#show better/0.
