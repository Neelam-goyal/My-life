CLASS lhc_materialdeclaration DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR materialdeclaration RESULT result.

*    METHODS earlynumbering_stocklines FOR NUMBERING
*      IMPORTING entities FOR CREATE Materialdeclaration.

    METHODS saveinfo FOR DETERMINE ON SAVE
      IMPORTING keys FOR Materialdeclaration~saveinfo.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Materialdeclaration RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Materialdeclaration.


ENDCLASS.

CLASS lhc_materialdeclaration IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<materialdecl>).
      " get from number range
      DATA(max_item_id) = 0.
    ENDLOOP.

    "Generate Declare No.
    SELECT SINGLE FROM zr_materialdecl
        FIELDS MAX( Declareno )
        WHERE Plantcode = @<materialdecl>-Plantcode AND Declaredate = @<materialdecl>-Declaredate
        INTO @DATA(maxDeclareno).
    max_item_id = maxDeclareno + 1.

    "assign Declare no.
    APPEND CORRESPONDING #( <materialdecl> ) TO mapped-materialdeclaration ASSIGNING FIELD-SYMBOL(<mapped_materialdecl>).
    IF <materialdecl>-Declareno IS INITIAL.
      <mapped_materialdecl>-Declareno = max_item_id.
    ENDIF.

  ENDMETHOD.

  METHOD saveinfo.
    READ ENTITY IN LOCAL MODE zr_materialdecl
      FIELDS ( Productcode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(matlines).

    DATA updates TYPE TABLE FOR UPDATE zr_materialdecl.

    LOOP AT matlines ASSIGNING FIELD-SYMBOL(<matlineitem>).
      APPEND VALUE #( %tky = <matlineitem>-%tky
                      declareno = 3
                       ) to updates.

    ENDLOOP.

*    MODIFY ENTITY IN LOCAL MODE zr_materialdecl
*      UPDATE FIELDS ( Declareno ) WITH updates.

  ENDMETHOD.

*  METHOD earlynumbering_stocklines.
*    READ ENTITIES OF zr_materialdecl IN LOCAL MODE
*      ENTITY Materialdeclaration
*        FIELDS ( Declareno )
*          WITH CORRESPONDING #( entities )
*          RESULT DATA(Materialdeclaration_lines)
*        FAILED failed.
*
*    LOOP AT entities ASSIGNING FIELD-SYMBOL(<material_line>).
*      " get highest item from sales order items of a sales order
*      DATA(max_item_id) = REDUCE #( INIT max = CONV posnr( '000000' )
*                                    FOR Materialdeclaration_line IN Materialdeclaration_lines USING KEY entity WHERE (
*                                            Plantcode = <material_line>-Plantcode AND Declaredate = <material_line>-Declaredate
*                                            and Bukrs = <material_line>-Bukrs )
*                                    NEXT max = COND posnr( WHEN Materialdeclaration_line-Declareno > max
*                                                           THEN Materialdeclaration_line-Declareno
*                                                           ELSE max )
*                                  ).
*    ENDLOOP.
*
**    "assign sales order item id
**    LOOP AT <material_line>-%key ASSIGNING FIELD-SYMBOL(<material_line_item>).
**        APPEND CORRESPONDING #( <material_line_item> ) TO mapped-materialdeclaration ASSIGNING FIELD-SYMBOL(<mapped_material_line_item>).
**        IF <material_line_item>-d IS INITIAL.
**          max_item_id += 1.
**          <mapped_material_line_item>-Declareno = max_item_id.
**        ENDIF.
**      ENDLOOP.
*
*  ENDMETHOD.


ENDCLASS.
