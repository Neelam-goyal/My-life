*CLASS zcl_gate_entry_print DEFINITION
*  PUBLIC
*  FINAL
*  CREATE PUBLIC .
*
*  PUBLIC SECTION.
*    CLASS-DATA : access_token TYPE string .
*    CLASS-DATA : xml_file TYPE string .
*    TYPES :
*      BEGIN OF struct,
*        xdp_template TYPE string,
*        xml_data     TYPE string,
*        form_type    TYPE string,
*        form_locale  TYPE string,
*        tagged_pdf   TYPE string,
*        embed_font   TYPE string,
*      END OF struct.
*    CLASS-METHODS :
*      create_client
*        IMPORTING url           TYPE string
*        RETURNING VALUE(result) TYPE REF TO if_web_http_client
*        RAISING   cx_static_check ,
*
*      read_posts
*        IMPORTING cleardoc        TYPE string
*        RETURNING VALUE(result12) TYPE string
*        RAISING   cx_static_check .
*
**      getformatteddate
**        IMPORTING lv_date                  TYPE string
**        RETURNING VALUE(lv_formatted_date) TYPE string ,
**      getformattedtime
**        IMPORTING lv_time                  TYPE string
**        RETURNING VALUE(lv_formatted_time) TYPE string ,
**      converttoutc
**        IMPORTING lv_time            TYPE string
**        RETURNING VALUE(lv_time_ist) TYPE i.
*
*
*  PROTECTED SECTION.
*
*  PRIVATE SECTION.
*    CONSTANTS lc_template_name TYPE string VALUE 'ZGATE_ENTRY_PRINT/ZGATE_ENTRY_PRINT'.
*ENDCLASS.
*
*CLASS zcl_gate_entry_print IMPLEMENTATION.
*
*  METHOD read_posts.
*
*    SELECT SINGLE
*      a~driver_name,
*      a~gate_pass,
*      a~entry_date,
*      a~vehicle_number,
*      a~route_name,
*      a~out_meter_reading,
*      a~out_date,
*      a~out_time,
*      a~salesman_name,
*      a~created_at,
*      a~cmcrate_1,
*      a~cmcrate_2,
*      a~cmcrate_3,
*      a~cmcrate_4,
*      a~vrn_no,
*      a~remarks,
*      b~plant_name1,
*      b~address1,
*      a~veh_out_remarks
*      FROM zgatepassheader AS a
*      LEFT JOIN Ztable_plant AS b ON a~plant = b~plant_code
*      WHERE a~gate_pass = @cleardoc
*      INTO @DATA(header).
*
*    " Fetch current UTC timestamp
*    DATA: lv_timestamp    TYPE timestampl,
*          lv_ist_date     TYPE d,
*          lv_ist_time     TYPE t.
*
*    GET TIME STAMP FIELD lv_timestamp.
*
*    " Convert UTC timestamp to IST
*    CONVERT TIME STAMP lv_timestamp TIME ZONE 'IST' INTO DATE lv_ist_date TIME lv_ist_time.
*
*    " Assign IST date and time to header fields
*    header-out_date = lv_ist_date.
*    header-out_time = lv_ist_time.
*
*    SELECT
*      a~document_no,
*      a~document_date,
*      a~vrn_no,
*      a~amount,
*      a~quantity,
*      b~SoldToParty,
*      c~CustomerName
*      FROM zgatepassline AS a
*      LEFT JOIN I_BillingDocument AS b ON a~document_no = b~BillingDocument
*      LEFT JOIN I_Customer AS c ON b~SoldToParty = c~Customer
*      WHERE a~gate_pass = @cleardoc
*      INTO TABLE @DATA(item).
*
*    CONDENSE header-veh_out_remarks.
*
*    DATA(lv_xml) =
*    |<Form>| &&
*    |<Header>| &&
*    |<Creat1>{ COND #( WHEN header-cmcrate_1 IS INITIAL THEN '' ELSE header-cmcrate_1 ) }</Creat1>| &&
*    |<Creat2>{ COND #( WHEN header-cmcrate_2 IS INITIAL THEN '' ELSE header-cmcrate_2 ) }</Creat2>| &&
*    |<Creat3>{ COND #( WHEN header-cmcrate_3 IS INITIAL THEN '' ELSE header-cmcrate_3 ) }</Creat3>| &&
*    |<Creat4>{ COND #( WHEN header-cmcrate_4 IS INITIAL THEN '' ELSE header-cmcrate_4 ) }</Creat4>| &&
*    |<Plant_Name>{ header-plant_name1 }</Plant_Name>| &&
*    |<Plant_Add>{ header-address1 }</Plant_Add>| &&
*    |<Scm_Remarks>{ header-remarks }</Scm_Remarks>| &&
*    |<Print_Date_Time>{ lv_ist_time }</Print_Date_Time>| &&
*    |<Print_Date>{ lv_ist_date }</Print_Date>| &&
*    |<Vrn_No>{ header-vrn_no }</Vrn_No>| &&
*    |<Driver>{ header-driver_name }</Driver>| &&
*    |<Sr_No_Gate_Pass>{ header-gate_pass }</Sr_No_Gate_Pass>| &&
*    |<Sr_No_Gate_Date>{ getformatteddate( CONV string( header-entry_date ) ) }</Sr_No_Gate_Date>| &&
*   |<Sr_No_Gate_Date>{ getformatteddate( CONV string( header-entry_date ) ) }</Sr_No_Gate_Date>| &&
*    |<Market_Place>{ header-salesman_name }</Market_Place>| &&
*    |<Vehicle_Number>{ header-vehicle_number }</Vehicle_Number>| &&
*    |<Route>{ header-route_name }</Route>| &&
*    |<Meter_Reading>{ COND #( WHEN header-out_meter_reading IS INITIAL THEN '' ELSE header-out_meter_reading ) }</Meter_Reading>| &&
*    |<Out_Time>{ header-out_time }</Out_Time>| &&
*    |<Out_Date>{ header-out_date }</Out_Date>| &&
*    |</Header>| &&
*    |<Lineitem>|.
*
*    LOOP AT item INTO DATA(wa_item).
*      DATA(lv_xml_item) =
*      |<Item>| &&
*      |<Inv_No>{ wa_item-document_no }</Inv_No>| &&
*      |<Inv_Date>{ wa_item-document_date }</Inv_Date>| &&
*      |<Vrn_No>{ wa_item-vrn_no }</Vrn_No>| &&
*      |<Amount>{ wa_item-amount }</Amount>| &&
*      |<Qty>{ wa_item-quantity }</Qty>| &&
*      |<Party_Name>{ wa_item-CustomerName }</Party_Name>| &&
*      |</Item>|.
*      CONCATENATE lv_xml lv_xml_item INTO lv_xml.
*    ENDLOOP.
*
*    CONCATENATE lv_xml '</Lineitem>' '</Form>' INTO lv_xml.
*
*    CALL METHOD zcl_ads_master=>getpdf(
*      EXPORTING
*        xmldata  = lv_xml
*        template = lc_template_name
*      RECEIVING
*        result   = result12 ).
*
*  ENDMETHOD.
*
*ENDCLASS.
*
*




*************************************************************************************************
CLASS zcl_gate_entry_print DEFINITION
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
      END OF struct.
    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING cleardoc        TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check ,

      getformatteddate
        IMPORTING lv_date                  TYPE string
        RETURNING VALUE(lv_formatted_date) TYPE string ,
      getformattedtime
        IMPORTING lv_time                  TYPE string
        RETURNING VALUE(lv_formatted_time) TYPE string ,
      converttoutc
        IMPORTING lv_time            TYPE string
        RETURNING VALUE(lv_time_ist) TYPE i,
      convert_utc_to_ist
        IMPORTING
          iv_utc_time          TYPE t
        RETURNING
          VALUE(rv_ist_string) TYPE string.


  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_template_name TYPE string VALUE 'ZGATE_ENTRY_PRINT/ZGATE_ENTRY_PRINT'.
ENDCLASS.



CLASS ZCL_GATE_ENTRY_PRINT IMPLEMENTATION.


  METHOD converttoutc.
    DATA lv_time_utc TYPE i.
    lv_time_utc = lv_time.

    lv_time_ist = lv_time_utc + 53000.

    IF lv_time_ist >= '240000'.
      lv_time_ist = lv_time_ist - '240000'.
    ENDIF.
  ENDMETHOD.


  METHOD convert_utc_to_ist.
    DATA: lv_utc_time   TYPE t,
          lv_utc_string TYPE string,
          lv_ist_time   TYPE t,
          lv_hours      TYPE i,
          lv_minutes    TYPE i,
          lv_seconds    TYPE i.

    lv_utc_time = iv_utc_time.

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

    rv_ist_string = lv_hours && ':' && str_min && ':' && str_sec.
  ENDMETHOD.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD getformatteddate.
    lv_formatted_date = |{ lv_date+6(2) }/{ lv_date+4(2) }/{ lv_date(4) }|.
  ENDMETHOD.


  METHOD getformattedtime.
    lv_formatted_time = |{ lv_time+0(2) }:{ lv_time+2(2) }:{ lv_time+4(2) }|.
  ENDMETHOD.


  METHOD read_posts .

    SELECT SINGLE
    a~driver_name,
    a~gate_pass,
    a~entry_date,
    a~vehicle_number,
    a~route_name,
    a~out_meter_reading,
    a~out_date,
    a~out_time,
    a~salesman_name,
    a~created_at,    """"""""""""""""header level
    a~cmcrate_1,
    a~cmcrate_2,
    a~cmcrate_3,
    a~cmcrate_4,
    a~vrn_no,
    a~remarks,
    b~plant_name1,
    b~address1,
    a~veh_out_remarks
    FROM zgatepassheader  AS a
    LEFT JOIN Ztable_plant   AS b ON a~plant = b~plant_code
   WHERE a~gate_pass = @cleardoc
   INTO @DATA(Header).


    DATA lv_timestamp TYPE string.
    lv_timestamp = header-created_at.

    DATA: lv_date TYPE d,
          lv_time TYPE t.

    lv_date = cl_abap_context_info=>get_system_date( ).
    lv_time = cl_abap_context_info=>get_system_time( ).

    SELECT
     a~document_no,
     a~document_date ,
     a~document_reference,
     a~vrn_no,
     a~amount,
     a~quantity,
     b~SoldToParty,
     c~CustomerName
     FROM zgatepassline  AS a
     LEFT JOIN I_BillingDocument  AS b ON a~document_no = b~BillingDocument
     LEFT JOIN  I_Customer AS c ON b~SoldToParty = c~Customer
    WHERE a~gate_pass = @cleardoc
    INTO TABLE @DATA(item).

    CONDENSE header-veh_out_remarks.

    DATA: lv_header_createdat_temp type string.
    DATA: lv_header_createdat type t.
    lv_header_createdat_temp = header-created_at.
    lv_header_createdat_temp = lv_header_createdat_temp+8(6).
    lv_header_createdat = lv_header_createdat_temp.


    IF header-out_date eq 00000000 .
    header-out_time = 000000 .
    ENDIF.

    DATA(lv_xml) =
    |<Form>| &&
    |<Header>| &&
    |<Creat1>{  header-cmcrate_1 }</Creat1>| &&
    |<Creat2>{ header-cmcrate_2 }</Creat2>| &&
    |<Creat3>{ header-cmcrate_3 }</Creat3>| &&
    |<Creat4>{ header-cmcrate_4  }</Creat4>| &&
    |<Plant_Name>{ header-plant_name1 }</Plant_Name>| &&
    |<Plant_Add>{ header-address1 }</Plant_Add>| &&
    |<Scm_Remarks>{ header-remarks }</Scm_Remarks>| &&
***************************************************************************
    |<Security_Remarks>{ header-veh_out_remarks }</Security_Remarks>| &&
***************************************************************************
    |<Print_Date_Time>{ zcl_gate_entry_print=>convert_utc_to_ist( iv_utc_time = lv_time ) }</Print_Date_Time>| &&
*    |<Print_Date_Time>{ lv_time }</Print_Date_Time>| &&
    |<Print_Date>{ lv_date }</Print_Date>| &&
    |<Vrn_No>{ header-vrn_no }</Vrn_No>| &&
    |<Driver>{ header-driver_name }</Driver>| &&
    |<Sr_No_Gate_Pass>{ header-gate_pass }</Sr_No_Gate_Pass>| &&
    |<Sr_No_Gate_Date>{ getformatteddate( CONV string( header-entry_date ) ) }</Sr_No_Gate_Date>| &&
    |<Sr_No_Gate_Time>{ zcl_gate_entry_print=>convert_utc_to_ist( iv_utc_time = lv_header_createdat ) }</Sr_No_Gate_Time>| &&
*    |<Sr_No_Gate_Time>{ lv_header_createdat }</Sr_No_Gate_Time>| &&
    |<Market_Place>{ header-salesman_name }</Market_Place>| &&
    |<Vehicle_Number>{ header-vehicle_number }</Vehicle_Number>| &&
    |<Route>{ header-route_name }</Route>| &&
    |<Meter_Reading>{ header-out_meter_reading }</Meter_Reading>| &&
*    |<Out_Time>{ zcl_gate_entry_print=>convert_utc_to_ist( iv_utc_time = header-out_time )  }</Out_Time>| &&
    |<Out_Time>{ header-out_time }</Out_Time>| &&
    |<Out_Date>{ getformatteddate( CONV string( header-out_date ) ) }</Out_Date>| &&
    |</Header>| &&
    |<Lineitem>|.


    LOOP AT item INTO DATA(wa_item).

      DATA(lv_xml_item) =
       |<Item>| &&
       |<Inv_No>{ COND #( WHEN wa_item-document_reference IS NOT INITIAL THEN wa_item-document_reference ELSE wa_item-document_no )  }</Inv_No>| &&
       |<Inv_Date>{ wa_item-document_date }</Inv_Date>| &&
       |<Vrn_No>{ wa_item-vrn_no }</Vrn_No>| &&
       |<Amount>{ wa_item-amount }</Amount>| &&
       |<Qty>{ wa_item-quantity }</Qty>| &&
       |<Party_Name>{ wa_item-CustomerName }</Party_Name>| &&
       |</Item>|.
      CONCATENATE lv_xml lv_xml_item INTO lv_xml.
    ENDLOOP.

    CONCATENATE lv_xml '</Lineitem>' '</Form>' INTO lv_xml.


    CALL METHOD zcl_ads_master=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
