class ZCL_HTTP_BREADMATQTYUPD definition
  public
  create public .

PUBLIC SECTION.

  INTERFACES if_http_service_extension .
  CLASS-METHODS saveData
    IMPORTING
      VALUE(request) TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message) TYPE string .

  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_BREADMATQTYUPD IMPLEMENTATION.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.

    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        response->set_text( saveData( request ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD saveData.

    TYPES: BEGIN OF ty_data,
             Plant           TYPE werks_d,
             Material        TYPE matnr,
             Rangedate       TYPE string,
             Todate          TYPE string,
             Shift           TYPE string,
             Quantity        TYPE p LENGTH 8 DECIMALS 5,
             Um              TYPE c LENGTH 3,
             Actual_Qty      TYPE p LENGTH 8 DECIMALS 5,
             Difference      TYPE p LENGTH 8 DECIMALS 5,
             Storagelocation TYPE c LENGTH 4,
             MatDesc         TYPE string,
             Batch           TYPE c LENGTH 10,
           END OF ty_data.


    DATA tt_json_structure TYPE TABLE OF ty_data WITH EMPTY KEY.
    TRY.
        DATA rv_message_id TYPE string.

        TRY.
            rv_message_id = cl_system_uuid=>create_uuid_c36_static( ).

          CATCH cx_uuid_error INTO DATA(lx_uuid).
            rv_message_id = '00000000-0000-0000-0000-000000000000'.
        ENDTRY.

        xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

        LOOP AT tt_json_structure INTO DATA(wa).

          DATA: diff TYPE p LENGTH 8 DECIMALS 5.
          diff = wa-actual_qty - wa-quantity.

          MODIFY ENTITIES OF zr_repmatbread
            ENTITY zrrepmatbread
            CREATE FIELDS (
                Plant
                Material
                Rangedate
                Todate
                Shift
                Quantity
                Um
                ActualQty
                Difference
                Storagelocation
                MatDesc
                Batch
                Idfier
           )
           WITH VALUE #( (
                %cid = getCID( )
                Plant = wa-plant
                Material = |{ wa-material ALPHA = OUT }|
                Rangedate = wa-rangedate
                Todate = wa-todate
                Shift = wa-shift
                Quantity = wa-quantity
                Um = wa-um
                ActualQty = wa-actual_qty
                Difference = diff
                Storagelocation = wa-storagelocation
                MatDesc = wa-matdesc
                Batch = wa-batch
                Idfier = rv_message_id
          ) )
          REPORTED DATA(ls_po_reported1)
          FAILED   DATA(ls_po_failed1)
          MAPPED   DATA(ls_po_mapped1).

          COMMIT ENTITIES BEGIN
             RESPONSE OF zr_repmatbread
             FAILED DATA(ls_save_failed1)
             REPORTED DATA(ls_save_reported1).

          IF ls_po_failed1 IS NOT INITIAL OR ls_save_failed1 IS NOT INITIAL.
            message = 'Failed to save data'.
          ELSE.
            message = 'Data saved successfully'.
          ENDIF.

          COMMIT ENTITIES END.
        ENDLOOP.

      CATCH cx_root INTO DATA(lx_root).
        message = |General Error: { lx_root->get_text( ) }|.
    ENDTRY.


*    Scehduling Job for Data Load

    DATA: lv_job_start  TYPE timestamp.
    lv_job_start  = cl_abap_context_info=>get_system_date(  ) &&
                    cl_abap_context_info=>get_system_time(  ).



    TRY.
        CALL METHOD cl_apj_rt_api=>schedule_job
          EXPORTING
            iv_job_text                   = 'Bread Material Quantity Update Job'
            iv_job_template_name          = 'ZAPJT_BREADMATUPD'
            is_start_info                 = VALUE #(
                                                 start_immediately = abap_true
                                                 timestamp        = lv_job_start
                                             )
            it_job_parameter_value = VALUE #( (
                                            name  = 'P_IDFIER'
                                            t_value = VALUE #( (
                                                            low = rv_message_id
                                                            option = 'EQ'
                                                            sign = 'I'
                                                      ) )
                                        ) )
          IMPORTING
            et_message                    = DATA(lt_messages).

        message = 'Uploading started.'.
      CATCH cm_apj_base INTO DATA(lx_apj).
        " HANDLE ERRORS
        message = lx_apj->get_text( ).

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
