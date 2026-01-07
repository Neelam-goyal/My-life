CLASS zcl_purchasejob_lines DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .
    METHODS Purchaseregister.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PURCHASEJOB_LINES IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'My ID'                                      changeable_ind = abap_true )
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'My Description'   lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     datatype = 'I' length = 10 param_text = 'My Count'                                   changeable_ind = abap_true )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length =  1 param_text = 'Full Processing' checkbox_ind = abap_true  changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '4711' )
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'My Default Description' )
      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = '200' )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = abap_false )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    TYPES ty_id TYPE c LENGTH 10.

    DATA s_id    TYPE RANGE OF ty_id.
    DATA p_descr TYPE c LENGTH 80.
    DATA p_count TYPE i.
    DATA p_simul TYPE abap_boolean.
    DATA processfrom TYPE d.

    DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
    DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
    DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA: template  TYPE cl_apj_rt_api=>ty_template_name.

    DATA: lt_purchinvlines     TYPE STANDARD TABLE OF zpurchinvlines,
          wa_purchinvlines     TYPE zpurchinvlines,
          lt_purchinvprocessed TYPE STANDARD TABLE OF zpurchinvproc,
          wa_purchinvprocessed TYPE zpurchinvproc.


****************************************************************************************
    DATA maxpostingdate TYPE d.
    DATA deleteString TYPE c LENGTH 4.
    DATA: lv_tstamp TYPE timestamp, lv_date TYPE d, lv_time TYPE t, lv_dst TYPE abap_bool.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    GET TIME STAMP FIELD lv_tstamp.
    CONVERT TIME STAMP lv_tstamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time DAYLIGHT SAVING TIME lv_dst.

    deleteString = |{ lv_date+6(2) }| && |{ lv_time+0(2) }|.


*    IF deleteString = '2217'.
    IF deleteString = p_descr+7(4).
      DELETE FROM zpurchinvlines WHERE supplierinvoice IS NOT INITIAL.
      DELETE FROM zpurchinvproc WHERE supplierinvoice IS NOT INITIAL.
      COMMIT WORK.
    ENDIF.

    SELECT FROM zpurchinvlines
      FIELDS MAX( postingdate )
      WHERE supplierinvoice IS NOT INITIAL
      INTO @maxpostingdate .
    IF maxpostingdate IS INITIAL.
      maxpostingdate = 20010101.
    ELSE.
      maxpostingdate = maxpostingdate - 30.
    ENDIF.
****************************************************************************************


    " Getting the actual parameter values
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'S_ID'.
          APPEND VALUE #( sign   = ls_parameter-sign
                          option = ls_parameter-option
                          low    = ls_parameter-low
                          high   = ls_parameter-high ) TO s_id.
        WHEN 'P_DESCR'. p_descr = ls_parameter-low.
        WHEN 'P_COUNT'. p_count = ls_parameter-low.
        WHEN 'P_SIMUL'. p_simul = ls_parameter-low.
      ENDCASE.
    ENDLOOP.
    IF deleteString = p_descr+7(4).
      DELETE FROM zpurchinvlines WHERE supplierinvoice IS NOT INITIAL.
      DELETE FROM zpurchinvproc WHERE supplierinvoice IS NOT INITIAL.
      COMMIT WORK.
    ENDIF.
    TRY.
*      read own runtime info catalog
        cl_apj_rt_api=>get_job_runtime_info(
                         IMPORTING
                           ev_jobname        = jobname
                           ev_jobcount       = jobcount
                           ev_catalog_name   = catalog
                           ev_template_name  = template ).

      CATCH cx_apj_rt.
        CLEAR p_count.
    ENDTRY.
    Purchaseregister( ).


  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    Purchaseregister( ).
  ENDMETHOD.


  METHOD Purchaseregister.
    DATA processfrom TYPE d.
    DATA p_simul TYPE abap_boolean.
    DATA p_descr TYPE c LENGTH 80.
    DATA assignmentreference TYPE string.

    DATA deleteString TYPE c LENGTH 4.
    DATA: lv_tstamp TYPE timestamp, lv_date TYPE d, lv_time TYPE t, lv_dst TYPE abap_bool.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    GET TIME STAMP FIELD lv_tstamp.
    CONVERT TIME STAMP lv_tstamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time DAYLIGHT SAVING TIME lv_dst.

    deleteString = |{ lv_date+6(2) }| && |{ lv_time+0(2) }|.

*    IF deleteString = '1913'.
    IF deleteString = p_descr+7(4).
      DELETE FROM zpurchinvlines WHERE supplierinvoice IS NOT INITIAL.
      DELETE FROM zpurchinvproc WHERE supplierinvoice IS NOT INITIAL.
      COMMIT WORK.
    ENDIF.

    DATA: lt_purchinvlines     TYPE STANDARD TABLE OF zpurchinvlines,
          wa_purchinvlines     TYPE zpurchinvlines,
          lt_purchinvprocessed TYPE STANDARD TABLE OF zpurchinvproc,
          wa_purchinvprocessed TYPE zpurchinvproc.

    p_simul = abap_true.
    processfrom = sy-datum - 30.
    IF p_simul = abap_true.
      processfrom = sy-datum - 2000.
    ENDIF.


***************************************************** HEADER *****************************************
    SELECT FROM I_SupplierInvoiceAPI01 AS c
    LEFT JOIN i_supplier AS b ON b~supplier = c~InvoicingParty
    LEFT JOIN C_SupplierInvoiceDEX AS SDex ON SDex~SupplierInvoice = c~SupplierInvoice
    LEFT JOIN I_BusPartAddress AS hdr1 ON c~BusinessPlace = hdr1~BusinessPartner
    FIELDS
    c~ReverseDocument , c~ReverseDocumentFiscalYear, c~BusinessPlace,
    c~CompanyCode , c~PaymentTerms , c~CreatedByUser , c~CreationDate , c~InvoicingParty , c~InvoiceGrossAmount,
    c~DocumentCurrency , c~SupplierInvoiceIDByInvcgParty, c~FiscalYear, c~SupplierInvoice, c~SupplierInvoiceWthnFiscalYear,
    c~DocumentDate, c~PostingDate, c~IsInvoice ,
    b~region, b~Suppliername, b~Supplier , b~PostalCode , b~BPAddrCityName , b~BPAddrStreetName , b~TaxNumber3, b~TaxNumber3 AS Supp_Gst,
    SDex~ReverseDocument AS revDoc, hdr1~AddressID
    WHERE c~PostingDate >= @processfrom
    AND NOT EXISTS ( SELECT supplierinvoice FROM zpurchinvproc
    WHERE c~supplierinvoice = zpurchinvproc~supplierinvoice
    AND c~CompanyCode = zpurchinvproc~companycode
    AND c~FiscalYear = zpurchinvproc~fiscalyearvalue )
    INTO TABLE @DATA(ltheader) PRIVILEGED ACCESS.

    SELECT FROM I_JournalEntry
    FIELDS OriginalReferenceDocument, IsReversal, IsReversed
    WHERE OriginalReferenceDocument IS NOT INITIAL
    INTO TABLE @DATA(it_journalentry) PRIVILEGED ACCESS.

    SELECT FROM  i_purchaseorderhistoryapi01 AS a
    FIELDS a~PurchasingHistoryDocument , a~PurchasingHistoryCategory, a~DebitCreditCode,
    a~ReferenceDocument, a~PurchaseOrder
    WHERE a~PurchasingHistoryCategory IN ( 'N' , 'Q' )
    INTO TABLE @DATA(it_transtype) PRIVILEGED ACCESS.

    SELECT FROM I_UnitOfMeasureText
    FIELDS UnitOfMeasure , UnitOfMeasureTechnicalName
    WHERE Language = 'E'
    INTO TABLE @DATA(it_uom) PRIVILEGED ACCESS.

    SELECT FROM I_TaxCodeRate
    FIELDS TaxCode, Country, ConditionRateRatio, AccountKeyForGLAccount, vatconditiontype
    WHERE AccountKeyForGLAccount IN ( 'JII', 'JIS', 'NVV' ) AND Country = 'IN'
    AND CndnRecordValidityEndDate = '99991231' AND TaxCode IN ( 'I0',  'I1' , 'I2',  'I3',  'I4', 'I5' , 'I6' , 'I7', 'I8' ,'I9' , 'F5', 'H3' , 'H4' , 'H5', 'H6' , 'J3' , 'G6' , 'G7' ,
    'MA' ,'MB' , 'MC' , 'MD' , 'N0' , 'N1' , 'N2' , 'N3' , 'N4' , 'N5' , 'N6' , 'N7', 'N8', 'N9' )
    INTO TABLE @DATA(it_taxrates) PRIVILEGED ACCESS.

    SELECT FROM I_TaxCodeText FIELDS TaxCode, TaxCodeName
    WHERE Language = 'E'
    INTO TABLE @DATA(it_taxcodename) PRIVILEGED ACCESS.

    SELECT FROM ztable_plant
    FIELDS comp_code, plant_code, gstin_no, plant_name1, plant_name2, profitcenter,
    city, address1, address2, address3, pin, district
    WHERE plant_code IS NOT INITIAL
    INTO TABLE @DATA(it_zplant) PRIVILEGED ACCESS.

    SELECT FROM I_ProductText FIELDS Product , ProductName
    WHERE Language = 'E' AND ProductName IS NOT INITIAL
    INTO TABLE @DATA(it_productdesc) PRIVILEGED ACCESS.

********************************************************* LINE ITEM ***************************************
    LOOP AT ltheader INTO DATA(waheader).
*      lv_timestamp = cl_abap_tstmp=>add_to_short( tstmp = lv_timestamp secs = 11111 ).
      GET TIME STAMP FIELD lv_timestamp.

* Delete already processed sales line
      DELETE FROM zpurchinvlines
      WHERE zpurchinvlines~companycode = @waheader-CompanyCode AND
      zpurchinvlines~fiscalyearvalue = @waheader-FiscalYear AND
      zpurchinvlines~supplierinvoice = @waheader-SupplierInvoice.


      SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
      LEFT JOIN I_PurchaseOrderItemAPI01 AS b ON a~PurchaseOrder = b~PurchaseOrder AND a~PurchaseOrderItem = b~PurchaseOrderItem
      LEFT JOIN i_purchaseorderapi01 AS c ON b~PurchaseOrder = c~PurchaseOrder
      LEFT JOIN I_Supplier AS li13 ON c~Supplier = li13~Supplier
      LEFT JOIN I_MaterialDocumentHeader_2 AS li14 ON a~ReferenceDocument = li14~MaterialDocument AND a~ReferenceDocumentFiscalYear = li14~MaterialDocumentYear
      LEFT JOIN I_BusinessPartner AS li7 ON c~Supplier = li7~BusinessPartner
      LEFT JOIN I_BusinessPartnerLegalFormText AS li8 ON li7~LegalForm = li8~LegalForm AND li8~Language = 'E'
      LEFT JOIN i_purchaseorderitemtp_2 AS li9 ON b~PurchaseOrder = li9~PurchaseOrder AND b~PurchaseOrderItem = li9~PurchaseOrderItem
      LEFT JOIN I_Requestforquotation_Api01 AS li10 ON li9~SupplierQuotation = li10~RequestForQuotation
      LEFT JOIN I_SupplierQuotation_Api01 AS li11 ON li9~SupplierQuotation = li11~SupplierQuotation
      FIELDS  a~PurchaseOrderItem, a~SupplierInvoiceItem,
      a~PurchaseOrder, a~SupplierInvoiceItemAmount AS tax_amt, a~SupplierInvoiceItemAmount, a~taxcode, a~ReferenceDocumentFiscalYear,
      a~FreightSupplier , a~SupplierInvoice , a~FiscalYear , a~TaxJurisdiction, a~plant, a~DebitCreditCode, a~IsSubsequentDebitCredit,
      a~PurchaseOrderItemMaterial AS material, a~QuantityInPurchaseOrderUnit, a~QtyInPurchaseOrderPriceUnit,
      a~PurchaseOrderQuantityUnit, PurchaseOrderPriceUnit, a~ReferenceDocument,
      b~NetPriceAmount, b~PurchaseOrderItemText,
      c~Supplier,
      li8~LegalFormDescription, li9~SupplierQuotation, li10~RFQPublishingDate, li11~SupplierQuotation AS sq,
      li11~QuotationSubmissionDate,
      li13~SupplierName, li14~PostingDate AS MRNPostingDate
      WHERE a~SupplierInvoice = @waheader-SupplierInvoice
      AND a~FiscalYear = @waheader-FiscalYear
      AND a~SuplrInvcDeliveryCostCndnType = ''
      ORDER BY a~PurchaseOrderItem, a~SupplierInvoiceItem
      INTO TABLE @DATA(ltlines).


      IF ltlines IS NOT INITIAL.
        SELECT FROM I_Producttext AS a FIELDS a~ProductName, a~Product
        FOR ALL ENTRIES IN @ltlines
        WHERE a~Product = @ltlines-material AND a~Language = 'E'
        INTO TABLE @DATA(it_product).

        SELECT FROM I_PurchaseOrderItemAPI01 AS a
        LEFT JOIN I_PurchaseOrderAPI01 AS b ON a~PurchaseOrdeR = b~PurchaseOrder
        FIELDS a~BaseUnit , b~PurchaseOrderType , b~PurchasingGroup , b~PurchasingOrganization ,
        b~PurchaseOrderDate , a~PurchaseOrder , a~PurchaseOrderItem , a~ProfitCenter
        FOR ALL ENTRIES IN @ltlines
        WHERE a~PurchaseOrder = @ltlines-PurchaseOrder AND a~PurchaseOrderItem = @ltlines-PurchaseOrderItem
        INTO TABLE @DATA(it_po).

        SELECT FROM I_MaterialDocumentItem_2
        FIELDS MaterialDocument , PurchaseOrder , PurchaseOrderItem , QuantityInBaseUnit , PostingDate
        FOR ALL ENTRIES IN @ltlines
        WHERE MaterialDocument  = @ltlines-ReferenceDocument
        INTO TABLE @DATA(it_grn).

        SELECT FROM I_taxcodetext
        FIELDS TaxCode , TaxCodeName
        FOR ALL ENTRIES IN @ltlines
        WHERE Language = 'E' AND taxcode = @ltlines-TaxCode
        INTO TABLE @DATA(it_tax).


        SELECT FROM  i_purorditmpricingelementapi01 AS a LEFT JOIN I_PurchaseOrderAPI01 AS b ON
        a~PricingDocument = b~PricingDocument
        FIELDS a~conditioncurrency , a~ConditionAmount , b~PurchaseOrder
        FOR ALL ENTRIES IN @ltlines
        WHERE b~PurchaseOrder = @ltLines-PurchaseOrder AND a~ConditionType IN ( 'ZDCP' , 'ZDCV' , 'ZCD1' , 'ZDCQ' )
        INTO TABLE @DATA(it_discount1).
      ENDIF.

      DATA lv_deliverycostamount TYPE I_SuplrInvcItemPurOrdRefAPI01-SupplierInvoiceItemAmount.
      DATA lv_signval TYPE i.

      LOOP AT ltlines INTO DATA(walines).
        wa_purchinvlines-client                     = sy-mandt.
        wa_purchinvlines-companycode                = waheader-CompanyCode.
        wa_purchinvlines-fiscalyearvalue            = waheader-FiscalYear.
        wa_purchinvlines-supplierbillno             = waheader-SupplierInvoiceIDByInvcgParty.
        wa_purchinvlines-supplierinvoice            = waheader-SupplierInvoice.
        wa_purchinvlines-supplierinvoiceitem        = walines-SupplierInvoiceItem.
        wa_purchinvlines-postingdate                = waheader-PostingDate.
