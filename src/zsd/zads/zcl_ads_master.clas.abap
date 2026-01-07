CLASS zcl_ads_master DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
************************************************************
    CLASS-METHODS get_xml_node_value
      IMPORTING
        xmldata       TYPE string
        node_name     TYPE string
      RETURNING
        VALUE(result) TYPE string.
************************************************************
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct.
    CLASS-DATA: lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf',
                lv1_url       TYPE string.

    CLASS-METHODS create_client
      IMPORTING url           TYPE string
      RETURNING VALUE(result) TYPE REF TO if_web_http_client
      RAISING   cx_static_check.

    CLASS-METHODS generate_token
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS getpdf
      IMPORTING template      TYPE string
                xmldata       TYPE string
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS getxdp
      IMPORTING form          TYPE string OPTIONAL
                template      TYPE string OPTIONAL
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS Get_Pdf_From_Saved_template
      IMPORTING xmldata_1     TYPE string OPTIONAL
                template_1    TYPE string OPTIONAL
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS Format_xml
      IMPORTING xmldata           TYPE string OPTIONAL
      RETURNING VALUE(result_xml) TYPE string .

ENDCLASS.



CLASS ZCL_ADS_MASTER IMPLEMENTATION.


  METHOD create_client.
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD.


  METHOD format_xml.

    DATA lv_xmldata TYPE string.
    lv_xmldata = xmldata.


    REPLACE ALL OCCURRENCES OF '\t' IN lv_xmldata WITH '&#9;'.
    REPLACE ALL OCCURRENCES OF '\n' IN lv_xmldata WITH '&#10;'.
    REPLACE ALL OCCURRENCES OF '\r' IN lv_xmldata WITH '&#13;'.
    REPLACE ALL OCCURRENCES OF '!' IN lv_xmldata WITH '&#33;'.
    REPLACE ALL OCCURRENCES OF '"' IN lv_xmldata WITH '&#34;'.
    REPLACE ALL OCCURRENCES OF '#' IN lv_xmldata WITH '&#35;'.
    REPLACE ALL OCCURRENCES OF '$' IN lv_xmldata WITH '&#36;'.
    REPLACE ALL OCCURRENCES OF '%' IN lv_xmldata WITH '&#37;'.
    REPLACE ALL OCCURRENCES OF '&' IN lv_xmldata WITH '&#38;'.
    REPLACE ALL OCCURRENCES OF |'| IN lv_xmldata WITH '&#39;'.
    REPLACE ALL OCCURRENCES OF '(' IN lv_xmldata WITH '&#40;'.
    REPLACE ALL OCCURRENCES OF ')' IN lv_xmldata WITH '&#41;'.
    REPLACE ALL OCCURRENCES OF '*' IN lv_xmldata WITH '&#42;'.
    REPLACE ALL OCCURRENCES OF '+' IN lv_xmldata WITH '&#43;'.
    REPLACE ALL OCCURRENCES OF ',' IN lv_xmldata WITH '&#44;'.
    REPLACE ALL OCCURRENCES OF '-' IN lv_xmldata WITH '&#45;'.
    REPLACE ALL OCCURRENCES OF '.' IN lv_xmldata WITH '&#46;'.
    REPLACE ALL OCCURRENCES OF '/' IN lv_xmldata WITH '&#47;'.
    REPLACE ALL OCCURRENCES OF ':' IN lv_xmldata WITH '&#58;'.
    REPLACE ALL OCCURRENCES OF ';' IN lv_xmldata WITH '&#59;'.
    REPLACE ALL OCCURRENCES OF '<' IN lv_xmldata WITH '&#60;'.
    REPLACE ALL OCCURRENCES OF '=' IN lv_xmldata WITH '&#61;'.
    REPLACE ALL OCCURRENCES OF '>' IN lv_xmldata WITH '&#62;'.
    REPLACE ALL OCCURRENCES OF '?' IN lv_xmldata WITH '&#63;'.
    REPLACE ALL OCCURRENCES OF '@' IN lv_xmldata WITH '&#64;'.
    REPLACE ALL OCCURRENCES OF '[' IN lv_xmldata WITH '&#91;'.
    REPLACE ALL OCCURRENCES OF '\' IN lv_xmldata WITH '&#92;'.
    REPLACE ALL OCCURRENCES OF ']' IN lv_xmldata WITH '&#93;'.
    REPLACE ALL OCCURRENCES OF '^' IN lv_xmldata WITH '&#94;'.
    REPLACE ALL OCCURRENCES OF '_' IN lv_xmldata WITH '&#95;'.
    REPLACE ALL OCCURRENCES OF '`' IN lv_xmldata WITH '&#96;'.
    REPLACE ALL OCCURRENCES OF '{' IN lv_xmldata WITH '&#123;'.
    REPLACE ALL OCCURRENCES OF '|' IN lv_xmldata WITH '&#124;'.
    REPLACE ALL OCCURRENCES OF '}' IN lv_xmldata WITH '&#125;'.
    REPLACE ALL OCCURRENCES OF '~' IN lv_xmldata WITH '&#126;'.
    REPLACE ALL OCCURRENCES OF '€' IN lv_xmldata WITH '&#128;'.
    REPLACE ALL OCCURRENCES OF '‚' IN lv_xmldata WITH '&#130;'.
    REPLACE ALL OCCURRENCES OF 'ƒ' IN lv_xmldata WITH '&#131;'.
    REPLACE ALL OCCURRENCES OF '„' IN lv_xmldata WITH '&#132;'.
    REPLACE ALL OCCURRENCES OF '…' IN lv_xmldata WITH '&#133;'.
    REPLACE ALL OCCURRENCES OF '†' IN lv_xmldata WITH '&#134;'.
    REPLACE ALL OCCURRENCES OF '‡' IN lv_xmldata WITH '&#135;'.
    REPLACE ALL OCCURRENCES OF 'ˆ' IN lv_xmldata WITH '&#136;'.
    REPLACE ALL OCCURRENCES OF '‰' IN lv_xmldata WITH '&#137;'.
    REPLACE ALL OCCURRENCES OF 'Š' IN lv_xmldata WITH '&#138;'.
    REPLACE ALL OCCURRENCES OF '‹' IN lv_xmldata WITH '&#139;'.
    REPLACE ALL OCCURRENCES OF 'Œ' IN lv_xmldata WITH '&#140;'.
    REPLACE ALL OCCURRENCES OF 'Ž' IN lv_xmldata WITH '&#142;'.
    REPLACE ALL OCCURRENCES OF '‘' IN lv_xmldata WITH '&#145;'.
    REPLACE ALL OCCURRENCES OF '’' IN lv_xmldata WITH '&#146;'.
    REPLACE ALL OCCURRENCES OF '“' IN lv_xmldata WITH '&#147;'.
    REPLACE ALL OCCURRENCES OF '”' IN lv_xmldata WITH '&#148;'.
    REPLACE ALL OCCURRENCES OF '•' IN lv_xmldata WITH '&#149;'.
    REPLACE ALL OCCURRENCES OF '–' IN lv_xmldata WITH '&#150;'.
    REPLACE ALL OCCURRENCES OF '—' IN lv_xmldata WITH '&#151;'.
    REPLACE ALL OCCURRENCES OF '˜' IN lv_xmldata WITH '&#152;'.
    REPLACE ALL OCCURRENCES OF '™' IN lv_xmldata WITH '&#153;'.
    REPLACE ALL OCCURRENCES OF 'š' IN lv_xmldata WITH '&#154;'.
    REPLACE ALL OCCURRENCES OF '›' IN lv_xmldata WITH '&#155;'.
    REPLACE ALL OCCURRENCES OF 'œ' IN lv_xmldata WITH '&#156;'.
    REPLACE ALL OCCURRENCES OF 'ž' IN lv_xmldata WITH '&#158;'.
    REPLACE ALL OCCURRENCES OF 'Ÿ' IN lv_xmldata WITH '&#159;'.
    REPLACE ALL OCCURRENCES OF '¡' IN lv_xmldata WITH '&#161;'.
    REPLACE ALL OCCURRENCES OF '¢' IN lv_xmldata WITH '&#162;'.
    REPLACE ALL OCCURRENCES OF '£' IN lv_xmldata WITH '&#163;'.
    REPLACE ALL OCCURRENCES OF '¤' IN lv_xmldata WITH '&#164;'.
    REPLACE ALL OCCURRENCES OF '¥' IN lv_xmldata WITH '&#165;'.
    REPLACE ALL OCCURRENCES OF '¦' IN lv_xmldata WITH '&#166;'.
    REPLACE ALL OCCURRENCES OF '§' IN lv_xmldata WITH '&#167;'.
    REPLACE ALL OCCURRENCES OF '¨' IN lv_xmldata WITH '&#168;'.
    REPLACE ALL OCCURRENCES OF '©' IN lv_xmldata WITH '&#169;'.
    REPLACE ALL OCCURRENCES OF 'ª' IN lv_xmldata WITH '&#170;'.
    REPLACE ALL OCCURRENCES OF '«' IN lv_xmldata WITH '&#171;'.
    REPLACE ALL OCCURRENCES OF '¬' IN lv_xmldata WITH '&#172;'.
    REPLACE ALL OCCURRENCES OF '®' IN lv_xmldata WITH '&#174;'.
    REPLACE ALL OCCURRENCES OF '¯' IN lv_xmldata WITH '&#175;'.
    REPLACE ALL OCCURRENCES OF '°' IN lv_xmldata WITH '&#176;'.
    REPLACE ALL OCCURRENCES OF '±' IN lv_xmldata WITH '&#177;'.
    REPLACE ALL OCCURRENCES OF '²' IN lv_xmldata WITH '&#178;'.
    REPLACE ALL OCCURRENCES OF '³' IN lv_xmldata WITH '&#179;'.
    REPLACE ALL OCCURRENCES OF '´' IN lv_xmldata WITH '&#180;'.
    REPLACE ALL OCCURRENCES OF 'µ' IN lv_xmldata WITH '&#181;'.
    REPLACE ALL OCCURRENCES OF '¶' IN lv_xmldata WITH '&#182;'.
    REPLACE ALL OCCURRENCES OF '·' IN lv_xmldata WITH '&#183;'.
    REPLACE ALL OCCURRENCES OF '¸' IN lv_xmldata WITH '&#184;'.
    REPLACE ALL OCCURRENCES OF '¹' IN lv_xmldata WITH '&#185;'.
    REPLACE ALL OCCURRENCES OF 'º' IN lv_xmldata WITH '&#186;'.
    REPLACE ALL OCCURRENCES OF '»' IN lv_xmldata WITH '&#187;'.
    REPLACE ALL OCCURRENCES OF '¼' IN lv_xmldata WITH '&#188;'.
    REPLACE ALL OCCURRENCES OF '½' IN lv_xmldata WITH '&#189;'.
    REPLACE ALL OCCURRENCES OF '¾' IN lv_xmldata WITH '&#190;'.
    REPLACE ALL OCCURRENCES OF '¿' IN lv_xmldata WITH '&#191;'.
    REPLACE ALL OCCURRENCES OF 'À' IN lv_xmldata WITH '&#192;'.
    REPLACE ALL OCCURRENCES OF 'Á' IN lv_xmldata WITH '&#193;'.
    REPLACE ALL OCCURRENCES OF 'Â' IN lv_xmldata WITH '&#194;'.
    REPLACE ALL OCCURRENCES OF 'Ã' IN lv_xmldata WITH '&#195;'.
    REPLACE ALL OCCURRENCES OF 'Ä' IN lv_xmldata WITH '&#196;'.
    REPLACE ALL OCCURRENCES OF 'Å' IN lv_xmldata WITH '&#197;'.
    REPLACE ALL OCCURRENCES OF 'Æ' IN lv_xmldata WITH '&#198;'.
    REPLACE ALL OCCURRENCES OF 'Ç' IN lv_xmldata WITH '&#199;'.
    REPLACE ALL OCCURRENCES OF 'È' IN lv_xmldata WITH '&#200;'.
    REPLACE ALL OCCURRENCES OF 'É' IN lv_xmldata WITH '&#201;'.
    REPLACE ALL OCCURRENCES OF 'Ê' IN lv_xmldata WITH '&#202;'.
    REPLACE ALL OCCURRENCES OF 'Ë' IN lv_xmldata WITH '&#203;'.
    REPLACE ALL OCCURRENCES OF 'Ì' IN lv_xmldata WITH '&#204;'.
    REPLACE ALL OCCURRENCES OF 'Í' IN lv_xmldata WITH '&#205;'.
    REPLACE ALL OCCURRENCES OF 'Î' IN lv_xmldata WITH '&#206;'.
    REPLACE ALL OCCURRENCES OF 'Ï' IN lv_xmldata WITH '&#207;'.
    REPLACE ALL OCCURRENCES OF 'Ð' IN lv_xmldata WITH '&#208;'.
    REPLACE ALL OCCURRENCES OF 'Ñ' IN lv_xmldata WITH '&#209;'.
    REPLACE ALL OCCURRENCES OF 'Ò' IN lv_xmldata WITH '&#210;'.
    REPLACE ALL OCCURRENCES OF 'Ó' IN lv_xmldata WITH '&#211;'.
    REPLACE ALL OCCURRENCES OF 'Ô' IN lv_xmldata WITH '&#212;'.
    REPLACE ALL OCCURRENCES OF 'Õ' IN lv_xmldata WITH '&#213;'.
    REPLACE ALL OCCURRENCES OF 'Ö' IN lv_xmldata WITH '&#214;'.
    REPLACE ALL OCCURRENCES OF '×' IN lv_xmldata WITH '&#215;'.
    REPLACE ALL OCCURRENCES OF 'Ø' IN lv_xmldata WITH '&#216;'.
    REPLACE ALL OCCURRENCES OF 'Ù' IN lv_xmldata WITH '&#217;'.
    REPLACE ALL OCCURRENCES OF 'Ú' IN lv_xmldata WITH '&#218;'.
    REPLACE ALL OCCURRENCES OF 'Û' IN lv_xmldata WITH '&#219;'.
    REPLACE ALL OCCURRENCES OF 'Ü' IN lv_xmldata WITH '&#220;'.
    REPLACE ALL OCCURRENCES OF 'Ý' IN lv_xmldata WITH '&#221;'.
    REPLACE ALL OCCURRENCES OF 'Þ' IN lv_xmldata WITH '&#222;'.
    REPLACE ALL OCCURRENCES OF 'ß' IN lv_xmldata WITH '&#223;'.
    REPLACE ALL OCCURRENCES OF 'à' IN lv_xmldata WITH '&#224;'.
    REPLACE ALL OCCURRENCES OF 'á' IN lv_xmldata WITH '&#225;'.
    REPLACE ALL OCCURRENCES OF 'â' IN lv_xmldata WITH '&#226;'.
    REPLACE ALL OCCURRENCES OF 'ã' IN lv_xmldata WITH '&#227;'.
    REPLACE ALL OCCURRENCES OF 'ä' IN lv_xmldata WITH '&#228;'.
    REPLACE ALL OCCURRENCES OF 'å' IN lv_xmldata WITH '&#229;'.
    REPLACE ALL OCCURRENCES OF 'æ' IN lv_xmldata WITH '&#230;'.
    REPLACE ALL OCCURRENCES OF 'ç' IN lv_xmldata WITH '&#231;'.
    REPLACE ALL OCCURRENCES OF 'è' IN lv_xmldata WITH '&#232;'.
    REPLACE ALL OCCURRENCES OF 'é' IN lv_xmldata WITH '&#233;'.
    REPLACE ALL OCCURRENCES OF 'ê' IN lv_xmldata WITH '&#234;'.
    REPLACE ALL OCCURRENCES OF 'ë' IN lv_xmldata WITH '&#235;'.
    REPLACE ALL OCCURRENCES OF 'ì' IN lv_xmldata WITH '&#236;'.
    REPLACE ALL OCCURRENCES OF 'í' IN lv_xmldata WITH '&#237;'.
    REPLACE ALL OCCURRENCES OF 'î' IN lv_xmldata WITH '&#238;'.
    REPLACE ALL OCCURRENCES OF 'ï' IN lv_xmldata WITH '&#239;'.
    REPLACE ALL OCCURRENCES OF 'ð' IN lv_xmldata WITH '&#240;'.
    REPLACE ALL OCCURRENCES OF 'ñ' IN lv_xmldata WITH '&#241;'.
    REPLACE ALL OCCURRENCES OF 'ò' IN lv_xmldata WITH '&#242;'.
    REPLACE ALL OCCURRENCES OF 'ó' IN lv_xmldata WITH '&#243;'.
    REPLACE ALL OCCURRENCES OF 'ô' IN lv_xmldata WITH '&#244;'.
    REPLACE ALL OCCURRENCES OF 'õ' IN lv_xmldata WITH '&#245;'.
    REPLACE ALL OCCURRENCES OF 'ö' IN lv_xmldata WITH '&#246;'.
    REPLACE ALL OCCURRENCES OF '÷' IN lv_xmldata WITH '&#247;'.
    REPLACE ALL OCCURRENCES OF 'ø' IN lv_xmldata WITH '&#248;'.
    REPLACE ALL OCCURRENCES OF 'ù' IN lv_xmldata WITH '&#249;'.
    REPLACE ALL OCCURRENCES OF 'ú' IN lv_xmldata WITH '&#250;'.
    REPLACE ALL OCCURRENCES OF 'û' IN lv_xmldata WITH '&#251;'.
    REPLACE ALL OCCURRENCES OF 'ü' IN lv_xmldata WITH '&#252;'.
    REPLACE ALL OCCURRENCES OF '✓' IN lv_xmldata WITH 'a'.
    REPLACE ALL OCCURRENCES OF 'ý' IN lv_xmldata WITH '&#253;'.
    REPLACE ALL OCCURRENCES OF '&#40;' IN lv_xmldata WITH ''.
    REPLACE ALL OCCURRENCES OF '&#41;' IN lv_xmldata WITH ''.
    REPLACE ALL OCCURRENCES OF '&#58;' IN lv_xmldata WITH ''.
    REPLACE ALL OCCURRENCES OF '&#91;' IN lv_xmldata WITH ''.
    REPLACE ALL OCCURRENCES OF '&#93;' IN lv_xmldata WITH ''.
