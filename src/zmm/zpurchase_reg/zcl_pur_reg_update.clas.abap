CLASS zcl_pur_reg_update DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PUR_REG_UPDATE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    SELECT FROM zpurchinvlines FIELDS *
    WHERE supplierinvoice IS NOT INITIAL
    INTO TABLE @DATA(it_prlines) PRIVILEGED ACCESS.

    LOOP AT it_prlines INTO DATA(wa_prlines).

      wa_prlines-taxableamount = wa_prlines-netamount.
      MODIFY zpurchinvlines FROM @wa_prlines.
      COMMIT WORK.

    ENDLOOP.

    DATA lv_abc TYPE c LENGTH 10.
    lv_abc = 'chjbs'.
    lv_abc = 'chjbs'.

    SELECT FROM zpurchinvlines FIELDS companycode, fiscalyearvalue, supplierinvoice
    WHERE deliverycost IS NOT INITIAL
    INTO TABLE @DATA(it_dlrvycost) PRIVILEGED ACCESS.

    LOOP AT it_dlrvycost INTO DATA(wa_dlvry).

      DELETE FROM zpurchinvlines    "'item'
      WHERE companycode = @wa_dlvry-companycode
      AND fiscalyearvalue = @wa_dlvry-fiscalyearvalue
      AND supplierinvoice = @wa_dlvry-supplierinvoice.
      COMMIT WORK.

      DELETE FROM zpurchinvproc "hdr
      WHERE companycode = @wa_dlvry-companycode
      AND fiscalyearvalue = @wa_dlvry-fiscalyearvalue
      AND supplierinvoice = @wa_dlvry-supplierinvoice.
      COMMIT WORK.

    ENDLOOP.

    DATA lv_abcd TYPE c LENGTH 10.
    lv_abcd = 'chjbs'.
    lv_abcd = 'chjbs'.


  ENDMETHOD.
ENDCLASS.
