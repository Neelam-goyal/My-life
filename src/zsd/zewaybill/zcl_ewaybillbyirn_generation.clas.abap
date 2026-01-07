CLASS zcl_ewaybillbyirn_generation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_ship_details,
             address1   TYPE string,
             address2   TYPE string,
             location   TYPE string,
             pincode    TYPE string,
             state_code TYPE string,
           END OF ty_ship_details.
    TYPES: BEGIN OF ty_dispatch_details,
             company_name TYPE string,
             address1     TYPE string,
             address2     TYPE string,
             location     TYPE string,
             pincode      TYPE string,
             state_code   TYPE string,
           END OF ty_dispatch_details.
    TYPES: BEGIN OF ty_final,
             user_gstin                  TYPE string,
             irn                         TYPE string,
             transporter_id              TYPE string,
             transportation_mode         TYPE string,
             transporter_document_number TYPE string,
             transporter_document_date   TYPE string,
             vehicle_number              TYPE string,
             distance                    TYPE string,
             vehicle_type                TYPE string,
             transporter_name            TYPE string,
             data_source                 TYPE string,
             dispatch_details            TYPE ty_dispatch_details,
             ship_details                TYPE ty_ship_details,
           END OF ty_final.
    CLASS-DATA: wa_final TYPE ty_final.
    CLASS-METHODS :generated_ewaybillbyirn IMPORTING
                                                     companycode   TYPE ztable_irn-bukrs
                                                     document      TYPE ztable_irn-billingdocno
                                           RETURNING VALUE(result) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EWAYBILLBYIRN_GENERATION IMPLEMENTATION.


  METHOD generated_ewaybillbyirn.
    DATA: lv_comp TYPE ztable_irn-bukrs.
    lv_comp = companycode.
    DATA: lv_doc TYPE ztable_irn-billingdocno.
    lv_doc = document.

    SELECT SINGLE FROM i_billingdocument AS a
    INNER JOIN I_BillingDocumentItem AS b ON a~BillingDocument = b~BillingDocument
    FIELDS a~BillingDocument,
    a~BillingDocumentType,
    a~BillingDocumentDate,
    b~Plant
    WHERE a~BillingDocument = @document AND
    b~BillingDocumentType NOT IN ( 'S1','S2' )
    INTO @DATA(lv_document_details) PRIVILEGED ACCESS.


    SELECT SINGLE a~addressid,
                  b~addresssearchterm2 AS gstin,
                  b~careofname AS lglnm,
                  b~streetname AS addr1,
                  b~cityname AS addr2,
                  b~districtname AS city,
                  b~postalcode AS pin,
                  b~region AS stcd
    FROM i_plant AS a
    LEFT JOIN i_address_2 AS b ON ( a~addressid = b~addressid )
    WHERE plant = @lv_document_details-plant INTO @DATA(sellerplantaddress) PRIVILEGED ACCESS.

    SELECT SINGLE FROM
   i_companycode AS a
   FIELDS a~CompanyCodeName
   WHERE a~CompanyCode = @lv_comp
   INTO @DATA(lv_dispatch_details) PRIVILEGED ACCESS.

    wa_final-dispatch_details-company_name = 'dqfefkewl'. "lv_dispatch_details.
    wa_final-dispatch_details-address1    = 'Vila'. "sellerplantaddress-addr1.
    wa_final-dispatch_details-address2    =  'Vila'. "sellerplantaddress-addr2.
    wa_final-dispatch_details-location     = 'Noida'. "sellerplantaddress-city.
    wa_final-dispatch_details-location     =  'Noida'.   " HARDCODED
    wa_final-dispatch_details-pincode     = '201301'. "sellerplantaddress-stcd.
    wa_final-dispatch_details-state_code     =  '09'. "'09'.   " HARDCODED

    wa_final-user_gstin = '09AAAPG7885R002'.     "" hardcoded
    wa_final-ship_details-address1 = 'PILA 1'.
    wa_final-ship_details-address2 = 'PILA 1'.
    wa_final-ship_details-location = 'Nainital'.
    wa_final-ship_details-pincode = '248001'.
    wa_final-ship_details-state_code = 'UTTARAKHAND'.

    SELECT SINGLE FROM
    ztable_irn AS a
    FIELDS a~irnno,a~billingdocno,a~bukrs
    WHERE a~bukrs = @lv_comp AND a~billingdocno = @lv_doc
    INTO @DATA(wa_irn) PRIVILEGED ACCESS.

    wa_final-irn = wa_irn-irnno.
    wa_final-transporter_id = '05AAABB0639G1Z8'.     """ hardcoded
    wa_final-transportation_mode = '1'.
    wa_final-transporter_document_number = '12345'.   """ hardcoded
    wa_final-transporter_document_date = '14/09/2023'.
    wa_final-vehicle_number = 'KA01AB1234'.
    wa_final-distance = '256'.
    wa_final-vehicle_type = 'R'.
    wa_final-transporter_name = 'Jay Trans'.
    wa_final-data_source = 'erp'.

    DATA:json TYPE REF TO if_xco_cp_json_data.

    xco_cp_json=>data->from_abap(
      EXPORTING
        ia_abap      = wa_final
      RECEIVING
        ro_json_data = json   ).
    json->to_string(
      RECEIVING
        rv_string =   DATA(lv_string) ).


    REPLACE ALL OCCURRENCES OF '"USER_GSTIN"' IN lv_string WITH '"user_gstin"'.
    REPLACE ALL OCCURRENCES OF '"IRN"' IN lv_string WITH '"irn"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_ID"' IN lv_string WITH '"transporter_id"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTATION_MODE"' IN lv_string WITH '"transportation_mode"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_DOCUMENT_NUMBER"' IN lv_string WITH '"transporter_document_number"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_DOCUMENT_DATE"' IN lv_string WITH '"transporter_document_date"'.
    REPLACE ALL OCCURRENCES OF '"VEHICLE_NUMBER"' IN lv_string WITH '"vehicle_number"'.
    REPLACE ALL OCCURRENCES OF '"DISTANCE"' IN lv_string WITH '"distance"'.
    REPLACE ALL OCCURRENCES OF '"VEHICLE_TYPE"' IN lv_string WITH '"vehicle_type"'.
    REPLACE ALL OCCURRENCES OF '"TRANSPORTER_NAME"' IN lv_string WITH '"transporter_name"'.
    REPLACE ALL OCCURRENCES OF '"DATA_SOURCE"' IN lv_string WITH '"data_source"'.
    REPLACE ALL OCCURRENCES OF '"DISPATCH_DETAILS"' IN lv_string WITH '"dispatch_details"'.
    REPLACE ALL OCCURRENCES OF '"SHIP_DETAILS"' IN lv_string WITH '"ship_details"'.

    REPLACE ALL OCCURRENCES OF '"COMPANY_NAME"' IN lv_string WITH '"company_name"'.
    REPLACE ALL OCCURRENCES OF '"ADDRESS1"' IN lv_string WITH '"address1"'.
    REPLACE ALL OCCURRENCES OF '"ADDRESS2"' IN lv_string WITH '"address2"'.
    REPLACE ALL OCCURRENCES OF '"LOCATION"' IN lv_string WITH '"location"'.
    REPLACE ALL OCCURRENCES OF '"PINCODE"' IN lv_string WITH '"pincode"'.
    REPLACE ALL OCCURRENCES OF '"STATE_CODE"' IN lv_string WITH '"state_code"'.

    result = lv_string.

  ENDMETHOD.
ENDCLASS.