********************************** Item Level Fields Added ****************************
        wa_purchinvlines-plantcode                  = walines-Plant.
        wa_purchinvlines-plant                      = walines-Plant.
*            wa_purchinvlines-product_trade_name = walines-trade_name.
        wa_purchinvlines-vendor_invoice_date        = waheader-DocumentDate.
        wa_purchinvlines-vendor_type                = walines-LegalFormDescription.
        wa_purchinvlines-rfqno                      = walines-SupplierQuotation.
        wa_purchinvlines-rfqdate                    = walines-RFQPublishingDate.
        wa_purchinvlines-supplierquotation          = walines-sq.
        wa_purchinvlines-supplierquotationdate      = walines-QuotationSubmissionDate.
        wa_purchinvlines-supp_gst                   = waheader-supp_gst.
        wa_purchinvlines-suppliercode               = walines-supplier.
        wa_purchinvlines-suppliercodename           = walines-SupplierName. "| { walines-Supplier } - { walines-SupplierName  } |.
        wa_purchinvlines-purchaseorder              = walines-PurchaseOrder.
        wa_purchinvlines-purchaseorderitem          = walines-PurchaseOrderItem.
        wa_purchinvlines-product                    = walines-material.

        READ TABLE it_zplant INTO DATA(wa_zplant3) WITH KEY plant_code = walines-Plant.
        IF wa_zplant3 IS NOT INITIAL.
          wa_purchinvlines-plantname                = |{ wa_zplant3-plant_name1 } { wa_zplant3-plant_name2 }|.
          wa_purchinvlines-plantgst                 = wa_zplant3-gstin_no.
          wa_purchinvlines-plantadr                 = |{ wa_zplant3-address1 } { wa_zplant3-address2 } { wa_zplant3-address3 }|.
          wa_purchinvlines-plantpin                 = wa_zplant3-pin.
          wa_purchinvlines-plantcity                = wa_zplant3-city.
        ENDIF.

        IF walines-material <> ''.
          READ TABLE it_product INTO DATA(wa_product) WITH KEY product = walines-material.
          wa_purchinvlines-productname                = wa_product-ProductName.
        ELSE.
          wa_purchinvlines-productname                = walines-PurchaseOrderItemText.
        ENDIF.
        CONCATENATE walines-SupplierInvoice walines-FiscalYear INTO wa_purchinvlines-originalreferencedocument.

        READ TABLE it_po INTO DATA(wa_po) WITH KEY PurchaseOrder = walines-PurchaseOrder
                                                PurchaseOrderItem = walines-PurchaseOrderItem.

        READ TABLE it_uom INTO DATA(wa_uom) WITH KEY UnitOfMeasure = wa_po-BaseUnit.
        IF wa_uom IS NOT INITIAL.
          wa_purchinvlines-baseunit                 = to_upper( wa_uom-UnitOfMeasureTechnicalName ).
          CLEAR wa_uom.
        ELSE .
          wa_purchinvlines-baseunit                 = wa_po-BaseUnit.
        ENDIF.
        wa_purchinvlines-profitcenter               = wa_po-ProfitCenter.
        wa_purchinvlines-purchaseordertype          = wa_po-PurchaseOrderType.
        wa_purchinvlines-purchaseorderdate          = wa_po-PurchaseOrderDate.
        wa_purchinvlines-purchasingorganization     = wa_po-PurchasingOrganization.
        wa_purchinvlines-purchasinggroup            = wa_po-PurchasingGroup.
        wa_purchinvlines-basicrate                  = walines-NetPriceAmount.
        wa_purchinvlines-grnno                      = walines-ReferenceDocument.
        wa_purchinvlines-mrnquantityinbaseunit      = walines-QtyInPurchaseOrderPriceUnit.
        wa_purchinvlines-mrnpostingdate             = walines-mrnpostingdate.
        READ TABLE it_tax INTO DATA(wa_tax) WITH KEY     TaxCode = walines-TaxCode.
        wa_purchinvlines-taxcodename                = wa_tax-TaxCodeName.
        IF waHeader-revdoc <> ''.
          wa_purchinvlines-isreversed = 'X'.
        ENDIF.
        CONCATENATE walines-PurchaseOrder walines-PurchaseOrderItem INTO assignmentreference.

        SELECT  TaxItemAcctgDocItemRef, IN_HSNOrSACCode FROM i_operationalacctgdocitem
        WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear AND TaxItemAcctgDocItemRef IS NOT INITIAL
        AND AccountingDocumentItemType <> 'T'
        AND FiscalYear = @walines-FiscalYear
        AND CompanyCode = @waheader-CompanyCode
        AND AccountingDocumentType = 'RE'
        AND AssignmentReference = @assignmentreference
        AND Product = @walines-material
        AND AccountingDocumentItemType IS NOT INITIAL
        INTO  TABLE @DATA(it_taxitems).

        SORT it_taxitems  ASCENDING BY TaxItemAcctgDocItemRef.
        READ TABLE it_taxitems INTO DATA(wa_taxitems) INDEX 1.
        DATA lv_TaxItemAcctgDocItemRef TYPE i_operationalacctgdocitem-TaxItemAcctgDocItemRef.
        DATA lv_HSNCode TYPE i_operationalacctgdocitem-IN_HSNOrSACCode.

        IF wa_taxitems IS NOT INITIAL.
          lv_TaxItemAcctgDocItemRef = wa_taxitems-TaxItemAcctgDocItemRef .
          lv_HSNCode = wa_taxitems-IN_HSNOrSACCode .
        ENDIF.
        wa_purchinvlines-hsncode                    = lv_HSNCode.

        SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
        WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
        AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
        AND AccountingDocumentItemType = 'T'
        AND FiscalYear = @walines-FiscalYear
        AND CompanyCode = @waheader-CompanyCode
        AND TransactionTypeDetermination = 'JII'
        INTO  @wa_purchinvlines-igst.

        IF wa_purchinvlines-igst IS INITIAL.
          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
          WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
          AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
          AND AccountingDocumentItemType = 'T'
          AND FiscalYear = @walines-FiscalYear
          AND CompanyCode = @waheader-CompanyCode
          AND TransactionTypeDetermination = 'JIC'
          INTO  @wa_purchinvlines-cgst.

          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
          WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
          AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
          AND AccountingDocumentItemType = 'T'
          AND FiscalYear = @walines-FiscalYear
          AND CompanyCode = @waheader-CompanyCode
          AND TransactionTypeDetermination = 'JIS'
          INTO  @wa_purchinvlines-sgst.
        ENDIF.

        SELECT  SINGLE AmountInCompanyCodeCurrency  FROM i_operationalacctgdocitem
        WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
        AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
        AND AccountingDocumentItemType = 'T'
        AND FiscalYear = @walines-FiscalYear
        AND CompanyCode = @waheader-CompanyCode
        AND TransactionTypeDetermination = 'JRI'
        INTO  @wa_purchinvlines-rcmigst .

        IF wa_purchinvlines-rcmigst IS INITIAL.
          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
          WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
          AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
          AND AccountingDocumentItemType = 'T'
          AND FiscalYear = @walines-FiscalYear
          AND CompanyCode = @waheader-CompanyCode
          AND TransactionTypeDetermination = 'JRC'
          INTO  @wa_purchinvlines-rcmcgst.

          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
          WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
          AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
          AND AccountingDocumentItemType = 'T'
          AND FiscalYear = @walines-FiscalYear
          AND CompanyCode = @waheader-CompanyCode
          AND TransactionTypeDetermination = 'JRS'
          INTO  @wa_purchinvlines-rcmsgst.

          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
          WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
          AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
          AND AccountingDocumentItemType = 'T'
          AND FiscalYear = @walines-FiscalYear
          AND CompanyCode = @waheader-CompanyCode
          AND TransactionTypeDetermination = 'JIM'
          INTO  @wa_purchinvlines-igst.
        ENDIF.

        lv_signval = 1.

*        //For TransactionType
        READ TABLE it_transtype INTO DATA(wa_transtype) WITH KEY PurchasingHistoryDocument = waheader-SupplierInvoice.

        READ TABLE it_journalentry INTO DATA(wa_journalentry) WITH KEY OriginalReferenceDocument = waheader-SupplierInvoiceWthnFiscalYear.
        IF wa_journalentry IS NOT INITIAL.
          IF ( waheader-IsInvoice = 'X' AND wa_journalentry-IsReversal IS INITIAL
              AND wa_transtype-PurchasingHistoryCategory = 'Q' AND wa_transtype-DebitCreditCode = 'S' ) OR
             ( waheader-IsInvoice = 'X' AND wa_journalentry-IsReversed IS INITIAL AND wa_transtype IS INITIAL ).
            wa_purchinvlines-transactiontype = 'Invoice'.
            lv_signval = 1.
          ELSEIF waheader-IsInvoice IS INITIAL AND wa_journalentry-IsReversal = 'X' AND
                 wa_transtype-PurchasingHistoryCategory = 'Q' AND wa_transtype-DebitCreditCode = 'H' .
            wa_purchinvlines-transactiontype = 'Invoice'.
            lv_signval = -1.
          ELSEIF ( waheader-IsInvoice IS INITIAL AND wa_journalentry-IsReversal IS INITIAL ) OR
                 ( waheader-IsInvoice IS INITIAL AND wa_journalentry-IsReversal = 'X' AND wa_transtype IS INITIAL ).
            wa_purchinvlines-transactiontype = 'Debit Note'.    "credit memo
            lv_signval = -1.
          ELSEIF waheader-IsInvoice = 'X' AND wa_journalentry-IsReversal = 'X'.
            wa_purchinvlines-transactiontype = 'Debit Note'.    "credit memo
            lv_signval = 1.
          ELSEIF waheader-IsInvoice = 'X' AND wa_journalentry-IsReversal IS INITIAL AND
                 wa_transtype-PurchasingHistoryCategory = 'N' AND wa_transtype-DebitCreditCode = 'S'.
            wa_purchinvlines-transactiontype = 'Credit Memo'.    "Debit Note
            lv_signval = 1.
          ELSEIF waheader-IsInvoice IS INITIAL AND wa_journalentry-IsReversal = 'X' AND
                 wa_transtype-PurchasingHistoryCategory = 'N' AND wa_transtype-DebitCreditCode = 'H'.
            wa_purchinvlines-transactiontype = 'Credit Memo'.    "Debit Note
            lv_signval = -1.
          ENDIF.
        ENDIF.
        CLEAR:  wa_journalentry, wa_transtype.

        """"""""""""""""""""""""""""""""""""""""""""""""for rate percent.
        wa_purchinvlines-rateigst   = 0.
        wa_purchinvlines-ratecgst   = 0.
        wa_purchinvlines-ratesgst   = 0.
        wa_purchinvlines-ratendigst = 0.
        wa_purchinvlines-ratendcgst = 0.
        wa_purchinvlines-ratendsgst = 0.
        IF walines-TaxCode = 'I0'.
          wa_purchinvlines-ratecgst   = 0.
          wa_purchinvlines-ratesgst   = 0.
        ELSEIF walines-TaxCode = 'I9'.
          wa_purchinvlines-rateigst   = 0.
        ELSEIF walines-TaxCode = 'I1'.
          wa_purchinvlines-ratecgst   = '2.5'.
          wa_purchinvlines-ratesgst   = '2.5'.
        ELSEIF walines-TaxCode = 'I5'.
          wa_purchinvlines-rateigst   = 5.
        ELSEIF walines-TaxCode = 'I2'.
          wa_purchinvlines-ratecgst   = 6.
          wa_purchinvlines-ratesgst   = 6.
        ELSEIF walines-TaxCode = 'I6'.
          wa_purchinvlines-rateigst   = 12.
        ELSEIF walines-TaxCode = 'I3'.
          wa_purchinvlines-ratecgst   = 9.
          wa_purchinvlines-ratesgst   = 9.
        ELSEIF walines-TaxCode = 'I7'.
          wa_purchinvlines-rateigst   = 18.
        ELSEIF walines-TaxCode = 'I4'.
          wa_purchinvlines-ratecgst   = 14.
          wa_purchinvlines-ratesgst   = 14.
        ELSEIF walines-TaxCode = 'I8'.
          wa_purchinvlines-rateigst   = 28.
        ELSEIF walines-TaxCode = 'F5'.
          wa_purchinvlines-ratecgst   = 9.
          wa_purchinvlines-ratesgst   = 9.
        ELSEIF walines-TaxCode = 'H5'.
          wa_purchinvlines-ratecgst   = 9.
          wa_purchinvlines-ratesgst   = 9.
