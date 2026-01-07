CLASS zcl_customertrial DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CUSTOMERTRIAL IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).
      TYPES BEGIN OF ty_value.
      TYPES: quantity TYPE i_stockquantitycurrentvalue_2-matlwrhsstkqtyinmatlbaseunit,
             value    TYPE i_stockquantitycurrentvalue_2-stockvalueindisplaycurrency.
      TYPES END OF ty_value.


      DATA: lt_response    TYPE TABLE OF ZCustomer_Trial,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout,
            lt_value       TYPE TABLE OF ty_value,
            ls_value       TYPE ty_value,
            lv_price       TYPE p DECIMALS 2,
            openingvalue   TYPE p DECIMALS 2,
            closingvalue   TYPE p DECIMALS 2,
            calcvalue      TYPE p DECIMALS 2.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      TRY.
          DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lo_error).
          DATA(lv_msg) = lo_error->get_text( ).
      ENDTRY.
      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO lo_error.
          lv_msg = lo_error->get_text( ).
      ENDTRY.

      LOOP AT lt_parameter ASSIGNING FIELD-SYMBOL(<fs_p>).
        CASE <fs_p>-parameter_name.
          WHEN 'P_FROMDATE'.   DATA(p_fromdate) = <fs_p>-value.
          WHEN 'P_TODATE'.   DATA(p_todate) = <fs_p>-value.
        ENDCASE.
      ENDLOOP.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'CUSTOMERCODE'.
          DATA(lt_customercode) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'CUSTOMERACCOUNTGROUP'.
          DATA(lt_customeraccountgroup) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'REGION'.
          DATA(lt_region) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'DISTRICTNAME'.
          DATA(lt_districtname) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_bukrs) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.

*get basic information
      SELECT cc~CompanyCode, cust~Customer, cust~CustomerName, cust~CustomerAccountGroup, cust~Region, cust~DistrictName
      FROM I_Customer AS cust
        INNER JOIN I_CustomerCompany AS cc ON cust~Customer = cc~Customer
      WHERE cust~Customer IN @lt_customercode
      AND cust~CustomerAccountGroup IN @lt_customeraccountgroup
      AND cust~Region IN @lt_region
      and cust~DistrictName in @lt_districtname
      AND cc~CompanyCode IN  @lt_bukrs
      INTO TABLE @DATA(lt_customer).

      LOOP AT lt_customer INTO DATA(ls_customer).
        ls_response-companycode = ls_customer-CompanyCode.
        ls_response-customercode = ls_customer-Customer.
        ls_response-customeraccountgroup = ls_customer-CustomerAccountGroup.
        ls_response-region = ls_customer-Region.
        ls_response-districtname = ls_customer-DistrictName.
        ls_response-customername = ls_customer-CustomerName.

        openingvalue = 0.
        closingvalue = 0.
        calcvalue = 0.

* Opening Balance
*        SELECT SUM( AmountInCompanyCodeCurrency )
*          FROM I_OperationalAcctgDocItem
*          WHERE CompanyCode = @ls_customer-CompanyCode
*            AND Customer = @ls_customer-Customer
*            AND PostingDate < @p_fromdate
*            AND AccountingDocumentType NOT IN ('WL', 'AB', 'DZ')
*          INTO @calcvalue.
*        openingvalue = openingvalue + calcvalue.

*        SELECT SUM( NetPaymentAmount )
*          FROM I_OperationalAcctgDocItem
*          WHERE CompanyCode = @ls_customer-CompanyCode
*            AND Customer = @ls_customer-Customer
*            AND PostingDate < @p_fromdate
*            AND AccountingDocumentType = 'DZ'
*          INTO @calcvalue.
*        openingvalue = openingvalue + calcvalue.
*        ls_response-openingbalance = openingvalue.

*       UE - Adjustments
*        SELECT SUM( AmountInCompanyCodeCurrency )
*          FROM I_OperationalAcctgDocItem
*          WHERE CompanyCode = @ls_customer-CompanyCode
*            AND Customer = @ls_customer-Customer
*            AND PostingDate >= @p_fromdate
*            AND PostingDate <= @p_todate
*            AND AccountingDocumentType = 'UE'
*          INTO @ls_response-AdjustmentDrCr.

