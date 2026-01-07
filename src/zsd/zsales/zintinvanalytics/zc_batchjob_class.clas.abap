CLASS zc_batchjob_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_rt_exec_object .
    METHODS calculate.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZC_BATCHJOB_CLASS IMPLEMENTATION.


  METHOD if_apj_rt_exec_object~execute.
  calculate( ) .
  ENDMETHOD.


  METHOD calculate.


   ENDMETHOD.
ENDCLASS.
