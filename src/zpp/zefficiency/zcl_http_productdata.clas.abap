CLASS ZCL_HTTP_PRODUCTDATA DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

    CLASS-DATA it_product TYPE TABLE OF zproductdata.

    TYPES: BEGIN OF ty_json,
             to_product LIKE it_product,
           END OF ty_json.

    DATA: lv_json TYPE ty_json.

    TYPES: BEGIN OF ty_product,
             posting_date        TYPE I_MfgOrderConfirmation-PostingDate,
             work_center         TYPE I_WorkCenter-WorkCenter,
             shift               TYPE  c LENGTH 5,
             productionorder     TYPE I_MfgOrderConfirmation-ManufacturingOrder,
             order_type          TYPE c LENGTH 4,
             product             TYPE i_product-product,
             product_description TYPE I_ProductText-ProductName,
             total_quantity      TYPE p LENGTH 13 DECIMALS 3,
             total_wastage       TYPE p LENGTH 13 DECIMALS 3,
             actual_runtime      TYPE p LENGTH 13 DECIMALS 2,
             plant_runtime       TYPE p LENGTH 13 DECIMALS 2,
             diffrence_runtime   TYPE p LENGTH 13 DECIMALS 2,
             start_time          TYPE c LENGTH 8,
             end_time            TYPE c LENGTH 8,
           END OF ty_product.

    TYPES: tt_product TYPE STANDARD TABLE OF ty_product WITH DEFAULT KEY.

    DATA: it_final_master TYPE tt_product,
          wa_final_master TYPE ty_product.


PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_PRODUCTDATA IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    TRY.

        DATA(lv_body) = request->get_text( ).

        CASE request->get_method( ).

          WHEN CONV string( if_web_http_client=>post ).
            TRY.
                CALL METHOD /ui2/cl_json=>deserialize
                  EXPORTING
                    json = lv_body
                  CHANGING
                    data = it_final_master.
              CATCH cx_root INTO DATA(lx_json).
                response->set_status( i_code   = 400
                                      i_reason = 'Invalid JSON format' ).
                response->set_text( |Deserialization failed: { lx_json->get_text( ) }| ).
                RETURN.
            ENDTRY.

*            DATA(it_final_master) = lv_json-to_product.


            IF it_final_master IS NOT INITIAL.
             DATA: lv_start_time TYPE string,
                  lv_end_time   TYPE string,
                  lv_diff_mins  TYPE i.

            DATA: lt_start TYPE t,
                  lt_end   TYPE t.

            DATA: lv_start_sec TYPE i,
                  lv_end_sec   TYPE i,
                  lv_diff_sec  TYPE i,
                  ls_prod_details TYPE zprod_details.

             LOOP AT it_final_master INTO DATA(wa_final_master1).
               IF wa_final_master1-shift = 'DAY'.
                 wa_final_master1-shift  = 'Day'.
               ELSEIF wa_final_master1-shift = 'NIGHT'.
                  wa_final_master1-shift  = 'Night'.
               ENDIF.
               modify it_final_master from wa_final_master1.
               clear: wa_final_master1.
             ENDLOOP.


              LOOP AT it_final_master INTO DATA(wa_final_master).

               data : var1 type I_MfgOrderConfirmation-ManufacturingOrder.
               var1 = |{ wa_final_master-productionorder ALPHA = IN }|.


                CLEAR: lv_start_time,lv_end_time,lt_start,lt_end,lv_start_sec,lv_end_sec,lv_diff_sec,lv_diff_mins.

                lv_start_time =  wa_final_master-start_time.
                lv_end_time   = wa_final_master-end_time.

                REPLACE ALL OCCURRENCES OF ':' IN lv_start_time WITH ''.
                REPLACE ALL OCCURRENCES OF ':' IN lv_end_time WITH ''.

                IF lv_start_time IS NOT INITIAL AND lv_end_time IS NOT INITIAL.

                lt_start = lv_start_time.
                lt_end   = lv_end_time.

                " Convert time to seconds
                lv_start_sec = ( lt_start+0(2) * 3600 ) + ( lt_start+2(2) * 60 ) + lt_start+4(2).
                lv_end_sec   = ( lt_end+0(2) * 3600 ) + ( lt_end+2(2) * 60 ) + lt_end+4(2).

                " Calculate difference in seconds
                lv_diff_sec = lv_end_sec - lv_start_sec.

                " Convert seconds to minutes
                lv_diff_mins = lv_diff_sec / 60.

                ELSE.
                  lv_diff_mins = 0.
                ENDIF.
                ls_prod_details-posting_date        = wa_final_master-posting_date.
                ls_prod_details-work_center         = wa_final_master-work_center.
                ls_prod_details-shift               = wa_final_master-shift.
                ls_prod_details-mfgorder            = var1.
                ls_prod_details-order_type          = wa_final_master-order_type.
                ls_prod_details-prod                = wa_final_master-product.
                ls_prod_details-prod_desc           = wa_final_master-product_description.
                ls_prod_details-rawqty              = wa_final_master-total_quantity.
                ls_prod_details-wstqty              = wa_final_master-total_wastage.
                ls_prod_details-plant_runtime       = wa_final_master-plant_runtime.
                ls_prod_details-actual_runtime      = lv_diff_mins.
                ls_prod_details-manual_actual_runtime = lv_diff_mins.
                ls_prod_details-difference_runtime  = wa_final_master-plant_runtime - lv_diff_mins.
                ls_prod_details-start_time          = wa_final_master-start_time.
                ls_prod_details-end_time            = wa_final_master-end_time.

                MODIFY zprod_details FROM @ls_prod_details.
                CLEAR : wa_final_master,ls_prod_details,var1.

              ENDLOOP.
              response->set_status( i_code = 200 i_reason = 'Success' ).
              response->set_text( 'Data updated successfully' ).
              RETURN.

            ELSE.
              response->set_status( i_code = 204 i_reason = 'No Content' ).
              response->set_text( 'No data provided' ).
              RETURN.
            ENDIF.

          WHEN OTHERS.
            response->set_status( i_code = 405 i_reason = 'Method Not Allowed' ).
            response->set_text( 'Only POST method is supported' ).
            RETURN.

        ENDCASE.

      CATCH cx_root INTO DATA(lx_error).
        response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
        RETURN.
        response->set_text( |Unexpected error: { lx_error->get_text( ) }| ).
        RETURN.

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
