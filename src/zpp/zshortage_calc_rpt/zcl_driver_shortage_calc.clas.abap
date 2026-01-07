CLASS zcl_driver_shortage_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
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
                  production TYPE string
                  comp_code  TYPE string
                  plant  TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zshort_calc/zshort_calc'.
ENDCLASS.



CLASS ZCL_DRIVER_SHORTAGE_CALC IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD if_oo_adt_classrun~main.

*    TYPES: BEGIN OF ty_component_data,
*             material         TYPE c LENGTH 40,    " Component Number (Key)
*             BOMLocation      TYPE c LENGTH 4,     " BOM Location (Key)
*             productionorder  TYPE c LENGTH 12,  " Production Order (Mandatory Filter)
*             bukrs            TYPE c LENGTH 4,    " Company Code (Mandatory Filter, Value Help)
*             plant            TYPE c LENGTH 4,     " Plant (Mandatory Filter, Value Help)
*             maktx            TYPE c LENGTH 50,    " Component Description
*             stock            TYPE p DECIMALS 3 LENGTH 16,  " Quantity at BOM Location (Hidden Filter)
*             plantstock       TYPE p DECIMALS 3 LENGTH 16,  " Plant Stock (Hidden Filter)
*             requiredquantity TYPE p DECIMALS 3 LENGTH 16,  " Required Quantity (Hidden Filter)
*             short_excess_qty TYPE p DECIMALS 3 LENGTH 16,  " Short/Excess Quantity (Hidden Filter)
*           END OF ty_component_data.
*
*    DATA: lt_response    TYPE TABLE OF zcds_shortage_calc, " WITH KEY material bomlocation,
*          ls_line        LIKE LINE OF lt_response,
*          lt_responseout LIKE lt_response,
*          ls_responseout LIKE LINE OF lt_responseout.
*
*
*    TYPES: BEGIN OF ty_plantstock,
*             material        TYPE c LENGTH 40,
*             plant           TYPE c LENGTH 4,
*             StorageLocation TYPE c LENGTH 4,
*             plantstock      TYPE p LENGTH 16 DECIMALS 3,
*           END OF ty_plantstock.
*    DATA it_plantproduct TYPE TABLE OF ty_plantstock.
*    DATA it_lgort_product TYPE TABLE OF ty_plantstock.
*    DATA wa_plantproduct TYPE ty_plantstock.
*
*    SELECT FROM i_productionordertp AS a
*    LEFT JOIN I_ProductText AS b ON a~Product = b~Product
*    FIELDS a~ProductionOrder,a~product,a~OrderPlannedTotalQty,a~CreationDate,b~ProductName
*    WHERE a~ProductionOrder IN ( '000001000005','000000300060' )
*    INTO TABLE @DATA(it_line).
*
*    SELECT FROM I_ProductionOrderOpComponentTP  AS a
*    LEFT JOIN I_ProductDescription_2 AS b ON b~Product = a~Material AND b~Language = 'E'
*    LEFT JOIN I_BillOfMaterialItemBasic AS c ON c~BillOfMaterial = a~BillOfMaterialInternalID
*    AND c~BillOfMaterialCategory = a~BillOfMaterialCategory AND c~BillOfMaterialItemNodeNumber = a~BillOfMaterialItemNodeNumber
*    AND c~BOMItemInternalChangeCount = a~BOMItemInternalChangeCount
*    LEFT JOIN ZI_PlantTable AS d ON d~PlantCode = a~Plant
**    LEFT JOIN I_StockQuantityCurrentValue_2( p_displaycurrency = 'INR' ) AS e
**    ON e~Product = a~Material AND e~Plant = a~Plant AND e~StorageLocation = a~StorageLocation
**    AND e~ValuationAreaType = '1' AND e~InventoryStockType = '01'
*    FIELDS a~Reservation, a~ReservationItem, a~ReservationRecordType,  a~Material, a~plant,
*     a~ProductionOrder, a~storagelocation, a~BillOfMaterialCategory, a~BillOfMaterialItemNodeNumber,
*     a~BOMItemInternalChangeCount, a~RequiredQuantity,
*     b~ProductDescription,
*     c~ProdOrderIssueLocation " e~MatlWrhsStkQtyInMatlBaseUnit AS lgortstock
*    WHERE a~ProductionOrder IN ( '000001000005','000000300060' ) AND d~CompCode = 'PPAL'
*    AND a~Plant = 'PP02'
*    INTO TABLE @DATA(it) PRIVILEGED ACCESS.
*
*    SELECT FROM I_StockQuantityCurrentValue_2( p_displaycurrency = 'INR' )
*    FIELDS Product , Plant , StorageLocation, MatlWrhsStkQtyInMatlBaseUnit AS plantstock
*    WHERE Plant = 'PP02' AND ValuationAreaType = '1' AND InventoryStockType = '01'
*    INTO TABLE @DATA(it_plant_stock) PRIVILEGED ACCESS.
*
*    LOOP AT it_plant_stock ASSIGNING FIELD-SYMBOL(<wa_plantstock2>).
*      wa_plantproduct-material        = <wa_plantstock2>-Product.
*      wa_plantproduct-plant           = <wa_plantstock2>-Plant.
*      wa_plantproduct-storagelocation = <wa_plantstock2>-StorageLocation.
*      wa_plantproduct-plantstock      = <wa_plantstock2>-plantstock.
*      COLLECT wa_plantproduct INTO it_lgort_product.
*
*      CLEAR wa_plantproduct.
*      wa_plantproduct-material   = <wa_plantstock2>-Product.
*      wa_plantproduct-plant      = <wa_plantstock2>-Plant.
*      wa_plantproduct-plantstock = <wa_plantstock2>-plantstock.
*      COLLECT wa_plantproduct INTO it_plantproduct.
*      CLEAR wa_plantproduct.
*    ENDLOOP.
*
*    SORT it BY Material ProdOrderIssueLocation.
*    LOOP AT it ASSIGNING FIELD-SYMBOL(<wa>).
*      CLEAR ls_line.
*
*      ls_line-material              = <wa>-Material.
*      ls_line-plant                 = <wa>-Plant.
*      ls_line-maktx                 = <wa>-ProductDescription.
*      ls_line-BOMLocation           = <wa>-ProdOrderIssueLocation.
*      ls_line-requiredquantity      = <wa>-RequiredQuantity.
**      ls_line-productionorder       = <wa>-ProductionOrder.
*
*      COLLECT ls_line INTO lt_response.
*    ENDLOOP.
*
*    LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<ls_resp>).
*
*      READ TABLE it_lgort_product ASSIGNING FIELD-SYMBOL(<wa_lgort_product>)
*                 WITH KEY material = <ls_resp>-Material
*                          plant    = <ls_resp>-Plant
*                          storagelocation = <ls_resp>-BOMLocation.
*      IF sy-subrc = 0.
*        <ls_resp>-stock = <wa_lgort_product>-plantstock.
*      ENDIF.
*
*      READ TABLE it_plantproduct ASSIGNING FIELD-SYMBOL(<wa_plantstock>)
*           WITH KEY material = <ls_resp>-Material
*                    plant    = <ls_resp>-Plant.
*      IF sy-subrc = 0.
*        <ls_resp>-plantstock = <wa_plantstock>-plantstock.
*      ENDIF.
*
*      <ls_resp>-short_excess_qty = <ls_resp>-stock - <ls_resp>-requiredquantity.
*
*      <ls_resp>-material = | { <ls_resp>-material ALPHA = OUT } |.
*
*    ENDLOOP.
*    SORT lt_response BY productionorder material plant BOMLocation.
*
*    DATA(lv_xml) = |<Form>| &&
*                      |<comp_code></comp_code>| &&
*                      |<plant_code></plant_code>| &&
*                      |<comp_desc></comp_desc>| &&
*                      |<plant_desc></plant_desc>| &&
*                      |<table>|.
*
*    LOOP AT it_line INTO DATA(wa_line).
*      DATA(lv_xml2) = |<Item>| &&
*                      |<pro_no>{ wa_line-ProductionOrder }</pro_no>| &&
*                      |<fg_code>{ wa_line-Product }</fg_code>| &&
*                      |<fg_desc>{ wa_line-ProductName }</fg_desc>| &&
*                      |<qty>{ wa_line-OrderPlannedTotalQty }</qty>| &&
*                      |<creation_date>{ wa_line-CreationDate }</creation_date>| &&
*                      |</Item>|.
*      CONCATENATE lv_xml lv_xml2 INTO lv_xml.
*      CLEAR :  wa_line.
*    ENDLOOP.
*
*    CONCATENATE lv_xml '</table>' '<table2>' INTO lv_xml.
*
*    LOOP AT lt_response INTO DATA(wa_res).
*      DATA(lv_xml3) = |<item2>| &&
*                      |<comp_no>{ wa_res-material }</comp_no>| &&
*                      |<comp_desc>{ wa_res-maktx }</comp_desc>| &&
*                      |<qty_comp></qty_comp>| &&
*                      |<uom></uom>| &&
*                      |<bom_loc>{ wa_res-bomlocation }</bom_loc>| &&
*                      |<plant_stock>{ wa_res-plantstock }</plant_stock>| &&
*                      |<qty_req>{ wa_res-requiredquantity }</qty_req>| &&
*                      |<stock_bom>{ wa_res-stock }</stock_bom>| &&
*                      |<diff>{ wa_res-short_excess_qty }</diff>| &&
*                      |</item2>|.
*      CONCATENATE lv_xml lv_xml3 INTO lv_xml.
*      CLEAR :  wa_res.
*    ENDLOOP.
*    CONCATENATE lv_xml '</table2>' '</Form>' INTO lv_xml.
*    out->write( lv_xml ).
  ENDMETHOD.


    METHOD read_posts.
     TYPES: BEGIN OF ty_component_data,
             material         TYPE c LENGTH 40,    " Component Number (Key)
             BOMLocation      TYPE c LENGTH 4,     " BOM Location (Key)
             productionorder  TYPE c LENGTH 12,  " Production Order (Mandatory Filter)
             bukrs            TYPE c LENGTH 4,    " Company Code (Mandatory Filter, Value Help)
             plant            TYPE c LENGTH 4,     " Plant (Mandatory Filter, Value Help)
             maktx            TYPE c LENGTH 50,    " Component Description
             stock            TYPE p DECIMALS 3 LENGTH 16,  " Quantity at BOM Location (Hidden Filter)
             plantstock       TYPE p DECIMALS 3 LENGTH 16,  " Plant Stock (Hidden Filter)
             requiredquantity TYPE p DECIMALS 3 LENGTH 16,  " Required Quantity (Hidden Filter)
             short_excess_qty TYPE p DECIMALS 3 LENGTH 16,  " Short/Excess Quantity (Hidden Filter)
           END OF ty_component_data.

    DATA: lt_response    TYPE TABLE OF zcds_shortage_calc, " WITH KEY material bomlocation,
          ls_line        LIKE LINE OF lt_response,
          lt_responseout LIKE lt_response,
          ls_responseout LIKE LINE OF lt_responseout.


    TYPES: BEGIN OF ty_plantstock,
             material        TYPE c LENGTH 40,
             plant           TYPE c LENGTH 4,
             StorageLocation TYPE c LENGTH 4,
             plantstock      TYPE p LENGTH 16 DECIMALS 3,
           END OF ty_plantstock.
    DATA it_plantproduct TYPE TABLE OF ty_plantstock.
    DATA it_lgort_product TYPE TABLE OF ty_plantstock.
    DATA wa_plantproduct TYPE ty_plantstock.

    DATA : lt_productionorder TYPE RANGE OF I_ProductionOrderTP-ProductionOrder,
       lt_companycode    TYPE RANGE OF I_CompanyCode-CompanyCode,
       lt_plant          TYPE RANGE OF I_Plant-Plant.

    " Process Production Orders
    SPLIT production AT ',' INTO TABLE DATA(lt_pro_strings).
    LOOP AT lt_pro_strings ASSIGNING FIELD-SYMBOL(<lv_pro>).
      CONDENSE <lv_pro> NO-GAPS.
      IF <lv_pro> IS NOT INITIAL.
        APPEND VALUE #(
          sign   = 'I'
          option = 'EQ'
          low    = <lv_pro>
        ) TO lt_productionorder.
      ENDIF.
    ENDLOOP.

    " Process Company Codes
    SPLIT comp_code AT ',' INTO TABLE DATA(lt_bukrs_strings).
    LOOP AT lt_bukrs_strings ASSIGNING FIELD-SYMBOL(<lv_bukrs>).
      CONDENSE <lv_bukrs> NO-GAPS.
      IF <lv_bukrs> IS NOT INITIAL.
        APPEND VALUE #(
          sign   = 'I'
          option = 'EQ'
          low    = <lv_bukrs>
        ) TO lt_companycode.
      ENDIF.
    ENDLOOP.

    " Process Plants
    SPLIT plant AT ',' INTO TABLE DATA(lt_plant_strings).
    LOOP AT lt_plant_strings ASSIGNING FIELD-SYMBOL(<lv_plant>).
      CONDENSE <lv_plant> NO-GAPS.
      IF <lv_plant> IS NOT INITIAL.
        APPEND VALUE #(
          sign   = 'I'
          option = 'EQ'
          low    = <lv_plant>
        ) TO lt_plant.
      ENDIF.
    ENDLOOP.

        " Alpha Conversion for Production Orders
    IF lt_productionorder IS NOT INITIAL.
      LOOP AT lt_productionorder INTO DATA(wa_PRD_ORDER).
        DATA : var1 TYPE I_ProductionOrderTP-ProductionOrder.
        IF wa_PRD_ORDER-low IS NOT INITIAL.
          var1 = wa_PRD_ORDER-low.
          wa_PRD_ORDER-low = |{ var1 ALPHA = IN }|.
        ENDIF.
        IF wa_PRD_ORDER-high IS NOT INITIAL.
          CLEAR var1.
          var1 = wa_PRD_ORDER-high.
          wa_PRD_ORDER-high = |{ var1 ALPHA = IN }|.
        ENDIF.
        MODIFY lt_productionorder FROM wa_PRD_ORDER.
      ENDLOOP.
    ENDIF.

    " Alpha Conversion for Company Codes
    IF lt_companycode IS NOT INITIAL.
      LOOP AT lt_companycode INTO DATA(wa_COMP_CODE).
        DATA: var2 TYPE I_CompanyCode-CompanyCode.
        IF wa_COMP_CODE-low IS NOT INITIAL.
          var2 = wa_COMP_CODE-low.
          wa_COMP_CODE-low = |{ var2 ALPHA = IN }|.
        ENDIF.
        IF wa_COMP_CODE-high IS NOT INITIAL.
          CLEAR var2.
          var2 = wa_COMP_CODE-high.
          wa_COMP_CODE-high = |{ var2 ALPHA = IN }|.
        ENDIF.
        MODIFY lt_companycode FROM wa_COMP_CODE.
      ENDLOOP.
    ENDIF.

    " Alpha Conversion for Plants
    IF lt_plant IS NOT INITIAL.
      LOOP AT lt_plant INTO DATA(wa_PLANT).
        DATA : var3 TYPE c length 4.
        IF wa_PLANT-low IS NOT INITIAL.
          var3 = wa_PLANT-low.
          wa_PLANT-low = |{ var3 ALPHA = IN }|.
        ENDIF.
        IF wa_PLANT-high IS NOT INITIAL.
          CLEAR var3.
          var3 = wa_PLANT-high.
          wa_PLANT-high = |{ var3 ALPHA = IN }|.
        ENDIF.
        MODIFY lt_plant FROM wa_PLANT.
      ENDLOOP.
    ENDIF.

    select single from ztable_plant as a
    left join I_CompanyCode as b on a~comp_code = b~CompanyCode
    fields a~comp_code,a~plant_code,a~plant_name1,b~CompanyCodeName
    where a~comp_code in @lt_companycode and a~plant_code in @lt_plant
    into @data(header).

