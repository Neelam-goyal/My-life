CLASS zcl_glaccount DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS :
      read_posts

        IMPORTING CompanyCode     TYPE string
                  GlAccount        TYPE string
                  LastDate        TYPE string
                  CurrentDate     TYPE string
                  ProfitCenter    TYPE string
        RETURNING VALUE(result12) TYPE string

        RAISING   cx_static_check .

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS  lc_template_name TYPE string VALUE 'GLAccount/GLAccount'.
ENDCLASS.



CLASS ZCL_GLACCOUNT IMPLEMENTATION.


  METHOD read_posts.

    DATA: lv_currentdate TYPE string,
          lv_lastdate    TYPE string.

    lv_currentdate = |{ currentdate+6(2) }-{ currentdate+4(2) }-{ currentdate+0(4) }|.
    lv_lastdate    = |{ lastdate+6(2) }-{ lastdate+4(2) }-{ lastdate+0(4) }|.

    DATA(todaydate) = cl_abap_context_info=>get_system_date( ).
    DATA : todaydate1 TYPE string.
    todaydate1 = |{ todaydate+6(2) }/{ todaydate+4(2) }/{ todaydate(4) }|.
    DATA(FromDateTodate) = |From ({ lv_lastdate } To { lv_currentdate })|.

    DATA :debit_amount  TYPE i_accountingdocumentjournal-DebitAmountInCoCodeCrcy,
          credit_amount TYPE i_accountingdocumentjournal-CreditAmountInCoCodeCrcy,
          lv_CREDIT     TYPE i_accountingdocumentjournal-DebitAmountInCoCodeCrcy,
          balance       TYPE i_accountingdocumentjournal-DebitAmountInCoCodeCrcy,
          total_debit   TYPE i_accountingdocumentjournal-DebitAmountInCoCodeCrcy,
          total_credit  TYPE i_accountingdocumentjournal-CreditAmountInCoCodeCrcy,
          total_balance TYPE i_accountingdocumentjournal-DebitAmountInCoCodeCrcy.


    SELECT SINGLE FROM I_CompanyCode
    FIELDS CompanyCodeName
    WHERE CompanyCode = @CompanyCode
    INTO @DATA(comp).

    SELECT SINGLE FROM
    I_GLAccountText AS a
    FIELDS a~GLAccountLongName,a~GLAccount
    WHERE a~GLAccount = @GlAccount
    INTO @DATA(gl_text).

    DATA : gltext TYPE string.
    gltext = | { gl_text-GLAccountLongName } [{ gl_text-GLAccount }]|.


    IF profitcenter IS NOT INITIAL.
      SELECT FROM i_accountingdocumentjournal( P_Language = 'E' ) AS a
        FIELDS DISTINCT a~AccountingDocument,
               a~AccountingDocumentType
        WHERE a~IsReversed IS INITIAL
          AND a~IsReversal IS INITIAL
          AND a~ReversalReferenceDocument IS INITIAL
          AND a~GLAccount = @GlAccount
          AND a~CompanyCode = @CompanyCode
          AND a~PostingDate BETWEEN @lastdate AND @currentdate
          AND ( a~ProfitCenter = @ProfitCenter )
          AND a~IsReversal = ''
          AND a~IsReversed = ''
          AND a~ReversalReferenceDocument = ''
          AND a~Ledger = '0L'
        ORDER BY  AccountingDocument,AccountingDocumentType
        INTO TABLE @DATA(it1).
    ELSE.
      SELECT FROM i_accountingdocumentjournal( P_Language = 'E' ) AS a
     FIELDS DISTINCT a~AccountingDocument,
            a~AccountingDocumentType
     WHERE a~IsReversed IS INITIAL
       AND a~IsReversal IS INITIAL
       AND a~ReversalReferenceDocument IS INITIAL
       AND a~GLAccount = @GlAccount
       AND a~CompanyCode = @CompanyCode
       AND a~PostingDate BETWEEN @lastdate AND @currentdate
       AND a~IsReversal = ''
       AND a~IsReversed = ''
       AND a~ReversalReferenceDocument = ''
       AND a~Ledger = '0L'
       ORDER BY  AccountingDocument,AccountingDocumentType
     INTO TABLE @it1.
    ENDIF.

    LOOP AT it1 ASSIGNING FIELD-SYMBOL(<wa_add>).
      <wa_add>-AccountingDocument = |{ <wa_add>-AccountingDocument  ALPHA = IN  }|.
    ENDLOOP.

    TYPES: acc_range TYPE RANGE OF I_AccountingDocumentJournal-AccountingDocument.

    DATA:  lt_accounting_documents TYPE acc_range.

    LOOP AT it1 INTO DATA(wa_check).
      APPEND VALUE #( sign = 'I'
                      option = 'EQ'
                      low = wa_check-accountingdocument ) TO lt_accounting_documents.
    ENDLOOP.

    IF lt_accounting_documents IS NOT INITIAL.
      IF profitcenter IS NOT INITIAL.
        SELECT FROM I_AccountingDocumentJournal( P_Language = 'E' ) AS a
        FIELDS
          a~PostingDate,
          a~AccountingDocumentType,
          a~AccountingDocument,
          a~ClearingAccountingDocument,
          a~ClearingDate,
          a~DebitAmountInCoCodeCrcy,
          a~CreditAmountInCoCodeCrcy,
          a~FiscalYear,
          a~CompanyCode,
          a~GLAccount
          WHERE a~CompanyCode = @CompanyCode
          AND a~GlAccount = @GlAccount
          AND ( a~ProfitCenter = @ProfitCenter )
          AND a~AccountingDocument IN @lt_accounting_documents
          AND a~PostingDate BETWEEN @lastdate AND @currentdate
          AND a~IsReversal = ''
          AND a~IsReversed = ''
          AND a~ReversalReferenceDocument = ''
          AND ledger = '0L'
          INTO TABLE @DATA(it_item1).
      ELSE.
        SELECT FROM I_AccountingDocumentJournal( P_Language = 'E' ) AS a
     FIELDS
       a~PostingDate,
       a~AccountingDocumentType,
       a~AccountingDocument,
       a~ClearingAccountingDocument,
       a~ClearingDate,
       a~DebitAmountInCoCodeCrcy,
       a~CreditAmountInCoCodeCrcy,
       a~FiscalYear,
       a~CompanyCode,
       a~GLAccount
       WHERE a~CompanyCode = @CompanyCode
       AND a~GlAccount = @GlAccount
       AND a~AccountingDocument IN @lt_accounting_documents
       AND a~PostingDate BETWEEN @lastdate AND @currentdate
       AND a~IsReversal = ''
       AND a~IsReversed = ''
       AND a~ReversalReferenceDocument = ''
       AND ledger = '0L'
       INTO TABLE @it_item1.
      ENDIF.
    ENDIF.

    DATA : it_item LIKE it_item1.
    APPEND LINES OF it_item1 TO it_item.
    SORT it_item BY PostingDate AccountingDocument.

    SELECT FROM  i_accountingdocumentjournal( P_Language = 'E' )
        FIELDS  SUM( DebitAmountInCoCodeCrcy ) AS debit ,SUM( CreditAmountInCoCodeCrcy ) AS credit
        WHERE PostingDate LT @lastdate AND Ledger = '0L' AND IsReversed IS INITIAL
         AND IsReversal IS INITIAL
         AND ReversalReferenceDocument IS INITIAL
         AND GLAccount = @GlAccount
         AND CompanyCode =  @CompanyCode
        INTO @DATA(opening).

    DATA : opening_bal  TYPE i_accountingdocumentjournal-DebitAmountInCoCodeCrcy.

    opening_bal = opening-debit + opening-credit.

    DATA : check TYPE i VALUE 0.


    DATA(lv_xml) =
    |<form1>| &&
    |<plantname>{ comp }</plantname>| &&
    |<REPORTDATE>{ todaydate1 }</REPORTDATE>| &&
    |<FromDateTodate>{ FromDateTodate }</FromDateTodate>| &&
    |<companyCode>{ companycode }</companyCode>| &&
    |<gltext>{ gltext }</gltext>| &&
    |<LopTab>| .
    LOOP AT it_item INTO DATA(wa_item).

      lv_xml = lv_xml &&
              |<Row>| &&
              |<Date>{ wa_item-PostingDate }</Date>| &&
              |<DocumentType>{ wa_item-AccountingDocumentType }</DocumentType>| &&
              |<DocumentNumber>{ wa_item-AccountingDocument }</DocumentNumber>| .

      "********************************Narration********************************

      SELECT SINGLE FROM I_AccountingDocumentJournal( P_Language = 'E' )
      FIELDS customer, supplier
      WHERE AccountingDocument = @wa_item-AccountingDocument
      INTO @DATA(ls_AccountDocJournal).

      DATA: lv_businesspartner TYPE string,
            lv_glaccountname   TYPE string,
            lv_reference       TYPE string.

      IF ls_AccountDocJournal-customer IS NOT INITIAL OR ls_AccountDocJournal-supplier IS NOT INITIAL.
        SELECT SINGLE BusinessPartnerFullName
          FROM I_BusinessPartner
          WHERE BusinessPartner = @ls_AccountDocJournal-customer
             OR BusinessPartner = @ls_AccountDocJournal-supplier
          INTO @lv_businesspartner.
      ELSE.
        SELECT SINGLE
          FROM I_GLAccountText
          FIELDS GLAccountLongName
          WHERE GLAccount = @wa_item-GLAccount
          INTO @lv_businesspartner.
      ENDIF.

      IF wa_item-AccountingDocumentType = 'RE'.

        SELECT SINGLE FROM I_OperationalAcctgDocItem
        FIELDS OriginalReferenceDocument
        WHERE AccountingDocument = @wa_item-AccountingDocument
        INTO @DATA(ls_OriginalReference).

        DATA(lv_short_ref) = COND string(
          WHEN strlen( ls_OriginalReference ) > 4
          THEN substring(
            val = ls_OriginalReference
            off = 0
            len = strlen( ls_OriginalReference ) - 4
          )
          ELSE ls_OriginalReference
        ).

