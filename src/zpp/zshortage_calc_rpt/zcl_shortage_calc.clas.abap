CLASS  zcl_shortage_calc  DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SHORTAGE_CALC IMPLEMENTATION.


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
      ELSEIF ls_filter_cond-name = 'PRODUCTIONORDER'.
        DATA(lt_aufnr) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'BUKRS'.
        DATA(lt_bukrs) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'MATERIAL'.
        DATA(lt_matnr) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'BOMLOCATION'.
        DATA(lt_lgort) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'MAKTX'.
        DATA(lt_maktx) = ls_filter_cond-range[].
      ENDIF.
    ENDLOOP.

    TYPES: BEGIN OF ty_plantstock,
             material        TYPE c LENGTH 40,
             plant           TYPE c LENGTH 4,
             StorageLocation TYPE c LENGTH 4,
             plantstock      TYPE p LENGTH 16 DECIMALS 3,
           END OF ty_plantstock.
    DATA it_plantproduct TYPE TABLE OF ty_plantstock.
    DATA it_lgort_product TYPE TABLE OF ty_plantstock.
    DATA wa_plantproduct TYPE ty_plantstock.

    DATA: lt_response    TYPE TABLE OF zcds_shortage_calc,
          ls_line        LIKE LINE OF lt_response,
          lt_responseout LIKE lt_response,
          ls_responseout LIKE LINE OF lt_responseout.

    DATA lv_aufnr TYPE c LENGTH 12.

    LOOP AT lt_aufnr INTO DATA(ls_aufnr).
      lv_aufnr = |{ ls_aufnr-low ALPHA = IN }|.
      ls_aufnr-low = lv_aufnr.
      CLEAR lv_aufnr.
      lv_aufnr = |{ ls_aufnr-high ALPHA = IN }|.
      ls_aufnr-high = lv_aufnr.
      MODIFY lt_aufnr FROM ls_aufnr.
      CLEAR : ls_aufnr, lv_aufnr.
    ENDLOOP.

    SELECT FROM I_ProductionOrderOpComponentTP  AS a
    LEFT JOIN I_ProductDescription_2 AS b ON b~Product = a~Material AND b~Language = 'E'
    LEFT JOIN I_BillOfMaterialItemBasic AS c ON c~BillOfMaterial = a~BillOfMaterialInternalID
    AND c~BillOfMaterialCategory = a~BillOfMaterialCategory AND c~BillOfMaterialItemNodeNumber = a~BillOfMaterialItemNodeNumber
    AND c~BOMItemInternalChangeCount = a~BOMItemInternalChangeCount
    LEFT JOIN ZI_PlantTable AS d ON d~PlantCode = a~Plant
