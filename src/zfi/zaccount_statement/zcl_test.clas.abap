CLASS ZCL_TEST DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.
*    TYPES : BEGIN OF ty_final,
*              document                     TYPE i_operationalacctgdocitem-accountingdocument,
*              postingdate                  TYPE i_operationalacctgdocitem-postingdate,
*              accountingdocumenttype       TYPE i_operationalacctgdocitem-accountingdocumenttype,
*              companycode                  TYPE i_operationalacctgdocitem-companycode,
*              fiscalyear                   TYPE i_operationalacctgdocitem-fiscalyear,
*              material                     TYPE i_operationalacctgdocitem-material,
*              FINANCIALACCOUNTTYPE         TYPE i_operationalacctgdocitem-FinancialAccountType,
*              quantity                     TYPE i_operationalacctgdocitem-quantity,
*              baseunit                     TYPE i_operationalacctgdocitem-baseunit,
*              amountintransactioncurrency  TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*              CashDiscountAmount           TYPE i_operationalacctgdocitem-CashDiscountAmount,
*              transactiontypedetermination TYPE i_operationalacctgdocitem-transactiontypedetermination,
*              debitcreditcode              TYPE i_operationalacctgdocitem-debitcreditcode,
*              joi                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*              joc                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*              jos                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*              jtc                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*              wth                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*              deb_amt                      TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*              cre_amt                      TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*              closing_bal                  TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*              taxableamt                   TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*              taxableamtc                  TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*              remarks                      TYPE i_operationalacctgdocitem-documentitemtext,
*              businessplace                TYPE i_operationalacctgdocitem-businessplace,
*            END OF ty_final.
*
*    CLASS-DATA : BEGIN OF w_head,
*                   opening_bal   TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*                   closing_bal   TYPE i_operationalacctgdocitem-amountintransactioncurrency,
*                   value         TYPE i_operationalacctgdocitem-customer,
*                   cusvssupp(25) TYPE c,
*                   tds(25)       TYPE c,
*                 END OF w_head.
*
*    CLASS-DATA : BEGIN OF wa_add1,
*                   name               TYPE i_supplier-supplierfullname,
*                   taxnumber3         TYPE i_supplier-taxnumber3,
*                   customer           TYPE i_supplier-customer,
*                   telephonenumber1   TYPE i_supplier-phonenumber1,
*                   organizationname1  TYPE i_address_2-organizationname1,
*                   organizationname2  TYPE i_address_2-organizationname2,
*                   organizationname3  TYPE i_address_2-organizationname3,
*                   housenumber        TYPE i_address_2-housenumber,
*                   streetname         TYPE i_address_2-streetname,
*                   streetprefixname1  TYPE i_address_2-streetprefixname1,
*                   streetprefixname2  TYPE i_address_2-streetprefixname2,
*                   streetsuffixname1  TYPE i_address_2-streetsuffixname1,
*                   streetsuffixname2  TYPE i_address_2-streetsuffixname2,
*                   districtname       TYPE i_address_2-districtname,
*                   cityname           TYPE i_address_2-cityname,
*                   addresssearchterm1 TYPE i_address_2-addresssearchterm1,
*                   postalcode         TYPE i_supplier-postalcode,
*                   regionname         TYPE i_regiontext-regionname,
*                 END OF wa_add1.
*
*    CLASS-DATA :BEGIN OF wa_add,
*                  var1(80)  TYPE c,
*                  var2(80)  TYPE c,
*                  var3(80)  TYPE c,
*                  var4(80)  TYPE c,
*                  var5(80)  TYPE c,
*                  var6(80)  TYPE c,
*                  var7(80)  TYPE c,
*                  var8(80)  TYPE c,
*                  var9(80)  TYPE c,
*                  var10(80) TYPE c,
*                  var11(80) TYPE c,
*                  var12(80) TYPE c,
*                  var13(80) TYPE c,
*                  var14(80) TYPE c,
*                  var15(80) TYPE c,
*                END OF wa_add.
*
*    CLASS-DATA : it_final TYPE TABLE OF ty_final,
*                 wa_final TYPE ty_final.
*
*
*    CLASS-METHODS :
*
*      read_posts
*         IMPORTING VALUE(companycode)     TYPE string
*                  VALUE(correspondence)   TYPE string
*                  VALUE(accounttype)      TYPE string
*                  VALUE(customer)         TYPE string
*                  VALUE(lastdate)         TYPE string
*                  VALUE(currentdate)      TYPE string
*                  VALUE(profitcenter)     TYPE CHAR10
*                  VALUE(confirmletterbox) TYPE string
*        RETURNING VALUE(result12) TYPE string
*        RAISING   cx_static_check .
*
*  PROTECTED SECTION.
*  PRIVATE SECTION.
*
*    CONSTANTS  lc_template_name TYPE string VALUE 'ACCOUNTSTATEMENT_NEW7/ACCOUNTSTATEMENT_NEW7'..
protected section.
private section.
ENDCLASS.



CLASS ZCL_TEST IMPLEMENTATION.


  METHOD IF_OO_ADT_CLASSRUN~MAIN.

  ENDMETHOD.
ENDCLASS.
