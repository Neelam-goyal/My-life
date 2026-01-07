CLASS ztest_dom_tax_invoice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA : bill_doc TYPE I_BillingDocument-BillingDocument.
*    CLASS-DATA : company_code TYPE I_BillingDocument-CompanyCode.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_DOM_TAX_INVOICE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

 bill_doc = '0090000021'.
* company_code = 'GT00'.


    DATA : plant_add   TYPE string.
    DATA : p_add1  TYPE string.
    DATA : p_add2 TYPE string.
    DATA : p_city TYPE string.
    DATA : p_dist TYPE string.
    DATA : p_state TYPE string.
    DATA : p_pin TYPE string.
    DATA : p_country   TYPE string,
           plant_name  TYPE string,
           plant_gstin TYPE string.



    SELECT single
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
    j~transportername ,
    b~SALESORGANIZATION ,
    l~SALESORGANIZATIONNAME ,
    a~companycode
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
    LEFT JOIN I_SalesOrganizationText as l on l~SalesOrganization = b~SalesOrganization
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_header).



      p_add1 = wa_header-address1 && ',' .
      p_add2 = wa_header-address2 && ','.
      p_dist = wa_header-district && ','.
      p_city = wa_header-city && ','.
      p_state = wa_header-state_name .
      p_pin =  wa_header-pin .
      p_country =  '(' &&  wa_header-country && ')' .


      CONCATENATE p_add1  p_add2  p_dist p_city   p_state '-' p_pin  p_country INTO plant_add SEPARATED BY space.

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
    d~STREETSUFFIXNAME1,
    d~STREETSUFFIXNAME2
   FROM I_BillingDocument AS a
   LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
   LEFT JOIN i_customer AS c ON c~customer = b~Customer
   left JOIN i_address_2 AS d ON d~AddressID = c~AddressID
   LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
   LEFT JOIN i_countrytext AS f ON d~Country = f~Country
   WHERE b~partnerFunction = 'RE' AND  a~BillingDocument = @bill_doc
   INTO @DATA(wa_bill)
   PRIVILEGED ACCESS.




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
    LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
    LEFT JOIN i_customer AS c ON c~customer = b~Customer
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    LEFT JOIN I_RegionText AS e on e~Region = d~Region and e~Country = d~Country
    WHERE b~partnerFunction = 'RE' AND  a~BillingDocument = @bill_doc
    and c~Language = 'E'
    and a~BillingDocument = @bill_doc
    INTO @DATA(wa_ship)
    PRIVILEGED ACCESS.


      DATA : wa_ad5 TYPE string.
      wa_ad5 = wa_bill-PostalCode.
      CONCATENATE wa_ad5 wa_bill-CityName  wa_bill-DistrictName INTO wa_ad5 SEPARATED BY space.

      DATA : wa_ad5_ship TYPE string.
      wa_ad5_ship = wa_ship-PostalCode.
      CONCATENATE wa_ad5_ship wa_ship-CityName  wa_ship-DistrictName INTO wa_ad5_ship SEPARATED BY space.


**********************************************************************PLANT GST

select single
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
from i_billingdocumentitem as a
left join i_plant as b on b~plant = a~plant
left join i_customer as c on c~customer = b~plantcustomer
left join i_address_2 AS d ON d~AddressID = c~AddressID
where a~billingdocument = @bill_doc
into @data(wa_plantgst)
 PRIVILEGED ACCESS.


**********************************************************************

      """""""""""""""""""""""""""""""""""ITEM DETAILS"""""""""""""""""""""""""""""""""""

      SELECT
        a~billingdocument,
        a~billingdocumentitem,
        a~product,
        a~netamount,
        b~handlingunitreferencedocument,
        b~material,
        b~handlingunitexternalid,
        c~packagingmaterial,
        d~productdescription,
        e~materialbycustomer ,
        f~consumptiontaxctrlcode  ,   "HSN CODE
        a~billingdocumentitemtext ,   "mat
*12.03        e~yy1_packsize_sd_sdi  ,  "i_avgpkg
        a~billingquantity  ,  "Quantity
        a~billingquantityunit  ,  "UOM
