CLASS zproforma_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZPROFORMA_TEST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*  METHOD read_posts.
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
    j~billingdocno  ,    "invoice no
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
*    m~CNDNROUNDINGOFFDIFFAMOUNT
*12.03    k~YY1_DODate_SDH,
*12.03    k~yy1_dono_sdh
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
    WHERE a~BillingDocument = '0090000321'
    INTO @DATA(wa_header).



*    ********************************round off***********
* select single from I_BillingDocumentPrcgElmnt with PRIVILEGED ACCESS as a
* fields a~*
* where a~BillingDocument = '0090000321' and a~ConditionType = 'DRD1'
* into @data(wa_round).
*******************************************************
    SELECT SINGLE
    j~ackdate,
    substring( j~ackdate, 1, 10 ) AS ackdate_only
FROM ztable_irn AS j
WHERE j~billingdocno = '0090000321'
INTO @DATA(wa_AckDate).


**************************************************************************************partner Logic
    SELECT SINGLE
     a~SoldToParty
     FROM i_billingdocument AS a
     WHERE a~BillingDocument = '0090000321'
     INTO @DATA(wa_partnerBiilTo).

    SELECT SINGLE
 a~PurchaseOrderByCustomer
  FROM i_billingdocument AS a
  WHERE a~BillingDocument = '0090000321'
  INTO @DATA(wa_CUSTREF).
***************************************************************************************************brandname/carrieage/notify
    SELECT SINGLE FROM ztable_irn AS a
    LEFT JOIN I_BillingDocumentItem AS b ON a~billingdocno = b~BillingDocument
    LEFT JOIN i_product AS c ON b~Product = c~Product
    LEFT JOIN I_BillingDocumentTP AS d ON a~billingdocno = d~BillingDocument
    LEFT JOIN I_PaymentTermsText AS e ON d~CustomerPaymentTerms = e~PaymentTerms
    FIELDS a~placereceipopre ,
     c~YY1_brandcode_PRD ,
     d~YY1_NotifyParty_BDH ,
     d~TransactionCurrency ,
     e~PaymentTermsDescription,
     d~YY1_Remark_BDH
       WHERE a~billingdocno = '0090000321'
       INTO @DATA(wa_notify).

    SELECT SINGLE FROM I_BillingDocument AS a
    LEFT JOIN I_PaymentTermsText AS b ON a~CustomerPaymentTerms = b~PaymentTerms
     FIELDS
      a~YY1_NotifyParty_BDH ,
     b~PaymentTermsName
      WHERE a~BillingDocument = '0090000321'
      INTO @DATA(wa_paymentterms).


    SHIFT wa_partnerBiilTo LEFT DELETING LEADING '0'.

    SELECT SINGLE
     a~SoldToParty
     FROM i_billingdocumentitem AS a
     LEFT JOIN i_salesdocumentitem AS b ON a~SalesDocument = b~SalesDocument
     WHERE a~BillingDocument = '0090000321'
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
 WHERE b~partnerFunction = 'RE' AND  a~BillingDocument = '0090000321'
 INTO @DATA(wa_bill)
 PRIVILEGED ACCESS.


DATA: add1B TYPE string.

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

DATA: add2B TYPE string.

add2B = wa_bill-CityName.
IF wa_bill-PostalCode IS NOT INITIAL.
  IF add2B IS NOT INITIAL.
    CONCATENATE add2B wa_bill-PostalCode INTO add2B SEPARATED BY '- '.
  ELSE.
    add2B = wa_bill-PostalCode.
  ENDIF.
ENDIF.


