CLASS zcl_tax_invoice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    CLASS-DATA : template TYPE string .
    CLASS-DATA : tot_sum  TYPE string.

    TYPES : BEGIN OF struct,
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
        RAISING   cx_static_check,

      read_posts
        IMPORTING co              TYPE string
                  fs              TYPE string
                  ac              TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.

*    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
*    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.eu10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
*    CONSTANTS  lv2_url    TYPE string VALUE 'https://btp-yvzjjpaz.authentication.eu10.hana.ondemand.com/oauth/token'  .
*    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.

    CONSTANTS  lc_template_name TYPE string VALUE 'zfitaxinvoice/zfitaxinvoice'.
ENDCLASS.



CLASS ZCL_TAX_INVOICE IMPLEMENTATION.


  METHOD create_client.
  ENDMETHOD.


  METHOD read_posts.

   select single from I_OperationalAcctgDocItem as a
   left join ztable_plant as b on a~BusinessPlace = b~plant_code
   fields b~plant_name1,b~plant_code,b~address1,b~address2,b~address3,b~phone,b~pan_no,b~fssai_no,b~gstin_no,b~city,b~pin
    WHERE a~AccountingDocument = @ac AND
    a~FiscalYear = @fs AND
    a~CompanyCode = @co
    and a~Customer is not INITIAL
    into @data(header).

    data : address type string.

    if header-address1 is not INITIAL.
     address = |{ header-address1 }|.
    endif.
    if header-address2 is not INITIAL.
     address = |{ address }, { header-address2 }|.
    endif.
    if header-address3 is not INITIAL.
     address = |{ address }, { header-address3 }|.
    endif.
    if header-city is not INITIAL.
     address = |{ address }, { header-city }|.
    endif.
     if header-pin is not INITIAL.
     address = |{ address }-{ header-pin }|.
    endif.

    SELECT SINGLE FROM
    i_accountingdocumentjournal AS a
    LEFT JOIN I_BusinessPartner AS b ON a~Customer = b~BusinessPartner
    LEFT JOIN I_Businesspartnertaxnumber AS c ON a~Customer = b~BusinessPartner
    LEFT JOIN i_customer AS d ON a~Customer = d~Customer
    FIELDS
    a~DocumentReferenceID,
    a~PostingDate,
    b~BusinessPartnerFullName,
    c~BPTaxNumber,
    d~Region
    WHERE a~AccountingDocument = @ac AND
    a~FiscalYear = @fs AND
    a~CompanyCode = @co AND
    a~ledger = '0L' AND
    a~IsReversal IS INITIAL AND
    a~IsReversed IS INITIAL AND
*    a~AccountingDocumentType = 'DR'
    a~AccountingDocumentType IN ( 'DR','DG' )
    INTO @DATA(lv_invoice).

    SELECT SINGLE FROM
    i_accountingdocumentjournal AS a
    LEFT JOIN I_BusinessPartner AS b ON a~Customer = b~BusinessPartner
    LEFT JOIN I_Businesspartnertaxnumber AS c ON a~Customer = c~BusinessPartner
    LEFT JOIN i_customer AS d ON a~Customer = d~Customer
    LEFT JOIN i_regiontext AS e ON d~Region = e~Region AND e~Country = d~Country AND e~Language = 'E'
    LEFT JOIN i_countrytext as f on d~County = f~Country AND f~Language = 'E'
    FIELDS
    a~DocumentReferenceID,
    a~PostingDate,
    a~AccountingDocumentType,
    b~BusinessPartnerFullName,
    c~BPTaxNumber,
    d~Region,
    d~StreetName,
    d~CityName,
    d~PostalCode,
    d~country,
    f~countryName,
    e~RegionName
    WHERE a~AccountingDocument = @ac AND
    a~FiscalYear = @fs AND
    a~CompanyCode = @co AND
    a~ledger = '0L' AND
    a~IsReversal IS INITIAL AND
    a~IsReversed IS INITIAL AND
