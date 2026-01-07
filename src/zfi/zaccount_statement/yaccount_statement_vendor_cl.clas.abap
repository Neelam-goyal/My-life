CLASS yaccount_statement_vendor_cl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.
    TYPES : BEGIN OF ty_final,
              document                     TYPE i_operationalacctgdocitem-accountingdocument,
              postingdate                  TYPE i_operationalacctgdocitem-postingdate,
              accountingdocumenttype       TYPE i_operationalacctgdocitem-accountingdocumenttype,
              companycode                  TYPE i_operationalacctgdocitem-companycode,
              fiscalyear                   TYPE i_operationalacctgdocitem-fiscalyear,
              material                     TYPE i_operationalacctgdocitem-Product,
              financialaccounttype         TYPE i_operationalacctgdocitem-FinancialAccountType,
              quantity                     TYPE i_operationalacctgdocitem-quantity,
              baseunit                     TYPE i_operationalacctgdocitem-baseunit,
              amountintransactioncurrency  TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              CashDiscountAmount           TYPE i_operationalacctgdocitem-CashDiscountAmount,
              transactiontypedetermination TYPE i_operationalacctgdocitem-transactiontypedetermination,
              debitcreditcode              TYPE i_operationalacctgdocitem-debitcreditcode,
              joi                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              joc                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              jos                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              jtc                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              wth                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              deb_amt                      TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              cre_amt                      TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              closing_bal                  TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              taxableamt                   TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              taxableamtc                  TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              remarks                      TYPE i_operationalacctgdocitem-documentitemtext,
              businessplace                TYPE i_operationalacctgdocitem-businessplace,
              naration                     type string,
            END OF ty_final.

    CLASS-DATA : BEGIN OF w_head,
                   opening_bal   TYPE i_operationalacctgdocitem-amountintransactioncurrency,
                   closing_bal   TYPE i_operationalacctgdocitem-amountintransactioncurrency,
                   value         TYPE i_operationalacctgdocitem-customer,
                   cusvssupp(25) TYPE c,
                   tds(25)       TYPE c,
                 END OF w_head.

    CLASS-DATA : BEGIN OF wa_add1,
                   name               TYPE i_supplier-supplierfullname,
                   taxnumber3         TYPE i_supplier-taxnumber3,
                   customer           TYPE i_supplier-customer,
                   supplier           Type I_Supplier-Supplier,
                   telephonenumber1   TYPE i_supplier-phonenumber1,
                   organizationname1  TYPE i_address_2-organizationname1,
                   organizationname2  TYPE i_address_2-organizationname2,
                   organizationname3  TYPE i_address_2-organizationname3,
                   housenumber        TYPE i_address_2-housenumber,
                   streetname         TYPE i_address_2-streetname,
                   streetprefixname1  TYPE i_address_2-streetprefixname1,
                   streetprefixname2  TYPE i_address_2-streetprefixname2,
                   streetsuffixname1  TYPE i_address_2-streetsuffixname1,
                   streetsuffixname2  TYPE i_address_2-streetsuffixname2,
                   districtname       TYPE i_address_2-districtname,
                   cityname           TYPE i_address_2-cityname,
                   addresssearchterm1 TYPE i_address_2-addresssearchterm1,
                   postalcode         TYPE i_supplier-postalcode,
                   regionname         TYPE i_regiontext-regionname,
                 END OF wa_add1.

    CLASS-DATA :BEGIN OF wa_add,
                  var1(80)  TYPE c,
                  var2(80)  TYPE c,
                  var3(80)  TYPE c,
                  var4(80)  TYPE c,
                  var5(80)  TYPE c,
                  var6(80)  TYPE c,
                  var7(80)  TYPE c,
                  var8(80)  TYPE c,
                  var9(80)  TYPE c,
                  var10(80) TYPE c,
                  var11(80) TYPE c,
                  var12(80) TYPE c,
                  var13(80) TYPE c,
                  var14(80) TYPE c,
                  var15(80) TYPE c,
                END OF wa_add.

    CLASS-DATA : it_final TYPE TABLE OF ty_final,
                 wa_final TYPE ty_final.


    CLASS-METHODS :

      read_posts
        IMPORTING companycode     TYPE string
                  correspondence   TYPE string
                  accounttype     TYPE string
                  customer         TYPE string
*                  Value(customer)         TYPE string ##NEEDED
                  lastdate        TYPE string
                  currentdate      TYPE string
                  profitcenter    TYPE prctr
                  confirmletterbox TYPE string
                  both          TYPE string
        RETURNING VALUE(result12)   TYPE string ##NEEDED
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS  lc_template_name TYPE string VALUE 'ACCOUNTSTATEMENT_NEW7/ACCOUNTSTATEMENT_NEW7'.
ENDCLASS.



