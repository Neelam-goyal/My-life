CLASS zopf_driver DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION .

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
                  lv_saleorder    TYPE C
*                  company_code     TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .

  PROTECTED SECTION.
  PRIVATE SECTION.

  CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZOPF/ZOPF'."'zpo/zpo_v2'."
ENDCLASS.



CLASS ZOPF_DRIVER IMPLEMENTATION.


 METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD .


  METHOD read_posts .

    DATA r_flag TYPE i VALUE 0.
    DATA d_flag TYPE i VALUE 0.
    DATA i_flag TYPE i VALUE 0.
    DATA c_s_flag TYPE i VALUE 0.
    DATA lv_container TYPE string.
    DATA pidate TYPE string.
    DATA lv_totalqtycb TYPE I_SalesQuotationItem-OrderQuantity.
    DATA lv_totalqtykg TYPE I_SalesQuotationItemTP-ItemNetWeight.
    DATA devcharges TYPE  I_SalesQuotationTP-YY1_DevelopmentCharges_SDH.
    DATA buyerpo TYPE string.
    DATA lv_pidate TYPE c LENGTH 12.
    DATA lv_buydate TYPE c LENGTH 12.

    SELECT SINGLE a~salesorganization,a~Salesorder,a~Creationdate,a~purchaseorderbycustomer,a~CustomerPurchaseOrderDate,b~salesorganizationname,
    c~customer,d~customername,e~countryname FROM i_salesorder AS a
    LEFT JOIN i_salesorganizationtext AS b ON b~SalesOrganization = a~SalesOrganization AND b~Language = 'E'
    LEFT JOIN  i_salesorderpartner AS c ON c~SalesOrder = a~SalesOrder AND c~PartnerFunction = 'RE'
    LEFT JOIN  i_customer AS d ON d~customer = c~customer AND d~Language = 'E'
    LEFT JOIN I_CountryText AS e ON e~Country = d~Country AND e~Language = 'E'
     WHERE a~SalesOrder = @lv_saleorder
    INTO  @DATA(lv_header).


*    ******************container logic*******************
     select single  from I_salesordertp
     fields YY1_ContainerCount_SDH
      WHERE SalesOrder = @lv_saleorder
     into @data(cont).


**************************************************I

*   select single from I_SalesOrder as a
*   left join i_salesquotationtp as b on a~ReferenceSDDocument = b~SalesOrganization
*   fields b~YY1_Batch_format_SDH , B~SalesQuotation , a~SalesOrder
*   where a~SalesOrder = @lv_saleorder
*   into @data(lv_batchformat).

    CONCATENATE lv_header-CustomerPurchaseOrderDate+6(2) lv_header-CustomerPurchaseOrderDate+4(2) lv_header-CustomerPurchaseOrderDate+0(4) INTO lv_buydate
    SEPARATED BY '/'.

    CONCATENATE lv_header-purchaseorderbycustomer 'DATE' lv_buydate INTO buyerpo SEPARATED BY space.

    SELECT a~ReferenceSDDocument,
           a~orderquantity as qtyincb,
           a~itemnetweight as qtyinkgs,
           a~salesorderitemtext as productdescription,
           b~YY1_NoofContainers_sdi,
           b~YY1_ContType_sdi,
           j~yy1_dispatchschedule_sdh,
           d~yy1_brandcode_prd,
           c~yy1_shelflife_sdh,
           c~YY1_ThirdPartyInspecti_SDH,
           i~yy1_packingmaterial_sdi,
           c~YY1_Batch_format_SDH,
*           e~material_text AS productdescription
           e~materialcode,
           d~product,
           d~netweight,
*           f~OrderQuantity,
           b~itemnetweight,
           c~YY1_DevelopmentCharges_SDH,
           g~plantname1,
           h~creationdate
    FROM I_SalesOrderItem AS a
    lEFT JOIN I_SalesOrderTP as j on a~SalesOrder = j~SalesOrder
    LEFT JOIN I_SalesOrderItemTP AS i ON a~SalesOrder = i~SalesOrder AND a~SalesOrderItem = i~SalesOrderItem
    LEFT JOIN I_SalesQuotationItemTP AS b ON b~SalesQuotation = a~ReferenceSDDocument AND b~SalesQuotationItem = a~ReferenceSDDocumentItem
    LEFT JOIN I_SalesQuotationTP AS c ON c~SalesQuotation = a~ReferenceSDDocument
    LEFT JOIN I_SalesQuotation AS h ON h~SalesQuotation = a~ReferenceSDDocument
    LEFT JOIN I_product AS d ON d~Product = a~Product
    LEFT JOIN zmaterialtext AS e ON e~materialcode = d~Product