*        DATA(lv_short_ref_clean) = ''.
*
*        DO strlen( lv_short_ref ) TIMES.
*          DATA(lv_char) = lv_short_ref+sy-index(1).
*          IF lv_char CO '0123456789'.
*            lv_short_ref_clean = lv_short_ref_clean && lv_char.
*          ENDIF.
*        ENDDO.
*
*        lv_short_ref = lv_short_ref_clean.
        REPLACE ALL OCCURRENCES OF REGEX '[^\d]' IN lv_short_ref WITH ''.

        SELECT SINGLE FROM I_SupplierInvoiceAPI01
        FIELDS SupplierInvoiceIDByInvcgParty,DocumentHeaderText
        WHERE SupplierInvoice = @lv_short_ref
        INTO @DATA(ls_SupplierIn).
        DATA(Narration) = |INV. NO : { ls_SupplierIn-SupplierInvoiceIDByInvcgParty }. { lv_businesspartner }. BEING PURC.OF { ls_supplierin-DocumentHeaderText }|.

      ELSEIF wa_item-AccountingDocumentType = 'KR'.

        SELECT SINGLE FROM I_AccountingDocumentJournal( P_Language = 'E' )
        FIELDS DocumentReferenceID,DocumentItemText
        WHERE AccountingDocument = @wa_item-AccountingDocument
        INTO @DATA(ls_ACCT_KR).
        Narration = |INV. NO : { ls_acct_kr-DocumentReferenceID }. BEING AMT OF { ls_ACCT_KR-DocumentItemText }|.

      ELSEIF wa_item-AccountingDocumentType = 'KZ' OR wa_item-AccountingDocumentType = 'EZ'.

        SELECT SINGLE FROM I_AccountingDocumentJournal( P_Language = 'E' )
        FIELDS DocumentItemText
        WHERE AccountingDocument = @wa_item-AccountingDocument
        AND  fiscalYear = @wa_item-FiscalYear
        AND companyCode = @CompanyCode
        INTO @DATA(ls_ACCT_KZ).
        Narration = |To AMOUNT PAID TO : { lv_businesspartner }. { ls_ACCT_KZ }|.

      ELSEIF wa_item-AccountingDocumentType = 'DZ'.

        SELECT SINGLE FROM I_AccountingDocumentJournal( P_Language = 'E' )
        FIELDS DocumentItemText
        WHERE AccountingDocument = @wa_item-AccountingDocument
        AND  fiscalYear = @wa_item-FiscalYear
        AND companyCode = @CompanyCode
        INTO @DATA(ls_ACCT_DZ).

        Narration = |To AMOUNT RECEIVED FROM : { lv_businesspartner }. { ls_ACCT_DZ }|.

      ELSEIF wa_item-AccountingDocumentType = 'CP' OR wa_item-AccountingDocumentType = 'CR'.

        SELECT SINGLE FROM I_AccountingDocumentJournal( P_Language = 'E' )
        FIELDS DocumentItemText
        WHERE AccountingDocument = @wa_item-AccountingDocument
        AND  fiscalYear = @wa_item-FiscalYear
        AND companyCode = @CompanyCode
        INTO @DATA(ls_ACCT_CP).

        Narration = |To AMOUNT OF : { lv_businesspartner }. { ls_ACCT_CP }|.

      ELSE.
        SELECT SINGLE FROM I_AccountingDocumentJournal( P_Language = 'E' )
        FIELDS DocumentItemText
        WHERE AccountingDocument = @wa_item-AccountingDocument
        AND  fiscalYear = @wa_item-FiscalYear
        AND companyCode = @CompanyCode
        INTO @DATA(ls_ACCT).
        Narration = |BEING : { ls_ACCT }|.

      ENDIF.
      lv_xml = lv_xml &&
      |<Narration>{ Narration }</Narration>|.

