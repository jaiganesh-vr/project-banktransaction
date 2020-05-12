-module(money).
-export([start/0,main_process/1]).

start() ->
  %Reading the customers input data
  {ok,Customers} = file:consult("customers.txt"),
  io:fwrite("** Customers and loan objectives **~n"),
  print(Customers),
  %Reading the banks input data
  {ok,Banks} = file:consult("banks.txt"),
  io:fwrite("** Banks and financial resources **~n"),
  print(Banks),

  Empty_list = [],
  %Registering the main process
  register(main, spawn(money, main_process, [Empty_list])),
  bank_creation(Banks),
  customer_creation(Customers).
  %Process creating and registration for banks
  bank_creation([]) -> ok;
  bank_creation([Head|Tail]) ->
      {Name,Amount} = Head,
      register(Name,spawn(bank, bank_process, [Name,Amount])),
      bank_creation(Tail).
  %Process creation and registration for customers
  customer_creation ([]) -> ok;
  customer_creation([Head|Tail]) ->
      {Name,Amount} = Head,
      {ok,Banks} = file:consult("banks.txt"),
      Banklist = lists:map(fun ({V, _}) -> V end, Banks),
      register(Name,spawn(customer, customer_process, [Name,Amount,Amount,Banklist])),
      customer_creation(Tail).
  %Printing the input data
  print([])->[];
  print([Head|Tail]) ->
  	{Name,Amount} = Head,
  	io:fwrite("~p:~p~n",[Name,Amount]),
  	print(Tail).

main_process(Final_List) ->

  Final_status = Final_List,

  receive
    %Printing the respective messages from the customers and the banks
    {"Achieved",Name,Amount_orig} ->
    List = lists:flatten(io_lib:format("~s has reached the objective of ~p dollar(s). Woo Hoo !",[Name,Amount_orig])),
    main_process(lists:append(Final_status,[List]));

    {"Pending",Name,Amount} ->
    List = lists:flatten(io_lib:format("~s was only able to borrow ~p dollar(s). Boo Hoo !",[Name,Amount])),
    main_process(lists:append(Final_status,[List]));

    {"Closing",Name,Amount} ->
    List = lists:flatten(io_lib:format("~s has ~p dollar(s) remaining.",[Name,Amount])),
    main_process(lists:append(Final_status,[List]));

    {"Requesting",Cus_name,Request_amt,Request_bank} ->
    io:fwrite("~s requests a loan of ~p dollar(s) from ~s.~n",[Cus_name,Request_amt,Request_bank]),
    main_process(Final_status);

    {"Approved",Bank_name,Request_amt,Customer_name} ->
    io:fwrite("~s approves a loan of ~p dollar(s) from ~s.~n",[Bank_name,Request_amt,Customer_name]),
    main_process(Final_status);

    {"Dennied",Bank_name,Request_amt,Customer_name} ->
    io:fwrite("~s denies a loan of ~p dollar(s) from ~s.~n",[Bank_name,Request_amt,Customer_name]),
    main_process(Final_status)

  after 5000 ->   io:fwrite("~n~n"), final_print(Final_status)

	end.

final_print([]) -> [];
final_print([Head|Tail]) ->
  io:fwrite("~s~n",[Head]),
  final_print(Tail).
