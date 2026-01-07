CLASS zcl_eway_generation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_item_list,
             productName          TYPE string,
             productDesc          TYPE string,
             hsnCode              TYPE int4,
             quantity             TYPE P length 13 decimals 2,
             qtyUnit              TYPE string,
             cgstRate            TYPE P length 13 decimals 2,
             sgstRate            TYPE P length 13 decimals 2,
             igstRate            TYPE P length 13 decimals 2,
             cessRate            TYPE P length 13 decimals 2,
             cessAdvol         TYPE P length 13 decimals 2,
             taxableAmount       TYPE P length 13 decimals 2,
           END OF ty_item_list.
    CLASS-DATA itemList TYPE TABLE OF ty_item_list.
    TYPES: BEGIN OF ty_final,
            supplyType       TYPE string,
             subSupplyType    TYPE string,
             subSupplyDesc    TYPE string,
             docType          TYPE string,
             docNo            TYPE string,
             docDate          TYPE string,
             fromGstin        TYPE string,
             fromTrdName      TYPE string,
             transactionType  TYPE INT1,
             fromLglName      TYPE string,
             fromAddr1        TYPE string,
             fromAddr2        TYPE string,
             fromPlace        TYPE string,
             fromPincode      TYPE int4,
             actFromStateCode TYPE int4,
             fromStateCode    TYPE int4,
             toGstin          TYPE string,
             toTrdName        TYPE string,
             toLglName        TYPE string,
             toAddr1          TYPE string,
             toAddr2          TYPE string,
             toPlace          TYPE string,
             toPincode        TYPE int4,
             actToStateCode   TYPE int4,
             toStateCode      TYPE int4,
             totalValue       TYPE P length 13 decimals 2,
             cgstValue        TYPE P length 13 decimals 2,
             sgstValue        TYPE P length 13 decimals 2,
             igstValue        TYPE P length 13 decimals 2,
             cessValue        TYPE P length 13 decimals 2,
             totInvValue      TYPE P length 13 decimals 2,
             transporterId    TYPE string,
             transporterName  TYPE string,
             transDocNo       TYPE string,
             transMode        TYPE string,
             transDistance    TYPE string,
             transDocDate     TYPE string,  " Consider converting to DATS if needed
             vehicleNo        TYPE string,
             vehicleType      TYPE string,
             itemList                    LIKE itemList,
           END OF ty_final.

    CLASS-DATA: wa_final TYPE ty_final.
    CLASS-METHODS :generated_eway_bill IMPORTING
                                                 invoice       TYPE ztable_irn-billingdocno
                                                 companycode   TYPE ztable_irn-bukrs
                                       RETURNING VALUE(result) TYPE string.
protected section.
private section.
ENDCLASS.



