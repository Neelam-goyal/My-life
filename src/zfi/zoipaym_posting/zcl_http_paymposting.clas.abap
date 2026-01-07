class ZCL_HTTP_PAYMPOSTING definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
  CLASS-METHODS saveData
    IMPORTING
      VALUE(request) TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message) TYPE string .

  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_PAYMPOSTING IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

   CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        response->set_text( saveData( request ) ).

    ENDCASE.

  endmethod.


  METHOD saveData.

    TYPES: BEGIN OF ty_data,
             Companycode            TYPE bukrs,
             Documentdate           TYPE c LENGTH 10,
             Bpartner               TYPE lifnr,
             SpecialGlCode          TYPE c LENGTH 1,
             AccountingDocumenttype TYPE blart,
             Postingdate            TYPE c LENGTH 10,
             Type                   TYPE c LENGTH 20,
             Businessplace          TYPE werks_d,
             Sectioncode            TYPE bukrs,
             Gltext                 TYPE text100,
             Glaccount              TYPE saknr,
             Housebank              TYPE hbkid,
             glamount               TYPE p LENGTH 16 DECIMALS 2,
             Assignmentreference    TYPE dzuonr,
             Accountid              TYPE hktid,
             Profitcenter           TYPE prctr,
             Costcenter             TYPE kostl,
             Currencycode           TYPE waers,
             wbselement             TYPE C LENGTH 24,
             ReferenceId            TYPE string,
           END OF ty_data.



    DATA tt_json_structure TYPE TABLE OF ty_data WITH EMPTY KEY.
    TRY.
        xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

        LOOP AT tt_json_structure INTO DATA(wa).

          DATA(count) = CONV string( sy-tabix ).
          DATA(bpPartner) = |{ wa-Bpartner ALPHA = IN }|.

          MODIFY ENTITIES OF zr_oipayments
          ENTITY ZrOipayments
          CREATE FIELDS (
            Companycode
            Documentdate
            Bpartner
            Createdtime
            SpecialGlCode
            LineNum
            Postingdate
            AccountingDocumenttype
            Glamount
            Type
            Businessplace
            Sectioncode
            Gltext
            Glaccount
            Housebank
            Accountid
            Profitcenter
            Costcenter
            Currencycode
            Assignmentreference
            ReferenceID
            Wbselement
          )
          WITH VALUE #( (
              %cid = getCID( )
              Companycode = wa-companycode
              Documentdate = wa-documentdate
              Bpartner = bpPartner
              Createdtime = cl_abap_context_info=>get_system_time( )
              SpecialGlCode = wa-specialglcode
              LineNum = |{ count ALPHA = IN }|
              Postingdate = wa-postingdate
              AccountingDocumenttype = wa-accountingdocumenttype
              Glamount = wa-glamount
              Type = wa-type
              Businessplace = wa-businessplace
              Sectioncode = wa-sectioncode
              Gltext = wa-gltext
              Glaccount = wa-glaccount
              Housebank = wa-housebank
              Accountid = wa-accountid
              Profitcenter = wa-profitcenter
              Costcenter = wa-costcenter
              Currencycode = wa-currencycode
              Assignmentreference = wa-assignmentreference
              ReferenceID = wa-referenceid
              Wbselement = wa-wbselement
          ) )
          REPORTED DATA(ls_po_reported)
          FAILED   DATA(ls_po_failed)
          MAPPED   DATA(ls_po_mapped).

          COMMIT ENTITIES BEGIN
             RESPONSE OF zr_oipayments
             FAILED DATA(ls_save_failed)
             REPORTED DATA(ls_save_reported).

          IF ls_po_failed IS NOT INITIAL OR ls_save_failed IS NOT INITIAL.
            message = 'Failed to save data'.
          ELSE.
            message = 'Data saved successfully'.
          ENDIF.

          COMMIT ENTITIES END.
        ENDLOOP.


      CATCH cx_root INTO DATA(lx_root).
        message = |General Error: { lx_root->get_text( ) }|.
    ENDTRY.

  ENDMETHOD.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
