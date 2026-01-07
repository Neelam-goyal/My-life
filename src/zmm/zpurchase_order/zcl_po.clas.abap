CLASS zcl_po DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun.
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    CLASS-DATA : var1 TYPE vbeln.
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
        IMPORTING po              TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZPURCHASE_ORDER/ZPURCHASE_ORDER'.


ENDCLASS.



CLASS ZCL_PO IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts.

    var1 = po.
    var1 = |{ |{ var1 ALPHA = OUT }| ALPHA = IN }| .
    DATA(lv_po) = var1.

    SELECT SINGLE
        a~PurchaseOrder,
        a~supplier,
        a~PurchaseOrderdate,
        b~companycodename,
        b~companycode,
        c~HouseNumber,
        c~StreetName,
        c~CityName,
        d~SupplierName,
        d~BPAddrStreetName,
        d~CityName AS cn,
        d~businesspartnerpannumber,
        d~postalcode,
        d~taxnumber3, "gstin no
        e~RegionName,
        g~businesspartnername,
        h~CreationDate,
        a~PurchasingProcessingStatus

      FROM i_purchaseorderapi01 AS a
      LEFT JOIN i_companycode AS b ON a~CompanyCode = b~CompanyCode
      LEFT JOIN I_Address_2 AS c ON c~addressid = b~addressid
      LEFT JOIN i_supplier AS d ON d~Supplier = a~Supplier
      LEFT JOIN i_regiontext AS e ON e~region = d~region
      LEFT JOIN i_Businesspartner AS g ON g~BusinessPartner = d~Supplier
      LEFT JOIN i_supplierquotationtp AS h ON h~Supplier = a~Supplier
      WHERE a~PurchaseOrder EQ @lv_po
      INTO  @DATA(wa_header).

    SELECT SINGLE
    FROM i_purchaseorderitemapi01 AS a
    INNER JOIN i_producttext AS b ON a~material = b~product
    INNER JOIN ztable_plant AS c ON c~plant_code = a~plant
    FIELDS c~address1, c~address2, c~address3,
    c~city, c~district, c~state_code1,
    c~state_code2, c~state_name, c~pin,c~plant_name1,c~gstin_no,c~fssai_no,
    c~country
    WHERE a~PurchaseOrder EQ @lv_po
    AND b~language = 'E'
    INTO @DATA(plant_address)
    PRIVILEGED ACCESS.

    DATA : plant_add TYPE string.
    DATA : plant_add1 TYPE string.
    DATA : plant_add2 TYPE string.
    DATA : plant_final TYPE string.

    plant_add = |{ plant_address-address1 } { plant_address-address2  } { plant_address-address3 }|.
    plant_add1 = |{ plant_address-city } { plant_address-district } { plant_address-state_code1 } |.
    plant_add2 = | { plant_address-pin }  { plant_address-country }|.


    plant_final = |{  plant_add } {  plant_add1 } {  plant_add2 }|.

    DATA(yy1_company_name_pdi) = plant_address-plant_name1.
    DATA(yy1_company_address_pdi) = plant_final.


    SELECT SINGLE FROM i_purchaseorderapi01 AS a
     LEFT JOIN i_supplier AS b ON b~supplier = a~supplier
      LEFT JOIN i_address_2 AS c ON c~addressid = b~addressid
       LEFT JOIN I_regiontext AS d ON d~country = b~country AND d~Region = b~Region
     FIELDS a~purchaseorder , b~suppliername , b~taxnumber3,
     c~streetname ,
     c~streetprefixname1 , c~streetprefixname2 , c~streetsuffixname1,
     c~streetsuffixname2 , c~cityname ,c~region,c~postalcode ,d~regionname
     WHERE  a~PurchaseOrder EQ @lv_po
     INTO @DATA(wa_supp)
     PRIVILEGED ACCESS.

    DATA : sup_add TYPE string.
    CONCATENATE  wa_supp-streetname wa_supp-streetprefixname1
   wa_supp-streetprefixname2 wa_supp-streetsuffixname1
   wa_supp-streetsuffixname2  wa_supp-cityname
    INTO sup_add.

    DATA(yy1_suppliername_pdh) = wa_supp-suppliername.
    DATA(yy1_vendoraddress_pdh) = sup_add.


    """"""""""""""""""""""""""""""""ITEM DETAILS""""""""""""""""""""""""""""""""""
    SELECT
       a~baseunit,       " uom
       a~OrderQuantity,   "order qty
       a~netpriceamount,
       a~DocumentCurrency,
       b~ProductName,    " des of goods
       b~product,
       a~taxcode,
       a~PurchaseOrderItem,
       a~purchaseorder,
       a~purchasingdocumentdeletioncode
     FROM I_PurchaseOrderItemAPI01 AS a
     LEFT JOIN i_producttext AS b ON b~Product = a~Material
     WHERE a~PurchaseOrder EQ @lv_po
     INTO TABLE @DATA(it).


    """"""""""""""""""""""""""""""""rate""""""""""""""""""""""""""""""""""""""

    DATA : ratess TYPE p DECIMALS 2.
    DATA : ratess_val TYPE c LENGTH 20.



    SELECT  b~purchaseorder, d~purchaseorderitem ,
    conditionratevalue, conditiontype ,d~purchasingdocumentdeletioncode
  FROM i_purorditmpricingelementapi01 AS a
  INNER JOIN i_purchaseorderapi01 AS b
  ON a~pricingdocument = b~pricingdocument
  AND b~language = 'E'
  INNER JOIN i_purchaseorderitemapi01 AS d ON d~purchaseorder = a~purchaseorder AND
   d~purchaseorderitem = a~purchaseorderitem
WHERE a~purchaseorder EQ @lv_po
   AND d~purchasingdocumentdeletioncode <> 'L'
    INTO TABLE @DATA(rate)
    PRIVILEGED ACCESS.

*    DATA: lt_yy1_rate_pdi TYPE TABLE OF rate,
*          lv_rate         TYPE string.

*    IF rate IS NOT INITIAL.
*      LOOP AT  rate INTO DATA(wa_rate).
*        ratess = wa_rate-conditionratevalue.
*        ratess_val  = ratess.
*        CONDENSE : ratess_val.
*        IF wa_rate-conditiontype = 'PMP0' OR wa_rate-conditiontype = 'PPR0'.
*          DATA(yy1_rate_pdi) = ratess_val.
*        ENDIF.
*        CLEAR : ratess , wa_rate ,ratess_val .
*      ENDLOOP.
*    ENDIF.


    """""""""""""""""""""""""""""""""discount"""""""""""""""""""""""""""""""""""""
    DATA : disc TYPE c LENGTH 30.
    DATA : disc_2 TYPE c LENGTH 20.
    DATA : disc_3 TYPE c LENGTH 20.
    DATA : disc1 TYPE c LENGTH 20.
    DATA : disc11 TYPE c LENGTH 20.
    DATA : disc2 TYPE c LENGTH 30.
    DATA : dis1 TYPE p DECIMALS 2.
    DATA : dis_value TYPE c LENGTH 20.
    DATA : discsss TYPE  p DECIMALS 2.
    DATA : unit TYPE c LENGTH 30.
    DATA : sum_dis TYPE p DECIMALS 2.
    DATA : sum_gst TYPE p DECIMALS 2.



    SELECT  d~purchaseorder ,
    d~purchaseorderitem,
    conditiontype,
           conditionratevalue, conditionquantityunit,
           conditionamount, conditioncurrency ,c~companycodename ,d~purchasingdocumentdeletioncode,
           e~rate
      FROM i_purorditmpricingelementapi01 AS a
      INNER JOIN i_purchaseorderapi01 AS b
      ON a~pricingdocument = b~pricingdocument AND b~language = 'E'
      INNER JOIN i_companycode AS c ON c~companycode  = b~companycode
      INNER JOIN i_purchaseorderitemapi01 AS d ON d~purchaseorder = a~purchaseorder AND
       d~purchaseorderitem = a~purchaseorderitem
      LEFT JOIN zi_taxcode AS e ON e~taxcode = d~taxcode
      WHERE a~purchaseorder EQ @lv_po
      AND d~purchasingdocumentdeletioncode <> 'L'
      INTO TABLE  @DATA(dis)
     PRIVILEGED ACCESS.

