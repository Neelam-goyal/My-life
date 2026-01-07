CLASS zcl_delete_glaccount DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA: check TYPE i,
          gate_entry_no1 TYPE zcontrolsheet-gate_entry_no,
          gate_entry_no2 TYPE zcontrolsheet-gate_entry_no,
          plant TYPE zcontrolsheet-plant,
          cgpno1 TYPE zcashroomcrtable-cgpno,
          cgpno2 TYPE zcashroomcrtable-cgpno,
          plant2 TYPE zcashroomcrtable-plant.
    INTERFACES: if_oo_adt_classrun.

  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DELETE_GLACCOUNT IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    IF check = 1.
      DELETE FROM zbillinglines WHERE invoice IS NOT INITIAL.
      DELETE FROM zbillingproc WHERE billingdocument IS NOT INITIAL.

    ELSEIF check = 2.
      DELETE FROM zcontrolsheet WHERE gate_entry_no = @gate_entry_no1.

    ELSEIF check = 3.
      DELETE FROM zcontrolsheet WHERE ( gate_entry_no < @gate_entry_no2 AND gate_entry_no > @gate_entry_no1 ).

    ELSEIF check = 4.
      DELETE FROM zcontrolsheet WHERE plant = @plant.

    ELSEIF check = 5.
      DELETE FROM zcontrolsheet where gate_entry_no is not initial.

    ELSEIF check = 6.
      DELETE FROM zcashroomcrtable WHERE cgpno = @cgpno1.

    ELSEIF check = 7.
      DELETE FROM zcashroomcrtable WHERE ( cgpno < @cgpno2 AND cgpno > @cgpno1 ).

    ELSEIF check = 8.
      DELETE FROM zcashroomcrtable WHERE plant = @plant2.

    ELSEIF check = 9.
      DELETE FROM zcashroomcrtable where cgpno is not initial.

    ELSEIF check = 10.
      DELETE FROM zcustcontrolsht WHERE gate_entry_no = @gate_entry_no1.

    ELSEIF check = 11.
      DELETE FROM zcustcontrolsht WHERE ( gate_entry_no < @gate_entry_no2 AND gate_entry_no > @gate_entry_no1 ).

    ELSEIF check = 12.
      DELETE FROM zcustcontrolsht WHERE plant = @plant.

    ELSEIF check = 13.
      DELETE FROM zcustcontrolsht where gate_entry_no is not initial.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
