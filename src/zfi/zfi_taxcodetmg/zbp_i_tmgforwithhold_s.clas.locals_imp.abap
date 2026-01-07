CLASS LHC_RAP_TDAT_CTS DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      GET
        RETURNING
          VALUE(RESULT) TYPE REF TO IF_MBC_CP_RAP_TDAT_CTS.

ENDCLASS.

CLASS LHC_RAP_TDAT_CTS IMPLEMENTATION.
  METHOD GET.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = 'ZTMGFORWITHHOLD'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'TmgForWithHoldingTa' table = 'ZDT_TAXCODE' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZI_TMGFORWITHHOLD_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR TmgForWithHoldinAll
        RESULT result,
      SELECTCUSTOMIZINGTRANSPTREQ FOR MODIFY
        IMPORTING
          KEYS FOR ACTION TmgForWithHoldinAll~SelectCustomizingTransptReq
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR TmgForWithHoldinAll
        RESULT result,
      EDIT FOR MODIFY
        IMPORTING
          KEYS FOR ACTION TmgForWithHoldinAll~edit.
ENDCLASS.

CLASS LHC_ZI_TMGFORWITHHOLD_S IMPLEMENTATION.
  METHOD GET_INSTANCE_FEATURES.
    DATA: edit_flag            TYPE abp_behv_op_ctrl    VALUE if_abap_behv=>fc-o-enabled
         ,selecttransport_flag TYPE abp_behv_op_ctrl    VALUE if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( FOR key in keys (
               %TKY = key-%TKY
               %ACTION-edit = edit_flag
               %ASSOC-_TmgForWithHoldingTa = edit_flag
               %ACTION-SelectCustomizingTransptReq = COND #( WHEN key-%IS_DRAFT = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD SELECTCUSTOMIZINGTRANSPTREQ.
    MODIFY ENTITIES OF ZI_TmgForWithHold_S IN LOCAL MODE
      ENTITY TmgForWithHoldinAll
        UPDATE FIELDS ( TransportRequestID HideTransport )
        WITH VALUE #( FOR key IN keys
                        ( %TKY               = key-%TKY
                          TransportRequestID = key-%PARAM-transportrequestid
                          HideTransport      = abap_false ) ).

    READ ENTITIES OF ZI_TmgForWithHold_S IN LOCAL MODE
      ENTITY TmgForWithHoldinAll
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %TKY   = entity-%TKY
                          %PARAM = entity ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_TMGFORWITHHOLD' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%UPDATE      = is_authorized.
    result-%ACTION-Edit = is_authorized.
    result-%ACTION-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.
  METHOD EDIT.
    CHECK lhc_rap_tdat_cts=>get( )->is_transport_mandatory( ).
    DATA(transport_request) = lhc_rap_tdat_cts=>get( )->get_transport_request( ).
    IF transport_request IS NOT INITIAL.
      MODIFY ENTITY IN LOCAL MODE ZI_TmgForWithHold_S
        EXECUTE SelectCustomizingTransptReq FROM VALUE #( ( %IS_DRAFT = if_abap_behv=>mk-on
                                                            SingletonID = 1
                                                            %PARAM-transportrequestid = transport_request ) ).
      reported-TmgForWithHoldinAll = VALUE #( ( %IS_DRAFT = if_abap_behv=>mk-on
                                     SingletonID = 1
                                     %MSG = mbc_cp_api=>message( )->get_transport_selected( transport_request ) ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
CLASS LSC_ZI_TMGFORWITHHOLD_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS:
      SAVE_MODIFIED REDEFINITION.
ENDCLASS.

