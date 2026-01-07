CLASS zcl_gstr_sales_rep DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GSTR_SALES_REP IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
    DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

    DATA(lt_parameters)  = io_request->get_parameters( ).
    DATA(lt_fileds)  = io_request->get_requested_elements( ).
    DATA(lt_sort)  = io_request->get_sort_elements( ).

    TRY.
        DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
        CLEAR lt_Filter_cond.
    ENDTRY.

    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
      IF ls_filter_cond-name =  'COMP_CODE'.
        DATA(lt_comp_code) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'PLANT_CODE'.
        DATA(lt_plant) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'BILL_NO'.
        DATA(lt_bill) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'INVOICE_DATE'.
        DATA(lt_invdt) = ls_filter_cond-range[].
      ENDIF.
    ENDLOOP.
    TYPES: BEGIN OF ty_rk,
             plant  TYPE zr_usersetup_items-plant,
             userid TYPE zr_usersetup_items-Userid,
           END OF ty_rk.

    DATA: it_plant TYPE TABLE OF ty_rk,
          lv_plant TYPE ty_rk.

    DATA: lt_response    TYPE TABLE OF zce_gstr_sales_rep,
          it_final       TYPE TABLE OF zce_gstr_sales_rep,
          ls_line        LIKE LINE OF lt_response,
          lt_responseout LIKE lt_response,
          ls_responseout LIKE LINE OF lt_responseout.

    DATA lv_invoice TYPE c LENGTH 12.


    DATA: curr_user TYPE sy-uname.

    curr_user = sy-uname.

*    LOOP AT lt_bill INTO DATA(ls_bill).
*      lv_bill = |{ ls_bill-low ALPHA = IN }|.
*      ls_bille-low = lv_bill.
*      CLEAR lv_invoice.
*      lv_invoice = |{ ls_invoice-high ALPHA = IN }|.
*      ls_invoice-high = lv_invoice.
*      MODIFY lt_invoice FROM ls_invoice.
*      CLEAR : ls_invoice, lv_invoice.
*    ENDLOOP.

    SELECT FROM zr_usersetup_items FIELDS plant WHERE userid = @curr_user INTO TABLE @it_plant.
*
*      SELECT FROM zbillinglines AS a
*      LEFT JOIN ztable_irn AS b ON a~irnacknumber = b~ackno AND a~companycode = b~bukrs
*      LEFT JOIN ztable_plant AS c ON b~bukrs = c~comp_code AND b~plant = c~plant_code
*      FIELDS a~invoice, a~lineitemno AS line_item, a~invoicedate AS invoice_date, b~irnno AS irn, b~ackdate AS irn_date, a~companycode AS comp_code,
*      a~billingtype AS doc_type, a~soldtopartyname AS party_name ,a~soldtopartygstin AS party_gst, a~deliveryplacestatecode AS party_state,
*      a~hsncode AS hsn_code, a~materialdescription AS item, a~rate, a~qty, a~uom, a~netamount AS amnt, a~saletype AS nature, c~plant_name2 AS location,
*       a~igstamt AS igst, a~cgstamt AS cgst, a~sgstamt AS sgst, a~ewaybillnumber AS eway_bill, a~ewaybilldatetime AS eway_date, b~plant AS plant_code
*       WHERE a~companycode IN @lt_comp_code AND b~plant IN @lt_plant AND
*       invoice IN @lt_invoice AND invoicedate IN @lt_invdt
*       INTO CORRESPONDING FIELDS OF TABLE @lt_response.
*
*       loop at lt_response into data(wa_response).
*
*       read table lv_plant into data(wa_plant) with key plant = wa_response-plant_code.
*
*       if sy-subrc ne '0'.
*        clear wa_response.
*       endif.
*
*       modify lt_response from wa_response.
*       clear wa_response.
*       endloop.


*      SELECT FROM ZR_USERSETUP_items AS Z LEFT JOIN ztable_irn AS b ON z~Plant = b~plant
*      LEFT JOIN zbillinglines AS a ON  a~invoice = b~billingdocno AND a~companycode = b~bukrs
**      LEFT JOIN ztable_plant AS c ON b~bukrs = c~comp_code AND b~plant = c~plant_code
*      FIELDS a~invoice, a~lineitemno AS line_item, a~invoicedate AS invoice_date, b~irnno AS irn, b~ackdate AS irn_date, a~companycode AS comp_code,
*      a~billingtype AS doc_type, a~soldtopartyname AS party_name ,a~soldtopartygstin AS party_gst, a~deliveryplacestatecode AS party_state,
*      a~hsncode AS hsn_code, a~materialdescription AS item, a~rate, a~qty, a~uom, a~netamount AS amnt, a~saletype AS nature, B~PLANT AS location,
*       a~igstamt AS igst, a~cgstamt AS cgst, a~sgstamt AS sgst, a~ewaybillnumber AS eway_bill, a~ewaybilldatetime AS eway_date, b~plant AS plant_code
*       WHERE z~Userid = @curr_user and a~companycode IN @lt_comp_code AND b~plant IN @lt_plant AND
*       invoice IN @lt_invoice AND invoicedate IN @lt_invdt and a~companycode is not INITIAL and b~plant is not INITIAL and a~invoice is not INITIAL
*       and a~lineitemno is not INITIAL
*       INTO CORRESPONDING FIELDS OF TABLE @lt_response.

    SELECT FROM zbillinglines AS a
