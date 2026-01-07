class ZCL_HTTP_PLANTTABLE_EXCEL definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
   DATA :tb_data       TYPE TABLE OF ztable_plant,
          lt_json_table TYPE TABLE OF ztable_plant,
          wa_data       TYPE ztable_plant.

    METHODS: post_html IMPORTING data TYPE string RETURNING VALUE(message) TYPE string.

    DATA: lv_json TYPE string.

protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_PLANTTABLE_EXCEL IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

    DATA(req_method) = request->get_method( ).

    CASE req_method.
      WHEN CONV string( if_web_http_client=>post ).

        " Handle POST request

        DATA(data) = request->get_text( ).

        response->set_text( post_html( data ) ).

    ENDCASE.
  endmethod.


   METHOD post_html.

     IF data IS NOT INITIAL.

       TRY.

           DATA(count) = 0.
           message =  data.

           /ui2/cl_json=>deserialize(
         EXPORTING
           json = data
         CHANGING
           data = tb_data
       ).

           LOOP AT tb_data INTO DATA(wa).
             MODIFY ztable_plant FROM @wa.
           ENDLOOP.

           message = |Data uploading Successfully done. |.


         CATCH cx_static_check INTO DATA(er).

           message = |Something Went Wrong: { er->get_longtext( ) }|.

       ENDTRY.

     ELSE.

       message = |No Data Added|.

     ENDIF.


   ENDMETHOD.
ENDCLASS.
