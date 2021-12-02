-module(run).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

run(Filename) ->
    Fh = myio:open_file(Filename),
    move_sub(myio:split_line(myio:next_line(Fh)), {0, 0, 0}, Fh).

move_sub(eof, {H, D, _A}, _Fh) ->
    H*D;
move_sub(["forward", N], {H, D, A}, Fh) ->
    Adj = erlang:list_to_integer(N),
    move_sub(myio:split_line(myio:next_line(Fh)),
             {H + Adj, D + (A * Adj), A},
             Fh);
move_sub(["down", N], {H, D, A}, Fh) ->
    move_sub(myio:split_line(myio:next_line(Fh)),
             {H, D, A + erlang:list_to_integer(N)},
             Fh);
move_sub(["up", N], {H, D, A}, Fh) ->
    move_sub(myio:split_line(myio:next_line(Fh)),
             {H, D, A - erlang:list_to_integer(N)},
             Fh).



count_increases([_T1,_T2], _Prev, Tally) ->
    Tally;
count_increases([H1,H2,H3|T], Prev, Tally) when H1+H2+H3 > Prev ->
    count_increases([H2,H3|T], H1+H2+H3, Tally+1);
count_increases([H1,H2,H3|T], _Prev, Tally) ->
    count_increases([H2,H3|T], H1+H2+H3, Tally).
