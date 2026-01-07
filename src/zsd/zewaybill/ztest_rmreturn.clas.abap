CLASS ztest_rmreturn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    CLASS-DATA : bill_doc TYPE I_BillingDocument-BillingDocument.
*    CLASS-DATA : company_code TYPE I_BillingDocument-CompanyCode.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_RMRETURN IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    Data : bill_doc Type I_BillingDocument-BillingDocument.
    DATA : plant_add   TYPE string.
    DATA : p_add1  TYPE string.
    DATA : p_add2 TYPE string.
    DATA : p_city TYPE string.
    DATA : p_dist TYPE string.
    DATA : p_state TYPE string.
    DATA : p_pin TYPE string.
    DATA : p_name TYPE string.
    DATA : custref TYPE string.
    DATA : p_StateCode TYPE string.
    DATA : p_country   TYPE string,
           plant_name  TYPE string,
           plant_gstin TYPE string.



    SELECT SINGLE
    a~billingdocument ,
    a~billingdocumentdate ,
    a~creationdate,
    a~creationtime,
    a~accountingexchangerate,
    a~documentreferenceid,
    b~referencesddocument ,
    b~plant,
    d~deliverydocumentbysupplier,
    e~gstin_no ,
    e~state_code2 ,
    e~plant_name1 ,
    e~address1 ,
    e~address2 ,
    e~city ,
    e~district ,
    e~state_name ,
    e~state_code1,
    e~pin ,
    e~country ,
    g~supplierfullname,
    i~documentdate,
    j~irnno ,
    j~ackno ,
    j~ackdate ,
    j~billingdocno  ,
    j~billingdate ,
    j~signedqrcode ,
    j~ewaybillno ,
    j~ewaydate ,
    j~transportergstin ,
    j~grno,
    j~grdate,
    j~vehiclenum,
    j~grossweight,
    j~netweight,
    j~transportername ,
    b~salesorganization ,
    l~salesorganizationname ,
    a~companycode
    FROM i_billingdocument AS a
    LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
    LEFT JOIN i_purchaseorderhistoryapi01 AS c ON b~batch = c~batch AND c~goodsmovementtype = '101'
    LEFT JOIN i_inbounddelivery AS d ON c~deliverydocument = d~inbounddelivery
    LEFT JOIN ztable_plant AS e ON e~plant_code = b~plant
    LEFT JOIN i_billingdocumentpartner AS f ON a~BillingDocument = f~BillingDocument
    LEFT JOIN I_Supplier AS g ON f~Supplier = g~Supplier
    LEFT JOIN i_materialdocumentitem_2 AS h ON h~purchaseorder = c~purchaseorder AND h~goodsmovementtype = '101'
    LEFT JOIN I_MaterialDocumentHeader_2 AS i ON h~MaterialDocument = i~MaterialDocument
    LEFT JOIN ztable_irn AS j ON j~billingdocno = a~BillingDocument AND a~CompanyCode = j~bukrs
    LEFT JOIN i_salesdocument AS k ON k~salesdocument = b~salesdocument
    LEFT JOIN I_SalesOrganizationText AS l ON l~SalesOrganization = b~SalesOrganization
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_header).
    DATA: materialordelivery TYPE string.

    SELECT SINGLE
    FROM i_billingdocumentitem AS a
    FIELDS ReferenceSDDocument
    WHERE a~billingdocument = @bill_doc AND a~ReferenceSDDocumentCategory = '2'
    INTO @DATA(material_doc).
    materialordelivery = material_doc.

    IF materialordelivery IS INITIAL.
      SELECT SINGLE
      FROM i_billingdocumentitem AS a
      FIELDS referencesddocument
      WHERE a~billingdocument = @bill_doc AND a~referencesddocumentcategory = 'J'
      INTO @DATA(delivery_no).
      materialordelivery = delivery_no.
    ENDIF.


    IF wa_header-ewaydate CS '-'.
      DATA(ewaydate) = wa_header-ewaydate+8(2) && '/' && wa_header-ewaydate+5(2) && '/' && wa_header-ewaydate(4).
    ELSEIF wa_header-ewaydate CS '/'.
      ewaydate = wa_header-ewaydate(10).
    ELSEIF wa_header-ewaydate IS INITIAL.
      ewaydate = ''.
    ENDIF.
*******************************************************
    SELECT SINGLE
    j~ackdate,
    substring( j~ackdate, 1, 10 ) AS ackdate_only
FROM ztable_irn AS j
WHERE j~billingdocno = @bill_doc
INTO @DATA(wa_AckDate).


**************************************************************************************partner Logic
    SELECT SINGLE
     a~SoldToParty
     FROM i_billingdocument AS a
     WHERE a~BillingDocument = @bill_doc
     INTO @DATA(wa_partnerBiilTo).

    SELECT SINGLE
 a~PurchaseOrderByCustomer
  FROM i_billingdocument AS a
  WHERE a~BillingDocument = @bill_doc
  INTO @DATA(wa_CUSTREF).
***************************************************************************************************brandname/carrieage/notify
    SELECT SINGLE  FROM ztable_irn AS a
    LEFT JOIN I_BillingDocumentItem AS b ON a~billingdocno = b~BillingDocument
    LEFT JOIN i_product AS c ON b~Product = c~Product
    LEFT JOIN I_BillingDocumentTP AS d ON a~billingdocno = d~BillingDocument
    LEFT JOIN I_PaymentTermsText AS e ON d~CustomerPaymentTerms = e~PaymentTerms
    LEFT JOIN zmaster_tab WITH PRIVILEGED ACCESS AS f ON c~YY1_brandcode_PRD = f~brandcode
    FIELDS a~placereceipopre ,
     c~YY1_brandcode_PRD ,
     d~YY1_NotifyParty_BDH ,
     d~TransactionCurrency ,
     e~PaymentTermsDescription,
     d~YY1_Remark_BDH,
     d~YY1_ApplicationPFINo_BDH,
     d~YY1_InspectionNo_BDH,
     f~brandtag
       WHERE a~billingdocno = @bill_doc
       INTO @DATA(wa_notify).
*
*************************brand multi code**************


    SELECT FROM ztable_irn AS a
    LEFT JOIN I_BillingDocumentItem AS b ON a~billingdocno = b~BillingDocument
    LEFT JOIN i_product AS c ON b~Product = c~Product
    LEFT JOIN I_BillingDocumentTP AS d ON a~billingdocno = d~BillingDocument
    LEFT JOIN I_PaymentTermsText AS e ON d~CustomerPaymentTerms = e~PaymentTerms
    LEFT JOIN zmaster_tab WITH PRIVILEGED ACCESS AS f ON c~YY1_brandcode_PRD = f~brandcode
    FIELDS a~placereceipopre ,
     c~YY1_brandcode_PRD ,
     d~YY1_NotifyParty_BDH ,
     d~TransactionCurrency ,
     e~PaymentTermsDescription,
     d~YY1_Remark_BDH,
     d~YY1_ApplicationPFINo_BDH,
     d~YY1_InspectionNo_BDH,
     f~brandtag
       WHERE a~billingdocno = @bill_doc
       INTO TABLE @DATA(multibrand).


    DATA: brandcode        TYPE string,
          lt_unique_brands TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line,
          lv_brand         TYPE string.

    CLEAR brandcode.

    LOOP AT multibrand INTO DATA(wa_brand).
      IF wa_brand-brandtag IS NOT INITIAL.
        lv_brand = wa_brand-brandtag.
        INSERT lv_brand INTO TABLE lt_unique_brands.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_unique_brands INTO lv_brand.
      IF brandcode IS INITIAL.
        brandcode = lv_brand.
      ELSE.
        CONCATENATE brandcode lv_brand INTO brandcode SEPARATED BY ','.
      ENDIF.
    ENDLOOP.


***************************************************


*************notify_party and third party  custom invoice *******************
    SELECT SINGLE FROM I_BillingDocument AS a
    LEFT JOIN I_PaymentTermsText AS b ON a~CustomerPaymentTerms = b~PaymentTerms
    LEFT JOIN I_BillingDocumentTP AS c ON a~BillingDocument = c~BillingDocument
     FIELDS
      c~YY1_NotifyParty_BDH ,
     b~PaymentTermsName,
     c~YY1_ThirdPartyName_BDH

      WHERE a~BillingDocument = @bill_doc
      INTO @DATA(wa_paymentterms).

*******************************************


    SHIFT wa_partnerBiilTo LEFT DELETING LEADING '0'.

    SELECT SINGLE
     a~SoldToParty
     FROM i_billingdocumentitem AS a
     LEFT JOIN i_salesdocumentitem AS b ON a~SalesDocument = b~SalesDocument
     WHERE a~BillingDocument = @bill_doc
     INTO @DATA(wa_partnerShipTo).

    SHIFT wa_partnerShipTo LEFT DELETING LEADING '0'.



