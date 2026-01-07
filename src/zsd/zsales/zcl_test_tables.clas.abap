CLASS zcl_test_tables DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEST_TABLES IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

UPDATE zdt_rplcrnote set imdate = '20250805',glposted = '' where imno = '000007' and implant = 'BN02'.

ENDMETHOD.
ENDCLASS.
