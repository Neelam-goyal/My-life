CLASS zcl_bppostvalidate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .

    CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

    TYPES: BEGIN OF ty_validate_doc,
             companycode   TYPE zr_bpposting-companycode,
             documentdate  TYPE zr_bpposting-documentdate,
             updatedate    TYPE zr_bpposting-Documentdate,
             postingdate   TYPE zr_bpposting-postingdate,
             bpartner      TYPE zr_bpposting-Businesspartner1,
             businessplace TYPE zr_bpposting-Businessplace1,
             vouchertype   TYPE zr_bpposting-vouchertype,
             itemtext      TYPE zr_bpposting-ItemText1,
             amount        TYPE zr_bpposting-amount1,
             currencycode  TYPE zr_bpposting-currencycode,
             amounttype    TYPE zr_bpposting-AmtType1,
             Assignment    TYPE zr_bpposting-assignment1,
             profitcenter  TYPE zr_bpposting-profitcenter1,
             SpecialGLCode TYPE zr_bpposting-SpecialGlCode1,
             createdtime   TYPE zr_bpposting-Createdtime,
             linenum       TYPE zr_bpposting-LineNum,
             docnumber     TYPE i,
             accdoc        TYPE zr_bpposting-Accdoc1,
             year          TYPE zr_bpposting-Accdocyear1,
             validate1     type zr_bpposting-validate1,
             validate2     type zr_bpposting-validate2,
           END OF ty_validate_doc.

      CLASS-METHODS validate_document
      RETURNING VALUE(message) TYPE string.

      CLASS-METHODS  ErrorLog
      IMPORTING
        wa_data TYPE zr_bpposting
        message TYPE string .

     class-METHODS validcustomerdocs
     IMPORTING
        wa_data        TYPE ty_validate_doc
      RETURNING
        VALUE(message) TYPE string .

     class-METHODS validSupplierDocs
     IMPORTING
        wa_data        TYPE ty_validate_doc
      RETURNING
        VALUE(message) TYPE string .

      class-METHODS validateDoc
      IMPORTING
      wa_data type ty_validate_doc
      iv_flag type abap_boolean .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BPPOSTVALIDATE IMPLEMENTATION.


    METHOD validate_document.

      SELECT * FROM zr_bpposting
         WHERE isdeleted = ''
                 AND isposted  = ''
                 AND ApprovedBy IS NOT INITIAL
                 AND ApprovedAt IS NOT INITIAL
        INTO TABLE @DATA(lt_input).


      LOOP AT lt_input INTO DATA(ls_input).

        DATA(psDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-postingdate ) datetype = 'Posting' ).
        FIND 'Invalid' IN psDate.
        IF sy-subrc = 0.
          errorlog( wa_data = ls_input message = psDate ).
          CONTINUE.
        ENDIF.

        DATA(dcDate) = zcl_http_oipaympost=>checkDateFormat( date = CONV string( ls_input-Documentdate ) datetype = 'Document' ).
        FIND 'Invalid' IN dcDate.
        IF sy-subrc = 0.
          errorlog( wa_data = ls_input message = dcDate ).
          CONTINUE.
        ENDIF.


        IF ls_input-Amount1 NE ls_input-Amount2 .
          errorlog( wa_data = ls_input message = 'Both Amount1 and Amount2 are not equal' ).
          CONTINUE.
        ENDIF.

        IF ls_input-Accdoc1 IS INITIAL.

          DATA(param) = VALUE ty_validate_doc(
            companycode   = ls_input-Companycode
            documentdate  = dcdate
            updatedate    = ls_input-Documentdate
            postingdate   = psdate
            bpartner      = ls_input-Businesspartner1
            businessplace = ls_input-Businessplace1
            vouchertype   = ls_input-Vouchertype
            itemtext      = ls_input-ItemText1
            amount        = ls_input-Amount1
            currencycode  = ls_input-Currencycode
            amounttype    = ls_input-AmtType1
            assignment    = ls_input-Assignment1
            profitcenter  = ls_input-Profitcenter1
            SpecialGLCode = ls_input-SpecialGLCode1
            createdtime   = ls_input-Createdtime
            linenum       = ls_input-LineNum
            docnumber     = 1
          ).

          IF to_lower( ls_input-type1 ) = 'supplier'.
            message = validsupplierdocs( wa_data = param ).
          ELSEIF to_lower( ls_input-type1 ) = 'customer'.
            message = validcustomerdocs( wa_data = param ).
          ENDIF.
        ENDIF.

        IF ls_input-Accdoc2 IS INITIAL.

          DATA(param2) = VALUE ty_validate_doc(
            companycode   = ls_input-Companycode
            documentdate  = dcdate
            updatedate    = ls_input-Documentdate
            postingdate   = psdate
            bpartner      = ls_input-Businesspartner2
            businessplace = ls_input-Businessplace2
            vouchertype   = ls_input-Vouchertype
            itemtext      = ls_input-ItemText2
            amount        = ls_input-Amount2
            currencycode  = ls_input-Currencycode
            amounttype    = ls_input-AmtType2
            assignment    = ls_input-Assignment2
            profitcenter  = ls_input-Profitcenter2
            specialglcode = ls_input-SpecialGLCode2
            createdtime   = ls_input-Createdtime
            linenum       = ls_input-LineNum
            docnumber     = 2
          ).

          IF to_lower( ls_input-type2 ) = 'supplier'.
            message = validSupplierDocs( wa_data = param2 ).
          ELSEIF to_lower( ls_input-type2 ) = 'customer'.
            message = validcustomerdocs( wa_data = param2 ).
          ENDIF.
        ENDIF.


      ENDLOOP.

    ENDMETHOD.


 METHOD validcustomerdocs.
   DATA: lt_je_deep TYPE TABLE FOR FUNCTION IMPORT I_JournalEntryTP~Validate.

   DATA(customer_amt) = COND #( WHEN wa_data-amounttype = 'DR'
                                 THEN wa_data-amount
                                 ELSE wa_data-amount * -1 ).

   SELECT SINGLE FROM zr_integration_tab
   FIELDS Intgpath
   WHERE Intgmodule = 'BP-CONTROL-GL'
   INTO @DATA(lv_intgpath).


   APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
   <je_deep>-%cid = getCid(  ).
   <je_deep>-%param = VALUE #(
   companycode = wa_data-Companycode
   businesstransactiontype = 'RFBU'
   accountingdocumenttype = wa_data-vouchertype
   CreatedByUser = sy-uname
   documentdate = wa_data-Documentdate
   postingdate = COND #( WHEN wa_data-postingdate IS INITIAL
                 THEN cl_abap_context_info=>get_system_date( )
                 ELSE wa_data-postingdate )

   _aritems = VALUE #( (   glaccountlineitem = |001|
                           Customer = wa_data-Bpartner
                           DocumentItemText = wa_data-itemtext
                           BusinessPlace = wa_data-Businessplace
                           AssignmentReference = wa_data-Assignment
                           SpecialGLCode = wa_data-SpecialGlCode
                           _currencyamount = VALUE #( (
                                           currencyrole = '00'
                                           journalentryitemamount = customer_amt
                                           currency = wa_data-Currencycode ) ) )
                      )
   _glitems = VALUE #(
                       ( glaccountlineitem = |002|

                       glaccount = lv_intgpath
                       AssignmentReference = wa_data-Assignment
                       BusinessPlace = wa_data-Businessplace
                       DocumentItemText = wa_data-itemtext
                       ProfitCenter = wa_data-Profitcenter
                       _currencyamount = VALUE #( (
                                           currencyrole = '00'
                                           journalentryitemamount = customer_amt * -1
                                           currency = wa_data-Currencycode ) ) ) )
   ).

   READ ENTITIES OF i_journalentrytp PRIVILEGED ENTITY JournalEntry
   EXECUTE Validate FROM lt_je_deep
   RESULT DATA(ls_result)
   REPORTED DATA(ls_reported_deep)
   FAILED DATA(ls_failed_deep).



   IF ls_failed_deep IS NOT INITIAL.

     LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
       message = <ls_reported_deep>-%msg->if_message~get_text( ).
     ENDLOOP.

     ErrorLog( wa_data = VALUE zr_bpposting(
                                               Companycode = wa_data-companycode
                                               Documentdate = wa_data-updatedate
                                               Createdtime = wa_data-createdtime
                                               LineNum = wa_data-linenum )
                     message = message ).

   ELSE.
     validateDoc( wa_data = wa_data
                   iv_flag = 'X' ).
   ENDIF.

 ENDMETHOD.


  METHOD validSupplierDocs.
    DATA: lt_je_deep     TYPE TABLE FOR FUNCTION IMPORT i_journalentrytp~validate.

    DATA(supplier_amt) = COND #( WHEN wa_data-amounttype = 'DR'
                                      THEN wa_data-amount
                                      ELSE wa_data-amount * -1 ).

    SELECT SINGLE FROM zr_integration_tab
    FIELDS Intgpath
    WHERE Intgmodule = 'BP-CONTROL-GL'
    INTO @DATA(lv_intgpath).

    APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
    <je_deep>-%cid = getCid(  ).
    <je_deep>-%param = VALUE #(
    companycode = wa_data-Companycode
    businesstransactiontype = 'RFBU'
    accountingdocumenttype = wa_data-Vouchertype
    CreatedByUser = sy-uname
    documentdate = wa_data-Documentdate
    postingdate = COND #( WHEN wa_data-postingdate IS INITIAL
                  THEN cl_abap_context_info=>get_system_date( )
                  ELSE wa_data-postingdate )

    _apitems = VALUE #( ( glaccountlineitem = |001|
                            Supplier = wa_data-Bpartner
                            BusinessPlace = wa_data-Businessplace
                            AssignmentReference = wa_data-assignment
                            DocumentItemText = wa_data-itemtext
                            SpecialGLCode = wa_data-SpecialGlCode
                            _currencyamount = VALUE #( (
                                            currencyrole = '00'
                                            journalentryitemamount = supplier_amt
                                            currency = wa_data-Currencycode ) ) )
                       )
    _glitems = VALUE #(
                        ( glaccountlineitem = |002|
                        glaccount = lv_intgpath
                        AssignmentReference = wa_data-assignment
                        ProfitCenter = wa_data-Profitcenter
                        DocumentItemText = wa_data-itemtext
                        _currencyamount = VALUE #( (
                                            currencyrole = '00'
                                            journalentryitemamount = supplier_amt * -1
                                            currency = wa_data-Currencycode ) ) ) )
    ).

    READ ENTITIES OF i_journalentrytp PRIVILEGED ENTITY JournalEntry
    EXECUTE Validate FROM lt_je_deep
    RESULT DATA(ls_result)
    REPORTED DATA(ls_reported_deep)
    FAILED DATA(ls_failed_deep).

    IF ls_failed_deep IS NOT INITIAL.
      LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
        message = <ls_reported_deep>-%msg->if_message~get_text( ).
      ENDLOOP.

      ErrorLog( wa_data = VALUE zr_bpposting(
                                                Companycode = wa_data-companycode
                                                Documentdate = wa_data-updatedate
                                                Createdtime = wa_data-createdtime
                                                LineNum = wa_data-linenum )
                      message = message ).

    ELSE.
      validateDoc( wa_data = wa_data
                    iv_flag = 'X' ).
    ENDIF.



  ENDMETHOD.


  METHOD ErrorLog.
    UPDATE zbpposting SET Error_Log = @message
         WHERE companycode = @wa_data-companycode
           AND Documentdate = @wa_data-Documentdate
           AND Createdtime = @wa_data-Createdtime
           AND line_no = @wa_data-LineNum.

  ENDMETHOD.


  METHOD validatedoc.
  CASE wa_data-docnumber.
      WHEN 1.
        MODIFY ENTITIES OF zr_bpposting
        ENTITY ZrBpposting
        UPDATE FIELDS ( validate1 )
        WITH VALUE #(  (
            Validate1 = iv_flag
            Companycode = wa_data-Companycode
            Documentdate = wa_data-updatedate
            Createdtime = wa_data-createdtime
            LineNum = wa_data-LineNum
            )  )
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_bpposting
        FAILED DATA(lt_commit_failed2)
        REPORTED DATA(lt_commit_reported2).
        ...
        COMMIT ENTITIES END.
        WHEN 2.
        MODIFY ENTITIES OF zr_bpposting
      ENTITY ZrBpposting
      UPDATE FIELDS ( validate2 )
      WITH VALUE #(  (
          Validate2 = iv_flag
          Companycode = wa_data-Companycode
          Documentdate = wa_data-updatedate
          Createdtime = wa_data-createdtime
          LineNum = wa_data-LineNum
          )  )
      FAILED lt_failed
      REPORTED lt_reported.

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_bpposting
        FAILED lt_commit_failed2
        REPORTED lt_commit_reported2.
        ...
        COMMIT ENTITIES END.
    ENDCASE.

  ENDMETHOD.


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
   validate_document( ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
  validate_document( ).
  ENDMETHOD.
ENDCLASS.
