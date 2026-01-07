CLASS zcl_suppliertrial DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SUPPLIERTRIAL IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF ZSupplier_Trial,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

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
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          lv_msg = lo_error->get_text( ).
      ENDTRY.

      LOOP AT lt_parameter ASSIGNING FIELD-SYMBOL(<fs_p>).
        CASE <fs_p>-parameter_name.
          WHEN 'P_FROMDATE'.   DATA(p_fromdate) = <fs_p>-value.
          WHEN 'P_TODATE'.   DATA(p_todate) = <fs_p>-value.
        ENDCASE.
      ENDLOOP.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'VENDORCODE'.
          DATA(lt_vendorcode) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'SUPPLIERACCOUNTGROUP'.
          DATA(lt_supplieraccountgroup) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'REGION'.
          DATA(lt_region) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_bukrs) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.

*get basic information
      SELECT cc~CompanyCode, sup~Supplier, sup~SupplierName, sup~SupplierAccountGroup, sup~Region
      FROM I_Supplier AS sup
        INNER JOIN I_SupplierCompany AS cc ON sup~Supplier = cc~Supplier
      WHERE sup~Supplier IN @lt_vendorcode
      AND sup~SupplierAccountGroup IN @lt_supplieraccountgroup
      AND sup~Region IN @lt_region
      AND cc~CompanyCode IN  @lt_bukrs
      INTO TABLE @DATA(lt_supplier).

      LOOP AT lt_supplier INTO DATA(ls_supplier).
        ls_response-companycode = ls_supplier-CompanyCode.
        ls_response-vendorcode = ls_supplier-Supplier.
        ls_response-supplieraccountgroup = ls_supplier-SupplierAccountGroup.
        ls_response-region = ls_supplier-Region.
        ls_response-vendorname = ls_supplier-SupplierName.

* Opening Balance
****        SELECT SUM( AmountInCompanyCodeCurrency )
****          FROM I_OperationalAcctgDocItem
****          WHERE CompanyCode = @ls_supplier-CompanyCode
****            AND Supplier = @ls_supplier-Supplier
****            AND PostingDate < @p_fromdate
****          INTO @ls_response-openingbalance.
        SELECT SINGLE SUM( AmountInCompanyCodeCurrency ) FROM I_OperationalAcctgDocItem
        WHERE CompanyCode = @ls_supplier-CompanyCode
        AND Supplier = @ls_supplier-Supplier
        AND PostingDate < @p_fromdate
        INTO @DATA(lv_openingbal) PRIVILEGED ACCESS.

        ls_response-openingbalance = lv_openingbal.

****
***** Debit Balance
****        SELECT SUM( AmountInCompanyCodeCurrency )
****          FROM I_OperationalAcctgDocItem
****          WHERE CompanyCode = @ls_supplier-CompanyCode
****            AND Supplier = @ls_supplier-Supplier
****            AND PostingDate >= @p_fromdate
****            AND PostingDate <= @p_todate
****            AND AmountInCompanyCodeCurrency > 0
****          INTO @ls_response-debitbalance.

        SELECT SINGLE SUM( AmountInCompanyCodeCurrency ) FROM I_OperationalAcctgDocItem
        WHERE CompanyCode = @ls_supplier-CompanyCode
        AND Supplier = @ls_supplier-Supplier
        AND PostingDate >= @p_fromdate AND PostingDate <= @p_todate
        AND AmountInCompanyCodeCurrency > 0
        INTO @DATA(lv_debitbal) PRIVILEGED ACCESS.
        ls_response-debitbalance = lv_debitbal.



****
***** Credit Balance
****        SELECT SUM( - AmountInCompanyCodeCurrency )
****          FROM I_OperationalAcctgDocItem
****          WHERE CompanyCode = @ls_supplier-CompanyCode
****            AND Supplier = @ls_supplier-Supplier
****            AND PostingDate >= @p_fromdate
****            AND PostingDate <= @p_todate
****            AND AmountInCompanyCodeCurrency < 0
****          INTO @ls_response-creditbalance.

        SELECT SINGLE SUM( AmountInCompanyCodeCurrency ) FROM I_OperationalAcctgDocItem
        WHERE CompanyCode = @ls_supplier-CompanyCode
        AND Supplier = @ls_supplier-Supplier
        AND PostingDate >= @p_fromdate AND PostingDate <= @p_todate
        AND AmountInCompanyCodeCurrency < 0
        INTO @DATA(lv_creditbal) PRIVILEGED ACCESS.
        ls_response-creditbalance = ( lv_creditbal * -1 ) .
****
***** Closing Balance
****        SELECT SUM( AmountInCompanyCodeCurrency )
****          FROM I_OperationalAcctgDocItem
****          WHERE CompanyCode = @ls_supplier-CompanyCode
****            AND Supplier = @ls_supplier-Supplier
****            AND PostingDate <= @p_todate
****          INTO @ls_response-closingbalance.

        SELECT SINGLE SUM( AmountInCompanyCodeCurrency ) FROM I_OperationalAcctgDocItem
        WHERE CompanyCode = @ls_supplier-CompanyCode
        AND Supplier = @ls_supplier-Supplier
        AND PostingDate <= @p_todate
        INTO @DATA(lv_closingbal) PRIVILEGED ACCESS.
        ls_response-closingbalance = lv_closingbal.

****        COLLECT ls_response INTO lt_response.
        APPEND ls_response TO lt_response.
        CLEAR : ls_response, lv_openingbal, lv_debitbal, lv_creditbal, lv_closingbal.
      ENDLOOP.

      SORT lt_response BY companycode vendorcode. "supplieraccountgroup region
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
