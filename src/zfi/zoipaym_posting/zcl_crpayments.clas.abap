CLASS zcl_crpayments DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

    CLASS-METHODS  postCRPayments
       IMPORTING
        wa_data  TYPE zr_oipayments
        psDate TYPE string
        dcDate TYPE string
        RETURNING
        VALUE(message)  TYPE STRING .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CRPAYMENTS IMPLEMENTATION.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD postCRPayments.
        DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
              document   TYPE string.


        APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
            <je_deep>-%cid = getCid(  ).
            <je_deep>-%param = VALUE #(
              companycode = wa_data-Companycode
              businesstransactiontype = 'RFBU'
              accountingdocumenttype = wa_data-AccountingDocumenttype
              AccountingDocumentHeaderText = wa_data-Gltext
              CreatedByUser = sy-uname
              documentdate = dcDate
              postingdate = COND #( WHEN psDate IS INITIAL
                                    THEN cl_abap_context_info=>get_system_date( )
                                    ELSE psDate )

              " Customer Item (Debit)
              _aritems = VALUE #( (
                  glaccountlineitem = |002|
                  Customer = wa_data-Bpartner
                  DocumentItemText = wa_data-Gltext
                  BusinessPlace = wa_data-Businessplace
                  SpecialGLCode = wa_data-SpecialGlCode
                  _currencyamount = VALUE #( (
                      currencyrole = '00'
                      journalentryitemamount = wa_data-Glamount
                      currency = wa_data-Currencycode
                  ) )
              ) )

              " G/L Item (Credit)
              _glitems = VALUE #( (
                  glaccountlineitem = |001|
                  glaccount = wa_data-Glaccount
                  HouseBank = wa_data-Housebank
                  HouseBankAccount = wa_data-Accountid
                  BusinessPlace = wa_data-Businessplace
                  AssignmentReference = wa_data-Assignmentreference
                  DocumentItemText = wa_data-Gltext
                  CostCenter = wa_data-Costcenter
                  _currencyamount = VALUE #( (
                      currencyrole = '00'
                      journalentryitemamount = wa_data-Glamount * -1
                      currency = wa_data-Currencycode
                  ) )
              ) )
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
            ...
            COMMIT ENTITIES END.
          ELSE.
            message = |Document Creation Failed: { message }|.
          ENDIF.

        ENDIF.

      ENDMETHOD.
ENDCLASS.
