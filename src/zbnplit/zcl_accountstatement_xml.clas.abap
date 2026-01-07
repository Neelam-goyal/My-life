CLASS zcl_accountstatement_xml DEFINITION
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
        IMPORTING
                  pCompanyCode     TYPE string
                  pCust_Supp       TYPE string
                  pGLAccount       TYPE string
                  pFromDate        TYPE string
                  pToDate          TYPE string
                  pBusinessPlace   TYPE string
                  pIsRevDoc        TYPE string
                  pIsExcSplGL      TYPE string
                  lc_template_name TYPE string
        RETURNING VALUE(result12)  TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.

ENDCLASS.



CLASS ZCL_ACCOUNTSTATEMENT_XML IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .
    DATA(todaydate) = cl_abap_context_info=>get_system_date( ).
    todaydate = todaydate+6(2) && '/' &&
                    todaydate+4(2) && '/' &&
                    todaydate(4).
    DATA(FromDateTodate) = |Period From { pFromDate } Period To { pToDate }|.

    DATA pcust_supp_code TYPE string.
    Data pGLAccount_code Type string.

    SELECT SINGLE
     a~address1,
     a~address2,
     a~city,
     a~STATE_Name,
     a~pin,
     a~country,
     a~GSTin_No,
     a~PAN_No,
     a~Cin_No,
     a~plant_name1
     FROM ztable_plant AS a
     WHERE a~comp_code = @pCompanyCode

     INTO  @DATA(Plant_address).

    IF Plant_address IS NOT INITIAL.
      DATA(lv_plant_address) = |{ Plant_address-address1 }, { Plant_address-address2 }, { Plant_address-city }, { Plant_address-state_name }-{ Plant_address-pin }|.
    ELSE.
      lv_plant_address = ' '.
    ENDIF.

    pcust_supp_code = pcust_supp.
    pGLAccount_code = pGLAccount.

    SHIFT pcust_supp_code LEFT DELETING LEADING '0'.

    " Check if input is purely numeric
    IF pcust_supp_code CO '0123456789'.
      " Pad with leading zeros to length 10
      pcust_supp_code = |{ pcust_supp_code ALIGN = RIGHT PAD = '0' WIDTH = 10  }|.
    ELSE.
      " Do nothing for alphanumeric input
      pcust_supp_code = pcust_supp_code.
    ENDIF.

    SHIFT pGLAccount_code LEFT DELETING LEADING '0'.

    " Check if input is purely numeric
    IF pGLAccount_code CO '0123456789'.
      " Pad with leading zeros to length 10
      pGLAccount_code = |{ pGLAccount_code ALIGN = RIGHT PAD = '0' WIDTH = 10  }|.
    ELSE.
      " Do nothing for alphanumeric input
      pGLAccount_code = pGLAccount_code.
    ENDIF.

    SELECT
        a~*

         FROM ZUI_AccountStatement( pcompanycode = @pcompanycode,
         pcust_supp = @pcust_supp_code,pGLAccount = @pGLAccount_code, pfromdate = @pfromdate,
         ptodate = @ptodate, pbusinessplace = @pbusinessplace, pisrevdoc = @pIsRevDoc, pisexcsplgl = @pIsExcSplGL
         ) AS a
         WHERE a~partycode = @pcust_supp_code
         ORDER BY a~srno DESCENDING
         INTO TABLE @DATA(ACStmtData).

    IF ACStmtData IS INITIAL.
        SELECT
        a~*

         FROM ZUI_EmpStatement( pcompanycode = @pcompanycode,
         pempcode = @pcust_supp_code,pGLAccount = @pGLAccount_code, pfromdate = @pfromdate,
         ptodate = @ptodate, pbusinessplace = @pbusinessplace, pisrevdoc = @pIsRevDoc, pisexcsplgl = @pIsExcSplGL
         ) AS a
         WHERE a~empcode = @pcust_supp_code
         ORDER BY a~srno DESCENDING
         INTO TABLE @DATA(EMPStmtData).
    Endif.
    IF ACStmtData IS NOT INITIAL.

      SELECT SINGLE a~* FROM @ACStmtData AS a WHERE a~AccountingDocumentType = 'OB'
        INTO @DATA(opbalrow) .

      SELECT SINGLE a~*
      FROM ZDIM_BusinessPartner AS a
      WHERE BusinessPartner = @pcust_supp_code
      INTO @DATA(bprow).

      DATA(lv_xml) =
       |<form1>| &&
       |<plantname>{ Plant_address-plant_name1 }</plantname>| &&
       |<address1>{ lv_plant_address }</address1>| &&
       |<CINNO>{ Plant_address-cin_no }</CINNO>| &&
       |<GSTIN>{ Plant_address-gstin_no }</GSTIN>| &&
       |<PAN>{ Plant_address-pan_no }</PAN>| &&
       |<REPORTDATE>{ todaydate }</REPORTDATE>| &&
       |<FromDateTodate>{ FromDateTodate }</FromDateTodate>| &&
       |<LeftSide>| &&
       |<partyno>{ bprow-BusinessPartnerFullName }</partyno>| &&
       |<ccode>({ bprow-BusinessPartner })</ccode>| &&
       |<companyCode>{ pCompanyCode }</companyCode>| &&
       |<partyno2></partyno2>| &&
       |<partyno3></partyno3>| &&
       |<partyadd></partyadd>| &&
       |<partynumbername></partynumbername>| &&
       |<partyadd1></partyadd1>| &&
       |<PHNNO></PHNNO>| &&
       |<EMAIL></EMAIL>| &&
       |<Subform7/>| &&
       |</LeftSide>| &&
       |<RightSide>| &&
       |<openingdate>{ opbalrow-postingdate }</openingdate>| &&
       |<openingBal>{ opbalrow-runningbalance }</openingBal>| &&
       |<OpeningBalance>{ opbalrow-runningbalance }</OpeningBalance>| &&

       |<ToDate>{ pToDate }</ToDate>| &&
       |<Page>| &&
       |<HaderData>| &&
       |<RightSide>| &&
       |<StationNo></StationNo>| &&
       |</RightSide>| &&
       |</HaderData>| &&
       |</Page>| &&
       |</RightSide>| .



      LOOP AT ACStmtData INTO DATA(wa_final).

        lv_xml = lv_xml &&
           |<LopTab>| &&
           |<Row1>| &&