**************************************************************************Packing List Logic
    SELECT SINGLE
        FROM i_billingdocumentitem AS a
        LEFT JOIN I_SalesDocument AS c ON a~SalesDocument = c~SalesDocument
        LEFT JOIN I_SalesDocumentItem AS b ON a~SalesDocument = b~SalesDocument
    FIELDS b~ReferenceSDDocument , b~CreationDate , c~PurchaseOrderByCustomer
       WHERE a~BillingDocument = '0090000321'
        INTO @DATA(Wa_PerfomaInvoice).


    SELECT SINGLE
       FROM I_BillingDocumentItem AS a
       LEFT JOIN I_SalesDocumentItem AS b ON a~SalesDocument = b~SalesDocument
       LEFT JOIN I_SalesQuotation AS c ON b~ReferenceSDDocument = c~SalesQuotation
       LEFT JOIN I_SalesQuotationtp AS d ON c~SalesQuotation = d~SalesQuotation
       FIELDS
        d~YY1_CountryOfDestinati_SDH ,
        d~YY1_PortOfDischarge_SDH ,d~YY1_PortOfLoading_SDH
          WHERE a~BillingDocument = '0090000321'
       INTO @DATA(wa_Potloading).

    SELECT SINGLE
    FROM I_BillingDocument AS a
    LEFT JOIN I_PaymentTermsText AS b ON a~CustomerPaymentTerms = b~PaymentTerms
    FIELDS a~IncotermsClassification , b~PaymentTermsName
       WHERE a~BillingDocument = '0090000321'
    INTO @DATA(wa_incoterms).



    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""SHIP TO  Address
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
   WHERE b~partnerFunction = 'WE' AND  a~BillingDocument = '0090000321'
   AND c~Language = 'E'
   AND a~BillingDocument = '0090000321'
   INTO @DATA(wa_ship)
   PRIVILEGED ACCESS.

DATA: add1S TYPE string.

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

DATA: add2S TYPE string.

add2S = wa_ship-CityName.
IF wa_ship-PostalCode IS NOT INITIAL.
  IF add2S IS NOT INITIAL.
    CONCATENATE add2S wa_ship-PostalCode INTO add2S SEPARATED BY '- '.
  ELSE.
    add2S = wa_ship-PostalCode.
  ENDIF.
ENDIF.

*    DATA : wa_ad5 TYPE string.
*    wa_ad5 = wa_bill-PostalCode.
*    CONCATENATE wa_ad5 wa_bill-CityName  wa_bill-DistrictName INTO wa_ad5 SEPARATED BY space.

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
    WHERE a~billingdocument = '0090000321'
    INTO @DATA(wa_plantgst)
     PRIVILEGED ACCESS.


**********************************************************************
    SELECT SINGLE FROM ztable_irn AS a
    FIELDS a~irnno , a~signedqrcode , a~ewaybillno , a~ewaydate
    WHERE a~billingdocno = '0090000321'
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
      LEFT JOIN I_UnitOfMeasureText as h on a~BillingQuantityUnit = h~UnitOfMeasure and h~Language = 'E'
      LEFT JOIN I_SalesDocumentItem AS e ON e~SalesDocument = a~SalesDocument AND e~salesdocumentitem = a~salesdocumentitem
      LEFT JOIN i_productplantbasic AS f ON a~Product = f~Product AND a~Plant = f~Plant
      LEFT JOIN i_billingdocumentitemprcgelmnt AS g ON g~BillingDocument = a~BillingDocument AND g~BillingDocumentItem = a~BillingDocumentItem
      WHERE a~billingdocument = '0090000321' AND  a~billingquantity NE ''
      INTO TABLE  @DATA(it_item)
      PRIVILEGED ACCESS.

    SELECT SUM( ConditionAmount ) AS rounding_sum,
       BillingDocument
  FROM I_BillingDocumentItemPrcgElmnt
  WHERE BillingDocument = '0090000321'
    AND ConditionType = 'DRD1'
  GROUP BY BillingDocument
  INTO TABLE @DATA(it_round).





    SORT it_item BY BillingDocumentItem.
    DELETE ADJACENT DUPLICATES FROM it_item COMPARING BillingDocument BillingDocumentItem.


    DATA : discount TYPE p DECIMALS 3.

*      out->write( it_item ).
*    out->write( wa_header ).

    DATA: temp_add TYPE string.
    temp_add = wa_bill-postalcode.
    CONCATENATE temp_add wa_bill-CityName wa_bill-DistrictName INTO temp_add.

    SELECT SUM( conditionamount )
FROM i_billingdocitemprcgelmntbasic
WHERE billingdocument = '0090000321'
  AND conditiontype = 'ZFRT'
  INTO @DATA(freight).

    SELECT SUM( conditionamount )