*    left join I_PRODUCTDESCRIPTION as e on e~product = d~product
    LEFT JOIN I_SalesQuotationItem AS f ON f~SalesQuotation = b~SalesQuotation AND f~SalesQuotationItem = b~SalesQuotationitem
    LEFT JOIN zdd_plant_tableexcel AS g ON g~plantcode = a~Plant
    WHERE a~SalesOrder = @lv_saleorder
    INTO TABLE @DATA(it_line).

    select FROM I_SalesOrderItem AS a
    LEFT JOIN I_SalesQuotationItemTP AS b ON b~SalesQuotation = a~ReferenceSDDocument AND b~SalesQuotationItem = a~ReferenceSDDocumentItem
    LEFT JOIN I_SalesQuotationTP AS c ON c~SalesQuotation = a~ReferenceSDDocument
    LEFT JOIN I_SalesQuotation AS h ON h~SalesQuotation = a~ReferenceSDDocument
    LEFT JOIN I_product AS d ON d~Product = b~Product
    LEFT JOIN zmaster_tab WITH PRIVILEGED ACCESS AS f ON d~YY1_brandcode_PRD = f~brandcode
    fields b~Product,
           d~YY1_brandcode_PRD,f~brandtag
    WHERE SalesOrder = @lv_saleorder
    INTO TABLE @DATA(lv_brand).

        DATA: brandcode        TYPE string,
          lt_unique_brands TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line,
          lv_brand1         TYPE string.

    LOOP AT lv_brand INTO DATA(wa_brand).
      IF wa_brand-brandtag IS NOT INITIAL.
        lv_brand1 = wa_brand-brandtag.
        INSERT lv_brand1 INTO  TABLE lt_unique_brands.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_unique_brands INTO lv_brand1.
      IF brandcode IS INITIAL.
        brandcode = lv_brand1.
      ELSE.
        CONCATENATE brandcode lv_brand1 INTO brandcode SEPARATED BY ','.
      ENDIF.
    ENDLOOP.

*" Step 1: Remove empty and duplicate brand codes
*DATA(lt_unique_brands) = VALUE string_table( ).
*LOOP AT lv_brand ASSIGNING FIELD-SYMBOL(<fs_brand>).
*    IF <fs_brand>-YY1_brandcode_PRD IS NOT INITIAL AND
*       NOT line_exists( lt_unique_brands[ table_line = <fs_brand>-YY1_brandcode_PRD ] ).
*        APPEND <fs_brand>-YY1_brandcode_PRD TO lt_unique_brands.
*    ENDIF.
*ENDLOOP.
*
*" Step 2: Concatenate with commas (if entries exist)
*DATA(lv_brand_string) = COND string(
*    WHEN lt_unique_brands IS NOT INITIAL
*    THEN concat_lines_of( table = lt_unique_brands sep = ',' )
*    ELSE '' ).


    DATA : lv_count TYPE i .
    lv_count = 1.