***************************************************************************************************plantAddress

    p_add1 = wa_header-address1.
    p_add2 = wa_header-address2.
    p_dist = wa_header-district.
    p_city = wa_header-city .
    p_state = wa_header-state_name .
    p_pin =  wa_header-pin .
    p_statecode = wa_header-state_code1.
    p_name = wa_header-plant_name1.
*    p_country =  '(' &&  wa_header-country && ')' .


    CONCATENATE p_add1  p_add2  p_dist p_city   p_state '-' p_pin  INTO plant_add SEPARATED BY space.

    plant_name = wa_header-plant_name1.
    plant_gstin = wa_header-gstin_no.


    """""""""""""""""""""""""""""""""   BILL TO """""""""""""""""""""""""""""""""

    DATA: add1B        TYPE string,
          add2B        TYPE string,
          billcustomer TYPE string.

    SELECT SINGLE
    FROM I_BillingDocument AS a
    LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument AND b~partnerFunction = 'RE'
    LEFT JOIN i_customer AS c ON c~customer = b~Customer AND c~CustomerAccountGroup = 'CPD'
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
    LEFT JOIN i_countrytext AS f ON d~Country = f~Country
    LEFT JOIN i_onetimeaccountcustomer AS g ON g~AddressID = b~AddressID
    FIELDS
      g~streetaddressname,
      g~CityName,
      g~postalcode,
      f~CountryName,
      g~BusinessPartnerName1 AS customername,
      e~RegionName
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_bill1)
    PRIVILEGED ACCESS.

    SELECT SINGLE
FROM I_BillingDocument AS a
LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument AND b~partnerFunction = 'RE'
LEFT JOIN i_customer AS c ON c~customer = b~Customer
FIELDS
  a~BillingDocument,
  c~TelephoneNumber1,
  c~TelephoneNumber2
 WHERE a~BillingDocument = @bill_doc
INTO @DATA(wa_Bill_tell)
PRIVILEGED ACCESS.

    IF wa_bill1-streetaddressname IS NOT INITIAL.
      add1B = |{ wa_bill1-StreetAddressName }|.
    ENDIF.
    IF wa_bill1-streetaddressname IS NOT INITIAL AND wa_bill1-CityName IS NOT INITIAL.
      add1B = |{ wa_bill1-StreetAddressName },{ wa_bill1-CityName }|.
    ENDIF.
    IF wa_bill1-streetaddressname IS NOT INITIAL AND wa_bill1-CityName IS NOT INITIAL AND wa_bill1-PostalCode IS NOT INITIAL.
      add1B = |{ wa_bill1-StreetAddressName },{ wa_bill1-CityName },{ wa_bill1-PostalCode }|.
    ENDIF.
    IF  wa_bill1-RegionName  IS NOT INITIAL .
      add2B = |{ wa_bill1-RegionName }|.
    ENDIF.
    IF  wa_bill1-RegionName  IS NOT INITIAL AND wa_bill1-CountryName IS NOT INITIAL.
      add2B = |{ wa_bill1-RegionName },{ wa_bill1-CountryName }|.
    ENDIF.

    DATA BiiTO_telephone TYPE i_customer-telephonenumber1.
    IF wa_Bill_tell-TelephoneNumber1 IS NOT INITIAL AND wa_Bill_tell-TelephoneNumber2 IS INITIAL.
      BiiTO_telephone = wa_Bill_tell-TelephoneNumber1.
    ELSEIF wa_Bill_tell-TelephoneNumber1 IS INITIAL AND wa_Bill_tell-TelephoneNumber2 IS NOT INITIAL.
      BiiTO_telephone = wa_Bill_tell-TelephoneNumber2.
    ELSEIF wa_Bill_tell-TelephoneNumber1 IS NOT INITIAL AND wa_Bill_tell-TelephoneNumber2 IS NOT INITIAL.
      BiiTO_telephone = wa_Bill_tell-TelephoneNumber1.
    ENDIF.

    IF add1B IS INITIAL AND add2B IS INITIAL.
      SELECT SINGLE
    d~streetname ,         " bill to add
    d~streetprefixname1 ,   " bill to add
    d~streetprefixname2 ,   " bill to add
    d~cityname ,   " bill to add
    d~region ,  "bill to add
    d~postalcode ,   " bill to add
    d~districtname ,   " bill to add
    d~country  ,
    d~housenumber ,
    c~customername,
    e~regionname,
    f~countryname,
    c~taxnumber3,
    d~streetsuffixname1,
    d~streetsuffixname2
   FROM I_BillingDocument AS a
   LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
   LEFT JOIN i_customer AS c ON c~customer = b~Customer
   LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
   LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
   LEFT JOIN i_countrytext AS f ON d~Country = f~Country
   WHERE b~partnerFunction = 'RE' AND  a~BillingDocument = @bill_doc
   INTO @DATA(wa_bill)
   PRIVILEGED ACCESS.
      add1B = wa_bill-StreetName. " Start with StreetName
      IF wa_bill-StreetPrefixName1 IS NOT INITIAL.
        IF add1B IS NOT INITIAL.
          CONCATENATE add1B wa_bill-StreetPrefixName1 INTO add1B SEPARATED BY ' '.
        ELSE.
          add1B = wa_bill-StreetPrefixName1.
        ENDIF.
      ENDIF.
      IF wa_bill-StreetPrefixName2 IS NOT INITIAL.
        IF add1B IS NOT INITIAL.
          CONCATENATE add1B wa_bill-StreetPrefixName2 INTO add1B SEPARATED BY ' '.
        ELSE.
          add1B = wa_bill-StreetPrefixName2.
        ENDIF.
      ENDIF.
      add2B = wa_bill-CityName.
      IF wa_bill-PostalCode IS NOT INITIAL.
        IF add2B IS NOT INITIAL.
          CONCATENATE add2B wa_bill-PostalCode INTO add2B SEPARATED BY '- '.
        ELSE.
          add2B = wa_bill-PostalCode.
        ENDIF.
      ENDIF.

    ENDIF.

    IF wa_bill-CustomerName IS NOT INITIAL.
      billcustomer = wa_bill-CustomerName.
    ELSE.
      billcustomer = wa_bill1-CustomerName.
    ENDIF.

    DATA : wa_ad5_bill TYPE string.
    wa_ad5_bill = wa_bill-PostalCode.
    CONCATENATE wa_ad5_bill wa_bill-CityName  wa_bill-DistrictName INTO wa_ad5_bill SEPARATED BY space.