FROM i_billingdocitemprcgelmntbasic
WHERE billingdocument = '0090000321'
AND conditiontype = 'ZPCK'
INTO @DATA(PackingCharging).

*    DATA InvoiceCopyName TYPE c LENGTH 25.
*    IF printform = 'expoOriginal' OR printform = 'stoOriginal' OR printform = 'DCOriginal'.
*      InvoiceCopyName = 'Original For Buyer' .
*    ELSEIF printform = 'expoTransporter' OR printform = 'stoDuplicate' OR printform = 'DCDuplicate'.
*      InvoiceCopyName = 'Duplicate For Transporter'.
*    ELSEIF printform = 'expoOffice'  OR printform = 'stoOffice' OR printform = 'DCOffice' .
*      InvoiceCopyName = 'Office Copy'.
*    ENDIF.

***************************************container Logic



    SELECT SINGLE
      c~YY1_NoofContainers_SDI,
      c~YY1_ContType_SDI
  FROM I_BillingDocumentItem AS a
  LEFT JOIN I_SalesDocumentItem AS b ON a~SalesDocument = b~SalesDocument
  LEFT JOIN i_salesquotationitemtp AS c ON b~ReferenceSDDocument = c~salesquotation
  WHERE a~BillingDocument = '0090000321'
  INTO @DATA(wa_container).


    DATA(lv_xml) =
    |<Form>| &&
    |<BillingDocumentNode>| &&
    |<AckDate>{ wa_ackdate-ackdate_only }</AckDate>| &&
    |<AckNumber>{ wa_header-ackno }</AckNumber>| &&
    |<BillingDate>{ wa_header-billingdate }</BillingDate>| &&
    |<RecieptCariage>{ wa_notify-placereceipopre }</RecieptCariage>| &&
    |<BrandCode>{ wa_notify-YY1_brandcode_PRD }</BrandCode>| &&
    |<NotifyParty>{ wa_paymentterms-YY1_NotifyParty_BDH }</NotifyParty>| &&
    |<TransactionCurrency>{ wa_notify-TransactionCurrency }</TransactionCurrency>| &&
    |<IRN>{ wa_irn-irnno }</IRN>| &&
    |<SignedQRCode>{ wa_irn-signedqrcode }</SignedQRCode>| &&
    |<EwayNo>{ wa_irn-ewaybillno }</EwayNo>| &&
    |<Fright>{ freight }</Fright>| &&
    |<Originalheader></Originalheader>| &&
    |<PackingCharges>{ PackingCharging }</PackingCharges>| &&
    |<Remark>{ wa_notify-YY1_Remark_BDH }</Remark>| &&
    |<NoofContainers>{ wa_container-YY1_NoofContainers_SDI }</NoofContainers>| &&
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

    DATA(lv_ewaydate) = wa_irn-ewaydate.

    " Format as YYYY-MM-DD
    DATA(lv_formatted_ewaydate) = lv_ewaydate(4) && '-' && lv_ewaydate+4(2) && '-' && lv_ewaydate+6(2).

    " Remove unwanted spaces (if any)
    CONDENSE lv_formatted_ewaydate.


    DATA(lv_ewayheader) =
        |<EWAYBILLDATE>{ lv_formatted_ewaydate }</EWAYBILLDATE>| .

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
    WHERE a~BillingDocument = '0090000321'
    AND b~BillingDocument = '0090000321'
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
    |<ShippingTerms>{ wa_incoterms-IncotermsClassification }</ShippingTerms>| &&
    |<PaymentTerms>{ wa_incoterms-PaymentTermsName }</PaymentTerms>| &&
    |<EWAYBILLNO>{ wa_header-ewaybillno }</EWAYBILLNO>| &&
    |<TRANSPORTERGSTIN>{ wa_header-transportergstin }</TRANSPORTERGSTIN>| &&
    |<TRANSPORTERNAME>{ wa_header-transportername }</TRANSPORTERNAME>| &&
    |<GRNO>{ wa_header-grno }</GRNO>| &&
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
    |<FullName>{ wa_bill-CustomerName }</FullName>| &&   " done
    |<Partner>{ wa_partnerBiilTo }</Partner>| &&
     |<CustomerRef>{ wa_custref }</CustomerRef>| &&
    |<RegionName>{ wa_bill-RegionName }</RegionName>| &&
    |</BillToParty>| &&
    |<Items>|.

    CONCATENATE lv_xml lv_header2 INTO lv_xml.