*    DATA(lv_xml) = |<Form>| &&
*                    |<SupplierName>{ lv_header-SalesOrganizationName }</SupplierName>| &&
*                    |<No>{ lv_header-SalesOrder }</No>| &&
*                    |<Date>{ lv_header-CreationDate }</Date>| &&
*                    |<PartyName>{ lv_header-CustomerName }</PartyName>| &&
*                    |<Country>{ lv_header-countryname }</Country>| &&
***                    |<Container>{  }</Container>| &&
*                    |<BatchFormat>{ '' }</BatchFormat>| &&
*                    |<PiNoDate>{ ' ' }</PiNoDate>| &&
*                    |<DispatchSchedule>{ '' }</DispatchSchedule>| &&
*                    |<ShelfLife>{ '' }</ShelfLife>| &&
*                    |<BuyersPoNo>{ lv_header-PurchaseOrderByCustomer }</BuyersPoNo>| &&
*                    |<ThirdPartyInspection>{ '' }</ThirdPartyInspection>| &&
*                    |<TotalQtyInCb>{ ' ' }</TotalQtyInCb>| &&
*                    |<TotalQtyInKgs>{ '' }</TotalQtyInKgs>| &&
*                    |<Advance>{ ''  }</Advance>| &&
*                    |<EcgcLimit>{ '' }</EcgcLimit>| &&
*                    |<DevCharges>{ '' }</DevCharges>| &&
*                    |<BalAfterShp>{ '' }</BalAfterShp>| &&
*                    |<temp1>{ '' }</temp1>| &&
*                    |<Table>|.
*
*    DATA : lv_xml1 TYPE string .


    LOOP AT it_line ASSIGNING FIELD-SYMBOL(<fs_line>).
      SHIFT <fs_line>-product LEFT DELETING LEADING '0'.
    ENDLOOP.

    LOOP AT it_line INTO DATA(wa_lines).


      IF wa_lines-productdescription IS INITIAL.
        SELECT SINGLE productdescription FROM I_ProductDescription WHERE Product = @wa_lines-Product INTO @DATA(des).
        IF sy-subrc EQ 0.
          wa_lines-productdescription = des.
        ENDIF.

      ENDIF.
      CONCATENATE wa_lines-CreationDate+6(2) wa_lines-CreationDate+4(2) wa_lines-CreationDate+0(4) INTO lv_pidate
      SEPARATED BY '/'.

      CONCATENATE wa_lines-YY1_NoofContainers_SDI 'X' wa_lines-YY1_ContType_SDI INTO lv_container SEPARATED BY space.
      CONCATENATE wa_lines-ReferenceSDDocument '-' lv_pidate INTO pidate SEPARATED BY space.

      lv_totalqtycb = lv_totalqtycb + wa_lines-qtyincb.
      lv_totalqtykg = lv_totalqtykg + wa_lines-ItemNetWeight.
      devcharges =  wa_lines-YY1_DevelopmentCharges_SDH.


      DATA(lv_xml2) = |<Item>| &&
       |<SRNO>{ lv_count }</SRNO>| &&
       |<MATDES>{ wa_lines-productdescription }</MATDES>| &&
       |<PackingMaterial>{ wa_lines-YY1_PackingMaterial_SDI }</PackingMaterial>| &&
       |<NetWt>{ wa_lines-NetWeight }</NetWt>| &&
       |<product>{ wa_lines-product }</product>| &&
       |<QtyInCb>{ wa_lines-qtyincb }</QtyInCb>| &&
       |<QtyInKgs>{ wa_lines-qtyinkgs }</QtyInKgs>| &&
       |</Item>|.

      DATA(lv_xml) = |<Form>| &&
                   |<SupplierName>{ wa_lines-PlantName1 }</SupplierName>| &&
                   |<No>{ lv_header-SalesOrder }</No>| &&
                   |<container_cnt>{ cont }</container_cnt>| &&
                   |<Date>{ lv_header-CreationDate }</Date>| &&
                   |<PartyName>{ lv_header-CustomerName }</PartyName>| &&
                   |<Country>{ lv_header-countryname }</Country>| &&
                   |<Brand>{ brandcode }</Brand>| &&
                   |<Container>{ lv_container }</Container>| &&
                   |<BatchFormat>{ wa_lines-YY1_Batch_format_SDH }</BatchFormat>| &&
                   |<PiNo>{ pidate }</PiNo>| &&
                   |<PiNoDate>{ lv_header-CustomerPurchaseOrderDate }</PiNoDate>| &&
                   |<DispatchSchedule>{ wa_lines-YY1_DispatchSchedule_SDH }</DispatchSchedule>| &&
                   |<ShelfLife>{ wa_lines-YY1_ShelfLife_SDH }</ShelfLife>| &&
                   |<BuyersPoNo>{ buyerpo }</BuyersPoNo>| &&
                   |<ThirdPartyInspection>{ wa_lines-YY1_ThirdPartyInspecti_SDH }</ThirdPartyInspection>| &&
                   |<TotalQtyInCb>{ lv_totalqtycb  }</TotalQtyInCb>| &&
                   |<TotalQtyInKgs>{ lv_totalqtykg  }</TotalQtyInKgs>| &&
                   |<Advance>{ ''  }</Advance>| &&
                   |<EcgcLimit>{ '' }</EcgcLimit>| &&
                   |<DevCharges>{ devcharges }</DevCharges>| &&
                   |<BalAfterShp>{ '' }</BalAfterShp>| &&
                   |<temp1>{ '' }</temp1>| &&
                   |<Table>|.

      DATA : lv_xml1 TYPE string .

      CONCATENATE lv_xml1 lv_xml2 INTO lv_xml1.
      lv_count += 1.
      clear : wa_lines.
    ENDLOOP.

    DATA(lv_xml3) =   |</Table>| &&
                      |</Form>|.

    CONCATENATE lv_xml lv_xml1 lv_xml3 INTO lv_xml.
     REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.

    CALL METHOD zcl_ads_master=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
