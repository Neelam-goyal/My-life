CLASS zcl_inventoryaging DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_INVENTORYAGING IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).

      DATA p_keydate TYPE d.

      TYPES BEGIN OF ty_value.
      TYPES: quantity TYPE i_stockquantitycurrentvalue_2-matlwrhsstkqtyinmatlbaseunit,
             value    TYPE i_stockquantitycurrentvalue_2-stockvalueindisplaycurrency.
      TYPES END OF ty_value.

      DATA: lt_response        TYPE TABLE OF ZInventoryAging,
            ls_response        LIKE LINE OF lt_response,
            lt_responseout     LIKE lt_response,
            ls_responseout     LIKE LINE OF lt_responseout,
            lt_response_period TYPE TABLE OF ZInventoryAging,
            ls_response_period LIKE LINE OF lt_response_period,
            lt_response_delete TYPE TABLE OF i_materialdocumentitem_2,
            ls_response_delete LIKE LINE OF lt_response_delete,
            lt_value           TYPE TABLE OF ty_value,
            ls_value           TYPE ty_value,
            lv_price           TYPE p DECIMALS 2.


      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      TRY.
          data(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_filter_option).
         RETURN.
      ENDTRY.
      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
         RETURN.
      ENDTRY.

****************************Data selection and business logics goes here*********************************

      p_keydate = cl_abap_context_info=>get_system_date( ).
*      LOOP AT lt_parameter ASSIGNING FIELD-SYMBOL(<fs_p>).
*        CASE <fs_p>-parameter_name.
*          WHEN 'pkeydate'.   DATA(p_keydate) = <fs_p>-value.
*        ENDCASE.
*      ENDLOOP.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'STORAGELOCATION'.
          DATA(lt_storagelocation) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'PRODUCT'.
          DATA(lt_material) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'PLANTCODE'.
          DATA(lt_plant) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_bukrs) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'BATCH'.
          DATA(lt_batch) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'PRODUCTTYPE'.
          DATA(lt_producttype) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.


*get inventory information based on date
      SELECT
          FROM i_materialstock_2 as a
          join I_Product as b on a~Material = b~Product
          left join I_ProductText as c on b~Product = c~Product AND c~Language = 'E'
          FIELDS a~CompanyCode, a~Plant, a~StorageLocation, a~Material, a~Batch, a~MatlWrhsStkQtyInMatlBaseUnit, c~ProductName,
            b~ProductType
          WHERE a~matldoclatestpostgdate <= @p_keydate
          AND a~companycode IN  @lt_bukrs
          AND a~plant IN @lt_plant
          AND a~storagelocation IN @lt_storagelocation
          AND a~material in @lt_material AND b~ProductType in @lt_producttype "'ZFRT'
          INTO TABLE @DATA(lt_stock).

      LOOP AT lt_stock INTO DATA(ls_stock).
        ls_response-companycode = ls_stock-companycode.
        ls_response-plantcode = ls_stock-plant.
        ls_response-product = ls_stock-material.
        ls_response-StorageLocation = ls_stock-storagelocation.
        ls_response-Producttype = ls_stock-ProductType.
        ls_response-productname = ls_stock-ProductName.
        ls_response-currentstock = ls_stock-matlwrhsstkqtyinmatlbaseunit.

        COLLECT ls_response INTO lt_response.
      ENDLOOP.

*period start date calculation
      DATA lv_30 TYPE d.
      DATA lv_60 TYPE d.
      DATA lv_90 TYPE d.
      DATA cd TYPE d.
      cd = p_keydate.
      lv_30 = cd - 30.
      lv_60 = cd - 60.
      lv_90 = cd - 90.

      IF lt_response IS NOT INITIAL.
*get material movement history
          SELECT MaterialDocumentYear, MaterialDocument, MaterialDocumentItem, reversedmaterialdocumentyear, reversedmaterialdocument,
                companycode, plant, material, storagelocation, quantityinbaseunit, postingdate
          FROM i_materialdocumentitem_2
          FOR ALL ENTRIES IN @lt_response
          WHERE
          storagelocation = @lt_response-StorageLocation
          AND postingdate <= @p_keydate
          AND plant IN @lt_plant
          AND companycode IN @lt_bukrs
          AND material = @lt_response-product
          AND goodsmovementiscancelled IS INITIAL
          INTO TABLE @DATA(lt_movement).

          DATA(lt_movement_reverse) = lt_movement[].

          LOOP AT lt_movement INTO DATA(ls_movement).
            READ TABLE lt_movement_reverse WITH KEY  reversedmaterialdocumentyear = ls_movement-materialdocumentyear
                                                     reversedmaterialdocument = ls_movement-materialdocument
                                           TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
"              DELETE lt_movement FROM ls_movement.
              ls_response_delete-MaterialDocumentYear = ls_movement-MaterialDocumentYear.
              ls_response_delete-MaterialDocument = ls_movement-MaterialDocument.
              ls_response_delete-MaterialDocumentItem = ls_movement-MaterialDocumentItem.

              COLLECT ls_response_delete INTO lt_response_delete.
              CLEAR ls_response_delete.
            ENDIF.
          ENDLOOP.

          LOOP AT lt_movement INTO ls_movement WHERE reversedmaterialdocument IS INITIAL.

            READ TABLE lt_response_delete WITH KEY MaterialDocumentYear = ls_movement-materialdocumentyear
                                                   MaterialDocument = ls_movement-MaterialDocument
                                                   MaterialDocumentItem = ls_movement-MaterialDocumentItem
                                           TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
                ls_response_period-companycode = ls_movement-companycode.
                ls_response_period-plantcode = ls_movement-plant.
                "ls_response_period-Producttype = ls_movement-.
                "ls_response_period-productname = "".
                ls_response_period-product = ls_movement-material.
                ls_response_period-StorageLocation = ls_movement-storagelocation.
