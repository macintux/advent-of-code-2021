-module(run).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

run() ->
    Ints = myio:all_integers("input.txt"),
    count_increases(Ints, 10000000, 0).

count_increases([], _Prev, Tally) ->
    Tally;
count_increases([H|T], Prev, Tally) when H > Prev ->
    count_increases(T, H, Tally+1);
count_increases([H|T], _Prev, Tally) ->
    count_increases(T, H, Tally).