*    LEFT JOIN ztable_irn AS b ON  a~irnacknumber = b~ackno AND a~companycode = b~bukrs
*    LEFT JOIN zr_usersetup_items AS z ON z~plant = b~plant

    FIELDS a~invoice, a~billno AS bill_no, a~lineitemno AS line_item, a~invoicedate AS invoice_date,  a~companycode AS comp_code, "b~irnno AS irn, b~ackdate AS irn_date,
    a~billingtype AS doc_type, a~soldtopartyname AS party_name ,a~soldtopartygstin AS party_gst, a~deliveryplacestatecode AS party_state,
    a~hsncode AS hsn_code, a~materialno AS matnr, a~materialdescription AS item, a~rate, a~qty, a~uom, a~taxablevalueafterdiscount AS amnt, a~tcsamount AS tcs,
    a~saletype AS nature, a~deliveryplant AS plant_code, a~totaltaxamount AS taxableamnt, a~totalamount AS totamnt,
     a~igstamt AS igst, a~cgstamt AS cgst, a~sgstamt AS sgst, a~ewaybillnumber AS eway_bill, a~ewaybilldatetime AS eway_date, a~irnacknumber AS irnack

     WHERE  a~companycode IN @lt_comp_code AND a~deliveryplant IN @lt_plant AND "z~Userid = @curr_user AND
     billno IN @lt_bill AND invoicedate IN @lt_invdt AND a~companycode IS NOT INITIAL AND invoicedate IS NOT INITIAL AND materialno NE '1400000031'
     AND a~billno IS NOT INITIAL AND a~lineitemno IS NOT INITIAL AND deliveryplant IS NOT INITIAL AND a~cancelledinvoice NE 'X'

     INTO CORRESPONDING FIELDS OF TABLE @lt_response.


    SORT lt_response BY comp_code plant_code Bill_No Line_Item.
    DELETE ADJACENT DUPLICATES FROM lt_response COMPARING ALL FIELDS.
*    DELETE lt_response WHERE matnr = '1400000031'.
*    DELETE lt_response WHERE matnr = '1400000023'.


    LOOP AT lt_response INTO DATA(wa_response).

      SELECT SINGLE FROM ztable_irn FIELDS irnno, ackdate
      WHERE ackno = @wa_response-irnACK AND bukrs = @wa_response-comp_code AND plant IN @lt_plant
      INTO ( @wa_response-irn, @wa_response-irn_date ).

      SELECT SINGLE FROM ztable_plant FIELDS plant_name2 WHERE plant_code = @wa_response-plant_code INTO @wa_response-Location.

      READ TABLE it_plant INTO lv_plant WITH KEY plant = wa_response-plant_code.
      IF  sy-subrc NE 0.
        CLEAR: wa_response.
      ENDIF.

      IF  wa_response-igst IS NOT INITIAL.
        wa_response-Local_centre = 'Centre'.
        IF wa_response-igst NE '0' AND wa_response-amnt NE '0'.
          wa_response-gst_rate =  ( wa_response-igst / wa_response-amnt ) * 100 .
        ENDIF.
      ENDIF.
      IF  wa_response-cgst IS NOT INITIAL OR wa_response-sgst IS NOT INITIAL.
        wa_response-Local_centre = 'Local'.
        IF wa_response-cgst NE '0' AND wa_response-sgst NE '0' AND wa_response-amnt NE '0'.
          wa_response-gst_rate =  ( ( wa_response-cgst + wa_response-sgst ) / wa_response-amnt ) * 100 .
        ENDIF.
      ENDIF.

      IF wa_response-doc_type = 'CBRE' AND wa_response-amnt GT '0'.

        wa_response-amnt = wa_response-amnt * ( -1 ).

      ENDIF.

*      if   wa_response-tcs lt '0' .
*        wa_response-amnt = wa_response-amnt + wa_response-tcs.
*      endif.

      MODIFY lt_response FROM wa_response.
      CLEAR: wa_response.
    ENDLOOP.


    DELETE lt_response WHERE comp_code IS INITIAL.
    DELETE lt_response WHERE plant_code IS INITIAL.
    DELETE lt_response WHERE Bill_No IS INITIAL.
    DELETE lt_response WHERE Line_Item IS INITIAL.
    DELETE lt_response WHERE Invoice_Date IS INITIAL.


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

  ENDMETHOD.
ENDCLASS.
