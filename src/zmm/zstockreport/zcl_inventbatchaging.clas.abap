CLASS zcl_inventbatchaging DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_INVENTBATCHAGING IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).

      DATA: p_keydate TYPE d.
      DATA: lt_response    TYPE TABLE OF ZInventBatchAging,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.


      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      "DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      DATA entrydone TYPE int2.

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          RETURN.
      ENDTRY.

      p_keydate = cl_abap_context_info=>get_system_date( ).

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'STORAGELOCATION'.
          DATA(lt_lgort) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'PRODUCT'.
          DATA(lt_material) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'PLANTCODE'.
          DATA(lt_plant) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'BATCH'.
          DATA(lt_batch) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.

      SELECT FROM i_matlstkatkeydateinaltuom( p_keydate = @p_keydate ) AS a
      LEFT JOIN i_product AS b ON b~Product = a~Product
      LEFT JOIN I_ProductText AS c ON c~Product = a~Product AND c~Language = 'E'
      LEFT JOIN I_ProductGroupText_2 AS d ON d~ProductGroup = b~ProductGroup AND d~Language = 'E'
      LEFT JOIN i_batch AS e ON e~Material = a~Product AND e~Batch = a~Batch AND e~Plant = a~Plant
      LEFT JOIN I_ProductStorage_2 AS f ON f~Product = a~Product
      FIELDS a~Plant, a~StorageLocation, a~Product, a~Batch, a~CompanyCode, a~MatlWrhsStkQtyInMatlBaseUnit,
      b~ProductType, b~YY1_brandcode_PRD,
      c~ProductName, d~ProductGroupName, d~ProductGroupText,
      e~ShelfLifeExpirationDate, e~ManufactureDate,
      f~TotalShelfLife
      WHERE a~InventoryStockType = '01' AND a~AlternativeUnit = a~MaterialBaseUnit
      AND a~Plant IN @lt_plant AND a~Product IN @lt_material AND a~StorageLocation IN @lt_lgort AND a~Batch IN @lt_batch "'000000001000000185'
      AND a~MatlWrhsStkQtyInMatlBaseUnit <> '0' AND a~Plant IS NOT INITIAL AND a~Product IS NOT INITIAL AND
      a~Plant IS NOT INITIAL AND a~StorageLocation IS NOT INITIAL AND a~Batch IS NOT INITIAL
      INTO TABLE @DATA(it_product) PRIVILEGED ACCESS.

      DELETE it_product WHERE TotalShelfLife <= 0.

      IF it_product IS NOT INITIAL.
        SELECT FROM I_ProductValuationBasic AS a
        FIELDS a~Product, a~ValuationArea, a~StandardPrice, a~MovingAveragePrice, a~InventoryValuationProcedure
        FOR ALL ENTRIES IN @it_product WHERE Product = @it_product-Product AND ValuationArea = @it_product-Plant
        AND InventoryValuationProcedure IN ( 'V', 'S' )
        INTO TABLE @DATA(it_value) PRIVILEGED ACCESS.
      ENDIF.

      LOOP AT it_product ASSIGNING FIELD-SYMBOL(<wa_final>).
        ls_response-Product         = <wa_final>-Product.
        ls_response-productname     = <wa_final>-ProductName.
        ls_response-plantcode       = <wa_final>-Plant.
        ls_response-StorageLocation = <wa_final>-StorageLocation.
        ls_response-Batch           = <wa_final>-Batch.
        ls_response-Producttype     = <wa_final>-ProductType.
        ls_response-productgroup    = <wa_final>-ProductGroupName.
        ls_response-productgroup2   = <wa_final>-ProductGrouptext.
        ls_response-companycode     = <wa_final>-CompanyCode.
        ls_response-brandname       = <wa_final>-YY1_brandcode_PRD.
        ls_response-batchmfgdate    = <wa_final>-ManufactureDate.
        ls_response-shelfexpirydate = <wa_final>-ShelfLifeExpirationDate.
        ls_response-currentstock    = <wa_final>-MatlWrhsStkQtyInMatlBaseUnit.
        ls_response-monthyear       = |{ <wa_final>-ManufactureDate+4(2) }-{ <wa_final>-ManufactureDate+0(4) }|.
        ls_response-prd_shelf_days  = <wa_final>-TotalShelfLife.
        ls_response-left_shelfdays  = <wa_final>-ShelfLifeExpirationDate - p_keydate.

        IF ls_response-left_shelfdays > 0 AND ls_response-prd_shelf_days > 0.
          ls_response-rem_life        = ( ls_response-left_shelfdays / ls_response-prd_shelf_days ) * 100.
        ENDIF.
        IF <wa_final>-ManufactureDate <> 0.
          ls_response-agedays         = p_keydate - <wa_final>-ManufactureDate.
        ENDIF.

        READ TABLE it_value ASSIGNING FIELD-SYMBOL(<wa_value>) WITH KEY Product       = <wa_final>-Product
                                                                        ValuationArea = <wa_final>-Plant.
        IF <wa_value> IS ASSIGNED AND <wa_value>-InventoryValuationProcedure = 'S'.
          ls_response-currentvalue    = <wa_value>-StandardPrice * ls_response-currentstock.
          UNASSIGN <wa_value>.
        ELSEIF <wa_value> IS ASSIGNED AND <wa_value>-InventoryValuationProcedure = 'V'.
          ls_response-currentvalue    = <wa_value>-MovingAveragePrice * ls_response-currentstock.
          UNASSIGN <wa_value>.
        ENDIF.
        COLLECT ls_response INTO lt_response.
        CLEAR ls_response.
      ENDLOOP.

      SORT lt_response BY plantcode StorageLocation Product Batch.

      LOOP AT lt_sort ASSIGNING FIELD-SYMBOL(<wa_sort>).
        CASE <wa_sort>-element_name.
          WHEN 'PRODUCT'.
            SORT lt_response BY Product ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY Product DESCENDING.
            ENDIF.
          WHEN 'PLANTCODE'.
            SORT lt_response BY plantcode ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY plantcode DESCENDING.
            ENDIF.
          WHEN 'PRODUCTNAME'.
            SORT lt_response BY productname ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY productname DESCENDING.
            ENDIF.
          WHEN 'BATCH'.
            SORT lt_response BY Batch ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY Batch DESCENDING.
            ENDIF.
          WHEN 'STORAGELOCATION'.
            SORT lt_response BY StorageLocation ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY StorageLocation DESCENDING.
            ENDIF.
          WHEN 'PRODUCTTYPE'.
            SORT lt_response BY Producttype ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY Producttype DESCENDING.
            ENDIF.
          WHEN 'PRODUCTGROUP'.
            SORT lt_response BY productgroup ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY productgroup DESCENDING.
            ENDIF.
          WHEN 'PRODUCTNAMETEXT'.
            SORT lt_response BY productname ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY productname DESCENDING.
            ENDIF.
          WHEN 'BRANDNAME'.
            SORT lt_response BY brandname ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY brandname DESCENDING.
            ENDIF.
          WHEN 'COMPANYCODE'.
            SORT lt_response BY companycode ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY companycode DESCENDING.
            ENDIF.
          WHEN 'MONTHYEAR'.
            SORT lt_response BY monthyear ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY monthyear DESCENDING.
            ENDIF.
          WHEN 'BATCHMFGDATE'.
            SORT lt_response BY batchmfgdate ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY batchmfgdate DESCENDING.
            ENDIF.
          WHEN 'SHELFEXPIRYDATE'.
            SORT lt_response BY shelfexpirydate ASCENDING.
            IF <wa_sort>-descending = 'X'.
              SORT lt_response BY shelfexpirydate DESCENDING.
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

    ENDIF.
  ENDMETHOD.
ENDCLASS.