*     DATA : wa_dis like disss.

*    IF disss IS NOT INITIAL.
*      LOOP AT disss INTO DATA(dis).
*        dis1 = abs( dis-conditionratevalue ).
*        discsss = abs( dis-conditionamount ).
*        unit  = dis-conditionquantityunit.
*        DATA(yy1_gst_rate_pdi) = dis-rate.
*        IF dis1 IS NOT INITIAL.
*          disc1 = dis1.
*          disc1 = disc1.
*          CONDENSE :  disc1.
*        ENDIF.
*
*        IF unit IS NOT INITIAL .
*          disc_2 = |{ dis1 } / { unit }|.
*        ELSE.
*          disc_2 = disc1.
*          CONDENSE: disc_2.
*        ENDIF.
*
*
*        IF dis-conditioncurrency IS NOT INITIAL.
*          disc_3 = |{ dis1 } { dis-conditioncurrency }|.
*        ELSE.
*          disc_3 = disc1.
*          CONDENSE: disc_3.
*        ENDIF.
*
*
*        IF discsss  IS NOT INITIAL.
*          dis_value = discsss .
*          dis_value = dis_value.
*          CONDENSE :  dis_value.
*        ENDIF.
*
*        IF dis-conditiontype = 'TTX1'.
*          sum_gst += discsss.
*        ENDIF.
*
*        DATA : yy1_total_gst_pdi TYPE c LENGTH 30.
*        yy1_total_gst_pdi += sum_gst.
*
*        CASE dis-conditiontype.
*          WHEN 'ZDCP'.
*            CONDENSE  disc1.
*            disc1 = |{ disc1 }%|.
*            DATA(yy1_discount_pdi) = disc1.
*            dis_value = |{ dis_value } INR|.
*            DATA(yy1_dis_val_pdi) = dis_value.
*            sum_dis += discsss.

