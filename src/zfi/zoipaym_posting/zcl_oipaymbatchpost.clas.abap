CLASS zcl_oipaymbatchpost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun.

    TYPES: BEGIN OF ty_json_structure,
             companycode  TYPE c LENGTH 4,
             documentdate TYPE c LENGTH 10,
             bpartner     TYPE c LENGTH 10,
           END OF ty_json_structure.


    CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

    CLASS-METHODS postData

      RETURNING
        VALUE(message) TYPE string.

    CLASS-METHODS postDZDocuments.
    CLASS-METHODS postKZEZDocuments.
    CLASS-METHODS postCPDocuments.
    CLASS-METHODS postKRDocuments.
    CLASS-METHODS postCRDocuments.
    CLASS-METHODS postDGDocuments.
    CLASS-METHODS postKZSPLGLDocuments.
    CLASS-METHODS postKGDocuments.
    CLASS-METHODS updatePostedDocs.
    class-METHODS postEkDocuments.

    CLASS-METHODS  updateErrorLog
      IMPORTING
        wa_data TYPE zr_oipayments
        message TYPE string .

    CLASS-METHODS  updateErrorLogAdv
      IMPORTING
        wa_data TYPE ty_json_structure
        message TYPE string .

PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_OIPAYMBATCHPOST IMPLEMENTATION.


     METHOD getCID.
        TRY.
            cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
          CATCH cx_uuid_error.
            ASSERT 1 = 0.
        ENDTRY.
      ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    postData( ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    postData( ).
  ENDMETHOD.


  METHOD updateErrorLog.

    UPDATE zoipayments SET Error_Log = @message
         WHERE companycode = @wa_data-Companycode
           AND Documentdate = @wa_data-Documentdate
           AND Bpartner = @wa_data-Bpartner
           AND Createdtime = @wa_data-Createdtime
           AND special_gl_code = @wa_data-SpecialGlCode
           AND line_no = @wa_data-LineNum.

  ENDMETHOD.


    METHOD updateErrorLogAdv.

    UPDATE zoipayments SET Error_Log = @message
         WHERE companycode = @wa_data-Companycode
           AND Documentdate = @wa_data-Documentdate
           AND Bpartner = @wa_data-Bpartner.

  ENDMETHOD.


  METHOD postDZDocuments.

    SELECT * FROM zr_oipayments
      WHERE isdeleted = ''
              AND isposted  = ''
              AND ApprovedBy IS NOT INITIAL
              AND ApprovedAt IS NOT INITIAL
              AND AccountingDocumenttype = 'DZ'
     INTO TABLE @DATA(lt_input).

    LOOP AT lt_input INTO DATA(ls_input).


      DATA(psDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-postingdate ) datetype = 'Posting' ).
      FIND 'Invalid' IN psDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = psDate ).
        CONTINUE.
      ENDIF.

      DATA(dcDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-Documentdate ) datetype = 'Document' ).
      FIND 'Invalid' IN dcDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = dcDate ).
        CONTINUE.
      ENDIF.

      DATA(message) = zcl_http_oipaympost=>postCustomerPayment( wa_data = ls_input psdate = psDate dcdate = dcDate ).
      updateerrorlog( wa_data = ls_input message = message ).

    ENDLOOP.


  ENDMETHOD.


 METHOD postKGDocuments.

    SELECT * FROM zr_oipayments
      WHERE isdeleted = ''
              AND isposted  = ''
              AND ApprovedBy IS NOT INITIAL
              AND ApprovedAt IS NOT INITIAL
              AND AccountingDocumenttype = 'KG'
     INTO TABLE @DATA(lt_input).

    LOOP AT lt_input INTO DATA(ls_input).


      DATA(psDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-postingdate ) datetype = 'Posting' ).
      FIND 'Invalid' IN psDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = psDate ).
        CONTINUE.
      ENDIF.

      DATA(dcDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-Documentdate ) datetype = 'Document' ).
      FIND 'Invalid' IN dcDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = dcDate ).
        CONTINUE.
      ENDIF.

      DATA(message) = zcl_kgpayments=>postkgpayments( wa_data = ls_input psdate = psDate dcdate = dcDate ).
      updateerrorlog( wa_data = ls_input message = message ).

    ENDLOOP.


  ENDMETHOD.


