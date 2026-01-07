CLASS zc_testdata DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZC_TESTDATA IMPLEMENTATION.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA(lo_singleton_instance) = this_is_xyz=>get_instance( ).

    " Access and modify its instance variables
    out->write( |Initial data: { lo_singleton_instance->mv_value }| ).

    lo_singleton_instance->mv_value = '121'.

    " Access the instance again later (it returns the SAME object)
    DATA(lo_same_instance) = this_is_xyz=>get_instance( ).

    out->write( |Modified data: { lo_same_instance->mv_value }| ).

  ENDMETHOD.
ENDCLASS.
