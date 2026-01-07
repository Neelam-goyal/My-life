

CLASS zcl_vprint_xml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct.


    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING
                  lv_companycode        TYPE string
                  lv_fiscalyear         TYPE string
                  lv_accountingdocument TYPE string
                  lc_template_name      TYPE string
        RETURNING VALUE(result12)       TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.

ENDCLASS.



CLASS ZCL_VPRINT_XML IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

    SELECT SINGLE rec~companycode,
      rec~fiscalyear,
      rec~accountingdocument,
      rec~companycodename,

      rec~housenumber,
      rec~street,
      rec~pincode,
      rec~city,
      rec~region,
      rec~country,

      rec~plantcode,

      rec~currency,
      rec~accountingdocumenttype,
      rec~accountingdocumenttypename,
      rec~businesstransactiontype,
      rec~businesstransactiontypename,
      rec~documentdate,
      rec~postingdate,
      rec~referencedocumenttype,
      rec~referencedocumenttypename,
      rec~documentreferenceid,
      rec~originalreferencedocument,
      rec~misctext,
      rec~profitcenter,
      rec~amount,
      rec~userdescription,
      rec~createdon,
      rec~lastchangedon
    FROM
     z_cds_vprint_header( p_companycode = @lv_companycode ,
      p_fiscalyear = @lv_fiscalyear,
      p_accountingdocument = @lv_accountingdocument ) AS rec


    INTO @DATA(wa).

    IF wa IS NOT INITIAL.
      IF wa-plantcode IS NOT INITIAL OR wa-plantcode <> ''.

        SELECT SINGLE
           zi_planttable~compcode,
           zi_planttable~plantcode,
           zi_planttable~plantname1,
           zi_planttable~plantname2,
           zi_planttable~address1,
           zi_planttable~address2,
           zi_planttable~address3,
           zi_planttable~city,
           zi_planttable~district,
           zi_planttable~statecode1,
           zi_planttable~statecode2,
           zi_planttable~statename,
           zi_planttable~pin,
           zi_planttable~country,
           zi_planttable~cinno,
           zi_planttable~gstinno,
           zi_planttable~fssaino,
           zi_planttable~panno
         FROM
          zi_planttable
        WHERE zi_planttable~plantcode = @wa-plantcode
        AND zi_planttable~compcode = @lv_companycode
        INTO @DATA(plant).
      ENDIF.



      SELECT

           rec~companycode,
           rec~fiscalyear,
           rec~accountingdocument,
           rec~ledgergllineitem,
           rec~postingdate,
           rec~documentdate,
           rec~accountingdocumenttype,
           rec~accountingdocumentitem,
           rec~assignmentreference,
           rec~accountingdocumentcategory,
           rec~controllingarea,
           rec~controllingareaname,
           rec~debitcreditcode,
           rec~CompanyCodeCurrency,
           rec~AmountInCompanyCodeCurrency,
           rec~CreditAmountInCoCodeCrcy,
           rec~DebitAmountInCoCodeCrcy,
           rec~referencedocumenttype,
           rec~glaccount,
           rec~glaccountname,
           rec~chartofaccounts,
           rec~costcenter,
           rec~costcentername,
           rec~profitcenter,
           rec~profitcentername,
           rec~functionalarea,
           rec~functionalareaname,
           rec~businessarea,
           rec~businessareaname,
           rec~segment,
           rec~segmentname,
           rec~postingkey,
           rec~postingkeyname,
           rec~transactiontypedetermination,
           rec~alternativeglaccount,
           rec~invoicereference,
           rec~invoicereferencefiscalyear,
           rec~followondocumenttype,
           rec~invoiceitemreference,
           rec~purchasingdocument,
           rec~purchasingdocumentitem,
           rec~accountassignmentnumber,
           rec~documentitemtext,
           rec~salesdocument,
           rec~salesdocumentitem,
           rec~product,
           rec~productname,
           rec~plant,
           rec~plantname,
           rec~supplier,
           rec~suppliername,
           rec~suppliercountry,
           rec~customer,
           rec~customername,
           rec~customercountry,
           rec~taxcode,
           rec~housebank,
           rec~housebankaccount,
           rec~housebankaccountdescription,
           rec~isopenitemmanaged,
           rec~clearingdate,
           rec~clearingjournalentryfiscalyear,
           rec~clearingjournalentry,
           rec~valuedate,
           rec~costorigingroup,
           rec~offsettingaccount,
           rec~offsettingaccounttype,
           rec~offsettingchartofaccounts,
           rec~personnelnumber,
           rec~netduedate
         FROM
          z_cds_vprint_detail( p_companycode = @lv_companycode ,
           p_fiscalyear = @lv_fiscalyear,
           p_accountingdocument = @lv_accountingdocument ) AS rec
           WHERE rec~companycode IS NOT INITIAL
            ORDER BY rec~ledgergllineitem
         INTO TABLE @DATA(it_lines).

      DATA CompanyName TYPE string VALUE ''.
      DATA AddressLine1 TYPE string VALUE ''.
      DATA AddressLine2 TYPE string VALUE ''.


      IF plant IS NOT INITIAL.
        CompanyName = |{ plant-PlantName1 }|.
        AddressLine1 = |{ plant-Address1 }, { plant-city }, { plant-StateCode2 }-{ plant-Pin }|.
        AddressLine2 = replace( val = plant-PlantName2 off = 0 len = 4 with = 'Plant  ').
      ELSE.
        companyname = |{ wa-CompanyCodeName }|.
        AddressLine1 = |{ wa-housenumber }, { wa-street }|.
        AddressLine2 = |{ wa-city }, { wa-region }-{ wa-PINCode }|.
      ENDIF.