*          wa_purchinvlines-rateigst   = 18.
        ELSEIF walines-TaxCode = 'H6'.
          wa_purchinvlines-ratecgst   = 9.
*                   ls_response-Ugstrate = '9'.
*                   wa_purchinvlines-CESSRate = '18'.
        ELSEIF walines-TaxCode = 'H4'.
          wa_purchinvlines-rateigst   = 18.
*                   ls_response-Ugstrate = '9'.
*                   ls_response-CESSRate = '18'.
        ELSEIF walines-TaxCode = 'H3'.
          wa_purchinvlines-ratecgst   = 9.
*                   ls_response-Ugstrate = '9'.
*                   LS_RESPONSE-CESSRate = '18'.
        ELSEIF walines-TaxCode = 'J3'.
          wa_purchinvlines-ratecgst   = 9.
*                   ls_response-Ugstrate = '9'.
*                   LS_RESPONSE-CESSRate = '18'.
        ELSEIF walines-TaxCode = 'G6'.
          wa_purchinvlines-rateigst   = 18.
*                   ls_response-Ugstrate = '9'.
*                   ls_response-CESSRate = '18'.
        ELSEIF walines-TaxCode = 'G7'.
          wa_purchinvlines-ratecgst   = 9.
          wa_purchinvlines-ratesgst   = 9.
*                   ls_response-CESSRate = '18'.
        ELSEIF walines-TaxCode = 'MA'.
          wa_purchinvlines-rateigst   = 5.
        ELSEIF walines-TaxCode = 'MB'.
          wa_purchinvlines-rateigst   = 12.
        ELSEIF walines-TaxCode = 'MC'.
          wa_purchinvlines-rateigst   = 18.
        ELSEIF walines-TaxCode = 'MD'.
          wa_purchinvlines-rateigst   = 28.
        ENDIF.

        SELECT SINGLE FROM I_JournalEntry
        FIELDS DocumentDate , DocumentReferenceID , IsReversed
        WHERE OriginalReferenceDocument = @walines-SupplierInvoice
        INTO (  @wa_purchinvlines-journaldocumentdate , @wa_purchinvlines-journaldocumentrefid, @wa_purchinvlines-isreversed ).

        wa_purchinvlines-pouom                    = walines-PurchaseOrderPriceUnit.
        wa_purchinvlines-poqty                      = walines-QuantityInPurchaseOrderUnit.
        wa_purchinvlines-netamount                  = walines-SupplierInvoiceItemAmount.

        wa_purchinvlines-taxableamount              = walines-SupplierInvoiceItemAmount.

        IF walines-TaxCode = 'N0'.
          wa_purchinvlines-ratendcgst   = 0.
          wa_purchinvlines-ratendsgst   = 0.
        ELSEIF walines-TaxCode = 'N9'.
          wa_purchinvlines-ratendigst   = 0.
        ELSEIF walines-TaxCode = 'N1'.
          wa_purchinvlines-ratendcgst   = '2.5'.
          wa_purchinvlines-ratendsgst   = '2.5'.
          wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.025' * lv_signval.
          wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.025' * lv_signval.
        ELSEIF walines-TaxCode = 'N5'.
          wa_purchinvlines-ratendigst   = 5.
          wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.05' * lv_signval.
        ELSEIF walines-TaxCode = 'N2'.
          wa_purchinvlines-ratendcgst   = 6.
          wa_purchinvlines-ratendsgst   = 6.
          wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.06' * lv_signval.
          wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.06' * lv_signval.
        ELSEIF walines-TaxCode = 'N6'.
          wa_purchinvlines-ratendigst   = 12.
          wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.12' * lv_signval.
        ELSEIF walines-TaxCode = 'N3'.
          wa_purchinvlines-ratendcgst   = 9.
          wa_purchinvlines-ratendsgst   = 9.
          wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.09' * lv_signval.
          wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.09' * lv_signval.
        ELSEIF walines-TaxCode = 'N7'.
          wa_purchinvlines-ratendigst   = 18.
          wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.18' * lv_signval.
*          wa_purchinvlines-taxamount =
        ELSEIF walines-TaxCode = 'N4'.
          wa_purchinvlines-ratendcgst   = 14.
          wa_purchinvlines-ratendsgst   = 14.
          wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.14' * lv_signval.
          wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.14' * lv_signval.
        ELSEIF walines-TaxCode = 'N8'.
          wa_purchinvlines-ratendigst   = 28.
          wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.28' * lv_signval.
        ENDIF.


        IF wa_purchinvlines-ndcgst IS NOT INITIAL OR wa_purchinvlines-ndigst IS NOT INITIAL OR wa_purchinvlines-ndsgst IS NOT INITIAL.
          wa_purchinvlines-cgst = 0.
          wa_purchinvlines-igst = 0.
          wa_purchinvlines-sgst = 0.
        ENDIF.

        wa_purchinvlines-taxamount                  = wa_purchinvlines-igst + wa_purchinvlines-sgst + wa_purchinvlines-ndigst +
                                                        wa_purchinvlines-ndsgst +  wa_purchinvlines-ndcgst + wa_purchinvlines-cgst.
        wa_purchinvlines-totalamount                = wa_purchinvlines-taxamount + wa_purchinvlines-netamount.

        SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
        FIELDS a~PurchaseOrderItem, a~SupplierInvoiceItem,a~SuplrInvcDeliveryCostCndnType,
        a~PurchaseOrder, a~SupplierInvoiceItemAmount, a~taxcode,
        a~FreightSupplier
        WHERE a~SupplierInvoice = @waheader-SupplierInvoice
        AND a~FiscalYear = @waheader-FiscalYear
        AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
        AND a~SuplrInvcDeliveryCostCndnType <> ''
        INTO TABLE @DATA(ltsublines).

        wa_purchinvlines-discount                   = 0.
        wa_purchinvlines-freight                    = 0.
        wa_purchinvlines-insurance                  = 0.
        wa_purchinvlines-ecs                        = 0.
        wa_purchinvlines-epf                        = 0.
        wa_purchinvlines-othercharges               = 0.
        wa_purchinvlines-packaging                  = 0.
        lv_deliverycostamount                       = 0.

        LOOP AT ltsublines INTO DATA(wasublines).

          IF wasublines-SuplrInvcDeliveryCostCndnType = 'ZFRV'.
*                       Freight
            wa_purchinvlines-freight += wasublines-SupplierInvoiceItemAmount.
            wa_purchinvlines-localfreightcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'FQU1'.
*                       Freight
            wa_purchinvlines-freight += wasublines-SupplierInvoiceItemAmount.
            wa_purchinvlines-localfreightcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'FVA1'.
*                       Freight
            wa_purchinvlines-freight += wasublines-SupplierInvoiceItemAmount.
            wa_purchinvlines-localfreightcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZINP'.
*                       Insurance Value
            wa_purchinvlines-insurance11 += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZINV'.
*                       Insurance Value
            wa_purchinvlines-insurance11 += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZECS'.
*                       ECS
            wa_purchinvlines-ecs += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZEPF'.
*                       EPF
            wa_purchinvlines-epf += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZDCP'.
*                       Discount
*            IF walines-IsSubsequentDebitCredit = 'X'.
*              wa_purchinvlines-discount += walines-SupplierInvoiceItemAmount * -1.
*            ELSE.
            wa_purchinvlines-discount += wasublines-SupplierInvoiceItemAmount.
*            ENDIF.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZDCV'.
*                       Discount
*            IF walines-IsSubsequentDebitCredit = 'X'.
*              wa_purchinvlines-discount += walines-SupplierInvoiceItemAmount * -1.
*            ELSE.
            wa_purchinvlines-discount += wasublines-SupplierInvoiceItemAmount.
*            ENDIF.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZCD1'.
*                       Discount
*            IF walines-IsSubsequentDebitCredit = 'X'.
*              wa_purchinvlines-discount += walines-SupplierInvoiceItemAmount * -1.
*            ELSE.
            wa_purchinvlines-discount += wasublines-SupplierInvoiceItemAmount.
*            ENDIF.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZDCQ'.
*                       Discount
*            IF walines-IsSubsequentDebitCredit = 'X'.
*              wa_purchinvlines-discount += walines-SupplierInvoiceItemAmount * -1.
*            ELSE.
            wa_purchinvlines-discount += wasublines-SupplierInvoiceItemAmount.
*            ENDIF.

          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZOTH'.
*                       Other Charges
            wa_purchinvlines-othercharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZPKG'.
*                       Packaging & Forwarding Charges
            wa_purchinvlines-packaging += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZOFV'.
*                       Ocean Freight Charges
            wa_purchinvlines-oceanfreightcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZFLV'.
*                       For-Land Charges
            wa_purchinvlines-forlandcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'JCDB'.
*                       Custom Duty Charges
            wa_purchinvlines-customdutycharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'JSWC'.
*                       Social Welfare Charges
            wa_purchinvlines-socialwelfarecharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZCMP' OR wasublines-SuplrInvcDeliveryCostCndnType = 'ZCMQ'.
*                       Commercial Charges
            wa_purchinvlines-commissioncharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZIHV'.
*                       InLand Charges
            wa_purchinvlines-inlandcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZCHA'.
*                       CHA Charges
            wa_purchinvlines-carrierhandcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZDMV'.
*                       Demmurage Charges
            wa_purchinvlines-demmuragecharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZPFP'  .
*                       Packing Charges
            wa_purchinvlines-packagingcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZPFV'  .
*                       Packing Charges
            wa_purchinvlines-packagingcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZLDV'  .
*                       Load Charges
            wa_purchinvlines-loadingcharges += wasublines-SupplierInvoiceItemAmount.
          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZULV'  .
