CLASS zcl_number_utils DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS parse_decimal
      IMPORTING
          iv_value_str TYPE string
      RETURNING
        VALUE(rv_value)     TYPE decfloat34.
ENDCLASS.



CLASS ZCL_NUMBER_UTILS IMPLEMENTATION.


  METHOD parse_decimal.
     DATA(lv_str) = iv_value_str.

    lv_str = iv_value_str.

    " 1️⃣ Remove thousand separators (comma, space) and currency symbols
    REPLACE ALL OCCURRENCES OF ',' IN lv_str WITH ''.
    REPLACE ALL OCCURRENCES OF REGEX '[^0-9\.\-\+]+' IN lv_str WITH ''.
    CONDENSE lv_str NO-GAPS.

    " 2️⃣ If empty or invalid, return zero
    IF lv_str IS INITIAL.
      rv_value = CONV decfloat34( 0 ).
      RETURN.
    ENDIF.

    " 3️⃣ Try conversion (ABAP will raise error if malformed)
    TRY.
        rv_value = CONV decfloat34( lv_str ).
      CATCH cx_sy_conversion_no_number.
        rv_value = CONV decfloat34( 0 ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