*    a~AccountingDocumentType = 'DR'
    a~AccountingDocumentType IN ( 'DR','DG' )
     AND
    a~Customer IS NOT INITIAL
    INTO @DATA(lv_invoice2).
    DATA: lv_comp_name TYPE string.

    data str1 type string.

    CONCATENATE lv_invoice2-StreetName lv_invoice2-CityName lv_invoice2-PostalCode lv_invoice2-CountryName INTO   str1 SEPARATED BY space.

    IF co = 'BNPL'.
      lv_comp_name = 'BONN NUTRIENTS PVT. LTD.'.
    ELSEIF co = 'BIPL'.
      lv_comp_name = 'BONN INDUSTRIES PVT. LTD.'.
    ELSEIF co = 'CAPL'.
      lv_comp_name = 'CHOICE AGROS PVT. LTD.'.
    ELSEIF co = 'SSFI'.
      lv_comp_name = 'S S FOOD INDUSTRIES'.
    ELSEIF co = 'HOVL'.
      lv_comp_name = 'HOUSE OF VEDA PVT. LTD.'.
    ELSEIF co = 'PPAL'.
      lv_comp_name = 'PRIME PACKAGING'.
    ELSEIF co = 'PFPL'.
      lv_comp_name = 'PFLEX PACKAGING PVT. LTD.'.
    ELSEIF co = 'BNBG'.
      lv_comp_name = 'B AND B GLOBAL FZ-LLC'.
    ELSEIF co = 'BBPL'.
      lv_comp_name = 'BONN BISCUITS PVT. LTD.'.
    ENDIF.
    data sr1 type string.
    if lv_invoice2-AccountingDocumentType = 'DR'.
        str1 = 'TAX INVOICE'.
      ELSEIF lv_invoice2-AccountingDocumentType = 'DG'.

       str1 = 'CREDIT NOTE'.
    ENDIF.

    DATA(lv_xml_header) =
    |<form>| &&
    |<header>| &&
    |<companyname>{ header-plant_name1 }</companyname>| && " done
    |<Tax>{ str1 }</Tax>| && " done
    |<plant_add>{ address }</plant_add>| &&
    |<plant_phone>{ header-phone }</plant_phone>| &&
    |<plant_gst>{ header-gstin_no }</plant_gst>| &&
    |<plant_pan>{ header-pan_no }</plant_pan>| &&
    |<plant_fssai>{ header-fssai_no }</plant_fssai>| &&
    |<invoice>{ lv_invoice-DocumentReferenceID }</invoice>| && " done
    |<date>{ lv_invoice-PostingDate }</date>| && " done
    |<billto>{ lv_invoice2-BusinessPartnerFullName }</billto>| && " done
    |<billgstin>{ lv_invoice2-BPTaxNumber }</billgstin>| && " done
    |<ShipAdd>{ str1 }</ShipAdd>| && " done
    |<billAdd>{ str1 }</billAdd>| && " done
    |<billpan>{ lv_invoice2-BPTaxNumber+2(10) }</billpan>| &&
    |<billstate>{ lv_invoice2-RegionName }</billstate>| && " done
    |<billstatecode>{ lv_invoice2-BPTaxNumber+0(2) }</billstatecode>| &&
    |<billplaceofsupply>{ lv_invoice2-RegionName }</billplaceofsupply>| &&
    |<shipto>{ lv_invoice2-BusinessPartnerFullName }</shipto>| &&
    |<co>{ co }</co>| &&
    |</header>| &&
    |<lineitems>|.

    SELECT FROM
    I_AccountingDocumentJournal AS a
    FIELDS
    a~AccountingDocumentItem,
    a~DocumentReferenceID,
    a~CreditAmountInCoCodeCrcy,
    a~DocumentItemText,
    a~TaxCode,
    a~AccountingDocument,
    a~AccountingDocumentType
    WHERE a~AccountingDocument = @ac AND
    a~FiscalYear = @fs AND
    a~CompanyCode = @co AND
    a~ledger = '0L' AND
    a~IsReversal IS INITIAL AND
    a~IsReversed IS INITIAL AND
