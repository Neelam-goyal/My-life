CLASS zcl_credit_note DEFINITION
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
                  lc_template_name TYPE string ##NEEDED
        RETURNING VALUE(result12) TYPE string ##NEEDED
        RAISING   cx_static_check .
PROTECTED SECTION.
  PRIVATE SECTION.
*      CONSTANTS lc_template_name TYPE string VALUE 'Z_DEBITNOTE_TEST/Z_DEBITNOTE_TEST'.
*      CONSTANTS lc_template_name TYPE string VALUE ''.
ENDCLASS.



CLASS ZCL_CREDIT_NOTE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.


 METHOD read_posts.

 DATA lv_template_name TYPE string.

   SELECT SINGLE FROM I_SupplierInvoiceAPI01 AS a
      LEFT JOIN i_CompanyCode AS b ON a~CompanyCode = b~CompanyCode
      LEFT JOIN ztable_plant AS c ON a~companycode = c~comp_code
      LEFT JOIN i_supplier AS d ON a~InvoicingParty = d~Supplier
      LEFT JOIN I_SuplrInvcItemPurOrdRefAPI01 AS f ON a~SupplierInvoice = f~SupplierInvoice AND
                                                        a~ReverseDocument IS INITIAL AND f~issubsequentdebitcredit IS INITIAL
      LEFT JOIN ztable_plant AS h ON f~Plant = h~plant_code
      LEFT JOIN I_Businesspartnertaxnumber AS g ON d~Supplier = g~BusinessPartner
      LEFT JOIN I_RegionText AS e ON d~Region = e~Region AND d~Country = e~Country AND e~Language = CAST( 'EN' AS LANG )
      FIELDS a~CompanyCode , a~SupplierPostingLineItemText  , b~CompanyCodeName , h~gstin_no , d~SupplierName , d~Region, d~StreetName,d~CityName,d~PostalCode,
                d~Country,d~TaxNumber3 AS SuppGST,
                f~supplierinvoice,
             a~DocumentDate , a~PostingDate , g~BPTaxNumber,
             e~RegionName,
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
         plant_tel TYPE string.

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

   SELECT FROM i_supplierinvoiceapi01 AS b
   LEFT JOIN I_SuplrInvcItemPurOrdRefAPI01 AS a ON a~SupplierInvoice = b~SupplierInvoice AND a~FiscalYear = b~FiscalYear
   LEFT JOIN I_ProductDescription AS c ON a~PurchaseOrderItemMaterial = c~Product
   LEFT JOIN I_ProductPlantBasic AS d ON a~PurchaseOrderItemMaterial = d~Product AND a~Plant = d~Plant
   LEFT JOIN ztaxcode AS f ON f~taxcode = a~TaxCode

    FIELDS c~ProductDescription AS Des_Goods,
           d~ConsumptionTaxCtrlCode AS hsn,
           a~PurchaseOrderQuantityUnit AS uqc,
           a~QuantityInPurchaseOrderUnit AS Quantity,
           a~SupplierInvoiceItemAmount AS total,
           a~SupplierInvoice ,a~SupplierInvoiceItem, a~FiscalYear, a~ReferenceDocument, a~SupplierInvoiceItemAmount, a~TaxCode,
           f~rate, f~description, f~transactiontypedetermination

    WHERE a~SupplierInvoice = @supplierinvoice
      AND a~FiscalYear = @fiscalyear
      AND b~CompanyCode = @Companycode
    INTO TABLE @DATA(it_items) PRIVILEGED ACCESS.

**************************

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
      INTO TABLE @DATA(it_items1).

      LOOP AT it_items1 INTO DATA(lv_item1).





