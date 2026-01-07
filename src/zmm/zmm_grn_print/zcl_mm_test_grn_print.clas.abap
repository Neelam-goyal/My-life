
CLASS zcl_mm_test_grn_print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MM_TEST_GRN_PRINT IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  SELECT SINGLE

  a~MATERIALDOCUMENT,
  a~MATERIALDOCUMENTYEAR,
  a~companycode,
  a~plant,
  b~Plant_name1,   """""""""""""""""""""company Name
  b~ADDRESS1,   """""""""""""""plant add
  b~ADDRESS2,
  b~ADDRESS3,
  b~CITY,
  b~Pin,
  b~State_code2,
  b~state_name,    """""""""""""""plant add
  a~PURCHASEORDER,     """"""""""""""it is used for supplier
  c~supplier,   """""""""""" this is supplier Code
  d~SupplierFullName     """"""""""""'supplier Name

  FROM I_MATERIALDOCUMENTITEM_2 WITH PRIVILEGED ACCESS as a

  LEFT JOIN ZTABLE_PLANT WITH PRIVILEGED ACCESS as b on a~plant = b~plant_code
  LEFT JOIN I_PURCHASEORDERAPI01 WITH PRIVILEGED ACCESS as c on a~PurchaseOrder = c~PurchaseOrder
  LEFT JOIN  i_supplier WITH PRIVILEGED ACCESS as d on c~Supplier = d~Supplier

  WHERE a~MaterialDocument = '5000000005' AND a~MaterialDocumentYear = '2025'
  AND a~CompanyCode = 'BBPL'

  INTO @DATA(header).

  out->write( header ).
 """"""""""""""""""""""""""""""""""""""line item""""""""""""""""""""""
  SELECT

  a~MATERIALDOCUMENT,
  a~MATERIALDOCUMENTYEAR,
  a~companycode


  FROM I_MATERIALDOCUMENTITEM_2 WITH PRIVILEGED ACCESS as a

  WHERE a~MaterialDocument = '5000000005' AND a~MaterialDocumentYear = '2025'
  AND a~CompanyCode = 'BBPL'
  INTO TABLE @DATA(it_item).

  out->write( it_item ).



  DATA(lv_xml) =
  |<Form>| &&
  |<Header>| &&
  |<Company_Name></Company_Name>| &&
  |<Pb_Tel></Pb_Tel>| &&
  |<GSTIN_NO></GSTIN_NO>| &&
  |<Supplier_Name></Supplier_Name>| &&
  |<Supplier_Code></Supplier_Code>| &&
  |<Supplier_Add></Supplier_Add>| &&
  |<Supplier_GSTIN></Supplier_GSTIN>| &&
  |<GRN_NO></GRN_NO>| &&
  |<GRN_Date></GRN_Date>| &&
  |<Value_Date></Value_Date>| &&
  |<Party_Invoice_Number></Party_Invoice_Number>| &&
  |</Header>| &&
  |<Line_Item>| .



  LOOP AT it_item INTO DATA(wa_it_item).

   DATA(lv_xml_item) =
   |<Item>| &&
   |<Sr_No></Sr_No>| &&
   |<Description_of_goods></Description_of_goods>| &&
   |<HSN_SAG_NO></HSN_SAG_NO>| &&
   |<A_C_Posting></A_C_Posting>| &&
   |<Po_Indent_No></Po_Indent_No>| &&
   |<Uom></Uom>| &&
   |<Qty></Qty>| &&
   |<Rate></Rate>| &&
   |<Total></Total>| &&
   |</Item>|.

 CONCATENATE lv_xml lv_xml_item INTO lv_xml.
  ENDLOOP.

 CONCATENATE lv_xml '</Line_Item>' '</Form>' INTO lv_xml.
 out->write( lv_xml ).

  ENDMETHOD.
ENDCLASS.