*    a~AccountingDocumentType = 'DR'
    a~AccountingDocumentType IN ( 'DR','DG' )
     AND
    a~Customer IS INITIAL and
    a~TRANSACTIONTYPEDETERMINATION is INITIAL
    INTO TABLE @DATA(lt_table).

    CLEAR lv_comp_name.

    DATA: lv_gst TYPE string.
    DATA: lv_igst TYPE string.
    DATA: lv_reverse TYPE string.

    LOOP AT lt_table INTO DATA(wa_table).

      select single from
      I_OPERATIONALACCTGDOCITEM as a
      FIELDS
      a~IN_HSNOrSACCode
      where a~AccountingDocument = @wa_table-AccountingDocument and
      a~CompanyCode = @co and
      a~FiscalYear = @fs and
      a~AccountingDocumentItem = @wa_table-AccountingDocumentItem
      into @data(lv_hsn).

      IF wa_table-TaxCode = 'O0'.
        lv_gst = '0'.
      ENDIF.
      IF wa_table-TaxCode = 'O1'.
        lv_gst = '2.5'.
      ENDIF.
      IF wa_table-TaxCode = 'O2'.
        lv_gst = '6'.
      ENDIF.
      IF wa_table-TaxCode = 'O3'.
        lv_gst = '9'.
      ENDIF.
      IF wa_table-TaxCode = 'O4'.
        lv_gst = '14'.
      ENDIF.

      IF wa_table-TaxCode = 'O9'.
        lv_igst = '0'.
      ENDIF.
      IF wa_table-TaxCode = 'O5'.
        lv_igst = '5'.
      ENDIF.
      IF wa_table-TaxCode = 'O6'.
        lv_igst = '12'.
      ENDIF.
      IF wa_table-TaxCode = 'O7'.
        lv_igst = '18'.
      ENDIF.
      IF wa_table-TaxCode = 'O8'.
        lv_igst = '28'.
      ENDIF.

      IF wa_table-TaxCode = 'R0' OR wa_table-TaxCode = 'R1' OR wa_table-TaxCode = 'R2' OR
      wa_table-TaxCode = 'R3' OR wa_table-TaxCode = 'R4' OR wa_table-TaxCode = 'R5' OR wa_table-TaxCode = 'R6'
       OR wa_table-TaxCode = 'R7' OR wa_table-TaxCode = 'R8' OR wa_table-TaxCode = 'R9'.
        lv_reverse = 'Y'.
      ELSE.
        lv_reverse = 'N'.
      ENDIF.

      select single from
      I_OPERATIONALACCTGDOCITEM as a
      FIELDS
      a~TaxItemGroup
      where a~AccountingDocument = @ac and
      a~CompanyCode = @co and
      a~FiscalYear = @fs and
      a~AccountingDocumentItem = @wa_table-AccountingDocumentItem
