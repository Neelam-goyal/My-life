CLASS zcl_debite_taxable DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    CLASS-METHODS :
      read_posts
        IMPORTING supplierinvoice TYPE string ##NEEDED
                  Companycode     TYPE string ##NEEDED
                  fiscalyear      TYPE string ##NEEDED
        RETURNING VALUE(result12) TYPE string ##NEEDED
        RAISING   cx_static_check .
PROTECTED SECTION.
  PRIVATE SECTION.
      CONSTANTS lc_template_name TYPE string VALUE 'zdebiteTaxable/zdebiteTaxable'.
ENDCLASS.



CLASS ZCL_DEBITE_TAXABLE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.


 METHOD read_posts.

    SELECT SINGLE FROM I_SupplierInvoiceAPI01 AS a
       LEFT JOIN i_CompanyCode AS b ON a~CompanyCode = b~CompanyCode
       LEFT JOIN ztable_plant AS c ON a~companycode = c~comp_code
       LEFT JOIN i_supplier AS d ON a~InvoicingParty = d~Supplier
       LEFT JOIN I_SuplrInvcItemPurOrdRefAPI01 AS f ON a~SupplierInvoice = f~SupplierInvoice AND
                                                         a~ReverseDocument IS INITIAL AND f~issubsequentdebitcredit IS INITIAL
       LEFT JOIN ztable_plant as h on f~Plant = h~plant_code
       LEFT JOIN I_Businesspartnertaxnumber AS g ON d~Supplier = g~BusinessPartner
       FIELDS a~CompanyCode , a~SupplierPostingLineItemText , b~CompanyCodeName , h~gstin_no , d~SupplierName , d~Region, d~StreetName,d~CityName,d~PostalCode,
                 d~Country,d~TaxNumber3 as SuppGST,
                 f~supplierinvoice,
              a~DocumentDate , g~BPTaxNumber,
              h~address1,h~address2,h~address3,h~phone,h~plant_name1
       WHERE a~SupplierInvoice =  @supplierinvoice
           AND a~FiscalYear = @fiscalyear
           AND a~CompanyCode = @Companycode
       INTO @DATA(header).


   DATA: add1S TYPE string,
         add2S TYPE string.
   IF  header-StreetName IS NOT INITIAL.
     add1S = |{ header-StreetName }|.
   ENDIF.
   IF header-CityName IS NOT INITIAL.
     add2S = |{ header-CityName }|.
   ENDIF.
   IF header-PostalCode IS NOT INITIAL.
     add2S = |{ header-CityName }-{ header-PostalCode }|.
   ENDIF.
   IF header-Country IS NOT INITIAL.
     add2S = |{ header-CityName }-{ header-PostalCode },{ header-Country }.|.
   ENDIF.

      DATA: plant_add TYPE string,
            plant_tel  TYPE string.

    IF header-address1 IS NOT INITIAL.
      plant_add = header-address1.
    ENDIF.

    IF header-address2 IS NOT INITIAL.
      IF plant_add IS INITIAL.
        plant_add = header-address2.
      ELSE.
        plant_add = plant_add && ', ' && header-address2.
      ENDIF.
    ENDIF.

    IF header-address3 IS NOT INITIAL.
      IF plant_add IS INITIAL.
        plant_add = header-address3.
      ELSE.
        plant_add = plant_add && ', ' && header-address3.
      ENDIF.
    ENDIF.

   plant_tel = header-phone.

    DATA(SuppStateCode) = header-SuppGST(2).
   DATA(StateCode) = header-BPTaxNumber(2).
   DATA(ReferenceDocument) = |{ supplierinvoice }{ fiscalyear }|.

   SELECT SINGLE FROM i_supplierinvoiceapi01
   FIELDS SupplierInvoiceIDByInvcgParty, documentdate
    WHERE SupplierInvoiceWthnFiscalYear = @ReferenceDocument
    INTO  @DATA(it_header).

   select from i_supplierinvoiceapi01 AS b
     inner JOIN I_SuplrInvcItemPurOrdRefAPI01 AS a ON a~SupplierInvoice = b~SupplierInvoice and a~FiscalYear = b~FiscalYear
      inner JOIN I_ProductDescription AS c ON a~PurchaseOrderItemMaterial = c~Product
      inner JOIN I_ProductPlantBasic AS d ON a~PurchaseOrderItemMaterial = d~Product and a~Plant = d~Plant
      inner JOIN I_OperationalAcctgDocItem AS e ON  e~OriginalReferenceDocument = @ReferenceDocument