*12.03        e~yy1_packsize_sd_sdiu  ,   " package_qtyunit
*12.03        e~yy1_noofpack_sd_sdi  ,   " avg_content
        g~conditionratevalue   ,  " i_per
        g~conditionamount ,
        g~conditionbasevalue,
        g~conditiontype


        FROM I_BillingDocumentItem AS a
        LEFT JOIN i_handlingunititem AS b ON a~referencesddocument = b~handlingunitreferencedocument
        LEFT JOIN i_handlingunitheader AS c ON b~handlingunitexternalid = c~handlingunitexternalid
        LEFT JOIN i_productdescription AS d ON d~product = c~packagingmaterial
        LEFT JOIN I_SalesDocumentItem AS e ON e~SalesDocument = a~SalesDocument AND e~salesdocumentitem = a~salesdocumentitem
        LEFT JOIN i_productplantbasic AS f ON a~Product = f~Product
        LEFT JOIN i_billingdocumentitemprcgelmnt AS g ON g~BillingDocument = a~BillingDocument AND g~BillingDocumentItem = a~BillingDocumentItem
        WHERE a~billingdocument = @bill_doc
        INTO TABLE  @DATA(it_item)
        PRIVILEGED ACCESS.

*      out->write( it_item ).
      SELECT SUM( conditionamount )
  FROM i_billingdocitemprcgelmntbasic
  WHERE billingdocument = @bill_doc
    AND conditiontype = 'ZFRT'
    INTO @DATA(freight).



    SORT it_item BY BillingDocumentItem.
    DELETE ADJACENT DUPLICATES FROM it_item COMPARING BillingDocument BillingDocumentItem.

    DATA : discount TYPE p DECIMALS 3.

*      out->write( it_item ).
*    out->write( wa_header ).

    data: temp_add type string.
    temp_add = wa_bill-POSTALCODE.
    CONCATENATE temp_add wa_bill-CityName wa_bill-DistrictName into temp_add.


    DATA(lv_xml) =
    |<Form>| &&
    |<BillingDocumentNode>| &&
    |<AckDate>{ wa_header-ackdate }</AckDate>| &&
    |<AckNumber>{ wa_header-ackno }</AckNumber>| &&
    |<BillingDate>{ wa_header-billingdate }</BillingDate>|.


**********************************************************************BILLINGDOCUMENTDATE

DATA(lv_date) = wa_header-BillingDocumentDate.

" Format as YYYY-MM-DD
DATA(lv_formatted_date) = lv_date(4) && '-' && lv_date+4(2) && '-' && lv_date+6(2).

" Remove unwanted spaces (if any)
CONDENSE lv_formatted_date.


DATA(lv_header5) =
    |<BillingDocumentDate>{ lv_formatted_date }</BillingDocumentDate>| .

CONCATENATE lv_xml lv_header5 into lv_xml.


**********************************************************************BILLINGDOCUMENTDATE


**********************************************************************EWAYDATE

DATA(lv_ewaydate) = wa_header-ewaydate.

" Format as YYYY-MM-DD
DATA(lv_formatted_ewaydate) = lv_ewaydate(4) && '-' && lv_ewaydate+4(2) && '-' && lv_ewaydate+6(2).

" Remove unwanted spaces (if any)
CONDENSE lv_formatted_ewaydate.


DATA(lv_ewayheader) =
    |<EWAYBILLDATE>{ lv_formatted_ewaydate }</EWAYBILLDATE>| .

CONCATENATE lv_xml lv_ewayheader into lv_xml.



**********************************************************************EWAYDATE


**********************************************************************FSSAINO
select single
a~billingdocument ,
c~fssai_no
FROM i_billingdocument AS a
LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
LEFT JOIN ztable_plant as c on c~comp_code = b~CompanyCode and c~plant_code = b~Plant
where a~BillingDocument = @bill_doc
and b~BillingDocument = @bill_doc
into @data(wa_fssai)
PRIVILEGED ACCESS.

  DATA(lv_fssai) =
     |<FSSAINO>{ wa_fssai-fssai_no }</FSSAINO>| .

CONCATENATE lv_xml lv_fssai into lv_xml.


