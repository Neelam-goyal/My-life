CLASS zcl_performainvoice DEFINITION
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
      END OF struct."


    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING
                  salesQT        TYPE string
*                  company_code     TYPE string
               lc_template_name  TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
*    CONSTANTS lc_template_name TYPE string VALUE 'ZBonnTaxInvoice/ZBonnTaxInvoice'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE string VALUE 'zsd_sto_tax_inv/zsd_sto_tax_inv'."'zpo/zpo_v2'."
*    CONSTANTS company_code TYPE string VALUE 'GT00'.
ENDCLASS.



CLASS ZCL_PERFORMAINVOICE IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts.
    DATA : plant_add   TYPE string.
    DATA : p_add1  TYPE string.
    DATA : p_add2 TYPE string.
    DATA : p_city TYPE string.
    DATA : p_dist TYPE string.
    DATA : p_state TYPE string.
    DATA : p_pin TYPE string.
    Data : p_name type string.
    DATA : CUSTREF TYPE string.
    DATA : p_StateCode type string.
    DATA : p_country   TYPE string,
           plant_name  TYPE string,
           plant_gstin TYPE string.



SELECT SINGLE FROM I_SalesQuotation AS a
    FIELDS a~SalesQuotation , a~CreationDate,a~TransactionCurrency
     WHERE SalesQuotation = @salesQT
    INTO @DATA(wa_header).

*    SELECT SINGLE FROM I_SalesQuotation WITH PRIVILEGED ACCESS AS a
*    LEFT JOIN I_SalesOrganizationText  WITH PRIVILEGED ACCESS AS b ON a~SalesOrganization = b~SalesOrganization
*    LEFT JOIN I_SalesQuotationItem WITH PRIVILEGED ACCESS AS c ON a~SalesQuotation = c~SalesQuotation
*    LEFT JOIN I_Plant WITH PRIVILEGED ACCESS AS d ON c~Plant = d~Plant
*    LEFT JOIN I_Customer WITH PRIVILEGED ACCESS AS e ON d~PlantCustomer = e~Customer
*    LEFT JOIN I_Address_2 WITH PRIVILEGED ACCESS  AS f ON e~AddressID = f~AddressID
*    LEFT JOIN I_RegionText WITH PRIVILEGED ACCESS AS g ON f~Region = g~Region AND f~Country = g~Country AND g~Language = 'E'
*    LEFT JOIN I_CountryText WITH PRIVILEGED ACCESS AS h ON f~Country = h~Country AND h~Language = 'E'
*    FIELDS b~SalesOrganizationName, f~StreetPrefixName1,f~StreetPrefixName2,f~StreetName,f~CityName,f~PostalCode,g~RegionName,h~CountryName,e~TelephoneNumber1,
*    e~TaxNumber3
*    WHERE a~SalesQuotation = @salesQT
*    INTO @DATA(wa_supplier).

   SELECT SINGLE FROM I_SalesQuotation WITH PRIVILEGED ACCESS AS a
    LEFT JOIN I_SalesQuotationItem WITH PRIVILEGED ACCESS AS b ON a~SalesQuotation = b~SalesQuotation
    left join ztable_plant as c on c~plant_code = b~Plant
   fields c~comp_code, c~plant_name1,c~address2,c~address1,c~city,c~pin,c~state_name,c~country,c~phone,c~gstin_no,a~SalesOrganization
   WHERE a~SalesQuotation = @salesQT
    INTO @DATA(wa_supplier).

    SELECT SINGLE FROM I_SalesQuotationPartner AS a
    LEFT JOIN I_Customer AS b ON a~Customer = b~Customer
    LEFT JOIN I_Address_2 WITH PRIVILEGED ACCESS AS c ON b~AddressID = c~AddressID
     LEFT JOIN I_RegionText WITH PRIVILEGED ACCESS AS g ON c~Region = g~Region AND c~Country = g~Country AND g~Language = 'E'
    LEFT JOIN I_CountryText WITH PRIVILEGED ACCESS AS h ON c~Country = h~Country AND h~Language = 'E'
    LEFT JOIN  i_addressemailaddress_2 WITH PRIVILEGED ACCESS AS i ON c~AddressID = i~AddressID
    FIELDS a~Customer ,b~CustomerName,a~FullName, c~StreetName, c~StreetPrefixName1,c~StreetPrefixName2,c~CityName,c~PostalCode,g~RegionName,h~CountryName,b~TelephoneNumber1,
    i~EmailAddress,b~TaxNumber3
    WHERE a~SalesQuotation = @salesQT AND a~PartnerFunction = 'RE'
     INTO @DATA(wa_buyer).


      SELECT SINGLE FROM I_SalesQuotationPartner AS a
    LEFT JOIN I_Customer AS b ON a~Customer = b~Customer
    LEFT JOIN I_Address_2 WITH PRIVILEGED ACCESS AS c ON b~AddressID = c~AddressID
     LEFT JOIN I_RegionText WITH PRIVILEGED ACCESS AS g ON c~Region = g~Region AND c~Country = g~Country AND g~Language = 'E'
    LEFT JOIN I_CountryText WITH PRIVILEGED ACCESS AS h ON c~Country = h~Country AND h~Language = 'E'
    LEFT JOIN  i_addressemailaddress_2 WITH PRIVILEGED ACCESS AS i ON c~AddressID = i~AddressID
    FIELDS a~Customer ,b~CustomerName,a~FullName, c~StreetName, c~StreetPrefixName1,c~StreetPrefixName2,c~CityName,c~PostalCode,g~RegionName,h~CountryName,b~TelephoneNumber1,
    i~EmailAddress,b~TaxNumber3
    WHERE a~SalesQuotation = @salesQT AND a~PartnerFunction = 'WE'
     INTO @DATA(wa_consignee).

     select single from I_SalesQuotationTP as a
     left join I_salesQuotation as b on  a~SalesQuotation = b~SalesQuotation
     fields a~YY1_NotifyParty1_SDH,b~SalesQuotation
     where a~SalesQuotation = @salesQT
     into @data(notify).