*                       UnLoad Charges
            wa_purchinvlines-unloadingcharges += wasublines-SupplierInvoiceItemAmount.
          ELSE.
            wa_purchinvlines-othercharges += wasublines-SupplierInvoiceItemAmount.

          ENDIF.

          IF wasublines-TaxCode IS NOT INITIAL.

            DATA lv_chrgrateigst TYPE p DECIMALS 2.
            DATA lv_chrgratecgst TYPE p DECIMALS 2.
            DATA lv_chrgratesgst TYPE p DECIMALS 2.
            DATA lv_chrgratendigst TYPE p DECIMALS 2.
            DATA lv_chrgratendcgst TYPE p DECIMALS 2.
            DATA lv_chrgratendsgst TYPE p DECIMALS 2.

            lv_chrgrateigst = 0.
            lv_chrgratecgst = 0.
            lv_chrgratesgst = 0.
            lv_chrgratendigst = 0.
            lv_chrgratendcgst = 0.
            lv_chrgratendsgst = 0.

            IF wasublines-TaxCode = 'I0'.
              lv_chrgratecgst   = 0.
              lv_chrgratesgst   = 0.
            ELSEIF wasublines-TaxCode = 'I9'.
              lv_chrgrateigst   = 0.
            ELSEIF wasublines-TaxCode = 'I1'.
              lv_chrgratecgst   = '2.5'.
              lv_chrgratesgst   = '2.5'.
            ELSEIF wasublines-TaxCode = 'I5'.
              lv_chrgrateigst   = 5.
            ELSEIF wasublines-TaxCode = 'I2'.
              lv_chrgratecgst   = 6.
              lv_chrgratesgst   = 6.
            ELSEIF wasublines-TaxCode = 'I6'.
              lv_chrgrateigst   = 12.
            ELSEIF wasublines-TaxCode = 'I3'.
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'I7'.
              lv_chrgrateigst   = 18.
            ELSEIF wasublines-TaxCode = 'I4'.
              lv_chrgratecgst   = 14.
              lv_chrgratesgst   = 14.
            ELSEIF wasublines-TaxCode = 'I8'.
              lv_chrgrateigst   = 28.
            ELSEIF wasublines-TaxCode = 'F5'.
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'H5'.
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'H6'.   "H6
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'H4'.
              lv_chrgrateigst   = 18.
            ELSEIF wasublines-TaxCode = 'H3'.   "H3
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'J3'.
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'G6'.
              lv_chrgrateigst   = 18.
            ELSEIF wasublines-TaxCode = 'G7'.
              lv_chrgratecgst   = 9.
              lv_chrgratesgst   = 9.
            ELSEIF wasublines-TaxCode = 'MA'.
              lv_chrgrateigst   = 5.
            ELSEIF wasublines-TaxCode = 'MB'.
              lv_chrgrateigst   = 12.
            ELSEIF wasublines-TaxCode = 'MC'.
              lv_chrgrateigst   = 18.
            ELSEIF wasublines-TaxCode = 'MD'.
              lv_chrgrateigst   = 28.
            ENDIF.

            IF wasublines-TaxCode = 'N0'.
              lv_chrgratendcgst   = 0.
              lv_chrgratendsgst   = 0.
            ELSEIF wasublines-TaxCode = 'N9'.
              lv_chrgratendigst   = 0.
            ELSEIF wasublines-TaxCode = 'N1'.
              lv_chrgratendcgst   = '2.5'.
              lv_chrgratendsgst   = '2.5'.
            ELSEIF wasublines-TaxCode = 'N5'.
              lv_chrgratendigst   = 5.
            ELSEIF wasublines-TaxCode = 'N2'.
              lv_chrgratendcgst   = 6.
              lv_chrgratendsgst   = 6.
            ELSEIF wasublines-TaxCode = 'N6'.
              lv_chrgratendigst   = 12.
            ELSEIF wasublines-TaxCode = 'N3'.
              lv_chrgratendcgst   = 9.
              lv_chrgratendsgst   = 9.
            ELSEIF wasublines-TaxCode = 'N7'.
              lv_chrgratendigst   = 18.
            ELSEIF wasublines-TaxCode = 'N4'.
              lv_chrgratendcgst   = 14.
              lv_chrgratendsgst   = 14.
            ELSEIF wasublines-TaxCode = 'N8'.
              lv_chrgratendigst   = 28.
            ENDIF.

            IF lv_chrgrateigst IS NOT INITIAL.
              wa_purchinvlines-igst +=   lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgrateigst / 100 .
              wa_purchinvlines-taxamount += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgrateigst / 100 .
              lv_deliverycostamount += wasublines-SupplierInvoiceItemAmount.
            ENDIF.
            IF lv_chrgratecgst IS NOT INITIAL.
              wa_purchinvlines-cgst += lv_signval *  wasublines-SupplierInvoiceItemAmount *  lv_chrgratecgst  / 100 .
              wa_purchinvlines-taxamount += lv_signval *  wasublines-SupplierInvoiceItemAmount *  lv_chrgratecgst / 100 .
              lv_deliverycostamount += wasublines-SupplierInvoiceItemAmount.
            ENDIF.
            IF lv_chrgratesgst IS NOT INITIAL.
              wa_purchinvlines-sgst += lv_signval *  wasublines-SupplierInvoiceItemAmount *  lv_chrgratesgst / 100 .
              wa_purchinvlines-taxamount += lv_signval *  wasublines-SupplierInvoiceItemAmount *  lv_chrgratesgst / 100 .
            ENDIF.
            IF lv_chrgratendigst IS NOT INITIAL.
              wa_purchinvlines-ndigst += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgratendigst / 100 .
              wa_purchinvlines-taxamount += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgratendigst / 100 .
              lv_deliverycostamount += wasublines-SupplierInvoiceItemAmount.
            ENDIF.
            IF lv_chrgratendcgst IS NOT INITIAL.
              wa_purchinvlines-ndcgst += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgratendcgst / 100 .
              wa_purchinvlines-taxamount += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgratendcgst / 100 .
              lv_deliverycostamount += wasublines-SupplierInvoiceItemAmount.
            ENDIF.
            IF lv_chrgratendsgst IS NOT INITIAL.
              wa_purchinvlines-ndsgst += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgratendsgst / 100 .
              wa_purchinvlines-taxamount += lv_signval * wasublines-SupplierInvoiceItemAmount *  lv_chrgratendsgst / 100 .
            ENDIF.
          ENDIF.
        ENDLOOP.


        SELECT FROM  i_purorditmpricingelementapi01 AS a
        INNER JOIN I_PurchaseOrderItemAPI01 AS b ON a~PurchaseOrder = b~PurchaseOrder
        AND a~PurchaseOrderItem = b~PurchaseOrderItem
        FIELDS a~conditioncurrency , a~ConditionAmount , b~PurchaseOrder
        WHERE b~PurchaseOrder = @walines-PurchaseOrder
        AND b~PurchaseOrderItem = @walines-PurchaseOrderItem
        AND a~ConditionType IN ( 'ZDCP' , 'ZDCV' , 'ZCD1' , 'ZDCQ' )
        INTO TABLE @DATA(it_discount2).
        LOOP AT it_discount2 INTO DATA(waDiscount).  "DIscount
          wa_purchinvlines-discount += waDiscount-ConditionAmount.
        ENDLOOP.

        wa_purchinvlines-DeliveryCost = wa_purchinvlines-freight +
                                      wa_purchinvlines-insurance11 + wa_purchinvlines-ecs +
                                      wa_purchinvlines-epf + wa_purchinvlines-othercharges +
                                      wa_purchinvlines-packaging + wa_purchinvlines-oceanfreightcharges +
                                      wa_purchinvlines-carrierhandcharges + wa_purchinvlines-commissioncharges +
                                      wa_purchinvlines-customdutycharges + wa_purchinvlines-demmuragecharges +
                                      wa_purchinvlines-forlandcharges + wa_purchinvlines-inlandcharges +
                                      wa_purchinvlines-loadingcharges + wa_purchinvlines-socialwelfarecharges +
                                      wa_purchinvlines-unloadingcharges +
                                      wa_purchinvlines-packagingcharges.

        wa_purchinvlines-totalamount = abs( wa_purchinvlines-taxamount ) + wa_purchinvlines-netamount + wa_purchinvlines-DeliveryCost +
                                       wa_purchinvlines-rcmcgst + wa_purchinvlines-rcmsgst + wa_purchinvlines-rcmigst .
        wa_purchinvlines-taxableamount += lv_deliverycostamount.

        wa_purchinvlines-discount *= lv_signval .
        wa_purchinvlines-DeliveryCost *= lv_signval.
        wa_purchinvlines-freight *= lv_signval.
        wa_purchinvlines-insurance11 *= lv_signval.
        wa_purchinvlines-ecs *= lv_signval.
        wa_purchinvlines-epf *= lv_signval.
        wa_purchinvlines-othercharges *= lv_signval.
        wa_purchinvlines-oceanfreightcharges *= lv_signval.
        wa_purchinvlines-packaging *= lv_signval.
        wa_purchinvlines-carrierhandcharges *= lv_signval.
        wa_purchinvlines-commissioncharges *= lv_signval.
        wa_purchinvlines-customdutycharges *= lv_signval.
        wa_purchinvlines-demmuragecharges *= lv_signval.
        wa_purchinvlines-forlandcharges *= lv_signval.
        wa_purchinvlines-inlandcharges *= lv_signval.
        wa_purchinvlines-socialwelfarecharges *= lv_signval.
        wa_purchinvlines-loadingcharges *= lv_signval.
        wa_purchinvlines-unloadingcharges *= lv_signval.
        wa_purchinvlines-packagingcharges *= lv_signval.
        wa_purchinvlines-totalamount *= lv_signval.
        wa_purchinvlines-poqty *= lv_signval.
        wa_purchinvlines-netamount *= lv_signval.
        wa_purchinvlines-taxableamount *= lv_signval.
        wa_purchinvlines-rcmcgst *= lv_signval.
        wa_purchinvlines-rcmsgst *= lv_signval.
        wa_purchinvlines-rcmigst *= lv_signval.
        wa_purchinvlines-mrnquantityinbaseunit *= lv_signval.

        wa_purchinvlines-miro_item_type = 'PO Ref Entry'.

        wa_purchinvlines-invoicingpartycodename = | { waheader-Supplier } - { waheader-SupplierName } |.
*            //For Reverse Document
        wa_purchinvlines-referencedocumentno = waheader-revdoc .
        APPEND wa_purchinvlines TO lt_purchinvlines.
*    ********************* Added on 08.02.2025
        MODIFY zpurchinvlines FROM @wa_purchinvlines.
        CLEAR : wa_purchinvlines, wa_po, wa_tax, lv_taxitemacctgdocitemref, it_discount2, wa_zplant3.
      ENDLOOP.







***** For Non Product Entries

      SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
**********************************************
          LEFT JOIN I_PurchaseOrderItemAPI01 AS li ON a~PurchaseOrder = li~PurchaseOrder AND a~PurchaseOrderItem = li~PurchaseOrderItem
*            LEFT JOIN zmaterial_table AS li4 ON li~Material = li4~mat
          LEFT JOIN i_deliverydocumentitem AS li2 ON li~PurchaseOrder = li2~ReferenceSDDocument AND li~PurchaseOrderItem = li2~ReferenceSDDocumentItem
          LEFT JOIN i_deliverydocument AS li3 ON li2~DeliveryDocument = li3~DeliveryDocument
          LEFT JOIN I_SupplierInvoiceAPI01 AS li5 ON a~SupplierInvoice = li5~SupplierInvoice AND a~FiscalYear = li5~FiscalYear
          LEFT JOIN i_purchaseorderapi01 AS c ON li~PurchaseOrder = c~PurchaseOrder
          LEFT JOIN I_Supplier AS li13 ON c~Supplier = li13~Supplier
          LEFT JOIN I_MaterialDocumentHeader_2 AS li14 ON a~ReferenceDocument = li14~MaterialDocument AND a~ReferenceDocumentFiscalYear = li14~MaterialDocumentYear
          LEFT JOIN I_BusinessPartner AS li7 ON c~Supplier = li7~BusinessPartner
          LEFT JOIN I_BusinessPartnerLegalFormText AS li8 ON li7~LegalForm = li8~LegalForm
          LEFT JOIN i_purchaseorderitemtp_2 AS li9 ON li~PurchaseOrder = li9~PurchaseOrder
          LEFT JOIN I_Requestforquotation_Api01 AS li10 ON li9~SupplierQuotation = li10~RequestForQuotation
          LEFT JOIN I_SupplierQuotation_Api01 AS li11 ON li9~SupplierQuotation = li11~SupplierQuotation
*    ********************************************
          FIELDS
              a~PurchaseOrderItem, a~SupplierInvoiceItem,
              a~PurchaseOrder, a~SupplierInvoiceItemAmount AS tax_amt, a~SupplierInvoiceItemAmount, a~taxcode,
              a~FreightSupplier , a~SupplierInvoice , a~FiscalYear , a~TaxJurisdiction, a~plant, a~SuplrInvcDeliveryCostCndnType,
              a~PurchaseOrderItemMaterial AS material, a~QuantityInPurchaseOrderUnit, a~QtyInPurchaseOrderPriceUnit,
              a~PurchaseOrderQuantityUnit, PurchaseOrderPriceUnit, a~ReferenceDocument , a~ReferenceDocumentFiscalYear,
*    ***********************************************
              li~Plant AS plantcity, li~Plant AS plantpin, li3~DeliveryDocumentBySupplier, li5~DocumentDate,
              li8~LegalFormDescription, li9~SupplierQuotation, li10~RFQPublishingDate, li11~SupplierQuotation AS sq,
              li11~QuotationSubmissionDate, li5~PostingDate, li~NetPriceAmount, a~IsSubsequentDebitCredit, li~br_ncm
              , c~Supplier, li13~SupplierFullName, li14~PostingDate AS MRNPostingDate, li~PurchaseOrderItemText
