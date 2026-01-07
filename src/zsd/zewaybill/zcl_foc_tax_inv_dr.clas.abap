CLASS zcl_foc_tax_inv_dr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FOC_TAX_INV_DR IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    SELECT SINGLE

    a~creationdate,  "" header date
    a~documentreferenceid,
    a~purchaseorderbycustomer,
    c~salesdocument,
    c~creationdate AS salecreationdate,
    c~salesdocument AS i_salesdaument,
    b~plant,
    b~REFERENCESDDOCUMENT,
    d~gstin_no ,
     d~state_code2 ,
    d~plant_name1 ,
    d~address1 ,
    d~address2 ,
    d~city ,
   d~district ,
   d~state_name ,
   d~pin ,
   d~country,
*12.03   e~supplierName,
*12.03   e~taxnumber3,
*12.03   c~yy1_dono_sdh,
*12.03   c~yy1_dodate_sdh,
*12.03   c~yy1_poamendmentno_sdh,
*12.03   c~yy1_poamendmentdate_sdh,
   c~customerpurchaseorderdate
*12.03   f~region,
*12.03   g~regionname

    FROM i_billingdocument WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
    LEFT JOIN i_salesdocument WITH PRIVILEGED ACCESS AS c  ON b~SalesDocument = c~SalesDocument
    LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS AS d ON d~plant_code = b~plant
*12.03    LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS e ON a~YY1_TransportDetails_BDH = e~Supplier
*12.03    LEFT    JOIN i_customer WITH PRIVILEGED ACCESS AS f ON a~SoldToParty = e~Customer
*12.03    LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS AS g ON f~Country = g~Country

    WHERE a~billingdocument = '0090000114'
    INTO  @DATA(wa_header).
*12.03    out->write( wa_header ).





    """"""""""""""""item level data """"""""""""""""'

    SELECT
     a~billingdocument,
     a~billingdocumentitem,
     a~plant,
     a~product,
     a~billingdocumentitemtext ,   "mat
     a~billingquantity  ,  "Quantity
     a~billingquantityunit  ,  "UOM
     b~consumptiontaxctrlcode  ,   "HSN CODE
*12.03     c~yy1_packsize_sd_sdi  ,  "i_avgpkg
*12.03     c~yy1_packsize_sd_sdiu  ,   " package_qtyunit
     d~conditionratevalue     " i_per



     FROM I_BillingDocumentItem AS a
      LEFT JOIN i_productplantbasic AS b ON a~Product = b~Product
     LEFT JOIN I_SalesDocumentItem AS c ON c~SalesDocument = a~SalesDocument AND c~salesdocumentitem = a~salesdocumentitem
     LEFT JOIN i_billingdocumentitemprcgelmnt AS d ON d~BillingDocument = a~BillingDocument AND d~BillingDocumentItem = a~BillingDocumentItem
     WHERE a~billingdocument = '0090000114'
     INTO TABLE  @DATA(it_item).
    out->write( it_item ).

    """"""""""""condition based""""""""""""""
    SELECT
   a~conditionType  ,  "hidden conditiontype
   a~conditionamount ,  "hidden conditionamount
   a~conditionratevalue  ,  "condition ratevalue
   a~conditionbasevalue   " condition base value
   FROM I_BillingDocItemPrcgElmntBasic AS a
    WHERE a~BillingDocument = '0090000114'
   INTO TABLE @DATA(lt_item2).
    out->write( lt_item2 ).


       DATA(lv_xml) =
  |<Form>| &&
  |<BillingDocumentNode>| &&
  |<Billing Date>{ wa_header-CreationDate }</Billing Date>| &&
  |<Document Reference ID>{ wa_header-ReferenceSDDocument }</Document Reference ID>| &&
  |<Purchase Order By Customer>{ wa_header-gstin_no }</Purchase Order By Customer>| && "" po number
  |<AmountInWords></AmountInWords>| &&                      " pending
  |<SalesDocument>{ wa_header-DocumentReferenceID }</SalesDocument>| && "" work order no
  |<SalesOrderDate></SalesOrderDate>| &&          ""work order date
  |<YY1_CustPODate_BD_h_BDH>{ wa_header-ReferenceSDDocument }</YY1_CustPODate_BD_h_BDH>| &&   ""  po date
  |<YY1_LR Date_B DH></YY1_LR Date_B DH>| &&   """Consignment_Note_Date
  |<YY1_PLANT_COM_ADD_BDH></YY1_PLANT_COM_ADD_BDH>| &&
  |<YY1_PLANT_COM_NAME_BDH></YY1_PLANT_COM_NAME_BDH>| &&
  |<YY1_PLANT_GSTIN_NO_BDH></YY1_PLANT_GSTIN_NO_BDH>| &&
  |YY1_TransportDetails_BDHT></YY1_TransportDetails_BDHT>| &&
  |YY1_TransportGST_bd_BDH></YY1_TransportGST_bd_BDH>| &&
  |YY1_VehicleNo_BDH></YY1_VehicleNo_BDH>| &&
  |<YY1_dodatebd_BDH></YY1_dpdatebd+BDH>| &&
  |<YY1_dono_bd_BDH></YY1_dono_bd_BDH>| &&
  |<BillToParty>| &&
  |<Region></Region>| &&
  |<RegionName></RegionName>| &&
  |</BillToParty>| &&
  |<Items>|.


 DATA(lv_xml_data) =
 |<BillingDocumentItemNode>| &&


 |</BilliongDocumentItemNode>| .







  ENDMETHOD.
ENDCLASS.