*                ls_response_period-currentstock = ls_movement-materialbaseunit.
*                ls_response_period-currentvalue = ls_movement-companycodecurrency.

                IF ls_movement-postingdate > lv_30 AND ls_movement-postingdate <= cd.
                  ls_response_period-period1stock = ls_movement-quantityinbaseunit.
                ELSEIF ls_movement-postingdate > lv_60 AND ls_movement-postingdate <= lv_30.
                  ls_response_period-period2stock = ls_movement-quantityinbaseunit.
                ELSEIF ls_movement-postingdate > lv_90 AND ls_movement-postingdate <= lv_60.
                  ls_response_period-period3stock = ls_movement-quantityinbaseunit.
                ELSE.
                  ls_response_period-period4stock = ls_movement-quantityinbaseunit.
                ENDIF.

                COLLECT ls_response_period INTO lt_response_period.
                CLEAR ls_response_period.
            ENDIF.
          ENDLOOP.

          LOOP AT lt_response INTO ls_response.
            READ TABLE lt_response_period WITH KEY companycode = ls_response-companycode
                                                   plantcode = ls_response-plantcode
                                                   product = ls_response-product
                                                   storagelocation = ls_response-StorageLocation
                                          INTO ls_response_period.


            IF sy-subrc = 0.
*     period 1 calculation with 30 days.
              IF ls_response-currentstock < ls_response_period-period1stock AND ls_response_period-period1stock > 0.
                ls_response-period1stock = ls_response-currentstock.
              ELSE.
                ls_response-period1stock = ls_response_period-period1stock.
              ENDIF.
*     period 2 calculation between 30 days to 60 days.
              IF ( ls_response-currentstock - ls_response_period-period1stock )  < 0.
                ls_response-period2stock = 0.
              ELSEIF ( ls_response-currentstock - ls_response_period-period1stock ) < ls_response_period-period2stock AND ls_response_period-period2stock > 0.
                ls_response-period2stock = ls_response-currentstock - ls_response_period-period1stock.
              ELSEIF ( ls_response-currentstock - ls_response_period-period1stock ) >= ls_response_period-period2stock.
                ls_response-period2stock = ls_response_period-period2stock.
              ENDIF.
*     period 3 calculation more than 60 days
              IF ( ls_response-currentstock - ls_response_period-period1stock - ls_response_period-period2stock )  < 0.
                ls_response-period3stock = 0.
              ELSEIF ( ls_response-currentstock - ls_response_period-period1stock - ls_response_period-period2stock ) < ls_response_period-period3stock AND ls_response_period-period3stock > 0.
                ls_response-period3stock = ls_response-currentstock - ls_response_period-period1stock - ls_response_period-period2stock.
              ELSEIF ( ls_response-currentstock - ls_response_period-period1stock - ls_response_period-period2stock ) >= ls_response_period-period3stock.
                ls_response-period3stock = ls_response_period-period3stock.
              ENDIF.
*     period 4 calculation more than 90 days
*              IF ( ls_response-currentstock - ls_response_period-period1stock - ls_response_period-period2stock - ls_response_period-period2stock - ls_response_period-period3stock)  < 0.
*                ls_response-period3stock = 0.
*              ELSEIF ( ls_response-currentstock - ls_response_period-period1stock - ls_response_period-period2stock ) < ls_response_period-period3stock AND ls_response_period-period3stock > 0.
*                ls_response-period3stock = ls_response-currentstock - ls_response_period-period1stock - ls_response_period-period2stock.
*              ELSEIF ( ls_response-currentstock - ls_response_period-period1stock - ls_response_period-period2stock ) >= ls_response_period-period3stock.
*                ls_response-period3stock = ls_response_period-period3stock.
*              ENDIF.

            ELSEIF sy-subrc > 0 AND ls_response-currentstock > 0.
              ls_response-period4stock = ls_response-currentstock.
            ENDIF.

*     getting price information
            SELECT SUM( matlwrhsstkqtyinmatlbaseunit ) AS quantity,
                   SUM( stockvalueincccrcy ) AS value
                   FROM i_stockquantitycurrentvalue_2( p_displaycurrency = 'INR' )
                   WHERE product = @ls_response-product
                   AND plant = @ls_response-plantcode
                   AND storagelocation = @ls_response-storagelocation
                   AND valuationareatype = 1
                   GROUP BY product,plant,storagelocation
                   INTO TABLE @lt_value.

            IF sy-subrc = 0.
              CLEAR: ls_value,
                     lv_price.
              READ TABLE lt_value INTO ls_value INDEX 1.
              IF ls_value-quantity NE 0.
                lv_price = ls_value-value / ls_value-quantity.
              ENDIF.
            ENDIF.

*     calculate value information
            ls_response-currentvalue = ls_response-currentstock * lv_price.
            ls_response-period1value = ls_response-period1stock * lv_price.
            ls_response-period2value = ls_response-period2stock * lv_price.
            ls_response-period3value = ls_response-period3stock * lv_price.
            ls_response-period4value = ls_response-period4stock * lv_price.

            MODIFY lt_response FROM ls_response.
            CLEAR ls_response.
          ENDLOOP.
      ENDIF.

*paging way to return huge amount of data
      SORT lt_response BY storagelocation product.
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
