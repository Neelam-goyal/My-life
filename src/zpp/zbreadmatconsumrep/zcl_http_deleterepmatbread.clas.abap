class ZCL_HTTP_DELETEREPMATBREAD definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
   CLASS-METHODS saveData
    IMPORTING
      VALUE(request) TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message) TYPE string .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_DELETEREPMATBREAD IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        response->set_text( saveData( request ) ).

    ENDCASE.

  ENDMETHOD.


   METHOD saveData.

     TYPES: BEGIN OF ty_data,
              Plant     TYPE werks_d,
              Material  TYPE matnr,
              Rangedate TYPE string,
              Todate    TYPE string,
              Shift     TYPE string,
            END OF ty_data.


     DATA tt_json_structure TYPE TABLE OF ty_data WITH EMPTY KEY.
     TRY.
         xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

         LOOP AT tt_json_structure INTO DATA(wa).


           MODIFY ENTITIES OF zr_repmatbread
           ENTITY zrrepmatbread
           DELETE FROM VALUE #( (
                %key-Material = wa-material
                %key-Plant = wa-plant
                %key-Rangedate = wa-rangedate
                %key-Todate = wa-todate
                %key-Shift = wa-shift
            ) )
           FAILED DATA(failed1)
           REPORTED DATA(reported1).

           COMMIT ENTITIES.

           IF wa-shift IS INITIAL.
             DELETE FROM zmatvarbread
                WHERE creationdate >= @wa-Rangedate AND creationdate <= @wa-Todate
                      AND product = @wa-Material
                      AND plant_code = @wa-Plant.
           ELSE.
             DELETE FROM zmatvarbread
             WHERE creationdate >= @wa-Rangedate AND creationdate <= @wa-Todate
                   AND product = @wa-Material
                   AND plant_code = @wa-Plant
                   AND shift = @wa-shift.
           ENDIF.

         ENDLOOP.

       CATCH cx_root INTO DATA(lx_root).
         message = |General Error: { lx_root->get_text( ) }|.
     ENDTRY.

   ENDMETHOD.
ENDCLASS.