*         |<invoicedate>{ invdt }</invoicedate>| &&
           |<docdate>{ wa_final-postingdate+6(2) }.{ wa_final-postingdate+4(2) }.{ wa_final-postingdate+0(4) }</docdate>| &&
           |<JournalEntry>{  wa_final-AccountingDocument WIDTH = 10 ALIGN = RIGHT PAD = '0' }</JournalEntry>| &&
           |<naration>{ wa_final-documentitemtext  }</naration>| &&
           |<debitamt>{ wa_final-debitamountincmpcdcrcy }</debitamt>| &&
           |<creditamt>{ wa_final-creditamountincmpcdcrcy }</creditamt>| &&
           |<Balance>{ wa_final-runningbalance } { wa_final-Sign }</Balance>| &&
           |</Row1>| &&
           |</LopTab>|.

      ENDLOOP.

      SELECT SINGLE a~* FROM @ACStmtData AS a
      WHERE a~srno = 1
      INTO @DATA(closing).


      lv_xml = lv_xml &&
         |<Subform3>| &&
         |<Table3>| &&
         |<Row1>| &&
         |<closingbl>{ closing-runningbalance }</closingbl>| &&
         |</Row1>| &&
         |</Table3>| &&
         |</Subform3>| &&
         |</form1>| .



            " 1. Clean Control Characters using PCRE (Modern Standard)
        REPLACE ALL OCCURRENCES OF PCRE '[\x00-\x08\x0B\x0C\x0E-\x1F]'
          IN lv_xml
          WITH ''.

        " 2. Fix Non-Breaking Spaces (Hex A0) using PCRE
        REPLACE ALL OCCURRENCES OF PCRE '\xA0'
          IN lv_xml
          WITH ' '.

      REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH '&amp;' .
      "Please don't delete this line
*    REPLACE ALL OCCURRENCES OF ` ` IN lv_xml WITH `_` .
      CONDENSE lv_xml.

*      result12 = lv_xml.

*      DATA(lv_xmldata2) = zcl_ads_master=>Format_xml( xmldata = lv_xml ).
*      DATA(ls_data_xml) = cl_web_http_utility=>encode_base64( lv_xmldata2 ).
*      lv_xml = cl_web_http_utility=>decode_x_base64( encoded = ls_data_xml ).
*