************************************************************** NEW CODE ***********************************************************

   SELECT SINGLE
      a~companycode,
      b~plant_name1,
      b~address1,
      b~address2,
      b~city,
      b~district,
      b~state_code1,
      b~state_name,
      b~pin,
      b~country,
      b~cin_no,
      b~gstin_no,
      b~pan_no,
      b~fssai_no
     FROM c_supplierinvoiceitemdex WITH PRIVILEGED ACCESS AS a
     LEFT JOIN ztable_plant AS b ON a~plant = b~plant_code
     WHERE a~FiscalYear = @fiscalyear
     AND  a~SupplierInvoice = @supplierinvoice
     AND a~CompanyCode = @Companycode
     INTO  @DATA(waiopcds).

   DATA : Corp_off TYPE string.
   CONCATENATE waiopcds-address1 waiopcds-address2
   waiopcds-district ',' waiopcds-city ',' waiopcds-state_name ',' waiopcds-Country '-' waiopcds-pin
   INTO Corp_off SEPARATED BY space.






**********************************************************************************************************************************




   DATA(lv_xml) = |<Form>| &&
                  |<Header>| &&
                  |<companycode>{ header-CompanyCode }</companycode>| &&
                  |<LOGOcompanycode>{ header-CompanyCode }</LOGOcompanycode>| &&
                  |<plant_add>{ plant_add }</plant_add>| &&
                  |<MAIN_PLANTADRESS>{ Corp_off }</MAIN_PLANTADRESS>| &&
                  |<plant_tel>{ header-phone }</plant_tel>| &&
                  |<plant_name>{ header-plant_name1 }</plant_name>| &&
                  |<plant_GST>{ waiopcds-gstin_no }</plant_GST>| &&
                  |<plant_STATENAME>{ waiopcds-state_name }</plant_STATENAME>| &&
                  |<plant_STATECODE>{ waiopcds-state_code1 }</plant_STATECODE>| &&
                  |<GSTIN>{ header-gstin_no }</GSTIN>| &&
                  |<SupplierDetail>{ header-SupplierName }</SupplierDetail>| &&
                  |<SupplierGST>{ header-SuppGST }</SupplierGST>| &&
                  |<SupplierStateCode>{ header-RegionName }</SupplierStateCode>| &&
                  |<Address1>{ add1s }</Address1>| &&
                  |<Address2>{ add2s }</Address2>| &&
                  |<DocNumeber>{ header-SupplierInvoice }</DocNumeber>| &&
                  |<DocDate>{ header-PostingDate }</DocDate>| &&
                  |<SuppState>{ header-Region }</SuppState>| &&
                  |<StateCode>{ StateCode }</StateCode>| &&
                  |<PartyInvNumber>{ it_header-SupplierInvoiceIDByInvcgParty }</PartyInvNumber>| &&
                  |<PartyInvDate>{ it_header-DocumentDate }</PartyInvDate>| &&
                  |<Remark>{ header-SupplierPostingLineItemText }</Remark>| &&
                  |</Header>| &&
                  |<Items>|.

   DATA: rateunit       TYPE p LENGTH 16 DECIMALS 2,
         igst           TYPE p LENGTH 16 DECIMALS 2,
         Cond_Type      TYPE string,
         Cond_Rate      TYPE p LENGTH 16 DECIMALS 2,
         Cond_Amt       TYPE p LENGTH 16 DECIMALS 2,
         sgst           TYPE p LENGTH 16 DECIMALS 2,
         cgst           TYPE p LENGTH 16 DECIMALS 2,
         gst            TYPE p LENGTH 16 DECIMALS 2,
         igst_amt       TYPE p LENGTH 16 DECIMALS 2,
         sgst_amt       TYPE p LENGTH 16 DECIMALS 2,
         cgst_amt       TYPE p LENGTH 16 DECIMALS 2,
         taxable_amount TYPE p LENGTH 16 DECIMALS 2,
         netamount      TYPE p LENGTH 16 DECIMALS 2,
         total_igst     TYPE p LENGTH 16 DECIMALS 2,
         total_sgst     TYPE p LENGTH 16 DECIMALS 2,
         total_cgst     TYPE p LENGTH 16 DECIMALS 2,
         gst_amt        TYPE p LENGTH 16 DECIMALS 2,
         lv_tax_amount  TYPE TABLE OF I_OperationalAcctgDocTaxItem WITH EMPTY KEY.

   LOOP AT it_items INTO DATA(lv_item).
     CLEAR: igst, sgst, cgst, gst , taxable_amount,lv_tax_amount,igst_amt,sgst_amt,cgst_amt,gst_amt..

     netamount += lv_item-total.

     rateunit = lv_item-total / lv_item-quantity.

     taxable_amount     = ( lv_item-total * lv_item-rate ) / 100 .

     IF lv_item-transactiontypedetermination = 'JII'.
       igst_amt     = taxable_amount .
       total_igst += igst_amt.
       igst = lv_item-rate.
       gst = igst.
       gst_amt = igst_amt.
       Cond_Rate = lv_item-rate.
       Cond_Amt = taxable_amount.

     ELSEIF lv_item-transactiontypedetermination = 'JIC' OR lv_item-transactiontypedetermination = 'JIS'.
       sgst_amt     = taxable_amount / 2.
       cgst_amt     = taxable_amount / 2.
       total_sgst += sgst_amt.
       total_cgst += cgst_amt.
       cgst = lv_item-rate / 2.
       sgst = lv_item-rate / 2.
       gst = sgst + cgst.
       gst_amt = sgst_amt + cgst_amt.
       Cond_Rate = lv_item-rate / 2.
       Cond_Amt = taxable_amount / 2.
     ENDIF.


