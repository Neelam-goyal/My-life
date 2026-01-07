CLASS zcl_record_correction_cashroom DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_RECORD_CORRECTION_CASHROOM IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lv_plant         TYPE zcashroomcrtable-plant , "VALUE 'BN02',
          lv_cfyear        TYPE zcashroomcrtable-cfyear , "VALUE '2526',
          lv_cgpno_string  TYPE string, "VALUE '00364,01051',
          lt_cgpno         TYPE TABLE OF zcashroomcrtable-cgpno,
          lv_reference_doc TYPE zcashroomcrtable-reference_doc, " VALUE ' ',
          lv_glposted      TYPE zcashroomcrtable-glposted, "VALUE ' '.
          lv_variable      TYPE string VALUE ' '.


    DATA lt_cgpno_values TYPE TABLE OF zcashroomcrtable-cgpno WITH EMPTY KEY.

    SPLIT lv_cgpno_string AT ',' INTO TABLE lt_cgpno_values.

    IF lv_variable EQ '1'.

      LOOP AT lt_cgpno_values INTO DATA(lv_cgpno).
        UPDATE zcashroomcrtable
           SET reference_doc = @lv_reference_doc,
               glposted      = @lv_glposted
         WHERE plant   = @lv_plant
           AND cfyear  = @lv_cfyear
           AND cgpno  = @lv_cgpno.
      ENDLOOP.

    ELSEIF lv_variable EQ '2'.


      UPDATE zcashroomcrtable
         SET reference_doc = @lv_reference_doc,
             glposted      = @lv_glposted
       WHERE plant   = @lv_plant
         AND cfyear  = @lv_cfyear
         AND cgpno   IN ( '03644', '03645', '03647', '03648',
                          '03649', '03653', '03656', '03657',
                          '03658', '03659', '03661', '03662',
                          '03663', '03664', '03666', '03667',
                          '03669', '03671', '04243', '04275',
                          '04282', '04288' ).

    ENDIF.

  ENDMETHOD.
ENDCLASS.
