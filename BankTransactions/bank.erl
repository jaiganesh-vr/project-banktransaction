-module(bank).
-export ([bank_process/2]).

bank_process(Name,Amount) ->

    Bank_name = Name,
    Bank_loan_amt = Amount,

    receive

      %Performing the checks for the loan request approval
      {Customer_name,Request_amt} ->
        if
          Request_amt =< Bank_loan_amt ->
          main ! {"Approved",Bank_name,Request_amt,Customer_name},
          Customer_name ! {"Approved"},
          bank_process(Bank_name,Bank_loan_amt-Request_amt);
        true ->
          main ! {"Dennied",Bank_name,Request_amt,Customer_name},
          Customer_name ! {"Denied"}
        end,
        bank_process(Bank_name,Bank_loan_amt)

    after 4000 -> main ! {"Closing",Bank_name,Bank_loan_amt}, exit(whereis(Name), ok)

    end.
