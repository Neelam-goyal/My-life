CLASS z_delete_table DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z_DELETE_TABLE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


    SELECT
    FROM i_billingdocument AS b
    INNER JOIN i_billingdocumentitem AS a
      ON b~billingdocument = a~billingdocument
    INNER JOIN i_billingdocumentitem AS ref
      ON a~ReferenceSDDocument = ref~ReferenceSDDocument
    LEFT JOIN zmaterialtext AS c
      ON a~Product = c~materialcode
      FIELDS a~product, a~billingquantity, c~material_text AS materialtext , c~materialcode , a~BillingDocument
    WHERE ref~billingdocument = '0090000552'
      AND b~sddocumentcategory = 'M'
      AND a~billingquantity <> 0
    INTO TABLE @DATA(wa_PCKDescription).

***************************************************************************************************************************CUSTOM INVOICE
select from I_BillingDocumentItem as a
inner join I_BillingDocumentTP as e on a~BillingDocument = e~BillingDocument
inner join I_SalesOrderItem as f on a~SalesDocument = f~SalesOrder
*inner join I_SalesQuotationItemTP as i on f~ReferenceSDDocument = i~SalesQuotation and f~SalesOrderItem = i~SalesQuotationItem
*inner join I_BillingDocumentItemPrcgElmnt as b on a~BillingDocument = b~BillingDocument and a~BillingDocumentItem = b~BillingDocumentItem and b~ConditionType = 'PPR0'
*inner join I_BillingDocumentItemPrcgElmnt as c on a~BillingDocument = c~BillingDocument and a~BillingDocumentItem = c~BillingDocumentItem and c~ConditionType = 'ZDQT'
*inner join I_BillingDocumentItemPrcgElmnt as d on a~BillingDocument = d~BillingDocument and a~BillingDocumentItem = d~BillingDocumentItem and d~ConditionType = 'ZDPT'
*inner join I_BillingDocumentItemPrcgElmnt as g on a~BillingDocument = g~BillingDocument and a~BillingDocumentItem = g~BillingDocumentItem and g~ConditionType = 'ZFRT'
*inner join I_BillingDocumentItemPrcgElmnt as h on a~BillingDocument = h~BillingDocument and a~BillingDocumentItem = h~BillingDocumentItem and h~ConditionType = 'ZINS'
*inner join I_BillingDocumentItemPrcgElmnt as j on a~BillingDocument = j~BillingDocument and a~BillingDocumentItem = j~BillingDocumentItem and j~ConditionType = 'ZPCK'
fields a~BillingQuantity,
a~BillingDocument,
a~BillingDocumentItem,
a~ItemNetWeight,
*b~ConditionAmount as b_qty ,
*c~ConditionAmount as c_qty ,
*d~ConditionAmount as d_qty,
*g~ConditionAmount as g_qty ,
*h~ConditionAmount as h_qty,
e~YY1_DFAIDate_BDH,
e~YY1_DFIANo_BDH,
a~SalesDocument
,f~ReferenceSDDocument
*j~ConditionAmou<nt as j_qty
*,i~YY1_ContNo_SDI,i~YY1_ContType_SDI,i~YY1_NoofContainers_SDI,
where a~BillingDocument = '0090000552' and a~BillingQuantity ne 0
into table @data(it).

SELECT * FROM i_billingdocumentitem AS a
WHERE a~billingdocument = '0090000552'
INTO TABLE @DATA(it_item).

  ENDMETHOD.
ENDCLASS.
