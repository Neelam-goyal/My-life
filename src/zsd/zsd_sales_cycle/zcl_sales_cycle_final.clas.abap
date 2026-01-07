CLASS zcl_sales_cycle_final DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun.
    class-METHODS createSO.
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_SALES_CYCLE_FINAL IMPLEMENTATION.


  METHOD createSO.


    DATA : lv_del  TYPE string,
           lv_msg2 TYPE string,
           lv_msg3 TYPE string.
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
    DATA Amt TYPE p LENGTH 15 DECIMALS 2.
    DATA: elog   TYPE string, result TYPE String.

    DATA : lv_item_cid   TYPE string.
*  *******************************SALES ORDER CODE BEGIN**********************************************
    DATA : check TYPE c LENGTH 1.
    DATA : it_head TYPE TABLE OF zinv_mst.
    DATA : roundoffproduct TYPE c LENGTH 40.

*    select from zintegration_tab as a
*        fields a~intgmodule,a~intgpath
*        where a~intgmodule is not INITIAL
*        into table @data(it_integration).

*    loop at it_integration into data(wa_integration).
*        if wa_integration-intgmodule = 'SALESFILTER' and wa_integration-intgpath is not INITIAL.
*            check = '1'.
*        endif.
*    ENDLOOP.

    SELECT SINGLE FROM zintegration_tab AS a
        FIELDS a~intgmodule,a~intgpath
        WHERE a~intgmodule = 'SALESFILTER'
        INTO @DATA(wa_integration1).

    IF wa_integration1-intgmodule = 'SALESFILTER' AND wa_integration1-intgpath IS NOT INITIAL AND wa_integration1 IS NOT INITIAL.
      check = '1'.
    ENDIF.

    SELECT SINGLE FROM zintegration_tab AS a
        FIELDS a~intgmodule,a~intgpath
        WHERE a~intgmodule = 'ROUNDOFFSALES'
        INTO @DATA(wa_integration2).

    IF wa_integration2-intgmodule = 'ROUNDOFFSALES' AND wa_integration2 IS NOT INITIAL.
      roundoffproduct = wa_integration2-intgpath.
    ENDIF.


    DATA lv_vbeln TYPE string.

    IF check = '1'.
    SELECT a~*
      FROM zinv_mst AS a
      INNER JOIN zinv_mst_filter AS b
        ON a~comp_code  = b~comp_code
       AND a~plant      = b~plant
       AND a~imfyear    = b~imfyear
       AND a~imtype     = b~imtype
       AND a~imno       = b~imno
      WHERE ( a~datavalidated = 1 AND a~reference_doc     IS INITIAL
                                    AND a~reference_doc_del IS INITIAL )
         OR ( a~datavalidated = 2 AND a~reference_doc     IS NOT INITIAL
                                    AND a~reference_doc_del IS INITIAL )
      ORDER BY a~comp_code, a~plant, a~imfyear, a~imtype, a~imno
      INTO TABLE @it_head.

    ELSE.
    SELECT a~*
      FROM zinv_mst AS a
      WHERE ( a~datavalidated = 1 AND a~reference_doc IS INITIAL AND a~reference_doc_del IS INITIAL )
        OR ( a~datavalidated = 2 AND a~reference_doc IS NOT INITIAL AND a~reference_doc_del IS INITIAL )
      ORDER BY a~comp_code, a~plant, a~imfyear, a~imtype, a~imno
      INTO TABLE @it_head.
    ENDIF.


    LOOP AT it_head INTO DATA(wa_head).
      CLEAR : elog, result.
      DATA : custref TYPE string.

      CONCATENATE  wa_head-plant wa_head-imfyear wa_head-imtype wa_head-imno INTO custref SEPARATED BY '-'.

      SELECT SINGLE FROM I_salesOrder AS a
      FIELDS a~SalesOrder
      WHERE a~SoldToParty = @wa_head-cust_code AND a~SalesOrderDate = @wa_head-imdate AND a~PurchaseOrderByCustomer = @custref
      INTO @DATA(wa_salesorderid).

      DATA : mat_false TYPE i VALUE 0.

      IF wa_salesorderid IS NOT INITIAL.

        SELECT SINGLE FROM i_salesorderITEM AS a
           FIELDS SUM( a~NetAmount + a~TaxAmount ) AS Amt
           WHERE a~SalesOrder = @wa_salesorderid
           INTO @Amt.

        IF wa_head-imtype = 'D'.
          result =  zcl_salesapitax=>callapi( salesorder = wa_salesorderid ).
          IF result NE 'Success'.
            elog = result.
          ENDIF.
        ENDIF.

        UPDATE zinv_mst SET
            processed = 'X',
            reference_doc = @wa_salesorderid ,
            orderamount = @Amt,
            status = 'Sales Order Created',
            error_log = @elog,
            po_tobe_created = @wa_head-po_tobe_created
        WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
        CLEAR: wa_salesorderid.
      ELSE.

        SELECT
        FROM zinvoicedatatab1 AS a
        FIELDS SUM( a~idprdamt ) AS lineamount, MAX( a~idaid ) AS srno
        WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~idfyear = @wa_head-imfyear AND  a~idtype = @wa_head-imtype
            AND a~idno = @wa_head-imno
        INTO TABLE @DATA(it_datasum).

        LOOP AT it_datasum INTO DATA(wa_datasum).
          DATA : lv_roundamount TYPE p DECIMALS 2.
