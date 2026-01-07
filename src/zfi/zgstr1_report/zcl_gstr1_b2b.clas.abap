CLASS zcl_gstr1_b2b DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GSTR1_B2B IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zgstr1_ce,
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

*      LOOP AT lt_parameter ASSIGNING FIELD-SYMBOL(<fs_p>).
*        CASE <fs_p>-parameter_name.
*          WHEN 'P_FROMDATE'.   DATA(p_fromdate) = <fs_p>-value.
*          WHEN 'P_TODATE'.   DATA(p_todate) = <fs_p>-value.
*        ENDCASE.
*      ENDLOOP.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'CUSTOMERCODE'.
          DATA(lt_customercode) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'FISCALYEARVALUE'.
          DATA(lt_fiscalyearvalue) = ls_filter_cond-range[].
*        ELSEIF  ls_filter_cond-name = 'REGION'.
*          DATA(lt_region) = ls_filter_cond-range[].
*        ELSEIF  ls_filter_cond-name = 'DISTRICTNAME'.
*          DATA(lt_districtname) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_bukrs) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.


      SELECT FROM zbillingproc
      FIELDS *
      WHERE bukrs IN @lt_bukrs AND fiscalyearvalue IN @lt_fiscalyearvalue
      AND billingdocument IN @lt_fiscalyearvalue
      INTO TABLE @DATA(it_bill_hdr).


      LOOP AT it_bill_hdr INTO DATA(wa).

        SELECT SINGLE FROM zbillinglines FIELDS billno, lineitemno, invoicedate, materialno, uom, "invoice no replaced with bill no
        materialdescription, billingtype, soldtopartynumber, soldtopartyname, soldtopartygstin,
        soldtoregioncode, hsncode, documentcurrency, deliveryplant, billingqtyinsku
        WHERE invoice = @wa-billingdocument AND fiscalyearvalue = @wa-fiscalyearvalue
        AND companycode = @wa-bukrs
        INTO @DATA(wa_billing_line).

        ls_response-companycode = wa-bukrs.
        ls_response-invoice = wa_billing_line-billno. " wa-billingdocument.
        ls_response-invoicelitem = wa_billing_line-lineitemno.
        ls_response-fiscalyearvalue = wa-fiscalyearvalue.

        ls_response-billingtype = wa_billing_line-billingtype.
        ls_response-billingdate = wa_billing_line-invoicedate.
        ls_response-materialno = wa_billing_line-materialno.
        ls_response-materialdescription = wa_billing_line-materialdescription.
        ls_response-uom = wa_billing_line-uom.
        ls_response-customername = wa_billing_line-soldtopartyname.
        ls_response-soldtopartynumber = wa_billing_line-soldtopartynumber.
        ls_response-region = wa_billing_line-soldtoregioncode.
        ls_response-GSTIN_number = wa_billing_line-soldtopartygstin.
        ls_response-hsncode = wa_billing_line-hsncode.
        ls_response-Documentcurrency = wa_billing_line-documentcurrency.
        ls_response-deliveryplant = wa_billing_line-deliveryplant.
        ls_response-billingqtyinsku = wa_billing_line-billingqtyinsku.



        APPEND ls_response TO lt_response.
        CLEAR : ls_response, wa.
      ENDLOOP.

      SORT lt_response BY companycode invoice.
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