*            DATA : yy1_total_dis_value_pdi TYPE c LENGTH 30.
*
*
*            yy1_total_dis_value_pdi += sum_dis.
*          WHEN 'ZDCQ'.
*            yy1_discount_pdi =  disc_2.
*            dis_value = |{ dis_value } INR|.
*            yy1_dis_val_pdi = dis_value.
*            sum_dis += discsss.
*
*
*            yy1_total_dis_value_pdi += sum_dis.
*          WHEN 'ZCD1'.
*            yy1_discount_pdi =  disc_2.
*            dis_value = |{ dis_value  }INR|.
*            yy1_dis_val_pdi = dis_value.
*            sum_dis += discsss.
*            yy1_total_dis_value_pdi += sum_dis.
*          WHEN 'ZDCV'.
*
*            dis_value = |{ dis_value } INR|.
*            yy1_dis_val_pdi = dis_value.
*            sum_dis += discsss.
*
*            yy1_total_dis_value_pdi += sum_dis.
*        ENDCASE.
*
*        CLEAR : disc1,  disc_2 ,disc_3 .
*        CLEAR : dis ,dis1  ,discsss ,dis_value ,sum_gst ,sum_dis .
*
*      ENDLOOP.
*    ENDIF.

    DATA(main_xml) =
       |<FORM>| &&
       |<PurchaseOrderNode>| &&
       |<HEADER>| &&
       |<CompanyCode>{ wa_header-CompanyCode }</CompanyCode>| &&
       |<CompanyName>{ yy1_company_name_pdi }</CompanyName>| &&
       |<companyAd>{ yy1_company_address_pdi }</companyAd>| &&
       |<PurchaseOrder>{ wa_header-PurchaseOrder }</PurchaseOrder>| &&
       |<PurchaseOrderDate>{ wa_header-PurchaseOrderDate }</PurchaseOrderDate>| &&
       |<Supplier>{ wa_header-Supplier }</Supplier>| &&
       |<YY1_SupplierName_PDH>{ yy1_suppliername_pdh }</YY1_SupplierName_PDH>| &&
       |<YY1_VendorAddress_PDH>{ yy1_vendoraddress_pdh }</YY1_VendorAddress_PDH>| &&
       |<IN_GSTIdentificationNumber>{ wa_header-TaxNumber3 }</IN_GSTIdentificationNumber>| &&
       |</HEADER>| &&
       |<PurchaseOrderItems>|.

    LOOP AT it INTO DATA(wa).
      DATA(lv_item) =
      |<PurchaseOrderItemNode>| &&
      |<desc>{ wa-ProductName }</desc>| &&
      |<material>{ wa-Product }</material>| &&
      |<hsn></hsn>| &&
      |<qty>{ wa-OrderQuantity }</qty>|.

      READ TABLE rate INTO DATA(wa_rate1) WITH KEY purchaseorder = wa-PurchaseOrder PurchaseOrderItem = wa-PurchaseOrderItem.

      IF sy-subrc = 0.
        IF wa_rate1-conditiontype = 'PMP0' OR wa_rate1-conditiontype = 'PPR0'.
          DATA(lv_rate) =
         |<rate>{ wa_rate1-ConditionRateValue }</rate>|.
        ENDIF.
      ENDIF.

      READ TABLE dis INTO DATA(wa_dis) WITH KEY purchaseorder = wa-PurchaseOrder PurchaseOrderItem = wa-PurchaseOrderItem.

      IF wa_dis-ConditionType = 'ZDCP'.
        DATA(lv_dis) =
        |<dis>{ wa_dis-ConditionAmount }% { wa_dis-ConditionQuantityUnit }</dis>| &&
        |<dis1>{ wa_dis-ConditionAmount } { wa_dis-ConditionCurrency }</dis1>|.
      ENDIF.
      IF wa_dis-ConditionType = 'ZDCQ'.
        DATA(lv_dis1) =
        |<dis>{ wa_dis-ConditionAmount }% { wa_dis-ConditionQuantityUnit }</dis>| &&
        |<dis1>{ wa_dis-ConditionAmount } { wa_dis-ConditionCurrency }</dis1>|.
      ENDIF.
      IF wa_dis-ConditionType = 'ZDCV'.
        DATA(lv_dis2) =
        |<dis>{ wa_dis-ConditionAmount }% { wa_dis-ConditionQuantityUnit }</dis>| &&
        |<dis1>{ wa_dis-ConditionAmount } { wa_dis-ConditionCurrency }</dis1>|.
      ENDIF.

      IF wa_dis-ConditionType = 'ZCD1'.
        DATA(lv_dis3) =
        |<dis>{ wa_dis-ConditionAmount }% { wa_dis-ConditionQuantityUnit }</dis>| &&
        |<dis1>{ wa_dis-ConditionAmount } { wa_dis-ConditionCurrency }</dis1>|.
      ENDIF.


*      |<gst>{ yy1_gst_rate_pdi }</gst>| &&
*      |</PurchaseOrderItemNode>|.

      CONCATENATE main_xml lv_item lv_rate lv_dis lv_dis1 lv_dis2 lv_dis3 '|</PurchaseOrderItemNode>' INTO main_xml.
      CLEAR wa.
*      CLEAR yy1_gst_rate_pdi.
*      CLEAR yy1_discount_pdi.
*      CLEAR yy1_rate_pdi.
*      CLEAR yy1_dis_val_pdi.
      CLEAR wa_rate1.
      CLEAR wa_dis.



    ENDLOOP.

    CONCATENATE main_xml '</PurchaseOrderItems>' '</PurchaseOrderNode>' '</FORM>' INTO main_xml.
*    out->write( main_xml ).

    CALL METHOD zcl_ads_master=>getpdf(
      EXPORTING
        xmldata  = main_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).


  ENDMETHOD.
ENDCLASS.