*********************************ITEMS******************************************

    SELECT YY1_NoofContainers_SDI, YY1_ContType_SDI, SalesQuotation,YY1_ContNo_SDI
      FROM I_SalesQuotationItemTP
      WHERE SalesQuotation = @salesQT
      GROUP BY YY1_NoofContainers_SDI, YY1_ContType_SDI, SalesQuotation,YY1_ContNo_SDI
      INTO TABLE @DATA(it).


      data: cont_sum type i.
      data : prev type I_SalesQuotationItemTP-YY1_NoofContainers_SDI.
      Loop at it into data(wa_sum).
      cont_sum = cont_sum + wa_sum-YY1_NoofContainers_SDI.
      ENDLOOP.



  TYPES: BEGIN OF ty_line_item,
         Product                   TYPE I_SalesQuotationItemtp-Product,
         YY1_ContType_SDI          TYPE I_SalesQuotationItemtp-YY1_ContType_SDI,
         YY1_NoofContainers_SDI    TYPE I_SalesQuotationItemtp-YY1_NoofContainers_SDI,
         ConsumptionTaxCtrlCode   TYPE I_ProductPlantBasic-ConsumptionTaxCtrlCode,
         NetWeight                 TYPE I_Product-NetWeight,
         OrderQuantity             TYPE I_SalesQuotationItem-OrderQuantity,
         ItemNetWeight             TYPE I_SalesQuotationItem-ItemNetWeight,
         ConditionRateValue       TYPE I_SalesQuotationItemPrcgElmnt-ConditionRateValue,
         ConditionAmount           TYPE I_SalesQuotationItemPrcgElmnt-ConditionAmount,
         ProductDescription        Type I_ProductDescription-ProductDescription,
         YY1_Loadability_PRD       type I_Product-YY1_Loadability_PRD,
         YY1_brandcode_PRD type i_Product-YY1_brandcode_PRD,
         brand type i_Product-YY1_brandcode_PRD,
         YY1_ContNo_SDI  type I_SalesQuotationItemtp-YY1_ContNo_SDI,
         material_text type  zmaterialtext-material_text,
         mat_desc type  zmaterialtext-material_text,
         brandtag type zmaster_tab-brandtag,
       END OF ty_line_item.

    DATA: line_items TYPE TABLE OF ty_line_item.
    data : line_items1 type table of ty_line_item.

      SELECT FROM I_SalesQuotationItemtp AS a
      left join zmaterialtext as g on a~Product = g~materialcode
      LEFT JOIN I_SalesQuotationItem AS d ON a~SalesQuotation = d~SalesQuotation AND a~SalesQuotationItem = d~SalesQuotationItem
      LEFT JOIN I_ProductPlantBasic AS b ON d~Plant = b~plant AND d~Product = b~Product
      LEFT JOIN i_product AS c ON d~Product = c~Product
      LEFT JOIN zmaster_tab with PRIVILEGED ACCESS as h on c~YY1_brandcode_PRD = h~brandcode
      left join I_ProductDescription as f on d~Product = f~Product
      LEFT JOIN I_SalesQuotationItemPrcgElmnt AS e ON d~SalesQuotation = e~SalesQuotation AND d~SalesQuotationItem = e~SalesQuotationItem
      FIELDS a~Product , a~YY1_ContType_SDI ,a~YY1_NoofContainers_SDI,b~ConsumptionTaxCtrlCode,c~NetWeight,d~OrderQuantity,d~ItemNetWeight,e~ConditionRateValue,
      e~ConditionAmount,f~ProductDescription,c~YY1_Loadability_PRD, c~YY1_brandcode_PRD,a~YY1_ContNo_SDI,g~material_text,g~material_text as mat_desc,
     c~YY1_brandcode_PRD as brand,h~brandtag
      WHERE a~SalesQuotation = @salesQT