********************************For Debit and Credit Amounts********************************
      IF wa_item-ClearingAccountingDocument IS INITIAL AND wa_item-ClearingDate IS INITIAL.
        IF wa_item-debitamountincocodecrcy IS NOT INITIAL.
          debit_amount = wa_item-DebitAmountInCoCodeCrcy.
        ELSEIF wa_item-creditamountincocodecrcy IS NOT INITIAL.
          credit_amount = wa_item-creditamountincocodecrcy.
        ENDIF.
      ENDIF.

      IF check = 0.
        balance += opening_bal + debit_amount + credit_amount .
      ELSE.
        balance +=  debit_amount + credit_amount .
      ENDIF.

      check = 1.
      total_credit += credit_amount.
      total_debit  += debit_amount.
      total_balance += balance.

      lv_xml = lv_xml &&
      |<DebitAmount>{ debit_amount }</DebitAmount>| &&
      |<CreditAmount>{ credit_amount }</CreditAmount>| &&
      |<Balance>{ balance }</Balance>| &&
      |</Row>| .
      CLEAR: debit_amount, credit_amount ,lv_credit,lv_businesspartner,wa_item,ls_OriginalReference,ls_SupplierIn,ls_ACCT_KR,ls_ACCT_KZ,ls_ACCT_DZ,
      ls_ACCT_CP,ls_ACCT.
    ENDLOOP.
    check = 0.

    DATA : opening_dat TYPE string.
    opening_dat =  |{ lastdate+6(2) }/{ lastdate+4(2) }/{ lastdate+0(4) }|.

    lv_xml = lv_xml &&
        |<TOTALCREDIT>{ total_credit }</TOTALCREDIT>| &&
        |<TOTALDEBIT>{ total_debit }</TOTALDEBIT>| &&
        |<TOTALBALANCE>{ total_balance }</TOTALBALANCE>| &&
        |<opening>{ opening_bal }</opening>| &&
        |<opening_date>{ opening_dat }</opening_date>| &&
        |</LopTab>| &&
        |</form1>| .

    CLEAR: lv_currentdate, lv_lastdate, todaydate, FromDateTodate,
           total_debit, total_credit, total_balance,opening_bal.

    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.

    CALL METHOD zcl_ads_master=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).
  ENDMETHOD.
ENDCLASS.
