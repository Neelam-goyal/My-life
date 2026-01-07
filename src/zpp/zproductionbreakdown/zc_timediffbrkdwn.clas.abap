CLASS zc_timediffbrkdwn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZC_TIMEDIFFBRKDWN IMPLEMENTATION.


METHOD if_sadl_exit_calc_element_read~calculate.
    DATA:   lt_PRODBRKDWN TYPE STANDARD TABLE OF zc_prodbreakdown WITH DEFAULT KEY,
            lv_start_seconds TYPE i,
            lv_end_seconds   TYPE i,
            lv_diff_seconds  TYPE i.
    lt_PRODBRKDWN = CORRESPONDING #( it_original_data ).

    loop at lt_PRODBRKDWN assigning FIELD-SYMBOL(<lfs_progressors>).

        lv_start_seconds = ( <lfs_progressors>-Brkdnstarttime(2) * 3600 ) + ( <lfs_progressors>-Brkdnstarttime+2(2) * 60 ).
        lv_end_seconds   = ( <lfs_progressors>-Brkdnendtime(2) * 3600 ) + ( <lfs_progressors>-Brkdnendtime+2(2) * 60 ).

        " Calculate the difference in seconds
        lv_diff_seconds = lv_end_seconds - lv_start_seconds.

        " Convert to minutes
        DATA(minutes) = lv_diff_seconds / 60.

        if minutes < 0.
            <lfs_progressors>-BrkDwnInMin = 1440 + minutes.
        else.
            <lfs_progressors>-BrkDwnInMin = minutes.
        ENDIF.

    endloop.
    ct_calculated_data = CORRESPONDING #( lt_PRODBRKDWN ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.
ENDCLASS.