*    REPLACE ALL OCCURRENCES OF '&' IN lv_xmldata WITH 'and'.
    REPLACE ALL OCCURRENCES OF ' </' IN lv_xmldata WITH '</'.
    REPLACE ALL OCCURRENCES OF '༯' IN lv_xmldata WITH '/'.
    REPLACE ALL OCCURRENCES OF '\u00A0' IN lv_xmldata WITH space.
    REPLACE ALL OCCURRENCES OF PCRE '[\x00-\x08\x0B\x0C\x0E-\x1F]' IN lv_xmldata WITH ''.
    REPLACE ALL OCCURRENCES OF PCRE '\xA0' IN lv_xmldata WITH ' '.




    result_xml = xmldata .
  ENDMETHOD.


  METHOD generate_token.

    DATA url             TYPE string.
    DATA client_id       TYPE string.
    DATA client_password TYPE string.

    url = 'https://bon-dev.authentication.jp10.hana.ondemand.com'.
    client_id = 'sb-752080ff-e40b-48d2-976e-81111144b3a7!b19130|ads-xsappname!b3446'.
    client_password = '994d514c-b639-4c9b-b281-be7ad92957e5$qI6tb_WmqPrP1vRCsTJz3YQvUoVh7-MhEPxZX0guiHU='.
    TRY.
        DATA(client) = create_client( |{ url }/oauth/token| ).
      CATCH cx_static_check INTO DATA(lv_cx_static_check).
        result = lv_cx_static_check->get_longtext( ).
        "handle exception
    ENDTRY.
    DATA(req) = client->get_http_request(  ).

    req->set_authorization_basic(
    i_username = client_id
    i_password = client_password )  .
    req->set_content_type( 'application/x-www-form-urlencoded'  ).
    req->set_form_field( EXPORTING i_name  = 'grant_type'
                                   i_value = 'client_credentials' ) .
    TRY.
        DATA(response) = client->execute( if_web_http_client=>post )->get_text(  ).
      CATCH cx_web_http_client_error INTO DATA(lv_cx_web_http_client_error). "cx_web_message_error.
        result = lv_cx_web_http_client_error->get_longtext( ).
        "handle exception
    ENDTRY.
    REPLACE ALL OCCURRENCES OF '{"access_token":"' IN response WITH ''.
    SPLIT response AT '","token_type' INTO DATA(v1) DATA(v2) .
    result = v1 .
    TRY.
        client->close(  ).
      CATCH cx_web_http_client_error INTO DATA(lv_cx_web_http_client_error2).
        result = lv_cx_web_http_client_error2->get_longtext( ).
        "handle exception
    ENDTRY.

  ENDMETHOD.


  METHOD getpdf.

    lv1_url = 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1'.
    DATA(lv_xmldata2) = Format_xml( xmldata = xmldata ).