*****************************************************************************************Description Of Goods
*
*     SELECT FROM i_billingdocumentitem AS a
*     LEFT JOIN i_billingdocumentitem AS b ON a~ReferenceSDDocument = b~ReferenceSDDocument
*     LEFT JOIN i_billingdocument AS c ON b~BillingDocument = c~BillingDocument AND c~SDDocumentCategory = 'M'
*     LEFT JOIN ztable_irn AS d ON d~billingdocno = c~BillingDocument
*     FIELDS a~referencesddocument ,b~billingdocument AS billing , c~BillingDocument , d~containerno
*     WHERE a~BillingDocument = '0090000321'
*     INTO  @DATA(wa_GoodsDescription).

*SELECT FROM i_billingdocumentitem AS a
*  LEFT JOIN i_billingdocumentitem AS b
*    ON a~ReferenceSDDocument = b~ReferenceSDDocument
*  LEFT JOIN i_billingdocument AS c
*    ON b~BillingDocument = c~BillingDocument
*    AND c~SDDocumentCategory = 'M'
*  LEFT JOIN ztable_irn AS d
*    ON d~billingdocno = c~BillingDocument
*  FIELDS
*    a~ReferenceSDDocument,
*    b~BillingDocument AS billing,
*    c~BillingDocument,
*    d~ContainerNo
*  WHERE a~BillingDocument = '0090000321'
*  INTO @DATA(wa_GoodsDescription).
*  ENDSELECT.

    SELECT a~billingdocument, a~ReferenceSDDocument ,a~product, a~billingquantity, c~containerno AS ContainerNo
    FROM i_billingdocument AS b
    INNER JOIN i_billingdocumentitem AS a
      ON b~billingdocument = a~billingdocument
    INNER JOIN i_billingdocumentitem AS ref
      ON a~ReferenceSDDocument = ref~ReferenceSDDocument
    LEFT JOIN ztable_irn AS c
      ON a~BillingDocument = c~billingdocno
    WHERE ref~billingdocument = '0090000321'
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
    WHERE ref~billingdocument = '0090000321'
      AND b~sddocumentcategory = 'M'
      AND a~billingquantity <> 0
    INTO TABLE @DATA(wa_PCKDescription).

***************************************************************************************************************************CUSTOM INVOICE
select from I_BillingDocumentItem as a
left join I_BillingDocumentTP as e on a~BillingDocument = e~BillingDocument
left join I_SalesOrderItem as f on a~SalesDocument = f~SalesOrder
inner join I_SalesQuotationItemTP as i on f~ReferenceSDDocument = i~SalesQuotation and f~SalesOrderItem = i~SalesQuotationItem
left join I_BillingDocumentItemPrcgElmnt as b on a~BillingDocument = b~BillingDocument and a~BillingDocumentItem = b~BillingDocumentItem and b~ConditionType = 'PPR0'
left join I_BillingDocumentItemPrcgElmnt as c on a~BillingDocument = c~BillingDocument and a~BillingDocumentItem = c~BillingDocumentItem and c~ConditionType = 'ZDQT'
left join I_BillingDocumentItemPrcgElmnt as d on a~BillingDocument = d~BillingDocument and a~BillingDocumentItem = d~BillingDocumentItem and d~ConditionType = 'ZDPT'
left join I_BillingDocumentItemPrcgElmnt as g on a~BillingDocument = g~BillingDocument and a~BillingDocumentItem = g~BillingDocumentItem and g~ConditionType = 'ZFRT'
left join I_BillingDocumentItemPrcgElmnt as h on a~BillingDocument = h~BillingDocument and a~BillingDocumentItem = h~BillingDocumentItem and h~ConditionType = 'ZINS'
left join I_BillingDocumentItemPrcgElmnt as j on a~BillingDocument = j~BillingDocument and a~BillingDocumentItem = j~BillingDocumentItem and j~ConditionType = 'ZPCK'
fields a~BillingQuantity,a~BillingDocument,a~BillingDocumentItem,a~ItemNetWeight,b~ConditionAmount as b_qty ,c~ConditionAmount as c_qty ,d~ConditionAmount as d_qty,
g~ConditionAmount as g_qty ,h~ConditionAmount as h_qty,e~YY1_DFAIDate_BDH,e~YY1_DFIANo_BDH, a~SalesDocument
,f~ReferenceSDDocument,i~YY1_ContNo_SDI,i~YY1_ContType_SDI,i~YY1_NoofContainers_SDI,j~ConditionAmount as j_qty
where a~BillingDocument = '0090000321' and a~BillingQuantity ne 0
into table @data(it).
delete ADJACENT DUPLICATES FROM it COMPARING ALL FIELDS.