*          lv_roundamount = wa_head-imnetamtro - wa_datasum-lineamount .
           lv_roundamount = wa_head-imnetamtro - wa_head-imnetamt.
           SELECT SINGLE FROM zinvoicedatatab1
           fields idprdcode,idno,idfyear,comp_code,plant
              WHERE comp_code = @wa_head-comp_code
                AND plant     = @wa_head-plant
                AND idfyear   = @wa_head-imfyear
                AND idtype    = @wa_head-imtype
                AND idno      = @wa_head-imno
                AND idprdcode = @roundoffproduct
              INTO @DATA(lv_existing).

          IF lv_roundamount <> 0 and lv_existing is INITIAL.

            DATA: wa_new_row TYPE zinvoicedatatab1.
            CLEAR wa_new_row.

            wa_new_row-comp_code      = wa_head-comp_code.
            wa_new_row-plant          = wa_head-plant.
            wa_new_row-idfyear        = wa_head-imfyear.
            wa_new_row-idtype         = wa_head-imtype.
            wa_new_row-idno           = wa_head-imno.
            wa_new_row-idaid          = wa_datasum-srno + 1.
            wa_new_row-idprdrate      = lv_roundamount.
            wa_new_row-idtotaldiscamt = 0.
            wa_new_row-idid           = 0.
            wa_new_row-idcat          = ''.
            wa_new_row-idnoseries     = ''.
            wa_new_row-iddate         = lv_date.
            wa_new_row-idpartycode    = wa_head-impartycode.
            wa_new_row-idroutecode    = ''.
            wa_new_row-idsalesmancode = ''.
            wa_new_row-iddealercode   = ''.
            wa_new_row-idprdcode      = roundoffproduct.
            wa_new_row-idprdasgncode  = roundoffproduct.
            wa_new_row-idqtybag       = 0.
            wa_new_row-idprdqty       = 1.
            wa_new_row-idprdqtyf      = 0.
            wa_new_row-idprdqtyr      = 0.
            wa_new_row-idprdqtyw      = 0.
            wa_new_row-idprdnrate     = 0.
            wa_new_row-iddiscrate     = 0.
            wa_new_row-idprdamt       = lv_roundamount.
            wa_new_row-idprdnamt      = lv_roundamount.
            wa_new_row-idremarks      = ''.
            wa_new_row-iduserid       = ''.
            wa_new_row-iddfdt         = ''.
            wa_new_row-iddudt         = ''.
            wa_new_row-iddelttag      = ''.
            wa_new_row-idprdacode     = ''.
            wa_new_row-idnar          = ''.
            wa_new_row-idreprate      = 0.
            wa_new_row-idwsb1         = 0.
            wa_new_row-idwsb2         = 0.
            wa_new_row-idrdc1         = 0.
            wa_new_row-idwsb3         = 0.
            wa_new_row-idrdc2         = 0.
            wa_new_row-idtxbamt       = 0.
            wa_new_row-idsono         = ''.
            wa_new_row-idsodate       = '00000000'.
            wa_new_row-idtdiscrate    = 0.
            wa_new_row-idtdiscamt     = 0.
            wa_new_row-idorderno      = ''.
            wa_new_row-idorderdate    = '00000000'.
            wa_new_row-idplantrunhrs  = 0.
            wa_new_row-idprdbatch     = ''.
            wa_new_row-idreprate1     = 0.
            wa_new_row-idddealercode  = ''.
            wa_new_row-idcgstrate     = 0.
            wa_new_row-idsgstrate     = 0.
            wa_new_row-idigstrate     = 0.
            wa_new_row-idcgstamount   = 0.
            wa_new_row-idsgstamount   = 0.
            wa_new_row-idigstamount   = 0.
            wa_new_row-idprdhsncode   = ''.
            wa_new_row-idprdqtyss     = 0.
            wa_new_row-idssamount     = 0.
            wa_new_row-idssrate       = 0.
            wa_new_row-imsdtag        = ''.
            wa_new_row-idforqty       = 0.
            wa_new_row-idfreeqty      = 0.
            wa_new_row-idonbillos     = 0.
            wa_new_row-idoffbillos    = 0.
            wa_new_row-idoffbillcrdo  = 0.
            wa_new_row-idtgtqty       = 0.
            wa_new_row-idmrp          = 0.
            wa_new_row-idver          = 0.
            wa_new_row-idprdstock     = 0.
            wa_new_row-idprdcodefree  = ''.
            wa_new_row-idrepldiscamt  = 0.
            wa_new_row-idvehcodesale  = ''.
            wa_new_row-error_log      = ''.
            wa_new_row-remarks        = ''.
            wa_new_row-processed      = ''.
            wa_new_row-reference_doc  = ''.

            INSERT INTO zinvoicedatatab1 VALUES @wa_new_row.

          ENDIF.
          clear : wa_datasum,lv_existing,lv_roundamount.
        ENDLOOP.

        CLEAR: it_datasum.

        SELECT a~idqtybag, a~remarks, a~idcat, a~idid, a~idno, a~idpartycode, a~idprdcode, a~idprdqty,a~idprdrate,a~idprdqtyf,
            a~idtdiscamt,a~idprdbatch,a~idtotaldiscamt,a~idcgstrate,a~idcgstamount,a~idsgstrate,a~idsgstamount,a~idigstrate,a~idigstamount,
            a~IdTcsAmt , CASE
            WHEN a~idprdrate = 0 THEN 'CBXN'  " Replace with your other value
            END AS salesitemcategory
            FROM zinvoicedatatab1 AS a
            WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~idfyear = @wa_head-imfyear AND  a~idtype = @wa_head-imtype
            AND a~idno = @wa_head-imno
            INTO TABLE @DATA(it_data).


        DATA: var_sales_org TYPE string,
              var_org_div   TYPE string,
              party_code    TYPE string,
              mycid         TYPE string,
              storage       TYPE string.

        var_sales_org = wa_head-comp_code(2) && '00'.

        DATA : var_dist TYPE string.