*      AND a~YY1_NoofContainers_SDI = @wa_container-YY1_NoofContainers_SDI AND a~YY1_ContType_SDI = @wa_container-YY1_ContType_SDI
      AND e~ConditionType = 'PPR0'
      INTO CORRESPONDING FIELDS OF TABLE @line_items.

    data :  mat_desc type zmaterialtext-material_text.

    loop at line_items into data(wa_final).
    if wa_final-material_text is not INITIAL.
    wa_final-mat_desc = wa_final-material_text.
    else.
    wa_final-mat_desc = wa_final-productdescription.
    endif.
    modify line_items from wa_final.
    ENDLOOP.


************************brand multi code**************
        DATA: brandcode TYPE string,
              lt_unique_brands TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line,
              lv_brand TYPE string.

        CLEAR brandcode.

        LOOP AT line_items INTO DATA(wa_brand).
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


**************************************************


    Select from I_SalesQuotationItem as a
    left join  I_SalesQuotationItemPrcgElmnt as b on a~SalesQuotation = b~SalesQuotation and a~SalesQuotationItem = b~SalesQuotationItem
    fields b~ConditionAmount
    where b~ConditionType = 'ZFRT' and a~SalesQuotation = @salesQT
    into table @data(it_frt).

    Select from I_SalesQuotationItem as a
    left join  I_SalesQuotationItemPrcgElmnt as b on a~SalesQuotation = b~SalesQuotation and a~SalesQuotationItem = b~SalesQuotationItem
    fields b~ConditionAmount
    where b~ConditionType = 'ZINS'  and a~SalesQuotation = @salesQT
    into table @data(it_ins).

    Select from I_SalesQuotationItem as a
    left join  I_SalesQuotationItemPrcgElmnt as b on a~SalesQuotation = b~SalesQuotation and a~SalesQuotationItem = b~SalesQuotationItem
    fields b~ConditionAmount
    where b~ConditionType = 'ZPCK'  and a~SalesQuotation = @salesQT
    into table @data(it_pack).

    Select from I_SalesQuotationItem as a
    left join  I_SalesQuotationItemPrcgElmnt as b on a~SalesQuotation = b~SalesQuotation and a~SalesQuotationItem = b~SalesQuotationItem
    fields b~ConditionAmount
    where b~ConditionType in ( 'ZDQT', 'ZDPT' )  and a~SalesQuotation = @salesQT
    into table @data(it_dis).

    data: freight type I_SalesQuotationItemPrcgElmnt-ConditionAmount.
    data : ins type I_SalesQuotationItemPrcgElmnt-ConditionAmount.
    data : pack type I_SalesQuotationItemPrcgElmnt-ConditionAmount.
    data : dis type  I_SalesQuotationItemPrcgElmnt-ConditionAmount.

    Loop at it_frt into data(wa_frt).
     freight = freight + wa_frt-ConditionAmount.
    endloop.

    Loop at it_ins into data(wa_ins).
     ins = ins + wa_ins-ConditionAmount.
    endloop.

    Loop at it_pack into data(wa_pack).
     pack = pack + wa_pack-ConditionAmount.
    endloop.

    loop at it_dis into data(wa_dis).
      dis = dis + wa_dis-ConditionAmount.
    ENDLOOP.