*      result12 = lv_xmldata2.
      CALL METHOD zcl_ads_master=>getpdf(
        EXPORTING
          xmldata  = lv_xml
          template = lc_template_name
        RECEIVING
          result   = result12 ).

    ELSEIF EMPStmtData IS NOT INITIAL.

      SELECT SINGLE a~* FROM @EMPStmtData AS a WHERE a~AccountingDocumentType = 'OB'
        INTO @DATA(emp_opbalrow) .

      SELECT SINGLE a~*
      FROM ZDIM_BusinessPartner AS a
      WHERE BusinessPartner = @pcust_supp_code
      INTO @DATA(emp_bprow).

      DATA(emp_lv_xml) =
       |<form1>| &&
       |<plantname>{ Plant_address-plant_name1 }</plantname>| &&
       |<address1>{ lv_plant_address }</address1>| &&
       |<CINNO>{ Plant_address-cin_no }</CINNO>| &&
       |<GSTIN>{ Plant_address-gstin_no }</GSTIN>| &&
       |<PAN>{ Plant_address-pan_no }</PAN>| &&
       |<REPORTDATE>{ todaydate }</REPORTDATE>| &&
       |<FromDateTodate>{ FromDateTodate }</FromDateTodate>| &&
       |<LeftSide>| &&
       |<partyno>{ emp_bprow-BusinessPartnerFullName }</partyno>| &&
       |<ccode>({ emp_bprow-BusinessPartner })</ccode>| &&
       |<companyCode>{ pCompanyCode }</companyCode>| &&
       |<partyno2></partyno2>| &&
       |<partyno3></partyno3>| &&
       |<partyadd></partyadd>| &&
       |<partynumbername></partynumbername>| &&
       |<partyadd1></partyadd1>| &&
       |<PHNNO></PHNNO>| &&
       |<EMAIL></EMAIL>| &&
       |<Subform7/>| &&
       |</LeftSide>| &&
       |<RightSide>| &&
       |<openingdate>{ emp_opbalrow-postingdate }</openingdate>| &&
       |<openingBal>{ emp_opbalrow-runningbalance }</openingBal>| &&
       |<OpeningBalance>{ emp_opbalrow-runningbalance }</OpeningBalance>| &&

       |<ToDate>{ pToDate }</ToDate>| &&
       |<Page>| &&
       |<HaderData>| &&
       |<RightSide>| &&
       |<StationNo></StationNo>| &&
       |</RightSide>| &&
       |</HaderData>| &&
       |</Page>| &&
       |</RightSide>| .



      LOOP AT EMPStmtData INTO DATA(emp_wa_final).

        emp_lv_xml = emp_lv_xml &&
           |<LopTab>| &&
           |<Row1>| &&
*         |<invoicedate>{ invdt }</invoicedate>| &&
           |<docdate>{ emp_wa_final-postingdate+6(2) }.{ emp_wa_final-postingdate+4(2) }.{ emp_wa_final-postingdate+0(4) }</docdate>| &&
           |<JournalEntry>{  emp_wa_final-AccountingDocument WIDTH = 10 ALIGN = RIGHT PAD = '0' }</JournalEntry>| &&
           |<naration>{ emp_wa_final-documentitemtext  }</naration>| &&
           |<debitamt>{ emp_wa_final-debitamountincmpcdcrcy }</debitamt>| &&
           |<creditamt>{ emp_wa_final-creditamountincmpcdcrcy }</creditamt>| &&
           |<Balance>{ emp_wa_final-runningbalance } { emp_wa_final-Sign }</Balance>| &&
           |</Row1>| &&
           |</LopTab>|.

      ENDLOOP.

      SELECT SINGLE a~* FROM @EMPStmtData AS a
      WHERE a~srno = 1
      INTO @DATA(EMP_closing).


      emp_lv_xml = emp_lv_xml &&
         |<Subform3>| &&
         |<Table3>| &&
         |<Row1>| &&
         |<closingbl>{ EMP_closing-runningbalance }</closingbl>| &&
         |</Row1>| &&
         |</Table3>| &&
         |</Subform3>| &&
         |</form1>| .



            " 1. Clean Control Characters using PCRE (Modern Standard)
        REPLACE ALL OCCURRENCES OF PCRE '[\x00-\x08\x0B\x0C\x0E-\x1F]'
          IN emp_lv_xml
          WITH ''.

        " 2. Fix Non-Breaking Spaces (Hex A0) using PCRE
        REPLACE ALL OCCURRENCES OF PCRE '\xA0'
          IN emp_lv_xml
          WITH ' '.

      REPLACE ALL OCCURRENCES OF '&' IN emp_lv_xml WITH '&amp;' .
      "Please don't delete this line
*    REPLACE ALL OCCURRENCES OF ` ` IN lv_xml WITH `_` .
      CONDENSE emp_lv_xml.

*      result12 = lv_xml.

*      DATA(lv_xmldata2) = zcl_ads_master=>Format_xml( xmldata = lv_xml ).
*      DATA(ls_data_xml) = cl_web_http_utility=>encode_base64( lv_xmldata2 ).
*      lv_xml = cl_web_http_utility=>decode_x_base64( encoded = ls_data_xml ).
*

*      result12 = lv_xmldata2.
      CALL METHOD zcl_ads_master=>getpdf(
        EXPORTING
          xmldata  = emp_lv_xml
          template = lc_template_name
        RECEIVING
          result   = result12 ).
    ELSE.
      result12   = 'No record found V1.' && pcust_supp_code && '---' && pcust_supp.
    ENDIF.


  ENDMETHOD .
ENDCLASS.
