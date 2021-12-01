-module(run).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

run() ->
    Ints = myio:all_integers("input.txt"),
    count_increases(Ints, 10000000, 0).

count_increases([_T1,_T2], _Prev, Tally) ->
    Tally;
count_increases([H1,H2,H3|T], Prev, Tally) when H1+H2+H3 > Prev ->
    count_increases([H2,H3|T], H1+H2+H3, Tally+1);
count_increases([H1,H2,H3|T], _Prev, Tally) ->
    count_increases([H2,H3|T], H1+H2+H3, Tally).