*        IF wa_head-scrapbill = 'N'.
*           var_dist = 'GT'.
*           var_org_div = 'B1'.
*           storage = ''.
*        ELSEIF wa_head-scrapbill = 'Y'.
*          var_dist = 'SS'.
*          var_org_div = 'S1'.
*          storage = 'SC01'.
*        ENDIF.
*************changes 12/8****************
         IF wa_head-scrapbill = 'SS'.
           var_dist = 'SS'.
           var_org_div = 'S1'.
           storage = 'SC01'.
        elseif wa_head-scrapbill = 'OS'.
           var_dist = 'OS'.
           var_org_div = 'R2'.
           Storage = 'RS01'.
        ELSE.
          var_dist = wa_head-scrapbill.
          var_org_div = 'B1'.
          storage = ''.
        ENDIF.
******************************************
        party_code = wa_head-cust_code.

        DATA : final_rate TYPE p DECIMALS 2.
        LOOP AT it_data INTO DATA(wa_rate).
          wa_rate-idprdqty = wa_rate-idprdqty + wa_rate-idprdqtyf.
          wa_rate-idprdrate = ( wa_rate-idprdrate - ( wa_rate-idtotaldiscamt / wa_rate-idprdqty ) ) * 1000.
*          wa_rate-IdTcsAmt = ( wa_rate-IdTcsAmt / wa_rate-idprdqty ) * wa_rate-idprdqty.
           if wa_rate-idprdrate is initial or wa_rate-idprdrate = 0.
           wa_rate-salesitemcategory = 'CBXN'.
           ENDIF..
          MODIFY it_data FROM wa_rate.
        ENDLOOP.

