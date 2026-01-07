CLASS LHC_ZR_ACTIVITYDECL DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Activitydeclaration
        RESULT result,
      get_instance_authorizations FOR INSTANCE AUTHORIZATION
            IMPORTING keys REQUEST requested_authorizations FOR Activitydeclaration RESULT result.

          METHODS earlynumbering_create FOR NUMBERING
            IMPORTING entities FOR CREATE Activitydeclaration.
ENDCLASS.

CLASS LHC_ZR_ACTIVITYDECL IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<activitydecl>).
      " get from number range
      DATA(max_item_id) = 0.
    ENDLOOP.

    "Generate Declare No.
    SELECT SINGLE FROM zr_activitydecl
        FIELDS MAX( Declareno )
        WHERE Plantcode = @<activitydecl>-Plantcode AND Declaredate = @<activitydecl>-Declaredate
        INTO @DATA(maxDeclareno).
    max_item_id = maxDeclareno + 1.

    "assign Declare no.
    APPEND CORRESPONDING #( <activitydecl> ) TO mapped-activitydeclaration ASSIGNING FIELD-SYMBOL(<mapped_activitydecl>).
    IF <activitydecl>-Declareno IS INITIAL.
      <mapped_activitydecl>-Declareno = max_item_id.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