*       RV - Billing
*        SELECT SUM( AmountInCompanyCodeCurrency )
*          FROM I_OperationalAcctgDocItem
*          WHERE CompanyCode = @ls_customer-CompanyCode
*            AND Customer = @ls_customer-Customer
*            AND PostingDate >= @p_fromdate
*            AND PostingDate <= @p_todate
*            AND AccountingDocumentType = 'RV'
*          INTO @ls_response-BillingDr.

*       DR - Direct Invoice
*        SELECT SUM( AmountInCompanyCodeCurrency )
*          FROM I_OperationalAcctgDocItem
*          WHERE CompanyCode = @ls_customer-CompanyCode
*            AND Customer = @ls_customer-Customer
*            AND PostingDate >= @p_fromdate
*            AND PostingDate <= @p_todate
*            AND AccountingDocumentType = 'DR'
*          INTO @ls_response-DirectInvoiceDr.

*       DG - Billing
*        SELECT SUM( AmountInCompanyCodeCurrency )
*          FROM I_OperationalAcctgDocItem
*          WHERE CompanyCode = @ls_customer-CompanyCode
*            AND Customer = @ls_customer-Customer
*            AND PostingDate >= @p_fromdate
*            AND PostingDate <= @p_todate
*            AND AccountingDocumentType = 'DG'
*          INTO @ls_response-CreditMemoCr.

*       DZ - Credit
*        SELECT SUM( NetPaymentAmount )
*          FROM I_OperationalAcctgDocItem
*          WHERE CompanyCode = @ls_customer-CompanyCode
*            AND Customer = @ls_customer-Customer
*            AND PostingDate >= @p_fromdate
*            AND PostingDate <= @p_todate
*            AND AccountingDocumentType = 'DZ'
*            AND NetPaymentAmount < 0
*          INTO @ls_response-PaymentCr.

*       DZ - Debit
*        SELECT SUM( NetPaymentAmount )
*          FROM I_OperationalAcctgDocItem
*          WHERE CompanyCode = @ls_customer-CompanyCode
*            AND Customer = @ls_customer-Customer
*            AND PostingDate >= @p_fromdate
*            AND PostingDate <= @p_todate
*            AND AccountingDocumentType = 'DZ'
*            AND NetPaymentAmount > 0
*          INTO @ls_response-PaymentDr.

*        ls_response-debitbalance = ls_response-AdjustmentDrCr + ls_response-BillingDr + ls_response-DirectInvoiceDr + ls_response-PaymentDr.
*        ls_response-creditbalance = ls_response-CreditMemoCr + ls_response-PaymentCr + ls_response-AdvanceAmountCr.


* Closing Balance
*        SELECT SUM( AmountInCompanyCodeCurrency )
*          FROM I_OperationalAcctgDocItem
*          WHERE CompanyCode = @ls_customer-CompanyCode
*            AND Customer = @ls_customer-Customer
*            AND PostingDate <= @p_todate
*            AND AccountingDocumentType NOT IN ('WL', 'AB', 'DZ')
*          INTO @calcvalue.
*        closingvalue = closingvalue + calcvalue.

*        SELECT SUM( NetPaymentAmount )
*          FROM I_OperationalAcctgDocItem
*          WHERE CompanyCode = @ls_customer-CompanyCode
*            AND Customer = @ls_customer-Customer
*            AND PostingDate <= @p_todate
*            AND AccountingDocumentType = 'DZ'
*          INTO @calcvalue.
*        closingvalue = closingvalue + calcvalue.
*        ls_response-closingbalance = closingvalue.


        COLLECT ls_response INTO lt_response.
        CLEAR ls_customer.
      ENDLOOP.