***********************************************************************************************************************************************
    DATA(lv_name) = get_xml_node_value(
        xmldata = lv_xmldata2
        node_name = 'correct'
        ).

    DATA(lv_CorrectInvoice) = get_xml_node_value(
         xmldata = lv_xmldata2
         node_name = 'InvoiceValue'
         ).

    IF lv_name = 'NotValidateToPrint'.
      result = 'Kindly Generate IRN Before Printing'.
      RETURN.
    ENDIF.
*    IF lv_CorrectInvoice = 'Value_Not_Matched'.
*      result = 'SYSTEM VALUE AND PRINT VALUE MISMATCH. KINDLY CHECK THE INVOICES.'.
*      RETURN.
*    ENDIF.
***********************************************************************************************************************************************
    result  = get_pdf_from_saved_template( template_1 = template
                                           xmldata_1  = lv_xmldata2 ).
    IF result IS INITIAL .

      access_token = generate_token( ).
      DATA url TYPE string.
*      DATA(gv) = |{ lv1_url }/adsRender/pdf?templateSource=storageName&TraceLevel=2|.
      DATA(gv) = |https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2|.
      DATA(ls_data_xml) = cl_web_http_utility=>encode_base64( lv_xmldata2 ).
      url = |{ gv }|.
      TRY.
          DATA(client) = create_client( url ).
        CATCH cx_static_check INTO DATA(lv_cx_static_check2).
          result = lv_cx_static_check2->get_longtext( ).
          "handle exception
      ENDTRY.
      DATA(req) = client->get_http_request(  ).
      req->set_authorization_bearer( access_token ) .

      DATA(ls_body) = VALUE struct( xdp_template = template
                                       xml_data = ls_data_xml
                                        form_type = 'print'
*                                     form_type = 'interactive'
                                       form_locale = 'en_US'
                                       tagged_pdf = '0'
                                       embed_font = '0' ).
      DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_body compress = abap_true pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
      req->append_text(
                EXPORTING
                  data   = lv_json
              ).