***************************************************************************************************************************CUSTOM INVOICE


    LOOP AT it_item INTO DATA(wa_item).
      DATA(lv_item) =
      |<BillingDocumentItemNode>|.
      CONCATENATE lv_xml lv_item INTO lv_xml.

      DATA(lv_container_xml) = ``.
      DATA(lv_material_text) = ``.

******************************************************************************************************************************CUSTOM INVOICE
* Calculate totals first
DATA:
  cif_qty  TYPE I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
  dis      TYPE I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
  fob      TYPE I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
  frt      TYPE I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
  ins      TYPE I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
  dis_ttl  TYPE I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
  other_charges type I_BillingDocumentItemPrcgElmnt-ConditionAmount VALUE 0,
  netweight type p length 6 DECIMALS 3,
  DFAIDATE TYPE D,
  DFAINO  TYPE C LENGTH 10.


Loop at it into data(wa_foter) .
 frt += wa_foter-g_qty.
 ins += wa_foter-h_qty.
 other_charges += wa_foter-j_qty.
ENDLOOP.

data(lv_fright) =
    |<CustFreight>{ frt }</CustFreight>| &&
    |<CustInsurance>{ ins }</CustInsurance>| &&
    |<DFAIDate>{ wa_foter-YY1_DFAIDate_BDH }</DFAIDate>| &&
    |<DFAIno>{ wa_foter-YY1_DFIANo_BDH }</DFAIno>| &&
    |<otherCharges>{ other_charges }</otherCharges>| .
     CONCATENATE lv_xml lv_fright INTO lv_xml.
    clear:frt,ins,other_charges.
    READ TABLE it WITH KEY BillingDocument = wa_item-BillingDocument BillingDocumentItem = wa_item-BillingDocumentItem INTO data(wa_cust).
       IF sy-subrc = 0.

  cif_qty = wa_cust-b_qty - ( wa_cust-c_qty - wa_cust-d_qty ).
  fob = cif_qty.
  cif_qty = wa_cust-b_qty + wa_cust-g_qty + wa_cust-h_qty.
  cif_qty = cif_qty / wa_cust-ItemNetWeight.
  dis = wa_cust-c_qty + wa_cust-d_qty.

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
CLEAR: cif_qty, dis, fob, frt, ins, dis_ttl, wa_cust , DFAIDate,DFAInO.
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

  SELECT
    a~Product,
    a~Batch,
    a~Plant,
    a~ReferenceSDDocument,
    b~matlbatchavailabilitydate,
    b~shelflifeexpirationdate,
    d~NetWeight as NetWeight_cust_pkg,
    d~GrossWeight as GrossWeight_cust_pkg,
    c~ConsumptionTaxCtrlCode AS hsncode_cust_pkg,
    e~ActualDeliveryQuantity as TOtalCTNS_Cust_pkg
FROM I_BillingDocumentItem AS a
Inner JOIN i_batch AS b
    ON a~Product = b~Material
    AND a~Batch = b~Batch
    AND a~Plant = b~Plant
inner JOIN i_productplantbasic AS c
    ON b~Material = c~Product AND b~Plant = c~Plant
INNER JOIN I_Product as d
    ON c~Product = d~Product
INNER JOIN I_DeliveryDocumentItem as e
    ON a~ReferenceSDDocument = e~DeliveryDocument
    and a~ReferenceSDDocumentItem = e~DeliveryDocumentItem