CLASS YACCOUNT_STATEMENT_VENDOR_CL IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  ENDMETHOD.


  METHOD read_posts .

    DATA rec TYPE string.
    DATA xsml   TYPE string.
    DATA date2  TYPE string.
    DATA gv1    TYPE string .
    DATA gv2    TYPE string .
    DATA gv3    TYPE string .
    DATA close_bal TYPE   i_operationalacctgdocitem-AmountInCompanyCodeCurrency .

    gv3 = currentdate+6(4)  . "12/31/2024
    gv2 = currentdate+3(2)  .                               "20240901
    gv1 = currentdate+0(2)  .

    CONCATENATE gv3 gv2 gv1   INTO date2.

    DATA date3 TYPE string.
    DATA gv4 TYPE string .
    DATA gv5 TYPE string .
    DATA gv6 TYPE string .

    gv6 = lastdate+6(4)  . "09/01/2024
    gv5 = lastdate+3(2)  .
    gv4 = lastdate+0(2)  .

    CONCATENATE gv6 gv5 gv4  INTO date3.

    SELECT SINGLE a~taxnumber3,
                  a~customer,
                  a~Supplier,
                  b~organizationname1,
                  b~organizationname2,
                  b~organizationname3,
                  b~housenumber,
                  b~streetname,
                  b~streetprefixname1,
                  b~streetprefixname2,
                  b~streetsuffixname1,
                  b~streetsuffixname2,
                  b~districtname,
                  b~cityname,
                  b~addresssearchterm1,
                  b~postalcode,
                  c~regionname
                  FROM i_supplier AS a
                  INNER JOIN i_address_2 WITH PRIVILEGED ACCESS AS b ON ( b~addressid =  a~addressid )
                  LEFT JOIN i_regiontext AS c ON ( c~region = a~region AND c~language = 'E' AND c~country = 'IN ' )
*                  LEFT JOIN i_customer AS d ON a~Supplier = d~Supplier
                  WHERE a~supplier = @customer  INTO CORRESPONDING FIELDS OF @wa_add1.

    DATA(lv_cutomer) = |{ wa_add1-organizationname1 }/{ wa_add1-Supplier }|.

    wa_add-var1 = wa_add1-organizationname1.
    wa_add-var2 = wa_add1-organizationname2.
    wa_add-var3 = wa_add1-organizationname3.
    wa_add-var1 = wa_add1-housenumber.
    wa_add-var2 = wa_add1-streetname.
    wa_add-var3 = wa_add1-streetprefixname1.
    wa_add-var4 = wa_add1-streetprefixname2.
    wa_add-var5 = wa_add1-streetsuffixname1.
    wa_add-var6 = wa_add1-streetsuffixname2.
    wa_add-var1 = wa_add1-cityname.
    wa_add-var3 = wa_add1-postalcode.

    SELECT SINGLE FROM I_Customer
    FIELDS Customer
    WHERE Customer = @customer
    INTO @DATA(Supplier_as_cust).

    SELECT
      a~billingdocument,
      a~accountingdocument,
      a~postingdate,
      a~accountingdocumenttype,
      a~companycode,
      a~fiscalyear,
      a~product,
      a~clearingjournalentry ,
      a~financialaccounttype,
      SUM( a~AmountInCompanyCodeCurrency ) AS amountintransactioncurrency,
      SUM( a~CashDiscountAmount ) AS CashDiscountAmount,
      a~debitcreditcode,
      a~baseunit,
      a~documentdate
      FROM i_operationalacctgdocitem AS a
*      LEFT JOIN i_customer AS b ON a~Supplier = b~Supplier
      INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                               AND c~CompanyCode = a~CompanyCode
                                               AND c~FiscalYear = a~FiscalYear
                                               AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
      WHERE a~companycode = @companycode
        AND a~Supplier = @customer
        AND a~financialaccounttype = 'K'
        AND a~specialglcode <> 'F'
        AND ( a~ProfitCenter = @ProfitCenter OR @ProfitCenter = '' )
        AND a~PostingDate GE @date3 AND a~PostingDate LE @date2
        GROUP BY
      a~billingdocument,
      a~accountingdocument,
      a~postingdate,
      a~accountingdocumenttype,
      a~companycode,
      a~fiscalyear,
      a~product,
      a~clearingjournalentry ,
      a~debitcreditcode,
      a~baseunit,
      a~financialaccounttype,
      a~documentdate
        INTO TABLE @DATA(it_tab) .

    IF supplier_as_cust IS NOT INITIAL AND both = 'true'.
      SELECT
  a~billingdocument,