**************************************************************************Packing List Logic
    SELECT SINGLE
        FROM i_billingdocumentitem AS a
        LEFT JOIN I_SalesDocument AS c ON a~SalesDocument = c~SalesDocument
        LEFT JOIN I_SalesDocumentItem AS b ON a~SalesDocument = b~SalesDocument
    FIELDS b~ReferenceSDDocument , b~CreationDate , c~PurchaseOrderByCustomer
       WHERE a~BillingDocument = @bill_doc
        INTO @DATA(Wa_PerfomaInvoice).


    SELECT SINGLE
       FROM I_BillingDocumentItem AS a
       LEFT JOIN I_SalesDocumentItem AS b ON a~SalesDocument = b~SalesDocument
       LEFT JOIN I_SalesQuotation AS c ON b~ReferenceSDDocument = c~SalesQuotation
       LEFT JOIN I_SalesQuotationtp AS d ON c~SalesQuotation = d~SalesQuotation
       FIELDS
        d~YY1_CountryOfDestinati_SDH ,
        d~YY1_PortOfDischarge_SDH ,d~YY1_PortOfLoading_SDH
          WHERE a~BillingDocument = @bill_doc
       INTO @DATA(wa_Potloading).

    SELECT SINGLE
    FROM I_BillingDocument AS a
    LEFT JOIN I_PaymentTermsText AS b ON a~CustomerPaymentTerms = b~PaymentTerms
    FIELDS a~IncotermsClassification , b~PaymentTermsName
       WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_incoterms).
    SELECT SINGLE
    FROM I_BillingDocumentItem AS a
    LEFT JOIN I_Salesorder AS b ON a~SalesDocument = b~SalesOrder
    FIELDS b~IncotermsClassification
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(incoterms).



    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""SHIP TO  Address

    DATA: add1S        TYPE string,
          add2S        TYPE string,
          ShipCustomer TYPE string.


    SELECT SINGLE
   FROM I_BillingDocumentitem AS a
   LEFT JOIN I_BillingDocItemPartner AS b ON b~billingdocument = a~billingdocument AND b~partnerFunction = 'WE'
   LEFT JOIN i_customer AS c ON c~customer = b~Customer AND c~CustomerAccountGroup = 'CPD'
   LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
   LEFT JOIN I_RegionText AS e ON e~Region = d~Region AND e~Country = d~Country
   LEFT JOIN i_countrytext AS g ON e~Country = g~Country
   LEFT JOIN i_onetimeaccountcustomer AS f ON b~AddressID = f~AddressID
   FIELDS
   f~streetaddressname,
   f~CityName,
   f~postalcode,
   g~CountryName,
   c~TelephoneNumber1,
   c~TelephoneNumber2,
   f~BusinessPartnerName1 AS customername,
   e~RegionName
   WHERE a~BillingDocument = @bill_doc
   AND c~Language = 'E'
   AND a~BillingDocument = @bill_doc
   INTO @DATA(wa_ship1)
   PRIVILEGED ACCESS.

    SELECT SINGLE
    FROM I_BillingDocumentitem AS a
    LEFT JOIN I_BillingDocItemPartner AS b ON b~billingdocument = a~billingdocument AND b~partnerFunction = 'WE'
    LEFT JOIN i_customer AS c ON c~customer = b~Customer
    FIELDS
    c~TelephoneNumber1,
    c~TelephoneNumber2
    WHERE a~BillingDocument = @bill_doc
    AND c~Language = 'E'
    INTO @DATA(wa_ship_Tell)
    PRIVILEGED ACCESS.

    IF  wa_ship1-StreetAddressName IS NOT INITIAL.
      add1S = |{ wa_ship1-StreetAddressName }|.
    ENDIF.
    IF wa_ship1-StreetAddressName IS NOT INITIAL AND wa_ship1-CityName IS NOT INITIAL.
      add1S = |{ wa_ship1-StreetAddressName },{ wa_ship1-CityName }|.
    ENDIF.
    IF wa_ship1-StreetAddressName IS NOT INITIAL AND wa_ship1-CityName IS NOT INITIAL AND wa_ship1-PostalCode IS NOT INITIAL.
      add1S = |{ wa_ship1-StreetAddressName },{ wa_ship1-CityName },{ wa_ship1-PostalCode }|.
    ENDIF.

    IF wa_ship1-RegionName  IS NOT INITIAL.
      add2S = |{ wa_ship1-RegionName }|.
    ENDIF.
    IF wa_ship1-RegionName IS NOT INITIAL AND wa_ship1-CountryName IS NOT INITIAL.
      add2S = |{ wa_ship1-RegionName },{ wa_ship1-CountryName },|.
    ENDIF.

    DATA ShipTo_telephone TYPE i_customer-telephonenumber1.
    IF wa_ship_Tell-TelephoneNumber1 IS NOT INITIAL AND wa_ship_Tell-TelephoneNumber2 IS INITIAL.
      ShipTo_telephone = wa_ship_Tell-TelephoneNumber1.
    ELSEIF wa_ship_Tell-TelephoneNumber1 IS INITIAL AND wa_ship_Tell-TelephoneNumber2 IS NOT INITIAL.
      ShipTo_telephone = wa_ship_Tell-TelephoneNumber2.
    ELSEIF wa_ship_Tell-TelephoneNumber1 IS NOT INITIAL AND wa_ship_Tell-TelephoneNumber2 IS NOT INITIAL.
      ShipTo_telephone = wa_ship_Tell-TelephoneNumber1.
    ENDIF.

    IF add1S IS INITIAL AND add2S IS INITIAL.

      SELECT SINGLE
      d~streetname ,
      d~streetprefixname1 ,
      d~streetprefixname2 ,
      d~cityname ,
      d~region ,
      d~postalcode ,
      d~districtname ,
      d~country  ,
      d~housenumber ,
      c~customername ,
      a~soldtoparty ,
      e~regionname ,
      c~taxnumber3
     FROM I_BillingDocumentitem AS a
     LEFT JOIN I_BillingDocItemPartner AS b ON b~billingdocument = a~billingdocument
     LEFT JOIN i_customer AS c ON c~customer = b~Customer
     LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
     LEFT JOIN I_RegionText AS e ON e~Region = d~Region AND e~Country = d~Country
     WHERE b~partnerFunction = 'WE' AND  a~BillingDocument = @bill_doc
     AND c~Language = 'E'
     AND a~BillingDocument = @bill_doc
     INTO @DATA(wa_ship)
     PRIVILEGED ACCESS.


      add1S = wa_ship-StreetName. " Start with StreetName
      IF wa_ship-StreetPrefixName1 IS NOT INITIAL.
        IF add1S IS NOT INITIAL.
          CONCATENATE add1S wa_ship-StreetPrefixName1 INTO add1S SEPARATED BY ' '.
        ELSE.
          add1S = wa_ship-StreetPrefixName1.
        ENDIF.
      ENDIF.
      IF wa_ship-StreetPrefixName2 IS NOT INITIAL.
        IF add1S IS NOT INITIAL.
          CONCATENATE add1S wa_ship-StreetPrefixName2 INTO add1S SEPARATED BY ' '.
        ELSE.
          add1S = wa_ship-StreetPrefixName2.
        ENDIF.
      ENDIF.
      add2S = wa_ship-CityName.
      IF wa_ship-PostalCode IS NOT INITIAL.
        IF add2S IS NOT INITIAL.
          CONCATENATE add2S wa_ship-PostalCode INTO add2S SEPARATED BY '- '.
        ELSE.
          add2S = wa_ship-PostalCode.
        ENDIF.
      ENDIF.
    ENDIF.

    IF wa_ship-CustomerName IS NOT INITIAL.
      shipcustomer = wa_ship-CustomerName.
    ELSE.
      shipcustomer = wa_ship1-CustomerName.
    ENDIF.

    DATA : wa_ad5_ship TYPE string.
    wa_ad5_ship = wa_ship-PostalCode.
    CONCATENATE wa_ad5_ship wa_ship-CityName  wa_ship-DistrictName INTO wa_ad5_ship SEPARATED BY space.

**********************************************************************PLANT GST

    SELECT SINGLE
    c~taxnumber3 ,
    d~streetname ,
    d~streetprefixname1 ,
    d~streetprefixname2 ,
    d~cityname ,
    d~region ,
    d~postalcode ,
    d~districtname ,
    d~country  ,
    d~housenumber
    FROM i_billingdocumentitem AS a
    LEFT JOIN i_plant AS b ON b~plant = a~plant
    LEFT JOIN i_customer AS c ON c~customer = b~plantcustomer
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    WHERE a~billingdocument = @bill_doc
    INTO @DATA(wa_plantgst)
     PRIVILEGED ACCESS.


**********************************************************************
    SELECT SINGLE FROM ztable_irn AS a
    FIELDS a~irnno , a~signedqrcode , a~ewaybillno , a~ewaydate
    WHERE a~billingdocno = @bill_doc
    INTO @DATA(wa_irn).

    """""""""""""""""""""""""""""""""""ITEM DETAILS"""""""""""""""""""""""""""""""""""

    SELECT
      a~billingdocument,
      a~billingdocumentitem,
      a~product,
      a~ReferenceSDDocument,
      a~batch,
      a~plant,
      a~netamount,
      a~ItemGrossWeight,
      a~ItemNetWeight,
      a~salesdocumentitemcategory,
      b~handlingunitreferencedocument,
      b~material,
      b~handlingunitexternalid,
      c~packagingmaterial,
      d~productdescription,
      e~materialbycustomer ,
      f~consumptiontaxctrlcode  ,   "HSN CODE
      a~billingdocumentitemtext ,   "mat
      a~billingquantity  ,  "Quantity
      a~billingquantityunit  ,  "UOM
      g~conditionratevalue   ,  " i_per
      g~conditionamount ,
      g~conditionbasevalue,
      g~conditiontype,
      h~UnitOfMeasure_E
*      g~CndnRoundingOffDiffAmount
      FROM I_BillingDocumentItem AS a
      LEFT JOIN i_handlingunititem AS b ON a~referencesddocument = b~handlingunitreferencedocument
      LEFT JOIN i_handlingunitheader AS c ON b~handlingunitexternalid = c~handlingunitexternalid
      LEFT JOIN i_productdescription AS d ON d~product = c~packagingmaterial
      LEFT JOIN I_UnitOfMeasureText AS h ON a~BillingQuantityUnit = h~UnitOfMeasure AND h~Language = 'E'
      LEFT JOIN I_SalesDocumentItem AS e ON e~SalesDocument = a~SalesDocument AND e~salesdocumentitem = a~salesdocumentitem
      LEFT JOIN i_productplantbasic AS f ON a~Product = f~Product AND a~Plant = f~Plant
      LEFT JOIN i_billingdocumentitemprcgelmnt AS g ON g~BillingDocument = a~BillingDocument AND g~BillingDocumentItem = a~BillingDocumentItem
      WHERE a~billingdocument = @bill_doc
       AND  a~billingquantity NE ''
      INTO TABLE  @DATA(it_item)
      PRIVILEGED ACCESS.



    SELECT SUM( ConditionAmount ) AS rounding_sum,
       BillingDocument
  FROM I_BillingDocumentItemPrcgElmnt
  WHERE BillingDocument = @bill_doc
    AND ConditionType = 'DRD1'
  GROUP BY BillingDocument
  INTO TABLE @DATA(it_round).





    SORT it_item BY billingdocument BillingDocumentItem.
    DELETE ADJACENT DUPLICATES FROM it_item COMPARING BillingDocument BillingDocumentItem.


    DATA : discount TYPE p DECIMALS 3.

