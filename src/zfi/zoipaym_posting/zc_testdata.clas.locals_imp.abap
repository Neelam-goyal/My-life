*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
class this_is_xyz definition.

  PUBLIC SECTION.

    METHODS setup1.
    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO this_is_xyz.
    CLASS-DATA: mv_value TYPE i.
    METHODS constructor.

protected section.
  PRIVATE SECTION.
    CLASS-DATA go_single_instance TYPE REF TO this_is_xyz.

  ENDCLASS.

class this_is_xyz implementation.

 METHOD get_instance.
    IF go_single_instance IS NOT BOUND.
      " If no instance exists, create the only one
      CREATE OBJECT go_single_instance.
    ENDIF.
    " Return the single, existing instance
    ro_instance = go_single_instance.
  ENDMETHOD.

 METHOD constructor.
   mv_value = 42.

 ENDMETHOD.


 METHOD setup1.
   mv_value = 42.
   " Initialize the class under test before each test method runs
 ENDMETHOD.


endclass.