METHOD postCRDocuments.

    SELECT * FROM zr_oipayments
      WHERE isdeleted = ''
              AND isposted  = ''
              AND ApprovedBy IS NOT INITIAL
              AND ApprovedAt IS NOT INITIAL
              AND AccountingDocumenttype = 'CR'
     INTO TABLE @DATA(lt_input).

    LOOP AT lt_input INTO DATA(ls_input).


      DATA(psDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-postingdate ) datetype = 'Posting' ).
      FIND 'Invalid' IN psDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = psDate ).
        CONTINUE.
      ENDIF.

      DATA(dcDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-Documentdate ) datetype = 'Document' ).
      FIND 'Invalid' IN dcDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = dcDate ).
        CONTINUE.
      ENDIF.

      DATA(message) = zcl_crpayments=>postcrpayments( wa_data = ls_input psdate = psDate dcdate = dcDate ).
      updateerrorlog( wa_data = ls_input message = message ).

    ENDLOOP.


  ENDMETHOD.


METHOD postDGDocuments.

    SELECT * FROM zr_oipayments
      WHERE isdeleted = ''
              AND isposted  = ''
              AND ApprovedBy IS NOT INITIAL
              AND ApprovedAt IS NOT INITIAL
              AND AccountingDocumenttype = 'DG'
     INTO TABLE @DATA(lt_input).

    LOOP AT lt_input INTO DATA(ls_input).


      DATA(psDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-postingdate ) datetype = 'Posting' ).
      FIND 'Invalid' IN psDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = psDate ).
        CONTINUE.
      ENDIF.

      DATA(dcDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-Documentdate ) datetype = 'Document' ).
      FIND 'Invalid' IN dcDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = dcDate ).
        CONTINUE.
      ENDIF.

      DATA(message) = zcl_dgpayments=>postdgdocuments( wa_data = ls_input psdate = psDate dcdate = dcDate ).
      updateerrorlog( wa_data = ls_input message = message ).

    ENDLOOP.


  ENDMETHOD.


  METHOD updatePostedDocs.

    SELECT FROM zr_oipayments
    FIELDS ErrorLog, Companycode, Documentdate ,Bpartner, Createdtime, SpecialGlCode, LineNum, Postingdate
    WHERE   isdeleted = ''
            AND isposted  = ''
            AND ErrorLog IS NOT INITIAL
    INTO TABLE @DATA(lt_input).

    LOOP AT lt_input INTO DATA(ls_input).

      DATA lv_number TYPE string.
      DATA lv_match  TYPE string.

      FIND REGEX 'Document Created Successfully:\s*(\d+)' IN ls_input-ErrorLog SUBMATCHES lv_number.

      IF sy-subrc = 0.

        DATA(doc_date) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-documentdate ) datetype = 'Document' ).

        SELECT SINGLE FROM I_journalentry
            FIELDS AccountingDocument
            WHERE Companycode = @ls_input-Companycode
                AND Documentdate = @doc_date
                AND AccountingDocument = @lv_number
            INTO @lv_match.

        IF lv_match IS INITIAL.
          CONTINUE.
        ENDIF.

        MODIFY ENTITIES OF zr_oipayments
           ENTITY ZrOipayments
           UPDATE FIELDS ( Accountingdocument Postingdate Isposted )
           WITH VALUE #(  (
               Accountingdocument = lv_number
               Postingdate = ls_input-Postingdate
               Isposted = abap_true
               Companycode = ls_input-Companycode
               Documentdate = ls_input-Documentdate
               Bpartner = ls_input-Bpartner
               Createdtime = ls_input-Createdtime
               SpecialGlCode = ls_input-SpecialGlCode
               LineNum = ls_input-LineNum
               )  )
           FAILED DATA(lt_failed)
           REPORTED DATA(lt_reported).

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_oipayments
        FAILED DATA(lt_commit_failed2)
        REPORTED DATA(lt_commit_reported2).

        ...
        COMMIT ENTITIES END.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD postKRDocuments.

    SELECT * FROM zr_oipayments
      WHERE isdeleted = ''
              AND isposted  = ''
              AND ApprovedBy IS NOT INITIAL
              AND ApprovedAt IS NOT INITIAL
              AND AccountingDocumenttype = 'KR'
     INTO TABLE @DATA(lt_input).

    LOOP AT lt_input INTO DATA(ls_input).


      DATA(psDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-postingdate ) datetype = 'Posting' ).
      FIND 'Invalid' IN psDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = psDate ).
        CONTINUE.
      ENDIF.

      DATA(dcDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-Documentdate ) datetype = 'Document' ).
      FIND 'Invalid' IN dcDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = dcDate ).
        CONTINUE.
      ENDIF.

      DATA(message) = zcl_http_expenspaympost=>postexpensepaym( wa_data = ls_input psdate = psDate dcdate = dcDate ).
      updateerrorlog( wa_data = ls_input message = message ).

    ENDLOOP.


  ENDMETHOD.


  METHOD postCPDocuments.

    SELECT * FROM zr_oipayments
      WHERE isdeleted = ''
              AND isposted  = ''
              AND ApprovedBy IS NOT INITIAL
              AND ApprovedAt IS NOT INITIAL
              AND AccountingDocumenttype = 'CP'
     INTO TABLE @DATA(lt_input).

    LOOP AT lt_input INTO DATA(ls_input).


      DATA(psDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-postingdate ) datetype = 'Posting' ).
      FIND 'Invalid' IN psDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = psDate ).
        CONTINUE.
      ENDIF.

      DATA(dcDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-Documentdate ) datetype = 'Document' ).
      FIND 'Invalid' IN dcDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = dcDate ).
        CONTINUE.
      ENDIF.

      DATA(message) = zcl_http_oipaympost=>postcashpayment( wa_data = ls_input psdate = psDate dcdate = dcDate ).
      updateerrorlog( wa_data = ls_input message = message ).

    ENDLOOP.
  ENDMETHOD.


   METHOD postKZEZDocuments.

     SELECT * FROM zr_oipayments
       WHERE isdeleted = ''
               AND isposted  = ''
               AND ApprovedBy IS NOT INITIAL
               AND ApprovedAt IS NOT INITIAL
               AND AccountingDocumenttype IN ( 'KZ', 'EZ' )
               AND SpecialGlCode = ''
      INTO TABLE @DATA(lt_input).

     LOOP AT lt_input INTO DATA(ls_input).


       DATA(psDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-postingdate ) datetype = 'Posting' ).
       FIND 'Invalid' IN psDate.
       IF sy-subrc = 0.
         updateerrorlog( wa_data = ls_input message = psDate ).
         CONTINUE.
       ENDIF.

       DATA(dcDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-Documentdate ) datetype = 'Document' ).
       FIND 'Invalid' IN dcDate.
       IF sy-subrc = 0.
         updateerrorlog( wa_data = ls_input message = dcDate ).
         CONTINUE.
       ENDIF.

       DATA(message) = zcl_http_oipaympost=>postSupplierPayment( wa_data = ls_input psdate = psDate dcdate = dcDate ).
       updateerrorlog( wa_data = ls_input message = message ).

     ENDLOOP.


   ENDMETHOD.


    METHOD postKZSPLGLDocuments.

      SELECT * FROM zr_oipayments
        WHERE isdeleted = ''
                AND isposted  = ''
                AND ApprovedBy IS NOT INITIAL
                AND ApprovedAt IS NOT INITIAL
                AND AccountingDocumenttype = 'KZ'
                AND SpecialGlCode <> ''
       INTO TABLE @DATA(lt_input).

      LOOP AT lt_input INTO DATA(ls_input).

        DATA(psDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-postingdate ) datetype = 'Posting' ).
        FIND 'Invalid' IN psDate.
        IF sy-subrc = 0.
          updateerrorlog( wa_data = ls_input message = psDate ).
          CONTINUE.
        ENDIF.

        DATA(dcDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-Documentdate ) datetype = 'Document' ).
        FIND 'Invalid' IN dcDate.
        IF sy-subrc = 0.
          updateerrorlog( wa_data = ls_input message = dcDate ).
          CONTINUE.
        ENDIF.

        DATA(message) = zcl_http_advpaympost=>postadvdata( wa_data = ls_input psdate = psDate dcdate = dcDate ).
        updateerrorlog( wa_data = ls_input message = message ).

      ENDLOOP.


    ENDMETHOD.


    METHOD postEKDocuments.

    SELECT * FROM zr_oipayments
      WHERE isdeleted = ''
              AND isposted  = ''
              AND ApprovedBy IS NOT INITIAL
              AND ApprovedAt IS NOT INITIAL
              AND AccountingDocumenttype = 'EK'
     INTO TABLE @DATA(lt_input).

    LOOP AT lt_input INTO DATA(ls_input).

        DATA(psDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-postingdate ) datetype = 'Posting' ).
      FIND 'Invalid' IN psDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = psDate ).
        CONTINUE.
      ENDIF.

      DATA(dcDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-Documentdate ) datetype = 'Document' ).
      FIND 'Invalid' IN dcDate.
      IF sy-subrc = 0.
        updateerrorlog( wa_data = ls_input message = dcDate ).
        CONTINUE.
      ENDIF.

      DATA(message) = zcl_expenpaympost=>postExpensePaym( wa_data = ls_input psdate = psDate dcdate = dcDate ).
      updateerrorlog( wa_data = ls_input message = message ).

    ENDLOOP.

    ENDMETHOD.


  METHOD postData.
    postEKDocuments( ).
    postKGDocuments( ).
    postDZDocuments( ).
    postCRDocuments( ).
    postDGDocuments( ).
    postKZEZDocuments( ).
    postkrdocuments(  ).
    postcpdocuments(  ).
    postKZSPLGLDocuments(  ).
    updatePostedDocs( ).
  ENDMETHOD.
ENDCLASS.
