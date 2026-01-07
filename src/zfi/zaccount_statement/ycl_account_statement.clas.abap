CLASS ycl_account_statement DEFINITION
 PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    CLASS-DATA : template TYPE string .
    CLASS-DATA : tot_sum  TYPE string.

    TYPES : BEGIN OF struct,
        xdp_template TYPE string,

        xml_data     TYPE string,
        form_type    TYPE string,

        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct."

    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check,

      read_posts
        IMPORTING companycode     TYPE string
                  correspondence   TYPE string
                 accounttype     TYPE string
*                  VALUE(customer)         TYPE string
                 lastdate         TYPE string
                 currentdate      TYPE string
                  profitcenter     TYPE prctr
                 confirmletterbox TYPE string

        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.

*    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
*    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.eu10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
*    CONSTANTS  lv2_url    TYPE string VALUE 'https://btp-yvzjjpaz.authentication.eu10.hana.ondemand.com/oauth/token'  .
*    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
* CONSTANTS  lc_template_name TYPE string VALUE 'ACCOUNTSTATEMENT_NEW1/ACCOUNTSTATEMENT_NEW1'.
ENDCLASS.



CLASS YCL_ACCOUNT_STATEMENT IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD .


  METHOD if_oo_adt_classrun~main.
*    TRY.
*    ENDTRY.
  ENDMETHOD.


  METHOD read_posts .