*      out->write( it_item ).
*    out->write( wa_header ).

    DATA: temp_add TYPE string.
    temp_add = wa_bill-postalcode.
    CONCATENATE temp_add wa_bill-CityName wa_bill-DistrictName INTO temp_add.

    SELECT SUM( conditionamount )
FROM i_billingdocitemprcgelmntbasic
WHERE billingdocument = @bill_doc
  AND conditiontype = 'ZFRT'
      AND ConditionInactiveReason IS INITIAL
  INTO @DATA(freight).

    SELECT SUM( conditionamount )
FROM i_billingdocitemprcgelmntbasic
WHERE billingdocument = @bill_doc
    AND ConditionInactiveReason IS INITIAL
AND conditiontype = 'ZTCS'
INTO @DATA(tcs).

    SELECT SUM( conditionamount )
FROM i_billingdocitemprcgelmntbasic
WHERE billingdocument = @bill_doc
AND conditiontype = 'ZPCK'
    AND ConditionInactiveReason IS INITIAL
INTO @DATA(PackingCharging).

    SELECT SUM( conditionamount )
    FROM i_billingdocitemprcgelmntbasic
    WHERE billingdocument = @bill_doc
    AND conditiontype = 'ZINS'
        AND ConditionInactiveReason IS INITIAL
    INTO @DATA(Insurance).

*    DATA InvoiceCopyName TYPE c LENGTH 25.
*    IF printform = 'expoOriginal' OR printform = 'stoOriginal' OR printform = 'DCOriginal'.
*      InvoiceCopyName = 'Original For Buyer' .
*    ELSEIF printform = 'expoTransporter' OR printform = 'stoDuplicate' OR printform = 'DCDuplicate'.
*      InvoiceCopyName = 'Duplicate For Transporter'.
*    ELSEIF printform = 'expoOffice'  OR printform = 'stoOffice' OR printform = 'DCOffice' .
*      InvoiceCopyName = 'Office Copy'.
*    ENDIF.


**********************************************Commercial invoice Notify Party******************************

    SELECT SINGLE FROM I_BillingDocumentItem AS a
           LEFT JOIN i_deliverydocumentitem AS b ON a~ReferenceSDDocument = b~DeliveryDocument AND a~ReferenceSDDocumentItem = b~DeliveryDocumentItem
           LEFT JOIN I_SalesOrder AS c ON b~ReferenceSDDocument = c~SalesOrder
           LEFT JOIN I_SalesQuotationPartner AS d ON c~ReferenceSDDocument = d~SalesQuotation
           LEFT JOIN I_customer AS e ON d~Customer = e~Customer
           LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS f ON e~AddressID = f~AddressID
           LEFT JOIN I_RegionText AS g ON f~Region = g~Region AND f~Country = g~Country
           FIELDS d~FullName,d~Customer, f~streetname ,
                f~streetprefixname1 ,
                f~streetprefixname2 ,
                f~cityname ,
                f~region ,
                f~postalcode ,
                f~districtname ,
                f~country  ,
                f~housenumber ,
                a~soldtoparty ,
                g~regionname
           WHERE d~PartnerFunction = 'WE' AND a~BillingDocument = @bill_doc
           INTO @DATA(notify_comm).


    DATA: addnotify TYPE string.

    addnotify = notify_comm-StreetName.

    IF notify_comm-StreetPrefixName1 IS NOT INITIAL.
      IF addnotify IS NOT INITIAL.
        CONCATENATE addnotify notify_comm-StreetPrefixName1 INTO addnotify SEPARATED BY ', '.
      ELSE.
        addnotify = notify_comm-StreetPrefixName1.
      ENDIF.
    ENDIF.

    IF notify_comm-StreetPrefixName2 IS NOT INITIAL.
      IF addnotify IS NOT INITIAL.
        CONCATENATE addnotify notify_comm-StreetPrefixName2 INTO addnotify SEPARATED BY ', '.
      ELSE.
        addnotify = notify_comm-StreetPrefixName2.
      ENDIF.
    ENDIF.
***************************************container Logic
    SELECT SINGLE
       c~YY1_NoofContainers_SDI,
       c~YY1_ContType_SDI
   FROM I_BillingDocumentItem AS a
   LEFT JOIN I_SalesDocumentItem AS b ON a~SalesDocument = b~SalesDocument AND a~SalesDocumentItem = b~SalesDocumentItem
   LEFT JOIN i_salesquotationitemtp AS c ON b~ReferenceSDDocument = c~salesquotation AND b~ReferenceSDDocumentItem = c~SalesQuotationItem
   WHERE a~BillingDocument = @bill_doc
   INTO @DATA(wa_container).

    DATA(lv_xml) =
    |<Form>| &&
    |<BillingDocumentNode>| &&
    |<AckDate>{ wa_ackdate-ackdate_only }</AckDate>| &&
    |<AckNumber>{ wa_header-ackno }</AckNumber>| &&
    |<BillingDate>{ wa_header-billingdate }</BillingDate>| &&
    |<RecieptCariage>{ wa_notify-placereceipopre }</RecieptCariage>| &&
    |<ExchangeRate>{ wa_header-AccountingExchangeRate }</ExchangeRate>| &&
    |<BrandCode>{ brandcode }</BrandCode>| &&
    |<InspectionNo>{ wa_notify-YY1_InspectionNo_BDH }</InspectionNo>| &&
    |<ApplicationNo>{ wa_notify-YY1_ApplicationPFINo_BDH }</ApplicationNo>| &&
    |<NotifyParty>{ wa_paymentterms-YY1_NotifyParty_BDH }</NotifyParty>| &&
    |<ThirdParty>{ wa_paymentterms-YY1_ThirdPartyName_BDH }</ThirdParty>| &&
    |<NotifyParty_comm>{ notify_comm-FullName }</NotifyParty_comm>| &&
    |<NotifyParty_add>{ addnotify }</NotifyParty_add>| &&
    |<TransactionCurrency>{ wa_notify-TransactionCurrency }</TransactionCurrency>| &&
    |<IRN>{ wa_irn-irnno }</IRN>| &&
    |<SignedQRCode>{ wa_irn-signedqrcode }</SignedQRCode>| &&
    |<EwayNo>{ wa_irn-ewaybillno }</EwayNo>| &&
    |<Fright>{ freight }</Fright>| &&
    |<TCS>{ tcs }</TCS>| &&
    |<Originalheader></Originalheader>| &&
    |<PackingCharges>{ PackingCharging }</PackingCharges>| &&
    |<Insurance>{ Insurance }</Insurance>| &&
    |<Remark>{ wa_notify-YY1_Remark_BDH }</Remark>| &&
    |<BilltoTel>{ biito_telephone }</BilltoTel>| &&
    |<ShiptoTel>{ shipto_telephone }</ShiptoTel>| &&
*    |<NoofContainers>{ container_no_count }</NoofContainers>| &&
    |<ContType>{ wa_container-YY1_ContType_SDI }</ContType>| .

**********************************************************************BILLINGDOCUMENTDATE

    DATA(lv_date) = wa_header-BillingDocumentDate.

    " Format as YYYY-MM-DD
    DATA(lv_formatted_date) = lv_date(4) && '-' && lv_date+4(2) && '-' && lv_date+6(2).

    " Remove unwanted spaces (if any)
    CONDENSE lv_formatted_date.


    DATA(lv_header5) =
        |<BillingDocumentDate>{ lv_formatted_date }</BillingDocumentDate>| .

    CONCATENATE lv_xml lv_header5 INTO lv_xml.


**********************************************************************BILLINGDOCUMENTDATE


**********************************************************************EWAYDATE
    DATA(lv_ewayheader) =
        |<EWAYBILLDATE>{ ewaydate }</EWAYBILLDATE>| .

    CONCATENATE lv_xml lv_ewayheader INTO lv_xml.

**********************************************************************EWAYDATE

**********************************************************************FSSAINO
    SELECT SINGLE
    a~billingdocument ,
    c~fssai_no,
    c~gstin_no,
    c~pan_no,
    c~phone
    FROM i_billingdocument AS a
    LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
    LEFT JOIN ztable_plant AS c ON c~comp_code = b~CompanyCode AND c~plant_code = b~Plant
    WHERE a~BillingDocument = @bill_doc
    AND b~BillingDocument = @bill_doc
    INTO @DATA(wa_fssai)
    PRIVILEGED ACCESS.

    DATA(lv_fssai) =
       |<FSSAINO>{ wa_fssai-fssai_no }</FSSAINO>| &&
       |<PlantGST>{ wa_fssai-gstin_no }</PlantGST>| &&
       |<PlantPan>{ wa_fssai-pan_no }</PlantPan>| &&
        |<PlantPhone>{ wa_fssai-phone }</PlantPhone>|.

    CONCATENATE lv_xml lv_fssai INTO lv_xml.