a~accountingdocument,
a~postingdate,
a~accountingdocumenttype,
a~companycode,
a~fiscalyear,
a~product,
a~clearingjournalentry ,
a~financialaccounttype,
SUM( a~AmountInCompanyCodeCurrency ) AS amountintransactioncurrency,
SUM( a~CashDiscountAmount ) AS CashDiscountAmount,
a~debitcreditcode,
a~baseunit,
a~documentdate
FROM i_operationalacctgdocitem AS a
     INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                              AND c~CompanyCode = a~CompanyCode
                                              AND c~FiscalYear = a~FiscalYear
                                              AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
     WHERE a~companycode = @companycode
     AND    a~Customer = @customer
     AND    a~financialaccounttype = 'D'
     AND  a~SpecialGLCode NE 'F'
     AND a~AccountingDocumentType  <> 'WL' AND a~AccountingDocumentType  <> 'WA' AND a~AccountingDocumentType  <> 'WE'
     AND ( a~ProfitCenter = @ProfitCenter OR @ProfitCenter = '' )
     AND ( a~PostingDate >= @date3 ) AND ( a~PostingDate <= @date2 )
   GROUP BY

a~billingdocument,
a~accountingdocument,
a~postingdate,
a~accountingdocumenttype,
a~companycode,
a~fiscalyear,
a~product,
a~clearingjournalentry ,
a~debitcreditcode,
a~baseunit,
a~financialaccounttype,
a~documentdate
    APPENDING TABLE @it_tab.
    ENDIF.

    DATA gst1 TYPE string .
    DATA cin1 TYPE string .
    DATA pan1 TYPE string .
    DATA Register1 TYPE string .
    DATA Register2 TYPE string .
    DATA Register3 TYPE string .

    SELECT SINGLE
    a~address1,
    a~address2,
    a~district,
    a~city,
    a~STATE_Name,
    a~pin,
    a~country,
    a~GSTin_No,
    a~PAN_No,
    a~Cin_No,
    a~plant_name1
    FROM ztable_plant AS a
    WHERE a~comp_code = @companycode
    INTO  @DATA(Plant_address).

    IF plant_address IS NOT INITIAL.
      DATA(lv_plant_address) = |{ Plant_address-address1 }, { Plant_address-address2 }, { Plant_address-city }, { Plant_address-state_name }-{ Plant_address-pin }|.
    ELSE.
      lv_plant_address = ' '.
    ENDIF.

    SORT it_tab BY billingdocument accountingdocument  .

    IF it_tab IS NOT INITIAL.
      SELECT product,
          quantity,
          baseunit,
          billingdocument,
          a~accountingdocument,
          accountingdocumentitem,
          AmountInCompanyCodeCurrency AS amountintransactioncurrency,
          CashDiscountAmount,
          transactiontypedetermination,
          debitcreditcode,
          withholdingtaxamount,
          costcenter,
          a~accountingdocumenttype,
          HouseBank,
          glaccount,
          a~supplier,
          a~documentdate,
          a~DocumentItemText
     FROM i_operationalacctgdocitem AS a
