CLASS zcl_test_new DEFINITION
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
                  customer type string
                  todate type string
                  fromdate type string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
   CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
*    CONSTANTS lc_template_name TYPE string VALUE 'zcashledger/zcashledger'.
ENDCLASS.



CLASS ZCL_TEST_NEW IMPLEMENTATION.


  METHOD create_client.
     DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

  ENDMETHOD.


  METHOD read_posts.


      DATA: lt_cust TYPE RANGE OF i_customer-Customer.
      SPLIT customer AT ',' INTO TABLE DATA(lt_cust_string).

      LOOP AT lt_cust_string ASSIGNING FIELD-SYMBOL(<lv_cust>).
         CONDENSE <lv_cust> NO-GAPS.
         data : cust type i_customer-Customer.
        IF <lv_cust> IS NOT INITIAL.
          cust = |{ <lv_cust> ALPHA = IN }|.
          APPEND VALUE #(
            sign   = 'I'
            option = 'EQ'
            low    = cust
          ) TO lt_cust.
        ENDIF.
      ENDLOOP.

      select from I_BillingDocument
      fields BillingDocument
      where SoldToParty in @lt_cust and
      BillingDocumentDate BETWEEN @fromdate and @todate
      into tABLE @data(it).

 SELECT FROM I_BillingDocumentItem AS item
  INNER JOIN @it AS head ON item~BillingDocument = head~BillingDocument
    fields sum( item~BillingQuantity ) as Qty,
    head~BillingDocument
    GROUP BY head~BillingDocument
  INTO TABLE @DATA(lt_sum) .




  ENDMETHOD.
ENDCLASS.
