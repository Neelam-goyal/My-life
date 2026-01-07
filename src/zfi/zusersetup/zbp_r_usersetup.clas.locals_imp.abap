CLASS lhc_zr_usersetup DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_usersetup RESULT result.
    METHODS fillusername FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_usersetup~fillusername.

ENDCLASS.

CLASS lhc_zr_usersetup IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD FillUsername.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<wa_key>).

      SELECT SINGLE FROM i_user
        FIELDS UserDescription
        WHERE userid = @<wa_key>-Userid
        INTO @DATA(lv_username) PRIVILEGED ACCESS.

      IF lv_username IS NOT INITIAL.
        MODIFY ENTITIES OF zr_usersetup IN LOCAL MODE
          ENTITY zr_usersetup
            UPDATE FIELDS ( Username )
            WITH VALUE #( (
              %tky    = <wa_key>-%tky
              Username = lv_username
            ) ).
         ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