DATA: lv_time_utc    TYPE cl_abap_context_info=>ty_system_time,
      lv_hours       TYPE i,
      lv_minutes     TYPE i,
      lv_seconds     TYPE i,
      lv_seconds_utc TYPE i,
      lv_seconds_ist TYPE i,
      lv_date_utc    TYPE cl_abap_context_info=>ty_system_date,
      lv_date_ist    TYPE cl_abap_context_info=>ty_system_date,
      lv_time_ist    TYPE string,
      lv_hours_str   TYPE string,
      lv_minutes_str TYPE string,
      lv_seconds_str TYPE string.

  DATA : lv_date TYPE cl_abap_context_info=>ty_system_date,
           lv_time TYPE cl_abap_context_info=>ty_system_time.

  lv_date_utc = cl_abap_context_info=>get_system_date( ).
  lv_time = cl_abap_context_info=>get_system_time( ).

    lv_hours = lv_time(2).
    lv_minutes = lv_time+2(2).
    lv_seconds = lv_time+4(2).

    lv_seconds_utc = lv_hours * 3600 + lv_minutes * 60 + lv_seconds.

    lv_seconds_ist = lv_seconds_utc + 19800.

    IF lv_seconds_ist >= 86400.
      lv_seconds_ist = lv_seconds_ist - 86400.
      lv_date_ist = lv_date_utc + 1.
    ELSE.
      lv_date_ist = lv_date_utc.
    ENDIF.

    lv_hours = lv_seconds_ist DIV 3600.
    lv_minutes = ( lv_seconds_ist MOD 3600 ) DIV 60.
    lv_seconds = lv_seconds_ist MOD 60.

    lv_hours_str = |{ lv_hours WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.
    lv_minutes_str = |{ lv_minutes WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.
    lv_seconds_str = |{ lv_seconds WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.

    lv_time_ist = |T{ lv_hours_str }:{ lv_minutes_str }:{ lv_seconds_str }|.

    data : conc type string.
    conc = |{ lv_date_ist  }{ lv_time_ist }|.


    SELECT FROM i_productionordertp AS a
    LEFT JOIN I_ProductText AS b ON a~Product = b~Product
    FIELDS a~ProductionOrder,a~product,a~OrderPlannedTotalQty,a~CreationDate,b~ProductName
    WHERE a~ProductionOrder IN @lt_productionorder
    INTO TABLE @DATA(it_line).

    SELECT FROM I_ProductionOrderOpComponentTP  AS a
    LEFT JOIN I_ProductDescription_2 AS b ON b~Product = a~Material AND b~Language = 'E'
    LEFT JOIN I_BillOfMaterialItemBasic AS c ON c~BillOfMaterial = a~BillOfMaterialInternalID
    AND c~BillOfMaterialCategory = a~BillOfMaterialCategory AND c~BillOfMaterialItemNodeNumber = a~BillOfMaterialItemNodeNumber
    AND c~BOMItemInternalChangeCount = a~BOMItemInternalChangeCount
    LEFT JOIN ZI_PlantTable AS d ON d~PlantCode = a~Plant
*    LEFT JOIN I_StockQuantityCurrentValue_2( p_displaycurrency = 'INR' ) AS e
*    ON e~Product = a~Material AND e~Plant = a~Plant AND e~StorageLocation = a~StorageLocation
*    AND e~ValuationAreaType = '1' AND e~InventoryStockType = '01'
    FIELDS a~Reservation, a~ReservationItem, a~ReservationRecordType,  a~Material, a~plant,
     a~ProductionOrder, a~storagelocation, a~BillOfMaterialCategory, a~BillOfMaterialItemNodeNumber,
     a~BOMItemInternalChangeCount, a~RequiredQuantity,
     b~ProductDescription,
     c~ProdOrderIssueLocation " e~MatlWrhsStkQtyInMatlBaseUnit AS lgortstock
    WHERE a~ProductionOrder IN @lt_productionorder AND d~CompCode IN @lt_companycode
    AND a~Plant in @lt_plant
    INTO TABLE @DATA(it) PRIVILEGED ACCESS.

    SELECT FROM I_StockQuantityCurrentValue_2( p_displaycurrency = 'INR' )
    FIELDS Product , Plant , StorageLocation, MatlWrhsStkQtyInMatlBaseUnit AS plantstock
    WHERE Plant in @lt_plant AND ValuationAreaType = '1' AND InventoryStockType = '01'
    INTO TABLE @DATA(it_plant_stock) PRIVILEGED ACCESS.

    LOOP AT it_plant_stock ASSIGNING FIELD-SYMBOL(<wa_plantstock2>).
      wa_plantproduct-material        = <wa_plantstock2>-Product.
      wa_plantproduct-plant           = <wa_plantstock2>-Plant.
      wa_plantproduct-storagelocation = <wa_plantstock2>-StorageLocation.
      wa_plantproduct-plantstock      = <wa_plantstock2>-plantstock.
      COLLECT wa_plantproduct INTO it_lgort_product.

      CLEAR wa_plantproduct.
      wa_plantproduct-material   = <wa_plantstock2>-Product.
      wa_plantproduct-plant      = <wa_plantstock2>-Plant.
      wa_plantproduct-plantstock = <wa_plantstock2>-plantstock.
      COLLECT wa_plantproduct INTO it_plantproduct.
      CLEAR wa_plantproduct.
    ENDLOOP.

    SORT it BY Material ProdOrderIssueLocation.
    LOOP AT it ASSIGNING FIELD-SYMBOL(<wa>).
      CLEAR ls_line.

      ls_line-material              = <wa>-Material.
      ls_line-plant                 = <wa>-Plant.
      ls_line-maktx                 = <wa>-ProductDescription.
      ls_line-BOMLocation           = <wa>-ProdOrderIssueLocation.
      ls_line-requiredquantity      = <wa>-RequiredQuantity.
*      ls_line-productionorder       = <wa>-ProductionOrder.

      COLLECT ls_line INTO lt_response.
    ENDLOOP.

    LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<ls_resp>).

      READ TABLE it_lgort_product ASSIGNING FIELD-SYMBOL(<wa_lgort_product>)
                 WITH KEY material = <ls_resp>-Material
                          plant    = <ls_resp>-Plant
                          storagelocation = <ls_resp>-BOMLocation.
      IF sy-subrc = 0.
        <ls_resp>-stock = <wa_lgort_product>-plantstock.
      ENDIF.

      READ TABLE it_plantproduct ASSIGNING FIELD-SYMBOL(<wa_plantstock>)
           WITH KEY material = <ls_resp>-Material
                    plant    = <ls_resp>-Plant.
      IF sy-subrc = 0.
        <ls_resp>-plantstock = <wa_plantstock>-plantstock.
      ENDIF.

      <ls_resp>-short_excess_qty = <ls_resp>-stock - <ls_resp>-requiredquantity.

      <ls_resp>-material = | { <ls_resp>-material ALPHA = OUT } |.

    ENDLOOP.
    SORT lt_response BY productionorder material plant BOMLocation.

    DATA(lv_xml) = |<Form>| &&
                      |<comp_code>{ header-comp_code }</comp_code>| &&
                      |<plant_code>{ header-plant_code }</plant_code>| &&
                      |<comp_desc>{ header-CompanyCodeName }</comp_desc>| &&
                      |<plant_desc>{ header-plant_name1 }</plant_desc>| &&
                      |<date_time>{ conc }</date_time>| &&
                      |<table>|.
    Loop at it_line into data(wa_lines).
       shift wa_lines-ProductionOrder left DELETING LEADING '0'.
       MODIFY it_line from wa_lines.
       clear : wa_lines.
    ENDLOOP.

    LOOP AT it_line INTO DATA(wa_line).
      DATA(lv_xml2) = |<Item>| &&
                      |<pro_no>{ wa_line-ProductionOrder }</pro_no>| &&
                      |<fg_code>{ wa_line-Product }</fg_code>| &&
                      |<fg_desc>{ wa_line-ProductName }</fg_desc>| &&
                      |<qty>{ wa_line-OrderPlannedTotalQty }</qty>| &&
                      |<creation_date>{ wa_line-CreationDate }</creation_date>| &&
                      |</Item>|.
      CONCATENATE lv_xml lv_xml2 INTO lv_xml.
      CLEAR :  wa_line.
    ENDLOOP.

    CONCATENATE lv_xml '</table>' '<table2>' INTO lv_xml.

    LOOP AT lt_response INTO DATA(wa_res).
      DATA(lv_xml3) = |<item2>| &&
                      |<comp_no>{ wa_res-material }</comp_no>| &&
                      |<comp_desc>{ wa_res-maktx }</comp_desc>| &&
                      |<qty_comp></qty_comp>| &&
                      |<uom></uom>| &&
                      |<bom_loc>{ wa_res-bomlocation }</bom_loc>| &&
                      |<plant_stock>{ wa_res-plantstock }</plant_stock>| &&
                      |<qty_req>{ wa_res-requiredquantity }</qty_req>| &&
                      |<stock_bom>{ wa_res-stock }</stock_bom>| &&
                      |<diff>{ wa_res-short_excess_qty }</diff>| &&
                      |</item2>|.
      CONCATENATE lv_xml lv_xml3 INTO lv_xml.
      CLEAR :  wa_res.
    ENDLOOP.
    CONCATENATE lv_xml '</table2>' '</Form>' INTO lv_xml.
     REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.

      CALL METHOD zcl_ads_master=>getpdf(
        EXPORTING
          xmldata  = lv_xml
          template = lc_template_name
        RECEIVING
          result   = result12 ).
    ENDMETHOD.
ENDCLASS.