CLASS ZCL_EWAY_GENERATION IMPLEMENTATION.


  METHOD generated_eway_bill.

    DATA :        wa_itemlist TYPE ty_item_list.

    SELECT SINGLE FROM i_billingdocument AS a
   INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
   FIELDS a~BillingDocument,
   a~BillingDocumentType,
   a~BillingDocumentDate,a~DistributionChannel,
   b~Plant,a~CompanyCode, a~DocumentReferenceID, a~AccountingExchangeRate
   WHERE a~BillingDocument = @invoice
   INTO @DATA(lv_document_details) PRIVILEGED ACCESS.

    DATA SupType TYPE string.

    IF lv_document_details-DistributionChannel NE 'EX'.
      SupType = 'B2B'.
    ELSE.
      SupType = 'EXPWOP'.
    ENDIF.

    DATA DocDate TYPE string.

    SHIFT lv_document_details-BillingDocument LEFT DELETING LEADING '0'.
    wa_final-docno      = lv_document_details-DocumentReferenceID.
    DocDate             = lv_document_details-BillingDocumentDate+6(2) && '/' && lv_document_details-BillingDocumentDate+4(2) && '/' && lv_document_details-BillingDocumentDate(4).
    wa_final-docdate    = DocDate.
    wa_final-transactiontype = 1.

    IF lv_document_details-BillingDocumentType = 'F2' OR lv_document_details-BillingDocumentType = 'JSTO' OR lv_document_details-BillingDocumentType = 'JSP'
       OR lv_document_details-BillingDocumentType = 'L2' OR lv_document_details-BillingDocumentType = 'JDC' OR lv_document_details-BillingDocumentType = 'JVR'
       OR lv_document_details-BillingDocumentType = 'JSN' .
      wa_final-supplytype = 'O'.
    ELSEIF lv_document_details-BillingDocumentType = 'G2' OR lv_document_details-BillingDocumentType = 'CBRE'.
      wa_final-supplytype = 'I'.
    ENDIF.




    SELECT SINGLE FROM ztable_plant
    FIELDS gstin_no, city, address1, address2, pin, state_code1,plant_name1
    WHERE plant_code = @lv_document_details-plant AND comp_code = @lv_document_details-CompanyCode INTO @DATA(sellerplantaddress) PRIVILEGED ACCESS.

    wa_final-fromgstin    =  sellerplantaddress-gstin_no.
    wa_final-fromtrdname  =  sellerplantaddress-plant_name1.
    wa_final-fromlglname =  sellerplantaddress-plant_name1.
    wa_final-fromaddr1    =  sellerplantaddress-address1.
    wa_final-fromaddr2    =  sellerplantaddress-address2 .
    wa_final-fromplace     =  sellerplantaddress-address2 .
    IF sellerplantaddress-city IS NOT INITIAL.
      wa_final-fromplace      =  sellerplantaddress-city .
    ENDIF.
    wa_final-fromstatecode     =  sellerplantaddress-state_code1.
    wa_final-actfromstatecode     =  sellerplantaddress-state_code1.
    wa_final-frompincode      =  sellerplantaddress-pin.


    SELECT SINGLE FROM I_BillingDocumentPartner AS a
    FIELDS a~Customer
       WHERE a~BillingDocument = @invoice
       AND a~PartnerFunction = 'RE' INTO @DATA(buyer) PRIVILEGED ACCESS.


    SELECT SINGLE FROM I_BillingDocItemPartner AS a
    FIELDS a~Customer
       WHERE a~BillingDocument = @invoice
       AND a~PartnerFunction = 'WE' INTO @DATA(Shipper) PRIVILEGED ACCESS.

    IF buyer IS NOT INITIAL AND Shipper IS NOT INITIAL.
      IF buyer NE Shipper.
        wa_final-transactiontype = 2 .
        SELECT SINGLE FROM i_customer AS b
        FIELDS taxnumber3, postalcode, Region, customername, customerfullname
        WHERE b~Customer = @Shipper
        INTO  @DATA(buyeradd) PRIVILEGED ACCESS.
      ELSE.

        SELECT SINGLE FROM i_customer AS b
         FIELDS taxnumber3, postalcode, Region, customername, customerfullname
         WHERE b~Customer = @buyer
         INTO  @buyeradd PRIVILEGED ACCESS.

      ENDIF.
    ELSE.
      SELECT SINGLE FROM i_customer AS b
       FIELDS taxnumber3, postalcode, Region, customername, customerfullname
        WHERE b~Customer = @buyer
        INTO  @buyeradd PRIVILEGED ACCESS.
    ENDIF.

    IF SupType = 'EXPWOP'.
      wa_final-togstin = 'URP'.
      wa_final-topincode   = '999999'  .
      wa_final-tostatecode  = '96'  .
      wa_final-acttostatecode  = '96'  .
      wa_final-toplace = '96'.

    ELSE.
      wa_final-togstin = buyeradd-taxnumber3.
      wa_final-topincode   = buyeradd-postalcode  .

      SELECT SINGLE FROM zstatecodemaster
      FIELDS Statecodenum
      WHERE StateCode = @buyeradd-Region
      INTO @DATA(lv_statecode).

      wa_final-tostatecode  = lv_statecode  .
      wa_final-acttostatecode  = lv_statecode .
      wa_final-toplace = lv_statecode.
    ENDIF.

    wa_final-tolglname = buyeradd-customername.
    wa_final-totrdname = buyeradd-customername.
    wa_final-toaddr1 = buyeradd-customerfullname.
    wa_final-toaddr2 = ''.



    IF lv_document_details-BillingDocumentType = 'JDC' OR lv_document_details-BillingDocumentType = 'JSP'.
      wa_final-subsupplytype = '5'.
      wa_final-doctype = 'CHL'.
    ELSEIF lv_document_details-BillingDocumentType = 'JSN'.
      wa_final-subsupplytype = '4'.
      wa_final-doctype = 'CHL'.
    ELSEIF lv_document_details-BillingDocumentType = 'JVR'.
      wa_final-subsupplytype = '8'.
      wa_final-doctype = 'CHL'.
      wa_final-subsupplydesc = 'Others' .
    ELSE.
      wa_final-subsupplytype = '1'.
      wa_final-doctype = 'INV'.
    ENDIF.




    SELECT SINGLE FROM zr_zirntp
    FIELDS Transportername, Vehiclenum, Grdate, Grno, Transportergstin
    WHERE Billingdocno = @invoice AND Bukrs = @companycode
    INTO @DATA(Eway).

    wa_final-vehicleno = Eway-Vehiclenum .
    wa_final-transportername = Eway-Transportername .
    wa_final-transdocdate = Eway-Grdate+6(2) && '/' && Eway-Grdate+4(2) && '/' && Eway-Grdate(4).
    wa_final-transdocno = Eway-Grno .
    wa_final-transporterid = Eway-Transportergstin .
    wa_final-transmode = '1'.
    IF wa_final-topincode NE wa_final-frompincode.
      wa_final-transdistance = 0.
    ELSE.
      wa_final-transdistance = 10.
    ENDIF.
    wa_final-vehicletype = 'R'.

    SELECT FROM I_BillingDocumentItem AS item
        LEFT JOIN I_ProductDescription AS pd ON item~Product = pd~Product AND pd~LanguageISOCode = 'EN'
        LEFT JOIN i_productplantbasic AS c ON item~Product = c~Product AND item~Plant = c~Plant
        FIELDS item~BillingDocument, item~BillingDocumentItem
        , item~Plant, item~ProfitCenter, item~Product, item~BillingQuantity, item~BaseUnit, item~BillingQuantityUnit, item~NetAmount, item~Subtotal1Amount,
             item~TaxAmount, item~TransactionCurrency, item~CancelledBillingDocument, item~BillingQuantityinBaseUnit,
             pd~ProductDescription,
             c~consumptiontaxctrlcode
        WHERE item~BillingDocument = @invoice AND consumptiontaxctrlcode IS NOT INITIAL AND item~salesdocumentitemcategory NE 'CB99'
           INTO TABLE @DATA(ltlines).

    SELECT FROM I_BillingDocItemPrcgElmntBasic FIELDS BillingDocument , BillingDocumentItem, ConditionRateValue, ConditionAmount, ConditionType,
      transactioncurrency AS d_transactioncurrency
      WHERE BillingDocument = @invoice
      INTO TABLE @DATA(it_price).

    LOOP AT ltlines INTO DATA(wa_lines).
      wa_itemlist-productname = wa_lines-ProductDescription.
      wa_itemlist-productdesc = wa_lines-ProductDescription.
      wa_itemlist-hsncode = wa_lines-consumptiontaxctrlcode.
      wa_itemlist-quantity = wa_lines-BillingQuantity.


      SELECT SINGLE FROM zgstuom
      FIELDS gstuom
      WHERE uom = @wa_lines-BillingQuantityUnit "and bukrs = @wa_lines-CompanyCode
      INTO @DATA(uom).

      IF uom IS INITIAL.
        wa_itemlist-qtyunit = wa_lines-BillingQuantityUnit.
      ELSE.
        wa_itemlist-qtyunit = uom.
      ENDIF.


      READ TABLE it_price INTO DATA(wa_price1) WITH KEY BillingDocument = wa_lines-BillingDocument
                                                      BillingDocumentItem = wa_lines-BillingDocumentItem
                                                      ConditionType = 'JOIG'.
      IF wa_price1 IS NOT INITIAL.
        wa_itemlist-igstrate                       = wa_price1-ConditionRateValue .
        CLEAR wa_price1.

      ELSE.

        READ TABLE it_price INTO DATA(wa_price2) WITH KEY BillingDocument = wa_lines-BillingDocument
                                                         BillingDocumentItem = wa_lines-BillingDocumentItem
                                                         ConditionType = 'JOSG'.
        wa_itemlist-sgstrate                    = wa_price2-ConditionRateValue.

        READ TABLE it_price INTO DATA(wa_price3) WITH KEY BillingDocument = wa_lines-BillingDocument
                                                        BillingDocumentItem = wa_lines-BillingDocumentItem
                                                        ConditionType = 'JOCG'.
        wa_itemlist-cgstrate                    = wa_price3-ConditionRateValue.

        CLEAR : wa_price2,wa_price3.
      ENDIF.


      SELECT SUM( conditionamount )    FROM i_billingdocumentitemprcgelmnt
        WHERE   conditiontype IN ( 'JTC1', 'ZTCS' )
        AND billingdocument = @wa_lines-billingdocument AND billingdocumentitem = @wa_lines-billingdocumentitem
         INTO @DATA(tcs) .

      IF tcs IS NOT INITIAL .
        DATA(tcsamt) = tcs .
      ENDIF.

      SELECT SUM( conditionamount )    FROM i_billingdocumentitemprcgelmnt
         WHERE   conditiontype IN ( 'ZDIS', 'ZDIV', 'ZDPT', 'ZDQT','Z100' )
         AND billingdocument = @wa_lines-billingdocument AND billingdocumentitem = @wa_lines-billingdocumentitem
          INTO @DATA(discount) .

      IF discount < 0.
        discount                     =      discount * -1 * lv_document_details-AccountingExchangeRate.
      ELSE.
        discount                     =      discount * lv_document_details-AccountingExchangeRate.
      ENDIF.

      SELECT SUM( conditionamount )    FROM i_billingdocumentitemprcgelmnt
        WHERE   conditiontype IN ( 'YBHD', 'ZFRT','ZINS', 'FIN1','ZPCK' )
        AND billingdocument = @wa_lines-billingdocument AND billingdocumentitem = @wa_lines-billingdocumentitem
         INTO @DATA(OtherCharges) .


      SELECT   FROM i_billingdocumentitemprcgelmnt AS a
      FIELDS  SUM( a~ConditionRateAmount ) AS UnitPrice, SUM( a~ConditionAmount ) AS TotAmt
       WHERE   conditiontype IN ( 'ZEXF', 'ZBNP', 'ZPR0', 'PPR0','ZSTO' )
       AND billingdocument = @wa_lines-billingdocument AND billingdocumentitem = @wa_lines-billingdocumentitem
        INTO @DATA(unitprice) .

      wa_itemlist-taxableamount = ( unitprice-TotAmt + OtherCharges - discount ) * lv_document_details-AccountingExchangeRate.

      SELECT FROM i_billingdocumentitemprcgelmnt AS a
        FIELDS SUM( a~ConditionRateAmount ) AS UnitPrice, SUM( a~ConditionAmount ) AS TotAmt
        WHERE   conditiontype IN ( 'ZFOC' )
            AND billingdocument = @wa_lines-billingdocument AND billingdocumentitem = @wa_lines-billingdocumentitem
        INTO @DATA(foc_charge) .

      IF foc_charge-totamt IS NOT INITIAL.
        wa_itemlist-igstrate = 0.
        wa_itemlist-cgstrate = 0.
        wa_itemlist-sgstrate = 0.
      ENDIF.




      wa_final-totalvalue   +=  wa_lines-NetAmount.
      IF wa_itemlist-igstrate NE 0.
        wa_final-igstvalue +=  wa_itemlist-taxableamount *  ( wa_itemlist-igstrate / 100  ).
      ENDIF.

      IF wa_itemlist-cgstrate NE 0.
        wa_final-cgstvalue +=  wa_itemlist-taxableamount * ( wa_itemlist-cgstrate / 100 ).
      ENDIF.

      IF wa_itemlist-sgstrate NE 0.
        wa_final-sgstvalue +=  wa_itemlist-taxableamount *  ( wa_itemlist-sgstrate / 100 ).
      ENDIF.



      APPEND wa_itemlist TO itemList.
      CLEAR :  wa_itemlist.
    ENDLOOP.

    wa_final-totinvvalue = wa_final-totalvalue + wa_final-igstvalue + wa_final-cgstvalue + wa_final-sgstvalue .
    wa_final-itemlist = itemList.

    DATA:json TYPE REF TO if_xco_cp_json_data.

    xco_cp_json=>data->from_abap(
      EXPORTING
        ia_abap      = wa_final
      RECEIVING
        ro_json_data = json   ).
    json->to_string(
      RECEIVING
        rv_string =   DATA(lv_string) ).

    REPLACE ALL OCCURRENCES OF '"SUPPLYTYPE"' IN lv_string WITH '"supplyType"'.
    REPLACE ALL OCCURRENCES OF '"SUBSUPPLYTYPE"' IN lv_string WITH '"subSupplyType"'.
    REPLACE ALL OCCURRENCES OF '"SUBSUPPLYDESC"' IN lv_string WITH '"subSupplyDesc"'.
    REPLACE ALL OCCURRENCES OF '"TRANSACTIONTYPE"' IN lv_string WITH '"transactionType"'.
    REPLACE ALL OCCURRENCES OF '"DOCTYPE"' IN lv_string WITH '"docType"'.
    REPLACE ALL OCCURRENCES OF '"DOCNO"' IN lv_string WITH '"docNo"'.
    REPLACE ALL OCCURRENCES OF '"DOCDATE"' IN lv_string WITH '"docDate"'.
    REPLACE ALL OCCURRENCES OF '"FROMGSTIN"' IN lv_string WITH '"fromGstin"'.
    REPLACE ALL OCCURRENCES OF '"FROMTRDNAME"' IN lv_string WITH '"fromTrdName"'.
    REPLACE ALL OCCURRENCES OF '"FROMLGLNAME"' IN lv_string WITH '"fromLglName"'.
    REPLACE ALL OCCURRENCES OF '"FROMADDR1"' IN lv_string WITH '"fromAddr1"'.
    REPLACE ALL OCCURRENCES OF '"FROMADDR2"' IN lv_string WITH '"fromAddr2"'.
    REPLACE ALL OCCURRENCES OF '"FROMPLACE"' IN lv_string WITH '"fromPlace"'.
    REPLACE ALL OCCURRENCES OF '"FROMPINCODE"' IN lv_string WITH '"fromPincode"'.
    REPLACE ALL OCCURRENCES OF '"ACTFROMSTATECODE"' IN lv_string WITH '"actFromStateCode"'.
    REPLACE ALL OCCURRENCES OF '"FROMSTATECODE"' IN lv_string WITH '"fromStateCode"'.
    REPLACE ALL OCCURRENCES OF '"TOGSTIN"' IN lv_string WITH '"toGstin"'.
    REPLACE ALL OCCURRENCES OF '"TOTRDNAME"' IN lv_string WITH '"toTrdName"'.
    REPLACE ALL OCCURRENCES OF '"TOLGLNAME"' IN lv_string WITH '"toLglName"'.
    REPLACE ALL OCCURRENCES OF '"TOADDR1"' IN lv_string WITH '"toAddr1"'.
    REPLACE ALL OCCURRENCES OF '"TOADDR2"' IN lv_string WITH '"toAddr2"'.
    REPLACE ALL OCCURRENCES OF '"TOPLACE"' IN lv_string WITH '"toPlace"'.
    REPLACE ALL OCCURRENCES OF '"TOPINCODE"' IN lv_string WITH '"toPincode"'.
    REPLACE ALL OCCURRENCES OF '"ACTTOSTATECODE"' IN lv_string WITH '"actToStateCode"'.
    REPLACE ALL OCCURRENCES OF '"TOSTATECODE"' IN lv_string WITH '"toStateCode"'.
    REPLACE ALL OCCURRENCES OF '"TOTALVALUE"' IN lv_string WITH '"totalValue"'.
    REPLACE ALL OCCURRENCES OF '"CGSTVALUE"' IN lv_string WITH '"cgstValue"'.
    REPLACE ALL OCCURRENCES OF '"SGSTVALUE"' IN lv_string WITH '"sgstValue"'.
    REPLACE ALL OCCURRENCES OF '"IGSTVALUE"' IN lv_string WITH '"igstValue"'.
    REPLACE ALL OCCURRENCES OF '"CESSVALUE"' IN lv_string WITH '"cessValue"'.
    REPLACE ALL OCCURRENCES OF '"TOTINVVALUE"' IN lv_string WITH '"totInvValue"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTERID"' IN lv_string WITH '"transporterId"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTERNAME"' IN lv_string WITH '"transporterName"'.
    REPLACE ALL OCCURRENCES OF '"TRANSDOCNO"' IN lv_string WITH '"transDocNo"'.
    REPLACE ALL OCCURRENCES OF '"TRANSMODE"' IN lv_string WITH '"transMode"'.
    REPLACE ALL OCCURRENCES OF '"TRANSDISTANCE"' IN lv_string WITH '"transDistance"'.
    REPLACE ALL OCCURRENCES OF '"TRANSDOCDATE"' IN lv_string WITH '"transDocDate"'.
    REPLACE ALL OCCURRENCES OF '"VEHICLENO"' IN lv_string WITH '"vehicleNo"'.
    REPLACE ALL OCCURRENCES OF '"VEHICLETYPE"' IN lv_string WITH '"vehicleType"'.
    REPLACE ALL OCCURRENCES OF '"ITEMLIST"' IN lv_string WITH '"itemList"'.
    REPLACE ALL OCCURRENCES OF '"PRODUCTNAME"' IN lv_string WITH '"productName"'.
    REPLACE ALL OCCURRENCES OF '"PRODUCTDESC"' IN lv_string WITH '"productDesc"'.
    REPLACE ALL OCCURRENCES OF '"HSNCODE"' IN lv_string WITH '"hsnCode"'.
    REPLACE ALL OCCURRENCES OF '"QUANTITY"' IN lv_string WITH '"quantity"'.
    REPLACE ALL OCCURRENCES OF '"QTYUNIT"' IN lv_string WITH '"qtyUnit"'.
    REPLACE ALL OCCURRENCES OF '"CGSTRATE"' IN lv_string WITH '"cgstRate"'.
    REPLACE ALL OCCURRENCES OF '"SGSTRATE"' IN lv_string WITH '"sgstRate"'.
    REPLACE ALL OCCURRENCES OF '"IGSTRATE"' IN lv_string WITH '"igstRate"'.
    REPLACE ALL OCCURRENCES OF '"CESSRATE"' IN lv_string WITH '"cessRate"'.
    REPLACE ALL OCCURRENCES OF '"CESSADVOL"' IN lv_string WITH '"cessAdvol"'.
    REPLACE ALL OCCURRENCES OF '"TAXABLEAMOUNT"' IN lv_string WITH '"taxableAmount"'.

    REPLACE ALL OCCURRENCES OF '"transporterId":""' IN lv_string WITH '"transporterId":null'.
    REPLACE ALL OCCURRENCES OF '"transporterName":""' IN lv_string WITH '"transporterName":null'.
    REPLACE ALL OCCURRENCES OF '"transDocNo":""' IN lv_string WITH '"transDocNo":null'.
    REPLACE ALL OCCURRENCES OF '"transDocDate":"00/00/0000"' IN lv_string WITH |"transDocDate":"{ DocDate }"|.
    REPLACE ALL OCCURRENCES OF '"transDocDate":""' IN lv_string WITH |"transDocDate":"{ DocDate }"|.
    REPLACE ALL OCCURRENCES OF '0 "' IN lv_string WITH '0"'.


    result = lv_string.

  ENDMETHOD.
ENDCLASS.
