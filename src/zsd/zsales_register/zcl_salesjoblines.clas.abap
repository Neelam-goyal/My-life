CLASS zcl_salesjoblines DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .
    METHODS Salesregister.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SALESJOBLINES IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
       ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'My ID'                                      changeable_ind = abap_true )
       ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'My Description'   lowercase_ind = abap_true changeable_ind = abap_true )
       ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     datatype = 'I' length = 10 param_text = 'My Count'                                   changeable_ind = abap_true )
       ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length =  1 param_text = 'My Simulate Only' checkbox_ind = abap_true  changeable_ind = abap_true )
     ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '4711' )
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'My Default Description' )
      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 200 )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'X' )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    TYPES ty_id TYPE c LENGTH 10.

    DATA s_id    TYPE RANGE OF ty_id.
    DATA p_descr TYPE c LENGTH 80.
    DATA p_count TYPE i.
    DATA p_simul TYPE abap_boolean.

    DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
    DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
    DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA: template  TYPE cl_apj_rt_api=>ty_template_name.

    DATA: lt_billinglines     TYPE TABLE OF zbillinglines,
          wa_billinglines     TYPE zbillinglines,
          lt_billingprocessed TYPE STANDARD TABLE OF zbillingproc,
          wa_billingprocessed TYPE zbillingproc.
    DATA: lt_cancelled TYPE TABLE OF zbillinglines.
    DATA: wa_cancelled TYPE zbillinglines.

    DATA maxBillingDate TYPE d.
    DATA deleteString TYPE c LENGTH 4.
    DATA: lv_tstamp TYPE timestamp, lv_date TYPE d, lv_time TYPE t, lv_dst TYPE abap_bool.


    GET TIME STAMP FIELD lv_tstamp.
    CONVERT TIME STAMP lv_tstamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time DAYLIGHT SAVING TIME lv_dst.

    deleteString = |{ lv_date+6(2) }| && |{ lv_time+0(2) }|.


    SELECT FROM zbillinglines
      FIELDS MAX( invoicedate )
      WHERE invoice IS NOT INITIAL
      INTO @maxBillingDate .
    IF maxBillingDate IS INITIAL.
      maxBillingDate = 20010101.
    ELSE.
      maxBillingDate = maxBillingDate - 30.
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_timestamp).

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
      DELETE FROM zbillingproc WHERE billingdocument IS NOT INITIAL.
      DELETE FROM zbillinglines WHERE invoice IS NOT INITIAL.
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
        CLEAR jobcount.
    ENDTRY.
    salesregister( ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    salesregister( ).
  ENDMETHOD.


  METHOD Salesregister.
*  delete from zbillinglines where invoice is not initial.
*  delete from zbillingproc where billingdocument is not initial.
    TYPES ty_id TYPE c LENGTH 10.

    DATA s_id    TYPE RANGE OF ty_id.
    DATA p_descr TYPE c LENGTH 80.
    DATA p_count TYPE i.
    DATA p_simul TYPE abap_boolean.

    DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
    DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
    DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA: template  TYPE cl_apj_rt_api=>ty_template_name.

    DATA: lt_billinglines     TYPE TABLE OF zbillinglines,
          wa_billinglines     TYPE zbillinglines,
          lt_billingprocessed TYPE STANDARD TABLE OF zbillingproc,
          wa_billingprocessed TYPE zbillingproc.
    DATA: lt_cancelled TYPE TABLE OF zbillinglines.
    DATA: wa_cancelled TYPE zbillinglines.

    DATA maxBillingDate TYPE d.
    DATA deleteString TYPE c LENGTH 4.
    DATA: lv_tstamp TYPE timestamp, lv_date TYPE d, lv_time TYPE t, lv_dst TYPE abap_bool.


    GET TIME STAMP FIELD lv_tstamp.
    CONVERT TIME STAMP lv_tstamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time DAYLIGHT SAVING TIME lv_dst.

    deleteString = |{ lv_date+6(2) }| && |{ lv_time+0(2) }|.


    SELECT FROM zbillinglines
      FIELDS MAX( invoicedate )
      WHERE invoice IS NOT INITIAL
      INTO @maxBillingDate .
    IF maxBillingDate IS INITIAL.
      maxBillingDate = 20010101.
    ELSE.
      maxBillingDate = maxBillingDate - 60.
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    IF deleteString = p_descr+7(4).
      DELETE FROM zbillingproc WHERE billingdocument IS NOT INITIAL.
      DELETE FROM zbillinglines WHERE invoice IS NOT INITIAL.
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
        CLEAR jobcount.
    ENDTRY.
    SELECT FROM I_BillingDocument AS header
    JOIN I_BillingDocumentitem AS a ON header~BillingDocument = a~BillingDocument
    LEFT JOIN i_salesdocument AS b ON a~salesdocument = b~SalesDocument
    LEFT JOIN i_salesquotation AS c ON a~ReferenceSDDocument = c~ReferenceSDDocument
    LEFT JOIN i_salesdocumentpartner AS d ON a~salesdocument = d~salesdocument AND d~PartnerFunction = 'AP'
    LEFT JOIN i_customer AS e ON header~SoldToParty = e~Customer AND e~Language = 'E'
    LEFT JOIN I_RegionText AS f ON e~Region = f~Region AND e~Country = f~Country AND f~Language = 'E'
    LEFT JOIN i_deliverydocument AS g ON a~ReferenceSDDocument = g~DeliveryDocument

      FIELDS header~BillingDocument,  header~BillingDocumentType, header~Division, header~BillingDocumentDate, header~BillingDocumentIsCancelled,
              header~CompanyCode, header~FiscalYear, header~AccountingDocument, header~SoldToParty, header~CustomerGroup,header~SalesDistrict,header~SalesOrganization,
              header~DocumentReferenceID,
              b~referencesddocument,
              c~CreationDate,
              d~FullName,
              a~salesdocument,
              b~SalesDocumentDate AS sales_creationdate,
              b~purchaseorderbycustomer,
              e~TaxNumber3,
              e~customername,
              a~referencesddocument AS d_referencesddocument,
              g~CreationDate AS delivery_creationdate,
              a~plant,
              f~RegionName,
              e~Region AS customer_region,
              f~Region AS regiontext

      WHERE header~BillingDocumentDate >= @maxbillingdate AND  NOT EXISTS (
               SELECT BillingDocument FROM zbillingproc
               WHERE header~BillingDocument = zbillingproc~BillingDocument AND
                 header~CompanyCode = zbillingproc~bukrs AND
                 header~FiscalYear = zbillingproc~fiscalyearvalue )
      INTO TABLE @DATA(ltheader).
    SORT ltheader BY BillingDocument ASCENDING.
    DELETE ADJACENT DUPLICATES FROM ltheader COMPARING BillingDocument.
    SELECT FROM I_BillingDocument AS header
    LEFT JOIN I_BillingDocItemPartner AS h ON header~BillingDocument = h~BillingDocument AND h~PartnerFunction = 'WE'
    JOIN I_BillingDocumentitem AS a ON header~BillingDocument = a~BillingDocument
    LEFT JOIN i_salesdocument AS b ON a~salesdocument = b~SalesDocument
    LEFT JOIN i_salesquotation AS c ON a~ReferenceSDDocument = c~ReferenceSDDocument
    LEFT JOIN i_salesdocumentpartner AS d ON a~salesdocument = d~salesdocument AND d~PartnerFunction = 'AP'
    LEFT JOIN i_customer AS e ON a~ShipToParty = e~Customer AND e~language = 'E'
    LEFT JOIN I_RegionText AS g ON e~Region = g~Region AND e~Country = g~Country AND g~Language = 'E'
    LEFT JOIN I_SALESDOCUMENTitem AS f ON a~salesdocument = f~SalesDocument AND a~SalesDocumentItem = f~SalesDocumentItem
      FIELDS
      header~BillingDocument,
      header~BillingDocumentType,
      e~TaxNumber3,
      h~Customer AS shiptoparty,
      e~CustomerName AS ship_customername,
      e~taxnumber3 AS ship_taxnumber3,
      g~RegionName AS ship_regionname
    WHERE header~BillingDocumentDate >= @maxbillingdate AND  NOT EXISTS (
           SELECT BillingDocument FROM zbillingproc
           WHERE header~BillingDocument = zbillingproc~BillingDocument AND
             header~CompanyCode = zbillingproc~bukrs AND
             header~FiscalYear = zbillingproc~fiscalyearvalue )
    INTO TABLE @DATA(ltheader_ship).
    SORT ltheader_ship BY BillingDocument ASCENDING.

*   SORT ltheader_ship BY BillingDocument.
    DELETE ADJACENT DUPLICATES FROM ltheader_ship COMPARING BillingDocument.

    LOOP AT ltheader INTO DATA(wa).
      DELETE FROM zbillinglines
          WHERE zbillinglines~companycode = @wa-CompanyCode AND
          zbillinglines~fiscalyearvalue = @wa-FiscalYear AND
          zbillinglines~invoice = @wa-BillingDocument.
      READ TABLE ltheader_ship INTO DATA(wa_ship) WITH KEY BillingDocument = wa-BillingDocument.
      wa_billingprocessed-billingdocument = wa-BillingDocument.
      wa_billingprocessed-bukrs = wa-CompanyCode.
      wa_billingprocessed-fiscalyearvalue = wa-FiscalYear.
      wa_billingprocessed-creationdatetime = lv_timestamp.
*******************************************      add
      IF wa-BillingDocumentType <> 'F8'.
        SELECT FROM I_BillingDocumentItem AS item
                   LEFT JOIN I_ProductDescription AS pd ON item~Product = pd~Product AND pd~LanguageISOCode = 'EN'
                   LEFT JOIN I_BillingDocumentitem AS a ON item~BillingDocument = a~BillingDocument AND item~BillingDocumentItem = a~BillingDocumentItem
                   LEFT JOIN I_SalesDocumentItem AS b ON a~product = b~Material AND a~salesdocument = b~SalesDocument AND a~SalesDocumentItem = b~SalesDocumentItem
                   LEFT JOIN i_productplantbasic AS c ON a~Product = c~Product
                   LEFT JOIN I_ProductGroupText_2 AS d ON item~productgroup = d~ProductGroup AND d~Language = 'E'
                   LEFT JOIN i_billingdocument AS e ON a~BillingDocument = e~BillingDocument
                   LEFT JOIN I_DivisionText AS f ON item~division = f~Division AND f~Language = 'E'
                   LEFT JOIN I_DistributionChannelText AS g ON item~distributionchannel = g~DistributionChannel AND g~Language = 'E'
                   FIELDS item~BillingDocument, item~BillingDocumentItem
                        ,item~Plant, item~ProfitCenter, item~Product,
                        item~BillingQuantity, item~BaseUnit,
                        item~BillingQuantityUnit, item~NetAmount,
                        item~TaxAmount, item~TransactionCurrency, item~CancelledBillingDocument, item~BillingQuantityinBaseUnit,
                        item~ProductGroup,item~Division , item~DistributionChannel ,
                        item~ItemGrossWeight, item~ItemNetWeight,
                        pd~ProductDescription,
                        c~consumptiontaxctrlcode,
                        e~accountingexchangerate,
                        b~MaterialByCustomer,
                        d~ProductGroupName,
                        f~DivisionName,
                        g~DistributionChannelName
                      WHERE item~BillingDocument = @wa-BillingDocument AND consumptiontaxctrlcode IS NOT INITIAL
                      INTO TABLE @DATA(ltlines).



*    ************************************************************************************************************************************
        SELECT FROM I_BillingDocument AS a
        LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
        LEFT JOIN I_BillingDocumentitem AS d ON a~BillingDocument = d~BillingDocument
        LEFT JOIN i_customer AS c ON c~customer = b~Customer
        FIELDS c~TaxNumber3 , d~BillingDocumentItem , a~BillingDocument
        WHERE a~BillingDocument = @wa-BillingDocument
        INTO TABLE @DATA(lt_taxexempted).

        SORT lt_taxexempted BY billingdocument billingdocumentitem.
        DELETE ADJACENT DUPLICATES FROM lt_taxexempted COMPARING billingdocument billingdocumentitem.

*    ************************************************************************************************************************************
*    *Brand

        SELECT FROM I_BillingDocumentItem AS a
        LEFT JOIN i_product AS b ON a~Product = b~Product
        LEFT JOIN zmaster_tab WITH PRIVILEGED ACCESS AS c ON b~YY1_brandcode_PRD = c~brandcode
        FIELDS
        b~YY1_brandcode_PRD ,
        a~BillingDocument,
        a~BillingDocumentItem,
        c~brandtag
        WHERE a~BillingDocument = @wa-BillingDocument
        INTO TABLE @DATA(brand).

*    ************************************************************************************************************************************
*    *UOM

        SELECT FROM I_UnitOfMeasureText FIELDS UnitOfMeasure, UnitOfMeasureTechnicalName
        WHERE Language = 'E'
        INTO TABLE @DATA(it_uom).


*    ************************************************************************************************************************************
        SORT ltlines BY BillingDocument BillingDocumentItem.
        DELETE ADJACENT DUPLICATES FROM ltlines COMPARING ALL FIELDS.
        SELECT FROM i_billingdocumentitem AS a
        INNER JOIN I_UnitOfMeasureText AS b ON a~baseunit = b~UnitOfMeasure
        FIELDS b~UnitOfMeasureTechnicalName
        WHERE a~billingdocument = @wa-BillingDocument
        INTO TABLE @DATA(lt_unit).

        SELECT FROM i_billingdocumentitemprcgelmnt FIELDS BillingDocument , BillingDocumentItem, ConditionRateValue, ConditionAmount, ConditionType,ConditionQuantity ,
          transactioncurrency AS d_transactioncurrency
          WHERE BillingDocument = @wa-BillingDocument AND ConditionInactiveReason NE 'X'
          INTO TABLE @DATA(it_price).

*    ****************************************************************************
        SELECT FROM i_deliverydocument AS b
                      LEFT JOIN i_billingdocumentitem AS a ON b~deliverydocument = a~referencesddocument
                      LEFT JOIN ztable_irn AS c ON a~billingdocument = c~billingdocno
                      FIELDS  b~actualgoodsmovementdate, a~billingdocumentItem, a~billingdocument , c~ewaydate , c~ewaybillno , c~ackno
                      WHERE a~BillingDocument = @wa-BillingDocument
                      INTO TABLE @DATA(it_delivery).

*    ****************************************************************************
        SELECT FROM ztable_irn AS a
                LEFT JOIN i_billingdocumentitem AS b ON billingdocno = b~billingdocument
                 FIELDS
                   billingdocno,
                   b~BillingDocumentItem,
                   vehiclenum,
                   transportername,
                   transportmode,
                   b~ItemNetWeight,
                   b~ItemGrossWeight,
                   grno
                   WHERE billingdocno = @wa-BillingDocument
                   INTO TABLE @DATA(it_irn).
        DATA :lv_div_concat          TYPE string,
              lv_deliverySatatcode   TYPE string,
              lv_soldtoregioncode    TYPE string,
              lv_distributionchannel TYPE string.
*    ****************************************************************************
        LOOP AT ltlines INTO DATA(wa_lines).
          wa_billinglines-invoice = wa_lines-BillingDocument.
          wa_billinglines-lineitemno = wa_lines-BillingDocumentItem.
          wa_billinglines-fiscalyearvalue = wa-FiscalYear.
          wa_billinglines-invoice = wa-BillingDocument.
          wa_billinglines-lineitemno = wa_lines-BillingDocumentItem.
          wa_billinglines-exchangerate = wa_lines-AccountingExchangeRate.
          wa_billinglines-companycode = wa-CompanyCode.
          wa_billinglines-invoicedate = wa-BillingDocumentDate.

          READ TABLE lt_taxexempted INTO DATA(wa_taxexempted) WITH KEY billingdocument = wa_lines-billingdocument
                                                                                         billingdocumentitem = wa_lines-billingdocumentitem.
          IF wa_taxexempted-TaxNumber3 IS NOT INITIAL.
            wa_billinglines-saletype = 'B2B'.
          ELSE.
            wa_billinglines-saletype = 'B2C'.
          ENDIF.

          SHIFT wa_lines-Product LEFT DELETING LEADING '0'.
          wa_billinglines-materialno = wa_lines-Product.

          SELECT SINGLE FROM i_producttaxclassification
          FIELDS TaxClassification1,
                  TaxClassification2,
                 TaxClassification3
           WHERE Product = @wa_billinglines-materialno
           INTO @DATA(wa_saletype).

          IF wa_saletype-TaxClassification1 EQ 0 AND wa_saletype-TaxClassification2 EQ 0 AND wa_saletype-TaxClassification3 EQ 0.
            wa_billinglines-taxexempted = 'Taxable'.
          ELSE.
            wa_billinglines-taxexempted = 'Tax Exempt'.
          ENDIF.

          READ TABLE it_uom INTO DATA(wa_uom) WITH KEY UnitOfMeasure = wa_lines-BaseUnit.
          IF wa_uom IS NOT INITIAL.
            wa_billinglines-uom = to_upper( wa_uom-UnitOfMeasureTechnicalName ).
            CLEAR: wa_uom.
          ELSE.
            wa_billinglines-uom = wa_lines-BaseUnit.
          ENDIF.

          wa_billinglines-materialdescription  = wa_lines-ProductDescription.
          wa_billinglines-hsncode = wa_lines-consumptiontaxctrlcode.
          wa_billinglines-materialgroup = wa_lines-ProductGroup.
          wa_billinglines-materialgroupdescription = wa_lines-ProductGroupName.

          CONCATENATE wa_lines-Division wa_lines-DivisionName INTO lv_div_concat SEPARATED BY space.
          wa_billinglines-division = lv_div_concat.
          CONCATENATE wa_lines-DistributionChannel wa_lines-DistributionChannelName INTO lv_distributionchannel SEPARATED BY space.
          wa_billinglines-distributionchannel = lv_distributionchannel.
*          wa_billinglines-uom = wa_lines-baseunit.
          wa_billinglines-actualnetweight = wa_lines-ItemNetWeight.
          wa_billinglines-grossweight = wa_lines-ItemGrossWeight.

          READ TABLE it_irn INTO DATA(wa_irn) WITH KEY billingdocno = wa_lines-billingdocument BillingDocumentItem = wa_lines-BillingDocumentItem.
          wa_billinglines-vehiclenumber = wa_irn-vehiclenum.
          wa_billinglines-tptvendorname = wa_irn-transportername.
          wa_billinglines-tptmode = wa_irn-transportmode.
          wa_billinglines-grno = wa_irn-grno.

          READ TABLE brand INTO DATA(wa_brand) WITH KEY BillingDocument = wa_lines-billingdocument  BillingDocumentItem = wa_lines-BillingDocumentItem.
          wa_billinglines-brandname = wa_brand-brandtag.
          READ TABLE it_delivery INTO DATA(wa_delivery) WITH KEY billingdocument = wa_lines-billingdocument
                                                                BillingDocumentItem = wa_lines-billingdocumentitem.
          wa_billinglines-deliverydate = wa_delivery-actualgoodsmovementdate.
          wa_billinglines-ewaydatetime = wa_delivery-ewaydate.
          wa_billinglines-ewaybillnumber = wa_delivery-ewaybillno.
          wa_billinglines-irnacknumber = wa_delivery-ackno.

          wa_billinglines-customeritemcode = wa_lines-MaterialByCustomer.

          READ TABLE it_price INTO DATA(wa_price) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZMRP'.
          wa_billinglines-mrp                  = wa_price-ConditionRateValue.
          CLEAR wa_price.

          READ TABLE it_price INTO DATA(wa_price0) WITH KEY BillingDocument = wa-BillingDocument
                                                      BillingDocumentItem = wa_lines-BillingDocumentItem
                                                      ConditionType = 'ZR00'.
          CLEAR wa_price0.

          READ TABLE it_price INTO DATA(wa_pricePPR0) WITH KEY BillingDocument = wa-BillingDocument
                                                      BillingDocumentItem = wa_lines-BillingDocumentItem
                                                      ConditionType = 'PPR0'.
          READ TABLE it_price INTO DATA(wa_priceZEXF) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZEXF'.
          READ TABLE it_price INTO DATA(wa_priceZBNP) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZBNP'.
          READ TABLE it_price INTO DATA(wa_priceZSTO) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZSTO'.
          IF wa_pricePPR0 IS NOT INITIAL.
            wa_billinglines-rate = wa_pricePPR0-ConditionRateValue / wa_priceppr0-ConditionQuantity.
            wa_billinglines-taxablevaluebeforediscount = wa_priceppr0-ConditionAmount * wa_billinglines-exchangerate.
          ELSEIF wa_priceZEXF IS NOT INITIAL.
            wa_billinglines-rate = wa_priceZEXF-ConditionRateValue / wa_priceZEXF-ConditionQuantity.
            wa_billinglines-taxablevaluebeforediscount = wa_pricezexf-ConditionAmount * wa_billinglines-exchangerate.
          ELSEIF wa_priceZBNP IS NOT INITIAL.
            wa_billinglines-rate =  wa_priceZBNP-ConditionRateValue / wa_priceZBNP-ConditionQuantity.
            wa_billinglines-taxablevaluebeforediscount = wa_pricezbnp-ConditionAmount * wa_billinglines-exchangerate.
          ELSEIF wa_priceZSTO IS NOT INITIAL.
            wa_billinglines-rate =  wa_priceZSTO-ConditionRateValue / wa_priceZSTO-ConditionQuantity.
            wa_billinglines-taxablevaluebeforediscount = wa_pricezsto-ConditionAmount * wa_billinglines-exchangerate.
          ENDIF.
          CLEAR wa_pricePPR0.
          CLEAR wa_priceZEXF.
          CLEAR wa_priceZBNP.
          CLEAR wa_priceZSTO.

          READ TABLE it_price INTO DATA(wa_price1) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'JOIG'.
          wa_billinglines-igstamt                    = wa_price1-ConditionAmount.
          wa_billinglines-igstrate                = wa_price1-ConditionRateValue.
          CLEAR wa_price1.

          READ TABLE it_price INTO DATA(wa_price2) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'JOCG'.
*          wa_billinglines-sgstamt                    = wa_price2-ConditionAmount.
          wa_billinglines-cgstamt                    = wa_price2-ConditionAmount.
          wa_billinglines-cgstrate                = wa_price2-ConditionRateValue.
*          wa_billinglines-sgstrate                = wa_price2-ConditionRateValue.
          CLEAR wa_price2.

          READ TABLE it_price INTO DATA(wa_price3) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'JOSG'.
          wa_billinglines-sgstamt                    = wa_price3-ConditionAmount.
*          wa_billinglines-cgstamt                    = wa_price2-ConditionAmount.
*          wa_billinglines-cgstrate                = wa_price3-ConditionRateValue.
          wa_billinglines-sgstrate                = wa_price3-ConditionRateValue.
          CLEAR wa_price3.


          wa_billinglines-gstrate = wa_billinglines-igstrate + wa_billinglines-cgstrate + wa_billinglines-sgstrate.

          READ TABLE it_price INTO DATA(wa_price4) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'DRD1'.
          wa_billinglines-roundoffvalue                = wa_price4-ConditionAmount.
          CLEAR wa_price4.

          READ TABLE it_price INTO DATA(wa_price5) WITH KEY BillingDocument = wa-BillingDocument
                                                       BillingDocumentItem = wa_lines-BillingDocumentItem
                                                       ConditionType = 'ZMAN'.
          wa_billinglines-manditax                = wa_price5-ConditionAmount.
          CLEAR wa_price5.

          READ TABLE it_price INTO DATA(wa_price6) WITH KEY BillingDocument = wa-BillingDocument
                                                       BillingDocumentItem = wa_lines-BillingDocumentItem
                                                       ConditionType = 'ZMCS'.
          wa_billinglines-mandicess               = wa_price6-ConditionAmount.
          CLEAR wa_price6.

          READ TABLE it_price INTO DATA(wa_price20) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZDPT'.
          wa_billinglines-discountrate = wa_price20-ConditionRateValue.
*                            wa_billinglines-discountamount                = wa_price7-ConditionAmount.

          READ TABLE it_price INTO DATA(wa_price21) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZDQT'.
*                            wa_billinglines-discountamount          = wa_price8-ConditionAmount.
          READ TABLE it_price INTO DATA(wa_price22) WITH KEY BillingDocument = wa-BillingDocument
                                                   BillingDocumentItem = wa_lines-BillingDocumentItem
                                                   ConditionType = 'ZDIS'.
*                            wa_billinglines-discountamount          = wa_price9-ConditionAmount.
          READ TABLE it_price INTO DATA(wa_price23) WITH KEY BillingDocument = wa-BillingDocument
                                                BillingDocumentItem = wa_lines-BillingDocumentItem
                                                ConditionType = 'Z100'.
*                            wa_billinglines-discountamount          = wa_price9-ConditionAmount.

          IF wa_price20 IS NOT INITIAL.
            wa_billinglines-discountamount          = ( wa_price20-ConditionAmount * -1 ) * wa_billinglines-exchangerate.
          ELSEIF wa_price21 IS NOT INITIAL.
            wa_billinglines-discountamount          = ( wa_price21-ConditionAmount * -1 ) * wa_billinglines-exchangerate.
          ELSEIF wa_price22 IS NOT INITIAL.
            wa_billinglines-discountamount          = ( wa_price22-ConditionAmount * -1 ) * wa_billinglines-exchangerate.
          ELSEIF wa_price23 IS NOT INITIAL.
            wa_billinglines-discountamount          = ( wa_price23-ConditionAmount * -1 ) * wa_billinglines-exchangerate.
          ENDIF.
          CLEAR :wa_price20 ,wa_price21,wa_price22,wa_price23 .

*            wa_billinglines-itemrate                = walines-YY1_IGSTRate_BDI.
*            wa_billinglines-totalamount             = walines-NetAmount + walines-TaxAmount.
*
          SELECT SINGLE FROM i_productsalestax FIELDS Product
            WHERE Product = @wa_lines-Product AND Country = 'IN' AND TaxClassification = '1'
            INTO @DATA(lv_flag).

          IF lv_flag IS NOT INITIAL.
            wa_billinglines-exempted = 'No'.
          ELSE.
            wa_billinglines-exempted = 'Yes'.
          ENDIF.

*                wa_billinglines-discountrate            = 0.
          wa_billinglines-billingqtyinsku         = wa_lines-BillingQuantityInBaseUnit.

          READ TABLE it_price INTO DATA(wa_price8) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZTCS'.
          wa_billinglines-tcsamount                     = wa_price8-ConditionAmount.
          wa_billinglines-tcsrate                 = wa_price8-ConditionRateValue.
          CLEAR wa_price8.

          IF    wa_billinglines-tcsamount IS INITIAL.
            READ TABLE it_price INTO DATA(wa_pricezscp) WITH KEY BillingDocument = wa-BillingDocument
                                                  BillingDocumentItem = wa_lines-BillingDocumentItem
                                                  ConditionType = 'ZSCP'.
            wa_billinglines-tcsamount                     = wa_priceZSCP-ConditionAmount.
            wa_billinglines-tcsrate                 = wa_priceZSCP-ConditionRateValue.
            CLEAR wa_priceZSCP.

          ENDIF.

          READ TABLE it_price INTO DATA(wa_price31) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZFRT'.
          wa_billinglines-freightchargeinr           = wa_price31-ConditionAmount * wa_billinglines-exchangerate.
          CLEAR wa_price31.

          READ TABLE it_price INTO DATA(wa_price33) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZPCK'.
          wa_billinglines-packingamountinr           = wa_price33-ConditionAmount * wa_billinglines-exchangerate.
          wa_billinglines-packingchargerateinr       = wa_price33-ConditionRateValue * wa_billinglines-exchangerate.
          CLEAR wa_price33.

          READ TABLE it_price INTO DATA(wa_price9) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZINS'.
          wa_billinglines-insuranceamountinr           = wa_price9-ConditionAmount.
          wa_billinglines-insurancerateinr          = wa_price9-ConditionRateValue.
          CLEAR wa_price9.

          READ TABLE it_price INTO DATA(wa_price10_INS1) WITH KEY BillingDocument = wa-BillingDocument
                                                          BillingDocumentItem = wa_lines-BillingDocumentItem
                                                          ConditionType = 'ZINC'.

          READ TABLE it_price INTO DATA(wa_price10_INS2) WITH KEY BillingDocument = wa-BillingDocument
                                                          BillingDocumentItem = wa_lines-BillingDocumentItem
                                                          ConditionType = 'ZINP'.
          READ TABLE it_price INTO DATA(wa_price10_INS3) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZINS'.
          READ TABLE it_price INTO DATA(wa_price10_INS4) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'ZENS'.
          IF wa_price10_INS1 IS NOT INITIAL.
            wa_billinglines-insuranceamountinr           = wa_price10_INS1-ConditionAmount * wa_billinglines-exchangerate.
            wa_billinglines-insurancerateinr          = wa_price10_INS1-ConditionRateValue * wa_billinglines-exchangerate.
          ELSEIF wa_price10_INS2 IS NOT INITIAL.
            wa_billinglines-insuranceamountinr           = wa_price10_INS2-ConditionAmount * wa_billinglines-exchangerate.
            wa_billinglines-insurancerateinr          = wa_price10_INS2-ConditionRateValue * wa_billinglines-exchangerate.
          ELSEIF wa_price10_INS3 IS NOT INITIAL.
            wa_billinglines-insuranceamountinr           = wa_price10_INS3-ConditionAmount * wa_billinglines-exchangerate.
            wa_billinglines-insurancerateinr          = wa_price10_INS3-ConditionRateValue * wa_billinglines-exchangerate.
          ELSEIF wa_price10_INS4 IS NOT INITIAL.
            wa_billinglines-insuranceamountinr           = wa_price10_INS4-ConditionAmount * wa_lines-AccountingExchangeRate.
*              wa_billinglines-insurance_rate          = wa_price10_INS1-ConditionRateValue.
          ENDIF.
          CLEAR wa_price10_INS1.
          CLEAR wa_price10_INS2.
          CLEAR wa_price10_INS3.
          CLEAR wa_price10_INS4.
          READ TABLE it_price INTO DATA(wa_UGST) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem
                                                           ConditionType = 'JOUG'.
          IF wa_UGST IS NOT INITIAL.
            wa_billinglines-ugstrate = wa_UGST-ConditionRateValue.
            wa_billinglines-ugstamt = wa_UGST-ConditionAmount.
          ENDIF.
          CLEAR wa_UGST.

          SELECT SINGLE FROM I_OperationalAcctgDocItem AS a
      INNER JOIN I_OneTimeAccountCustomer AS b ON a~AccountingDocument = b~AccountingDocument
      FIELDS b~BusinessPartnerName1, b~CityName, b~PostalCode, b~Region
      WHERE a~BillingDocument = @wa-BillingDocument
      INTO @DATA(lv_onetime).

          READ TABLE it_price INTO DATA(wa_trans) WITH KEY BillingDocument = wa-BillingDocument
                                                           BillingDocumentItem = wa_lines-BillingDocumentItem.
          wa_billinglines-documentcurrency = wa_trans-d_transactioncurrency.
          wa_billinglines-rateininr =  wa_billinglines-rate  * wa_billinglines-exchangerate.
          CLEAR wa_trans.

          wa_billinglines-salesquotation = wa-ReferenceSDDocument.
          wa_billinglines-creationdate = wa-CreationDate.
          wa_billinglines-salesperson = wa-fullname.
          wa_billinglines-saleordernumber = wa-SalesDocument.
          wa_billinglines-salescreationdate = wa-sales_creationdate.
          wa_billinglines-customerponumber = wa-purchaseorderbycustomer.
          wa_billinglines-soldtopartygstin = wa-TaxNumber3.
          IF lv_onetime IS NOT INITIAL.
            wa_billinglines-soldtopartyname = lv_onetime-BusinessPartnerName1.
            WA_BILLINGLINES-soldtoregioncode = LV_ONETIME-REGION.
            WA_BILLINGLINES-deliveryplacepostalcode = LV_ONETIME-PostalCode.
            wa_billinglines-deliveryplacecity = LV_ONETIME-CityName.
*            WA_BILLINGLINES-deliveryplacestatecode =
          ELSE.
            wa_billinglines-soldtopartyname = wa-CustomerName.

            IF wa_ship-taxnumber3 IS NOT INITIAL.
              CONCATENATE  wa_ship-taxnumber3+0(2) wa_ship-ship_regionname INTO lv_soldtoregioncode SEPARATED BY '-'.
              wa_billinglines-soldtoregioncode = lv_soldtoregioncode.
            ENDIF.

            SELECT SINGLE FROM I_BillingDocumentPartner AS a LEFT JOIN i_customer AS b ON a~Customer = b~Customer AND b~Language = 'E'
            FIELDS b~CityName, b~PostalCode
            WHERE a~BillingDocument = @wa-BillingDocument AND a~PartnerFunction = 'AG'
             INTO ( @wa_billinglines-deliveryplacecity , @wa_billinglines-deliveryplacepostalcode ).

          ENDIF.

          CLEAR: lv_onetime.
          wa_billinglines-soldtopartynumber = wa-soldtoparty.
          wa_billinglines-shiptopartynumber = wa_ship-shiptoparty.
          wa_billinglines-shiptopartyname = wa_ship-ship_customername.
          wa_billinglines-shiptopartygstno = wa_ship-ship_taxnumber3.
          wa_billinglines-deliverynumber = wa-d_referencesddocument.
          wa_billinglines-billingtype = wa-billingdocumenttype.
          wa_billinglines-netamount            = wa_lines-NetAmount.
          wa_billinglines-taxamount            = wa_lines-TaxAmount.
          wa_billinglines-qty = wa_lines-billingquantity.
           IF wa-taxnumber3 IS NOT INITIAL.
              CONCATENATE  wa-taxnumber3+0(2) wa-RegionName INTO lv_deliverysatatcode SEPARATED BY '-'.
              wa_billinglines-deliveryplacestatecode = lv_deliverysatatcode.
            ENDIF.
          IF  wa_billinglines-discountamount < 0.
            wa_billinglines-discountamount = wa_billinglines-discountamount * -1.
          ENDIF.
          wa_billinglines-taxablevalueafterdiscount = wa_billinglines-taxablevaluebeforediscount - wa_billinglines-discountamount.
          wa_billinglines-totaltaxamount = ( wa_billinglines-taxablevalueafterdiscount + wa_billinglines-freightchargeinr + wa_billinglines-insuranceamountinr + wa_billinglines-packingamountinr ).
          wa_billinglines-totalamount = wa_billinglines-totaltaxamount + wa_billinglines-taxamount.
          wa_billinglines-invoiceamount  =  wa_billinglines-totalamount + wa_billinglines-tcsamount + wa_billinglines-roundoffvalue.

*           wa_billinglines-invoiceamount  =  wa_billinglines-taxablevalueafterdiscount + wa_billinglines-roundoffvalue + wa_lines-TaxAmount + wa_billinglines-tcsamount.
*           IF wa_billinglines-distributionchannel = 'EX'.
*             wa_billinglines-invoiceamount = ( wa_billinglines-taxablevalueafterdiscount + wa_billinglines-roundoffvalue
*                                              + wa_billinglines-freightchargeinr + wa_billinglines-insuranceamountinr + wa_billinglines-packingamountinr ).
*           ENDIF.
          wa_billinglines-cancelledinvoice = ''.
*
          IF wa_billinglines-billingtype = 'S1' OR wa_billinglines-billingtype = 'CBRE' OR wa_billinglines-billingtype = 'G2'.
            wa_billinglines-netamount            = wa_billinglines-netamount * -1.
            wa_billinglines-taxamount            = wa_billinglines-taxamount * -1.
            wa_billinglines-qty = wa_lines-billingquantity * -1.
            wa_billinglines-taxablevaluebeforediscount = wa_billinglines-taxablevaluebeforediscount * -1.
            wa_billinglines-taxablevalueafterdiscount = wa_billinglines-taxablevalueafterdiscount * -1.
            wa_billinglines-totaltaxamount = wa_billinglines-totaltaxamount * -1.
            wa_billinglines-totalamount = wa_billinglines-totalamount * -1.
            wa_billinglines-invoiceamount  = wa_billinglines-invoiceamount * -1.
            wa_billinglines-insuranceamountinr = wa_billinglines-insuranceamountinr * -1.
*            wa_billinglines-insurancerateinr = wa_billinglines-insurancerateinr * -1.
            wa_billinglines-packingamountinr = wa_billinglines-packingamountinr * -1.
*            wa_billinglines-packingchargerateinr = wa_billinglines-packingchargerateinr * -1.
            wa_billinglines-freightchargeinr = wa_billinglines-freightchargeinr * -1.
            wa_billinglines-tcsamount = wa_billinglines-tcsamount * -1.
            wa_billinglines-discountamount = wa_billinglines-discountamount * -1.
            wa_billinglines-mandicess = wa_billinglines-mandicess * -1.
            wa_billinglines-manditax = wa_billinglines-manditax * -1.
            wa_billinglines-roundoffvalue = wa_billinglines-roundoffvalue * -1.
            wa_billinglines-sgstamt     = wa_billinglines-sgstamt * -1.
            wa_billinglines-cgstamt = wa_billinglines-cgstamt * -1.
            wa_billinglines-igstamt = wa_billinglines-igstamt * -1.
            wa_billinglines-ugstamt = wa_billinglines-ugstamt * -1.
            wa_billinglines-actualnetweight = wa_billinglines-actualnetweight * -1.
            wa_billinglines-grossweight = wa_billinglines-grossweight * -1.
            IF  wa_billinglines-billingtype = 'S1'.
              wa_billinglines-cancelledinvoice = 'X'.
            ENDIF.
            wa_cancelled-invoice = wa_billinglines-invoice.
            APPEND wa_cancelled TO lt_cancelled.
            CLEAR wa_cancelled.
          ENDIF.

          IF wa-billingdocumenttype = 'F2'.
            wa_billinglines-billingdocdesc = 'Standard Invoice'.
          ENDIF.
          IF wa-billingdocumenttype = 'JSTO'.
            wa_billinglines-billingdocdesc = 'STO Invoice'.
          ENDIF.
          IF wa-billingdocumenttype = 'G2'.
            wa_billinglines-billingdocdesc = 'Credit Note'.
          ENDIF.
          IF wa-billingdocumenttype = 'L2'.
            wa_billinglines-billingdocdesc = 'Debit Note'.
          ENDIF.
          IF wa-billingdocumenttype = 'S1'.
            wa_billinglines-billingdocdesc = 'Invoice Cancellation'.
          ENDIF.
          IF wa-billingdocumenttype = 'S2'.
            wa_billinglines-billingdocdesc = 'Credit Memo Cancellation'.
          ENDIF.
          IF wa-billingdocumenttype = 'F8'.
            wa_billinglines-billingdocdesc = 'Export Commercial Invoice'.
          ENDIF.
          IF wa-billingdocumenttype = 'CBRE'.
            wa_billinglines-billingdocdesc = 'Sales Return Credit Note'.
          ENDIF.
          IF wa-billingdocumenttype = 'JDC'.
            wa_billinglines-billingdocdesc = 'IntraState Delivery Challan'.
          ENDIF.


          wa_billinglines-billno = wa-DocumentReferenceID.
          wa_billinglines-invoicedate = wa-billingdocumentdate.
          wa_billinglines-deliveryplant = wa-Plant.


* this logic has been added to the above logic in S2.
*          IF wa_billinglines-billingtype = 'CBRE'. "OR wa-BillingDocumentType = 'S2'. S2 is camcellation of CBRE which is -ve inv as -ve of -ve is +ve
*            IF wa_billinglines-grossweight > 0.
*              wa_billinglines-grossweight = wa_billinglines-grossweight * -1.
*            ENDIF.
*            IF wa_billinglines-actualnetweight > 0.
*              wa_billinglines-actualnetweight = wa_billinglines-actualnetweight * -1.
*            ENDIF.
*
*            IF wa_billinglines-qty > 0.
*              wa_billinglines-qty = wa_billinglines-qty * -1.
*            ENDIF.
*            IF wa_billinglines-rate > 0.
*              wa_billinglines-rate = wa_billinglines-rate * -1.
*            ENDIF.
*            IF wa_billinglines-rateininr > 0.
*              wa_billinglines-rateininr = wa_billinglines-rateininr * -1.
*            ENDIF.
*            IF wa_billinglines-taxablevaluebeforediscount > 0.
*              wa_billinglines-taxablevaluebeforediscount = wa_billinglines-taxablevaluebeforediscount * -1.
*            ENDIF.
*            IF wa_billinglines-igstamt > 0.
*              wa_billinglines-igstamt = wa_billinglines-igstamt * -1.
*            ENDIF.
*            IF wa_billinglines-taxablevalueafterdiscount > 0.
*              wa_billinglines-taxablevalueafterdiscount = wa_billinglines-taxablevalueafterdiscount * -1.
*            ENDIF.
*            IF wa_billinglines-sgstamt > 0.
*              wa_billinglines-sgstamt = wa_billinglines-sgstamt * -1.
*            ENDIF.
*            IF wa_billinglines-freightchargeinr > 0.
*              wa_billinglines-freightchargeinr = wa_billinglines-freightchargeinr * -1.
*            ENDIF.
*            IF wa_billinglines-cgstamt > 0.
*              wa_billinglines-cgstamt = wa_billinglines-cgstamt * -1.
*            ENDIF.
*            IF wa_billinglines-insurancerateinr > 0.
*              wa_billinglines-insurancerateinr = wa_billinglines-insurancerateinr * -1.
*            ENDIF.
*            IF wa_billinglines-insuranceamountinr > 0.
*              wa_billinglines-insuranceamountinr = wa_billinglines-insuranceamountinr * -1.
*            ENDIF.
*            IF wa_billinglines-packingamountinr > 0.
*              wa_billinglines-packingamountinr = wa_billinglines-packingamountinr * -1.
*            ENDIF.
*            IF wa_billinglines-packingchargerateinr > 0.
*              wa_billinglines-packingchargerateinr = wa_billinglines-packingchargerateinr * -1.
*            ENDIF.
*            IF wa_billinglines-ugstrate > 0.
*              wa_billinglines-ugstrate = wa_billinglines-ugstrate * -1.
*            ENDIF.
*            IF wa_billinglines-ugstamt > 0.
*              wa_billinglines-ugstamt = wa_billinglines-ugstamt * -1.
*            ENDIF.
*            IF wa_billinglines-roundoffvalue > 0.
*              wa_billinglines-roundoffvalue = wa_billinglines-roundoffvalue * -1.
*            ENDIF.
*            IF wa_billinglines-discountamount > 0.
*              wa_billinglines-discountamount = wa_billinglines-discountamount * -1.
*            ENDIF.
*            IF wa_billinglines-discountrate > 0.
*              wa_billinglines-discountrate = wa_billinglines-discountrate * -1.
*            ENDIF.
*            IF wa_billinglines-totaltaxamount > 0.
*              wa_billinglines-totaltaxamount = wa_billinglines-totaltaxamount * -1.
*            ENDIF.
*            IF wa_billinglines-totalamount > 0.
*              wa_billinglines-totalamount = wa_billinglines-totalamount * -1.
*            ENDIF.
*            IF wa_billinglines-invoiceamount > 0.
*              wa_billinglines-invoiceamount = wa_billinglines-invoiceamount * -1.
*            ENDIF.
*            IF wa_billinglines-igstrate > 0.
*              wa_billinglines-igstrate = wa_billinglines-igstrate * -1.
*            ENDIF.
*            IF wa_billinglines-cgstrate > 0.
*              wa_billinglines-cgstrate = wa_billinglines-cgstrate * -1.
*            ENDIF.
*            IF wa_billinglines-sgstrate  > 0.
*              wa_billinglines-sgstrate = wa_billinglines-sgstrate * -1.
*            ENDIF.
*            IF wa_billinglines-tcsrate > 0.
*              wa_billinglines-tcsrate = wa_billinglines-tcsrate * -1.
*            ENDIF.
*            IF wa_billinglines-tcsamount > 0.
*              wa_billinglines-tcsamount = wa_billinglines-tcsamount * -1.
*            ENDIF.
*          ENDIF.
          wa_billinglines-creationdate = cl_abap_context_info=>get_system_date(  ) .
          MODIFY zbillinglines FROM @wa_billinglines.

          IF wa_billinglines-billingtype = 'S2'.
            SELECT SINGLE FROM i_billingdocument
            FIELDS BillingDocument, CancelledBillingDocument
            WHERE BillingDocument = @wa_billinglines-invoice
            INTO @DATA(lv_cancelledinvoice).

            IF lv_cancelledinvoice IS NOT INITIAL.
              " update zbillinglines with cancelled invoice
              UPDATE zbillinglines SET cancelledinvoice = 'X'
              WHERE invoice = @lv_cancelledinvoice-CancelledBillingDocument.
            ENDIF.
          ENDIF.

          CLEAR: wa_lines,wa_billinglines,lv_div_concat,lv_deliverySatatcode ,lv_soldtoregioncode, lv_distributionchannel .
        ENDLOOP.
      ENDIF.
      MODIFY zbillingproc FROM @wa_billingprocessed.
      CLEAR: wa, wa_billingprocessed.
    ENDLOOP.
*   SORT lt_billinglines BY invoice .
*   SORT lt_billingprocessed BY billingdocument.

    LOOP AT lt_cancelled INTO wa_cancelled.
      SELECT SINGLE billingdocument,CancelledBillingDocument FROM i_billingdocument
            WHERE BillingDocument = @wa_cancelled-invoice
            INTO @DATA(temp).
      IF temp IS NOT INITIAL.
        SELECT * FROM zbillinglines AS dc
        WHERE dc~invoice = @temp-CancelledBillingDocument
        INTO TABLE @DATA(temp_zbillinglines).
*       SORT lt_billinglines BY invoice .
*       SORT lt_billingprocessed BY billingdocument.

        LOOP AT temp_zbillinglines INTO DATA(wa_temp_zbillinglines).
          wa_temp_zbillinglines-cancelledinvoice = 'X'.
          MODIFY zbillinglines FROM @wa_temp_zbillinglines.
          CLEAR wa_temp_zbillinglines.
        ENDLOOP.
      ENDIF.
      CLEAR wa_cancelled.
    ENDLOOP.
*   SORT lt_billinglines BY invoice .
*   SORT lt_billingprocessed BY billingdocument.
  ENDMETHOD.
ENDCLASS.
