CLASS LHC_ZR_PRODBREAKDOWN DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrProdbreakdown
        RESULT result,
      Valid_breadownpercentage FOR VALIDATE ON SAVE
            IMPORTING keys FOR ZrProdbreakdown~Valid_breadownpercentage.
*         CHANGING  failed FOR ZrProdbreakdown~Valid_breadownpercentage.
ENDCLASS.

CLASS LHC_ZR_PRODBREAKDOWN IMPLEMENTATION.

  METHOD GET_GLOBAL_AUTHORIZATIONS.

  ENDMETHOD.

  METHOD Valid_breadownpercentage.

        READ ENTITIES OF zr_prodbreakdown
           IN LOCAL MODE
           ENTITY ZrProdbreakdown
           FIELDS ( Breakdownpercentage )
           WITH CORRESPONDING #( keys )
           RESULT DATA(lt_breaks).

        LOOP AT lt_breaks ASSIGNING  FIELD-SYMBOL(<fs_break>).
          DATA(lv_Pct) = <fs_break>-Breakdownpercentage.
          IF lv_pct < 0  OR lv_pct > 100.
            append value #( %tky = <fs_break>-%tky ) to failed-zrprodbreakdown.
            APPEND VALUE #(
            %tky = keys[ 1 ]-%tky
            %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'Breakdown percentage must be between 0 and 100.'
                          ) ) TO reported-zrprodbreakdown.
          ENDIF.
        ENDLOOP.
      ENDMETHOD.

ENDCLASS.
