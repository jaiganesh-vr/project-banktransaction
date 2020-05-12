-module(customer).
-export ([customer_process/4]).

customer_process(Name,Amount_orig,Amount_loan,Banklist) ->

    if
      Amount_loan == 0 ->
      main ! {"Achieved",Name,Amount_orig}, exit(whereis(Name), ok);
    true ->
      io:fwrite("")
    end,

    if
      Banklist == [] ->
      main ! {"Pending",Name,Amount_orig-Amount_loan}, exit(whereis(Name), ok);
    true ->
      io:fwrite("")
    end,

    Cus_name = Name,
    Cus_orig_amt = Amount_orig,
    Cus_loan_amt = Amount_loan,
    Cus_aval_bank = Banklist,
    
    Random_no = rand:uniform(length(Cus_aval_bank)),
    Request_bank = lists:nth(Random_no,Cus_aval_bank),

    if
      Cus_loan_amt > 50 ->  Request_amt = rand:uniform(50);
    true ->
        Request_amt = rand:uniform(Cus_loan_amt)
    end,

    main ! {"Requesting",Cus_name,Request_amt,Request_bank},
    timer:sleep(1),
    %Requesting the bank for the loan
    Request_bank ! {Cus_name,Request_amt},

    receive
      {Msg} ->
        if
           Msg == "Approved" ->
           customer_process(Cus_name,Cus_orig_amt,Cus_loan_amt-Request_amt,Banklist);
        true ->
           customer_process(Cus_name,Cus_orig_amt,Cus_loan_amt,lists:delete(Request_bank,Banklist))
        end

    end.