**********************************************************************FSSAINO

    DATA(lv_header2) =

    |<DocumentReferenceID>{ wa_header-DocumentReferenceID }</DocumentReferenceID>| &&
    |<PerformaInvoice>{ wa_perfomainvoice-ReferenceSDDocument }</PerformaInvoice>| &&
    |<PerformaInvoiceDate>{ wa_perfomainvoice-CreationDate }</PerformaInvoiceDate>| &&
    |<packCustRef>{ wa_perfomainvoice-PurchaseOrderByCustomer }</packCustRef>| &&
    |<Countrydestination>{ wa_potloading-YY1_CountryOfDestinati_SDH }</Countrydestination>| &&
    |<PortOfDischarge>{ wa_potloading-YY1_PortOfDischarge_SDH }</PortOfDischarge>| &&
    |<PortOfLoading>{ wa_potloading-YY1_PortOfLoading_SDH }</PortOfLoading>| &&
    |<ShippingTerms>{ incoterms }</ShippingTerms>| &&
    |<PaymentTerms>{ wa_incoterms-PaymentTermsName }</PaymentTerms>| &&
    |<EWAYBILLNO>{ wa_header-ewaybillno }</EWAYBILLNO>| &&
    |<TRANSPORTERGSTIN>{ wa_header-transportergstin }</TRANSPORTERGSTIN>| &&
    |<TRANSPORTERNAME>{ wa_header-transportername }</TRANSPORTERNAME>| &&
    |<GRNO>{ wa_header-grno }</GRNO>| &&
    |<Deliverymaterialcode>{ materialordelivery }</Deliverymaterialcode>| &&
    |<GRDATE>{ wa_header-grdate }</GRDATE>| &&
    |<VehicleNo>{ wa_header-vehiclenum }</VehicleNo>| &&
    |<GrosWeight>{ wa_header-grossweight }</GrosWeight>| &&
    |<NetWeight>{ wa_header-netweight }</NetWeight>| &&
    |<YY1_PLANT_COM_ADD_BDH>{ plant_add }</YY1_PLANT_COM_ADD_BDH>| &&
    |<YY1_PLANT_COM_NAME_BDH>{ p_name }</YY1_PLANT_COM_NAME_BDH>| &&
    |<YY1_PLANT_COM_GSTIN_NO_BDH>{ plant_gstin }</YY1_PLANT_COM_GSTIN_NO_BDH>| &&
    |<PlantState>{ p_state }</PlantState>| &&
    |<PlantStateCode>{ p_statecode }</PlantStateCode>| &&
    |<Supplier>| &&
    |<CompanyCode>{ wa_header-CompanyCode }</CompanyCode>| &&
    |<HEADERCompanyCode>{ wa_header-CompanyCode }</HEADERCompanyCode>| &&
    |</Supplier>| &&
    |<Company>| &&
    |<CompanyName>{ wa_header-SalesOrganizationName }</CompanyName>| &&
    |<AddressLine1Text>{ wa_plantgst-StreetName }</AddressLine1Text>| &&
    |<AddressLine2Text>{ wa_plantgst-StreetPrefixName1 }</AddressLine2Text>| &&
    |<AddressLine3Text>{ wa_plantgst-StreetPrefixName2 }</AddressLine3Text>| &&
    |<AddressLine4Text>{ wa_plantgst-CityName }</AddressLine4Text>| &&
    |<AddressLine5Text>{ wa_plantgst-DistrictName }</AddressLine5Text>| &&
    |<AddressLine6Text>{ wa_plantgst-PostalCode }</AddressLine6Text>| &&
    |<AddressLine7Text>{ wa_plantgst-Region }</AddressLine7Text>| &&
    |<AddressLine8Text>{ wa_plantgst-Country }</AddressLine8Text>| &&
    |</Company>| &&
    |<BillToParty>| &&
    |<AddressLine3Text>{ add1b }</AddressLine3Text>| &&
    |<AddressLine4Text>{ add2b }</AddressLine4Text>| &&
    |<AddressLine5Text></AddressLine5Text>| &&
    |<AddressLine6Text></AddressLine6Text>| &&
    |<AddressLine7Text></AddressLine7Text>| &&
    |<AddressLine8Text>{ temp_add }</AddressLine8Text>| &&
    |<FullName>{ billcustomer }</FullName>| &&   " done
    |<Partner>{ wa_partnerBiilTo }</Partner>| &&
    |<CustomerRef>{ wa_custref }</CustomerRef>| &&
    |<RegionName>{ wa_bill-RegionName }</RegionName>| &&
    |</BillToParty>| &&
    |<Items>|.

    CONCATENATE lv_xml lv_header2 INTO lv_xml.


*****************************************************************************************Description Of Goods

    SELECT a~billingdocument, a~ReferenceSDDocument ,a~product, a~billingquantity, c~yy1_containerno_bdi AS ContainerNo
    FROM i_billingdocument AS b
    INNER JOIN i_billingdocumentitem AS a
      ON b~billingdocument = a~billingdocument
    INNER JOIN i_billingdocumentitem AS ref
      ON a~ReferenceSDDocument = ref~ReferenceSDDocument
    INNER JOIN i_billingdocumentitemtp AS c
    ON a~BillingDocument = c~billingdocument AND a~BillingDocumentItem = c~billingdocumentitem
    WHERE ref~billingdocument = @bill_doc
      AND b~sddocumentcategory = 'M'
       AND a~billingquantity <> 0
    INTO TABLE @DATA(wa_GoodsDescription).



    SELECT
    FROM i_billingdocument AS b
    INNER JOIN i_billingdocumentitem AS a
      ON b~billingdocument = a~billingdocument
    INNER JOIN i_billingdocumentitem AS ref
      ON a~ReferenceSDDocument = ref~ReferenceSDDocument
    LEFT JOIN zmaterialtext AS c
      ON a~Product = c~materialcode
      FIELDS a~product, a~billingquantity, c~material_text AS materialtext , c~materialcode , a~BillingDocument
    WHERE ref~billingdocument = @bill_doc
      AND b~sddocumentcategory = 'M'
      AND a~billingquantity <> 0
    INTO TABLE @DATA(wa_PCKDescription).

***************************************************************************************************************************CUSTOM INVOICE
    SELECT FROM I_BillingDocumentItem AS a
    INNER JOIN I_BillingDocumentTP AS e ON a~BillingDocument = e~BillingDocument
    INNER JOIN I_SalesOrderItem AS f ON a~SalesDocument = f~SalesOrder
    INNER JOIN I_SalesQuotationItemTP AS i ON f~ReferenceSDDocument = i~SalesQuotation AND f~SalesOrderItem = i~SalesQuotationItem
    INNER JOIN I_BillingDocumentItemPrcgElmnt AS b ON a~BillingDocument = b~BillingDocument AND a~BillingDocumentItem = b~BillingDocumentItem AND b~ConditionType = 'PPR0'
    LEFT JOIN I_BillingDocumentItemPrcgElmnt AS c ON a~BillingDocument = c~BillingDocument AND a~BillingDocumentItem = c~BillingDocumentItem AND c~ConditionType = 'ZDQT'
    LEFT JOIN I_BillingDocumentItemPrcgElmnt AS d ON a~BillingDocument = d~BillingDocument AND a~BillingDocumentItem = d~BillingDocumentItem AND d~ConditionType = 'ZDPT'
    LEFT JOIN I_BillingDocumentItemPrcgElmnt AS g ON a~BillingDocument = g~BillingDocument AND a~BillingDocumentItem = g~BillingDocumentItem AND g~ConditionType = 'ZFRT'
    LEFT JOIN I_BillingDocumentItemPrcgElmnt AS h ON a~BillingDocument = h~BillingDocument AND a~BillingDocumentItem = h~BillingDocumentItem AND h~ConditionType = 'ZINS'
    LEFT JOIN I_BillingDocumentItemPrcgElmnt AS j ON a~BillingDocument = j~BillingDocument AND a~BillingDocumentItem = j~BillingDocumentItem AND j~ConditionType = 'ZPCK'
    FIELDS
     a~BillingQuantity,
     a~BillingDocument,
     a~Batch,
     a~BillingDocumentItem,
     a~ItemNetWeight,
     b~ConditionAmount AS b_qty ,
     c~ConditionAmount AS c_qty ,
     d~ConditionAmount AS d_qty,
     g~ConditionAmount AS g_qty ,
     h~ConditionAmount AS h_qty,
     e~YY1_DFAIDate_BDH,
     e~YY1_DFIANo_BDH,
     a~SalesDocument
    ,f~ReferenceSDDocument,
    j~ConditionAmount AS j_qty
