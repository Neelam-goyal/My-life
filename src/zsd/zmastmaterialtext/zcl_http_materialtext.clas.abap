CLASS zcl_http_materialtext DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
    DATA :tb_data       TYPE TABLE OF zmaterialtext,
          lt_json_table TYPE TABLE OF zmaterialtext,
          wa_data       TYPE zmaterialtext.

    METHODS: post_html IMPORTING data TYPE string RETURNING VALUE(message) TYPE string.

    DATA: lv_json TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_MATERIALTEXT IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req_method) = request->get_method( ).

    CASE req_method.
      WHEN CONV string( if_web_http_client=>post ).

        " Handle POST request

        DATA(data) = request->get_text( ).

        response->set_text( post_html( data ) ).

    ENDCASE.

  ENDMETHOD.


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
*            insert INTO zmaterialtext VALUES @wa.
            MODIFY zmaterialtext FROM @wa.
          ENDLOOP.


*           LOOP AT tb_data INTO DATA(wa).
*             MODIFY zmaterialtext FROM @wa.
*           ENDLOOP.

          message = |Data uploading Successfully done. |.


        CATCH cx_static_check INTO DATA(er).

          message = |Something Went Wrong: { er->get_longtext( ) }|.

      ENDTRY.

    ELSE.

      message = |No Data Added|.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
