class ZCL_HTTP_ACTIVITYDECL_EXCEL definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
   DATA :tb_data       TYPE TABLE OF zactivitydecl,
          lt_json_table TYPE TABLE OF zactivitydecl,
          wa_data       TYPE zactivitydecl.

    METHODS: post_html IMPORTING data TYPE string RETURNING VALUE(message) TYPE string.

    DATA: lv_json TYPE string.

protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_ACTIVITYDECL_EXCEL IMPLEMENTATION.


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

      data : i type int4.
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

               SELECT SINGLE FROM i_workcenter WITH PRIVILEGED ACCESS
               FIELDS WorkCenterInternalID,WorkCenter
               where WorkCenterInternalID = @wa-workcenterid
               into  @data(wc).

             wa-workcenter = wc-WorkCenter.
*             wa-created_at           = cl_abap_context_info=>get_system_time( ).
*             wa-created_by =        cl_abap_context_info=>get_user_alias( ).
*             wa-last_changed_by = cl_abap_context_info=>get_user_ALIAS( ).
*             wa-last_changed_at      = Cl_abap_context_info=>get_system_time( ).



                select declareno from zactivitydecl
                    where declaredate = @wa-declaredate and plantcode = @wa-plantcode
                    order by declareno DESCENDING
                    into TABLE @data(wn).
               i = 1.

                LOOP AT wn INTO data(wn_data).
                  i += 1.
               ENDLOOP.
               wa-declareno = i.


             MODIFY zactivitydecl FROM @wa.

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
