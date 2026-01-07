CLASS zcl_expenpaympost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

  CLASS-METHODS  postExpensePaym
       IMPORTING
        wa_data  TYPE zr_oipayments
        psDate TYPE string
        dcDate TYPE string
        RETURNING
        VALUE(message)  TYPE STRING .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EXPENPAYMPOST IMPLEMENTATION.


  METHOD getCID.
        TRY.
            cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
          CATCH cx_uuid_error.
            ASSERT 1 = 0.
        ENDTRY.
      ENDMETHOD.


METHOD postExpensePaym.

        DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT I_JournalEntryTP~post,
              document   TYPE string.


*              SELECT SINGLE SUM( conditionrateratio )
*               FROM i_taxcoderate
*               WHERE taxcode = @wa_data-taxcode
*                     INTO @DATA(all_tax_perct).
*
*              SELECT  FROM i_taxcoderate
*              FIELDS TaxCode,ConditionRateRatio, VATConditionType,Country
*              WHERE taxcode = @wa_data-taxcode
*              INTO TABLE @DATA(taxes).
*
*
*
*              DATA: lv_assble_total TYPE p LENGTH 13 DECIMALS 2.
*              lv_assble_total =  ( wa_data-Glamount * 100 ) / ( 100 + all_tax_perct ) .


        APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
        <je_deep>-%cid = getCid(  ).
        <je_deep>-%param = VALUE #(
        companycode = wa_data-Companycode
        businesstransactiontype = 'RFBU'
        accountingdocumenttype = wa_data-AccountingDocumenttype
        AccountingDocumentHeaderText = wa_data-Gltext
        CreatedByUser = sy-uname
        documentdate = dcDate
*              TaxReportingDate = psDate
*              TaxDeterminationDate = psDate
        DocumentReferenceID = wa_data-ReferenceID
        postingdate =  COND #( WHEN psDate IS INITIAL
                          THEN cl_abap_context_info=>get_system_date( )
                          ELSE psDate )




        _apitems = VALUE #(
                          ( glaccountlineitem = |002|
                            Supplier = wa_data-Bpartner
                            BusinessPlace = wa_data-Businessplace
                           SpecialGLCode = wa_data-SpecialGlCode
                            DocumentItemText = wa_data-Gltext
                            AssignmentReference = wa_data-ReferenceID
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-Glamount
                                                currency = wa_data-Currencycode ) ) )
                          )



        _glitems = VALUE #(
                            ( glaccountlineitem = '001'
                              glaccount =  wa_data-Glaccount
                              CostCenter = wa_data-Costcenter "changes - only commented this
*                                    TaxCode = wa_data-Taxcode
*                              TaxItemAcctgDocItemRef = '003'
                              AssignmentReference = wa_data-ReferenceID
                              BusinessPlace = wa_data-Businessplace
                              DocumentItemText = wa_data-Gltext
                              _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount =  wa_data-Glamount * -1
*                                                      journalentryitemamount = lv_assble_total
                                                currency = wa_data-Currencycode ) ) ) )
*             _taxitems =  VALUE #( FOR tax IN taxes  INDEX INTO i ( glaccountlineitem = |{ ( i + 2 ) WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
*                                 TaxCode = tax-TaxCode
*                                 TaxRate = tax-ConditionRateRatio
*                                 ConditionType = tax-VATConditionType
*                                 TaxCountry = tax-Country
*                                  _currencyamount = VALUE #( (
*                                                      currencyrole = '00'
*                                                      TaxBaseAmount = lv_assble_total
*                                                      journalentryitemamount =  lv_assble_total * ( tax-ConditionRateRatio / 100 )
*                                                      currency = wa_data-Currencycode ) ) )
*                                 )
           ).

        MODIFY ENTITIES OF I_JournalEntryTP PRIVILEGED
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
          RESPONSE OF I_JournalEntryTP
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
            EXIT.
          ENDIF.

        ENDIF.

        CLEAR lt_je_deep.
      ENDMETHOD.
ENDCLASS.