*       result = lv_json.
*       return.
      req->set_content_type( 'application/json' ).
      DATA: url_response TYPE string.
      TRY.
          url_response = client->execute( if_web_http_client=>post )->get_text( ).
        CATCH cx_web_http_client_error cx_web_message_error INTO DATA(lv_err).
          result = lv_err->get_longtext( ).
      ENDTRY.
      result = url_response .


      FIELD-SYMBOLS:
        <data>                TYPE data,
        <field>               TYPE any,
        <pdf_based64_encoded> TYPE any.
      DATA : lr_d TYPE string .
      DATA(lr_d1) = /ui2/cl_json=>generate( json = url_response ).
      IF lr_d1 IS BOUND.
        ASSIGN lr_d1->* TO <data>.
        ASSIGN COMPONENT `fileContent` OF STRUCTURE <data> TO <field>.
        IF sy-subrc EQ 0.
          ASSIGN <field>->* TO <pdf_based64_encoded>.
          result = <pdf_based64_encoded> .
        ELSE.
          result = 'ERROR'.
        ENDIF.
      ENDIF.
    ENDIF .
  ENDMETHOD.


  METHOD getxdp.
    DATA(url) = |{ lv1_url }/v1/forms/{ form }/templates/{ template }|.
    TRY.
        DATA(client) = create_client( url ).
      CATCH cx_static_check INTO DATA(lv_cx_static_check3).
        result = lv_cx_static_check3->get_longtext( ).

    ENDTRY.
    DATA(req) = client->get_http_request( ).
    req->set_authorization_bearer( generate_token( ) ).
    TRY.
        DATA(url_response) = client->execute( if_web_http_client=>get )->get_text( ).
      CATCH cx_web_http_client_error cx_web_message_error INTO DATA(lv_error2).
        result = lv_error2->get_longtext( ).

    ENDTRY.


    DATA result11 TYPE string.
    FIELD-SYMBOLS <data>                TYPE data.
    FIELD-SYMBOLS <field>               TYPE any.
    FIELD-SYMBOLS <pdf_based64_encoded> TYPE any.
    DATA(lr_d1) = /ui2/cl_json=>generate( json = url_response ).
    IF lr_d1 IS BOUND.
      ASSIGN lr_d1->* TO <data>.
      ASSIGN COMPONENT `xdpTemplate` OF STRUCTURE <data> TO <field>.
      IF sy-subrc = 0.
        ASSIGN <field>->* TO <pdf_based64_encoded>.
        result = <pdf_based64_encoded>.
      ELSE.
        result = 'ERROR'.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_pdf_from_saved_template.
  ENDMETHOD.


  METHOD get_xml_node_value.
    DATA: lv_xml       TYPE string,
          lv_tag_open  TYPE string,
          lv_tag_close TYPE string,
          lv_start     TYPE i,
          lv_end       TYPE i,
          lv_length    TYPE i.

    lv_xml = xmldata.
    lv_tag_open = |<{ node_name }>|.
    lv_tag_close = |</{ node_name }>|.
    FIND lv_tag_open IN lv_xml MATCH OFFSET lv_start.
    IF sy-subrc = 0.
      FIND lv_tag_close IN lv_xml MATCH OFFSET lv_end.
      IF sy-subrc = 0.
        lv_start = lv_start + strlen( lv_tag_open ).
        lv_length = lv_end - lv_start.
        result = lv_xml+lv_start(lv_length).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.
ENDCLASS.
