CLASS zcl_bs_ghv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_sadl_exit_calc_element_read.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BS_GHV IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.
delete from zbook_trans where bankrecoid IS NOT INITIAL.
delete from zbank_reco where bankrecoid IS NOT INITIAL.
delete from zbankstmt where statement_id IS NOT INITIAL.
delete from zbankstmtlines where statement_id IS NOT INITIAL.
delete from zstatement_trans where bankrecoid IS NOT INITIAL.
ENDMETHOD.


 METHOD if_sadl_exit_calc_element_read~calculate.


 ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.
ENDCLASS.
