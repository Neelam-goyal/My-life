class ZCL_C_HTTP_CURRENTSTOCK definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
  data it_data TYPE TABLE of zcurrentstock.
   METHODS: post_html IMPORTING data TYPE string RETURNING VALUE(message) TYPE string.
*   METHODS: deleteData IMPORTING gv_del_data TYPE string RETURNING VALUE(lv_msg) TYPE string.

protected section.
private section.
ENDCLASS.



CLASS ZCL_C_HTTP_CURRENTSTOCK IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.
  DATA(req)  = request->get_method( ).
    DATA(req2) = request->get_form_fields( ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(lv_delete) = VALUE #( req2[ name = 'delete' ]-value OPTIONAL ).

    CASE req.
      WHEN CONV string( if_web_http_client=>post ).

        DATA(data)     =  request->get_text( ).
        DATA(del_data) = request->get_text( ).

        IF lv_delete IS NOT INITIAL.
*          DATA(lvr_msg) = deleteData( del_data ).
*          response->set_text( lvr_msg ).
        ELSE.
          response->set_text( post_html( data ) ).
        ENDIF.
ENDCASE.
  endmethod.


METHOD post_html.

    IF data IS NOT INITIAL.
      TRY.
          DATA(count) = 0.
          message = data.
          /ui2/cl_json=>deserialize(
          EXPORTING
          json = data
          CHANGING
          data = it_data ).

          DATA wa TYPE zcurrentstock.
          TYPES: BEGIN OF ty_sum,
                   plant                				TYPE c LENGTH 4,
                   product              				TYPE c LENGTH 40,
                   inserted_date        				TYPE datn,
                   inserted_time        				TYPE timn,
                   plant_name           				TYPE c LENGTH 60,
                   product_type         				TYPE c LENGTH 4,
                   product_name         				TYPE c LENGTH 40,
                   material_base_unit   				TYPE c LENGTH 3,
                   opening_stock_value                  TYPE zcurrentstock-opening_stock_value,
                   adjustment_stock_value               TYPE zcurrentstock-adjustment_stock_value,
                   matlwrhsstkqtyinmatlbaseunit         type zcurrentstock-matlwrhsstkqtyinmatlbaseunit,
                   unposted_stock_inv_value             type zcurrentstock-unposted_stock_inv_value,
                   unposted_stock_unsold_value          type zcurrentstock-unposted_stock_unsold_value,
                   posted_stock_value                   type zcurrentstock-posted_stock_value,
                   posted_return_stock_value            TYPE zcurrentstock-posted_return_stock_value,
                   production_stock_value               type zcurrentstock-production_stock_value,
                   purchase_stock_value                 type zcurrentstock-purchase_stock_value,
                   calculate_stock                      type zcurrentstock-calculate_stock,
                 END OF ty_sum.
          DATA: it_qty TYPE TABLE OF ty_sum,
                wa_qty TYPE ty_sum.

          LOOP AT it_data ASSIGNING FIELD-SYMBOL(<wa_data>).

          wa-plant =  <wa_data>-plant.
          wa-product =  <wa_data>-product.
          wa-inserted_date = <wa_data>-inserted_date.
          wa-inserted_time = <wa_data>-inserted_time.
          wa-plant_name =  <wa_data>-plant_name.
          wa-product_type = <wa_data>-product_type.
          wa-product_name =  <wa_data>-product_name.
          wa-opening_stock_value = <wa_data>-opening_stock_value.
          wa-material_base_unit =  <wa_data>-material_base_unit.
          wa-matlwrhsstkqtyinmatlbaseunit = <wa_data>-matlwrhsstkqtyinmatlbaseunit.
          wa-unposted_stock_inv_value = <wa_data>-unposted_stock_inv_value.
          wa-unposted_stock_unsold_value = <wa_data>-unposted_stock_unsold_value.
          wa-posted_stock_value = <wa_data>-posted_stock_value.
          wa-posted_return_stock_value = <wa_data>-posted_return_stock_value.
          wa-production_stock_value =  <wa_data>-production_stock_value.
          wa-purchase_stock_value =  <wa_data>-purchase_stock_value.
          wa-adjustment_stock_value = <wa_data>-adjustment_stock_value.
          wa-calculate_stock =  <wa_data>-calculate_stock.

          MODIFY zcurrentstock FROM @wa.

          ENDLOOP.
              message = |Data uploaded successfully|.
        CATCH cx_static_check INTO DATA(er).
          message = |Something went wrong: { er->get_longtext(  ) }|.
         ENDTRY.
    ENDIF.


ENDMETHOD.
ENDCLASS.
