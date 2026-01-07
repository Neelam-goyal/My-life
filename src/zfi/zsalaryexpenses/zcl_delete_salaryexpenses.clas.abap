CLASS zcl_delete_salaryexpenses DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DELETE_SALARYEXPENSES IMPLEMENTATION.


 METHOD if_oo_adt_classrun~main.

 delete from zsalaryexpenses where accountingdocument is not INITIAL.
 ENDMETHOD.
ENDCLASS.
