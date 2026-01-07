class ZCL_HTTP_ADVPAYMPOST definition
  public
  create public .

PUBLIC SECTION.

  INTERFACES if_http_service_extension .
  INTERFACES if_oo_adt_classrun.


   TYPES: BEGIN OF ty_json_structure,
                 companycode   TYPE c LENGTH 4,
                 documentdate  TYPE c LENGTH 10,
                 bpartner      TYPE c LENGTH 10,
                 SpecialGlCode TYPE c LENGTH 2,
                 createdtime   TYPE c LENGTH 6,
                 linenum      TYPE zr_oipayments-LineNum,
               END OF ty_json_structure.


  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
  CLASS-METHODS postData
    IMPORTING
      request        TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message) TYPE string .

  CLASS-METHODS postAdvData
    IMPORTING
        wa_data  TYPE zr_oipayments
        psDate TYPE string
        dcDate TYPE string
    RETURNING
      VALUE(message) TYPE string .


protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_ADVPAYMPOST IMPLEMENTATION.


 METHOD if_oo_adt_classrun~main.
 UPDATE zoipayments SET type = 'ADVC' , documenttype = 'KZ'
 WHERE companycode = 'BBPL'.
 ENDMETHOD.


       METHOD getCID.
        TRY.
            cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
          CATCH cx_uuid_error.
            ASSERT 1 = 0.
        ENDTRY.
      ENDMETHOD.


 METHOD IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

        CASE request->get_method(  ).
          WHEN CONV string( if_web_http_client=>post ).
           response->set_text( postData( request ) ).

        ENDCASE.


      ENDMETHOD.


      METHOD postData.

        DATA: wa_oipaym TYPE zr_oipayments.
        DATA tt_json_structure TYPE TABLE OF ty_json_structure WITH EMPTY KEY.

        TRY.

            xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

            LOOP AT tt_json_structure INTO DATA(wa).

            wa-bpartner = |{ wa-bpartner ALPHA = IN }|.

                SELECT SINGLE * FROM zr_oipayments
                WHERE Companycode = @wa-companycode AND Documentdate = @wa-documentdate AND Bpartner = @wa-bpartner
                AND Createdtime = @wa-createdtime AND SpecialGlCode = @wa-specialglcode AND LineNum = @wa-linenum
                AND AccountingDocumenttype = 'KZ' AND Isdeleted = '' AND Isposted = ''
                AND ( Type = 'ADVC' OR SpecialGlCode <> '' )
                INTO @DATA(wa_data).

                  DATA(psDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( wa_data-postingdate ) datetype = 'Posting' ).
                  FIND 'Invalid' IN psDate.
                  IF sy-subrc = 0.
                    message = psDate.
                    RETURN.
                  ENDIF.

                  DATA(dcDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( wa_data-Documentdate ) datetype = 'Document' ).
                  FIND 'Invalid' IN dcDate.
                  IF sy-subrc = 0.
                    message = dcDate.
                    RETURN.
                  ENDIF.

              message = postAdvData( wa_data = wa_data psdate = psDate dcdate = dcDate ).

            ENDLOOP.

          CATCH cx_sy_conversion_no_date INTO DATA(lx_date).
            message = |Error in Date Conversion: { lx_date->get_text( ) }|.

          CATCH cx_sy_conversion_no_time INTO DATA(lx_time).
            message = |Error in Time Conversion: { lx_time->get_text( ) }|.

          CATCH cx_sy_open_sql_db INTO DATA(lx_sql).
            message = |SQL Error: { lx_sql->get_text( ) }|.

          CATCH cx_root INTO DATA(lx_root).
            message = |General Error: { lx_root->get_text( ) }|.
        ENDTRY.

      ENDMETHOD.


      METHOD postAdvData.

        DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
              document   TYPE string.


*        SELECT SINGLE FROM zr_oipayments
*        FIELDS SUM( glamount ) AS Glamount
*        WHERE Companycode = @wa_data-companycode AND Documentdate = @wa_data-documentdate AND Bpartner = @wa_data-bpartner
*               AND AccountingDocumenttype = 'KZ' AND Isdeleted = '' AND Isposted = ''
*               AND ( Type = 'ADVC' OR SpecialGlCode <> '' )
*        INTO @DATA(Glamount).
*
*
*        SELECT SINGLE FROM zr_oipayments
*        FIELDS Bpartner, Businessplace, Glamount,Currencycode,SpecialGlCode, LineNum, Companycode, Documentdate, Createdtime
*        WHERE Companycode = @wa_data-companycode AND Documentdate = @wa_data-documentdate AND Bpartner = @wa_data-bpartner
*               AND Createdtime = @wa_data-createdtime AND SpecialGlCode = @wa_data-specialglcode AND LineNum = @wa_data-linenum
*               AND AccountingDocumenttype = 'KZ' AND Isdeleted = '' AND Isposted = ''
*               AND ( Type = 'ADVC' OR SpecialGlCode <> '' )
*        INTO @DATA(wa_data2).

