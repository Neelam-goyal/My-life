CLASS zdelivery_cycle DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun.

    METHODS createdeliveryorder.

    METHODS convertISTSeparate
      IMPORTING
        sdate        TYPE d
        stime        TYPE t
      EXPORTING
        VALUE(idate) TYPE d
        VALUE(itime) TYPE t.


PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDELIVERY_CYCLE IMPLEMENTATION.


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
    itime = timestp_str+8(6). " Extracting time part
  ENDMETHOD.


  METHOD createdeliveryorder.
    DATA : lv_del  TYPE string,
           lv_msg2 TYPE string,
           lv_msg3 TYPE string.
    DATA : error_exist type i value 0.
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_time) = cl_abap_context_info=>get_system_time( ).

*    get IST date and time for insertion
    CALL METHOD convertISTSeparate
      EXPORTING
        sdate = lv_date
        stime = lv_time
      IMPORTING
        idate = DATA(lv_date_ist)
        itime = DATA(lv_time_ist).


    DATA : check TYPE c LENGTH 1.
    DATA orderamt TYPE p LENGTH 15 DECIMALS 2.

    check = ''.
    SELECT SINGLE FROM zintegration_tab AS a
        FIELDS a~intgmodule,a~intgpath
        WHERE a~intgmodule = 'SALESFILTER'
        INTO @DATA(wa_integration).
    IF wa_integration IS NOT INITIAL.
      check = wa_integration-intgpath.
    ENDIF.

    DATA : it_head TYPE TABLE OF zinv_mst.

    IF check = '1'.
      SELECT a~*
        FROM zinv_mst AS a
        INNER JOIN zinv_mst_filter AS b
        ON a~comp_code  = b~comp_code
        AND a~plant      = b~plant
        AND a~imfyear    = b~imfyear
        AND a~imtype     = b~imtype
        AND a~imno       = b~imno
        WHERE a~reference_doc IS NOT INITIAL
        AND a~reference_doc_del IS INITIAL
        INTO TABLE @it_head.
    ELSE.
      SELECT *
        FROM zinv_mst AS a
        WHERE a~reference_doc IS NOT INITIAL
        AND a~reference_doc_del IS INITIAL
        INTO TABLE @it_head.
    ENDIF.
    LOOP AT it_head INTO DATA(wa_head).
      SELECT SINGLE FROM i_deliverydocumentitem AS a FIELDS a~deliverydocument
      WHERE a~referencesddocument = @wa_head-reference_doc AND a~deliverydocument IS NOT INITIAL
      INTO  @DATA(lv_delivery).
      IF lv_delivery IS NOT INITIAL.
        UPDATE zinv_mst SET
        reference_doc_del = @lv_delivery,
        status = 'Delivery Created'
        WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
        CLEAR: lv_delivery.

      ELSE.
        "Check Order and Data Amount
        orderamt = 0.
        SELECT SINGLE FROM i_salesorderitem AS a
           FIELDS SUM( a~netamount + a~taxamount ) AS amt
           WHERE a~salesorder = @wa_head-reference_doc
           INTO @orderamt.
        orderamt = round( val = orderamt
                          dec = 0 ) .
        IF wa_head-imnetamtro <> orderamt.
          IF wa_head-imtype = 'D'.
            DATA(result) =  zcl_salesapitax=>callapi( salesorder = wa_head-reference_doc ).
            IF result NE 'Success'.
              wa_head-error_log = |Amount Mismatch in Order { orderamt } and Integration Data { wa_head-imnetamtro }|.
              wa_head-datavalidated = 2.
              wa_head-status = 'Order value issue'.
              MODIFY zinv_mst FROM @wa_head.
              CONTINUE.
            ENDIF.
          ELSE.
            wa_head-error_log = |Amount Mismatch in Order { orderamt } and Integration Data { wa_head-imnetamtro }|.
            wa_head-datavalidated = 2.
            wa_head-status = 'Order value issue'.
            MODIFY zinv_mst FROM @wa_head.
            CONTINUE.
          ENDIF.
        ENDIF.

        select from I_salesdocumentitem as a
        fields a~OrderQuantity,a~ConfdDelivQtyInOrderQtyUnit,a~SalesDocument,a~Material
        where a~SalesDocument = @wa_head-reference_doc and a~OrderQuantity <> a~ConfdDelivQtyInOrderQtyUnit
        into table @data(stock_check).


        if stock_check is NOT INITIAL.
           error_exist = 1.
           wa_head-error_log = |Quantity not confirmed|.
           wa_head-status = 'Quantity confirmation issue '.
           MODIFY zinv_mst FROM @wa_head.
           CONTINUE.
        ENDIF.

        IF error_exist = 0.
           wa_head-error_log = ''.
           wa_head-status = ''.
           wa_head-datavalidated = 1.
           MODIFY zinv_mst FROM @wa_head.
        ENDIF.

        MODIFY ENTITIES OF i_outbounddeliverytp
             ENTITY outbounddelivery
             EXECUTE createdlvfromsalesdocument
             FROM VALUE #(
             ( %cid = 'DLV001'
             %param = VALUE #(
             %control = VALUE #(
                 shippingpoint = if_abap_behv=>mk-on
                 deliveryselectiondate = if_abap_behv=>mk-on
                 deliverydocumenttype = if_abap_behv=>mk-on
             )
             shippingpoint = wa_head-plant
             deliveryselectiondate = lv_date_ist
*            Cannot make Imdate because backdate orders also getting pushed and delivery schedukle automatically changed to current date
*             deliveryselectiondate = wa_head-imdate
*             deliveryselectiondate = lv_date
             deliverydocumenttype = 'LF'
             _referencesddocumentitem = VALUE #(
                ( %control = VALUE #(
                    referencesddocument = if_abap_behv=>mk-on
                )
                    referencesddocument = wa_head-reference_doc
             ) ) ) ) )
             MAPPED DATA(ls_mapped2)
             REPORTED DATA(ls_reported_modify2)
             FAILED DATA(ls_failed_modify2).

        DATA: ls_temporary_key TYPE i_outbounddeliverytp-outbounddelivery.

        COMMIT ENTITIES BEGIN
        RESPONSE OF i_outbounddeliverytp
        FAILED DATA(ls_failed_save)
        REPORTED DATA(ls_reported_save).
        COMMIT ENTITIES END.

        IF ls_failed_save IS INITIAL.
          SELECT SINGLE FROM i_deliverydocumentitem AS a FIELDS a~deliverydocument
          WHERE a~referencesddocument = @wa_head-reference_doc AND a~deliverydocument IS NOT INITIAL
          INTO  @DATA(delivery_num).
          IF delivery_num IS NOT INITIAL.
            UPDATE zinv_mst SET
             reference_doc_del = @delivery_num,
             status = 'Delivery Created'
             WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
            CLEAR: delivery_num.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_head, lv_del,stock_check.
      error_exist = 0.
    ENDLOOP.

  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    createdeliveryorder(  ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    createdeliveryorder(  ).
  ENDMETHOD.
ENDCLASS.