* Header
      DATA(lv_xml) = |<Form>| &&
                      |<AccountingRow>| &&
                      |<InternalDocumentNode>| &&
                      |<CompanyCode>{ wa-companycode }</CompanyCode>| &&
                      |<FiscalYear>{ wa-fiscalyear }</FiscalYear>| &&
                      |<AccountingDocument>{ wa-accountingdocument }</AccountingDocument>| &&
                      |<CompanyCodeName>{ CompanyName }</CompanyCodeName>| &&

                      |<AddressLine1>{ AddressLine1 }</AddressLine1>| &&
                      |<AddressLine2>{ AddressLine2 }</AddressLine2>| &&

                      |<Currency>{ wa-currency }</Currency>| &&
                      |<ProfitCenter>{ wa-profitcenter }</ProfitCenter>| &&
                      |<AccountingDocumentType>{ wa-accountingdocumenttype }</AccountingDocumentType>| &&
                      |<AccountingDocumentTypeName>{ wa-accountingdocumenttypename }</AccountingDocumentTypeName>| &&
                      |<BusinessTransactionType>{ wa-businesstransactiontype }</BusinessTransactionType>| &&
                      |<BusinessTransactionTypeName>{ wa-businesstransactiontypename }</BusinessTransactionTypeName>| &&
                      |<DocumentDate>{ wa-documentdate }</DocumentDate>| &&
                      |<PostingDate>{ wa-postingdate }</PostingDate>| &&
                      |<ReferenceDocumentType>{ wa-referencedocumenttype }</ReferenceDocumentType>| &&
                      |<ReferenceDocumentTypeName>{ wa-referencedocumenttypename }</ReferenceDocumentTypeName>| &&
                      |<DocumentReferenceID>{ wa-documentreferenceid }</DocumentReferenceID>| &&
                      |<OriginalReferenceDocument>{ wa-originalreferencedocument }</OriginalReferenceDocument>| &&
                      |<MiscText>{ wa-misctext }</MiscText>| &&
                      |<Amount>{ wa-amount }</Amount>| &&

                      |<UserDescription>{ wa-userdescription }</UserDescription>| &&
                      |<CreatedOn>{ wa-createdon }</CreatedOn>| &&
                      |<LastChangedOn>{ wa-lastchangedon }</LastChangedOn>| &&
                      |</InternalDocumentNode>| &&
                      |<Table>|.