*        APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
*        <je_deep>-%cid = getCid(  ).
*        <je_deep>-%param = VALUE #(
*        companycode = wa_data-Companycode
*        businesstransactiontype = 'RFBU'
*        accountingdocumenttype = wa_data-AccountingDocumenttype
*        AccountingDocumentHeaderText = wa_data-Gltext
*        CreatedByUser = sy-uname
*        documentdate = dcDate
*        postingdate =  COND #( WHEN psDate IS INITIAL
*                          THEN cl_abap_context_info=>get_system_date( )
*                          ELSE psDate )
*
*        _apitems = VALUE #( FOR wa_data1 IN lv_oipaym1  INDEX INTO i ( glaccountlineitem = |{ i WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
*                           Supplier = wa_data1-Bpartner
*                           BusinessPlace = wa_data1-Businessplace
*                           SpecialGLCode = wa_data1-SpecialGlCode
*                            DocumentItemText = wa_data-Gltext
*                            _currencyamount = VALUE #( (
*                                                currencyrole = '00'
*                                                journalentryitemamount = wa_data1-Glamount
*                                                currency = wa_data1-Currencycode ) ) )
*                           )
*        _glitems = VALUE #(
*                            ( glaccountlineitem = |{ ( lines( lv_oipaym1 ) + 1 ) WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
*                            glaccount = wa_data-Glaccount
*                            HouseBank = wa_data-Housebank
*                            HouseBankAccount = wa_data-Accountid
*                            AssignmentReference = wa_data-Assignmentreference
*                              ProfitCenter = wa_data-Profitcenter
*                               DocumentItemText = wa_data-Gltext
*                            _currencyamount = VALUE #( (
*                                                currencyrole = '00'
*                                                journalentryitemamount = Glamount * -1
*                                                currency = wa_data-Currencycode ) ) ) )
*        ).


        APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
        <je_deep>-%cid = getCid(  ).
        <je_deep>-%param = VALUE #(
        companycode = wa_data-Companycode
        businesstransactiontype = 'RFBU'
        accountingdocumenttype = wa_data-AccountingDocumenttype
        AccountingDocumentHeaderText = wa_data-Gltext
        CreatedByUser = sy-uname
        documentdate = dcDate
        postingdate =  COND #( WHEN psDate IS INITIAL
                          THEN cl_abap_context_info=>get_system_date( )
                          ELSE psDate )

        _apitems = VALUE #(
                          ( glaccountlineitem = |002|
                            Supplier = wa_data-Bpartner
                            BusinessPlace = wa_data-Businessplace
                            SpecialGLCode = wa_data-SpecialGlCode
                            DocumentItemText = wa_data-Gltext
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-Glamount
                                                currency = wa_data-Currencycode ) ) )
                          )
        _glitems = VALUE #(
                            ( glaccountlineitem = '001'
                              glaccount = wa_data-Glaccount
                              HouseBank = wa_data-Housebank
                              HouseBankAccount = wa_data-Accountid
                              AssignmentReference = wa_data-Assignmentreference
                              ProfitCenter = wa_data-Profitcenter
                              DocumentItemText = wa_data-Gltext
                              _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount =  wa_data-Glamount * -1
                                                currency = wa_data-Currencycode ) ) ) )
           ).

        MODIFY ENTITIES OF i_journalentrytp PRIVILEGED
        ENTITY journalentry
        EXECUTE post FROM lt_je_deep
        FAILED DATA(ls_failed_deep)
        REPORTED DATA(ls_reported_deep)
        MAPPED DATA(ls_mapped_deep).

        IF ls_failed_deep IS NOT INITIAL.

          LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
            message = <ls_reported_deep>-%msg->if_message~get_text( ).
          ENDLOOP.
          RETURN.
        ELSE.

          COMMIT ENTITIES BEGIN
          RESPONSE OF i_journalentrytp
          FAILED DATA(lt_commit_failed)
          REPORTED DATA(lt_commit_reported).

          IF lt_commit_reported IS NOT INITIAL.
            LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported>).
              document = <ls_reported>-AccountingDocument.
            ENDLOOP.
          ELSE.
            LOOP AT lt_commit_failed-journalentry ASSIGNING FIELD-SYMBOL(<ls_failed>).
              message = <ls_failed>-%fail-cause.
            ENDLOOP.
            RETURN.
          ENDIF.

          COMMIT ENTITIES END.

          IF document IS NOT INITIAL.
            message = |Document Created Successfully: { document }|.


              MODIFY ENTITIES OF zr_oipayments
              ENTITY ZrOipayments
              UPDATE FIELDS ( Accountingdocument Postingdate Isposted )
              WITH VALUE #(  (
                  Accountingdocument = document
                  Postingdate =  COND #( WHEN psDate IS INITIAL
                                    THEN cl_abap_context_info=>get_system_date( )
                                    ELSE psDate )
                  Isposted = abap_true
                  Companycode = wa_data-Companycode
                  Documentdate = wa_data-Documentdate
                  Bpartner = wa_data-Bpartner
                  Createdtime = wa_data-Createdtime
                  SpecialGlCode = wa_data-SpecialGlCode
                  LineNum = wa_data-LineNum
                  )  )
              FAILED DATA(lt_failed)
              REPORTED DATA(lt_reported).

              COMMIT ENTITIES BEGIN
              RESPONSE OF zr_oipayments
              FAILED DATA(lt_commit_failed2)
              REPORTED DATA(lt_commit_reported2).
              ..
              COMMIT ENTITIES END.

          ELSE.
            message = |Document Creation Failed: { message }|.
            EXIT.
          ENDIF.

        ENDIF.

        CLEAR lt_je_deep.

      ENDMETHOD.
ENDCLASS.
