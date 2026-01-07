class ZCL_HTTP_BPDATASAVE definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .

  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
   CLASS-METHODS saveData
    IMPORTING
      VALUE(request)  TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message)  TYPE STRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_BPDATASAVE IMPLEMENTATION.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.

    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        response->set_text( saveData( request ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD saveData.

    DATA tt_json_structure TYPE TABLE OF zr_bpposting WITH EMPTY KEY.

    TRY.
        DATA(text) = request->get_text( ).

        xco_cp_json=>data->from_string( text )->write_to( REF #( tt_json_structure ) ).

        LOOP AT tt_json_structure INTO DATA(wa).

          IF wa-Amount1 NE wa-Amount2.
            message = 'Amount1 and Amount2 should be equal'.
          ENDIF.

          DATA(count) = CONV string( sy-tabix ).
          DATA(curTime) = cl_abap_context_info=>get_system_time( ).

          DATA: bp1 TYPE zr_bpposting-businesspartner1,
                bp2 TYPE zr_bpposting-businesspartner2.

          bp1 = |{ wa-Businesspartner1 ALPHA = IN }|.
          bp2 = |{ wa-Businesspartner2 ALPHA = IN }|.


          SELECT SINGLE FROM I_businesspartner
            FIELDS BusinessPartnerName
            WHERE Businesspartner = @bp1
            INTO @DATA(bp_check1).

          SELECT SINGLE FROM I_businesspartner
            FIELDS BusinessPartnerName
            WHERE Businesspartner = @bp2
            INTO @DATA(bp_check2).

          DATA(itemText1) = |Bal trf to ({ wa-BusinessPlace2 }{ COND #( WHEN wa-SpecialGlCode2 IS NOT INITIAL THEN |,SplGL-{ wa-SpecialGlCode2 }| ELSE '' ) }) { bp_check1 } |.
          DATA(itemText2) = |Bal trf from ({ wa-BusinessPlace1 }{ COND #( WHEN wa-SpecialGlCode1 IS NOT INITIAL THEN |,SplGL-{ wa-SpecialGlCode1 }| ELSE '' ) }) { bp_check2 } |.

          MODIFY ENTITIES OF zr_bpposting
         ENTITY ZrBpposting
         CREATE FIELDS (
              Companycode
              Documentdate
              Createdtime
              LineNum
              Postingdate
              Vouchertype
              Type1
              Type2
              Businesspartner1
              Businesspartner2
              SpecialGlCode1
              SpecialGlCode2
              Amount1
              Amount2
              Currencycode
              AmtType1
              AmtType2
              BusinessPlace1
              BusinessPlace2
              ProfitCenter1
              ProfitCenter2
              ItemText1
              ItemText2
              Assignment1
              Assignment2
              ErrorLog
               )
         WITH VALUE #( (
                     %cid                = getcid( )
                     Companycode         = wa-Companycode
                     Documentdate        = wa-Documentdate
                     Createdtime         = curTime
                     LineNum             = count
                     Postingdate         = wa-Postingdate
                     Vouchertype         = wa-Vouchertype
                     Type1               = wa-Type1
                     Type2               = wa-Type2
                     Businesspartner1    = wa-Businesspartner1
                     Businesspartner2    = wa-Businesspartner2
                     SpecialGlCode1      = wa-SpecialGlCode1
                     SpecialGlCode2      = wa-SpecialGlCode2
                     Amount1             = wa-Amount1
                     Amount2             = wa-Amount2
                     Currencycode        = 'INR'
                     AmtType1           = wa-AmtType1
                     AmtType2           = wa-AmtType2
                     BusinessPlace1     = wa-BusinessPlace1
                     BusinessPlace2     = wa-BusinessPlace2
                     ProfitCenter1      = wa-ProfitCenter1
                     ProfitCenter2      = wa-ProfitCenter2
                     ItemText1          = itemText1
                     ItemText2          = itemText2
                     Assignment1        = wa-Assignment1
                     Assignment2        = wa-Assignment2
                     ErrorLog           = message

              ) )
          REPORTED DATA(ls_po_reported)
          FAILED   DATA(ls_po_failed)
          MAPPED   DATA(ls_po_mapped).

          COMMIT ENTITIES BEGIN
             RESPONSE OF zr_bpposting
             FAILED DATA(ls_save_failed)
             REPORTED DATA(ls_save_reported).

          IF ls_po_failed IS NOT INITIAL OR ls_save_failed IS NOT INITIAL.
            message = 'Failed to save data'.
          ELSE.
            message = 'Data saved successfully'.
          ENDIF.

          COMMIT ENTITIES END.

          CLEAR: message.
        ENDLOOP.

      CATCH cx_root INTO DATA(lx_root).
        message = |General Error: { lx_root->get_text( ) }|.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
