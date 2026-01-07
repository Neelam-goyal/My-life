CLASS zcl_delivery_return DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  INTERFACES if_apj_dt_exec_object .
  INTERFACES if_apj_rt_exec_object .
  INTERFACES if_oo_adt_classrun.
  CLASS-METHODS returndeliveryorder.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DELIVERY_RETURN IMPLEMENTATION.


      METHOD if_apj_dt_exec_object~get_parameters.

      ENDMETHOD.


      METHOD if_apj_rt_exec_object~execute.

          returndeliveryorder(  ).

      ENDMETHOD.


      METHOD if_oo_adt_classrun~main.

         returndeliveryorder(  ).

      ENDMETHOD.


  METHOD returndeliveryorder.
    DATA : lv_del  TYPE string,
           lv_msg2 TYPE string,
           lv_msg3 TYPE string.
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
    DATA : error_exist type i value 0.
    DATA : check TYPE c LENGTH 1.
    DATA : orderamt TYPE p LENGTH 15 DECIMALS 2.

    SELECT SINGLE FROM zintegration_tab AS a
       FIELDS a~intgmodule,a~intgpath
       WHERE a~intgmodule = 'UNSOLDFILTER'
       INTO @DATA(wa_integration1).


    IF wa_integration1-intgmodule = 'UNSOLDFILTER' AND wa_integration1-intgpath IS NOT INITIAL AND wa_integration1 IS NOT INITIAL.
      check = '1'.
    ENDIF.

    DATA : it_head TYPE TABLE OF zdt_usdatamst1.

    IF check = '1'.
      SELECT a~*
        FROM zdt_usdatamst1 AS a
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
      SELECT a~*
        FROM zdt_usdatamst1 AS a
       WHERE a~reference_doc IS NOT INITIAL
         AND a~reference_doc_del IS INITIAL
        INTO TABLE @it_head.
    ENDIF.

    LOOP AT it_head INTO DATA(wa_head).
      IF wa_head-reference_doc_del IS INITIAL.

        SELECT SINGLE FROM I_DeliveryDocumentItem AS a FIELDS a~DeliveryDocument
        WHERE a~ReferenceSDDocument = @wa_head-reference_doc AND a~DeliveryDocument IS NOT INITIAL
        INTO  @DATA(lv_delivery).

        IF lv_delivery IS NOT INITIAL.
          UPDATE zdt_usdatamst1 SET
          reference_doc_del = @lv_delivery,
          status = 'Delivery Created'
          WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
          CLEAR: lv_delivery.

        ELSE.
          "Check Order and Data Amount
        orderamt = 0.
        SELECT SINGLE FROM I_CustomerReturnItem AS a
           FIELDS SUM( a~netamount + a~taxamount ) AS amt
           WHERE a~CustomerReturn = @wa_head-reference_doc
           INTO @orderamt.

        orderamt = round( val = orderamt
                          dec = 0 ) .

        IF wa_head-imnetamtro <> orderamt.
            wa_head-error_log = |Amount Mismatch in Order { orderamt } and Integration Data { wa_head-imnetamtro }|.
            wa_head-datavalidated = 2.
            wa_head-status = 'Order value issue'.
            MODIFY zdt_usdatamst1 FROM @wa_head.
            CONTINUE.
        elseif wa_head-imnetamtro = orderamt.
            wa_head-datavalidated = 1.
            MODIFY zdt_usdatamst1 FROM @wa_head.
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
               deliverydocumenttype = if_abap_behv=>mk-on )
               shippingpoint = wa_head-plant
               deliveryselectiondate = lv_date
               deliverydocumenttype = 'LR'
               _referencesddocumentitem = VALUE #(
                  ( %control = VALUE #(
                  referencesddocument = if_abap_behv=>mk-on
                  )
                  referencesddocument = wa_head-reference_doc
               ) ) ) ) )
               MAPPED DATA(ls_mapped2)
               REPORTED DATA(ls_reported_modify2)
               FAILED DATA(ls_failed_modify2).

          DATA: ls_temporary_key TYPE i_outbounddeliverytp-OutboundDelivery.

          COMMIT ENTITIES BEGIN
          RESPONSE OF i_outbounddeliverytp
          FAILED DATA(ls_failed_save)
          REPORTED DATA(ls_reported_save).
          COMMIT ENTITIES END.

*        CONVERT KEY OF i_outbounddeliverytp FROM ls_temporary_key TO DATA(ls_final_key).
          IF ls_failed_save IS INITIAL.
            SELECT SINGLE FROM I_DeliveryDocumentItem AS a FIELDS a~DeliveryDocument
            WHERE a~ReferenceSDDocument = @wa_head-reference_doc AND a~DeliveryDocument IS NOT INITIAL
            INTO  @DATA(delivery_no).

            IF delivery_no IS NOT INITIAL.
              UPDATE zdt_usdatamst1 SET
              reference_doc_del = @delivery_no,
              status = 'Delivery Created'
              WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
              CLEAR: lv_delivery.
            ENDIF.
            ELSE.
                lv_msg3 = ls_reported_save-outbounddelivery[ 1 ]-%msg->if_message~get_longtext(  ).
                lv_msg2 = ls_reported_modify2-outbounddelivery[ 1 ]-%msg->if_message~get_longtext(  ).
                update zdt_usdatamst1 set status = 'Delivery Creation Failed' , error_log = @lv_msg3  where imno = @wa_head-imno and comp_code = @wa_head-comp_code and plant = @wa_head-plant and imfyear = @wa_head-imfyear and imtype = @wa_head-imtype.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_head, lv_del.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
