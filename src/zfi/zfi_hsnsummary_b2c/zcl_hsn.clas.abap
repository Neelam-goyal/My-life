CLASS zcl_hsn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HSN IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
*    IF io_request->is_data_requested( ).

    DATA: lt_response    TYPE TABLE OF zcds_hsn_b2c,
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



    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).

      IF ls_filter_cond-name = 'HSN'.
        DATA(lt_hsn) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'DESCRIPTION'.
        DATA(lt_description) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'HSN_DATE'.
        DATA(lt_Date) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'UQC'.
        DATA(lt_uqc) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'TOTAL_QUANTITY'.
        DATA(lt_total_quantity) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'TOTAL_VALUE'.
        DATA(lt_total_value) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'TAXABLE_VALUE'.
        DATA(lt_taxable_value) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'INTEGRATED_TAX_AMOUNT'.
        DATA(lt_integerated_tax_amount) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'CENTRAL_TAX_AMOUNT'.
        DATA(lt_central_tax_amount) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'COMPANY_CODE'.
        DATA(lt_company_code) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'PLANT_CODE'.
        DATA(lt_plant_code) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'RATE'.
        DATA(lt_Rate) = ls_filter_cond-range[].

      ELSEIF ls_filter_cond-name = 'STATEUT_TAXAMOUNT'.
        DATA(lt_ugstamt) = ls_filter_cond-range[].

      ENDIF.

    ENDLOOP.


    SELECT FROM zbillinglines AS a
    LEFT JOIN    i_productplantintltrd AS b ON a~materialno = b~Product
    LEFT JOIN I_AE_CnsmpnTaxCtrlCodeTxt AS c ON b~ConsumptionTaxCtrlCode = c~ConsumptionTaxCtrlCode
    FIELDS
   a~hsncode,
   a~deliverydate,
*   a~materialno,
*   b~ConsumptionTaxCtrlCode,
   c~ConsumptionTaxCtrlCodeText1,
   SUM( a~totalamount ) AS totalamount,
   a~uom,
   SUM( a~qty ) AS qty,
   a~rate,
   SUM( a~netamount ) AS netamount,
   SUM( a~igstamt ) AS igstamt,
   SUM( a~cgstamt ) AS cgstamt,
   SUM( a~ugstamt ) AS ugstamt,
   a~companycode ,
   a~deliveryplant

   WHERE a~saletype = 'B2C' AND a~billingtype = 'CBRE'
   AND a~hsncode IN @lt_hsn
   AND a~uom IN @lt_uqc
   AND c~ConsumptionTaxCtrlCodeText1 IN @lt_description
   AND a~qty IN @lt_total_quantity
   AND a~rate IN @lt_rate
   AND a~totalamount IN @lt_total_value
   AND a~netamount IN @lt_taxable_value
   AND a~igstamt IN @lt_integerated_tax_amount
   AND a~cgstamt IN @lt_central_tax_amount
   AND a~ugstamt IN @lt_ugstamt
   AND a~companycode IN @lt_company_code
   AND a~deliveryplant IN @lt_plant_code
   and a~deliverydate in @lt_date
   GROUP BY  a~hsncode,
   a~deliverydate,
*   a~materialno,
*   b~ConsumptionTaxCtrlCode,
   c~ConsumptionTaxCtrlCodeText1,
   a~uom,
   a~rate,
   a~companycode ,
   a~deliveryplant
   INTO TABLE  @DATA(header) PRIVILEGED ACCESS.

    SORT header BY hsncode uom ConsumptionTaxCtrlCodeText1.
*    DELETE ADJACENT DUPLICATES FROM header COMPARING ALL FIELDS.

    LOOP AT header INTO DATA(ls_header).

      ls_response-hsn = ls_header-hsncode.
      ls_response-description = ls_header-ConsumptionTaxCtrlCodeText1.
      ls_response-uqc = ls_header-uom.
*      ls_response-hsn_Date = ls_header-deliverydate.
      ls_response-Total_Quantity = COND #(
            WHEN ls_header-qty GT 0 THEN ls_header-qty
            ELSE ls_header-qty * -1
       ).
      ls_response-Total_Value = COND #(
            WHEN ls_header-totalamount GT 0 THEN ls_header-totalamount
            ELSE ls_header-totalamount * -1
       ).
      ls_response-Rate = COND #(
            WHEN ls_header-rate GT 0 THEN ls_header-rate
            ELSE ls_header-rate * -1
       ).
      ls_response-Taxable_Value = ls_header-netamount.
      ls_response-Integrated_Tax_Amount = COND #(
            WHEN ls_header-igstamt GT 0 THEN ls_header-igstamt
            ELSE ls_header-igstamt * -1
       ).
      ls_response-Central_Tax_Amount = COND #(
            WHEN ls_header-cgstamt GT 0 THEN ls_header-cgstamt
            ELSE ls_header-cgstamt * -1
       ).
      ls_response-company_code = ls_header-companycode.
      ls_response-plant_code = ls_header-deliveryplant.
      ls_response-StateUT_Tax_Amount = ls_header-ugstamt.
*   ls_response-Cess_Amount = ls_header-.

      APPEND ls_response TO lt_response.
*      COLLECT  ls_response INTO lt_response.
      CLEAR: ls_response .
    ENDLOOP.




    LOOP AT lt_sort INTO DATA(ls_sort).
      CASE ls_sort-element_name.

        WHEN 'HSN'.
          SORT lt_response BY hsn ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY hsn DESCENDING.
          ENDIF.

        WHEN 'UQC'.
          SORT lt_response BY uqc ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY uqc DESCENDING.
          ENDIF.

        WHEN 'TOTAL_QUANTITY'.
          SORT lt_response BY total_quantity ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY total_quantity DESCENDING.
          ENDIF.

        WHEN 'RATE'.
          SORT lt_response BY Rate ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY Rate DESCENDING.
          ENDIF.

        WHEN 'TOTAL_VALUE'.
          SORT lt_response BY total_value ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY total_value DESCENDING.
          ENDIF.

        WHEN 'TAXABLE_VALUE'.
          SORT lt_response BY taxable_value ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY taxable_value DESCENDING.
          ENDIF.


        WHEN 'INTEGRATED_TAX_AMOUNT'.
          SORT lt_response BY integrated_tax_amount ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY integrated_tax_amount DESCENDING.
          ENDIF.

        WHEN 'CENTRAL_TAX_AMOUNT'.
          SORT lt_response BY central_tax_amount ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY central_tax_amount DESCENDING.
          ENDIF.

        WHEN 'STATEUT_TAXAMOUNT'.
          SORT lt_response BY StateUT_Tax_Amount ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY StateUT_Tax_Amount DESCENDING.
          ENDIF.

        WHEN 'COMPANY_CODE'.
          SORT lt_response BY company_code ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY company_code DESCENDING.
          ENDIF.

        WHEN 'PLANT_CODE'.
          SORT lt_response BY plant_code ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY plant_code DESCENDING.
          ENDIF.

      ENDCASE.
    ENDLOOP.




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

*    ENDIF.

  ENDMETHOD.
ENDCLASS.
