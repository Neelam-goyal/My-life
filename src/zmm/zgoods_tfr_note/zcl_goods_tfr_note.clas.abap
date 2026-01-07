CLASS zcl_goods_tfr_note DEFINITION
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
                  lv_gateentry    TYPE string
                  lv_companycode     TYPE string
*                  lv_fiscalyear   type string
                  lv_plant type string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZGOODS_TFR_NOTE/ZGOODS_TFR_NOTE'."'zpo/zpo_v2'."

ENDCLASS.



CLASS ZCL_GOODS_TFR_NOTE IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD .


  METHOD read_posts .
    SELECT SINGLE FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS a
    LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS AS b ON a~Plant = b~plant_code
    LEFT JOIN  I_MATERIALDOCUMENTHEADER_2 as c on a~MaterialDocument = c~MaterialDocument AND a~MaterialDocumentYear = c~MaterialDocumentYear
    FIELDS
    a~Plant,
    a~MaterialDocument,
    a~CompanyCode,
    a~GoodsMovementType,
    a~MaterialDocumentYear,
    b~plant_name1, """""""""""for add
    b~address1,
    b~address2,
    b~address3,
    c~PostingDate,
    c~CreationTime

    WHERE a~MaterialDocument = @lv_gateentry  AND a~CompanyCode = @lv_companycode
    AND a~Plant = @lv_plant

    INTO @DATA(header).
      data :str1 type string.
      CONCATENATE header-address1 header-address2 header-address3 INTO str1 SEPARATED BY space.
      DATA : lv_date TYPE vdm_validitystart.
   lv_date = cl_abap_context_info=>get_system_date( ).
  DATA: lv_time TYPE string.

 lv_time = cl_abap_context_info=>get_system_time( ).
  data :lv_formatted_time type string.

   DATA: lv_utc_time   TYPE t,
            lv_utc_string TYPE string,
            lv_ist_time   TYPE t,
            lv_hours      TYPE i,
            lv_minutes    TYPE i,
            lv_seconds    TYPE i.

      lv_utc_time = lv_time.

* Extract hours, minutes, seconds
      lv_hours   = lv_utc_time+0(2).
      lv_minutes = lv_utc_time+2(2).
      lv_seconds = lv_utc_time+4(2).

* Convert to IST (Add 5 hours 30 minutes)
      lv_hours = lv_hours + 5.
      lv_minutes = lv_minutes + 30.

      IF lv_minutes >= 60.
        lv_minutes = lv_minutes - 60.
        lv_hours = lv_hours + 1.
      ENDIF.

      IF lv_hours >= 24.
        lv_hours = lv_hours - 24.
      ENDIF.

      DATA: str_min TYPE string.
      str_min = lv_minutes.
      CONDENSE str_min NO-GAPS.

      IF strlen( str_min ) = 1.
        str_min = '0' && str_min.
      ENDIF.

      DATA: str_sec TYPE string.
      str_sec = lv_seconds.
      CONDENSE str_sec NO-GAPS.

      IF strlen( str_sec ) = 1.
        str_sec = '0' && str_sec.
      ENDIF.

      lv_formatted_time = lv_hours && ':' && str_min && ':' && str_sec.









    DATA(lv_xml) =
    |<Form>| &&
    |<Header>| &&
    |<CompanyName>{ header-plant_name1 }</CompanyName>| &&
    |<Address>{ str1 }</Address>| &&
    |<Plant>{ header-Plant }</Plant>| &&
    |<Movement_Type>{ header-GoodsMovementType }</Movement_Type>| &&
    |<Movement_No></Movement_No>| &&
    |<Material_Document_Number>{ header-MaterialDocument }</Material_Document_Number>| &&
    |<Material_Document_Year>{ header-MaterialDocumentYear }</Material_Document_Year>| &&
    |<Material_date>{ header-PostingDate }</Material_date>| &&
    |<Material_Time>{ header-CreationTime }</Material_Time>| &&
    |<Company_Code>{ header-CompanyCode }</Company_Code>| &&
    |<Print_date>{ lv_date }</Print_date> | &&
    |<Print_Time>{ lv_formatted_time }</Print_Time>| &&
    |</Header>| &&
    |<Line_Item>|.

    SELECT FROM  I_MATERIALDOCUMENTITEM_2 WITH PRIVILEGED ACCESS as a
    LEFT JOIN i_producttext WITH PRIVILEGED ACCESS as b on a~Material = b~Product
    FIELDS
    a~Material,
    a~QuantityInBaseUnit,
    a~MaterialBaseUnit,
     a~StorageLocation,
    a~IssuingOrReceivingStorageLoc,
    a~CompanyCode,
    a~MaterialDocumentYear,
    b~ProductName,
    a~Batch

    WHERE a~MaterialDocument =  @lv_gateentry AND a~CompanyCode = @lv_companycode AND
    a~Plant = @lv_plant AND a~IsAutomaticallyCreated is INITIAL
    INTO TABLE @DATA(it_item).
    sort it_item by companycode.
    LOOP AT it_item INTO DATA(wa_it_item).
    SHIFT wa_it_item-Material LEFT DELETING LEADING '0'.
    data(lv_item_xml) =
    |<item>| &&
    |<Material>{ wa_it_item-Material }</Material>| &&
    |<Product_description>{ wa_it_item-ProductName }</Product_description>| &&
    |<GM_Qrt>{ wa_it_item-QuantityInBaseUnit }</GM_Qrt>| &&
    |<GM_UOm>{ wa_it_item-MaterialBaseUnit }</GM_UOm>| &&
    |<To_loc>{ wa_it_item-IssuingOrReceivingStorageLoc }</To_loc>| &&
    |<From_loc>{ wa_it_item-StorageLocation }</From_loc>| &&
    |<batch>{ wa_it_item-Batch }</batch>| &&
    |</item>|.
      CONCATENATE lv_xml lv_item_xml INTO lv_xml.
      ENDLOOP.
       CONCATENATE lv_xml '</Line_Item>' '</Form>' INTO lv_xml.

      CALL METHOD zcl_ads_master=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
