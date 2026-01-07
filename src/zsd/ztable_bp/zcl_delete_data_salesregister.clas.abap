CLASS zcl_delete_data_salesregister DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

     INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DELETE_DATA_SALESREGISTER IMPLEMENTATION.


   METHOD if_oo_adt_classrun~main.
 delete from zbillingproc where bukrs is not INITIAL.
  delete from zbillinglines where companycode is not INITIAL.
   endMETHOD.
ENDCLASS.