* Opening Value
      SELECT a~Customer, a~CompanyCode, SUM( a~AmountInCompanyCodeCurrency ) AS Amount
        FROM I_OperationalAcctgDocItem AS a
        INNER JOIN @lt_response AS b ON a~CompanyCode = b~companycode AND a~Customer = b~customercode
      WHERE a~PostingDate < @p_fromdate
      AND a~AccountingDocumentType NOT IN ('WL', 'AB', 'DZ')
      GROUP BY a~Customer, a~CompanyCode
      INTO TABLE @DATA(lt_calculate).

      DATA: ls_calculate LIKE LINE OF lt_calculate.

      LOOP AT lt_response INTO ls_response.
        READ TABLE lt_calculate WITH KEY Companycode = ls_response-Companycode
                                         Customer = ls_response-customercode
                                    INTO ls_calculate.
        IF sy-subrc = 0.
          ls_response-openingbalance = ls_response-openingbalance + ls_calculate-Amount.
          MODIFY lt_response FROM ls_response.
          CLEAR ls_response.
        ENDIF.
      ENDLOOP.

      CLEAR lt_calculate.
      SELECT a~Customer, a~CompanyCode, SUM( a~NetPaymentAmount ) AS Amount
        FROM I_OperationalAcctgDocItem AS a
        INNER JOIN @lt_response AS b ON a~CompanyCode = b~companycode AND a~Customer = b~customercode
      WHERE a~PostingDate < @p_fromdate
      AND a~AccountingDocumentType = 'DZ'
      GROUP BY a~Customer, a~CompanyCode
      INTO TABLE @lt_calculate.

      LOOP AT lt_response INTO ls_response.
        READ TABLE lt_calculate WITH KEY Companycode = ls_response-Companycode
                                         Customer = ls_response-customercode
                                    INTO ls_calculate.
        IF sy-subrc = 0.
          ls_response-openingbalance = ls_response-openingbalance + ls_calculate-Amount.
          MODIFY lt_response FROM ls_response.
          CLEAR ls_response.
        ENDIF.
      ENDLOOP.

* Periodic Transactions
*     UE - Adjustments
      CLEAR lt_calculate.
      SELECT a~Customer, a~CompanyCode, SUM( a~AmountInCompanyCodeCurrency ) AS Amount
        FROM I_OperationalAcctgDocItem AS a
        INNER JOIN @lt_response AS b ON a~CompanyCode = b~companycode AND a~Customer = b~customercode
      WHERE PostingDate >= @p_fromdate
            AND PostingDate <= @p_todate
            AND AccountingDocumentType = 'UE'
      GROUP BY a~Customer, a~CompanyCode
      INTO TABLE @lt_calculate.

      LOOP AT lt_response INTO ls_response.
        READ TABLE lt_calculate WITH KEY Companycode = ls_response-Companycode
                                         Customer = ls_response-customercode
                                    INTO ls_calculate.
        IF sy-subrc = 0.
          ls_response-AdjustmentDrCr = ls_response-AdjustmentDrCr + ls_calculate-Amount.
          MODIFY lt_response FROM ls_response.
          CLEAR ls_response.
        ENDIF.
      ENDLOOP.

*     RV - Billing
      CLEAR lt_calculate.
      SELECT a~Customer, a~CompanyCode, SUM( a~AmountInCompanyCodeCurrency ) AS Amount
        FROM I_OperationalAcctgDocItem AS a
        INNER JOIN @lt_response AS b ON a~CompanyCode = b~companycode AND a~Customer = b~customercode
      WHERE PostingDate >= @p_fromdate
            AND PostingDate <= @p_todate
            AND AccountingDocumentType = 'RV'
      GROUP BY a~Customer, a~CompanyCode
      INTO TABLE @lt_calculate.

      LOOP AT lt_response INTO ls_response.
        READ TABLE lt_calculate WITH KEY Companycode = ls_response-Companycode
                                         Customer = ls_response-customercode
                                    INTO ls_calculate.
        IF sy-subrc = 0.
          ls_response-BillingDr = ls_response-BillingDr + ls_calculate-Amount.
          MODIFY lt_response FROM ls_response.
          CLEAR ls_response.
        ENDIF.
      ENDLOOP.


*     DR - Direct Invoice
      CLEAR lt_calculate.
      SELECT a~Customer, a~CompanyCode, SUM( a~AmountInCompanyCodeCurrency ) AS Amount
        FROM I_OperationalAcctgDocItem AS a
        INNER JOIN @lt_response AS b ON a~CompanyCode = b~companycode AND a~Customer = b~customercode
      WHERE PostingDate >= @p_fromdate
            AND PostingDate <= @p_todate
            AND AccountingDocumentType = 'DR'
      GROUP BY a~Customer, a~CompanyCode
      INTO TABLE @lt_calculate.

      LOOP AT lt_response INTO ls_response.
        READ TABLE lt_calculate WITH KEY Companycode = ls_response-Companycode
                                         Customer = ls_response-customercode
                                    INTO ls_calculate.
        IF sy-subrc = 0.
          ls_response-DirectInvoiceDr = ls_response-DirectInvoiceDr + ls_calculate-Amount.
          MODIFY lt_response FROM ls_response.
          CLEAR ls_response.
        ENDIF.
      ENDLOOP.