*,i~YY1_ContNo_SDI,i~YY1_ContType_SDI,i~YY1_NoofContainers_SDI,
    WHERE a~BillingDocument = @bill_doc AND a~BillingQuantity NE 0
    INTO TABLE @DATA(it).

    SORT it BY BillingDocument BillingDocumentItem.
    DELETE ADJACENT DUPLICATES FROM it COMPARING ALL FIELDS.

    SELECT SUM( conditionamount )
    FROM I_BillingDocumentItemPrcgElmnt
    WHERE billingdocument = @bill_doc
      AND conditiontype = 'ZDPT'
      INTO @DATA(dis_custom_pt).

    SELECT SUM( conditionamount )
  FROM I_BillingDocumentItemPrcgElmnt
  WHERE billingdocument = @bill_doc
    AND ConditionType = 'ZDQT'
    INTO @DATA(dis_custom_qt).

    SELECT SUM( conditionamount )
    FROM I_BillingDocumentItemPrcgElmnt
    WHERE billingdocument = @bill_doc
      AND conditiontype = 'ZFRT'
      INTO @DATA(frt_custom).

***************************************************************************************************************************CUSTOM INVOICE

    DATA:
      cif_qty       TYPE p DECIMALS 5,
      dis           TYPE I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
      fob           TYPE I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
      frt           TYPE I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
      ins           TYPE I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
      dis_ttl       TYPE I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
      other_charges TYPE I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
      netweight     TYPE p LENGTH 6 DECIMALS 3,
      dfaidate      TYPE d,
      dfaino        TYPE c LENGTH 10.


    DATA container_no_count TYPE i.
    SELECT DISTINCT yy1_containerno_bdi
     FROM i_billingdocumentitemtp
     WHERE billingdocument = @bill_doc
       AND yy1_containerno_bdi IS NOT INITIAL
         INTO TABLE @DATA(wa_container_no).

    container_no_count = lines( wa_container_no ).

******************************Batches for Packing List*********************
    SELECT
            a~Product,
            a~Batch,
            a~Plant,
            a~Billingdocument,
            a~billingdocumentitem,
            a~billingquantity,
            a~ReferenceSDDocument,
            b~matlbatchavailabilitydate,
            b~ManufactureDate,
            b~shelflifeexpirationdate,
            d~NetWeight AS NetWeight_cust_pkg,
            d~GrossWeight AS GrossWeight_cust_pkg,
            c~ConsumptionTaxCtrlCode AS hsncode_cust_pkg,
            e~ActualDeliveryQuantity AS TOtalCTNS_Cust_pkg,
            a~salesdocument,
            a~salesdocumentitem
        FROM I_BillingDocumentItem AS a
        LEFT JOIN i_batch AS b
            ON a~Product = b~Material
            AND a~Batch = b~Batch
            AND a~Plant = b~Plant
        LEFT JOIN i_productplantbasic AS c
            ON b~Material = c~Product AND b~Plant = c~Plant
        LEFT JOIN I_Product AS d
            ON c~Product = d~Product
        LEFT JOIN I_DeliveryDocumentItem AS e
            ON a~ReferenceSDDocument = e~DeliveryDocument
            AND a~ReferenceSDDocumentItem = e~DeliveryDocumentItem
        WHERE
            a~BillingDocument = @bill_doc
        INTO TABLE @DATA(lt_batches).
    SORT lt_batches BY BillingDocument BillingDocumentItem.
    DATA(item_size) = lines( it_item ).
    DATA(batch_size) = lines( lt_batches ).
******************************************************************************************************

    DATA(lv_sum) = 0.
    LOOP AT it_item INTO DATA(wa_item).
***********************************************************************************************************************08.05 Given By Gill Sir
***********************************************************************************************************************

      DATA(lv_item) =
      |<BillingDocumentItemNode>|.
      CONCATENATE lv_xml lv_item INTO lv_xml.

      DATA(lv_container_xml) = ``.
      DATA(lv_material_text) = ``.
***************************************************************************************************************************** Logic added by vinay on 04-06-2025

      SELECT SINGLE
       NetWeight,
       GrossWeight
       FROM I_Product
       WHERE Product = @wa_item-product
       INTO @DATA(wa_product_weight).

      DATA(PackingListNodes) = |<PackingListNode>| &&
                               |<PACKLI_HSNCODE>{ wa_item-ConsumptionTaxCtrlCode }</PACKLI_HSNCODE>| &&
                               |<PACKLI_NetWeight>{ wa_product_weight-NetWeight }</PACKLI_NetWeight>| &&
                               |<PACKLI_GrossWeight>{ wa_product_weight-GrossWeight }</PACKLI_GrossWeight>| &&
                               |<PACKLI_TotalQty>{ wa_item-BillingQuantity }</PACKLI_TotalQty>| &&
                               |<PACKLI_TotalNetweight>{ wa_item-ItemNetWeight }</PACKLI_TotalNetweight>| &&
                               |<PAckLI_TotalGrossWeight>{ wa_item-ItemGrossWeight }</PAckLI_TotalGrossWeight>| &&
                               |</PackingListNode>|.

      CONCATENATE lv_xml PackingListNodes INTO lv_xml.

******************************************************************************************************************************CUSTOM INVOICE

      LOOP AT it INTO DATA(wa_foter) .
        frt += wa_foter-g_qty.
        ins += wa_foter-h_qty.
        other_charges += wa_foter-j_qty.
      ENDLOOP.

*      dis  = dis_custom_pt * ( -1 ) + dis_custom_qt * ( -1 ).

       dis  = dis_custom_pt  + dis_custom_qt .

      SELECT SINGLE YY1_ContainerNo_BDI,billingdocumentitem
        FROM i_billingdocumentitemtp
        WHERE billingdocument = @bill_doc
          AND billingdocumentitem = @wa_item-BillingDocumentItem
        INTO  @DATA(container_no).

      DATA(lv_fright) =
          |<ItemContainerNo>{ container_no-YY1_ContainerNo_BDI }</ItemContainerNo>| &&
          |<CustFreight>{ freight }</CustFreight>| &&
          |<CustInsurance>{ Insurance }</CustInsurance>| &&
          |<DFAIDate>{ wa_foter-YY1_DFAIDate_BDH }</DFAIDate>| &&
          |<DFAIno>{ wa_foter-YY1_DFIANo_BDH }</DFAIno>| &&
          |<otherCharges>{ PackingCharging }</otherCharges>| .
      CONCATENATE lv_xml lv_fright INTO lv_xml.
      CLEAR:frt,ins,other_charges.
      READ TABLE it WITH KEY BillingDocument = wa_item-BillingDocument BillingDocumentItem = wa_item-BillingDocumentItem INTO DATA(wa_cust).
      IF sy-subrc = 0.

        cif_qty = wa_cust-b_qty - ( ( wa_cust-c_qty * ( -1 ) ) +  ( wa_cust-d_qty * ( -1 ) ) ).
        fob += cif_qty.
        cif_qty = wa_cust-b_qty + wa_cust-g_qty + wa_cust-h_qty.
        cif_qty = cif_qty / wa_cust-ItemNetWeight.


        netweight = wa_cust-ItemNetWeight.


        " Generate CustomInvoice XML node for the retrieved item
        DATA(lv_CustInvoice) =
          |<CustomInvoice>| &&
          |<CustCIFQuantity>{ cif_qty }</CustCIFQuantity>| &&
          |<CustFOB>{ fob }</CustFOB>| &&
          |<netWeight>{ netweight }</netWeight>| &&
          |<CustDiscTotal>{ dis }</CustDiscTotal>| &&
          |</CustomInvoice>|.

        " Add to XML structure
        CONCATENATE lv_xml lv_CustInvoice INTO lv_xml.
      ENDIF.
      CLEAR: cif_qty, dis,frt, ins, dis_ttl, wa_cust , DFAIDate,DFAInO.
*
******************************************************************************************************************************CUSTOM INVOICE

      " Find container data
      LOOP AT wa_GoodsDescription INTO DATA(wa_cont)
        WHERE ReferenceSDDocument = wa_item-ReferenceSDDocument
          AND Product = wa_item-Product.
        lv_container_xml = wa_cont-containerno .
      ENDLOOP.



      " Find material description
      LOOP AT wa_PCKDescription INTO DATA(wa_pck)
        WHERE Product = wa_item-Product.
        lv_material_text = wa_pck-materialtext .
      ENDLOOP.

      READ TABLE it_round WITH KEY BillingDocument  = wa_item-BillingDocument  INTO DATA(wa_round).

      " Main item details
      DATA(lv_item_xml) =
      |<BillingDocumentItemText>{ wa_item-Product }</BillingDocumentItemText>| &&
      |<IN_HSNOrSACCode>{ wa_item-consumptiontaxctrlcode }</IN_HSNOrSACCode>| &&
      |<netWeight>{ wa_item-ItemNetWeight }</netWeight>| &&
      |<grossWeight>{ wa_item-ItemGrossWeight }</grossWeight>| &&
      |<NetPriceAmount></NetPriceAmount>| &&
      |<Plant></Plant>| &&
      |<Quantity>{ wa_item-BillingQuantity }</Quantity>| &&
      |<QuantityUnit>{ wa_item-UnitOfMeasure_E }</QuantityUnit>| &&
      |<YY1_bd_zdif_BDI></YY1_bd_zdif_BDI>| &&
      |<NetAmount>{ wa_item-NetAmount }</NetAmount>| &&
      |<ContainerNo>{ lv_container_xml }</ContainerNo>| &&
      |<MaterialText>{ lv_material_text }</MaterialText>| &&
      |<roundoff>{ wa_round-rounding_sum }</roundoff>| &&
      |<salesdocumentitemcategory>{ wa_item-SalesDocumentItemCategory }</salesdocumentitemcategory>| &&
      |<BatchDetails>|.

      CONCATENATE lv_xml lv_item_xml INTO lv_xml.

      " Add batch details for each batch
      DATA(lv_batch_details) = ``.
      DATA TotalNetWeight TYPE p LENGTH 16 DECIMALS 3.
      DATA TotalGrossWeight TYPE p LENGTH 16 DECIMALS 3.
      DATA foterpack TYPE p.
      DATA grossWeightTotal TYPE p LENGTH 16 DECIMALS 3.
      DATA netweightTotal TYPE p LENGTH 16 DECIMALS 3.