*    **********************************************
          WHERE a~SupplierInvoice = @waheader-SupplierInvoice
            AND a~FiscalYear = @waheader-FiscalYear
            AND a~SuplrInvcDeliveryCostCndnType <> ''
          ORDER BY a~PurchaseOrderItem, a~SupplierInvoiceItem
            INTO TABLE @DATA(ltlinesNp).


      IF ltlinesNp IS NOT INITIAL.

        IF ltlines IS NOT INITIAL.
          SELECT FROM I_Producttext AS a FIELDS
              a~ProductName, a~Product
          FOR ALL ENTRIES IN @ltlines
          WHERE a~Product = @ltlines-material AND a~Language = 'E'
              INTO TABLE @DATA(it_productNp).
        ENDIF.

        IF ltlines IS NOT INITIAL.
          SELECT FROM I_PurchaseOrderItemAPI01 AS a
              LEFT JOIN I_PurchaseOrderAPI01 AS b ON a~PurchaseOrdeR = b~PurchaseOrder
              FIELDS a~BaseUnit , b~PurchaseOrderType , b~PurchasingGroup , b~PurchasingOrganization ,
              b~PurchaseOrderDate , a~PurchaseOrder , a~PurchaseOrderItem , a~ProfitCenter
          FOR ALL ENTRIES IN @ltlines
          WHERE a~PurchaseOrder = @ltlines-PurchaseOrder AND a~PurchaseOrderItem = @ltlines-PurchaseOrderItem
              INTO TABLE @DATA(it_ponp).
        ENDIF.

        IF ltlines IS NOT INITIAL.
          SELECT FROM I_MaterialDocumentItem_2
              FIELDS MaterialDocument , PurchaseOrder , PurchaseOrderItem , QuantityInBaseUnit , PostingDate
          FOR ALL ENTRIES IN @ltlines
          WHERE MaterialDocument  = @ltlines-ReferenceDocument
              INTO TABLE @DATA(it_grnnp).
        ENDIF.
        IF ltlines IS NOT INITIAL.
          SELECT FROM I_taxcodetext
              FIELDS TaxCode , TaxCodeName
          FOR ALL ENTRIES IN @ltlines
          WHERE Language = 'E' AND taxcode = @ltlines-TaxCode
              INTO TABLE @DATA(it_taxnp).
        ENDIF.
*
        SELECT a~conditioncurrency,
               a~ConditionAmount,
               b~PurchaseOrder
          FROM i_purorditmpricingelementapi01 AS a
          INNER JOIN I_PurchaseOrderAPI01 AS b
            ON a~PricingDocument = b~PricingDocument
          WHERE b~PurchaseOrder IN ( SELECT PurchaseOrder
                                       FROM @ltlinesNp AS a )
            AND a~ConditionType IN ( 'ZDCP', 'ZDCV', 'ZCD1', 'ZDCQ' )
          INTO TABLE @DATA(it_discount1Np).
      ENDIF.

      SELECT SINGLE FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
      FIELDS a~PurchaseOrderItem, a~SupplierInvoiceItem
      WHERE a~SupplierInvoice = @waheader-SupplierInvoice AND a~FiscalYear = @waheader-FiscalYear
      AND a~SuplrInvcDeliveryCostCndnType = ''
      INTO @DATA(ltlinesNpCheck).

      IF ltlinesnpcheck IS INITIAL.
        LOOP AT ltlinesNp INTO DATA(walinesNp).
          wa_purchinvlines-client                     = sy-mandt.
          wa_purchinvlines-companycode                = waheader-CompanyCode.
          wa_purchinvlines-fiscalyearvalue            = waheader-FiscalYear.
          wa_purchinvlines-supplierbillno             = waheader-SupplierInvoiceIDByInvcgParty.
          wa_purchinvlines-supplierinvoice            = waheader-SupplierInvoice.
          wa_purchinvlines-supplierinvoiceitem        = walinesNp-SupplierInvoiceItem.
          wa_purchinvlines-postingdate                = walinesNp-PostingDate.
*    ********************************* Item Level Fields Added ****************************
          wa_purchinvlines-plantcity                  = walinesNp-plantcity.
          wa_purchinvlines-plantpin                   = walinesNp-plantpin.
          wa_purchinvlines-vendor_invoice_no          = walinesNp-DeliveryDocumentBySupplier.
          wa_purchinvlines-vendor_invoice_date        = walinesNp-DocumentDate.
          wa_purchinvlines-plant                      = walinesnp-Plant.
          wa_purchinvlines-vendor_type                = walinesNp-LegalFormDescription.
          wa_purchinvlines-rfqno                      = walinesNp-SupplierQuotation.
          wa_purchinvlines-rfqno                      = walinesNp-SupplierQuotation.
          wa_purchinvlines-rfqdate                    = walinesNp-RFQPublishingDate.
          wa_purchinvlines-supplierquotation          = walinesNp-sq.
          wa_purchinvlines-supplierquotationdate      = walinesNp-QuotationSubmissionDate.
          wa_purchinvlines-mrnquantityinbaseunit      = walinesNp-PostingDate.
          wa_purchinvlines-hsncode                    = walinesNp-br_ncm.
          wa_purchinvlines-supp_gst                   = waheader-supp_gst.
          wa_purchinvlines-suppliercode               = walinesNp-Supplier.
          wa_purchinvlines-suppliercodename           = waLinesNp-SupplierFullName ."| { walinesNp-Supplier } - { waLinesNp-SupplierFullName  } |.
          SELECT SINGLE FROM I_IN_BusinessPlaceTaxDetail AS a
              LEFT JOIN  I_Address_2  AS b ON a~AddressID = b~AddressID
              FIELDS
              a~BusinessPlaceDescription,
              a~IN_GSTIdentificationNumber,
              b~Street, b~PostalCode , b~CityName
          WHERE a~CompanyCode = @waheader-CompanyCode AND a~BusinessPlace = @walinesNp-Plant
          INTO ( @wa_purchinvlines-plantname, @wa_purchinvlines-plantgst, @wa_purchinvlines-plantadr, @wa_purchinvlines-plantpin,
              @wa_purchinvlines-plantcity ).

          wa_purchinvlines-product                    = walinesNp-material.
          IF walinesNp-material <> ''.
            READ TABLE it_productNp INTO DATA(wa_productNp) WITH KEY product = walinesNp-material.
            wa_purchinvlines-productname            = wa_productNp-ProductName.
          ELSE.
            wa_purchinvlines-productname            = walinesNp-PurchaseOrderItemText.
          ENDIF.

          wa_purchinvlines-purchaseorder              = walinesNp-PurchaseOrder.
          wa_purchinvlines-purchaseorderitem          = walinesNp-PurchaseOrderItem.
          CONCATENATE walinesNp-SupplierInvoice walinesNp-FiscalYear INTO wa_purchinvlines-originalreferencedocument.

          READ TABLE it_ponp INTO DATA(wa_poNp) WITH KEY PurchaseOrder = walinesNp-PurchaseOrder
                                                  PurchaseOrderItem = walinesNp-PurchaseOrderItem.

          wa_purchinvlines-baseunit                   = wa_poNp-BaseUnit.
          wa_purchinvlines-profitcenter               = wa_poNp-ProfitCenter.
          wa_purchinvlines-purchaseordertype          = wa_poNp-PurchaseOrderType.
          wa_purchinvlines-purchaseorderdate          = wa_poNp-PurchaseOrderDate.
          wa_purchinvlines-purchasingorganization     = wa_poNp-PurchasingOrganization.
          wa_purchinvlines-purchasinggroup            = wa_poNp-PurchasingGroup.
          wa_purchinvlines-basicrate                  = 0. "walines-NetPriceAmount.
          wa_purchinvlines-grnno                      = walinesNp-ReferenceDocument.
          wa_purchinvlines-mrnpostingdate             = walinesNp-mrnpostingdate.
          wa_purchinvlines-mrnquantityinbaseunit      = 0. "walines-QtyInPurchaseOrderPriceUnit.
*                READ TABLE it_grn INTO DATA(wa_grn) WITH KEY MaterialDocument = walines-ReferenceDocument.
*                    wa_purchinvlines-mrnquantityinbaseunit     = wa_grn-QuantityInBaseUnit.
          READ TABLE it_taxnp INTO DATA(wa_taxNp) WITH KEY     TaxCode = walinesNp-TaxCode.
          wa_purchinvlines-taxcodename                = wa_taxNp-TaxCodeName.
*            if walinesNp-IsSubsequentDebitCredit = 'X'.
*                wa_purchinvlines-isreversed = 'X'.
*            ENDIF.
          CONCATENATE walinesNp-PurchaseOrder walinesNp-PurchaseOrderItem INTO assignmentreference.

          SELECT SINGLE TaxItemAcctgDocItemRef, IN_HSNOrSACCode FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear AND TaxItemAcctgDocItemRef IS NOT INITIAL
              AND AccountingDocumentItemType <> 'T'
              AND FiscalYear = @walinesNp-FiscalYear
              AND CompanyCode = @waheader-CompanyCode
              AND AccountingDocumentType = 'RE'
              AND AssignmentReference = @assignmentreference
              AND Product = @walinesNp-material
          INTO  (  @DATA(lv_TaxItemAcctgDocItemRefNp), @DATA(lv_HSNCodeNp) ).
          wa_purchinvlines-hsncode                    = lv_HSNCodeNp.

          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                  AND AccountingDocumentItemType = 'T'
                  AND FiscalYear = @walinesNp-FiscalYear
                  AND CompanyCode = @waheader-CompanyCode
                  AND TransactionTypeDetermination = 'JII'
          INTO  @wa_purchinvlines-igst.

          IF wa_purchinvlines-igst IS INITIAL.
            SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
                WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                    AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                    AND AccountingDocumentItemType = 'T'
                    AND FiscalYear = @walinesNp-FiscalYear
                    AND CompanyCode = @waheader-CompanyCode
                    AND TransactionTypeDetermination = 'JIC'
            INTO  @wa_purchinvlines-cgst.

            SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
                WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                    AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                    AND AccountingDocumentItemType = 'T'
                    AND FiscalYear = @walinesNp-FiscalYear
                    AND CompanyCode = @waheader-CompanyCode
                    AND TransactionTypeDetermination = 'JIS'
            INTO  @wa_purchinvlines-sgst.
          ENDIF.

          SELECT  SINGLE AmountInCompanyCodeCurrency  FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                  AND AccountingDocumentItemType = 'T'
                  AND FiscalYear = @walinesNp-FiscalYear
                  AND CompanyCode = @waheader-CompanyCode
                  AND TransactionTypeDetermination = 'JRI'
          INTO  @wa_purchinvlines-rcmigst .
*            wa_purchinvlines-rcmigst = wa_purchinvlines-rcmigst * -1 .
          IF wa_purchinvlines-rcmigst IS INITIAL.
            SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
                WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                    AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                    AND AccountingDocumentItemType = 'T'
                    AND FiscalYear = @walinesNp-FiscalYear
                    AND CompanyCode = @waheader-CompanyCode
                    AND TransactionTypeDetermination = 'JRC'
            INTO  @wa_purchinvlines-rcmcgst.
*              wa_purchinvlines-rcmcgst *= -1 .

            SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
                WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                    AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                    AND AccountingDocumentItemType = 'T'
                    AND FiscalYear = @walinesNp-FiscalYear
                    AND CompanyCode = @waheader-CompanyCode
                    AND TransactionTypeDetermination = 'JRS'
            INTO  @wa_purchinvlines-rcmsgst.
*              wa_purchinvlines-rcmcgst *= -1 .
            SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
                WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
                    AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                    AND AccountingDocumentItemType = 'T'
                    AND FiscalYear = @walinesNp-FiscalYear
                    AND CompanyCode = @waheader-CompanyCode
                    AND TransactionTypeDetermination = 'JIM'
            INTO  @wa_purchinvlines-igst.

          ENDIF.


          """"""""""""""""""""""""""""""""""""""""""""""""for rate percent.
          wa_purchinvlines-rateigst   = 0.
          wa_purchinvlines-ratecgst   = 0.
          wa_purchinvlines-ratesgst   = 0.
          wa_purchinvlines-ratendigst = 0.
          wa_purchinvlines-ratendcgst = 0.
          wa_purchinvlines-ratendsgst = 0.
          IF walinesNp-TaxCode = 'I0'.
            wa_purchinvlines-ratecgst   = 0.
            wa_purchinvlines-ratesgst   = 0.
          ELSEIF walinesNp-TaxCode = 'I9'.
            wa_purchinvlines-rateigst   = 0.
          ELSEIF walinesNp-TaxCode = 'I1'.
            wa_purchinvlines-ratecgst   = '2.5'.
            wa_purchinvlines-ratesgst   = '2.5'.
          ELSEIF walinesNp-TaxCode = 'I5'.
            wa_purchinvlines-rateigst   = 5.
          ELSEIF walinesNp-TaxCode = 'I2'.
            wa_purchinvlines-ratecgst   = 6.
            wa_purchinvlines-ratesgst   = 6.
          ELSEIF walinesNp-TaxCode = 'I6'.
            wa_purchinvlines-rateigst   = 12.
          ELSEIF walinesNp-TaxCode = 'I3'.
            wa_purchinvlines-ratecgst   = 9.
            wa_purchinvlines-ratesgst   = 9.
          ELSEIF walinesNp-TaxCode = 'I7'.
            wa_purchinvlines-rateigst   = 18.
          ELSEIF walinesNp-TaxCode = 'I4'.
            wa_purchinvlines-ratecgst   = 14.
            wa_purchinvlines-ratesgst   = 14.
          ELSEIF walinesNp-TaxCode = 'I8'.
            wa_purchinvlines-rateigst   = 28.
          ELSEIF walinesNp-TaxCode = 'F5'.
            wa_purchinvlines-ratecgst   = 9.
            wa_purchinvlines-ratesgst   = 9.
          ELSEIF walinesNp-TaxCode = 'H5'.
            wa_purchinvlines-ratecgst   = 9.
            wa_purchinvlines-ratesgst   = 9.
            wa_purchinvlines-rateigst   = 18.
          ELSEIF walinesNp-TaxCode = 'H6'.
            wa_purchinvlines-ratecgst   = 9.
