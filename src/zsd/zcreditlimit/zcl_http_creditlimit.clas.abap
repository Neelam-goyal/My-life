class ZCL_HTTP_CREDITLIMIT definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
  CLASS-DATA : user_CustCode TYPE string.
  CLASS-DATA : var1 type I_OperationalAcctgDocItem-Customer.

protected section.

private section.
METHODS:  post_html IMPORTING
                          lv_CustCode       TYPE string
                RETURNING VALUE(html)    TYPE string.


ENDCLASS.



CLASS ZCL_HTTP_CREDITLIMIT IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

  data(req_method) = request->get_method(  ).
  case req_method.
  WHEN conv string( if_web_http_client=>post ).
  data(lv_CustCode) = request->get_form_field( `Customer` ).

  response->set_text( post_html( lv_CustCode = lv_CustCode ) ).
  ENDCASE.
  endmethod.


  METHOD post_html.

    DATA lv_custCode2 TYPE string.
      DATA : VAR1 TYPE i_operationalacctgdocitem-Customer.
       VAR1 = lv_custCode.
       VAR1   = |{ VAR1 ALPHA = IN }|.
       user_CustCode = lv_custCode.
       user_CustCode =  VAR1.
       data : lv_todaydate type cl_abap_context_info=>ty_system_date.
       lv_todaydate = cl_abap_context_info=>get_system_date( ).

       TYPES: BEGIN OF ty_result,
         PostingDate TYPE I_OPERATIONALACCTGDOCITEM-PostingDate,
         TotalAmount TYPE I_OPERATIONALACCTGDOCITEM-AmountInCompanyCodeCurrency,
       END OF ty_result.

       data : i type int4.
       data : totSales type p DECIMALS 3.
       data : custBal type p DECIMALS 3.
       data : pymtRcv type p DECIMALS 3.
       data : minBal type p DECIMALS 3.
       data : currDate type datub.
       Data : lt_collect type table of ty_result,
              ls_collect type ty_result.

       SELECT SINGLE FROM zdealer_tab_new1 WITH PRIVILEGED ACCESS
       FIELDS creditdays,min_bal,min_bal_date,businesspartner
       where businesspartner = @lv_custcode
       into  @data(wa).

    SELECT AmountInCompanyCodeCurrency, PostingDate, Customer
    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
       where
       Customer = @user_CustCode and
       AccountingDocumentType = 'RV'
    INTO TABLE @DATA(it).


       sort it by PostingDate DESCENDING.

         ls_collect-TotalAmount = 0.
         i = 0.
         totSales = 0.


        LOOP AT it INTO data(ls_data).
             if currDate <> ls_data-PostingDate AND ls_data-PostingDate <> lv_todaydate.
                 i += 1.
                 if i > wa-creditdays.
                  EXIT.
                 ENDIF.
                 currDate = ls_data-PostingDate.
               totSales = totSales + ls_data-AmountInCompanyCodeCurrency.
             elseif currDate = ls_data-PostingDate AND ls_data-PostingDate <> lv_todaydate.
              totSales = totSales + ls_data-AmountInCompanyCodeCurrency.
             endif.

          clear : ls_data.
        ENDLOOP.

       SELECT AmountInCompanyCodeCurrency,PostingDate,AccountingDocumentType
       FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
       where Customer = @user_CustCode and PostingDate <= @lv_todaydate
       and SPECIALGLCODE is INITIAL into TABLE @data(it2).
       custBal = 0.
       pymtRcv = 0.

       sort it2 by PostingDate DESCENDING.

        LOOP AT it2 INTO data(ls_data2).
             if  lv_todaydate > ls_data2-PostingDate.
                 custBal = custBal + ls_data2-AmountInCompanyCodeCurrency.
              ELSEIF (  ls_data2-AccountingDocumentType = 'DZ' AND ls_data2-AmountInCompanyCodeCurrency < 0 )
                  OR ( ls_data2-AccountingDocumentType = 'DG' AND ls_data2-AmountInCompanyCodeCurrency < 0 )
                  OR ( ls_data2-AccountingDocumentType = 'SA' AND ls_data2-AmountInCompanyCodeCurrency < 0 )
                  OR ( ls_data2-AccountingDocumentType = 'AB' AND ls_data2-AmountInCompanyCodeCurrency < 0 )
                  OR ( ls_data2-AccountingDocumentType = 'DR' AND ls_data2-AmountInCompanyCodeCurrency < 0 )
                  OR ( ls_data2-AccountingDocumentType = 'CR' AND ls_data2-AmountInCompanyCodeCurrency < 0 )
                  OR ( ls_data2-AccountingDocumentType = 'UE' AND ls_data2-AmountInCompanyCodeCurrency < 0 )
                  OR ( ls_data2-AccountingDocumentType = 'RV' AND ls_data2-AmountInCompanyCodeCurrency < 0 ).
                 pymtRcv = pymtRcv + ls_data2-AmountInCompanyCodeCurrency.
             ENDIF.
         clear : ls_data2.
        ENDLOOP.

        if custBal < wa-min_bal.
           minBal = custBal.
           if minBal < 0.
              minBal = 0.
           ENDIF.
           if wa-min_bal > 0.
               update zdealer_tab_new1
               set min_bal = @minBal
               where businesspartner = @lv_custcode.
           ENDIF.
        ELSE.
           minBal = wa-min_bal.
        ENDIF.

        totSales = totSales - pymtRcv + minBal.
        html =  `{Balance : ` && custBal && `,Limit : ` && totSales && `}`.

  ENDMETHOD.
ENDCLASS.