CLASS LSC_ZI_TMGFORWITHHOLD_S IMPLEMENTATION.
  METHOD SAVE_MODIFIED.
    DATA(transport_from_singleton) = VALUE #( update-TmgForWithHoldinAll[ 1 ]-TransportRequestID OPTIONAL ).
    IF transport_from_singleton IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = transport_from_singleton
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) )->update_last_changed_date_time( view_entity_name   = 'ZI_TMGFORWITHHOLD'
                                                                                                        maintenance_object = 'ZTMGFORWITHHOLD' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZI_TMGFORWITHHOLD DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR TmgForWithHoldingTa
        RESULT result,
      COPYTMGFORWITHHOLDINGTA FOR MODIFY
        IMPORTING
          KEYS FOR ACTION TmgForWithHoldingTa~CopyTmgForWithHoldingTa,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR TmgForWithHoldingTa
        RESULT result,
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR TmgForWithHoldingTa
        RESULT result,
      VALIDATETRANSPORTREQUEST FOR VALIDATE ON SAVE
        IMPORTING
          KEYS_TMGFORWITHHOLDINALL FOR TmgForWithHoldinAll~ValidateTransportRequest
          KEYS_TMGFORWITHHOLDINGTA FOR TmgForWithHoldingTa~ValidateTransportRequest.
ENDCLASS.

CLASS LHC_ZI_TMGFORWITHHOLD IMPLEMENTATION.
  METHOD GET_GLOBAL_FEATURES.
    DATA edit_flag TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%UPDATE = edit_flag.
    result-%DELETE = edit_flag.
  ENDMETHOD.
  METHOD COPYTMGFORWITHHOLDINGTA.
    DATA new_TmgForWithHoldingTa TYPE TABLE FOR CREATE ZI_TmgForWithHold_S\_TmgForWithHoldingTa.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-TmgForWithHoldingTa = VALUE #( FOR fkey IN keys ( %TKY = fkey-%TKY ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF ZI_TmgForWithHold_S IN LOCAL MODE
      ENTITY TmgForWithHoldingTa
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(ref_TmgForWithHoldingTa)
        FAILED DATA(read_failed).

    IF ref_TmgForWithHoldingTa IS NOT INITIAL.
      ASSIGN ref_TmgForWithHoldingTa[ 1 ] TO FIELD-SYMBOL(<ref_TmgForWithHoldingTa>).
      DATA(key) = keys[ KEY draft %TKY = <ref_TmgForWithHoldingTa>-%TKY ].
      DATA(key_cid) = key-%CID.
      APPEND VALUE #(
        %TKY-SingletonID = 1
        %IS_DRAFT = <ref_TmgForWithHoldingTa>-%IS_DRAFT
        %TARGET = VALUE #( (
          %CID = key_cid
          %IS_DRAFT = <ref_TmgForWithHoldingTa>-%IS_DRAFT
          %DATA = CORRESPONDING #( <ref_TmgForWithHoldingTa> EXCEPT
          SingletonID
        ) ) )
      ) TO new_TmgForWithHoldingTa ASSIGNING FIELD-SYMBOL(<new_TmgForWithHoldingTa>).
      <new_TmgForWithHoldingTa>-%TARGET[ 1 ]-Country = to_upper( key-%PARAM-Country ).
      <new_TmgForWithHoldingTa>-%TARGET[ 1 ]-Officialwhldgtaxcode = to_upper( key-%PARAM-Officialwhldgtaxcode ).
      <new_TmgForWithHoldingTa>-%TARGET[ 1 ]-Withholdingtaxcode = to_upper( key-%PARAM-Withholdingtaxcode ).

      MODIFY ENTITIES OF ZI_TmgForWithHold_S IN LOCAL MODE
        ENTITY TmgForWithHoldinAll CREATE BY \_TmgForWithHoldingTa
        FIELDS (
                 Country
                 Officialwhldgtaxcode
                 Withholdingtaxcode
                 Withholdingtaxtype
                 Whldgtaxrelevantpercent
                 Withholdingtaxpercent
               ) WITH new_TmgForWithHoldingTa
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.

      mapped-TmgForWithHoldingTa = mapped_create-TmgForWithHoldingTa.
    ENDIF.

    INSERT LINES OF read_failed-TmgForWithHoldingTa INTO TABLE failed-TmgForWithHoldingTa.

    IF failed-TmgForWithHoldingTa IS INITIAL.
      reported-TmgForWithHoldingTa = VALUE #( FOR created IN mapped-TmgForWithHoldingTa (
                                                 %CID = created-%CID
                                                 %ACTION-CopyTmgForWithHoldingTa = if_abap_behv=>mk-on
                                                 %MSG = mbc_cp_api=>message( )->get_item_copied( )
                                                 %PATH-TmgForWithHoldinAll-%IS_DRAFT = created-%IS_DRAFT
                                                 %PATH-TmgForWithHoldinAll-SingletonID = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_TMGFORWITHHOLD' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%ACTION-CopyTmgForWithHoldingTa = is_authorized.
  ENDMETHOD.
  METHOD GET_INSTANCE_FEATURES.
    result = VALUE #( FOR row IN keys ( %TKY = row-%TKY
                                        %ACTION-CopyTmgForWithHoldingTa = COND #( WHEN row-%IS_DRAFT = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
    ) ).
  ENDMETHOD.
  METHOD VALIDATETRANSPORTREQUEST.
    CHECK keys_TmgForWithHoldingTa IS NOT INITIAL.
    DATA change TYPE REQUEST FOR CHANGE ZI_TmgForWithHold_S.
    READ ENTITY IN LOCAL MODE ZI_TmgForWithHold_S
    FIELDS ( TransportRequestID ) WITH CORRESPONDING #( keys_TmgForWithHoldinAll )
    RESULT FINAL(transport_from_singleton).
    lhc_rap_tdat_cts=>get( )->validate_all_changes(
                                transport_request     = VALUE #( transport_from_singleton[ 1 ]-TransportRequestID OPTIONAL )
                                table_validation_keys = VALUE #(
                                                          ( table = 'ZDT_TAXCODE' keys = REF #( keys_TmgForWithHoldingTa ) )
                                                               )
                                reported              = REF #( reported )
                                failed                = REF #( failed )
                                change                = REF #( change ) ).
  ENDMETHOD.
ENDCLASS.