*      a~TRANSACTIONTYPEDETERMINATION = 'JOS'
      into @data(lv_gstamt1).

      select single from
      I_OPERATIONALACCTGDOCITEM as a
      FIELDS
      a~ABSOLUTEAMOUNTINCOCODECRCY
      where a~AccountingDocument = @ac and
      a~CompanyCode = @co and
      a~FiscalYear = @fs and
      a~TaxItemGroup = @lv_gstamt1 and
      a~TRANSACTIONTYPEDETERMINATION = 'JOS'
      into @data(lv_sgstamt).


      select single from
      I_OPERATIONALACCTGDOCITEM as a
      FIELDS
      a~ABSOLUTEAMOUNTINCOCODECRCY
      where a~AccountingDocument = @ac and
      a~CompanyCode = @co and
      a~FiscalYear = @fs and
      a~TaxItemGroup = @lv_gstamt1 and
      a~TRANSACTIONTYPEDETERMINATION = 'JOC'
      into @data(lv_cgstamt).

      select single from
      I_OPERATIONALACCTGDOCITEM as a
      FIELDS
      a~ABSOLUTEAMOUNTINCOCODECRCY
      where a~AccountingDocument = @ac and
      a~CompanyCode = @co and
      a~FiscalYear = @fs and
      a~TaxItemGroup = @lv_gstamt1 and
      a~TRANSACTIONTYPEDETERMINATION = 'JOI'
      into @data(lv_igstamt).



      if wa_table-AccountingDocumentType = 'DG'.

        SELECT SINGLE FROM   I_AccountingDocumentJournal as a
        FIELDS
        a~DEBITAMOUNTINCOCODECRCY
        WHERE a~AccountingDocument = @ac AND
        a~FiscalYear = @fs AND
    a~CompanyCode = @co AND
    a~ledger = '0L' AND
    a~IsReversal IS INITIAL AND
    a~IsReversed IS INITIAL AND
*
    a~Customer IS   INITIAL and
    a~TRANSACTIONTYPEDETERMINATION is  INITIAL
    INTO  @DATA(lt_table1) PRIVILEGED ACCESS.

     wa_table-CreditAmountInCoCodeCrcy = lt_table1.

       ENDIF.





       if  lv_cgstamt < '0'.
            lv_cgstamt = lv_cgstamt * -1.
      ENDIF.
       if  lv_sgstamt < '0'.
            lv_sgstamt = lv_sgstamt * -1.
      ENDIF.
       if  lv_igstamt < '0'.
            lv_igstamt = lv_igstamt * -1.
      ENDIF.
     if  wa_table-CreditAmountInCoCodeCrcy < '0'.
            wa_table-CreditAmountInCoCodeCrcy = wa_table-CreditAmountInCoCodeCrcy * -1.
      ENDIF.

      DATA(lv_xml_item) =
      |<item>| &&
      |<desofgoods>{ wa_table-DocumentItemText }</desofgoods>| && " done
      |<hsncode>{ lv_hsn }</hsncode>| && " done
      |<quan>1</quan>| && " done
      |<uom>NO</uom>| && " done
      |<rate>{ wa_table-CreditAmountInCoCodeCrcy }</rate>| && " done
      |<total>{ wa_table-CreditAmountInCoCodeCrcy * 1 }</total>| && " done
      |<dis></dis>| &&
      |<taxable>{ wa_table-CreditAmountInCoCodeCrcy * 1 }</taxable>| && " done
      |<sgst>{ lv_gst }</sgst>| && " done
      |<cgst>{ lv_gst }</cgst>| && " done
      |<igst>{ lv_igst }</igst>| && " done
      |<cgstamt>{ lv_cgstamt }</cgstamt>| && " done
      |<sgstamt>{ lv_sgstamt }</sgstamt>| && " done
      |<igstamt>{ lv_igstamt }</igstamt>| && " done
      |<reverse>{ lv_reverse }</reverse>| && " done
      |</item>|
      .
      CONCATENATE lv_xml_header lv_xml_item INTO lv_xml_header.
      CLEAR lv_gst.
      CLEAR wa_table.
      CLEAR lv_igst.
      clear lv_gstamt1.
      clear lv_cgstamt.
      clear lv_sgstamt.
      clear lv_igstamt.
      clear lv_hsn.
    ENDLOOP.

    DATA(lv_xml_last) =
    |</lineitems>| &&
    |</form>|.

    CONCATENATE lv_xml_header lv_xml_last INTO lv_xml_header.

    REPLACE ALL OCCURRENCES OF '&' IN lv_xml_header WITH 'and'.

    CALL METHOD zcl_ads_master=>getpdf(
      EXPORTING
        xmldata  = lv_xml_header
        template = lc_template_name
      RECEIVING
        result   = result12
    ).

  ENDMETHOD.
ENDCLASS.
