CLASS zcl_mm_grn_print DEFINITION
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
        IMPORTING cleardoc        TYPE string
                  lv_fiscal       TYPE string
                  lv_company      TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZMM_GRN_PRINT/ZMM_GRN_PRINT'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.
ENDCLASS.



CLASS zcl_mm_grn_print IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

    TYPES: BEGIN OF ty_item,
             materialdocument       TYPE i_materialdocumentitem_2-materialdocument,
             materialdocumentyear   TYPE i_materialdocumentitem_2-materialdocumentyear,
             companycode            TYPE i_materialdocumentitem_2-companycode,
             purchaseorder          TYPE i_materialdocumentitem_2-purchaseorder,
             purchaseorderitem      TYPE i_materialdocumentitem_2-purchaseorderitem,
             quantityinentryunit    TYPE i_materialdocumentitem_2-quantityinentryunit,
             entryunit              TYPE i_materialdocumentitem_2-entryunit,
             material               TYPE i_materialdocumentitem_2-material,
*         GOODSMOVEMENTTYPE         TYPE I_MaterialDocumentItem_2-GoodsMovementType,
             purchaseorderitemtext  TYPE i_purchaseorderitemapi01-purchaseorderitemtext,
             netpriceamount         TYPE i_purchaseorderitemapi01-netpriceamount,
             consumptiontaxctrlcode TYPE i_productplantintltrd-consumptiontaxctrlcode,
             gateentryno            TYPE zgateentryheader-gateentryno,
             gateqty                TYPE zgateentrylines-gateqty,
           END OF ty_item.

    DATA: it_item TYPE TABLE OF ty_item,
          wa_item TYPE ty_item.

    SELECT SINGLE
    a~materialdocument,
    a~materialdocumentyear,
    a~GoodsMovementType,
    a~companycode,
    a~plant,
    a~postingdate,
    a~Goodsmovementiscancelled,
    b~Plant_name1,   """""""""""""""""""""company Name
    b~address1,   """""""""""""""plant add
    b~address2,
    b~address3,
    b~city,
    b~Pin,
    b~State_code2,
    b~state_name,
    b~state_code1,
    b~gstin_no,    """""""""""""""plant add
    a~purchaseorder,     """"""""""""""it is used for supplier
    c~supplier,   """""""""""" this is supplier Code
    c~supplyingplant,
    d~SupplierFullName,
    d~SupplierName,  """"""""""""'supplier Name
    d~AddressID,
    d~TaxNumber3,
    e~street,
    e~streetprefixname1,
    e~streetprefixname2,
    e~POBoxPostalCode,
    e~region,              """"""" it is used for joining
    f~regionname,
    h~materialdocumentheadertext,
    g~invoiceno,
    g~invoicedate,
    g~vehicleno

    FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS a
    LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS AS b ON a~plant = b~plant_code
    LEFT JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS c ON a~PurchaseOrder = c~PurchaseOrder
    LEFT JOIN  i_supplier WITH PRIVILEGED ACCESS AS d ON c~Supplier = d~Supplier
    LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS e ON d~AddressID = e~AddressID
    LEFT JOIN  I_regiontext WITH PRIVILEGED ACCESS AS f ON e~Region = f~Region AND f~Country = 'IN'
    LEFT JOIN  i_materialdocumentheader_2 WITH PRIVILEGED ACCESS AS h ON ( a~MaterialDocument = h~MaterialDocument AND a~MaterialDocumentYear = h~MaterialDocumentYear )
    LEFT JOIN zgateentryheader WITH PRIVILEGED ACCESS AS g ON h~materialdocumentheadertext = g~gateentryno

    WHERE a~MaterialDocument = @cleardoc AND a~MaterialDocumentYear = @lv_fiscal
    AND a~CompanyCode = @lv_company
    INTO @DATA(header).


    IF header-supplier IS INITIAL.
      DATA(lv_supplyingplant) = |CV{ header-supplyingplant }|.
      SELECT SINGLE
        d~supplier,
        d~SupplierFullName,
        d~AddressID
        FROM I_Supplier AS d
        WHERE d~Supplier = @lv_supplyingplant
        INTO ( @header-supplier, @header-SupplierFullName, @header-AddressID ).
    ENDIF.
    CLEAR : lv_supplyingplant.

    DATA plant_add TYPE string.
    CONCATENATE header-address1 header-address2 header-address3 header-city header-pin header-state_code2 header-state_name INTO plant_add SEPARATED BY space.
    """""""""""""""supplier name and code"""""""""""""
    DATA str2 TYPE string.
    CONCATENATE header-Supplier header-SupplierName INTO str2 SEPARATED BY '-'.
    """"""""""""supplier add"""""""""""""""""""""""""""
    DATA str3 TYPE string.
    CONCATENATE header-Street header-streetprefixname1 header-streetprefixname2 header-POBoxPostalCode INTO str3 SEPARATED BY space.
    """"""""""""""""""plant state and code""""""""""""""""""""""""""""
    DATA str7 TYPE string.
    CONCATENATE header-state_name header-state_code1 INTO str7 SEPARATED BY '-'.

    DATA str9 TYPE string.
    CONCATENATE header-RegionName header-Region INTO str9 SEPARATED BY ' - '.
    DATA str8 TYPE string.
    """"""""""""""""""""""""""""""""""""""line item""""""""""""""""""""""

    SELECT
    a~materialdocument,
    a~materialdocumentyear,
    a~companycode,
    a~purchaseorder,
    a~purchaseorderitem,
    a~quantityinentryunit,
    a~entryunit,
    a~material,
    b~purchaseorderitemtext,
    b~netpriceamount,
    c~consumptiontaxctrlcode,
    g~gateentryno
*  i~gateqty
    FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS AS b ON a~PurchaseOrder = b~PurchaseOrder AND a~PurchaseOrderItem = b~PurchaseOrderItem
   LEFT JOIN i_productplantintltrd WITH PRIVILEGED ACCESS AS c ON a~Material = c~Product  AND a~Plant = c~Plant
   LEFT JOIN  i_materialdocumentheader_2 WITH PRIVILEGED ACCESS AS h ON a~MaterialDocument = h~MaterialDocument
      AND a~MaterialDocumentYear = h~MaterialDocumentYear
    LEFT JOIN zgateentryheader WITH PRIVILEGED ACCESS AS g ON h~materialdocumentheadertext = g~gateentryno
*  left join I_MATERIALDOCUMENTITEM_2 WITH PRIVILEGED ACCESS  as i
*  LEFT JOIN zgateentrylines WITH PRIVILEGED ACCESS as i on h~MATERIALDOCUMENTHEADERTEXT = i~gateentryno and a~PurchaseOrder = i~documentno
*   and a~PurchaseOrderItem = i~documentitemno
    WHERE a~MaterialDocument = @cleardoc
    AND a~MaterialDocumentYear = @lv_fiscal
    AND a~CompanyCode = @lv_company
    AND (
          ( a~GoodsMovementType = '101' AND a~PurchaseOrder IS NOT INITIAL )
          OR a~GoodsMovementType = '305' OR a~GoodsMovementType = '102'
        )

    INTO TABLE @it_item.
    SORT it_item BY MaterialDocument MaterialDocumentYear PurchaseOrder PurchaseOrderItem gateentryno.

    LOOP AT it_item INTO wa_item.
      SELECT SINGLE gateqty
       FROM zgateentrylines
       WHERE gateentryno     = @wa_item-gateentryno
         AND documentno      = @wa_item-purchaseorder
         AND documentitemno  = @wa_item-purchaseorderitem
             INTO @wa_item-gateqty.
      MODIFY it_item FROM wa_item TRANSPORTING gateqty.
    ENDLOOP.

    SELECT FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_purorditmpricingelementapi01 WITH PRIVILEGED ACCESS AS b ON a~PurchaseOrder = b~PurchaseOrder AND a~PurchaseOrderItem = b~PurchaseOrderItem AND
    b~ConditionType = 'PMP0' AND b~ConditionInactiveReason IS INITIAL
    FIELDS b~PurchaseOrder,b~PurchaseOrderItem,b~ConditionQuantity,b~ConditionQuantityUnit,b~ConditionRateValue
    WHERE a~MaterialDocument = @cleardoc
    AND a~MaterialDocumentYear = @lv_fiscal
    AND a~CompanyCode = @lv_company
    AND (
          ( a~GoodsMovementType = '101' AND a~PurchaseOrder IS NOT INITIAL )
          OR a~GoodsMovementType = '305' OR a~GoodsMovementType = '102'
        )
    INTO TABLE @DATA(it_item_new).



    IF header-Goodsmovementiscancelled IS NOT INITIAL  .
      str8 = 'Cancelled'.
    ENDIF.

    DATA(lv_xml) =
    |<Form>| &&
    |<Header>| &&
    |<Company_Name>{ header-plant_name1 }</Company_Name>| &&
    |<CompanyCode>{ header-CompanyCode }</CompanyCode>| &&
    |<Plant_Add>{ plant_add }</Plant_Add>| &&
    |<Pb_Tel>{ str7 }</Pb_Tel>| &&
    |<GSTIN_NO>{ header-gstin_no }</GSTIN_NO>| &&
    |<Supplier_Name>{ header-SupplierName }</Supplier_Name>| &&
    |<Supplier_Code>{ header-Supplier }</Supplier_Code>| &&
    |<Supplier_State_Code></Supplier_State_Code>| &&
    |<Supplier_State>{ str9 }</Supplier_State>| &&
    |<Supplier_Add>{ str3 }</Supplier_Add>| &&
    |<Supplier_GSTIN>{ header-TaxNumber3 }</Supplier_GSTIN>| &&
    |<GRN_NO>{ header-MaterialDocument }</GRN_NO>| &&
    |<GRN_Date>{ header-PostingDate }</GRN_Date>| &&
    |<Bill_No>{ header-invoiceno }</Bill_No>| &&
    |<Bill_Date>{ header-invoicedate }</Bill_Date>| &&
    |<Vehical_number>{ header-vehicleno }</Vehical_number>| &&
    |<Gate_entry>{ header-MaterialDocumentHeaderText }</Gate_entry>| &&
    |<Goods_Canceled>{ str8 }</Goods_Canceled>| &&
    |<Goods_Mov_type>{ header-GoodsMovementType }</Goods_Mov_type>| &&
    |</Header>| &&
    |<Line_Item>| .

    DATA str4 TYPE string.
    DATA str5 TYPE string.
    DATA str6 TYPE string.
    DATA str10 TYPE string.
    DATA str11 TYPE string.
    DATA rate_new TYPE string.

    LOOP AT it_item INTO DATA(wa_it_item).
      str10 = wa_it_item-PurchaseOrderItem.
      SHIFT str10 LEFT DELETING LEADING '0'.
      CONCATENATE wa_it_item-PurchaseOrder str10 INTO str4 SEPARATED BY '-'.

*  str5 = wa_it_item-QUANTITYINENTRYUNIT * wa_it_item-NetPriceAmount.
      READ TABLE it_item_new INTO DATA(wa_item_new) WITH KEY PurchaseOrder = wa_it_item-purchaseorder PurchaseOrderItem = wa_it_item-purchaseorderitem.

      str5 = ( wa_it_item-quantityinentryunit * wa_it_item-NetPriceAmount ) / wa_item_new-ConditionQuantity .
      DATA(rate_2dec)     = round( val = wa_item_new-ConditionRateValue dec = 2 ).
      DATA(quantity_3dec) = round( val = wa_item_new-ConditionQuantity dec = 3 ).
      DATA : rate_str TYPE string.
      DATA : qty_str TYPE string.

      rate_str = rate_2dec.
      qty_str = quantity_3dec.

*     rate_new = |{ rate_2dec }/{ quantity_3dec } { wa_item_new-ConditionQuantityUnit }|.
      rate_new = |{ rate_str }/{ qty_str } { wa_item_new-ConditionQuantityUnit }|.

*  CONCATENATE wa_it_item-Material wa_it_item-PurchaseOrderItemText INTO str6 SEPARATED BY '-'.

      str11 = wa_it_item-Material.
      SHIFT str11 LEFT DELETING LEADING '0'.

      SELECT SINGLE
      a~product,
      a~productname

      FROM i_producttext WITH PRIVILEGED ACCESS AS a
      WHERE a~Product = @wa_it_item-Material
      INTO @DATA(str12).

      IF wa_it_item-PurchaseOrderItemText IS INITIAL.
        wa_it_item-PurchaseOrderItemText = str12-ProductName.
      ENDIF.

      CONCATENATE wa_it_item-PurchaseOrderItemText str11 INTO str6
        SEPARATED BY cl_abap_char_utilities=>newline.


      DATA(lv_xml_item) =
      |<Item>| &&
      |<Sr_No></Sr_No>| &&
      |<item>{ wa_it_item-material }</item>| &&
      |<Description_of_goods>{ wa_it_item-purchaseorderitemtext }</Description_of_goods>| &&
      |<material>{ str11 }</material>| &&
      |<HSN_SAG_NO>{ wa_it_item-ConsumptionTaxCtrlCode }</HSN_SAG_NO>| &&
      |<A_C_Posting></A_C_Posting>| &&
      |<Po_Indent_No>{ str4 }</Po_Indent_No>| &&
      |<Uom>{ wa_it_item-entryunit }</Uom>| &&
      |<Qty>{ wa_it_item-quantityinentryunit }</Qty>| &&
      |<gate_qty>{ wa_it_item-gateqty }</gate_qty>| &&
      |<Rate>{ rate_new }</Rate>| &&
      |<Total>{ str5 }</Total>| &&
      |</Item>|.

      CONCATENATE lv_xml lv_xml_item INTO lv_xml.
      CLEAR : wa_item_new,wa_it_item,rate_new,str5,str4,str11,str12,rate_2dec,quantity_3dec,rate_str,qty_str.
    ENDLOOP.

    CONCATENATE lv_xml '</Line_Item>' '</Form>' INTO lv_xml.


    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.

    CALL METHOD zcl_ads_master=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