*      inner join I_OperationalAcctgDocTaxItem AS f ON e~AccountingDocument = f~AccountingDocument
      FIELDS c~ProductDescription AS Des_Goods,
             d~ConsumptionTaxCtrlCode AS hsn,
             a~PurchaseOrderQuantityUnit AS uqc,
             a~QuantityInPurchaseOrderUnit AS Quantity,
             a~SupplierInvoiceItemAmount AS total,
             e~AbsoluteAmountInCoCodeCrcy AS Taxable,
             e~AccountingDocument,
             e~TransactionTypeDetermination,
             e~DocumentItemText
*             f~TaxBaseAmountInCoCodeCrcy AS TaxBaseAmountInCoCodeCrcy,
*             f~TaxAmountInCoCodeCrcy AS TaxAmountInCoCodeCrcy
      WHERE a~SupplierInvoice = @supplierinvoice
        AND a~FiscalYear = @fiscalyear
        AND b~CompanyCode = @Companycode
        AND e~AccountingDocumentItemType = 'W'
      INTO TABLE @DATA(it_items).

   DATA(lv_xml) = |<Form>| &&
                  |<Header>| &&
                  |<companycode>{ header-CompanyCode }</companycode>| &&
                  |<plant_add>{ plant_add }</plant_add>| &&
                  |<plant_name>{ header-plant_name1 }</plant_name>| &&
                  |<plant_tel>{ header-phone }</plant_tel>| &&
                  |<GSTIN>{ header-gstin_no }</GSTIN>| &&
                  |<SupplierDetail>{ header-SupplierName }</SupplierDetail>| &&
                  |<SupplierGST>{ header-SuppGST }</SupplierGST>| &&
                  |<SupplierStateCode>{ suppstatecode }</SupplierStateCode>| &&
                  |<Address1>{ add1s }</Address1>| &&
                  |<Address2>{ add2s }</Address2>| &&
                  |<DocNumeber>{ header-SupplierInvoice }</DocNumeber>| &&
                  |<DocDate>{ header-DocumentDate }</DocDate>| &&
                  |<SuppState>{ header-Region }</SuppState>| &&
                  |<StateCode>{ StateCode }</StateCode>| &&
                  |<PartyInvNumber>{ it_header-SupplierInvoiceIDByInvcgParty }</PartyInvNumber>| &&
                  |<PartyInvDate>{ it_header-DocumentDate }</PartyInvDate>| &&
                  |<Remark>{ header-SupplierPostingLineItemText }</Remark>| &&
                  |</Header>| &&
                  |<Items>|.

DATA: rateunit TYPE p LENGTH 16 DECIMALS 2,
      IGST TYPE p LENGTH 16 DECIMALS 2,
      SGST TYPE p LENGTH 16 DECIMALS 2,
      CGST TYPE p LENGTH 16 DECIMALS 2,
      IGST_AMT TYPE p LENGTH 16 DECIMALS 2,
      SGST_AMT TYPE p LENGTH 16 DECIMALS 2,
      CGST_AMT TYPE p LENGTH 16 DECIMALS 2,
      lv_tax_amount TYPE TABLE OF I_OperationalAcctgDocTaxItem WITH EMPTY KEY.