**********************************************************************FSSAINO

    DATA(lv_header2) =

    |<DocumentReferenceID>{ wa_header-DocumentReferenceID }</DocumentReferenceID>| &&
    |<Irn>{ wa_header-irnno }</Irn>| &&
    |<EWAYBILLNO>{ wa_header-ewaybillno }</EWAYBILLNO>| &&
    |<TRANSPORTERGSTIN>{ wa_header-transportergstin }</TRANSPORTERGSTIN>| &&
    |<TRANSPORTERNAME>{ wa_header-transportername }</TRANSPORTERNAME>| &&
    |<YY1_PLANT_COM_ADD_BDH>{ plant_add }</YY1_PLANT_COM_ADD_BDH>| &&
    |<YY1_PLANT_COM_NAME_BDH>{ plant_name }</YY1_PLANT_COM_NAME_BDH>| &&
    |<YY1_PLANT_COM_GSTIN_NO_BDH>{ plant_gstin }</YY1_PLANT_COM_GSTIN_NO_BDH>| &&
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
*12.03    |<YY1_dodatebd_BDH>{ wa_header-YY1_DODate_SDH }</YY1_dodatebd_BDH>| &&
*12.03    |<YY1_dono_bd_BDH>{ wa_header-YY1_DONo_SDH }</YY1_dono_bd_BDH>| &&
*    |<Plant>{ wa_header-Plant }</Plant>| &&
*    |<RegionName>{ wa_header-state_name }</RegionName>| &&
    |<BillToParty>| &&
    |<AddressLine3Text>{ wa_bill-STREETNAME }</AddressLine3Text>| &&
    |<AddressLine4Text>{ wa_bill-STREETPREFIXNAME1 }</AddressLine4Text>| &&
    |<AddressLine5Text>{ wa_bill-STREETPREFIXNAME2 }</AddressLine5Text>| &&
    |<AddressLine6Text>{ wa_bill-STREETSUFFIXNAME1 }</AddressLine6Text>| &&
    |<AddressLine7Text>{ wa_bill-STREETSUFFIXNAME2 }</AddressLine7Text>| &&
    |<AddressLine8Text>{ temp_add }</AddressLine8Text>| &&
*    |<Region>{ wa_bill-Region }</Region>| &&
    |<FullName>{ wa_bill-CustomerName }</FullName>| &&   " done
*12.03    |<Partner>{ wa_header-YY1_DONo_SDH }</Partner>| &&
    |<RegionName>{ wa_bill-RegionName }</RegionName>| &&
    |</BillToParty>| &&
    |<Items>|.

CONCATENATE lv_xml lv_header2 into lv_xml.


    LOOP AT it_item INTO DATA(wa_item).

*      SELECT SINGLE
*     a~trade_name
*     FROM zmaterial_table AS a
*     WHERE a~mat = @wa_item-Product
*     INTO @DATA(wa_item3).
*
*      IF wa_item3 IS NOT INITIAL.
*        DATA(lv_item) =
*        |<BillingDocumentItemNode>| &&
*        |<YY1_fg_material_name_BDI>{ wa_item3 }</YY1_fg_material_name_BDI>|.
*        CONCATENATE lv_xml  lv_item INTO lv_xml.
*      ELSE.
*        " Fetch Product Name from `i_producttext`
*        SELECT SINGLE
*        a~productname
*        FROM i_producttext AS a
*        WHERE a~product = @wa_item-Product
*        INTO @DATA(wa_item4).
*
*        DATA(lv_item4) =
*        |<BillingDocumentItemNode>| &&
*        |<YY1_fg_material_name_BDI>{ wa_item4 }</YY1_fg_material_name_BDI>|.
*        CONCATENATE lv_xml lv_item4 INTO lv_xml.
*      ENDIF.
      DATA(lv_item) =
      |<BillingDocumentItemNode>|.
      CONCATENATE lv_xml lv_item INTO lv_xml.


      DATA(lv_item_xml) =

      |<BillingDocumentItemText>{ wa_item-Product }</BillingDocumentItemText>| &&
      |<IN_HSNOrSACCode>{ wa_item-consumptiontaxctrlcode }</IN_HSNOrSACCode>| &&
      |<NetPriceAmount></NetPriceAmount>| &&                       " pending
      |<Plant></Plant>| &&                                         " pending
      |<Quantity>{ wa_item-BillingQuantity }</Quantity>| &&
      |<QuantityUnit>{ wa_item-BillingQuantityUnit }</QuantityUnit>| &&
      |<YY1_bd_zdif_BDI></YY1_bd_zdif_BDI>| &&                      " pending
      |<NetAmount>{ wa_item-NetAmount }</NetAmount>| .
      CONCATENATE lv_xml lv_item_xml INTO lv_xml.


***************************************************************************************TRADENAME BEGIN
      SELECT SINGLE
      a~trade_name
      FROM zmaterial_table AS a
      WHERE a~mat = @wa_item-Product
      INTO  @DATA(wa_itemdesc).

      IF wa_itemdesc IS NOT INITIAL.
        DATA(lv_itemdesc) =
        |<YY1_fg_material_name_BDI>{ wa_itemdesc }</YY1_fg_material_name_BDI>|.
        CONCATENATE lv_xml lv_itemdesc INTO lv_item .
      ELSE.
        " Fetch Product Name from `i_producttext`
        SELECT SINGLE
        a~productname
        FROM i_producttext AS a
        WHERE a~product = @wa_item-Product
        INTO @DATA(wa_itemdesc2).

        DATA(lv_itemdesc2) =
        |<YY1_fg_material_name_BDI>{ wa_itemdesc2 }</YY1_fg_material_name_BDI>|.
        CONCATENATE lv_xml lv_itemdesc2 INTO lv_xml.
      ENDIF.
