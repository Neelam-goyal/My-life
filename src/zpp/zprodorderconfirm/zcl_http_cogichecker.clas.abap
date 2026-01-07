class ZCL_HTTP_COGICHECKER definition
  public
  create public .

public section.



  TYPES: BEGIN OF tt_response,
           ManufacturingOrder TYPE aufnr,
           Operation          TYPE c LENGTH 4,

           Confirmation       TYPE co_rueck,
         END OF tt_response.

   TYPES: BEGIN OF tt_validate_result,
         message            TYPE string,
         mfgorder           TYPE aufnr,
         operation          TYPE c LENGTH 4,
         confirmation TYPE string,
       END OF tt_validate_result.

  interfaces IF_HTTP_SERVICE_EXTENSION .
  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
  CLASS-METHODS postOrder
    IMPORTING
      VALUE(request) TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message) TYPE string .

  CLASS-METHODS validate
    IMPORTING
      filled_details TYPE tt_response
    RETURNING
      VALUE(result) TYPE tt_validate_result.

  CLASS-METHODS convertISTSeparate
    IMPORTING
      sdate        TYPE d
      stime        TYPE t
    RETURNING
      VALUE(idate) TYPE d.
protected section.
private section.
*    CLASS-DATA gv_confirm_counter TYPE i VALUE 0.
ENDCLASS.



CLASS ZCL_HTTP_COGICHECKER IMPLEMENTATION.


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
        response->set_text( postOrder( request ) ).
    ENDCASE.

  ENDMETHOD.


METHOD postOrder.

    DATA(filled_details) = VALUE tt_response( ).
  DATA(validate_result) = VALUE tt_validate_result( ).

    TRY.
      " read JSON into structure
      xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( filled_details ) ).

      " call validate which returns tt_validate_result
      validate_result = validate( filled_details ).

      " return serialized JSON so frontend can parse manufacturingOrder/operation/confirmation etc.
      message = /ui2/cl_json=>serialize( data = validate_result ).

    CATCH cx_root INTO DATA(lx_root).
      " always return JSON error object to frontend
      DATA(ls_err) = VALUE tt_validate_result( message = lx_root->get_text( )
*       mfgorder = '' operation = '' confirmation = ''
       ).
      message = /ui2/cl_json=>serialize( data = ls_err ).
  ENDTRY.

  ENDMETHOD.


  METHOD validate.


    DATA: mfgorder             TYPE aufnr,
          mfgorderoperation    TYPE c LENGTH 4,
          MfgOrderConfirmation TYPE string.



    mfgorder = filled_details-ManufacturingOrder.
    mfgorderoperation = filled_details-Operation.
    MfgOrderConfirmation = COND #( WHEN strlen( filled_details-confirmation ) > 8 THEN filled_details-confirmation+2(*)
                                 ELSE filled_details-confirmation    )
     .

    TRY.

        CLEAR result.
        result-mfgorder  = mfgorder.
        result-operation = mfgorderoperation.
        result-confirmation = MfgOrderConfirmation.

        SELECT SINGLE FROM I_FailedGoodsMovementitem AS b
              FIELDS
*          b~MfgOrderConfirmation,
                     b~failedgoodsmovement,
                     b~failedgoodsmovementitem,
                     b~erroroccurrencedate,
                     b~plant,
                     b~storagelocation,
                     b~orderid,
                     b~confirmationgroup,
                     b~postingdate
              WHERE OrderID = @mfgorder
*            AND ManufacturingOrderOperation_2 = @mfgorderoperation
                AND b~ConfirmationCount = @MfgOrderConfirmation
              INTO @DATA(mfg_order_confirmation).

************************* Check for stuck COGI orders*

        IF mfg_order_confirmation-ConfirmationGroup IS NOT INITIAL AND
           mfg_order_confirmation-failedgoodsmovement IS NOT INITIAL.
          result-message = |Information: There are failed goods movements for manufacturing order { mfgorder } and operation { mfgorderoperation }. Please check COGI for details.|.
          RETURN.
        ENDIF.
      CATCH cx_root INTO DATA(lx_root).
        result-message = |General Error: { lx_root->get_text( ) }|.
    ENDTRY.
**************************************************************

  ENDMETHOD.


METHOD convertISTSeparate.

      DATA: timestamp   TYPE timestampl,
            timestp_str TYPE string.
      timestamp = sdate && stime.

      CALL METHOD cl_abap_tstmp=>add
        EXPORTING
          tstmp   = timestamp
          secs    = 19800 " 5 hours 30 minutes in seconds
        RECEIVING
          r_tstmp = timestamp.

      timestp_str = timestamp.

      idate = timestp_str+0(8). " Extracting date part
    ENDMETHOD.
ENDCLASS.