* Item
      LOOP AT it_lines INTO DATA(wa_lines).


        DATA(lv_xml1) = |<tableDataRows>| &&

                         |<CompanyCode>{ wa_lines-companycode }</CompanyCode>| &&
                         |<FiscalYear>{ wa_lines-fiscalyear }</FiscalYear>| &&
                         |<AccountingDocument>{ wa_lines-accountingdocument }</AccountingDocument>| &&
                         |<LedgerGLLineItem>{ wa_lines-ledgergllineitem }</LedgerGLLineItem>| &&

                         |<PostingDate>{ wa_lines-postingdate }</PostingDate>| &&
                         |<DocumentDate>{ wa_lines-documentdate }</DocumentDate>| &&
                         |<AccountingDocumentType>{ wa_lines-accountingdocumenttype }</AccountingDocumentType>| &&
                         |<AccountingDocumentItem>{ wa_lines-accountingdocumentitem }</AccountingDocumentItem>| &&
                         |<AssignmentReference>{ wa_lines-assignmentreference }</AssignmentReference>| &&
                         |<AccountingDocumentCategory>{ wa_lines-accountingdocumentcategory }</AccountingDocumentCategory>| &&

                         |<ControllingArea>{ wa_lines-controllingarea }</ControllingArea>| &&
                         |<ControllingAreaName>{ wa_lines-controllingareaname }</ControllingAreaName>| &&
                         |<DebitCreditCode>{ wa_lines-debitcreditcode }</DebitCreditCode>| &&

                         |<CompanyCodeCurrency>{ wa_lines-CompanyCodeCurrency }</CompanyCodeCurrency>| &&
                         |<AmountInCompanyCodeCurrency>{ wa_lines-AmountInCompanyCodeCurrency }</AmountInCompanyCodeCurrency>| &&
                         |<CreditAmountInCoCodeCrcy>{ wa_lines-CreditAmountInCoCodeCrcy }</CreditAmountInCoCodeCrcy>| &&
                         |<DebitAmountInCoCodeCrcy>{ wa_lines-DebitAmountInCoCodeCrcy }</DebitAmountInCoCodeCrcy>| &&

                         |<ReferenceDocumentType>{ wa_lines-referencedocumenttype }</ReferenceDocumentType>| &&

                         |<GLAccount>{ wa_lines-glaccount }</GLAccount>| &&
                         |<GLAccountName>{ wa_lines-glaccountname } </GLAccountName>| &&
                         |<ChartOfAccounts>{ wa_lines-chartofaccounts }</ChartOfAccounts>| &&
                         |<CostCenter>{ wa_lines-costcenter }</CostCenter>| &&
                         |<CostCenterName>{ wa_lines-costcentername }</CostCenterName>| &&
                         |<ProfitCenter>{ wa_lines-profitcenter }</ProfitCenter>| &&
                         |<ProfitCenterName>{ wa_lines-profitcentername }</ProfitCenterName>| &&
                         |<FunctionalArea>{ wa_lines-functionalarea }</FunctionalArea>| &&
                         |<FunctionalAreaName>{ wa_lines-functionalareaname }</FunctionalAreaName>| &&
                         |<BusinessArea>{ wa_lines-businessarea }</BusinessArea>| &&
                         |<BusinessAreaName>{ wa_lines-businessareaname }</BusinessAreaName>| &&
                         |<Segment>{ wa_lines-segment }</Segment>| &&
                         |<SegmentName>{ wa_lines-segmentname }</SegmentName>| &&

                         |<PostingKey>{ wa_lines-postingkey }</PostingKey>| &&
                         |<PostingKeyName>{ wa_lines-postingkeyname }</PostingKeyName>| &&
                         |<TransactionTypeDetermination>{ wa_lines-transactiontypedetermination }</TransactionTypeDetermination>| &&

                         |<AlternativeGLAccount>{ wa_lines-alternativeglaccount }</AlternativeGLAccount>| &&
                         |<InvoiceReference>{ wa_lines-invoicereference }</InvoiceReference>| &&
                         |<InvoiceReferenceFiscalYear>{ wa_lines-invoicereferencefiscalyear }</InvoiceReferenceFiscalYear>| &&
                         |<FollowOnDocumentType>{ wa_lines-followondocumenttype }</FollowOnDocumentType>| &&
                         |<InvoiceItemReference>{ wa_lines-invoiceitemreference }</InvoiceItemReference>| &&
                         |<PurchasingDocument>{ wa_lines-purchasingdocument }</PurchasingDocument>| &&
                         |<PurchasingDocumentItem>{ wa_lines-purchasingdocumentitem }</PurchasingDocumentItem>| &&
                         |<AccountAssignmentNumber>{ wa_lines-accountassignmentnumber }</AccountAssignmentNumber>| &&
                         |<DocumentItemText>{ wa_lines-documentitemtext }</DocumentItemText>| &&
                         |<SalesDocument>{ wa_lines-salesdocument }</SalesDocument>| &&
                         |<SalesDocumentItem>{ wa_lines-salesdocumentitem }</SalesDocumentItem>| &&

                         |<Product>{ wa_lines-product }</Product>| &&
                         |<ProductName>{ wa_lines-productname }</ProductName>| &&

                         |<Plant>{ wa_lines-plant }</Plant>| &&
                         |<PlantName>{ wa_lines-plantname }</PlantName>| &&
                         |<Supplier>{ wa_lines-supplier }</Supplier>| &&
                         |<SupplierName>{ wa_lines-suppliername }</SupplierName>| &&
                         |<SupplierCountry>{ wa_lines-suppliercountry }</SupplierCountry>| &&
                         |<Customer>{ wa_lines-customer }</Customer>| &&
                         |<CustomerName>{ wa_lines-customername }</CustomerName>| &&
                         |<CustomerCountry>{ wa_lines-customercountry }</CustomerCountry>| &&
                         |<TaxCode>{ wa_lines-taxcode }</TaxCode>| &&
                         |<HouseBank>{ wa_lines-housebank }</HouseBank>| &&
                         |<HouseBankAccount>{ wa_lines-housebankaccount }</HouseBankAccount>| &&
                         |<HouseBankAccountDescription>{ wa_lines-housebankaccountdescription }</HouseBankAccountDescription>| &&
                         |<IsOpenItemManaged>{ wa_lines-isopenitemmanaged }</IsOpenItemManaged>| &&
                         |<ClearingDate>{ wa_lines-clearingdate }</ClearingDate>| &&
                         |<ClearingJournalEntryFiscalYear>{ wa_lines-clearingjournalentryfiscalyear }</ClearingJournalEntryFiscalYear>| &&
                         |<ClearingJournalEntry>{ wa_lines-clearingjournalentry }</ClearingJournalEntry>| &&
                         |<ValueDate>{ wa_lines-valuedate }</ValueDate>| &&

                         |<CostOriginGroup>{ wa_lines-costorigingroup }</CostOriginGroup>| &&

                         |<OffsettingAccount>{ wa_lines-offsettingaccount }</OffsettingAccount>| &&
                         |<OffsettingAccountType>{ wa_lines-offsettingaccounttype }</OffsettingAccountType>| &&
                         |<OffsettingChartOfAccounts>{ wa_lines-offsettingchartofaccounts }</OffsettingChartOfAccounts>| &&

                         |<PersonnelNumber>{ wa_lines-personnelnumber }</PersonnelNumber>| &&

                         |<NetDueDate>{ wa_lines-netduedate }</NetDueDate>| &&
                         |</tableDataRows>|.

        CLEAR : wa_lines.
        CONCATENATE: lv_xml lv_xml1 INTO lv_xml.

      ENDLOOP.

      DATA(lv_xml2) = |</Table>| &&
                      |</AccountingRow>| &&
                      |</Form>|.
      CONCATENATE: lv_xml lv_xml2 INTO lv_xml.


      REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH '&amp;' .
      "Please don't delete this line
      REPLACE ALL OCCURRENCES OF ` ` IN lv_xml WITH `_` .
      CONDENSE lv_xml.

*      result12 = lv_xml.

      CALL METHOD zcl_ads_master=>getpdf(
        EXPORTING
          xmldata  = lv_xml
          template = lc_template_name
        RECEIVING
          result   = result12 ).
    ELSE.
      result12   = 'No record found.'.
    ENDIF.


  ENDMETHOD .
ENDCLASS.