***************************************************************************************TRADENAME END


****************************************************************************RATE/UNIT

   SELECT SINGLE
        a~conditionamount ,
        a~conditiontype
        FROM I_BillingDocItemPrcgElmntBasic AS a
         WHERE a~BillingDocument = @bill_doc
         and a~ConditionType = 'ZSTO'
        INTO @DATA(wa_rate)
        PRIVILEGED ACCESS.


 DATA(lv_rate) =
    |<Rate>{ wa_rate-ConditionAmount }</Rate>|.
    CONCATENATE lv_xml lv_rate INTO lv_xml.




****************************************************************************RATE/UNIT


***************************************************************************DISCOUNT


   SELECT SINGLE
        a~conditionamount ,
        a~conditiontype
        FROM I_BillingDocItemPrcgElmntBasic AS a
         WHERE a~BillingDocument = @bill_doc
         and a~ConditionType IN ('ZDIS' , 'ZDIV' , 'ZDPT' , 'ZDQT' )
        INTO  @DATA(wa_disc)
        PRIVILEGED ACCESS.

 DATA(lv_disc) =
    |<Disc>{ wa_disc-ConditionAmount }</Disc>|.
    CONCATENATE lv_xml lv_disc INTO lv_xml.




***************************************************************************DISCOUNT



     DATA(lv_itembegin) =
      |<ItemPricingConditions>|.
      CONCATENATE lv_xml lv_itembegin into lv_xml.


      SELECT
        a~conditionType  ,  "hidden conditiontype
        a~conditionamount ,  "hidden conditionamount
        a~conditionratevalue  ,  "condition ratevalue
        a~conditionbasevalue   " condition base value
        FROM I_BillingDocItemPrcgElmntBasic AS a
         WHERE a~BillingDocument = @bill_doc "AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
        INTO TABLE @DATA(lt_item2)
        PRIVILEGED ACCESS.

      LOOP AT lt_item2 INTO DATA(wa_item2).
        DATA(lv_item2_xml) =
        |<ItemPricingConditionNode>| &&
        |<ConditionAmount>{ wa_item2-ConditionAmount }</ConditionAmount>| &&
        |<ConditionBaseValue>{ wa_item2-ConditionBaseValue }</ConditionBaseValue>| &&
        |<ConditionRateValue>{ wa_item2-ConditionRateValue }</ConditionRateValue>| &&
        |<ConditionType>{ wa_item2-ConditionType }</ConditionType>| &&
        |</ItemPricingConditionNode>|.
        CONCATENATE lv_xml lv_item2_xml INTO lv_xml.
        CLEAR wa_item2.
      ENDLOOP.
      DATA(lv_item3_xml) =
      |</ItemPricingConditions>| &&
      |</BillingDocumentItemNode>|.

      CONCATENATE lv_xml lv_item3_xml INTO lv_xml.
      CLEAR lv_item.
      CLEAR lv_item_xml.
      CLEAR lt_item2.
      CLEAR wa_item.
      CLEAR wa_rate.
      CLEAR wa_disc.
    ENDLOOP.

    DATA(lv_payment_term) =
      |<PaymentTerms>| &&
      |<PaymentTermsName></PaymentTermsName>| &&    " pending
      |</PaymentTerms>|.

    CONCATENATE lv_xml lv_payment_term INTO lv_xml.

    DATA(lv_shiptoparty) =
    |<ShipToParty>| &&
    |<AddressLine2Text>{ wa_ship-CustomerName }</AddressLine2Text>| &&
    |<AddressLine3Text>{ wa_ship-StreetPrefixName1 }</AddressLine3Text>| &&
    |<AddressLine4Text>{ wa_ship-StreetPrefixName2 }</AddressLine4Text>| &&
    |<AddressLine5Text>{ wa_ship-StreetName }</AddressLine5Text>| &&
    |<AddressLine6Text>{ wa_ad5_ship }</AddressLine6Text>| &&
    |<AddressLine7Text></AddressLine7Text>| &&
    |<AddressLine8Text></AddressLine8Text>| &&
    |<FullName>{ wa_bill-Region }</FullName>| &&
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

    CLEAR wa_ad5.
    CLEAR wa_ad5_ship.
    CLEAR wa_bill.
    CLEAR wa_ship.
    CLEAR wa_header.


    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN lv_xml WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN lv_xml WITH 'get'.



    out->write( lv_xml ).


  ENDMETHOD.
ENDCLASS.
