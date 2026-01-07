CLASS zcl_materialconsumption DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
    DATA: it_data TYPE TABLE OF zrepmaterials.

    METHODS: post_html IMPORTING data TYPE string RETURNING VALUE(message) TYPE string.
    METHODS: deleteData IMPORTING gv_del_data TYPE string RETURNING VALUE(lv_msg) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MATERIALCONSUMPTION IMPLEMENTATION.


  METHOD deleteData.
    IF gv_del_data IS NOT INITIAL.
      TRY.
          DATA(count) = 0.
          lv_msg = gv_del_data.
          /ui2/cl_json=>deserialize(
          EXPORTING
          json = gv_del_data
          CHANGING
          data = it_data ).

          LOOP AT it_data INTO DATA(wa_table).
            DELETE FROM zrepmaterials
            WHERE plant     = @wa_table-plant
            AND   material  = @wa_table-material
            AND   rangedate =  @wa_table-rangedate
            AND   todate    = @wa_table-todate.
          ENDLOOP.

          lv_msg = 'Data Deleted Successfully.'.
        CATCH cx_root INTO DATA(lv_error).
          lv_msg = lv_error->get_longtext( ).
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
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
          DATA(lvr_msg) = deleteData( del_data ).
          response->set_text( lvr_msg ).
        ELSE.
          response->set_text( post_html( data ) ).
        ENDIF.

    ENDCASE.
  ENDMETHOD.


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

          DATA wa TYPE zrepmaterials.
          TYPES: BEGIN OF ty_sum,
                   plant           TYPE c LENGTH 4,
                   rangedate       TYPE datn,
                   todate          TYPE datn,
                   material        TYPE c LENGTH 40,
                   batch           TYPE c LENGTH 10,
                   matDesc         TYPE c LENGTH 40,
                   um              TYPE c LENGTH 3,
                   ShiftDefinition TYPE c LENGTH 4,
                   qty             TYPE I_MaterialDocumentItem_2-QuantityInEntryUnit,
                 END OF ty_sum.
          DATA: it_qty TYPE TABLE OF ty_sum,
                wa_qty TYPE ty_sum.

          DATA lv_declareno TYPE i.
          lv_declareno = 1.

          SELECT FROM ZI_PlantTable FIELDS compcode, PlantCode
          WHERE CompCode IS NOT INITIAL
          INTO TABLE @DATA(lt_plant) PRIVILEGED ACCESS.

          LOOP AT it_data ASSIGNING FIELD-SYMBOL(<wa_data>).

            wa-plant            = <wa_data>-plant.
            wa-material         = |{ <wa_data>-material ALPHA = OUT }|.
            wa-quantity         = <wa_data>-quantity.
            wa-um               = <wa_data>-um.
            wa-rangedate        = <wa_data>-rangedate.
            wa-todate           = <wa_data>-todate.
            wa-shift            = <wa_data>-shift.
            wa-storagelocation  = to_upper( <wa_data>-storagelocation ).
            wa-matdesc          = <wa_data>-matdesc.
            wa-actual_qty       = <wa_data>-actual_qty.
            wa-difference       = <wa_data>-actual_qty - wa-quantity.
            wa-batch            = <wa_data>-batch.

            IF wa-plant IS NOT INITIAL AND wa-material IS NOT INITIAL
            AND wa-rangedate IS NOT INITIAL AND wa-todate IS NOT INITIAL.

              MODIFY zrepmaterials FROM @wa.

              SELECT FROM I_MaterialDocumentItem_2 AS a
              LEFT JOIN I_ProductText AS b ON a~Material =  b~Product AND b~Language = 'E'
              LEFT JOIN i_mfgorderconfirmation AS c ON c~MaterialDocument = a~MaterialDocument AND c~MaterialDocumentYear = a~MaterialDocumentYear
              FIELDS a~MaterialDocument, a~MaterialDocumentItem, a~MaterialDocumentYear, a~ReversedMaterialDocument,
              a~Material , a~Plant, a~StorageLocation, a~QuantityInEntryUnit, a~PostingDate, a~GoodsMovementType,
              a~MaterialBaseUnit, a~EntryUnit, a~Batch, b~ProductName, c~ShiftDefinition
              WHERE a~GoodsMovementType IN ( '261', '262' )
              AND a~Plant = @<wa_data>-plant AND a~Material = @<wa_data>-material
              AND a~Material IS NOT INITIAL
              AND a~PostingDate >= @<wa_data>-rangedate AND a~PostingDate <= @<wa_data>-todate
              INTO TABLE @DATA(lt_final) PRIVILEGED ACCESS.

              SORT lt_final BY Plant Material PostingDate ShiftDefinition.

              LOOP AT lt_final ASSIGNING FIELD-SYMBOL(<wa_final>).

                wa_qty-plant          = <wa_final>-Plant.
                wa_qty-rangedate      = <wa_final>-PostingDate.
                wa_qty-material       = <wa_final>-Material.
                wa_qty-batch          = wa-batch .
                wa_qty-matdesc        = <wa_final>-ProductName.
                wa_qty-um             = <wa_final>-EntryUnit.

                IF <wa_data>-shift IS NOT INITIAL.
                  wa_qty-shiftdefinition = <wa_final>-ShiftDefinition.
                ENDIF.

                IF <wa_final>-GoodsMovementType = '262'.
                  wa_qty-qty -= <wa_final>-QuantityInEntryUnit.
                ELSE.
                  wa_qty-qty  = <wa_final>-QuantityInEntryUnit.
                ENDIF.

                COLLECT wa_qty INTO it_qty.
                CLEAR wa_qty.
              ENDLOOP.

              DATA lv_totalqtysum TYPE I_MaterialDocumentItem_2-QuantityInEntryUnit.

              LOOP AT it_qty ASSIGNING FIELD-SYMBOL(<wa_matvar1>).

                READ TABLE lt_final INTO DATA(wa_lineexists1) WITH KEY Plant             = <wa_matvar1>-Plant
                                                                       Material          = <wa_matvar1>-Material
                                                                       PostingDate       = <wa_matvar1>-rangedate
                                                                       GoodsMovementType = '261'.
                IF wa_lineexists1 IS NOT INITIAL.
                  lv_totalqtysum += <wa_matvar1>-qty.
                  CLEAR wa_lineexists1.
                ENDIF.
              ENDLOOP.

              DATA wa_zmaterialdecl TYPE zmaterialdecl.
              LOOP AT it_qty ASSIGNING FIELD-SYMBOL(<wa_matvar>).

                READ TABLE lt_final INTO DATA(wa_lineexists) WITH KEY Plant             = <wa_matvar>-Plant
                                                        			  Material          = <wa_matvar>-Material
                                                        			  PostingDate       = <wa_matvar>-rangedate
                                                        			  GoodsMovementType = '261'.
                IF wa_lineexists IS NOT INITIAL.

                  READ TABLE lt_plant INTO DATA(wa_plant) WITH KEY PlantCode = <wa_matvar>-plant.
                  IF wa_plant IS NOT INITIAL.

                    <wa_matvar>-material           = |{ <wa_matvar>-material ALPHA = OUT }| .
                    wa_zmaterialdecl-plantcode     = <wa_matvar>-plant.
                    wa_zmaterialdecl-bukrs         = wa_plant-CompCode.
                    wa_zmaterialdecl-productcode   = <wa_matvar>-material.
                    wa_zmaterialdecl-batchno       = <wa_matvar>-batch.
                    wa_zmaterialdecl-productdesc   = <wa_matvar>-matdesc.
                    wa_zmaterialdecl-declaredate   = <wa_matvar>-rangedate.
                    wa_zmaterialdecl-uom 		   = <wa_matvar>-um.
                    wa_zmaterialdecl-declareno     = lv_declareno.
                    lv_declareno                  += 1.
                    wa_zmaterialdecl-stockquantity =  <wa_matvar>-qty + ( ( wa-difference * <wa_matvar>-qty ) / lv_totalqtysum ).

                    MODIFY zmaterialdecl FROM @wa_zmaterialdecl.
                  ENDIF.
                ENDIF.
                CLEAR: wa_plant, wa_zmaterialdecl, wa_lineexists.
              ENDLOOP.
            ENDIF.

            CLEAR :wa, wa_zmaterialdecl, lt_final, it_qty, lv_totalqtysum.
          ENDLOOP.

          message = |Data uploaded successfully|.
        CATCH cx_static_check INTO DATA(er).
          message = |Something went wrong: { er->get_longtext(  ) }|.
      ENDTRY.

    ELSE.
      message = |no data added|.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