*    DATA xsml TYPE string.
*    DATA date2 TYPE string.
*    DATA gv1 TYPE string .
*    DATA gv2 TYPE string .
*    DATA gv3 TYPE string .
*
*    gv3 = currentdate+6(4)  .
*    gv2 = currentdate+3(2)  .
*    gv1 = currentdate+0(2)  .
*
*    CONCATENATE gv3 gv2 gv1   INTO date2.
*
*    DATA date3 TYPE string.
*    DATA gv4 TYPE string .
*    DATA gv5 TYPE string .
*    DATA gv6 TYPE string .
*
*    gv6 = lastdate+6(4)  .
*    gv5 = lastdate+3(2)  .
*    gv4 = lastdate+0(2)  .
*
*    CONCATENATE gv6 gv5 gv4  INTO date3.
*
*    DATA VAR TYPE char10 .
*       VAR   = |{ customer ALPHA = IN }|.
*    customer = VAR.
*
* IF Profitcenter = '' .
*
*   SELECT  a~AccountingDocument ,
*             a~DocumentDate,
*             a~CompanyCode,
*             a~AccountingDocumentType,
*             a~FiscalYear,
*             SUM( a~AmountInCompanyCodeCurrency ) as AmountInCompanyCodeCurrency,
*             a~DebitCreditCode ,
*             a~WithholdingTaxAmount,
*             A~TRANSACTIONTYPEDETERMINATION,
*             SUM( a~CashDiscountAmount ) as CashDiscountAmount  FROM i_operationalacctgdocitem AS A
*      INNER JOIN I_JournalEntry  as c ON (  c~AccountingDocument = a~AccountingDocument
*                                                    AND c~CompanyCode = a~CompanyCode
*                                                    AND c~FiscalYear = a~FiscalYear
*                                                    AND c~IsReversal <> 'X' AND c~IsReversed <> 'X')
*     where A~Supplier = @customer and A~PostingDate GE @date3 AND A~PostingDate LE @date2 AND A~CompanyCode = @companycode AND A~SpecialGLCode NE 'F'
*     and ( A~AccountingDocumentType = 'RE' or A~AccountingDocumentType = 'KR' or A~AccountingDocumentType = 'AA'
*        or A~AccountingDocumentType = 'KG' or A~AccountingDocumentType = 'K6' or A~AccountingDocumentType = 'KZ'
*        or A~AccountingDocumentType = 'AA' or A~AccountingDocumentType = 'SA' or A~AccountingDocumentType = 'KC'
*        or A~AccountingDocumentType = 'RK' or A~AccountingDocumentType = 'ZA' or A~AccountingDocumentType = 'UE'
*        or a~AccountingDocumentType = 'KA')
*        AND ( A~FinancialAccountType = 'K' )
*              GROUP BY a~AccountingDocument ,
*             a~DocumentDate,
*             a~CompanyCode,
*             a~AccountingDocumentType,
*             a~FiscalYear,
*             a~DebitCreditCode ,
*             a~WithholdingTaxAmount,
*             A~TRANSACTIONTYPEDETERMINATION
*
*     INTO table @DATA(tab1).
*
*      data gst1 TYPE string .
*     data cin1 TYPE string .
*     data pan1 TYPE string .
*     data Register1 TYPE string .
*     data Register2 TYPE string .
*     data Register3 TYPE string .
*
*     IF companycode   =  '' .
*
*     gst1  = ''.
*     pan1  = ''.
*     Register1 = ''.
*     Register2 = '' .
*     Register3 = ''.
*     cin1 = ''.
*
*     elseif companycode   =  '' .
*
*     gst1  = ''.
*     pan1  = ''.
*     Register1 = ''.
*     Register2 = '' .
*     Register3 = ''.
*     cin1 = ''.
*
*     ENDIF.
*ELSEIF  Profitcenter <> '' .
*
*    IF Profitcenter  = ''.
*    gst1  = ''.
*    pan1  = ''.
*    Register1 = ''.
*    Register2 = '' .
*    Register3 = ''.
*    cin1 = ''.
*    elseif Profitcenter  = ''.
*     gst1  = ''.
*     pan1  = ''.
*     Register1 = ''.
*     Register2 = '' .
*     Register3 = ''.
*     cin1 = ''.
*    elseif Profitcenter  = ''.
*     gst1  = ''.
*     pan1  = ''.
*     Register1 = ''.
*     Register2 = '' .
*     Register3 = ''.
*     cin1 = ''.
*    elseif Profitcenter  = ''.
*     gst1  = ''.
*     pan1  = ''.
*     Register1 = ''.
*     Register2 = '' .
*     Register3 = ''.
*     cin1 = ''.
*    elseif Profitcenter  = ''.
*     gst1  = ''.
*     pan1  = ''.
*     Register1 = ''.
*     Register2 = '' .
*     Register3 = ''.
*     cin1 = ''.
*    elseif Profitcenter  = ''.
*     gst1  = ''.
*     pan1  = ''.
*     Register1 = ''.
*     Register2 = '' .
*     Register3 = ''.
*     cin1 = ''.
*    elseif Profitcenter  = ''.
*     gst1  = ''.
*     pan1  = ''.
*     Register1 = ''.
*     Register2 = '' .
*     Register3 = ''.
*     cin1 = ''.
*    ENDIF.
*
*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*
*
* SELECT  a~AccountingDocument ,
*             a~DocumentDate,
*             a~CompanyCode,
*             a~AccountingDocumentType,
*             a~FiscalYear,
*             SUM( a~AmountInCompanyCodeCurrency )  as AmountInCompanyCodeCurrency,
*             a~DebitCreditCode ,
*             a~WithholdingTaxAmount,
*             A~TRANSACTIONTYPEDETERMINATION,
*             SUM( a~CashDiscountAmount ) as CashDiscountAmount FROM i_operationalacctgdocitem AS A
*             INNER JOIN ZJOURNALENTRY_ITEM AS B ON (  B~AccountingDocument = a~AccountingDocument
*                                                    AND B~CompanyCode = a~CompanyCode
*                                                    AND B~FiscalYear = a~FiscalYear )
*            INNER JOIN I_JournalEntry  as c ON (  c~AccountingDocument = a~AccountingDocument
*                                                    AND c~CompanyCode = a~CompanyCode
*                                                    AND c~FiscalYear = a~FiscalYear
*                                                    AND c~IsReversal <> 'X' AND c~IsReversed <> 'X')
*               where a~Supplier = @customer and a~PostingDate GE @date3 AND a~PostingDate LE @date2 AND a~CompanyCode = @companycode AND a~SpecialGLCode NE 'F'
*     and ( a~AccountingDocumentType = 'RE' or a~AccountingDocumentType = 'KR' or a~AccountingDocumentType = 'AA'
*        or a~AccountingDocumentType = 'KG' or a~AccountingDocumentType = 'K6' or a~AccountingDocumentType = 'KZ'
*        or a~AccountingDocumentType = 'AA' or a~AccountingDocumentType = 'SA' or a~AccountingDocumentType = 'KC'
*        or a~AccountingDocumentType = 'RK' or a~AccountingDocumentType = 'ZA' or a~AccountingDocumentType = 'UE'
*        or a~AccountingDocumentType = 'KA')
*         AND B~ProfitCenter = @profitcenter
*              GROUP BY a~AccountingDocument ,
*             a~DocumentDate,
*             a~CompanyCode,
*             a~AccountingDocumentType,
*             a~FiscalYear,
*             a~DebitCreditCode ,
*             a~WithholdingTaxAmount,
*             A~TRANSACTIONTYPEDETERMINATION
*
*     INTO table @tab1.
*
*ENDIF.
*
*   IF tab1 IS NOT INITIAL .
*      READ TABLE tab1 INTO DATA(wa1) INDEX 1 .
*  ENDIF .
*
*""""""""""""""""""""""""""""""""""""""""""""""""""""""""OPENING BALANCE"""""""""""""""""""""""""""""""""""""""""""""""""""""""
*   IF Profitcenter = '' .
*
*    SELECT SUM( AMOUNTINCOMPANYCODECURRENCY )
*       FROM i_operationalacctgdocitem as a  WHERE A~Supplier = @customer AND
*        A~CompanyCode = @companycode  and
*        A~AccountingDocumentType NE 'GE' AND  A~AccountingDocumentType  NE 'WE' AND A~SpecialGLCode <> 'F'
*        AND A~PostingDate LT @date3 INTO @DATA(OPENING).
*
*ELSEIF Profitcenter <> '' .
*
*SELECT SUM( a~AMOUNTINCOMPANYCODECURRENCY )
*       FROM i_operationalacctgdocitem as a
*           INNER JOIN ZJOURNALENTRY_ITEM AS b ON (  b~AccountingDocument = a~AccountingDocument
*                                                    AND b~CompanyCode = a~CompanyCode
*                                                    AND b~FiscalYear = a~FiscalYear )
*       WHERE a~Supplier = @customer AND
*        a~CompanyCode = @companycode and
*        a~AccountingDocumentType NE 'GE' AND  a~AccountingDocumentType  NE 'WE' AND a~SpecialGLCode <> 'F'
*        AND a~PostingDate LT @date3 AND b~ProfitCenter = @profitcenter INTO @OPENING.
*
*ENDIF.
*""""""""""""""""""""""""""""""""""""""""""""""""""""""""CLOSING BALANCE""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*  IF profitcenter = '' .
*
*    SELECT SUM( AMOUNTINCOMPANYCODECURRENCY )
*       FROM i_operationalacctgdocitem as a
*       WHERE A~Supplier = @customer AND
*        A~CompanyCode = @companycode  and
*        A~AccountingDocumentType NE 'GE' AND A~AccountingDocumentType  NE 'WE' AND A~SpecialGLCode <> 'F'
*        AND A~PostingDate LE @date2 INTO @DATA(CLOSING_BAL).
*
*ELSEIF profitcenter <> '' .
*
*       SELECT SUM( A~AMOUNTINCOMPANYCODECURRENCY )
*       FROM i_operationalacctgdocitem as a
*       INNER JOIN ZJOURNALENTRY_ITEM AS b ON (  b~AccountingDocument = a~AccountingDocument
*                                                    AND b~CompanyCode = a~CompanyCode
*                                                    AND b~FiscalYear = a~FiscalYear )
*       WHERE a~Supplier = @customer AND
*        a~CompanyCode = @companycode and
*        a~AccountingDocumentType NE 'GE' AND a~AccountingDocumentType  NE 'WE' AND a~SpecialGLCode <> 'F'
*        AND a~PostingDate LE @date2 AND b~ProfitCenter = @profitcenter INTO @CLOSING_BAL.
*
*ENDIF.
*
*      DATA(CLOSING) =  CLOSING_BAL.
*
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*   SELECT SINGLE * FROM i_supplier as a
*   left outer  join I_SuplrBankDetailsByIntId as b on ( b~Supplier = a~Supplier  )
*    left outer  join  I_Bank_2 as f on ( f~BankInternalID = b~Bank  )  WHERE a~Supplier = @customer  INTO @DATA(supplier).
**   SELECT SINGLE * FROM ZSUPPLIER_DETAILS where Supplier = @customer  into @DATA(email).
*
*"""""""""""""""""""""""""""""""""""""""""""""""Address"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*
*      DATA(lv_xml) =
*
*        |<form1>| &&
*   |<plantname>{ Register1 }</plantname>| &&
*   |<address1>{ Register2 }</address1>| &&
*   |<address2>{ Register3 }</address2>| &&
*   |<address3></address3>| &&
*   |<CINNO>{ cin1 }</CINNO>| &&
*   |<GSTIN>{ gst1 }</GSTIN>| &&
*   |<PAN>{ pan1 }</PAN>| &&
*   |<LeftSide>| &&
*   |<partyno>{ supplier-A-SupplierName }</partyno>| &&
**   |<partyno2>{ email-StreetPrefixName1 }</partyno2>| &&
**   |<partyno3>{ email-StreetPrefixName2 }</partyno3>| &&
*   |<partyadd>{ supplier-A-CityName }-{ supplier-A-PostalCode }</partyadd>| &&
*   |<partyadd1>{ supplier-A-TaxNumber3 }</partyadd1>| &&
**   |<PHNNO>{ email-PhoneNumber1 }</PHNNO>| &&
**   |<EMAIL>{ email-EmailAddress }</EMAIL>| &&
*   |<Subform7/>| &&
*   |</LeftSide>| &&
*   |<RightSide>| &&
*      |<date></date>| &&
*      |<openingbl>{ OPENING }</openingbl>| &&
*      |<TransporterName></TransporterName>| &&
*      |<FromDate>{ lastdate }</FromDate>| &&
*      |<ToDate>{ currentdate }</ToDate>| &&
*      |<Page>| &&
*      |<HaderData>| &&
*      |<RightSide>| &&
*      |<StationNo></StationNo>| &&
*      |</RightSide>| &&
*      |</HaderData>| &&
*      |</Page>| &&
*      |</RightSide>| &&
*      |<BankDetail>| &&
*      |<BankName>{ supplier-F-BankName }</BankName>| &&
*      |<AccountNo>{ supplier-B-BankAccount }</AccountNo>| &&
*      |<IFSC>{ supplier-B-Bank }</IFSC>| &&
*      |</BankDetail>| &&
*      |<chk_mark>{ confirmletterbox }</chk_mark>| .
*
*    DATA sum TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*    DATA sum1 TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*    DATA sum2 TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*
*    DATA TaxTds TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*    DATA Tds TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*
*  SORT tab1 BY DocumentDate ASCENDING.
*  LOOP AT tab1 INTO DATA(Wa2).
*
*      SELECT SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*      where  FiscalYear = @WA2-FiscalYear AND CompanyCode = @WA2-CompanyCode AND TransactionTypeDetermination = 'WIT'
*      AND AccountingDocument = @WA2-AccountingDocument AND AccountingDocumentType = @WA2-AccountingDocumentType
*      INTO @Wa2-WithholdingTaxAmount.
*
*********************************************************************
*      SELECT ACCOUNTINGDOCUMENT, AmountInCompanyCodeCurrency, TRANSACTIONTYPEDETERMINATION, PROFITCENTER, ACCOUNTINGDOCUMENTTYPE
*       FROM i_operationalacctgdocitem
*      where  FiscalYear = @WA2-FiscalYear AND CompanyCode = @WA2-CompanyCode
*      AND AccountingDocument = @WA2-AccountingDocument AND AccountingDocumentType = @WA2-AccountingDocumentType
*       INTO table @DATA(TAB).
*
*LOOP at tab into data(wtab) .
*  DATA csgst TYPE P DECIMALS 2.
*  DATA Sgct TYPE P DECIMALS 2.
*  DATA Igst TYPE P DECIMALS 2.
*  DATA cdrdvalue TYPE P DECIMALS 2.
*  DATA VALUE TYPE P DECIMALS 2.
*  DATA TOTELCREDIT TYPE P DECIMALS 2.
*
*
* CASE wtab-TransactionTypeDetermination.
* WHEN 'JIC' .
* csgst  = csgst +  wtab-AmountInCompanyCodeCurrency.
* WHEN 'JIS' .
* Sgct   = Sgct +  wtab-AmountInCompanyCodeCurrency.
* WHEN 'JII' or 'JIM'.
* Igst = Igst + wtab-AmountInCompanyCodeCurrency.
* WHEN 'SKE'.
* cdrdvalue  =  cdrdvalue + wtab-AmountInCompanyCodeCurrency.
* WHEN 'WRX' OR 'AGD' OR 'BSX'  OR 'PRD' OR 'RKA' OR 'ANL' OR 'PK2'.
* VALUE  = VALUE + wtab-AmountInCompanyCodeCurrency.
* WHEN 'KBS' or 'EGK' .
* IF wtab-AccountingDocumentType = 'RE' OR wtab-AccountingDocumentType = 'KR'.
* TOTELCREDIT  = TOTELCREDIT +  wtab-AmountInCompanyCodeCurrency.
* ENDIF.
* ENDCASE.
*
*ENDLOOP.
*
*
*LOOP AT tab into wtab where ProfitCenter <> '' and TransactionTypeDetermination = ''  .
*
*DATA(VALUESUM) = wtab-AmountInCompanyCodeCurrency.
*
*
*ENDLOOP.
*
*IF wtab-AccountingDocumentType = 'RE'  OR wtab-AccountingDocumentType = 'KG'.
*VALUESUM = VALUE .
*ENDIF.
*
*IF VALUESUM = 0.
*VALUESUM = VALUE.
*ENDIF.
*
**************************************************************************
*  SELECT SINGLE * FROM i_journalentry
*  where AccountingDocument = @Wa2-AccountingDocument AND CompanyCode = @Wa2-CompanyCode
*  AND FiscalYear = @Wa2-FiscalYear INTO @DATA(tab2).
*
*     SELECT SINGLE GLAccount FROM i_operationalacctgdocitem
*     where  FiscalYear = @WA2-FiscalYear AND CompanyCode = @WA2-CompanyCode AND AccountingDocument = @WA2-AccountingDocument AND AccountingDocumentType = @WA2-AccountingDocumentType
*     AND GLAccount NE '2500001000' AND GLAccount NE '2500002000' AND GLAccount NE '2500003000' AND GLAccount NE '2500004000'
*     AND GLAccount NE '2700001010' AND GLAccount NE '2700001020' AND GLAccount NE '2700001030' AND GLAccount NE '2700001040'
*     AND GLAccount NE '2700001050' AND GLAccount NE '2700001060' AND GLAccount NE '2700001070'
*     AND GLAccount NE '2700001080' AND GLAccount NE '2700001090' AND GLAccount NE '2700001100'
*     AND GLAccount NE '2700002000' AND GLAccount NE '2700004000' AND GLAccount NE '2700004010' AND GLAccount NE '2700004020' AND GLAccount NE '2700004030'
*     AND GLAccount NE '2700004500' AND GLAccount NE '2700004510' AND GLAccount NE '2700004520' AND GLAccount NE '3500001410'
*     AND AccountingDocumentItemType <> 'T' INTO @DATA(GL).
*
* if GL is INITIAL .
*    SELECT SINGLE supplier as GLAccount FROM i_operationalacctgdocitem
*    where  FiscalYear = @WA2-FiscalYear AND CompanyCode = @WA2-CompanyCode
*    AND AccountingDocument = @WA2-AccountingDocument  AND FinancialAccountType = 'K'  INTO @GL.
*endif.
*
*  SELECT SINGLE GLAccountLongName FROM I_GLAccountText
*  WHERE GLAccount = @GL AND Language = 'E'
*  into @DATA(tab7).
*
*if tab7 is INITIAL .
*    SELECT SINGLE suppliername as GLAccountLongName FROM i_supplier
*  WHERE supplier = @GL into @tab7.
*  endif.
*
*
* if Wa2-DebitCreditCode = 'S' AND Wa2-AmountInCompanyCodeCurrency > 0.
* DATA PAISA TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
* DATA CDPAISA TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
* DATA TDSDEBIT TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*
* if wa2-AccountingDocumentType = 'KZ' .
*   PAISA = Wa2-AmountInCompanyCodeCurrency .
**    PAISA = Wa2-AmountInCompanyCodeCurrency + Wa2-cashdiscountamount .
*   CDPAISA = Wa2-AmountInCompanyCodeCurrency.
*   TDSDEBIT = Wa2-WithholdingTaxAmount .
* ELSE.
* PAISA = Wa2-AmountInCompanyCodeCurrency - Wa2-cashdiscountamount .
**    PAISA = Wa2-AmountInCompanyCodeCurrency + Wa2-cashdiscountamount .
*   CDPAISA = Wa2-AmountInCompanyCodeCurrency.
*   TDSDEBIT = Wa2-WithholdingTaxAmount .
* ENDIF.
*
* ELSEIF
* Wa2-DebitCreditCode = 'H' OR Wa2-AmountInCompanyCodeCurrency < 0 .
* DATA PAISA1 TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*      PAISA1 = Wa2-AmountInCompanyCodeCurrency .
* ENDIF.
*
*  DATA DESC TYPE STRING .
* if Wa2-AccountingDocumentType = 'RE' OR Wa2-AccountingDocumentType = 'UE'  .
*
*      DESC = 'PURCHASE'.
*
* ELSEif Wa2-AccountingDocumentType = 'KC'.
*      DESC = 'CREDIT NOTE'.
*
* ELSEif Wa2-AccountingDocumentType = 'KG' OR Wa2-AccountingDocumentType = 'ZA' OR Wa2-AccountingDocumentType = 'RK'.
*      DESC = 'DEBIT NOTE'.
*
* ELSE.
*      DESC = tab7.
*
* ENDIF.
*
*
*    sum   =  sum + CDPAISA + PAISA1 + TDSDEBIT  .
*    sum1  = sum + opening.
*    TaxTds = TaxTds + Wa2-WithholdingTaxAmount .
*
*    IF sum1 < 0 .
*    sum2  =  sum1 * -1 .
*    ELSE.
*    sum2  = sum1 .
*    ENDIF.
*
*    IF PAISA1 < 0 .
*    DATA PAISA2 TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*    PAISA2  =  ( PAISA1 + Wa2-WithholdingTaxAmount ) * -1  .
*    ELSEIF PAISA1 > 0.
*    PAISA2   =  PAISA1 + Wa2-WithholdingTaxAmount  .
*    ENDIF.
*
*     IF Wa2-WithholdingTaxAmount  < 0 .
*    Tds  =  Wa2-WithholdingTaxAmount  * 1 .
*    ELSE.
*    Tds  = Wa2-WithholdingTaxAmount  .
*    ENDIF.
*
*
*if VALUESUM = 0.
*VALUESUM = PAISA2 .
*if VALUESUM = 0.
*VALUESUM =  PAISA.
*ENDIF.
*ENDIF.
*if TOTELCREDIT = 0 .
*TOTELCREDIT = PAISA2.
*ENDIF.
*
*     DATA(lv_xml2) =
*    |<LopTab>| &&
*      |<Row1>| &&
*         |<docno>{ Tab2-DocumentReferenceID }</docno>| &&
*         |<docdate>{ tab2-DocumentDate  }</docdate>| &&
*         |<particulars>{ DESC  }</particulars>| &&
*         |<doctype>{ Wa2-AccountingDocumentType }</doctype>| &&
*         |<Value>{ VALUESUM }</Value>| &&
*         |<cdrd>{ cdrdvalue }</cdrd>| &&
*         |<IGST>{ Igst }</IGST>| &&
*         |<CGST>{ csgst }</CGST>| &&
*         |<SGST>{ Sgct }</SGST>| &&
*         |<Tdsamt>{ Tds }</Tdsamt>| &&
*         |<tcs></tcs>| &&
*         |<debitamt>{ PAISA }</debitamt>| &&
*         |<creditamt>{ TOTELCREDIT }</creditamt>| &&
*         |<Balance>{ sum2 }</Balance>| &&
*      |</Row1>| &&
*      |</LopTab>|.
*
* CONCATENATE xsml lv_xml2 INTO  xsml .
* clear : PAISA,PAISA1,DESC,PAISA2,TDSDEBIT,GL,tab7,tab2,Wa2,Tds, CDPAISA, csgst, Sgct,Igst, cdrdvalue,VALUE,VALUESUM,TOTELCREDIT.
*
* ENDLOOP.
*
*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
* " data(closingbl) = CLOSING + TaxTds.
*   DATA closingbl TYPE   i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*    closingbl = CLOSING .
*
*    DATA(lv_xml3) =
*       |<Subform3>| &&
*       |<Table3>| &&
*          |<Row1>| &&
*            |<closingbl>{ closingbl }</closingbl>| &&
*         |</Row1>| &&
*      |</Table3>| &&
*      |</Subform3>| &&
*      |<Subform2>| &&
*      |<SIGN></SIGN>| &&
*      |<preparedby></preparedby>| &&
*      |</Subform2>| &&
*      |</form1>| .
*
*    CONCATENATE lv_xml xsml lv_xml3 INTO lv_xml .
*
*CALL METHOD zcl_ads_master=>getpdf(
*       EXPORTING
*         xmldata  = LV_XML
*         template = lc_template_name
*       RECEIVING
*         result   = result12 ).

  ENDMETHOD.
ENDCLASS.