*   *****************************Footer******************************
    SELECT SINGLE FROM I_SalesQuotation AS a
    LEFT JOIN I_PaymentTermsText AS b ON a~CustomerPaymentTerms = b~PaymentTerms AND b~Language = 'E'
    LEFT JOIN I_SalesQuotationTP AS c ON a~SalesQuotation = c~SalesQuotation
    FIELDS a~IncotermsClassification,b~PaymentTermsName,c~YY1_PortOfLoading_SDH,c~YY1_PortOfDischarge_SDH,c~YY1_CountryOfDestinati_SDH,a~PurchaseOrderByCustomer,
    c~YY1_Product_SDH, c~YY1_NegotiationofDoc_SDH,c~YY1_DevelopmentCharges_SDH,c~YY1_ContainerPickPoint_SDH, c~YY1_ShelfLife_SDH,c~YY1_DispatchSchedule_SDH,
    c~YY1_ThirdPartyInspecti_SDH,c~YY1_Stuffing_SDH,c~YY1_Remarks_SDH,a~CustomerPurchaseOrderDate
    WHERE  a~SalesQuotation = @salesQT
    INTO @DATA(footer).

     DATA: lv_date_string TYPE string,
      podateandno    TYPE string.

     lv_date_string = |{ footer-CustomerPurchaseOrderDate+6(2) }/{ footer-CustomerPurchaseOrderDate+4(2) }/{ footer-CustomerPurchaseOrderDate+0(4) }|.

     CONCATENATE footer-PurchaseOrderByCustomer lv_date_string INTO podateandno SEPARATED BY '    '.


    DATA : add1 TYPE string.
    IF wa_supplier-address1 IS NOT INITIAL.
      CONCATENATE wa_supplier-address1 '' INTO add1 SEPARATED BY space.
    ENDIF.
    IF wa_supplier-address2 IS NOT INITIAL.
      CONCATENATE add1 wa_supplier-address2 INTO add1 SEPARATED BY ', '.
    ENDIF.

    DATA : add2 TYPE string.
    IF wa_supplier-city IS NOT INITIAL.
      CONCATENATE wa_supplier-city '' INTO add2 SEPARATED BY space.
    ENDIF.
    IF wa_supplier-pin IS NOT INITIAL.
      CONCATENATE add2 wa_supplier-pin INTO add2 SEPARATED BY ', '.
    ENDIF.
    IF wa_supplier-state_name IS NOT INITIAL.
      CONCATENATE add2 wa_supplier-state_name INTO add2 SEPARATED BY ', '.
    ENDIF.
        IF wa_supplier-country IS NOT INITIAL.
      CONCATENATE add2 wa_supplier-country INTO add2 SEPARATED BY ', '.
    ENDIF.


    DATA : tel TYPE string.
    IF wa_supplier-phone IS NOT INITIAL.
      tel = wa_supplier-phone.
    ENDIF.

DATA: add1b TYPE string.

add1b = wa_buyer-StreetName. " Start with StreetName

IF wa_buyer-StreetPrefixName1 IS NOT INITIAL.
  IF add1b IS NOT INITIAL.
    CONCATENATE add1b wa_buyer-StreetPrefixName1 INTO add1b SEPARATED BY ', '.
  ELSE.
    add1b = wa_buyer-StreetPrefixName1.
  ENDIF.
ENDIF.

IF wa_buyer-StreetPrefixName2 IS NOT INITIAL.
  IF add1b IS NOT INITIAL.
    CONCATENATE add1b wa_buyer-StreetPrefixName2 INTO add1b SEPARATED BY ', '.
  ELSE.
    add1b = wa_buyer-StreetPrefixName2.
  ENDIF.
ENDIF.

    DATA: add2b TYPE string.

add2b = wa_buyer-CityName. " Start with CityName

IF wa_buyer-RegionName IS NOT INITIAL.
  IF add2b IS NOT INITIAL.
    CONCATENATE add2b wa_buyer-RegionName INTO add2b SEPARATED BY ', '.
  ELSE.
    add2b = wa_buyer-RegionName.
  ENDIF.
