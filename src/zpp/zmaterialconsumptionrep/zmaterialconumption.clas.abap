CLASS zmaterialconumption DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZMATERIALCONUMPTION IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.



    DATA lv_aufnr TYPE zmatdistlines-productionorder.
    DATA lv_declaredate TYPE zmatdistlines-declaredate.
    DATA lv_plant TYPE zmatdistlines-plantcode.
*    DATA lv_productcode TYPE zmatdistlines-productcode.

*    lv_productcode = '00'.
    lv_declaredate = '00000000'.
    lv_plant = '0000'.
    lv_aufnr = '000000000'.

    SELECT FROM zmatdistlines
    FIELDS *
    WHERE plantcode = @lv_plant
    AND productionorder = @lv_aufnr
    AND declaredate = @lv_declaredate
    INTO TABLE @DATA(it_zmatdistlines) PRIVILEGED ACCESS.

    LOOP AT it_zmatdistlines INTO DATA(wa_zmatdistlines).
      wa_zmatdistlines-varianceposted = 0.

      MODIFY zmatdistlines FROM @wa_zmatdistlines.
      CLEAR wa_zmatdistlines.
    ENDLOOP.

    SELECT SINGLE FROM zmaterialdist
    FIELDS *
    WHERE plantcode = @lv_plant
    AND declarecdate = @lv_declaredate
    INTO @DATA(wa_zmaterialdist) PRIVILEGED ACCESS.

    wa_zmaterialdist-varianceclosed = 0.
    MODIFY zmaterialdist FROM @wa_zmaterialdist.

    out->write( 'updated' ).


  ENDMETHOD.
ENDCLASS.
