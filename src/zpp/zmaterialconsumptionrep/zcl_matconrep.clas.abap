CLASS zcl_matconrep DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MATCONREP IMPLEMENTATION.


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
      IF ls_filter_cond-name =  'PLANT'.
        DATA(lt_werks) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'MATERIAL'.
        DATA(lt_matnr) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'RANGEDATE'.
        DATA(lt_date) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'TODATE'.
        DATA(lt_todate) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'SHIFT'.
        DATA(lt_shift) = ls_filter_cond-range[].
      ENDIF.
    ENDLOOP.

    DATA: it_repmatTable TYPE TABLE OF zrepmaterials,
          wa_repmatTable TYPE zrepmaterials.

    DATA: lt_response    TYPE TABLE OF zc_customentity,
          ls_line        TYPE zc_customentity,
          lt_responseout TYPE TABLE OF zc_customentity,
          ls_responseout TYPE zc_customentity.

    DATA lv_matnr TYPE c LENGTH 18.

    TYPES: BEGIN OF ty_sum,
             plant           TYPE c LENGTH 4,
             rangedate       TYPE datn,
             todate          TYPE datn,
             material        TYPE c LENGTH 40,
             matDesc         TYPE c LENGTH 40,
             um              TYPE c LENGTH 3,
             ShiftDefinition TYPE c LENGTH 4,
             qty             TYPE I_MaterialDocumentItem_2-QuantityInEntryUnit,
           END OF ty_sum.
    DATA: it_qty TYPE TABLE OF ty_sum,
          wa_qty TYPE ty_sum.

    LOOP AT lt_matnr INTO DATA(ls_aufnr).
      lv_matnr = |{ ls_aufnr-low ALPHA = IN }|.
      ls_aufnr-low = lv_matnr.
      CLEAR lv_matnr.
      lv_matnr = |{ ls_aufnr-high ALPHA = IN }|.
      ls_aufnr-high = lv_matnr.
      MODIFY lt_matnr FROM ls_aufnr.
      CLEAR : ls_aufnr, lv_matnr.
    ENDLOOP.

    READ TABLE lt_date INTO DATA(wa_fromdate) INDEX 1.
    READ TABLE lt_todate INTO DATA(wa_todate) INDEX 1.
    READ TABLE lt_werks INTO DATA(wa_werks) INDEX 1.

    SELECT SINGLE FROM zrepmaterials
    FIELDS plant, material, rangedate, todate
    WHERE todate >= @wa_fromdate-low AND rangedate <= @wa_fromdate-low
    AND plant = @wa_werks-low
    INTO @DATA(wa_zrepmaterials) PRIVILEGED ACCESS.

    SELECT SINGLE FROM zrepmaterials
    FIELDS plant, material, rangedate, todate
    WHERE todate <= @wa_todate-low AND rangedate >= @wa_todate-low
    AND plant = @wa_werks-low
    INTO @DATA(wa_zrepmaterials2) PRIVILEGED ACCESS.

    IF wa_todate-low+0(4) = wa_fromdate-low+0(4) AND wa_todate-low+4(2) = wa_fromdate-low+4(2)
    AND wa_zrepmaterials IS INITIAL AND wa_zrepmaterials2 IS INITIAL.

      SELECT FROM I_MaterialDocumentItem_2 AS a
      LEFT JOIN I_ProductText AS b ON a~Material =  b~Product AND b~Language = 'E'
      LEFT JOIN i_mfgorderconfirmation AS c ON c~MaterialDocument = a~MaterialDocument AND c~MaterialDocumentYear = a~MaterialDocumentYear
      FIELDS a~MaterialDocument, a~MaterialDocumentItem, a~MaterialDocumentYear, a~ReversedMaterialDocument,
      a~Material , a~Plant, a~StorageLocation, a~QuantityInEntryUnit, a~PostingDate, a~GoodsMovementType,
      a~MaterialBaseUnit, a~EntryUnit, a~Batch, b~ProductName, c~ShiftDefinition
      WHERE a~GoodsMovementType IN ( '261', '262' )
      AND a~Plant IN @lt_werks AND a~Material IN @lt_matnr
      AND a~PostingDate >= @wa_fromdate-low AND a~PostingDate <= @wa_todate-low
      AND a~Material IS NOT INITIAL AND c~ShiftDefinition IN @lt_shift
      INTO TABLE @DATA(lt_final) PRIVILEGED ACCESS.

      SORT lt_final BY Plant Material PostingDate ShiftDefinition.

      LOOP AT lt_final ASSIGNING FIELD-SYMBOL(<wa_final>).

        wa_qty-plant          = <wa_final>-Plant.
        wa_qty-rangedate      = wa_fromdate-low.
        wa_qty-todate         = wa_todate-low.
        wa_qty-material       = <wa_final>-Material.

        IF lt_shift IS NOT INITIAL.
          wa_qty-shiftdefinition = <wa_final>-ShiftDefinition.
        ENDIF.

        wa_qty-matdesc        = <wa_final>-ProductName.
        wa_qty-um             = <wa_final>-EntryUnit.

        IF <wa_final>-GoodsMovementType = '262'.
          wa_qty-qty -= <wa_final>-QuantityInEntryUnit.
        ELSE.
          wa_qty-qty  = <wa_final>-QuantityInEntryUnit.
        ENDIF.

        COLLECT wa_qty INTO it_qty.
        CLEAR wa_qty.

      ENDLOOP.

      LOOP AT it_qty INTO wa_qty.

        ls_line-material     = wa_qty-material.
        ls_line-plant        = wa_qty-plant.
        ls_line-matdesc      = wa_qty-matdesc.
        ls_line-rangedate    = wa_qty-rangedate.
        ls_line-todate       = wa_qty-todate.
        ls_line-shift        = wa_qty-shiftdefinition.
        ls_line-um           = wa_qty-um.
        ls_line-quantity     = wa_qty-qty.

        APPEND ls_line TO lt_response.
        CLEAR ls_line.

      ENDLOOP.

      SORT lt_response BY plant material rangedate.

    ELSE.
      " Access query context
* DATA(lo_messages) = io_request->get_message_container( ).
*
*  " Report custom message (from SE91)
*  lo_messages->add_message(
*    iv_msgid = 'ZMSG'         " Your message class
*    iv_msgno = '001'          " Message number
*    iv_msgty = if_abap_behv_message=>msgty-error  " 'S', 'E', 'W', 'I'
*    iv_msgv1 = 'Date range missing'
*  ).


    ENDIF.
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
