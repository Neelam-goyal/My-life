CLASS ycl_account_statement_customer DEFINITION
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

 CONSTANTS  lc_template_name TYPE string VALUE 'ACCOUNTSTATEMENT_NEW1/ACCOUNTSTATEMENT_NEW1'.
ENDCLASS.



CLASS YCL_ACCOUNT_STATEMENT_CUSTOMER IMPLEMENTATION.


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
*
* IF Profitcenter = '' .
*
*     SELECT  a~AccountingDocument ,
*             a~OriginalReferenceDocument,
*             a~DocumentDate,
*             a~CompanyCode,
*             a~AccountingDocumentType,
*             a~FiscalYear,
*             SUM( a~AmountInCompanyCodeCurrency ) as AmountInCompanyCodeCurrency,
*             a~DebitCreditCode ,
*             A~TransactionTypeDetermination,
*             A~FINANCIALACCOUNTTYPE,
*             a~WithholdingTaxAmount FROM i_operationalacctgdocitem as a
*             INNER JOIN I_JournalEntry  as c ON (  c~AccountingDocument = a~AccountingDocument
*                                                    AND c~CompanyCode = a~CompanyCode
*                                                    AND c~FiscalYear = a~FiscalYear
*                                                    AND c~IsReversal <> 'X' AND c~IsReversed <> 'X')
*      where a~Customer = @customer and a~PostingDate GE @date3 AND a~PostingDate LE @date2 AND a~CompanyCode = @companycode
*      AND a~AccountingDocumentType <> 'WL' AND a~SpecialGLCode <> 'F'
*      GROUP BY a~AccountingDocument ,
*             a~DocumentDate,
*             a~CompanyCode,
*             a~AccountingDocumentType,
*             a~FiscalYear,
*              a~DebitCreditCode ,
*              A~TransactionTypeDetermination,
*              A~FINANCIALACCOUNTTYPE,
*              a~OriginalReferenceDocument,
*             a~WithholdingTaxAmount
*      INTO table @DATA(tab1).
*
*
*     data gst1 TYPE string .
*     data cin1 TYPE string .
*     data pan1 TYPE string .
*     data Register1 TYPE string .
*     data Register2 TYPE string .
*     data Register3 TYPE string .
*
*     IF companycode   =  '1000' .
*
*     gst1  = '08AAHCS2781A1ZH'.
*     pan1  = 'AAHCS2781A'.
*     Register1 = 'SWARAJ SUITING LIMITED'.
*     Register2 = 'Reg. Off. F-483 To F-487 RIICO Growth Centre' .
*     Register3 = 'Hamirgarh, Bhilwara-311025, Rajasthan, India'.
*     cin1 = 'L18101RJ2003PLC018359'.
*
*     elseif companycode   =  '2000' .
*
*     gst1  = '08AABCM5293P1ZT'.
*     pan1  = 'AABCM5293P'.
*     Register1 = 'MODWAY SUITING PVT. LIMITED'.
*     Register2 = 'Reg. Off. Weaving Division-I, 20th Km Stone, Chittorgarh Road' .
*     Register3 = 'Takhatpura, Bhilwara-311025, Rajasthan, India'.
*     cin1 = 'U18108RJ1986PTC003788'.
*
*     ENDIF.
*
*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*
*
*ELSEIF   Profitcenter <> '' .
*
*
*    IF Profitcenter  = '0000110000'.
*    gst1  = '23AAHCS2781A1ZP'.
*    pan1  = 'AAHCS2781A'.
*    Register1 = 'SWARAJ SUITING LIMITED'.
*    Register2 = 'Spinning Division-I, B-24 To B-41 Jhanjharwada Industrial Area' .
*    Register3 = ' Jhanjharwada, Neemuch - 458441, Madhya Pradesh, India'.
*    cin1 = 'L18101RJ2003PLC018359'.
*    elseif Profitcenter  = '0000120000'.
*     gst1  = '23AAHCS2781A1ZP'.
*     pan1  = 'AAHCS2781A'.
*     Register1 = 'SWARAJ SUITING LIMITED'.
*     Register2 = 'Denim Division-I, B-24 To B-41 Jhanjharwada Industrial Area' .
*     Register3 = 'Jhanjharwada, Neemuch - 458441, Madhya Pradesh, India'.
*     cin1 = 'L18101RJ2003PLC018359'.
*    elseif Profitcenter  = '0000130000'.
*     gst1  = '08AAHCS2781A1ZH'.
*     pan1  = 'AAHCS2781A'.
*     Register1 = 'SWARAJ SUITING LIMITED'.
*     Register2 = 'Weaving Division-I, F-483 To F-487 RIICO Growth Centre' .
*     Register3 = 'Hamirgarh, Bhilwara-311025, Rajasthan, India'.
*     cin1 = 'L18101RJ2003PLC018359'.
*    elseif Profitcenter  = '0000131000'.
*     gst1  = '23AAHCS2781A1ZP'.
*     pan1  = 'AAHCS2781A'.
*     Register1 = 'SWARAJ SUITING LIMITED'.
*     Register2 = 'Weaving Division-II, B-24 To B-41 Jhanjharwada Industrial Area' .
*     Register3 = 'Jhanjharwada, Neemuch-458441, Madhya Pradesh, India'.
*     cin1 = 'L18101RJ2003PLC018359'.
*    elseif Profitcenter  = '0000140000'.
*     gst1  = '23AAHCS2781A1ZP'.
*     pan1  = 'AAHCS2781A'.
*     Register1 = 'SWARAJ SUITING LIMITED'.
*     Register2 = 'Process House-I, B-24 To B-41 Jhanjharwada Industrial Area' .
*     Register3 = 'Jhanjharwada, Neemuch-458441, Madhya Pradesh, India'.
*     cin1 = 'L18101RJ2003PLC018359'.
*    elseif Profitcenter  = '0000210000'.
*     gst1  = '08AABCM5293P1ZT'.
*     pan1  = 'AABCM5293P'.
*     Register1 = 'MODWAY SUITING PVT. LIMITED'.
*     Register2 = 'Weaving Division-I, 20th Km Stone, Chittorgarh Road' .
*     Register3 = 'Takhatpura, Bhilwara-311025, Rajasthan, India'.
*     cin1 = 'U18108RJ1986PTC003788'.
*    elseif Profitcenter  = '0000220000'.
*     gst1  = '23AABCM5293P1Z1'.
*     pan1  = 'AABCM5293P'.
*     Register1 = 'MODWAY SUITING PVT. LIMITED'.
*     Register2 = 'Weaving Division-II, B-24 To B-41 Jhanjharwada Industrial Area' .
*     Register3 = 'Jhanjharwada, Neemuch-458441, Madhya Pradesh, India'.
*     cin1 = 'U18108RJ1986PTC003788'.
*    ENDIF.
*
*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*
*SELECT  a~AccountingDocument ,
*             a~OriginalReferenceDocument,
*             a~DocumentDate,
*             a~CompanyCode,
*             a~AccountingDocumentType,
*             a~FiscalYear,
*             SUM( a~AmountInCompanyCodeCurrency ) as AmountInCompanyCodeCurrency,
*             a~DebitCreditCode ,
*             A~TransactionTypeDetermination,
*             A~FINANCIALACCOUNTTYPE,
*             a~WithholdingTaxAmount FROM i_operationalacctgdocitem as a
*             INNER JOIN ZJOURNALENTRY_ITEM AS B ON (  B~AccountingDocument = a~AccountingDocument
*                                                    AND B~CompanyCode = a~CompanyCode
*                                                    AND B~FiscalYear = a~FiscalYear )
*             INNER JOIN I_JournalEntry  as c ON (  c~AccountingDocument = a~AccountingDocument
*                                                    AND c~CompanyCode = a~CompanyCode
*                                                    AND c~FiscalYear = a~FiscalYear
*                                                    AND c~IsReversal <> 'X' AND c~IsReversed <> 'X')
*      where a~Customer = @customer and a~PostingDate GE @date3 AND a~PostingDate LE @date2 AND a~CompanyCode = @companycode
*      AND a~AccountingDocumentType <> 'WL' AND a~SpecialGLCode <> 'F' AND B~ProfitCenter = @profitcenter
*      GROUP BY a~AccountingDocument ,
*             a~OriginalReferenceDocument,
*             a~DocumentDate,
*             a~CompanyCode,
*             a~AccountingDocumentType,
*             a~FiscalYear,
*              a~DebitCreditCode ,
*              A~TransactionTypeDetermination,
*              A~FINANCIALACCOUNTTYPE,
*             a~WithholdingTaxAmount
*      INTO table @tab1.
*ENDIF.
*
*   IF tab1 IS NOT INITIAL .
*      READ TABLE tab1 INTO DATA(wa1) INDEX 1 .
*  ENDIF .
*
*""""""""""""""""""""""""""""""""""""""""""""""""""""""""OPENING BALANCE"""""""""""""""""""""""""""""""""""""""""""""""""""""""
* IF Profitcenter = '' .
*    SELECT SUM( AMOUNTINCOMPANYCODECURRENCY )
*       FROM i_operationalacctgdocitem
*       WHERE Customer = @customer AND
*        CompanyCode = @companycode AND
*        AccountingDocumentType NE 'GE' AND  AccountingDocumentType  NE 'WE' AND SpecialGLCode <> 'F'
*        AND PostingDate LT @date3 INTO @DATA(OPENING).
*ELSEIF Profitcenter <> '' .
*
* SELECT SUM( a~AMOUNTINCOMPANYCODECURRENCY )
*       FROM   i_operationalacctgdocitem as a
*       INNER JOIN ZJOURNALENTRY_ITEM AS b ON (  b~AccountingDocument = a~AccountingDocument
*                                                    AND b~CompanyCode = a~CompanyCode
*                                                    AND b~FiscalYear = a~FiscalYear
*                                                     )
*        WHERE a~Customer = @customer AND
*        a~CompanyCode = @companycode
*        AND a~PostingDate LT @date3 AND B~ProfitCenter = @profitcenter
*        AND a~AccountingDocumentType NE 'GE' AND a~AccountingDocumentType  NE 'WE'
*         AND a~SpecialGLCode <> 'F' INTO @OPENING.
* ENDIF.
*""""""""""""""""""""""""""""""""""""""""""""""""""""""""CLOSING BALANCE""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*  IF Profitcenter = '' .
*     SELECT SUM( AMOUNTINCOMPANYCODECURRENCY )
*       FROM i_operationalacctgdocitem
*       WHERE Customer = @customer AND
*        CompanyCode = @companycode AND
*        AccountingDocumentType NE 'GE' AND AccountingDocumentType  NE 'WE' AND SpecialGLCode <> 'F'
*        AND PostingDate LE @date2 INTO @DATA(CLOSING_BAL).
*ELSEIF  Profitcenter <> '' .
*  SELECT SUM( A~AMOUNTINCOMPANYCODECURRENCY )
*       FROM i_operationalacctgdocitem as a
*        INNER JOIN ZJOURNALENTRY_ITEM AS B ON (  B~AccountingDocument = a~AccountingDocument
*                                                    AND B~CompanyCode = a~CompanyCode
*                                                    AND B~FiscalYear = a~FiscalYear
*
*                                                     )
*       WHERE A~Customer = @customer AND
*        A~CompanyCode = @companycode AND
*        A~AccountingDocumentType NE 'GE' AND A~AccountingDocumentType  NE 'WE' AND A~SpecialGLCode <> 'F'
*        AND A~PostingDate LE @date2 AND B~ProfitCenter = @profitcenter INTO @CLOSING_BAL.
*ENDIF.
*      DATA(CLOSING) =  CLOSING_BAL.
*
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*
*  SELECT SINGLE * FROM i_CUSTOMER  as a
*  LEFT OUTER JOIN I_BusinessPartnerBank as b ON ( b~BusinessPartner = a~Customer )
*  LEFT OUTER JOIN ZCUSTOMER_DETAILS as c ON ( c~Customer = a~Customer )
*  WHERE a~Customer = @customer  INTO @DATA(Cust).
* DATA(lv_xml) =
*
*   |<form1>| &&
*   |<plantname>{ Register1 }</plantname>| &&
*   |<address1>{ Register2 }</address1>| &&
*   |<address2>{ Register3 }</address2>| &&
*   |<address3></address3>| &&
*   |<CINNO>{ cin1 }</CINNO>| &&
*   |<GSTIN>{ gst1 }</GSTIN>| &&
*   |<PAN>{ pan1 }</PAN>| &&
*     |<LeftSide>| &&
*      |<partyno>{ CUST-A-CustomerName }</partyno>| &&
*      |<partyno2>{ CUST-C-StreetPrefixName1 }</partyno2>| &&
*      |<partyno3>{ CUST-C-StreetPrefixName2 }</partyno3>| &&
*      |<partyadd>{ CUST-A-CityName }-{ CUST-A-PostalCode }</partyadd>| &&
*      |<partyadd1>{ CUST-A-TaxNumber3 }</partyadd1>| &&
*      |<PHNNO>{ CUST-C-TelephoneNumber1 }</PHNNO>| &&
*      |<EMAIL>{ CUST-C-EmailAddress }</EMAIL>| &&
*    |<Subform7/>| &&
*   |</LeftSide>| &&
*   |<RightSide>| &&
*      |<date></date>| &&
*      |<openingbl>{ OPENING }</openingbl>| &&
*      |<TransporterName></TransporterName>| &&
*      |<FromDate>{ lastdate }</FromDate>| &&
*      |<ToDate>{ currentdate }</ToDate>| &&
*      |<Page>| &&
*         |<HaderData>| &&
*            |<RightSide>| &&
*               |<StationNo></StationNo>| &&
*            |</RightSide>| &&
*         |</HaderData>| &&
*      |</Page>| &&
*      |</RightSide>| &&
*      |<BankDetail>| &&
*      |<BankName>{ CUST-B-BankName }</BankName>| &&
*      |<AccountNo>{  CUST-B-BankAccount }</AccountNo>| &&
*      |<IFSC>{ CUST-B-SWIFTCode }</IFSC>| &&
*      |</BankDetail>| &&
*   |<chk_mark>{ confirmletterbox }</chk_mark>| .
*
*    DATA sum TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*    DATA sum1 TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*    DATA sum2 TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*    DATA TaxTds TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*    DATA Tds TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*     DATA DebitAmt TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*
*SORT tab1 BY DocumentDate ASCENDING.
*  LOOP AT tab1 INTO DATA(Wa2).
*
*
*SELECT SINGLE * FROM i_journalentry
*  where AccountingDocument = @Wa2-AccountingDocument AND CompanyCode = @Wa2-CompanyCode
*  AND FiscalYear = @Wa2-FiscalYear INTO @DATA(tab2).
*
* SELECT SINGLE GLAccount FROM i_operationalacctgdocitem
*      where  FiscalYear = @WA2-FiscalYear AND CompanyCode = @WA2-CompanyCode
*      AND AccountingDocument = @WA2-AccountingDocument  AND GLAccount <> '1850001003' AND GLAccount <> '3500001050'
*      AND  ( AccountingDocumentItemType = '' OR AccountingDocumentItemType = 'R' ) AND  FinancialAccountType <> 'D' AND FinancialAccountType <> 'K'  INTO @DATA(GL).
*
* if GL is INITIAL .
*    SELECT SINGLE customer as GLAccount FROM i_operationalacctgdocitem
*    where  FiscalYear = @WA2-FiscalYear AND CompanyCode = @WA2-CompanyCode
*    AND AccountingDocument = @WA2-AccountingDocument  AND FinancialAccountType = 'K'  INTO @GL.
*endif.
*
*  SELECT SINGLE * FROM I_GLAccountText
*  WHERE GLAccount = @GL AND Language = 'E'
*   into @data(tab7).
*
*
*if tab7 is INITIAL .
*    SELECT SINGLE customername as GLAccountLongName FROM i_customer
*  WHERE customer = @GL into @tab7.
*  endif.
*
*   DATA DESC  TYPE STRING.
*
*   DESC = tab7-GLAccountLongName.
*
*
*
* if Wa2-AccountingDocumentType = 'DZ'.
*
* SELECT SINGLE  AmountInCompanyCodeCurrency
*                             FROM i_operationalacctgdocitem
*                             WHERE accountingdocument = @wa2-accountingdocument
*                             AND GLAccount = '1850001003'
*                             AND CompanyCode = @wa2-CompanyCode
*                             AND FiscalYear = @wa2-FiscalYear
*                             INTO @DATA(AMTTDS) .
*ENDIF.
*
*   if Wa2-DebitCreditCode = 'S' AND Wa2-AmountInCompanyCodeCurrency > 0.
* DATA(PAISA) = Wa2-AmountInCompanyCodeCurrency  .
* ELSEIF
*
* Wa2-DebitCreditCode = 'H' OR Wa2-AmountInCompanyCodeCurrency < 0.
* DATA(PAISA1) = Wa2-AmountInCompanyCodeCurrency .
*
* ENDIF.
*
*    sum   =  sum + PAISA + PAISA1 + Wa2-WithholdingTaxAmount .
*    sum1  = sum + opening.
*    DebitAmt  =  PAISA - Tds .
*
*   IF  AMTTDS <> 0.
*     Tds  =  AMTTDS  .
*   ELSE .
*      Tds = Wa2-WithholdingTaxAmount  .
*   ENDIF.
*
*     IF sum1 < 0 .
*    sum2  =  sum1 * -1 .
*    ELSE.
*    sum2  = sum1 .
*    ENDIF.
*
*
*if wa2-AccountingDocumentType = 'DZ' AND WA2-FinancialAccountType = 'D'.
*
*    DATA(CreditAmt)  = ( PAISA1 * -1 ).
*
*
*
*
*ELSE.
*    IF PAISA1 < 0 .
*    CreditAmt  = ( PAISA1 * -1 ) - Tds.
*    ELSE.
*    CreditAmt   =  PAISA1 - Tds .
*    ENDIF.
*
*ENDIF.
*
*
*
*
*    TaxTds = TaxTds + Wa2-WithholdingTaxAmount .
*
************************************************************************************************
*     SELECT ACCOUNTINGDOCUMENT,
*     SUM( AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency ,
*      TRANSACTIONTYPEDETERMINATION, PROFITCENTER, ACCOUNTINGDOCUMENTTYPE, FINANCIALACCOUNTTYPE
*      FROM i_operationalacctgdocitem
*      where  FiscalYear = @WA2-FiscalYear AND CompanyCode = @WA2-CompanyCode
*      AND AccountingDocument = @WA2-AccountingDocument AND AccountingDocumentType = @WA2-AccountingDocumentType
*      GROUP BY
*      ACCOUNTINGDOCUMENT,
*      TRANSACTIONTYPEDETERMINATION,
*      PROFITCENTER,
*      ACCOUNTINGDOCUMENTTYPE,
*      FINANCIALACCOUNTTYPE
*      INTO table @DATA(TAB).
*
*LOOP at tab into data(wtab) .
* CASE wtab-TransactionTypeDetermination.
* WHEN 'JOS' or 'JOC' or 'JIS' or 'JIC' .
* Data(csgst) = wtab-AmountInCompanyCodeCurrency.
* WHEN 'JII' or 'JIM'.
* Data(Igst) = wtab-AmountInCompanyCodeCurrency.
* WHEN 'SKE'.
* Data(cdrdvalue)  = wtab-AmountInCompanyCodeCurrency.
* WHEN 'WRX'.
* Data(VALUE)  = wtab-AmountInCompanyCodeCurrency.
* WHEN 'KBS' or 'EGK' .
* IF wtab-AccountingDocumentType = 'RE' OR wtab-AccountingDocumentType = 'KR'.
* Data(TOTELCREDIT)  = wtab-AmountInCompanyCodeCurrency.
* ENDIF.
* ENDCASE.
*ENDLOOP.
*
*LOOP AT tab into wtab where ProfitCenter <> '' and TransactionTypeDetermination = ''  .
*
*DATA(VALUESUM) = wtab-AmountInCompanyCodeCurrency  .
*
**IF WTAB-AccountingDocumentType = 'DZ' AND WTAB-FINANCIALACCOUNTTYPE = 'S' AND WTAB-ProfitCenter <> ''.
**
**CreditAmt = WTAB-amountincompanycodecurrency + TDS.
**ENDIF.
*ENDLOOP.
*
*
*
********************************************************************************************
*     DATA(lv_xml2) =
*         |<LopTab>| &&
*         |<Row1>| &&
*         |<docno>{ wa2-OriginalReferenceDocument+0(10) }</docno>| &&
*         |<docdate>{ tab2-DocumentDate  }</docdate>| &&
*         |<particulars>{ DESC  }</particulars>| &&
*         |<doctype>{ Wa2-AccountingDocumentType }</doctype>| &&
*         |<Value>{ VALUESUM }</Value>| &&
*         |<cdrd>{ cdrdvalue }</cdrd>| &&
*         |<IGST>{ Igst }</IGST>| &&
*         |<CGST>{ csgst }</CGST>| &&
*         |<SGST>{ csgst }</SGST>| &&
*         |<Tdsamt>{ Tds }</Tdsamt>| &&
*         |<debitamt>{ DebitAmt }</debitamt>| &&
*         |<creditamt>{ CreditAmt }</creditamt>| &&
*         |<Balance>{ sum2 }</Balance>| &&
*         |</Row1>| &&
*         |</LopTab>|.
*
* CONCATENATE xsml lv_xml2 INTO  xsml .
* clear : PAISA,PAISA1,DESC,sum2,DebitAmt,CreditAmt,Tds,WA2,tab2,AMTTDS,GL,tab7,csgst,Igst,VALUESUM.
*
* ENDLOOP.
*DATA closingbl TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
*
*
*   closingbl = CLOSING + TaxTds.
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
