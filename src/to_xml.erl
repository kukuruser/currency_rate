-module(to_xml).

-export([to_xml/1]).

-define(RowTemplate, <<"<row><exchangerate ccy=\"MASKCCY\" base_ccy=\"MASKBASE_CCY\" buy=\"MASKBUY\" sale=\"MASKSALE\"/></row>">>).

to_xml(H) ->
  ConvertedMap = map2xml(H),
  <<"<exchangerates>", ConvertedMap/binary, "</exchangerates>">>.

map2xml([H|[]]) ->
  map2xml(H);

map2xml([H|T]) ->
  A = map2xml(H),
  B = map2xml(T),
  <<A/binary, B/binary>>;

map2xml(H) ->
  REPLACED_MASKCCY = binary:replace(?RowTemplate, <<"MASKCCY">>, maps:get(<<"ccy">>, H)),
  REPLACED_MASKBASE_CCY = binary:replace(REPLACED_MASKCCY,<<"MASKBASE_CCY">>,maps:get(<<"base_ccy">>, H)),
  REPLACED_MASKBUY = binary:replace(REPLACED_MASKBASE_CCY,<<"MASKBUY">>,maps:get(<<"buy">>, H)),
  binary:replace(REPLACED_MASKBUY,<<"MASKSALE">>,maps:get(<<"sale">>, H)).