*                       ls_response-Ugstrate = '9'.
*                       wa_purchinvlines-CESSRate = '18'.
          ELSEIF walinesNp-TaxCode = 'H4'.
            wa_purchinvlines-rateigst   = 18.
*                       ls_response-Ugstrate = '9'.
*                       ls_response-CESSRate = '18'.
          ELSEIF walinesNp-TaxCode = 'H3'.
            wa_purchinvlines-ratecgst   = 9.
*                       ls_response-Ugstrate = '9'.
*                       LS_RESPONSE-CESSRate = '18'.
          ELSEIF walinesNp-TaxCode = 'J3'.
            wa_purchinvlines-ratecgst   = 9.
*                       ls_response-Ugstrate = '9'.
*                       LS_RESPONSE-CESSRate = '18'.
          ELSEIF walinesNp-TaxCode = 'G6'.
            wa_purchinvlines-rateigst   = 18.
*                       ls_response-Ugstrate = '9'.
*                       ls_response-CESSRate = '18'.
          ELSEIF walinesNp-TaxCode = 'G7'.
            wa_purchinvlines-ratecgst   = 9.
            wa_purchinvlines-ratesgst   = 9.
*                       ls_response-CESSRate = '18'.
          ELSEIF walinesNp-TaxCode = 'MA'.
            wa_purchinvlines-rateigst   = 5.
          ELSEIF walinesNp-TaxCode = 'MB'.
            wa_purchinvlines-rateigst   = 12.
          ELSEIF walinesNp-TaxCode = 'MC'.
            wa_purchinvlines-rateigst   = 18.
          ELSEIF walinesNp-TaxCode = 'MD'.
            wa_purchinvlines-rateigst   = 28.
          ENDIF.


          SELECT SINGLE FROM I_JournalEntry
          FIELDS DocumentDate , DocumentReferenceID , IsReversed
          WHERE OriginalReferenceDocument = @walinesNp-SupplierInvoice
          INTO (  @wa_purchinvlines-journaldocumentdate , @wa_purchinvlines-journaldocumentrefid, @wa_purchinvlines-isreversed ).

          wa_purchinvlines-pouom                      = walinesNp-PurchaseOrderPriceUnit.

          IF walinesNp-IsSubsequentDebitCredit = 'X'.
            wa_purchinvlines-poqty                      = walinesNp-QuantityInPurchaseOrderUnit * -1.
            wa_purchinvlines-netamount                =   walinesNp-SupplierInvoiceItemAmount * -1.
          ELSE.
            wa_purchinvlines-poqty                      = walinesNp-QuantityInPurchaseOrderUnit.
            wa_purchinvlines-netamount                = walinesNp-SupplierInvoiceItemAmount.
          ENDIF.
          wa_purchinvlines-taxableamount              =   wa_purchinvlines-netamount.


          IF walines-TaxCode = 'N0'.
            wa_purchinvlines-ratendcgst   = 0.
            wa_purchinvlines-ratendsgst   = 0.
          ELSEIF walines-TaxCode = 'N9'.
            wa_purchinvlines-ratendigst   = 0.
          ELSEIF walines-TaxCode = 'N1'.
            wa_purchinvlines-ratendcgst   = '2.5'.
            wa_purchinvlines-ratendsgst   = '2.5'.
            wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.025'.
            wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.025'.
          ELSEIF walines-TaxCode = 'N5'.
            wa_purchinvlines-ratendigst   = 5.
            wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.05'.
          ELSEIF walines-TaxCode = 'N2'.
            wa_purchinvlines-ratendcgst   = 6.
            wa_purchinvlines-ratendsgst   = 6.
            wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.06'.
            wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.06'.
          ELSEIF walines-TaxCode = 'N6'.
            wa_purchinvlines-ratendigst   = 12.
            wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.12'.
          ELSEIF walines-TaxCode = 'N3'.
            wa_purchinvlines-ratendcgst   = 9.
            wa_purchinvlines-ratendsgst   = 9.
            wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.09'.
            wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.09'.
          ELSEIF walines-TaxCode = 'N7'.
            wa_purchinvlines-ratendigst   = 18.
            wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.18'.
          ELSEIF walines-TaxCode = 'N4'.
            wa_purchinvlines-ratendcgst   = 14.
            wa_purchinvlines-ratendsgst   = 14.
            wa_purchinvlines-ndcgst = wa_purchinvlines-netamount * '0.14'.
            wa_purchinvlines-ndsgst = wa_purchinvlines-netamount * '0.14'.
          ELSEIF walines-TaxCode = 'N8'.
            wa_purchinvlines-ratendigst   = 28.
            wa_purchinvlines-ndigst = wa_purchinvlines-netamount * '0.28'.
          ENDIF.

          IF wa_purchinvlines-ndcgst IS NOT INITIAL OR wa_purchinvlines-ndigst IS NOT INITIAL OR wa_purchinvlines-ndsgst IS NOT INITIAL.
            wa_purchinvlines-cgst = ''.
            wa_purchinvlines-igst = ''.
            wa_purchinvlines-sgst = ''.
          ENDIF.

          wa_purchinvlines-taxamount                  = wa_purchinvlines-igst + wa_purchinvlines-sgst + wa_purchinvlines-ndcgst +
                                                        wa_purchinvlines-cgst + wa_purchinvlines-ndigst + wa_purchinvlines-ndsgst.
          wa_purchinvlines-totalamount                = wa_purchinvlines-netamount.

          SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
          FIELDS
          a~PurchaseOrderItem, a~SupplierInvoiceItem,a~SuplrInvcDeliveryCostCndnType,
          a~PurchaseOrder, a~SupplierInvoiceItemAmount, a~taxcode,
          a~FreightSupplier
          WHERE a~SupplierInvoice = @waheader-SupplierInvoice
          AND a~FiscalYear = @waheader-FiscalYear
          AND a~PurchaseOrderItem = @walinesNp-PurchaseOrderItem
          AND a~SuplrInvcDeliveryCostCndnType <> ''
          AND a~SupplierInvoiceItem = @walinesnp-SupplierInvoiceItem
          INTO TABLE @DATA(ltsublinesNp).

          wa_purchinvlines-discount                   = 0.
          wa_purchinvlines-freight                    = 0.
          wa_purchinvlines-insurance                  = 0.
          wa_purchinvlines-ecs                        = 0.
          wa_purchinvlines-epf                        = 0.
          wa_purchinvlines-othercharges               = 0.
          wa_purchinvlines-packaging                  = 0.
          lv_deliverycostamount                       = 0.
          LOOP AT ltsublinesNp INTO DATA(wasublinesNp).
            IF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZFRV'.
*                           Freight
              wa_purchinvlines-freight += wasublinesNp-SupplierInvoiceItemAmount.
              wa_purchinvlines-localfreightcharges += wasublinesNp-SupplierInvoiceItemAmount.
              IF wa_purchinvlines-ratendigst IS NOT INITIAL .
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-localfreightcharges *  wa_purchinvlines-ratendigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratendcgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-localfreightcharges *  wa_purchinvlines-ratendcgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-localfreightcharges *  wa_purchinvlines-ratendsgst ) / 100 ).
              ELSEIF wa_purchinvlines-rateigst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-localfreightcharges *  wa_purchinvlines-rateigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratecgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-localfreightcharges *  wa_purchinvlines-ratecgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-localfreightcharges *  wa_purchinvlines-ratesgst ) / 100 ).
              ENDIF.

              IF ( wa_purchinvlines-ratecgst + wa_purchinvlines-ratesgst + wa_purchinvlines-rateigst +
                   wa_purchinvlines-ratendigst + wa_purchinvlines-ratendcgst + wa_purchinvlines-ratendsgst ) NE 0.

                lv_deliverycostamount       +=  wa_purchinvlines-localfreightcharges.

              ENDIF.

            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'FQU1'.
*                           Freight
              wa_purchinvlines-freight += wasublinesNp-SupplierInvoiceItemAmount.
              wa_purchinvlines-localfreightcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'FVA1'.
*                           Freight
              wa_purchinvlines-freight += wasublinesNp-SupplierInvoiceItemAmount.
              wa_purchinvlines-localfreightcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZINP'.
*                           Insurance Value
              wa_purchinvlines-insurance11 += wasublinesNp-SupplierInvoiceItemAmount.

              IF wa_purchinvlines-ratendigst IS NOT INITIAL .
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-insurance11 *  wa_purchinvlines-ratendigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratendcgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-insurance11 *  wa_purchinvlines-ratendcgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-insurance11 *  wa_purchinvlines-ratendsgst ) / 100 ).
              ELSEIF wa_purchinvlines-rateigst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-insurance11 *  wa_purchinvlines-rateigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratecgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-insurance11 *  wa_purchinvlines-ratecgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-insurance11 *  wa_purchinvlines-ratesgst ) / 100 ).
              ENDIF.

              IF ( wa_purchinvlines-ratecgst + wa_purchinvlines-ratesgst + wa_purchinvlines-rateigst +
                   wa_purchinvlines-ratendigst + wa_purchinvlines-ratendcgst + wa_purchinvlines-ratendsgst ) NE 0.

                lv_deliverycostamount       +=  wa_purchinvlines-insurance11.

              ENDIF.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZINV'.
*                           Insurance Value
              wa_purchinvlines-insurance11 += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZECS'.
*                           ECS
              wa_purchinvlines-ecs += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZEPF'.
*                           EPF
              wa_purchinvlines-epf += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZDCP'.
*                           Discount
              IF walines-IsSubsequentDebitCredit = 'X'.
                wa_purchinvlines-discount += walinesNp-SupplierInvoiceItemAmount * -1.
              ELSE.
                wa_purchinvlines-discount += wasublinesNp-SupplierInvoiceItemAmount.
              ENDIF.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZDCV'.
*                           Discount
              IF walines-IsSubsequentDebitCredit = 'X'.
                wa_purchinvlines-discount += walinesNp-SupplierInvoiceItemAmount * -1.
              ELSE.
                wa_purchinvlines-discount += wasublinesNp-SupplierInvoiceItemAmount.
              ENDIF.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZCD1'.
*                           Discount
              IF walines-IsSubsequentDebitCredit = 'X'.
                wa_purchinvlines-discount += walinesNp-SupplierInvoiceItemAmount * -1.
              ELSE.
                wa_purchinvlines-discount += wasublinesNp-SupplierInvoiceItemAmount.
              ENDIF.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZDCQ'.
*                           Discount
              IF walines-IsSubsequentDebitCredit = 'X'.
                wa_purchinvlines-discount += walinesNp-SupplierInvoiceItemAmount * -1.
              ELSE.
                wa_purchinvlines-discount += wasublinesNp-SupplierInvoiceItemAmount.
              ENDIF.

            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZOTH'.
*                           Other Charges
              wa_purchinvlines-othercharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZPKG'.
*                           Packaging & Forwarding Charges
              wa_purchinvlines-packaging += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZOFV'.
*                           Ocean Freight Charges
              wa_purchinvlines-oceanfreightcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZFLV'.
*                           For-Land Charges
              wa_purchinvlines-forlandcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'JCDB'.
*                           Custom Duty Charges
              wa_purchinvlines-customdutycharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'JSWC'.
*                           Social Welfare Charges
              wa_purchinvlines-socialwelfarecharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZCMP' OR wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZCMQ' .
*                           Commercial Charges
              wa_purchinvlines-commissioncharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZIHV'.
*                           InLand Charges
              wa_purchinvlines-inlandcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZCHA'.
*                           CHA Charges
              wa_purchinvlines-carrierhandcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZDMV'.
*                           Demmurage Charges
              wa_purchinvlines-demmuragecharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZPFP'  .
*                           Packing Charges
              wa_purchinvlines-packagingcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZPFV'  .
*                           Packing Charges
              wa_purchinvlines-packagingcharges += wasublinesNp-SupplierInvoiceItemAmount.

              IF wa_purchinvlines-ratendigst IS NOT INITIAL .
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-packagingcharges *  wa_purchinvlines-ratendigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratendcgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-packagingcharges *  wa_purchinvlines-ratendcgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-packagingcharges *  wa_purchinvlines-ratendsgst ) / 100 ).
              ELSEIF wa_purchinvlines-rateigst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-packagingcharges *  wa_purchinvlines-rateigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratecgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-packagingcharges *  wa_purchinvlines-ratecgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-packagingcharges *  wa_purchinvlines-ratesgst ) / 100 ).
              ENDIF.

              IF ( wa_purchinvlines-ratecgst + wa_purchinvlines-ratesgst + wa_purchinvlines-rateigst +
                   wa_purchinvlines-ratendigst + wa_purchinvlines-ratendcgst + wa_purchinvlines-ratendsgst ) NE 0.

                lv_deliverycostamount       +=  wa_purchinvlines-packagingcharges.

              ENDIF.

            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZLDV'  .