WHERE a~Batch NE ''
    AND a~BillingDocument = '0090000321'
    AND a~Product = @wa_item-Product
    AND a~ReferenceSDDocument = @wa_item-ReferenceSDDocument

INTO TABLE @DATA(lt_batches).

read table it_round with key BillingDocument  = wa_item-BillingDocument  into data(wa_round).

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
      |<BatchDetails>|.  " Start batch details section

      CONCATENATE lv_xml lv_item_xml INTO lv_xml.

      " Add batch details for each batch
        DATA(lv_batch_details) = ``.
        data TotalNetWeight type p length 16 decimals 3.
        data TotalGrossWeight type p length 16 decimals 3.
        data foterpack type p.
        data grossWeightTotal type p length 16 decimals 3.
        data netweightTotal type p length 16 decimals 3.

        Loop at lt_batches into data(wa_total).
                foterpack += wa_total-totalctns_cust_pkg.
        ENDLOOP.

      LOOP AT lt_batches INTO DATA(wa_batch).
        DATA(batch) = wa_batch-Batch.
        DATA(manufacturedate) = wa_batch-matlbatchavailabilitydate.
        DATA(mfd) = manufacturedate(4) && '/' && manufacturedate+4(2) && '/' && manufacturedate+6(2).
        DATA(expiredate) = wa_batch-shelflifeexpirationdate.
    DATA: lv_expiredate TYPE string.

   CONCATENATE expiredate+0(4) '/' expiredate+4(2) '/' expiredate+6(2) INTO lv_expiredate.

        TotalNetWeight = wa_batch-netweight_cust_pkg * wa_batch-totalctns_cust_pkg.
           netweighttotal  += TotalNetWeight.
        TotalGrossWeight = wa_batch-grossweight_cust_pkg * wa_batch-totalctns_cust_pkg.
            grossweighttotal += TotalGrossWeight.


       lv_batch_details = |MFG: { mfd }  EXP: { expiredate }  Batch Code: { batch }|.


        DATA(lv_batch_xml) =
        |<BatchNode>| &&
        |<lv_batch_details>{ lv_batch_details }</lv_batch_details>| &&
        |<hsncode_cust_pkg>{ wa_batch-hsncode_cust_pkg }</hsncode_cust_pkg>| &&
        |<netweight_cust_pkg>{ wa_batch-netweight_cust_pkg }</netweight_cust_pkg>| &&
        |<grossweight_cust_pkg>{ wa_batch-grossweight_cust_pkg }</grossweight_cust_pkg>| &&
        |<totalctns_cust_pkg>{ wa_batch-totalctns_cust_pkg }</totalctns_cust_pkg>| &&
        |<TotalNetWeight>{ TotalNetWeight }</TotalNetWeight>| &&
        |<TotalGrossWeight>{ TotalGrossWeight }</TotalGrossWeight>| &&
        |</BatchNode>|.

        CONCATENATE lv_xml lv_batch_xml INTO lv_xml.

      ENDLOOP.

      " Close batch details section
      DATA(lv_close_batches) = |</BatchDetails>|.
      CONCATENATE lv_xml lv_close_batches INTO lv_xml.

      " TRADENAME BEGIN

*      SELECT SINGLE
*      a~trade_name
*      FROM zmaterial_table AS a
*      WHERE a~mat = @wa_item-Product
*      INTO  @DATA(wa_itemdesc).

      Select single
      from zmaterialtext as a
      FIELDS a~material_text
      where a~materialcode = @wa_item-Product
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
            WHERE a~BillingDocument = '0090000321'
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
         WHERE a~BillingDocument = '0090000321' AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
        INTO TABLE @DATA(lt_item2).
      DATA disc TYPE string.

       data headng type string.
      LOOP AT lt_item2 INTO DATA(wa_item2).
        IF wa_item2-ConditionType = 'ZDIS' OR wa_item2-ConditionType = 'ZDIV' OR
           wa_item2-ConditionType = 'ZDPT' OR wa_item2-ConditionType = 'ZDQT'.
          disc = wa_item2-ConditionAmount + disc.
        ENDIF.

