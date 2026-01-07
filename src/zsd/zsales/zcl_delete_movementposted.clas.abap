CLASS zcl_delete_movementposted DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DELETE_MOVEMENTPOSTED IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  data: date_from type d,
        date_to type d.

if date_from is not initial and date_to is not initial.
DELETE FROM zcratesdata
WHERE movementposted IS INITIAL
  AND cmgpdate >= @date_from
  AND cmgpdate <= @date_to.
endif.

  ENDMETHOD.
ENDCLASS.