*     DG - Billing
      CLEAR lt_calculate.
      SELECT a~Customer, a~CompanyCode, SUM( a~AmountInCompanyCodeCurrency ) AS Amount
        FROM I_OperationalAcctgDocItem AS a
        INNER JOIN @lt_response AS b ON a~CompanyCode = b~companycode AND a~Customer = b~customercode
      WHERE PostingDate >= @p_fromdate
            AND PostingDate <= @p_todate
            AND AccountingDocumentType = 'DG'
      GROUP BY a~Customer, a~CompanyCode
      INTO TABLE @lt_calculate.

      LOOP AT lt_response INTO ls_response.
        READ TABLE lt_calculate WITH KEY Companycode = ls_response-Companycode
                                         Customer = ls_response-customercode
                                    INTO ls_calculate.
        IF sy-subrc = 0.
          ls_response-CreditMemoCr = ls_response-CreditMemoCr + ls_calculate-Amount.
          MODIFY lt_response FROM ls_response.
          CLEAR ls_response.
        ENDIF.
      ENDLOOP.


*     DZ - Credit
      CLEAR lt_calculate.
      SELECT a~Customer, a~CompanyCode, SUM( a~NetPaymentAmount ) AS Amount
        FROM I_OperationalAcctgDocItem AS a
        INNER JOIN @lt_response AS b ON a~CompanyCode = b~companycode AND a~Customer = b~customercode
      WHERE PostingDate >= @p_fromdate
            AND PostingDate <= @p_todate
            AND AccountingDocumentType = 'DZ'
            AND NetPaymentAmount < 0
      GROUP BY a~Customer, a~CompanyCode
      INTO TABLE @lt_calculate.

      LOOP AT lt_response INTO ls_response.
        READ TABLE lt_calculate WITH KEY Companycode = ls_response-Companycode
                                         Customer = ls_response-customercode
                                    INTO ls_calculate.
        IF sy-subrc = 0.
          ls_response-PaymentCr = ls_response-PaymentCr + ls_calculate-Amount.
          MODIFY lt_response FROM ls_response.
          CLEAR ls_response.
        ENDIF.
      ENDLOOP.


*     DZ - Debit
      CLEAR lt_calculate.
      SELECT a~Customer, a~CompanyCode, SUM( a~NetPaymentAmount ) AS Amount
        FROM I_OperationalAcctgDocItem AS a
        INNER JOIN @lt_response AS b ON a~CompanyCode = b~companycode AND a~Customer = b~customercode
      WHERE PostingDate >= @p_fromdate
            AND PostingDate <= @p_todate
            AND AccountingDocumentType = 'DZ'
            AND NetPaymentAmount > 0
      GROUP BY a~Customer, a~CompanyCode
      INTO TABLE @lt_calculate.

      LOOP AT lt_response INTO ls_response.
        READ TABLE lt_calculate WITH KEY Companycode = ls_response-Companycode
                                         Customer = ls_response-customercode
                                    INTO ls_calculate.
        IF sy-subrc = 0.
          ls_response-PaymentDr = ls_response-PaymentDr + ls_calculate-Amount.
          MODIFY lt_response FROM ls_response.
          CLEAR ls_response.
        ENDIF.
      ENDLOOP.

* Closing Balance & Debit/Credit Transaction
      LOOP AT lt_response INTO ls_response.
        ls_response-debitbalance = ls_response-AdjustmentDrCr + ls_response-BillingDr + ls_response-DirectInvoiceDr + ls_response-PaymentDr.
        ls_response-creditbalance = ls_response-CreditMemoCr + ls_response-PaymentCr + ls_response-AdvanceAmountCr.
        ls_response-closingbalance = ls_response-openingbalance + ls_response-debitbalance + ls_response-creditbalance.
        MODIFY lt_response FROM ls_response.
        CLEAR ls_response.
      ENDLOOP.



*paging way to return huge amount of data
      SORT lt_response BY companycode customeraccountgroup region.
      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

      CLEAR lt_responseout.
      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
        ls_responseout = <lfs_out_line_item>.
        APPEND ls_responseout TO lt_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).


    ENDIF.
  ENDMETHOD.
ENDCLASS.
