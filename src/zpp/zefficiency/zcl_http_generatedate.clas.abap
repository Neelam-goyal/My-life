class ZCL_HTTP_GENERATEDATE definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_GENERATEDATE IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA req_host TYPE string.
    DATA req_proto TYPE string.
    DATA json TYPE string .
    DATA : wa_final TYPE zproduction_mst.

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    IF req_proto IS INITIAL.
      req_proto = 'https'.

    ENDIF.

    DATA(plant) = VALUE #( req[ name = 'plant' ]-value OPTIONAL ).
    DATA(workCenter) = request->get_form_field( `workCenter` ).
    DATA(shift) = request->get_form_field( `shift` ).
    DATA(fromdate) = VALUE #( req[ name = 'fromdate' ]-value OPTIONAL ).
    DATA(todate) = VALUE #( req[ name = 'todate' ]-value OPTIONAL ).

    IF plant IS INITIAL OR fromdate IS INITIAL OR todate IS INITIAL.
      response->set_text( 'Error: Plant or Fromdate or Todate fields are not initialized.' ).
      RETURN.
    ENDIF.

    IF todate IS INITIAL.
      todate = cl_abap_context_info=>get_system_date( ).
    ENDIF.

    SELECT SINGLE FROM ztable_plant
    FIELDS plant_code
    WHERE plant_code = @plant
    INTO @DATA(plant_data).

    IF plant_data IS INITIAL .
      response->set_text( 'Error: Plz Write a Correct Plant' ).
      RETURN.
    ENDIF.

   IF workcenter IS INITIAL AND shift IS INITIAL.
  SELECT FROM I_MfgOrderConfirmation AS a
    LEFT JOIN i_workcenter AS wc ON a~WorkCenterInternalID = wc~WorkCenterInternalID
    FIELDS a~PostingDate,
           a~OrderConfirmationType,
           wc~WorkCenter,
           a~ShiftDefinition,
           a~Plant
    WHERE a~Plant = @plant
      AND a~PostingDate >= @fromdate
      AND a~PostingDate <= @todate
      AND a~IsReversal IS INITIAL
      AND a~IsReversed IS INITIAL
    INTO TABLE @DATA(order_confirmations).

ELSEIF workcenter IS NOT INITIAL AND shift IS INITIAL.
  SELECT FROM I_MfgOrderConfirmation AS a
    LEFT JOIN i_workcenter AS wc ON a~WorkCenterInternalID = wc~WorkCenterInternalID
    FIELDS a~PostingDate,
           a~OrderConfirmationType,
           wc~WorkCenter,
           a~ShiftDefinition,
           a~Plant
    WHERE a~Plant = @plant
      AND a~PostingDate >= @fromdate
      AND a~PostingDate <= @todate
      AND wc~WorkCenter = @workCenter
      AND a~IsReversal IS INITIAL
      AND a~IsReversed IS INITIAL
    INTO TABLE @order_confirmations.

ELSEIF workcenter IS INITIAL AND shift IS NOT INITIAL.

  SELECT FROM I_MfgOrderConfirmation AS a
    LEFT JOIN i_workcenter AS wc ON a~WorkCenterInternalID = wc~WorkCenterInternalID
    FIELDS a~PostingDate,
           a~OrderConfirmationType,
           wc~WorkCenter,
           a~ShiftDefinition,
           a~Plant
    WHERE a~Plant = @plant
      AND a~PostingDate >= @fromdate
      AND a~PostingDate <= @todate
      AND a~ShiftDefinition = @shift
      AND a~IsReversal IS INITIAL
      AND a~IsReversed IS INITIAL
    INTO TABLE @order_confirmations.

ELSE.

  SELECT FROM I_MfgOrderConfirmation AS a
    LEFT JOIN i_workcenter AS wc ON a~WorkCenterInternalID = wc~WorkCenterInternalID
    FIELDS a~PostingDate,
           a~OrderConfirmationType,
           wc~WorkCenter,
           a~ShiftDefinition,
           a~Plant
    WHERE a~Plant = @plant
      AND a~PostingDate >= @fromdate
      AND a~PostingDate <= @todate
      AND wc~WorkCenter = @workCenter
      AND a~ShiftDefinition = @shift
      AND a~IsReversal IS INITIAL
      AND a~IsReversed IS INITIAL
    INTO TABLE @order_confirmations.

ENDIF.

    IF order_confirmations IS NOT INITIAL.
      LOOP AT order_confirmations INTO DATA(wa_order).
        wa_final-posting_date = wa_order-PostingDate.
        wa_final-work_center = wa_order-WorkCenter.
        wa_final-order_type = wa_order-OrderConfirmationType.
        IF wa_order-ShiftDefinition = '1'.
          wa_final-shift = 'DAY'.
        ELSEIF wa_order-ShiftDefinition = '2'.
          wa_final-shift = 'NIGHT'.
        ENDIF.
        wa_final-plant = wa_order-Plant.
        MODIFY zproduction_mst FROM @wa_final.
        CLEAR : wa_order,wa_final.
      ENDLOOP.

*      sort zproduction_mst by posting_date work_center order_type shift plant.

      response->set_text( 'Generated Data Successfully.' ).
      RETURN.
    ELSE.
      response->set_text( 'Error: No Data Found in Standard CDS With Given Details.' ).
      RETURN.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
