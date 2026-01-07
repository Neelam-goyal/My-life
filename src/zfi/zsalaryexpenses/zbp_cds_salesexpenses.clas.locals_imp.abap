CLASS lhc_ZrSalesExpenses DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZrSalesExpenses RESULT result.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR ACTION ZrSalesExpenses~delete.

ENDCLASS.

CLASS lhc_ZrSalesExpenses IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD delete.
  Modify ENTITIES OF zcds_salesexpenses in LOCAL MODE
  entity ZrSalesExpenses
  update fields ( Isdeleted )
  with value #( For key in keys INDEX INTo i (
     %tky = key-%tky
     Employetype = key-Employetype
     Salarydate = key-Salarydate
     Plantcode = key-Plantcode
     isdeleted = abap_true
  ) )
  Failed DAta(lt_failed)
  Reported data(lt_reported).

  ENDMETHOD.

ENDCLASS.