*                           Load Charges
              wa_purchinvlines-loadingcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSEIF wasublinesNp-SuplrInvcDeliveryCostCndnType = 'ZULV'  .
*                           UnLoad Charges
              wa_purchinvlines-unloadingcharges += wasublinesNp-SupplierInvoiceItemAmount.
            ELSE.
              wa_purchinvlines-othercharges += wasublinesNp-SupplierInvoiceItemAmount.

              IF wa_purchinvlines-ratendigst IS NOT INITIAL .
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-othercharges *  wa_purchinvlines-ratendigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratendcgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-othercharges *  wa_purchinvlines-ratendcgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-othercharges *  wa_purchinvlines-ratendsgst ) / 100 ).
              ELSEIF wa_purchinvlines-rateigst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-othercharges *  wa_purchinvlines-rateigst ) / 100 ).
              ELSEIF wa_purchinvlines-ratecgst IS NOT INITIAL.
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-othercharges *  wa_purchinvlines-ratecgst ) / 100 ).
                wa_purchinvlines-taxamount = wa_purchinvlines-taxamount + ( ( wa_purchinvlines-othercharges *  wa_purchinvlines-ratesgst ) / 100 ).
              ENDIF.

              IF ( wa_purchinvlines-ratecgst + wa_purchinvlines-ratesgst + wa_purchinvlines-rateigst +
                   wa_purchinvlines-ratendigst + wa_purchinvlines-ratendcgst + wa_purchinvlines-ratendsgst ) NE 0.
                lv_deliverycostamount       +=  wa_purchinvlines-othercharges.

              ENDIF.
            ENDIF.
          ENDLOOP.

          SELECT FROM  i_purorditmpricingelementapi01 AS a
          INNER JOIN I_PurchaseOrderItemAPI01 AS b ON a~PurchaseOrder = b~PurchaseOrder
          AND a~PurchaseOrderItem = b~PurchaseOrderItem
          FIELDS a~conditioncurrency , a~ConditionAmount , b~PurchaseOrder
          WHERE b~PurchaseOrder = @walinesNp-PurchaseOrder
          AND b~PurchaseOrderItem = @walinesNp-PurchaseOrderItem
          AND a~ConditionType IN ( 'ZDCP' , 'ZDCV' , 'ZCD1' , 'ZDCQ' )
          INTO TABLE @DATA(it_discount2Np).
          LOOP AT it_discount2Np INTO DATA(waDiscountNp).
*                   DIscount
            wa_purchinvlines-discount += waDiscountNp-ConditionAmount.
          ENDLOOP.

*               //For TransactionType
          SELECT FROM  i_purchaseorderhistoryapi01 AS a
          FIELDS a~PurchasingHistoryDocument , a~PurchasingHistoryCategory , a~PurchaseOrder, a~DebitCreditCode, a~ReferenceDocument
          WHERE a~PurchaseOrder = @walinesNp-PurchaseOrder
          AND a~PurchasingHistoryDocument = @walinesNp-SupplierInvoice
          AND a~PurchasingHistoryDocumentItem = @walinesNp-SupplierInvoiceItem
          AND a~PurchasingHistoryCategory IN ( 'N' , 'Q' )
          INTO TABLE @DATA(it_transtypeNp).
          LOOP AT it_transtypeNp INTO DATA(waTransTypeNp).
*                   Transaction Type

            IF waTransTypeNp-PurchasingHistoryCategory = 'Q' AND wa_purchinvlines-purchaseordertype NE 'ZRET'.
              wa_purchinvlines-transactiontype = 'Invoice'.

            ELSEIF waTransTypeNp-PurchasingHistoryCategory = 'Q' AND wa_purchinvlines-purchaseordertype = 'ZRET'.

              IF waTransTypeNp-PurchasingHistoryCategory = 'Q' AND waTransTypeNp-DebitCreditCode = 'H'.
                wa_purchinvlines-transactiontype = 'Debit Note'.

              ELSEIF waTransTypeNp-PurchasingHistoryCategory = 'Q' AND waTransTypeNp-DebitCreditCode = 'S'.
                wa_purchinvlines-transactiontype = 'Credit Note'.
              ENDIF.

            ELSE.
              IF waTransTypeNp-PurchasingHistoryCategory = 'N' AND waTransTypeNp-DebitCreditCode = 'H'.
                wa_purchinvlines-transactiontype = 'Debit Note'.
              ELSEIF waTransTypeNp-PurchasingHistoryCategory = 'N' AND waTransTypeNp-DebitCreditCode = 'S'.
                wa_purchinvlines-transactiontype = 'Credit Note'.
              ENDIF.
            ENDIF.
          ENDLOOP.


          wa_purchinvlines-invoicingpartycodename = | { waheader-Supplier } - { waheader-SupplierName } |.
*           //For Reverse Document

          wa_purchinvlines-referencedocumentno = waheader-revdoc .
          wa_purchinvlines-DeliveryCost = wa_purchinvlines-freight +
                                        wa_purchinvlines-insurance11 + wa_purchinvlines-ecs +
                                        wa_purchinvlines-epf + wa_purchinvlines-othercharges +
                                        wa_purchinvlines-packaging + wa_purchinvlines-oceanfreightcharges +
                                        wa_purchinvlines-carrierhandcharges + wa_purchinvlines-commissioncharges +
                                        wa_purchinvlines-customdutycharges + wa_purchinvlines-demmuragecharges +
                                        wa_purchinvlines-forlandcharges + wa_purchinvlines-inlandcharges +
                                        wa_purchinvlines-loadingcharges + wa_purchinvlines-socialwelfarecharges +
                                        wa_purchinvlines-unloadingcharges +
                                        wa_purchinvlines-packagingcharges .

          wa_purchinvlines-totalamount    = wa_purchinvlines-taxamount + wa_purchinvlines-netamount + wa_purchinvlines-DeliveryCost +
                                       wa_purchinvlines-rcmcgst + wa_purchinvlines-rcmsgst
                                       + wa_purchinvlines-rcmigst .

*          wa_purchinvlines-netamount += lv_deliverycostamount.
          APPEND wa_purchinvlines TO lt_purchinvlines.
*        ********************* Added on 08.02.2025
          MODIFY zpurchinvlines FROM @wa_purchinvlines.
          CLEAR : wa_poNp, wa_taxNp, lv_taxitemacctgdocitemrefNp, it_discount2Np, wa_purchinvlines, waTransTypeNp ,  it_transtypeNp.
        ENDLOOP.
      ENDIF.

      wa_purchinvprocessed-client = sy-mandt.
      wa_purchinvprocessed-supplierinvoice = waheader-SupplierInvoice.
      wa_purchinvprocessed-companycode = waheader-CompanyCode.
      wa_purchinvprocessed-fiscalyearvalue = waheader-FiscalYear.
      wa_purchinvprocessed-supplierinvoicewthnfiscalyear = waheader-SupplierInvoiceWthnFiscalYear.
      wa_purchinvprocessed-creationdatetime = lv_timestamp.
************************************** Header Level Fields Added *******************************
      wa_purchinvlines-plantadr = waheader-AddressID.

      APPEND wa_purchinvprocessed TO lt_purchinvprocessed.
********************** Added on 08.02.2025
      MODIFY zpurchinvproc FROM @wa_purchinvprocessed.
      COMMIT WORK.

      CLEAR : ltlines, it_product, it_po, it_grn, it_tax, it_discount1, wa_purchinvprocessed, lt_purchinvprocessed, lt_purchinvlines. ", it_charges.
    ENDLOOP.






*********** For Non-Product Entries

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    LEFT JOIN I_SupplierInvoiceAPI01 AS b ON a~SupplierInvoice = b~SupplierInvoice AND a~FiscalYear = b~FiscalYear
    LEFT JOIN I_Supplier AS c ON b~InvoicingParty = c~Supplier
    FIELDS a~SupplierInvoice, a~SupplierInvoiceItem, a~FiscalYear , a~PurchaseOrderItem,
    a~PurchaseOrder, a~SupplierInvoiceItemAmount, a~taxcode, a~Plant,
    a~FreightSupplier, a~TaxJurisdiction, a~SuplrInvcDeliveryCostCndnType,
    a~PurchaseOrderItemMaterial AS material, a~QuantityInPurchaseOrderUnit, a~QtyInPurchaseOrderPriceUnit,
    a~PurchaseOrderQuantityUnit, a~PurchaseOrderPriceUnit, a~ReferenceDocument , a~ReferenceDocumentFiscalYear,
    b~CompanyCode, b~SupplierInvoiceIDByInvcgParty, b~PostingDate, b~DocumentDate, b~ReverseDocument,
    c~Supplier, c~TaxNumber3, c~SupplierFullName
    INTO TABLE @DATA(it_lines_nonproduct).

    DATA wa_pur_delivery_line TYPE zpurchinvlines.

    LOOP AT it_lines_nonproduct INTO DATA(wa_nonproduct) WHERE SuplrInvcDeliveryCostCndnType IS NOT INITIAL. "AND SupplierInvoice = '5105600317'.

      READ TABLE it_lines_nonproduct INTO DATA(wa_nonproduct2) WITH KEY SupplierInvoice = wa_nonproduct-SupplierInvoice
                                                                        FiscalYear = wa_nonproduct-FiscalYear
                                                                        SuplrInvcDeliveryCostCndnType = ''.
      IF wa_nonproduct2 IS INITIAL.
        wa_pur_delivery_line-SupplierInvoice      = wa_nonproduct-SupplierInvoice.
        wa_pur_delivery_line-SupplierInvoiceItem  = wa_nonproduct-SupplierInvoiceItem.
        wa_pur_delivery_line-fiscalyearvalue      = wa_nonproduct-FiscalYear.
        wa_pur_delivery_line-CompanyCode          = wa_nonproduct-CompanyCode.
        wa_pur_delivery_line-plant                = wa_nonproduct-Plant.
        wa_pur_delivery_line-plantcode            = wa_nonproduct-Plant.
        wa_pur_delivery_line-supplierbillno       = wa_nonproduct-SupplierInvoiceIDByInvcgParty.
        wa_pur_delivery_line-vendor_invoice_date  = wa_nonproduct-DocumentDate.
        wa_pur_delivery_line-postingdate          = wa_nonproduct-PostingDate.
        wa_pur_delivery_line-purchaseorder        = wa_nonproduct-PurchaseOrder.
        wa_pur_delivery_line-purchaseorderitem    = wa_nonproduct-PurchaseOrderItem.
        wa_pur_delivery_line-product              = wa_nonproduct-material.
        wa_pur_delivery_line-taxableamount        = wa_nonproduct-SupplierInvoiceItemAmount.
        wa_pur_delivery_line-suppliercode         = wa_nonproduct-Supplier.
        wa_pur_delivery_line-supp_gst             = wa_nonproduct-TaxNumber3.
        wa_pur_delivery_line-suppliercodename     = wa_nonproduct-SupplierFullName.
        wa_pur_delivery_line-miro_item_type       = 'Delivery Cost Entry'.
        wa_pur_delivery_line-transactiontype      = 'Invoice'.
        wa_pur_delivery_line-originalreferencedocument      = |{ wa_nonproduct-SupplierInvoice }{ wa_nonproduct-FiscalYear }|.

        IF wa_nonproduct-ReverseDocument IS NOT INITIAL.
          wa_pur_delivery_line-isreversed = 'X'.
        ENDIF.

        READ TABLE it_zplant INTO DATA(wa_zplant) WITH KEY plant_code = wa_nonproduct-Plant.
        IF wa_zplant IS NOT INITIAL.
          wa_pur_delivery_line-plantgst       = wa_zplant-gstin_no.
          wa_pur_delivery_line-plantname      = |{ wa_zplant-plant_name1 } { wa_zplant-plant_name2 } |.
          wa_pur_delivery_line-plantadr       = |{ wa_zplant-address1 } { wa_zplant-address2 } { wa_zplant-address3 } |.
          wa_pur_delivery_line-profitcenter   = wa_zplant-profitcenter.
          wa_pur_delivery_line-plantcity      = wa_zplant-city.
          wa_pur_delivery_line-plantpin       = wa_zplant-pin.
        ENDIF.

        READ TABLE it_taxcodename INTO DATA(wa_taxname) WITH KEY TaxCode = wa_nonproduct-TaxCode.
        IF wa_taxname IS NOT INITIAL.
          wa_pur_delivery_line-taxcodename = wa_taxname-TaxCodeName.
        ENDIF.

        READ TABLE it_productdesc INTO DATA(wa_productdesc) WITH KEY Product = wa_nonproduct-material.
        IF wa_productdesc IS NOT INITIAL.
          wa_pur_delivery_line-productname = wa_productdesc-ProductName.
        ENDIF.

        READ TABLE it_taxrates INTO DATA(wa_taxrate_jii) WITH KEY TaxCode = wa_nonproduct-TaxCode AccountKeyForGLAccount = 'JII'.
        IF wa_taxrate_jii IS NOT INITIAL.
          wa_pur_delivery_line-rateigst  = wa_taxrate_jii-ConditionRateRatio.
          wa_pur_delivery_line-igst      = wa_nonproduct-SupplierInvoiceItemAmount * wa_taxrate_jii-ConditionRateRatio  / 100.
        ENDIF.
        READ TABLE it_taxrates INTO DATA(wa_taxrate_jis) WITH KEY TaxCode = wa_nonproduct-TaxCode AccountKeyForGLAccount = 'JIS'.
        IF wa_taxrate_jis IS NOT INITIAL.
          wa_pur_delivery_line-ratecgst  = wa_taxrate_jis-ConditionRateRatio.
          wa_pur_delivery_line-ratesgst  = wa_taxrate_jis-ConditionRateRatio.
          wa_pur_delivery_line-cgst      = wa_nonproduct-SupplierInvoiceItemAmount * wa_taxrate_jis-ConditionRateRatio  / 100.
          wa_pur_delivery_line-sgst      = wa_nonproduct-SupplierInvoiceItemAmount * wa_taxrate_jis-ConditionRateRatio  / 100.
        ENDIF.

        wa_pur_delivery_line-taxamount   =  wa_pur_delivery_line-igst + wa_pur_delivery_line-cgst + wa_pur_delivery_line-sgst.
        wa_pur_delivery_line-totalamount =  wa_nonproduct-SupplierInvoiceItemAmount + wa_pur_delivery_line-taxamount.
        wa_pur_delivery_line-netamount   =  wa_pur_delivery_line-totalamount.

        MODIFY zpurchinvlines FROM @wa_pur_delivery_line.
      ENDIF.
      CLEAR: wa_nonproduct2, wa_pur_delivery_line, wa_taxname, wa_taxrate_jii, wa_taxrate_jis, wa_zplant, wa_productdesc.
    ENDLOOP.