***************for packinglist batch**************
      DATA : qty_check TYPE i VALUE 0.
      LOOP AT lt_batches INTO DATA(wa_total).
        foterpack += wa_total-totalctns_cust_pkg.
        IF wa_total-BillingQuantity EQ 0.
          qty_check = 1.
        ENDIF.
      ENDLOOP.
*******************************************

*******************************Batch Logic Update Packing List Previous*****************************************************************

      SORT lt_batches BY BillingDocument BillingDocumentItem.

      READ TABLE lt_batches INTO DATA(wa_batch) WITH KEY BillingDocument = wa_item-BillingDocument  BillingDocumentItem = wa_item-BillingDocumentItem.

      DATA(start_idx) = sy-tabix.

      DATA: prev_sales LIKE wa_batch-SalesDocument.
      DATA : prev_item LIKE wa_batch-SalesDocumentItem.
      DATA : prev_del LIKE wa_batch-ReferenceSDDocument.

      prev_sales = wa_batch-SalesDocument.
      prev_item  = wa_batch-SalesDocumentItem.
      prev_del   = wa_batch-ReferenceSDDocument.


      LOOP AT lt_batches INTO DATA(wa_batch2) FROM start_idx.

        IF wa_batch2-SalesDocument = prev_sales AND wa_batch2-SalesDocumentItem = prev_item AND  wa_batch2-ReferenceSDDocument = prev_del AND wa_batch2-Batch IS NOT INITIAL.

          DATA(batch2) = wa_batch2-Batch.
          DATA(manufacturedate2) = wa_batch2-ManufactureDate.
          DATA(mfd2) = manufacturedate2(4) && '/' && manufacturedate2+4(2) && '/' && manufacturedate2+6(2).
          DATA(expiredate2) = wa_batch2-shelflifeexpirationdate.
          DATA(expiredate3) = expiredate2(4) && '/' && expiredate2+4(2) && '/' && expiredate2+6(2).
          DATA: lv_expiredate1 TYPE string.

          TotalNetWeight = wa_batch2-netweight_cust_pkg * wa_batch2-totalctns_cust_pkg.
          netweighttotal  += TotalNetWeight.
          TotalGrossWeight = wa_batch2-grossweight_cust_pkg * wa_batch2-totalctns_cust_pkg.
          grossweighttotal += TotalGrossWeight.

          DATA(lv_batch_details1) = |MFG: { mfd2 }  EXP: { expiredate3 }  Batch Code: { batch2 }|.

          DATA(lv_batch_xml1) =
         |<BatchNode>| &&
         |<lv_batch_details>{ lv_batch_details1 }</lv_batch_details>| &&
         |<hsncode_cust_pkg>{ wa_batch2-hsncode_cust_pkg }</hsncode_cust_pkg>| &&
         |<netweight_cust_pkg>{ wa_batch2-netweight_cust_pkg }</netweight_cust_pkg>| &&
         |<grossweight_cust_pkg>{ wa_batch2-grossweight_cust_pkg }</grossweight_cust_pkg>| &&
         |<totalctns_cust_pkg>{ wa_batch2-totalctns_cust_pkg }</totalctns_cust_pkg>| &&
         |<TotalNetWeight>{ TotalNetWeight }</TotalNetWeight>| &&
         |<TotalGrossWeight>{ TotalGrossWeight }</TotalGrossWeight>| &&
         |</BatchNode>|.

          CONCATENATE lv_xml lv_batch_xml1 INTO lv_xml.
        ELSE.
          CONTINUE.
        ENDIF.
        prev_sales = wa_batch2-SalesDocument.
        prev_item = wa_batch2-SalesDocumentItem.
        prev_del = wa_batch2-ReferenceSDDocument.
        CLEAR : wa_batch2,lv_batch_details1.

      ENDLOOP.
      CLEAR : prev_sales,prev_item,prev_del.

      DATA(lv_close_batches) = |</BatchDetails>|.
      CONCATENATE lv_xml lv_close_batches INTO lv_xml.

      SELECT SINGLE
      FROM zmaterialtext AS a
      FIELDS a~material_text
      WHERE a~materialcode = @wa_item-Product
     INTO  @DATA(wa_itemdesc).

      IF wa_itemdesc IS NOT INITIAL.
        DATA(lv_itemdesc) =
        |<YY1_fg_material_name_BDI>{ wa_itemdesc }</YY1_fg_material_name_BDI>|.
        CONCATENATE lv_xml lv_itemdesc INTO lv_xml.
      ELSE.
        SELECT SINGLE
        a~productdescription
        FROM i_productdescription AS a
        WHERE a~product = @wa_item-Product
        INTO @DATA(wa_itemdesc2).

        DATA(lv_itemdesc2) =
        |<YY1_fg_material_name_BDI>{ wa_itemdesc2 }</YY1_fg_material_name_BDI>|.
        CONCATENATE lv_xml lv_itemdesc2 INTO lv_xml.
      ENDIF.

      " RATE/UNIT
      SELECT SINGLE
           a~conditionamount ,
           a~conditiontype
           FROM I_BillingDocItemPrcgElmntBasic AS a
            WHERE a~BillingDocument = @wa_item-BillingDocument
            AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
            AND a~ConditionInactiveReason IS INITIAL
            AND a~ConditionType = 'ZSTO'
           INTO @DATA(wa_rate).

      DATA(lv_rate) =
         |<Rate>{ wa_rate-ConditionAmount }</Rate>|.
      CONCATENATE lv_xml lv_rate INTO lv_xml.

      " Item pricing conditions
      DATA(lv_itembegin) =
       |<ItemPricingConditions>|.
      CONCATENATE lv_xml lv_itembegin INTO lv_xml.

      SELECT
        a~conditionType,
        a~conditionamount,
        a~conditionratevalue,
        a~conditionbasevalue,
        a~BillingDocumentItem
        FROM I_BillingDocItemPrcgElmntBasic AS a
         WHERE a~BillingDocument = @bill_doc AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
         AND a~ConditionInactiveReason IS INITIAL
        INTO TABLE @DATA(lt_item2).


      DATA: disc      TYPE p LENGTH 16 DECIMALS 2,
            total     TYPE p LENGTH 16 DECIMALS 2,
            gsttotal  TYPE p LENGTH 16 DECIMALS 2,
            gstamount TYPE string,
            GSTRate   TYPE string.

      DATA headng TYPE string.
      LOOP AT lt_item2 INTO DATA(wa_item2).
        IF wa_item2-ConditionType = 'ZDIS' OR wa_item2-ConditionType = 'ZDIV' OR
           wa_item2-ConditionType = 'ZDPT' OR wa_item2-ConditionType = 'ZDQT'.
          disc = wa_item2-ConditionAmount + disc.
        ENDIF.
        IF wa_item2-ConditionType = 'ZEXF' OR wa_item2-ConditionType = 'ZBNP' OR
          wa_item2-ConditionType = 'ZSTO' OR wa_item2-ConditionType = 'PPRO' OR wa_item2-ConditionType = 'ZPRO'.
          total = wa_item2-ConditionAmount + total.
        ENDIF.
        IF ( wa_item2-ConditionType = 'JOCG' AND wa_item2-ConditionType = 'JOSG' ) OR wa_item2-ConditionType = 'JOIG'.
          gsttotal = wa_item2-ConditionAmount + gsttotal.
        ENDIF.
      ENDLOOP.
      DATA : wa_item2_joig TYPE string VALUE '0'.
      DATA : wa_item2_jocg TYPE string VALUE '0'.
      DATA : wa_item2_josg TYPE string VALUE '0'.
      LOOP AT lt_item2 INTO wa_item2.
        DATA(lv_item2_xml) =

        |<ItemPricingConditionNode>| &&
        |<ConditionAmount>{ wa_item2-ConditionAmount }</ConditionAmount>| &&
        |<ConditionBaseValue>{ wa_item2-ConditionBaseValue }</ConditionBaseValue>| &&
        |<ConditionRateValue>{ wa_item2-ConditionRateValue }</ConditionRateValue>| &&
        |<ConditionType>{ wa_item2-ConditionType }</ConditionType>| &&
        |</ItemPricingConditionNode>|.

        IF wa_item2-ConditionType = 'JOIG'.
          wa_item2_joig = '1'.
        ENDIF.
        IF wa_item2-ConditionType = 'JOSG'.
          wa_item2_josg = '1'.
        ENDIF.
        IF wa_item2-ConditionType = 'JOCG'.
          wa_item2_jocg = '1'.
        ENDIF.

        CONCATENATE lv_xml lv_item2_xml INTO lv_xml.
      ENDLOOP.

      """"""""""""""""""""" changes by apratim on 22-05-2025 """"""""""""""""""""""""
      CLEAR wa_item2.

      CLEAR lv_item2_xml.

      IF wa_item2_joig = '0' AND wa_item2_josg = '0' AND wa_item2_jocg = '0'.
        lv_item2_xml =

          |<ItemPricingConditionNode>| &&
          |<ConditionAmount>0</ConditionAmount>| &&
          |<ConditionBaseValue>0</ConditionBaseValue>| &&
          |<ConditionRateValue>0</ConditionRateValue>| &&
          |<ConditionType>JOIG</ConditionType>| &&
          |</ItemPricingConditionNode>|.
        CONCATENATE lv_xml lv_item2_xml INTO lv_xml.

      ENDIF.
      CLEAR lt_item2.
      wa_item2_joig = '0'.
      wa_item2_jocg = '0'.
      wa_item2_josg = '0'.





      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      DATA(lv_discount_value) = disc.
      IF lv_discount_value < 0.
        lv_discount_value = |{ lv_discount_value * -1 }|.
        lv_discount_value = |-{ lv_discount_value }|.
      ENDIF.
      DATA originalDiscount TYPE string.

      IF lv_discount_value < 0.
        originalDiscount = disc * -1.
      ELSE.
      ENDIF.

      DATA(lv_discount_xml) = |<Discount>{ lv_discount_value }</Discount>| &&
                              |<PositiveDiscount>{ originalDiscount }</PositiveDiscount>|.

      CONCATENATE lv_xml lv_discount_xml INTO lv_xml.

      " Close item node
      DATA(lv_item3_xml) =
      |</ItemPricingConditions>|.
      CONCATENATE lv_xml lv_item3_xml INTO lv_xml.

*      ********************new tax exempt logic************************************************************************

      SELECT SINGLE
        a~ConditionAmount,
        a~ConditionRateValue,
        a~ConditionType
        FROM I_BillingDocItemPrcgElmntBasic AS a
        WHERE a~BillingDocument = @bill_doc AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
          AND ( a~ConditionType = 'JOCG'
             OR a~ConditionType = 'JOIG' )
         AND a~ConditionInactiveReason IS INITIAL
        INTO @DATA(wa_exempt).

      IF wa_exempt-ConditionType = 'JOCG'.
        wa_exempt-conditionamount = wa_exempt-conditionamount * 2.
        wa_exempt-conditionratevalue =  wa_exempt-conditionratevalue * 2.
      ELSEIF wa_exempt-ConditionType = 'JOIG'.
        wa_exempt-conditionamount = wa_exempt-conditionamount.
        wa_exempt-conditionratevalue =  wa_exempt-conditionratevalue.
      ENDIF.


      IF wa_exempt-conditionamount IS INITIAL.
        wa_exempt-conditionamount = 0.
      ENDIF.

      IF wa_exempt-conditionratevalue IS INITIAL.
        wa_exempt-conditionratevalue = 0.
      ENDIF.


      DATA(tax_exempt) = |<newconditionamt>{ wa_exempt-conditionamount }</newconditionamt>| &&
                         |<newconditionrate>{ wa_exempt-conditionratevalue }</newconditionrate>|.

****************************************************************************************************************
      CONCATENATE lv_xml tax_exempt '</BillingDocumentItemNode>' INTO lv_xml.


*********************************************************************************************************<*********
********************************************Validation1
      SELECT SUM( CAST( ProductTaxClassification1 AS INT4 ) +
                  CAST( ProductTaxClassification2 AS INT4 ) +
                  CAST( ProductTaxClassification3 AS INT4 ) )
        FROM I_BillingDocumentItem
        WHERE billingdocument = @bill_doc
          AND billingdocumentitem = @wa_item-BillingDocumentItem
        INTO @lv_sum.

      IF lv_sum IS NOT INITIAL.
        lv_sum += lv_sum .
      ENDIF.
*******************************************************Validate2
      DATA TotalCal TYPE p LENGTH 16 DECIMALS 2.
      DATA totalnetvalue TYPE p LENGTH 16 DECIMALS 2.

      totalnetvalue = total + disc + gsttotal.
      TotalCal += totalnetvalue.

**************************************************************************************************************************
      CLEAR: wa_itemdesc,wa_itemdesc2,lv_item, lv_item_xml, lt_item2, wa_item, wa_rate, disc,originalDiscount,tax_exempt,wa_exempt,totalnetvalue,total,disc,gsttotal,lv_rate.
      qty_check = 0.
    ENDLOOP.


    DATA(lv_summary_xml) =
      |<NoofContainers>{ container_no_count }</NoofContainers>| &&
      |<TotalPackages>{ foterpack }</TotalPackages>| &&
      |<TotalGrossWeight>{ grossweighttotal }</TotalGrossWeight>| &&
      |<TotalNetWeight>{ netweighttotal }</TotalNetWeight>| .

    CONCATENATE lv_xml lv_summary_xml INTO lv_xml.

    CLEAR: foterpack, grossweighttotal ,netweighttotal.
    DATA(lv_payment_term) =
      |<PaymentTerms>| &&
      |<PaymentTermsName>{ wa_paymentterms-PaymentTermsName }</PaymentTermsName>| &&    " pending
      |</PaymentTerms>|.

    CONCATENATE lv_xml lv_payment_term INTO lv_xml.

    DATA(lv_shiptoparty) =
    |<ShipToParty>| &&
    |<AddressLine2Text>{ shipcustomer }</AddressLine2Text>| &&
    |<AddressLine3Text>{ add1s }</AddressLine3Text>| &&
    |<AddressLine4Text>{ add2s }</AddressLine4Text>| &&
    |<AddressLine5Text></AddressLine5Text>| &&
    |<AddressLine6Text></AddressLine6Text>| &&
    |<AddressLine7Text></AddressLine7Text>| &&
    |<AddressLine8Text></AddressLine8Text>| &&
    |<FullName>{ wa_bill-Region }</FullName>| &&
    |<Partner>{ wa_partnerShipTo }</Partner>| &&
    |<RegionName>{ wa_ship-RegionName }</RegionName>| &&
    |</ShipToParty>|.

    CONCATENATE lv_xml lv_shiptoparty INTO lv_xml.

    DATA(lv_supplier) =
    |<Supplier>| &&
    |<RegionName></RegionName>| &&                " pending
    |</Supplier>|.
    CONCATENATE lv_xml lv_supplier INTO lv_xml.

    DATA(lv_taxation) =
    |<TaxationTerms>| &&
    |<IN_BillToPtyGSTIdnNmbr>{ wa_bill-taxnumber3 }</IN_BillToPtyGSTIdnNmbr>| &&
    |<IN_ShipToPtyGSTIdnNmbr>{ wa_ship-TaxNumber3 }</IN_ShipToPtyGSTIdnNmbr>| &&
    |<IN_GSTIdentificationNumber>{ wa_plantgst-TaxNumber3 }</IN_GSTIdentificationNumber>| &&
    |</TaxationTerms>|.
    CONCATENATE lv_xml lv_taxation INTO lv_xml.
***********************************************************************************************
    TotalCal = wa_round-rounding_sum + Freight + tcs + PackingCharging + totalcal.
    SELECT SINGLE
      SUM( NetAmount + TaxAmount ) AS total
      FROM i_billingdocumentitem
      WHERE billingdocument = @bill_doc
      INTO @totalnetvalue.

    DATA correctinvoice TYPE string.
*    if totalcal eq totalnetvalue.
*    correctinvoice = 'Value_Matched'.
*    else.
*    correctinvoice = 'Value_Not_Matched'.
*     endif.
************************************************************************************************
    DATA Validate TYPE string.
***********************************************************************************************
    DATA(lv_footer) =
    |</Items>| &&
    |<correct>{ validate }</correct>| &&
    |</BillingDocumentNode>| &&
    |</Form>|.

    CONCATENATE lv_xml lv_footer INTO lv_xml.


    CLEAR wa_ad5_ship.
    CLEAR wa_bill.
    CLEAR lv_sum.
    CLEAR wa_ship.
    CLEAR: wa_header,TotalCal,correctinvoice,totalnetvalue.




    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN lv_xml WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN lv_xml WITH 'get'.

    out->write( lv_xml ).
  ENDMETHOD.
ENDCLASS.
