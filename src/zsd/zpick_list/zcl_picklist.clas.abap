CLASS zcl_picklist DEFINITION
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
                  Delivery        TYPE string
*               lc_template_name  TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zpick_list/zpick_list'.
ENDCLASS.



CLASS ZCL_PICKLIST IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


    METHOD read_posts.



      DATA: lt_deliveries TYPE RANGE OF i_deliverydocument-deliverydocument.
      SPLIT Delivery AT ',' INTO TABLE DATA(lt_delivery_strings).

      LOOP AT lt_delivery_strings ASSIGNING FIELD-SYMBOL(<lv_delivery>).
      CONDENSE <lv_delivery> NO-GAPS.

        IF <lv_delivery> IS NOT INITIAL.
          <lv_delivery> = |00{ <lv_delivery> }|.
          APPEND VALUE #(
            sign   = 'I'
            option = 'EQ'
            low    = <lv_delivery>
          ) TO lt_deliveries.
        ELSE.
          DELETE lt_deliveries INDEX sy-tabix.
        ENDIF.
      ENDLOOP.


      SELECT a~ReferenceSDDocument ,a~deliverydocument
       FROM i_deliverydocumentitem AS a
        WHERE a~DeliveryDocument IN @lt_deliveries
       INTO TABLE @DATA(lt_orders).

      SELECT b~ShipToParty,c~customername
        FROM i_deliverydocument AS b
        LEFT JOIN  i_customer AS c ON b~ShipToParty = c~Customer
         WHERE b~DeliveryDocument IN @lt_deliveries
        INTO TABLE @DATA(lt_parties).


      SORT lt_parties BY ShipToParty.
      SORT lt_orders BY ReferenceSDDocument.
      DELETE ADJACENT DUPLICATES FROM lt_orders COMPARING ALL FIELDS.
      DELETE ADJACENT DUPLICATES FROM lt_parties COMPARING ALL FIELDS.

      DATA(order_cnt) = lines( lt_orders ).
      DATA(party_cnt) = lines( lt_parties ).

      SELECT FROM i_deliverydocumentitem AS a
     LEFT JOIN i_deliverydocument AS b ON a~DeliveryDocument = b~DeliveryDocument
     LEFT JOIN i_customer AS c ON b~ShipToParty = c~Customer
     LEFT JOIN i_productdescription AS d ON a~Product = d~Product
     FIELDS
       a~ReferenceSDDocument AS ReferenceSDDocument,
       a~Product AS Product,
       a~Batch AS Batch,
       SUM( a~ActualDeliveryQuantity ) AS ActualDeliveryQuantity,
       a~DeliveryDocument AS DeliveryDocument,
       d~ProductDescription AS ProductDescription
     WHERE a~DeliveryDocument IN @lt_deliveries
     GROUP BY
       a~ReferenceSDDocument,
       a~Product,
       a~Batch,
       a~DeliveryDocument,
       d~ProductDescription
     INTO TABLE @DATA(item).



      DELETE item WHERE ActualDeliveryQuantity = 0.
      SORT item BY deliverydocument Product .

      SELECT FROM  i_deliverydocumentitem AS a
      LEFT JOIN i_deliverydocument AS b ON a~DeliveryDocument = b~DeliveryDocument
      LEFT JOIN i_customer AS c ON b~ShipToParty = c~Customer
      FIELDS a~ReferenceSDDocument,
      a~Product,
      a~Batch,
      a~ActualDeliveryQuantity,
      a~DeliveryDocument
      ,c~CustomerName
      ,b~ShipToParty
      WHERE a~DeliveryDocument IN @lt_deliveries
      INTO TABLE @DATA(party).

      SELECT SINGLE FROM i_deliverydocumentitem  AS a
      LEFT JOIN ztable_plant AS b ON a~Plant = b~plant_code
      LEFT JOIN I_CompanyCode AS c ON b~comp_code = c~CompanyCode
      FIELDS b~comp_code,c~CompanyCodeName
      WHERE a~DeliveryDocument IN @lt_deliveries
      INTO @DATA(comp).

      DATA(lv_xml) = |<Form>| &&
      |<Header>| &&
      |<NumberOfOrders>{ order_cnt  }</NumberOfOrders>| &&
      |<comp_code>{ comp-comp_code }</comp_code>| &&
      |<comp_name>{ comp-CompanyCodeName }</comp_name>| &&
      |<NoofParty>{ party_cnt }</NoofParty>| &&
      |</Header>| &&
      |<Body>| &&
      |<Orders>|.
      DATA  : cnt TYPE i VALUE 0.
      LOOP AT lt_deliveries INTO DATA(wa_del).
        READ TABLE party INTO DATA(wa_party)  WITH KEY DeliveryDocument = wa_del-low .
        DATA(lv_xml2) = |<Order>| &&
        |<PartnerName>{ wa_party-CustomerName }</PartnerName>| &&
        |<DeliveryNo>{ wa_party-DeliveryDocument ALPHA = OUT }</DeliveryNo>| &&
        |<Sales></Sales>| &&
        |<Items>|.
        CONCATENATE lv_xml lv_xml2 INTO lv_xml.


        DATA: lt_processed_products TYPE TABLE OF string.

        DATA prev_product TYPE string VALUE ''.



        LOOP AT item INTO DATA(wa_item) WHERE DeliveryDocument = wa_del-low.
          READ TABLE lt_orders INTO DATA(wa_orders) WITH KEY ReferenceSDDocument = wa_item-ReferenceSDDocument.
          DATA grandtotl TYPE i VALUE 0.
         data lv_sno type i value 0.
          grandtotl = grandtotl + wa_item-ActualDeliveryQuantity.

          IF line_exists( lt_processed_products[ table_line = wa_item-Product ] ).
            wa_item-ProductDescription = ''.
            wa_item-Product = ''.
           lv_sno = ''.
          ELSE.
            APPEND wa_item-Product TO lt_processed_products.
            cnt = cnt + 1.
             lv_sno = cnt.
          ENDIF.

          DATA(lv_xml3) = |<Item>| &&
           |<Sno>{ lv_sno }</Sno>| &&
           |<ProductCode>{ wa_item-Product }</ProductCode>| &&
           |<ProductDescription>{ wa_item-ProductDescription }</ProductDescription>| &&
           |<InvoiceQty>{ wa_item-ActualDeliveryQuantity }</InvoiceQty>| &&
           |<OrderNo>{ wa_orders-ReferenceSDDocument ALPHA = OUT }</OrderNo>| &&
           |<Batch>{ wa_item-Batch }</Batch>| &&
           |</Item>|.
          CONCATENATE lv_xml lv_xml3 INTO lv_xml.
          CLEAR : wa_item.
        ENDLOOP.

        DATA(lv_close) =
              |</Items>| &&
              |</Order>| .
        CONCATENATE lv_xml lv_close INTO lv_xml.
        CLEAR : wa_party,wa_del,lt_processed_products.
        cnt = 0.
      ENDLOOP.

      DATA(lv_end) = |</Orders>| &&
                     |<GrandTotal>{ grandtotl }</GrandTotal>| &&
                     |</Body>| &&
                     |</Form>|.
      CONCATENATE lv_xml lv_end INTO lv_xml.
      REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.

      CALL METHOD zcl_ads_master=>getpdf(
        EXPORTING
          xmldata  = lv_xml
          template = lc_template_name
        RECEIVING
          result   = result12 ).
    ENDMETHOD.
ENDCLASS.
