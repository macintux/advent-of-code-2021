-module(myio).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

open_file(Filename) ->
    {ok, Fh} = file:open(Filename, [read]),
    Fh.

%% Time to make some smarter utility functions. For day 4 2020 I need
%% a way to convert a file to a sequence of maps.
file_to_maps(File) ->
    file_to_maps(File, ":").

%% Separator is internal to key/value pairs. If we end up with
%% something other than whitespace separating the pairs themselves,
%% will have to extend this.
file_to_maps({ok, Fh}, Separator) ->
    file_to_maps(next_line(Fh), Fh, #{}, [], Separator);
file_to_maps(Filename, Separator) ->
    file_to_maps(file:open(Filename, [read]), Separator).

str_to_kv_fold(KV, M, Separator) ->
    [K, V] = string:split(KV, Separator),
    M#{K => V}.

file_to_maps(eof, _Fh, Map, Accum, _Separator) ->
    [Map|Accum];
file_to_maps(Line, Fh, Map, Accum, Separator) when length(Line) == 0 ->
    file_to_maps(next_line(Fh), Fh, #{}, [Map|Accum], Separator);
file_to_maps(Line, Fh, Map, Accum, Separator) ->
    KVs = string:split(Line, " ", all),
    file_to_maps(next_line(Fh), Fh,
                 lists:foldl(fun(KV, M) -> str_to_kv_fold(KV, M, Separator) end,
                             Map, KVs),
                 Accum, Separator).

%% fold_file folds across each line in the file character by
%% character; sometimes you want to process the lines as a unit.
fold_lines(Fun, Acc, Filename) ->
    Fh = open_file(Filename),
    InputFun = fun next_line/1,
    real_fold_lines(Fun, Acc, InputFun(Fh), Fh, InputFun).

real_fold_lines(_Fun, Acc, eof, _Fh, _InputFun) ->
    Acc;
real_fold_lines(Fun, Acc, Input, Fh, InputFun) ->
    real_fold_lines(Fun, Fun(Input, Acc), InputFun(Fh), Fh, InputFun).

all_integers(Filename) ->
    lists:reverse(fold_file(fun(X, Acc) -> [X|Acc] end, [], Filename)).

fold_file(Fun, Acc, Filename) ->
    fold_file(Fun, Acc, Filename, fun grab_line/1).

fold_file(Fun, Acc, Filename, InputFun) ->
    Fh = {fh, open_file(Filename)},
    real_fold_file(Fun, Acc, InputFun(Fh), Fh, InputFun).

real_fold_file(_Fun, Acc, eof, _Fh, _InputFun) ->
    Acc;
real_fold_file(Fun, Acc, Input, Fh, InputFun) ->
    real_fold_file(Fun, lists:foldl(Fun, Acc, Input), InputFun(Fh), Fh, InputFun).

grab_records(InputFun, SplitFun, RecordFun) ->
    next_record(SplitFun(InputFun()), {InputFun, SplitFun, RecordFun}, []).

next_record(eof, {_, _, _}, Accum) ->
    lists:reverse(Accum);
next_record(Array, {I, S, R}, Accum) ->
    next_record(S(I()), {I, S, R}, [R(Array)|Accum]).

grab_line({fh, Fh}) ->
    grab_line(fun() -> next_line(Fh) end, fun split_line/1, fun erlang:list_to_integer/1).

grab_line() ->
    grab_line(fun next_line/0, fun split_line/1, fun erlang:list_to_integer/1).

grab_line(InputFun, SplitFun, ConvertFun) ->
    NextLine = SplitFun(InputFun()),
    case NextLine of
        eof ->
            eof;
        _ ->
            lists:map(ConvertFun, NextLine)
    end.

split_line(eof) ->
    eof;
split_line(Line) ->
    split_line(Line, "\t ,").

split_line(Line, Delim) ->
    string:tokens(Line, Delim).

next_line() ->
    chomp(io:get_line("")).

next_line({fh, Fh}) ->
    next_line(Fh);
next_line(Fh) ->
    chomp(io:get_line(Fh, "")).

chomp(eof) ->
    eof;
chomp(String) ->
    maybe_chomp(string:tokens(String, "\r\n")).

maybe_chomp([]) ->
    [];
maybe_chomp([Line | _Leftover]) ->
    Line.

%%%%%% Unit tests

chomp_noop_test() ->
    "   foo " == chomp("   foo ").

chomp_eol_test() ->
    "   foo " == chomp("   foo \n").

chomp_eol2_test() ->
    "   foo " == chomp("   foo \r\n").

chomp_multi_test() ->
    " " == chomp(" \n foo \r").

chomp_begin_eol_test() ->
    " foo" == chomp("\n foo").