ENDIF.

IF wa_buyer-CountryName IS NOT INITIAL.
  IF add2b IS NOT INITIAL.
    CONCATENATE add2b wa_buyer-CountryName INTO add2b SEPARATED BY ', '.
  ELSE.
    add2b = wa_buyer-CountryName.
  ENDIF.
ENDIF.

    DATA : add3 TYPE string.
    IF wa_buyer-TelephoneNumber1 IS NOT INITIAL.
      CONCATENATE wa_buyer-TelephoneNumber1 '' INTO add3 SEPARATED BY space.
    ENDIF.
    IF wa_buyer-EmailAddress IS NOT INITIAL.
      CONCATENATE add3 wa_buyer-EmailAddress INTO add3 SEPARATED BY ', '.
    ENDIF.




 DATA: add1c TYPE string.

add1c = wa_consignee-StreetName. " Start with StreetName

IF wa_consignee-StreetPrefixName1 IS NOT INITIAL.
  IF add1c IS NOT INITIAL.
    CONCATENATE add1c wa_consignee-StreetPrefixName1 INTO add1c SEPARATED BY ', '.
  ELSE.
    add1c = wa_consignee-StreetPrefixName1.
  ENDIF.
ENDIF.

IF wa_consignee-StreetPrefixName2 IS NOT INITIAL.
  IF add1c IS NOT INITIAL.
    CONCATENATE add1c wa_consignee-StreetPrefixName2 INTO add1c SEPARATED BY ', '.
  ELSE.
    add1c = wa_consignee-StreetPrefixName2.
  ENDIF.
ENDIF.

    DATA: add2c TYPE string.

add2c = wa_consignee-CityName. " Start with CityName

IF wa_consignee-RegionName IS NOT INITIAL.
  IF add2c IS NOT INITIAL.
    CONCATENATE add2c wa_consignee-RegionName INTO add2c SEPARATED BY ', '.
  ELSE.
    add2c = wa_consignee-RegionName.
  ENDIF.
ENDIF.

IF wa_consignee-CountryName IS NOT INITIAL.
  IF add2c IS NOT INITIAL.
    CONCATENATE add2c wa_consignee-CountryName INTO add2c SEPARATED BY ', '.
  ELSE.
    add2c = wa_consignee-CountryName.
  ENDIF.
ENDIF.

    DATA : add3c TYPE string.
    IF wa_consignee-TelephoneNumber1 IS NOT INITIAL.
      CONCATENATE wa_buyer-TelephoneNumber1 '' INTO add3c SEPARATED BY space.
    ENDIF.
    IF wa_consignee-EmailAddress IS NOT INITIAL.
      CONCATENATE add3c wa_buyer-EmailAddress INTO add3c SEPARATED BY ', '.
    ENDIF.