*    LEFT JOIN I_StockQuantityCurrentValue_2( p_displaycurrency = 'INR' ) AS e
*    ON e~Product = a~Material AND e~Plant = a~Plant AND e~StorageLocation = a~StorageLocation
*    AND e~ValuationAreaType = '1' AND e~InventoryStockType = '01'
    FIELDS a~Reservation, a~ReservationItem, a~ReservationRecordType,  a~Material, a~plant,
     a~ProductionOrder, a~storagelocation, a~BillOfMaterialCategory, a~BillOfMaterialItemNodeNumber,
     a~BOMItemInternalChangeCount, a~RequiredQuantity,
     b~ProductDescription,
     c~ProdOrderIssueLocation " e~MatlWrhsStkQtyInMatlBaseUnit AS lgortstock
    WHERE a~ProductionOrder IN @lt_aufnr AND d~CompCode IN @lt_bukrs AND a~Material IN @lt_matnr
    AND a~Plant IN @lt_werks AND c~ProdOrderIssueLocation IN @lt_lgort AND b~ProductDescription IN @lt_maktx
    INTO TABLE @DATA(it) PRIVILEGED ACCESS.

    SELECT FROM I_StockQuantityCurrentValue_2( p_displaycurrency = 'INR' )
    FIELDS Product , Plant , StorageLocation, MatlWrhsStkQtyInMatlBaseUnit AS plantstock
    WHERE Plant IN @lt_werks AND ValuationAreaType = '1' AND InventoryStockType = '01'
    AND Product IN @lt_matnr AND StorageLocation IN @lt_lgort
    INTO TABLE @DATA(it_plant_stock) PRIVILEGED ACCESS.

    LOOP AT it_plant_stock ASSIGNING FIELD-SYMBOL(<wa_plantstock2>).
      wa_plantproduct-material        = <wa_plantstock2>-Product.
      wa_plantproduct-plant           = <wa_plantstock2>-Plant.
      wa_plantproduct-storagelocation = <wa_plantstock2>-StorageLocation.
      wa_plantproduct-plantstock      = <wa_plantstock2>-plantstock.
      COLLECT wa_plantproduct INTO it_lgort_product.

      CLEAR wa_plantproduct.
      wa_plantproduct-material   = <wa_plantstock2>-Product.
      wa_plantproduct-plant      = <wa_plantstock2>-Plant.
      wa_plantproduct-plantstock = <wa_plantstock2>-plantstock.
      COLLECT wa_plantproduct INTO it_plantproduct.
      CLEAR wa_plantproduct.
    ENDLOOP.

    LOOP AT it ASSIGNING FIELD-SYMBOL(<wa>).
      CLEAR ls_line.

      ls_line-material              = <wa>-Material.
      ls_line-plant                 = <wa>-Plant.
      ls_line-maktx                 = <wa>-ProductDescription.
      ls_line-BOMLocation           = <wa>-ProdOrderIssueLocation.
      ls_line-requiredquantity      = <wa>-RequiredQuantity.

      COLLECT ls_line INTO lt_response.
    ENDLOOP.

    LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<ls_resp>).

      READ TABLE it_lgort_product ASSIGNING FIELD-SYMBOL(<wa_lgort_product>)
                 WITH KEY material = <ls_resp>-Material
                          plant    = <ls_resp>-Plant
                          storagelocation = <ls_resp>-BOMLocation.
      IF sy-subrc = 0.
        <ls_resp>-stock = <wa_lgort_product>-plantstock.
      ENDIF.

      READ TABLE it_plantproduct ASSIGNING FIELD-SYMBOL(<wa_plantstock>)
           WITH KEY material = <ls_resp>-Material
                    plant    = <ls_resp>-Plant.
      IF sy-subrc = 0.
        <ls_resp>-plantstock = <wa_plantstock>-plantstock.
      ENDIF.

      <ls_resp>-short_excess_qty = <ls_resp>-stock - <ls_resp>-requiredquantity.

      <ls_resp>-material = | { <ls_resp>-material ALPHA = OUT } |.

    ENDLOOP.

    SORT lt_response BY material plant BOMLocation.

    LOOP AT lt_sort INTO DATA(ls_sort).
      CASE ls_sort-element_name.
        WHEN 'MATERIAL'.
          SORT lt_response BY material ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY material DESCENDING.
          ENDIF.
        WHEN 'COMPONENTDESCRIPTION'.
          SORT lt_response BY maktx ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY maktx DESCENDING.
          ENDIF.
        WHEN 'BOMLOCATION'.
          SORT lt_response BY BOMLocation ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY BOMLocation DESCENDING.
          ENDIF.
        WHEN 'PLANTSTOCK'.
          SORT lt_response BY plantstock ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY plantstock DESCENDING.
          ENDIF.
        WHEN 'STOCK'.
          SORT lt_response BY stock ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY stock DESCENDING.
          ENDIF.
        WHEN 'REQUIREDQUANTITY'.
          SORT lt_response BY requiredquantity ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY requiredquantity DESCENDING.
          ENDIF.
        WHEN 'SHORT_EXCESS_QTY'.
          SORT lt_response BY short_excess_qty ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response BY short_excess_qty DESCENDING.
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

  ENDMETHOD.
ENDCLASS.