*        if printform = 'stoOriginal' or printform = 'stoDuplicate' or printform = 'stoOffice'.
*         if wa_item2-ConditionType = 'JOCG' or wa_item2-ConditionType = 'JOIG' or  wa_item2-ConditionType = 'JOSG' or wa_item2-ConditionType = 'JOIG'.
*           headng = 'Tax Invoice'.
*         else.
*         headng = 'Bill Of Supply'.
*        ENDIF.
*        ENDIF.
      ENDLOOP.
*       data (  ) )=
*        |<Heading>{ wa_item2-ConditionAmount }</Heading>| .
      LOOP AT lt_item2 INTO wa_item2.
        DATA(lv_item2_xml) =
        |<ItemPricingConditionNode>| &&
        |<ConditionAmount>{ wa_item2-ConditionAmount }</ConditionAmount>| &&
        |<ConditionBaseValue>{ wa_item2-ConditionBaseValue }</ConditionBaseValue>| &&
        |<ConditionRateValue>{ wa_item2-ConditionRateValue }</ConditionRateValue>| &&
        |<ConditionType>{ wa_item2-ConditionType }</ConditionType>| &&
        |</ItemPricingConditionNode>|.
        CONCATENATE lv_xml lv_item2_xml INTO lv_xml.
      ENDLOOP.

      DATA(lv_discount_value) = disc.
      IF lv_discount_value < 0.
        lv_discount_value = |{ lv_discount_value * -1 }|.
        lv_discount_value = |-{ lv_discount_value }|.
      ENDIF.

      DATA(lv_discount_xml) = |<Discount>{ lv_discount_value }</Discount>|.
      CONCATENATE lv_xml lv_discount_xml INTO lv_xml.

      " Close item node
      DATA(lv_item3_xml) =
      |</ItemPricingConditions>| &&
      |</BillingDocumentItemNode>|.

      CONCATENATE lv_xml lv_item3_xml INTO lv_xml.
      CLEAR: lv_item, lv_item_xml, lt_item2, wa_item, wa_rate, disc, lt_batches.
    ENDLOOP.
         DATA(lv_summary_xml) =

  |<TotalPackages>{ foterpack }</TotalPackages>| &&
  |<TotalGrossWeight>{ grossweighttotal }</TotalGrossWeight>| &&
  |<TotalNetWeight>{ netweighttotal }</TotalNetWeight>| .

CONCATENATE lv_xml lv_summary_xml INTO lv_xml.

    clear: foterpack, grossweighttotal ,netweighttotal.
    DATA(lv_payment_term) =
      |<PaymentTerms>| &&
        |<PaymentTermsName>{ wa_paymentterms-PaymentTermsName }</PaymentTermsName>| &&    " pending
      |</PaymentTerms>|.

    CONCATENATE lv_xml lv_payment_term INTO lv_xml.

    DATA(lv_shiptoparty) =
    |<ShipToParty>| &&
    |<AddressLine2Text>{ wa_ship-CustomerName }</AddressLine2Text>| &&
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
    |<IN_BillToPtyGSTIdnNmbr>{ wa_bill-taxnumber3 }</IN_BillToPtyGSTIdnNmbr>| &&       " pending   IN_BillToPtyGSTIdnNmbr
    |<IN_ShipToPtyGSTIdnNmbr>{ wa_ship-TaxNumber3 }</IN_ShipToPtyGSTIdnNmbr>| &&
    |<IN_GSTIdentificationNumber>{ wa_plantgst-TaxNumber3 }</IN_GSTIdentificationNumber>| &&
    |</TaxationTerms>|.
    CONCATENATE lv_xml lv_taxation INTO lv_xml.

    DATA(lv_footer) =
    |</Items>| &&
    |</BillingDocumentNode>| &&
    |</Form>|.

    CONCATENATE lv_xml lv_footer INTO lv_xml.


    CLEAR wa_ad5_ship.
    CLEAR wa_bill.
    CLEAR wa_ship.
    CLEAR wa_header.


    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN lv_xml WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN lv_xml WITH 'get'.

    out->write( lv_xml ).

*    CALL METHOD zcl_ads_master=>getpdf(
*      EXPORTING
*        xmldata  = lv_xml
*        template = lc_template_name
*      RECEIVING
*        result   = result12 ).
*out->write( lv_xml ).
  ENDMETHOD.
ENDCLASS.