LOOP AT it_items INTO DATA(lv_item).
  CLEAR: IGST, SGST, CGST, lv_tax_amount,IGST_AMT,SGST_AMT,CGST_AMT.

  rateunit = lv_item-total / lv_item-quantity.


  SELECT SINGLE TaxBaseAmountInCoCodeCrcy, TaxAmountInCoCodeCrcy
    FROM I_OperationalAcctgDocTaxItem
    WHERE AccountingDocument = @lv_item-AccountingDocument  AND FiscalYear = @fiscalyear
        AND CompanyCode = @Companycode
      AND TransactionTypeDetermination = 'JII'
    INTO @DATA(lv_tax_jii).

  IF lv_tax_jii IS NOT INITIAL AND lv_tax_jii-TaxAmountInCoCodeCrcy <> 0.
    IGST = ( lv_tax_jii-TaxAmountInCoCodeCrcy / lv_tax_jii-TaxBaseAmountInCoCodeCrcy ) * 100.
    IGST_AMT = lv_tax_jii-TaxAmountInCoCodeCrcy * ( -1 ) .
  ELSE.

    SELECT SINGLE TaxBaseAmountInCoCodeCrcy, TaxAmountInCoCodeCrcy
      FROM I_OperationalAcctgDocTaxItem
      WHERE AccountingDocument = @lv_item-AccountingDocument
      AND FiscalYear = @fiscalyear
        AND CompanyCode = @Companycode
        AND TransactionTypeDetermination = 'JIC'
      INTO @DATA(lv_tax_jic).

    IF lv_tax_jic IS NOT INITIAL AND lv_tax_jic-TaxAmountInCoCodeCrcy <> 0.
      SGST = ( lv_tax_jic-TaxAmountInCoCodeCrcy / lv_tax_jic-TaxBaseAmountInCoCodeCrcy ) * 100.
      CGST =  ( lv_tax_jic-TaxAmountInCoCodeCrcy / lv_tax_jic-TaxBaseAmountInCoCodeCrcy  ) * 100.
      CGST_AMT = lv_tax_jic-TaxAmountInCoCodeCrcy * ( -1 ).
      SGST_AMT = lv_tax_jic-TaxAmountInCoCodeCrcy * ( -1 ).
    ENDIF.
  ENDIF.

  " Build XML for the current item
  DATA(lv_itemXML) = |<Item>| &&
                     |<Descgoods>{ lv_item-des_goods }</Descgoods>| &&
                     |<Remarks>{ lv_item-DocumentItemText }</Remarks>| &&
                     |<HSN>{ lv_item-hsn }</HSN>| &&
                     |<UQC>{ lv_item-uqc }</UQC>| &&
                     |<Quantity>{ lv_item-quantity }</Quantity>| &&
                     |<RateUnit>{ rateunit }</RateUnit>| &&
                     |<Total>{ lv_item-total }</Total>| &&
                     |<Taxable>{ lv_item-taxable }</Taxable>| &&
                     |<Sgst>{ SGST }</Sgst>| &&
                     |<Cgst>{ CGST }</Cgst>| &&
                     |<Igst>{ IGST }</Igst>| &&

                     |<Sgst_amt>{ SGST_AMT }</Sgst_amt>| &&
                     |<Cgst_amt>{ CGST_AMT }</Cgst_amt>| &&
                     |<Igst_amt>{ IGST_AMT }</Igst_amt>| &&
                     |<FinalTotal>{ lv_item-total + IGST + SGST + CGST }</FinalTotal>| &&
                     |</Item>|.

  CONCATENATE lv_xml lv_itemXML INTO lv_xml.
ENDLOOP.

CONCATENATE lv_xml '</Items>' '</Form>' INTO lv_xml.

   CALL METHOD zcl_ads_master=>getpdf(
     EXPORTING
       xmldata  = lv_xml
       template = lc_template_name
     RECEIVING
       result   = result12 ).

 ENDMETHOD.
ENDCLASS.
