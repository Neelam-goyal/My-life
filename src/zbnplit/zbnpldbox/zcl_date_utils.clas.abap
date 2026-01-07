
CLASS zcl_date_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS parse_date
      IMPORTING
          iv_date_str TYPE string
          iv_format TYPE string

      RETURNING
        VALUE(rv_date)     TYPE sy-datum.

  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_DATE_UTILS IMPLEMENTATION.


  METHOD parse_date.
    DATA: lv_day   TYPE string,
          lv_month TYPE string,
          lv_year  TYPE string,
          lv_sep   TYPE c LENGTH 1.

    IF iv_date_str = ''.
        rv_date = '00000000'.
        return.
    ENDIF.
    " 1. Detect separator from format
    FIND FIRST OCCURRENCE OF REGEX '[^A-Za-z]' IN iv_format
         MATCH OFFSET DATA(lv_off) MATCH LENGTH DATA(lv_len).
    IF sy-subrc = 0.
      lv_sep = iv_format+lv_off(lv_len).
    ENDIF.

    " 2. Split format and date string by separator
    DATA lt_format_parts TYPE string_table.
    DATA lt_value_parts  TYPE string_table.
    SPLIT iv_format   AT lv_sep INTO TABLE lt_format_parts.
    SPLIT iv_date_str AT lv_sep INTO TABLE lt_value_parts.

    IF lines( lt_format_parts ) <> lines( lt_value_parts ).
      RAISE EXCEPTION TYPE cx_sy_conversion_no_date.
    ENDIF.

    " 3. Map parts
    LOOP AT lt_format_parts INTO DATA(lv_part).
      DATA(lv_value) = lt_value_parts[ sy-tabix ].
      CASE to_upper( lv_part ).
        WHEN 'DD'.
          lv_day = lv_value.
        WHEN 'MM'.
          lv_month = lv_value.
        WHEN 'YYYY'.
          lv_year = lv_value.
        WHEN 'YY'.
          lv_year = |20{ lv_value }|. " naive century assumption
        WHEN OTHERS.
          RAISE EXCEPTION TYPE cx_sy_conversion_no_date.
      ENDCASE.
    ENDLOOP.

    " 4. Build and validate date YYYYMMDD
    rv_date = |{ lv_year }{ lv_month ALPHA = IN }{ lv_day ALPHA = IN }|.
    rv_date = CONV d( rv_date ).  " validates, will raise if not a real date
  ENDMETHOD.
ENDCLASS.