*    out->write( add1 ).

    DATA(lv_xml) = |<Form>| &&
    |<SalesQuotation>| &&
    |<SalesQuotationHeader>| &&
    |<SalesQuotation>{ wa_header-SalesQuotation  }</SalesQuotation>| &&
    |<Companycode>{ wa_supplier-comp_code  }</Companycode>| &&
    |<creation_date>{ wa_header-CreationDate }</creation_date>| &&
    |<currency>{ wa_header-TransactionCurrency }</currency>| &&
    |</SalesQuotationHeader>| &&
    |<supplier>| &&
    |<supplier_name>{ wa_supplier-plant_name1 }</supplier_name>| &&
    |<address1>{ add1 }</address1>| &&
    |<address2>{ add2 }</address2>| &&
    |<telephone>{ tel }</telephone>| &&
    |<gstin_supplier>{ wa_supplier-gstin_no }</gstin_supplier>| &&
    |</supplier>| &&
    |<buyer>| &&
    |<buyers_name>{ wa_buyer-CustomerName }</buyers_name>| &&
    |<address1_buyers>{ add1b }</address1_buyers>| &&
    |<address2_buyers>{ add2b }</address2_buyers>| &&
    |<address3_buyers>{ add3 }</address3_buyers>| &&
    |<gstin_buyer>{ wa_buyer-TaxNumber3  } </gstin_buyer>| &&
    |<buyer_cust>{ wa_buyer-Customer }</buyer_cust>| &&
    |</buyer>| &&
    |<consignee>| &&
    |<consignee_name>{ wa_consignee-CustomerName }</consignee_name>| &&
    |<address1_consignee>{ add1c }</address1_consignee>| &&
    |<address2_consignee>{ add2c }</address2_consignee>| &&
    |<address3_consignee>{ add3c }</address3_consignee>| &&
    |<gstin_buyer>{ wa_consignee-TaxNumber3  } </gstin_buyer>| &&
    |<consignee_cust>{ wa_consignee-Customer }</consignee_cust>| &&
    |</consignee>| &&
    |<notify>{ notify-YY1_NotifyParty1_SDH }</notify>| &&
    |<sales_org>{ wa_supplier-SalesOrganization }</sales_org>| &&
    |<Table>|.

    LOOP AT line_items INTO DATA(wa_containers).

      DATA(lv_xml2) = |<SalesQuotationItem>| &&
                      |<container>{ wa_containers-YY1_NoofContainers_SDI }</container>| &&
                      |<container_type>{ wa_containers-YY1_ContType_SDI }</container_type>| &&
                      |<container_no>{ wa_containers-yy1_contno_sdi }</container_no>| &&
                      |<desc>{ wa_containers-mat_desc }</desc>| &&
                      |<hsn>{ wa_containers-ConsumptionTaxCtrlCode }</hsn>| &&
                      |<net_weight>{ wa_containers-NetWeight }</net_weight>| &&
                      |<load_ability>{ wa_containers-yy1_loadability_prd }</load_ability>| &&
                      |<qty>{ wa_containers-OrderQuantity }</qty>| &&
                      |<total_net_weight>{ wa_containers-ItemNetWeight }</total_net_weight>| &&
                      |<price_carton>{ wa_containers-ConditionRateValue }</price_carton>| &&
                      |<amount>{ wa_containers-ConditionAmount }</amount>| &&
                      |<labels>{ brandcode }</labels>| &&
                      |</SalesQuotationItem>|.
      CLEAR wa_containers.
      CONCATENATE lv_xml lv_xml2 INTO lv_xml.
    ENDLOOP.


    DATA(lv_footer) = |</Table>| &&
                      |<shipment>{ footer-IncotermsClassification }</shipment>| &&
                      |<no_of_containers>{ cont_sum }</no_of_containers>| &&
                      |<payment_terms> { footer-PaymentTermsName }</payment_terms>| &&
                      |<remarks>{ footer-YY1_Remarks_SDH }</remarks>| &&
                      |<freight>{ freight }</freight>| &&
                      |<insurance>{ ins }</insurance>| &&
                      |<discount>{ dis }</discount>| &&
                      |<packing>{ pack }</packing>| &&
                      |<product>{ footer-YY1_Product_SDH }</product>| &&
                      |<port_loading>{ footer-YY1_PortOfLoading_SDH }</port_loading>| &&
                      |<negotiation>{ footer-YY1_NegotiationofDoc_SDH }</negotiation>| &&
                      |<dev_charges>{ footer-YY1_DevelopmentCharges_SDH }</dev_charges>| &&
                      |<pick_up>{ footer-YY1_ContainerPickPoint_SDH }</pick_up>| &&
                      |<purchaseordenodate>{ podateandno }</purchaseordenodate>| &&
                      |<shelf_life>{ footer-YY1_ShelfLife_SDH }</shelf_life>| &&
                      |<port_discharge>{ footer-YY1_PortOfDischarge_SDH }</port_discharge>| &&
                      |<country_dest>{ footer-YY1_CountryOfDestinati_SDH }</country_dest>| &&
                      |<dispatch_schedule>{ footer-YY1_DispatchSchedule_SDH }</dispatch_schedule>| &&
                      |<third_party_insp>{ footer-YY1_ThirdPartyInspecti_SDH }</third_party_insp>| &&
                      |<stuffing>{ footer-YY1_Stuffing_SDH }</stuffing>| &&
                      |</SalesQuotation>| &&
                      |</Form>|.

    CONCATENATE lv_xml lv_footer INTO lv_xml.
    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'zxcvbnm'.

    CALL METHOD zcl_ads_master=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).


  ENDMETHOD.
ENDCLASS.