*************************Order Reason***********************************

    data : order_reason type c length 3.

    if wa_head-order_reason = 'Z1'.
      order_reason = 'Z1'.
    elseif  wa_head-order_reason = 'Z2'.
      order_reason = 'Z2'.
    else.
      order_reason = ''.
    endif.


***********************************************************************************************************

        IF wa_head-reference_doc IS INITIAL AND mat_false = 0.
          IF var_dist ne 'SS'.
          mycid = |H001{ custref }|.
          MODIFY ENTITIES OF i_salesordertp
             ENTITY salesorder
             CREATE
             FIELDS ( salesordertype
                    salesorganization distributionchannel organizationdivision
                      soldtoparty purchaseorderbycustomer CustomerPaymentTerms SalesOrderDate RequestedDeliveryDate PricingDate CustomerPurchaseOrderDate
                      SDDocumentReason )
             WITH VALUE #( ( %cid = mycid
                             %data = VALUE #(      salesordertype = 'TA'
                                                   salesorganization = var_sales_org
                                                   distributionchannel = var_dist
                                                   organizationdivision = var_org_div
                                                   soldtoparty = |{ party_code ALPHA = IN }|
                                                   purchaseorderbycustomer = custref
                                                   CustomerPurchaseOrderDate = wa_head-imdate
                                                   SalesOrderDate = wa_head-imdate
                                                   RequestedDeliveryDate = wa_head-imdate
                                                   PricingDate = wa_head-imdate
                                                   CustomerPaymentTerms = '0001'
                                                   SDDocumentReason = order_reason
                                               ) ) )


          CREATE BY \_item
          FIELDS ( Product RequestedQuantity SalesOrderItemCategory Plant YY1_Discount_amt_sd_SDI YY1_Discount_amt_sd_SDIC batch StorageLocation )
          WITH VALUE #( ( %cid_ref = mycid
                       salesorder = space
                       %target = VALUE #( FOR wa_data IN it_data INDEX INTO i (
                         %cid =  |I{ i WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                         product =  wa_data-idprdcode
                         requestedquantity =  wa_data-idprdqty
                         SalesOrderItemCategory = wa_data-salesitemcategory
                         plant = wa_head-plant
                         YY1_Discount_amt_sd_SDI = wa_data-idtotaldiscamt
                         YY1_Discount_amt_sd_SDIC = 'INR'
                         batch = wa_data-idprdbatch
                         StorageLocation = storage
                        ) ) ) )

          ENTITY SalesOrderItem
            CREATE BY \_itempricingelement
            FIELDS ( conditiontype conditionrateamount conditioncurrency conditionquantity )
            WITH VALUE #(
             FOR wa_data1 IN it_data INDEX INTO j
             (
               %cid_ref = |I{ j WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
               salesorder = space
               salesorderitem = space
               %target = VALUE #(
               ( %cid = |ITPRELM{ j }_01|
                   conditiontype = 'ZBNP'
                   conditionrateamount = wa_data1-idprdrate
                   conditioncurrency = 'INR'
                   conditionquantity = 1000
                 )
               )
             )
           )

         MAPPED DATA(ls_mapped)
         FAILED DATA(ls_failed)
         REPORTED DATA(ls_reported).


          ELSEIF var_dist = 'SS'.
             mycid = |H001{ custref }|.
          MODIFY ENTITIES OF i_salesordertp
             ENTITY salesorder
             CREATE
             FIELDS ( salesordertype
                    salesorganization distributionchannel organizationdivision
                      soldtoparty purchaseorderbycustomer CustomerPaymentTerms SalesOrderDate RequestedDeliveryDate PricingDate CustomerPurchaseOrderDate
                      SDDocumentReason )
             WITH VALUE #( ( %cid = mycid
                             %data = VALUE #(      salesordertype = 'TA'
                                                   salesorganization = var_sales_org
                                                   distributionchannel = var_dist
                                                   organizationdivision = var_org_div
                                                   soldtoparty = |{ party_code ALPHA = IN }|
                                                   purchaseorderbycustomer = custref
                                                   CustomerPurchaseOrderDate = wa_head-imdate
                                                   SalesOrderDate = wa_head-imdate
                                                   RequestedDeliveryDate = wa_head-imdate
                                                   PricingDate = wa_head-imdate
                                                   CustomerPaymentTerms = '0001'
                                                   SDDocumentReason = order_reason
                                               ) ) )


          CREATE BY \_item
          FIELDS ( Product RequestedQuantity Plant YY1_Discount_amt_sd_SDI YY1_Discount_amt_sd_SDIC batch StorageLocation )
          WITH VALUE #( ( %cid_ref = mycid
                       salesorder = space
                       %target = VALUE #( FOR wa_data IN it_data INDEX INTO i (
                         %cid =  |I{ i WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                         product =  wa_data-idprdcode
                         requestedquantity =  wa_data-idprdqty
                         plant = wa_head-plant
                         YY1_Discount_amt_sd_SDI = wa_data-idtotaldiscamt
                         YY1_Discount_amt_sd_SDIC = 'INR'
                         batch = wa_data-idprdbatch
                         StorageLocation = storage
                        ) ) ) )

          ENTITY SalesOrderItem
            CREATE BY \_itempricingelement
            FIELDS ( conditiontype conditionrateamount conditioncurrency conditionquantity  ConditionQuantityUnit )
            WITH VALUE #(
             FOR wa_data1 IN it_data INDEX INTO j
             (
               %cid_ref = |I{ j WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
               salesorder = space
               salesorderitem = space
               %target = VALUE #(
               ( %cid = |ITPRELM{ j }_01|
                   conditiontype = 'ZBNP'
                   conditionrateamount = wa_data1-idprdrate
                   conditioncurrency = 'INR'
                   conditionquantity = 1000
*                   ConditionQuantityUnit = 'KG'
                 )
                ( %cid = |ITPRELM{ j }_02|
                  conditiontype = 'ZSCP'
                  conditionrateamount = wa_data1-IdTcsAmt
*                  ConditionAmount = wa_data1-IdTcsAmt
                  conditioncurrency = 'INR'
                  conditionquantity = wa_data1-idprdqty
*                  ConditionQuantityUnit = 'KG'
                )
               )
             )
           )

         MAPPED DATA(ls_mapped1)
         FAILED DATA(ls_failed1)
         REPORTED DATA(ls_reported1).

       ENDIF.

          COMMIT ENTITIES BEGIN
          RESPONSE OF i_salesordertp
          FAILED DATA(ls_save_failed)
          REPORTED DATA(ls_save_reported).
          COMMIT ENTITIES END.

          IF ls_save_failed IS INITIAL.
            SELECT SINGLE FROM I_salesOrder AS a
            FIELDS a~SalesOrder
            WHERE a~SoldToParty = @wa_head-cust_code AND a~SalesOrderDate = @wa_head-imdate AND a~PurchaseOrderByCustomer = @custref
            INTO @DATA(salesorder).

            SELECT SINGLE FROM i_salesorderITEM AS a
               FIELDS SUM( a~NetAmount + a~TaxAmount ) AS Amt
               WHERE a~SalesOrder = @salesorder
               INTO @Amt.

            IF wa_head-imtype = 'D'.
              result =  zcl_salesapitax=>callapi( salesorder = salesorder ).
              IF result NE 'Success'.
                elog = result.
              ENDIF.
            ENDIF.
            IF salesorder IS NOT INITIAL.
              UPDATE zinv_mst SET
                  processed = 'X',
                  reference_doc = @salesorder ,
                  orderamount = @Amt,
                  status = 'Sales Order Created',
                  error_log = @elog,
                  po_tobe_created = @wa_head-po_tobe_created
              WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
              CLEAR: salesorder .
            ENDIF.
          ENDIF.
        ENDIF.
        CLEAR: wa_head, lv_vbeln,it_data, Amt,order_reason.
      ENDIF.
      mat_false = 0.
    ENDLOOP.


  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    createSO(  ).

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    createso(  ).

  ENDMETHOD.
ENDCLASS.
