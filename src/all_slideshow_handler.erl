-module(all_slideshow_handler).
-author("tapanp@koderoom.com").

-export([init/3]).

-export([content_types_provided/2]).
-export([welcome/2]).
-export([terminate/3]).

%% Init
init(_Transport, _Req, []) ->
	{upgrade, protocol, cowboy_rest}.

%% Callbacks
content_types_provided(Req, State) ->
	{[		
		{<<"text/html">>, welcome}	
	], Req, State}.

terminate(_Reason, _Req, _State) ->
	ok.

%% API
welcome(Req, State) ->
	Url_Top_News 					= infohealthhub_util:news_top_text_news_with_limit_and_skip("6","0"),
	{ok, "200", _, Response_Top_News} = ibrowse:send_req(Url_Top_News,[],get,[],[]),
	Res_Top_News = string:sub_string(Response_Top_News, 1, string:len(Response_Top_News) -1 ),
	[{<<"total_rows">>,_},{<<"offset">>,_},{<<"rows">>,Params1}] = jsx:decode(list_to_binary(Res_Top_News)),

	Url = infohealthhub_util:news_slideshow_url("100"),
	{ok, "200", _, Response} = ibrowse:send_req(Url,[],get,[],[]),
	Res = string:sub_string(Response, 1, string:len(Response) -1 ),
	[{<<"total_rows">>,_},{<<"offset">>,_},{<<"rows">>,Params}] = jsx:decode(list_to_binary(Res)),
	%io:format("params ~p ~n",[Params]),
	{ok, Body} = slideshow_all_dtl:render([{<<"news">>,Params1},{<<"params">>,Params}]),
    {Body, Req, State}.