*     LEFT JOIN i_customer AS b ON a~Supplier = b~Supplier
     INNER JOIN i_journalentry AS c
       ON  c~accountingdocument = a~accountingdocument
       AND c~companycode = a~companycode
       AND c~fiscalyear = a~fiscalyear
       AND c~isreversal <> 'X'
       AND c~isreversed <> 'X'
       AND  a~SpecialGLCode NE 'F'
     FOR ALL ENTRIES IN @it_tab
     WHERE a~companycode = @it_tab-companycode
       AND a~fiscalyear = @it_tab-fiscalyear
       AND a~accountingdocument = @it_tab-accountingdocument
       AND ( @profitcenter IS INITIAL OR a~profitcenter = @profitcenter )
       AND a~postingdate BETWEEN @date3 AND @date2
     INTO TABLE @DATA(it_tab2).

    ENDIF.
    IF it_tab IS NOT INITIAL AND supplier_as_cust IS NOT INITIAL AND both = 'true'.
      SELECT product,
          quantity,
          baseunit,
          billingdocument,
          a~accountingdocument,
          accountingdocumentitem,
          AmountInCompanyCodeCurrency AS amountintransactioncurrency,
          CashDiscountAmount,
          transactiontypedetermination,
          debitcreditcode,
          withholdingtaxamount,
          costcenter,
          a~accountingdocumenttype,
          HouseBank,
          glaccount,
          a~supplier,
          a~documentdate,
          a~DocumentItemText
     FROM i_operationalacctgdocitem AS a
             LEFT JOIN I_supplier AS b ON a~Customer = b~Customer
             INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                    AND c~CompanyCode = a~CompanyCode
                                                    AND c~FiscalYear = a~FiscalYear
                                                    AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )

             FOR ALL ENTRIES IN @it_tab
             WHERE a~companycode          = @it_tab-companycode
               AND a~fiscalyear           = @it_tab-fiscalyear
               AND a~accountingdocument   = @it_tab-accountingdocument
               AND ( @profitcenter IS INITIAL OR a~profitcenter = @profitcenter )
               AND a~AccountingDocumentType  <> 'WL' AND a~AccountingDocumentType  <> 'WA' AND a~AccountingDocumentType  <> 'WE'
               AND  a~SpecialGLCode NE 'F'
               AND a~PostingDate GE @date3 AND a~PostingDate LE @date2
               APPENDING TABLE @it_tab2 .

    ENDIF.

    "********************************************OPENING AMT***********************************************88
    SORT it_tab  BY postingdate accountingdocument billingdocument.
    DATA(opening) = w_head-opening_bal.

**********************************************************************************for today's date
    DATA(todaydate) = cl_abap_context_info=>get_system_date( ).
    DATA opening_bal TYPE p DECIMALS 2.

    DATA openingdate TYPE I_OperationalAcctgDocItem-PostingDate.


    DATA(day)   =  lastdate+0(2).
    DATA(month) = lastdate+3(2).
    DATA(year)  = lastdate+6(4).

    CONCATENATE year month day INTO openingdate.

    DATA(openingfinaldate) =  lastdate+0(2) && '.' &&
                              lastdate+3(2) && '.' &&
                              lastdate+6(4).
*    CONCATENATE day '.' month '.' year INTO openingfinaldate.

    SELECT amountintransactioncurrency , accountingdocument , accountingdocumenttype
      FROM i_operationalacctgdocitem AS a
*      left join i_customer as b on a~Supplier = b~Supplier
      WHERE a~Supplier = @customer
        AND postingdate < @openingdate
        and CompanyCode = @companycode
        AND clearingjournalentry IS INITIAL
        AND AccountingDocumentType  <> 'WL' AND AccountingDocumentType  <> 'WA' AND AccountingDocumentType  <> 'WE'
        AND AccountingDocumentitemType IS INITIAL
        AND  SpecialGLCode NE 'F'
        AND companycode = @companycode
      INTO TABLE @DATA(openingbal).
    IF supplier_as_cust IS NOT INITIAL AND both = 'true'.
      SELECT amountintransactioncurrency , accountingdocument , accountingdocumenttype
 FROM i_operationalacctgdocitem AS a
  LEFT JOIN I_supplier AS b ON a~Customer = b~Customer
 WHERE a~Customer = @customer
   AND postingdate < @openingdate
   and CompanyCode = @companycode
   AND clearingjournalentry IS INITIAL
   AND SpecialGLCode NE 'F'
   AND AccountingDocumentType  <> 'WL' AND AccountingDocumentType  <> 'WA' AND AccountingDocumentType  <> 'WE'
   AND AccountingDocumentitemType IS INITIAL
   AND companycode = @companycode
 APPENDING TABLE @openingbal.
    ENDIF.

    LOOP AT openingbal INTO DATA(wa_openingbal).
      opening_bal = opening_bal + wa_openingbal-amountintransactioncurrency.
    ENDLOOP.
*  for calculation and display purpose
    DATA final_opening_bal1 TYPE i_operationalacctgdocitem-amountincompanycodecurrency.
    final_opening_bal1 = opening_bal.
    IF final_opening_bal1 < 0.
      final_opening_bal1 = final_opening_bal1 * -1.
    ENDIF.

    todaydate = todaydate+6(2) && '/' &&
                todaydate+4(2) && '/' &&
                todaydate(4).
    DATA(FromDateTodate) = |Period From { lastdate } Period To { currentdate }|.

    SELECT SINGLE * FROM i_supplier AS a
LEFT OUTER  JOIN I_SuplrBankDetailsByIntId AS b ON ( b~Supplier = a~Supplier   )
LEFT OUTER  JOIN  I_Bank_2 AS f ON ( f~BankInternalID = b~Bank  )  WHERE a~Supplier = @customer  INTO @DATA(supplier).