*****************************New Logic***********************
     Cond_Type = lv_item-transactiontypedetermination.
************************************************************
     " Build XML for the current item
     DATA(lv_itemXML) = |<Item>| &&
                        |<Descgoods>{ lv_item-des_goods }</Descgoods>| &&
                        |<Cond_Type>{ Cond_Type }</Cond_Type>| &&
                        |<Cond_Rate>{ Cond_Rate }</Cond_Rate>| &&
                        |<Cond_Amt>{ Cond_Amt }</Cond_Amt>| &&
*                     |<Remarks>{ lv_item-DocumentItemText }</Remarks>| &&
                        |<HSN>{ lv_item-hsn }</HSN>| &&
                        |<UQC>{ lv_item-uqc }</UQC>| &&
                        |<Quantity>{ lv_item-quantity }</Quantity>| &&
                        |<RateUnit>{ rateunit }</RateUnit>| &&
                        |<Total>{ lv_item-total }</Total>| &&
                     |<Taxable>{ lv_item1-taxable }</Taxable>| &&
                        |<Sgst>{ sgst }</Sgst>| &&
                        |<Cgst>{ cgst }</Cgst>| &&
                        |<Igst>{ igst }</Igst>| &&
                        |<Gst>{ gst }</Gst>| &&
                        |<Gst_amt>{ gst_amt }</Gst_amt>| &&
                        |<Sgst_amt>{ sgst_amt }</Sgst_amt>| &&
                        |<Cgst_amt>{ cgst_amt }</Cgst_amt>| &&
                        |<Igst_amt>{ igst_amt }</Igst_amt>| &&
                        |</Item>|.

     CONCATENATE lv_xml lv_itemXML INTO lv_xml.
     CLEAR: igst, sgst, cgst, gst , taxable_amount,lv_tax_amount,igst_amt,sgst_amt,cgst_amt,gst_amt,
     Cond_Rate,Cond_Type,Cond_Amt,lv_item.

   ENDLOOP.
   ENDLOOP.
   DATA(lv_finalTotal) = |<FinalTotal>{ netamount + total_cgst + total_sgst + total_igst }</FinalTotal>|.
   CONCATENATE lv_xml lv_finalTotal INTO lv_xml.
   CLEAR: netamount,total_cgst, total_sgst,total_igst.

   CONCATENATE lv_xml '</Items>' '</Form>' INTO lv_xml.

   CALL METHOD zcl_ads_master=>getpdf(
     EXPORTING
       xmldata  = lv_xml
       template = lc_template_name
     RECEIVING
       result   = result12 ).

 ENDMETHOD.
ENDCLASS.