********** For G/L Account Entries

    DATA wa_pur_gl_line TYPE zpurchinvlines.

    SELECT FROM I_SuplrInvoiceItemGLAcctAPI01 AS a
    LEFT JOIN I_SupplierInvoiceAPI01 AS b ON a~SupplierInvoice = b~SupplierInvoice AND a~FiscalYear = b~FiscalYear
    LEFT JOIN I_Supplier AS c ON b~InvoicingParty = c~Supplier
    FIELDS a~SupplierInvoice, a~SupplierInvoiceItem, a~FiscalYear, a~CompanyCode, a~ProfitCenter,
    a~GLAccount, a~SupplierInvoiceItemAmount, a~TaxCode, b~BusinessPlace, b~PostingDate,
    b~SupplierInvoiceIDByInvcgParty, b~DocumentDate, b~ReverseDocument, b~SupplierInvoiceWthnFiscalYear,
    b~isinvoice, c~Supplier, c~TaxNumber3, c~SupplierFullName
    WHERE a~GLAccount IS NOT INITIAL
    INTO TABLE @DATA(it_gltab) PRIVILEGED ACCESS.

    LOOP AT it_gltab INTO DATA(wa_gltab).
      wa_pur_gl_line-companycode         = wa_gltab-CompanyCode.
      wa_pur_gl_line-fiscalyearvalue     = wa_gltab-FiscalYear.
      wa_pur_gl_line-supplierinvoice     = wa_gltab-SupplierInvoice.
      wa_pur_gl_line-supplierinvoiceitem = wa_gltab-SupplierInvoiceItem + 1000 .
      wa_pur_gl_line-plant               = wa_gltab-BusinessPlace.
      wa_pur_gl_line-plantcode           = wa_gltab-BusinessPlace.
      wa_pur_gl_line-postingdate         = wa_gltab-PostingDate.
      wa_pur_gl_line-product             = wa_gltab-GLAccount.
      wa_pur_gl_line-taxableamount       = wa_gltab-SupplierInvoiceItemAmount.
      wa_pur_gl_line-netamount           = wa_gltab-SupplierInvoiceItemAmount.
      wa_pur_gl_line-suppliercode        = wa_gltab-Supplier.
      wa_pur_gl_line-supp_gst            = wa_gltab-TaxNumber3.
      wa_pur_gl_line-suppliercodename    = wa_gltab-SupplierFullName.
      wa_pur_gl_line-supplierbillno      = wa_gltab-SupplierInvoiceIDByInvcgParty.
      wa_pur_gl_line-vendor_invoice_date = wa_gltab-DocumentDate.
      wa_pur_gl_line-profitcenter        = wa_gltab-ProfitCenter.
      wa_pur_gl_line-miro_item_type      = 'G/L Account Entry'.
      wa_pur_gl_line-transactiontype     = 'Invoice'.
      wa_pur_gl_line-originalreferencedocument     = |{ wa_gltab-SupplierInvoice }{ wa_gltab-FiscalYear }| .

      IF wa_gltab-ReverseDocument IS NOT INITIAL.
        wa_pur_gl_line-isreversed = 'X'.
      ENDIF.

      lv_signval = 1.
*        //For TransactionType
      READ TABLE it_transtype INTO DATA(wa_transtype2) WITH KEY PurchasingHistoryDocument = wa_gltab-SupplierInvoice.

      READ TABLE it_journalentry INTO DATA(wa_journalentry2) WITH KEY OriginalReferenceDocument = wa_gltab-SupplierInvoiceWthnFiscalYear.
      IF wa_journalentry2 IS NOT INITIAL.
        IF ( wa_gltab-IsInvoice = 'X' AND wa_journalentry2-IsReversal IS INITIAL
            AND wa_transtype2-PurchasingHistoryCategory = 'Q' AND wa_transtype2-DebitCreditCode = 'S' ) OR
           ( wa_gltab-IsInvoice = 'X' AND wa_journalentry2-IsReversed IS INITIAL AND wa_transtype2 IS INITIAL ).
          wa_pur_gl_line-transactiontype = 'Invoice'.
        ELSEIF wa_gltab-IsInvoice IS INITIAL AND wa_journalentry2-IsReversal = 'X' AND
               wa_transtype2-PurchasingHistoryCategory = 'Q' AND wa_transtype2-DebitCreditCode = 'H' .
          wa_pur_gl_line-transactiontype = 'Invoice'.
          lv_signval = -1.
        ELSEIF ( wa_gltab-IsInvoice IS INITIAL AND wa_journalentry2-IsReversal IS INITIAL ) OR
               ( wa_gltab-IsInvoice IS INITIAL AND wa_journalentry2-IsReversal = 'X' AND wa_transtype2 IS INITIAL ).
          wa_pur_gl_line-transactiontype = 'Debit Note'.    "credit memo
          lv_signval = -1.
        ELSEIF wa_gltab-IsInvoice = 'X' AND wa_journalentry2-IsReversal = 'X'.
          wa_pur_gl_line-transactiontype = 'Debit Note'.
        ELSEIF wa_gltab-IsInvoice = 'X' AND wa_journalentry2-IsReversal IS INITIAL AND
               wa_transtype2-PurchasingHistoryCategory = 'N' AND wa_transtype2-DebitCreditCode = 'S'.
          wa_pur_gl_line-transactiontype = 'Credit Memo'.
        ELSEIF wa_gltab-IsInvoice IS INITIAL AND wa_journalentry2-IsReversal = 'X' AND
               wa_transtype2-PurchasingHistoryCategory = 'N' AND wa_transtype2-DebitCreditCode = 'H'.
          wa_pur_gl_line-transactiontype = 'Credit Memo'.
          lv_signval = -1.
        ENDIF.
      ENDIF.

      READ TABLE it_zplant INTO DATA(wa_zplant2) WITH KEY plant_code = wa_gltab-BusinessPlace.
      IF wa_zplant2 IS NOT INITIAL.
        wa_pur_gl_line-plantgst       = wa_zplant2-gstin_no.
        wa_pur_gl_line-plantname      = |{ wa_zplant2-plant_name1 } { wa_zplant2-plant_name2 } |.
        wa_pur_gl_line-plantadr       = |{ wa_zplant2-address1 } { wa_zplant2-address2 } { wa_zplant2-address3 } |.
        wa_pur_gl_line-plantpin       =  wa_zplant2-pin.
        wa_pur_gl_line-plantcity      =  wa_zplant2-city.
      ENDIF.

      READ TABLE it_taxcodename INTO DATA(wa_taxnames) WITH KEY TaxCode = wa_gltab-TaxCode.
      IF wa_taxnames IS NOT INITIAL.
        wa_pur_gl_line-taxcodename = wa_taxnames-TaxCodeName.
      ENDIF.

      READ TABLE it_taxrates INTO DATA(wa_taxrates) WITH KEY TaxCode = wa_gltab-TaxCode.
      IF wa_taxrates IS NOT INITIAL.
        CASE wa_taxrates-AccountKeyForGLAccount.
          WHEN 'JII'.
            wa_pur_gl_line-rateigst             = wa_taxrates-ConditionRateRatio.
            wa_pur_gl_line-igst                 = wa_gltab-SupplierInvoiceItemAmount * wa_taxrates-ConditionRateRatio  / 100.
          WHEN 'JIS'.
            wa_pur_gl_line-ratecgst             = wa_taxrates-ConditionRateRatio.
            wa_pur_gl_line-ratesgst             = wa_taxrates-ConditionRateRatio.
            wa_pur_gl_line-cgst                 = wa_gltab-SupplierInvoiceItemAmount * wa_taxrates-ConditionRateRatio  / 100.
            wa_pur_gl_line-sgst                 = wa_gltab-SupplierInvoiceItemAmount * wa_taxrates-ConditionRateRatio  / 100.
        ENDCASE.
        IF wa_taxrates-accountkeyforglaccount = 'NVV'.
          CASE wa_taxrates-vatconditiontype+0(3).
            WHEN 'JII'.
              wa_pur_gl_line-ratendigst             = wa_taxrates-conditionrateratio.
              wa_pur_gl_line-ndigst                 = wa_gltab-supplierinvoiceitemamount * wa_taxrates-conditionrateratio  / 100.
            WHEN 'JIS' OR 'JIC'.
              wa_pur_gl_line-ratendcgst             = wa_taxrates-conditionrateratio.
              wa_pur_gl_line-ratendsgst             = wa_taxrates-conditionrateratio.
              wa_pur_gl_line-ndcgst                 = wa_gltab-supplierinvoiceitemamount * wa_taxrates-conditionrateratio  / 100.
              wa_pur_gl_line-ndsgst                 = wa_gltab-supplierinvoiceitemamount * wa_taxrates-conditionrateratio  / 100.
          ENDCASE.
        ENDIF.
      ENDIF.

      wa_pur_gl_line-taxamount                  =  wa_pur_gl_line-igst + wa_pur_gl_line-cgst + wa_pur_gl_line-sgst +
                                                   wa_pur_gl_line-ndigst + wa_pur_gl_line-ndcgst + wa_pur_gl_line-ndsgst..
      wa_pur_gl_line-totalamount                =  wa_gltab-SupplierInvoiceItemAmount + wa_pur_gl_line-taxamount.
      IF lv_signval < 0.
        wa_pur_gl_line-discount                *= lv_signval.
        wa_pur_gl_line-DeliveryCost            *= lv_signval.
        wa_pur_gl_line-freight                 *= lv_signval.
        wa_pur_gl_line-insurance11             *= lv_signval.
        wa_pur_gl_line-ecs                     *= lv_signval.
        wa_pur_gl_line-epf                     *= lv_signval.
        wa_pur_gl_line-othercharges            *= lv_signval.
        wa_pur_gl_line-oceanfreightcharges     *= lv_signval.
        wa_pur_gl_line-packaging               *= lv_signval.
        wa_pur_gl_line-carrierhandcharges      *= lv_signval.
        wa_pur_gl_line-commissioncharges       *= lv_signval.
        wa_pur_gl_line-customdutycharges       *= lv_signval.
        wa_pur_gl_line-demmuragecharges        *= lv_signval.
        wa_pur_gl_line-forlandcharges          *= lv_signval.
        wa_pur_gl_line-inlandcharges           *= lv_signval.
        wa_pur_gl_line-socialwelfarecharges    *= lv_signval.
        wa_pur_gl_line-loadingcharges          *= lv_signval.
        wa_pur_gl_line-unloadingcharges        *= lv_signval.
        wa_pur_gl_line-packagingcharges        *= lv_signval.
        wa_pur_gl_line-netamount               *= lv_signval.
        wa_pur_gl_line-taxableamount           *= lv_signval.
        wa_pur_gl_line-igst                    *= lv_signval.
        wa_pur_gl_line-cgst                    *= lv_signval.
        wa_pur_gl_line-sgst                    *= lv_signval.
        wa_pur_gl_line-taxamount               *= lv_signval.
        wa_pur_gl_line-totalamount             *= lv_signval.
        wa_pur_gl_line-poqty                   *= lv_signval.
        wa_pur_gl_line-mrnquantityinbaseunit   *= lv_signval.
      ENDIF.

      MODIFY zpurchinvlines FROM @wa_pur_gl_line.
      CLEAR: wa_pur_gl_line, wa_taxrates, wa_taxnames, wa_zplant2, lv_signval, wa_journalentry2, wa_transtype2.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