**************************************************************************************** BY VK

    """""""""""""""""""""""""""""""""""""""""""""""Address"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    DATA(lv_xml) =
   |<form1>| &&
   |<plantname>{ plant_address-plant_name1 }</plantname>| &&
   |<address1>{ lv_plant_address }</address1>| &&
   |<CINNO>{ Plant_address-cin_no }</CINNO>| &&
   |<GSTIN>{ Plant_address-gstin_no }</GSTIN>| &&
   |<PAN>{ Plant_address-pan_no }</PAN>| &&
   |<LeftSide>| &&
   |<partyno>{ supplier-a-SupplierName }</partyno>| &&
   |<ccode>({ customer })</ccode>| &&
   |<companyCode>{ companyCode }</companyCode>| &&
   |<partyadd>{ supplier-a-CityName }-{ supplier-a-PostalCode }</partyadd>| &&
   |<partyadd1>{ supplier-a-TaxNumber3 }</partyadd1>| &&
   |<REPORTDATE>{ todaydate }</REPORTDATE>| &&
   |<FromDateTodate>{ FromDateTodate }</FromDateTodate>| &&
   |<Subform7/>| &&
   |</LeftSide>| &&
   |<RightSide>| &&
*      |<date></date>| &&
   |<openingdate>{ openingfinaldate }</openingdate>| &&
   |<openingBal>{ opening_bal }</openingBal>| &&
   |<OpeningBalance>{ final_opening_bal1 }</OpeningBalance>| &&
*      |<TransporterName></TransporterName>| &&
*      |<FromDate>{ lastdate }</FromDate>| &&
   |<ToDate>{ currentdate }</ToDate>| &&
   |<Page>| &&
   |<HaderData>| &&
   |<RightSide>| &&
   |<StationNo></StationNo>| &&
   |</RightSide>| &&
   |</HaderData>| &&
   |</Page>| &&
   |</RightSide>|.
*      |<BankDetail>| &&
*      |<BankName>{ supplier-f-BankName }</BankName>| &&
*      |<AccountNo>{ supplier-b-BankAccount }</AccountNo>| &&
*      |<IFSC>{ supplier-b-Bank }</IFSC>| &&
*      |</BankDetail>| .
*      |<chk_mark>{ confirmletterbox }</chk_mark>| .

    LOOP AT it_tab INTO DATA(wa_tab).

      IF  wa_tab-billingdocument IS NOT INITIAL.
        wa_final-document    = wa_tab-billingdocument.
      ELSE.
        wa_final-document = wa_tab-accountingdocument.
      ENDIF.
      wa_final-postingdate                 = wa_tab-postingdate.
      wa_final-accountingdocumenttype      = wa_tab-accountingdocumenttype.
      wa_final-amountintransactioncurrency = wa_tab-amountintransactioncurrency.
      wa_final-CashDiscountAmount           =  wa_tab-CashDiscountAmount.
      wa_final-debitcreditcode             = wa_tab-debitcreditcode.
      wa_final-fiscalyear             = wa_tab-FiscalYear.
      wa_final-companycode             = wa_tab-CompanyCode.
      wa_final-financialaccounttype  = wa_tab-FinancialAccountType.

      IF wa_final-DebitCreditCode = 'S' AND wa_final-amountintransactioncurrency > 0.
        wa_final-deb_amt =  wa_tab-amountintransactioncurrency.
      ELSEIF
      wa_final-DebitCreditCode = 'H' OR wa_final-amountintransactioncurrency < 0 .
        wa_final-cre_amt =  wa_tab-amountintransactioncurrency.
      ENDIF.
      LOOP AT it_tab2 INTO DATA(wa_tab2) WHERE accountingdocument = wa_tab-accountingdocument  .


*******************************************************************************************
        DATA: lv_documentdate TYPE string.
        lv_documentdate = wa_tab2-documentdate+6(2) && '/' &&
                          wa_tab2-documentdate+4(2) && '/' &&
                          wa_tab2-documentdate(4).
        IF both = 'false'.
          IF wa_tab2-AccountingDocumentType  NE 'KZ'.

            SELECT SINGLE FROM i_operationalacctgdocitem AS a
             INNER JOIN i_journalentry AS d ON ( d~accountingdocument = a~accountingdocument
                                                 AND d~companycode = a~companycode
                                                 AND d~fiscalyear = a~fiscalyear
                                                 AND d~isreversal <> 'X' AND d~isreversed <> 'X' )
             FIELDS a~accountingdocument, a~billingdocument , d~DocumentReferenceID , a~DocumentItemText
               WHERE a~accountingdocument = @wa_tab2-accountingdocument
                  AND a~PostingDate GE @date3 AND a~PostingDate LE @date2
                 AND a~companycode = @companycode
                AND  a~SpecialGLCode NE 'F'
              INTO @DATA(wa_naration).

            IF  wa_naration-DocumentItemText IS INITIAL.
              DATA(lv_naration) = |Inv. No: { wa_naration-DocumentReferenceID } Dt: { lv_documentdate }|.
            ELSE.
              lv_naration = |Inv. No: { wa_naration-DocumentReferenceID } Dt: { lv_documentdate } BEING:{ wa_naration-DocumentItemText }|.
            ENDIF.

          ELSEIF wa_tab2-AccountingDocumentType  = 'KZ'.
            SELECT SINGLE b~bankname , c~businesspartnername ,a~clearingjournalentry, a~documentitemtext
              FROM i_operationalacctgdocitem AS a
              LEFT JOIN i_housebankbasic AS b ON a~CompanyCode = b~CompanyCode  AND b~HouseBank = b~HouseBank
              LEFT JOIN i_businesspartner AS c ON c~BusinessPartner = a~Supplier
              WHERE a~Supplier = @customer
                 AND  a~SpecialGLCode NE 'F'
                    AND a~PostingDate GE @date3 AND a~PostingDate LE @date2
                    AND a~companycode = @companycode
                AND ( @profitcenter IS INITIAL OR a~profitcenter = @profitcenter )
              INTO @DATA(wa_naration1).

            IF wa_naration1-clearingjournalentry IS INITIAL.
              lv_naration = |To amount { wa_naration1-BankName } against { wa_naration1-BusinessPartnerName },{ wa_naration1-documentitemtext }|.

            ELSE.
              lv_naration = |To amount NEFT from { wa_naration1-BankName } against { wa_naration1-BusinessPartnerName } (E-Net Ref. No. { wa_naration1-ClearingJournalEntry })|.
            ENDIF.
          ELSEIF wa_tab2-AccountingDocumentType = 'CP'.
            DATA(CustomerName) = lv_cutomer.
            REPLACE ALL OCCURRENCES OF '/' IN CustomerName WITH '&'.
            lv_naration = |By Amount Of Cash Received From { CustomerName })|.
          ENDIF.
        ENDIF.
**********************************************************************************************************************************

        IF supplier_as_cust IS NOT INITIAL AND both = 'true'.
          IF ( wa_tab2-AccountingDocumentType EQ 'KA' OR  wa_tab2-AccountingDocumentType EQ 'KG' OR  wa_tab2-AccountingDocumentType EQ 'KR' OR
          wa_tab2-AccountingDocumentType EQ 'KP' OR  wa_tab2-AccountingDocumentType EQ 'KZ' OR  wa_tab2-AccountingDocumentType EQ 'RE' ).
            IF wa_tab2-AccountingDocumentType  NE 'KZ'.

              SELECT SINGLE FROM i_operationalacctgdocitem AS a
               INNER JOIN i_journalentry AS d ON ( d~accountingdocument = a~accountingdocument
                                                   AND d~companycode = a~companycode
                                                   AND d~fiscalyear = a~fiscalyear
                                                   AND d~isreversal <> 'X' AND d~isreversed <> 'X' )
               FIELDS a~accountingdocument, a~billingdocument , d~DocumentReferenceID , a~DocumentItemText
                 WHERE a~accountingdocument = @wa_tab2-accountingdocument
                    AND a~PostingDate GE @date3 AND a~PostingDate LE @date2
                   AND a~companycode = @companycode
                  AND  a~SpecialGLCode NE 'F'
                INTO @DATA(sup1).

              IF  wa_naration-DocumentItemText IS INITIAL.
                lv_naration = |Inv. No: { sup1-DocumentReferenceID } Dt: { lv_documentdate }|.
              ELSE.
                lv_naration = |Inv. No: { sup1-DocumentReferenceID } Dt: { lv_documentdate } BEING:{ sup1-DocumentItemText }|.
              ENDIF.

            ELSEIF wa_tab2-AccountingDocumentType  = 'KZ'.
              SELECT SINGLE b~bankname , c~businesspartnername ,a~clearingjournalentry
                FROM i_operationalacctgdocitem AS a
                LEFT JOIN i_housebankbasic AS b ON a~CompanyCode = b~CompanyCode  AND b~HouseBank = b~HouseBank
                LEFT JOIN i_businesspartner AS c ON c~BusinessPartner = a~Supplier
                WHERE a~Supplier = @customer
                   AND  a~SpecialGLCode NE 'F'
                      AND a~PostingDate GE @date3 AND a~PostingDate LE @date2
                      AND a~companycode = @companycode
                  AND ( @profitcenter IS INITIAL OR a~profitcenter = @profitcenter )
                INTO @DATA(sup2).

              IF wa_naration1-clearingjournalentry IS INITIAL.
                lv_naration = |To amount { sup2-BankName } against { sup2-BusinessPartnerName }|.

              ELSE.
                lv_naration = |To amount NEFT from { sup2-BankName } against { sup2-BusinessPartnerName } (E-Net Ref. No. { sup2-ClearingJournalEntry })|.
              ENDIF.
            ELSEIF wa_tab2-AccountingDocumentType = 'CP'.
              CustomerName = lv_cutomer.
              REPLACE ALL OCCURRENCES OF '/' IN CustomerName WITH '&'.
              lv_naration = |By Amount Of Cash Received From { CustomerName })|.
            ENDIF.
          ELSEIF ( wa_tab2-AccountingDocumentType EQ 'DA' OR  wa_tab2-AccountingDocumentType EQ 'DG' OR  wa_tab2-AccountingDocumentType EQ 'DR' OR
        wa_tab2-AccountingDocumentType EQ 'DV' OR  wa_tab2-AccountingDocumentType EQ 'DZ' OR  wa_tab2-AccountingDocumentType EQ 'RV' ).
             IF wa_tab2-AccountingDocumentType NE 'RV' AND wa_tab2-AccountingDocumentType NE 'DZ'.
              SELECT SINGLE FROM I_AccountingDocumentJournal AS a
               FIELDS a~DocumentReferenceID
               WHERE a~AccountingDocument = @wa_tab2-AccountingDocument
                AND   a~Ledger = '0L'
                AND   a~CompanyCode = @CompanyCode
                AND a~PostingDate GE @date3 AND a~PostingDate LE @date2
                INTO @DATA(wa_naration6).
           lv_naration = |Inv. No: { wa_naration6 } Dt: { lv_documentdate }|.

            ELSEIF wa_tab2-AccountingDocumentType  NE 'DZ'.

              SELECT SINGLE FROM i_operationalacctgdocitem AS a
              INNER JOIN i_billingdocument AS b ON a~billingdocument = b~billingdocument
              INNER JOIN i_billingdocumentitem AS c ON b~billingdocument = c~billingdocument
              FIELDS a~accountingdocument, a~billingdocument , b~DocumentReferenceID , c~ReferenceSDDocument AS SalesDocument
                WHERE a~accountingdocument = @wa_tab2-accountingdocument
                 AND  a~SpecialGLCode NE 'F'
               INTO @DATA(wa_naration5).

              IF wa_naration5-salesdocument IS INITIAL.
                lv_naration = |Inv. No: { wa_naration5-DocumentReferenceID } Dt: { lv_documentdate }|.
              ELSE.
                lv_naration = |Inv. No: { wa_naration5-DocumentReferenceID } Dt: { lv_documentdate } SO: { wa_naration5-salesdocument }|.
              ENDIF.

            ELSEIF wa_tab2-AccountingDocumentType  = 'DZ'.
              SELECT SINGLE b~bankname , c~businesspartnername ,a~clearingjournalentry
                FROM i_operationalacctgdocitem AS a
                LEFT JOIN i_housebankbasic AS b ON a~CompanyCode = b~CompanyCode  AND b~HouseBank = b~HouseBank
                LEFT JOIN i_businesspartner AS c ON c~BusinessPartner = a~Supplier
                WHERE a~Supplier = @customer
                 AND  a~SpecialGLCode NE 'F'
                INTO @DATA(wa_naration8).
              IF wa_naration1-clearingjournalentry IS INITIAL.
                lv_naration = |To amount { wa_naration8-BankName } against { wa_naration8-BusinessPartnerName }|.

              ELSE.
                lv_naration = |To amount NEFT from { wa_naration1-BankName } against { wa_naration1-BusinessPartnerName } (E-Net Ref. No. { wa_naration1-ClearingJournalEntry })|.
              ENDIF.
            ELSEIF wa_tab2-AccountingDocumentType = 'CR'.
              CustomerName = lv_cutomer.
              REPLACE ALL OCCURRENCES OF '/' IN CustomerName WITH '&'.
              lv_naration = |By Amount Of Cash Received From { CustomerName })|.
            ENDIf.
        ENDIF.
      ENDIF.


*******************************************************************************************





      wa_final-quantity = wa_final-quantity + wa_tab2-quantity.
    ENDLOOP.

    wa_final-closing_bal =  opening + wa_final-cre_amt + wa_final-deb_amt .
    w_head-closing_bal =  opening + wa_final-cre_amt + wa_final-deb_amt .
    opening =  opening + wa_final-cre_amt + wa_final-deb_amt .

    wa_final-naration = lv_naration.
    APPEND wa_final TO it_final.
    CLEAR wa_final.

  ENDLOOP.

  CLEAR rec.


*    for calculation and display purpose
  DATA: TotalClosingbal           TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency,
        credit_Total              TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency,
        debit_Total               TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency,
        final_line_closingbalance TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency,
        final_line_creditbalance  TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency,
        final_line_debitbalance   TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency,
        line_closingvalue         TYPE c LENGTH 2.
  DATA: lineitem_closingcalcu TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency.
  LOOP AT it_final INTO wa_final.

    credit_Total = credit_Total + wa_final-cre_amt.
    debit_Total = debit_Total + wa_final-deb_amt.
    IF sy-tabix = 1.
      wa_final-closing_bal = wa_final-deb_amt + wa_final-cre_amt + opening_bal.
    ELSE.
      wa_final-closing_bal = wa_final-deb_amt + wa_final-cre_amt + lineitem_closingcalcu.
    ENDIF.
    lineitem_closingcalcu = wa_final-closing_bal.
    final_line_closingbalance = wa_final-closing_bal.
*********************************************************************
    IF final_line_closingbalance < 0.
      line_closingvalue = 'cr'.
    ELSEIF final_line_closingbalance > 0.
      line_closingvalue = 'dr'.
    ENDIF.
*********************************************************************
    IF final_line_closingbalance < 0.
      final_line_closingbalance = final_line_closingbalance * -1.
    ENDIF.
    final_line_creditbalance = wa_final-cre_amt.
    IF final_line_creditbalance < 0.
      final_line_creditbalance = final_line_creditbalance * -1.
    ENDIF.
    final_line_debitbalance = wa_final-deb_amt.
    IF final_line_debitbalance < 0.
      final_line_debitbalance = final_line_debitbalance * -1.
    ENDIF.


    rec = rec + 1.
    DATA(count) = lines( it_final ).
    SELECT SINGLE DocumentDate FROM I_OperationalAcctgDocItem
    WHERE AccountingDocument = @wa_final-document AND CompanyCode = @wa_final-CompanyCode
    AND FiscalYear = @wa_final-FiscalYear INTO @DATA(invdt).



      lv_xml = lv_xml &&

         |<LopTab>| &&
         |<Row1>| &&
         |<invoicedate>{ invdt }</invoicedate>| &&
         |<docdate>{ wa_final-postingdate+6(2) }.{ wa_final-postingdate+4(2) }.{ wa_final-postingdate+0(4) }</docdate>| &&
         |<naration>{ wa_final-naration  }</naration>| &&
         |<JournalEntry>{ wa_final-document }</JournalEntry>| &&
         |<debitamt>{ final_line_debitbalance }</debitamt>| &&
         |<creditamt>{ final_line_creditbalance }</creditamt>| &&
         |<Balance>{ final_line_closingbalance } { line_closingvalue }</Balance>| &&
         |</Row1>| &&
         |</LopTab>|.

      IF rec = count.
        close_bal = wa_final-closing_bal.
      ENDIF.

      CLEAR:wa_final.
    ENDLOOP.
    CLEAR final_line_closingbalance.
    DATA credittotal TYPE i_operationalacctgdocitem-amountincompanycodecurrency.

    IF credit_Total < 0.
      credittotal = credit_Total * -1.
    ENDIF.
    IF opening_bal < 0.
      TotalClosingbal = credittotal - debit_total  - opening_bal.
    ENDIF.
    IF TotalClosingbal < 0.
      TotalClosingbal = TotalClosingbal * -1.
    ENDIF.

    lv_xml = lv_xml &&

      |<Subform3>| &&
      |<Table3>| &&
      |<Row1>| &&
      |<closingbl>{ TotalClosingbal }</closingbl>| &&
      |</Row1>| &&
      |</Table3>| &&
      |</Subform3>| &&
      |</form1>| .

    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'zxcvbnm'.
    DATA:res TYPE string.
    CALL METHOD zcl_ads_master=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = res ).
    CONCATENATE result12 res INTO result12.
    CONDENSE result12 NO-GAPS.
  ENDMETHOD.
ENDCLASS.
