CLASS LHC_RAP_TDAT_CTS DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      GET
        RETURNING
          VALUE(RESULT) TYPE REF TO IF_MBC_CP_RAP_TDAT_CTS.

ENDCLASS.

CLASS LHC_RAP_TDAT_CTS IMPLEMENTATION.
  METHOD GET.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = 'ZTABLEFORTAXCODE'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'TableForTaxCode' table = 'ZWHT_TAXCODE' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZI_TABLEFORTAXCODE_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR TableForTaxCodeAll
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR TableForTaxCodeAll
        RESULT result.
ENDCLASS.

CLASS LHC_ZI_TABLEFORTAXCODE_S IMPLEMENTATION.
  METHOD GET_INSTANCE_FEATURES.
    DATA: edit_flag            TYPE abp_behv_op_ctrl    VALUE if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( FOR key in keys (
               %TKY = key-%TKY
               %ACTION-edit = edit_flag
               %ASSOC-_TableForTaxCode = edit_flag ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_TABLEFORTAXCODE' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%UPDATE      = is_authorized.
    result-%ACTION-Edit = is_authorized.
  ENDMETHOD.
ENDCLASS.
CLASS LSC_ZI_TABLEFORTAXCODE_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS:
      SAVE_MODIFIED REDEFINITION.
ENDCLASS.

CLASS LSC_ZI_TABLEFORTAXCODE_S IMPLEMENTATION.
  METHOD SAVE_MODIFIED ##NEEDED.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZI_TABLEFORTAXCODE DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR TableForTaxCode
        RESULT result,
      COPYTABLEFORTAXCODE FOR MODIFY
        IMPORTING
          KEYS FOR ACTION TableForTaxCode~CopyTableForTaxCode,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR TableForTaxCode
        RESULT result,
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR TableForTaxCode
        RESULT result.
ENDCLASS.

CLASS LHC_ZI_TABLEFORTAXCODE IMPLEMENTATION.
  METHOD GET_GLOBAL_FEATURES.
    DATA edit_flag TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%UPDATE = edit_flag.
    result-%DELETE = edit_flag.
  ENDMETHOD.
  METHOD COPYTABLEFORTAXCODE.
    DATA new_TableForTaxCode TYPE TABLE FOR CREATE ZI_TableForTaxCode_S\_TableForTaxCode.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-TableForTaxCode = VALUE #( FOR fkey IN keys ( %TKY = fkey-%TKY ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF ZI_TableForTaxCode_S IN LOCAL MODE
      ENTITY TableForTaxCode
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(ref_TableForTaxCode)
        FAILED DATA(read_failed).

    IF ref_TableForTaxCode IS NOT INITIAL.
      ASSIGN ref_TableForTaxCode[ 1 ] TO FIELD-SYMBOL(<ref_TableForTaxCode>).
      DATA(key) = keys[ KEY draft %TKY = <ref_TableForTaxCode>-%TKY ].
      DATA(key_cid) = key-%CID.
      APPEND VALUE #(
        %TKY-SingletonID = 1
        %IS_DRAFT = <ref_TableForTaxCode>-%IS_DRAFT
        %TARGET = VALUE #( (
          %CID = key_cid
          %IS_DRAFT = <ref_TableForTaxCode>-%IS_DRAFT
          %DATA = CORRESPONDING #( <ref_TableForTaxCode> EXCEPT
          SingletonID
          CreatedBy
          CreatedAt
          LocalLastChangedBy
          LocalLastChangedAt
          LastChangedAt
        ) ) )
      ) TO new_TableForTaxCode ASSIGNING FIELD-SYMBOL(<new_TableForTaxCode>).
      <new_TableForTaxCode>-%TARGET[ 1 ]-Country = to_upper( key-%PARAM-Country ).
      <new_TableForTaxCode>-%TARGET[ 1 ]-Officialwhldgtaxcode = to_upper( key-%PARAM-Officialwhldgtaxcode ).
      <new_TableForTaxCode>-%TARGET[ 1 ]-Withholdingtaxcode = to_upper( key-%PARAM-Withholdingtaxcode ).

      MODIFY ENTITIES OF ZI_TableForTaxCode_S IN LOCAL MODE
        ENTITY TableForTaxCodeAll CREATE BY \_TableForTaxCode
        FIELDS (
                 Country
                 Officialwhldgtaxcode
                 Withholdingtaxcode
                 Withholdingtaxtype
                 Whldgtaxrelevantpercent
                 Withholdingtaxpercent
                 Glaccount
               ) WITH new_TableForTaxCode
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.

      mapped-TableForTaxCode = mapped_create-TableForTaxCode.
    ENDIF.

    INSERT LINES OF read_failed-TableForTaxCode INTO TABLE failed-TableForTaxCode.

    IF failed-TableForTaxCode IS INITIAL.
      reported-TableForTaxCode = VALUE #( FOR created IN mapped-TableForTaxCode (
                                                 %CID = created-%CID
                                                 %ACTION-CopyTableForTaxCode = if_abap_behv=>mk-on
                                                 %MSG = mbc_cp_api=>message( )->get_item_copied( )
                                                 %PATH-TableForTaxCodeAll-%IS_DRAFT = created-%IS_DRAFT
                                                 %PATH-TableForTaxCodeAll-SingletonID = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_TABLEFORTAXCODE' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%ACTION-CopyTableForTaxCode = is_authorized.
  ENDMETHOD.
  METHOD GET_INSTANCE_FEATURES.
    result = VALUE #( FOR row IN keys ( %TKY = row-%TKY
                                        %ACTION-CopyTableForTaxCode = COND #( WHEN row-%IS_DRAFT = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
    ) ).
  ENDMETHOD.
ENDCLASS.
