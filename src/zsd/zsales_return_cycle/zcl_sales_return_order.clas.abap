CLASS zcl_sales_return_order DEFINITION
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



CLASS ZCL_SALES_RETURN_ORDER IMPLEMENTATION.


  METHOD createso.

    DATA : lv_del  TYPE string,
           lv_msg2 TYPE string,
           lv_msg3 TYPE string.
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).

    DATA  TotalNetAmount TYPE p LENGTH 15 DECIMALS 2.
    DATA: elog   TYPE string.

    DATA : lv_item_cid   TYPE string.
*  *******************************SALES ORDER CODE BEGIN**********************************************
    DATA : check TYPE c LENGTH 1.
    DATA : it_head TYPE TABLE OF zdt_usdatamst1.
    DATA : roundoffproduct TYPE c LENGTH 40.

    SELECT SINGLE FROM zintegration_tab AS a
        FIELDS a~intgmodule,a~intgpath
        WHERE a~intgmodule = 'UNSOLDFILTER'
        INTO @DATA(wa_integration1).


    IF wa_integration1-intgmodule = 'UNSOLDFILTER' AND wa_integration1-intgpath IS NOT INITIAL AND wa_integration1 IS NOT INITIAL.
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
          FROM zdt_usdatamst1 AS a
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
          FROM zdt_usdatamst1 AS a
                 WHERE ( a~datavalidated = 1 AND a~reference_doc IS INITIAL AND a~reference_doc_del IS INITIAL )
        OR ( a~datavalidated = 2 AND a~reference_doc IS NOT INITIAL AND a~reference_doc_del IS INITIAL )
          ORDER BY a~comp_code, a~plant, a~imfyear, a~imtype, a~imno
          INTO TABLE @it_head.
    ENDIF.



    LOOP AT it_head INTO DATA(wa_head).
     CLEAR : elog.
*           DATA(party_new) = |{ wa_head-comp_code }{ wa_head-impartycode }|.
*
*             SELECT SINGLE BusinessPartner, BusinessPartnerIDByExtSystem,d~CustomerAccountGroup
*             FROM I_BusinessPartner as c
*             LEFT JOIN I_Customer AS d ON c~BusinessPartner = d~Customer
*             WHERE BusinessPartnerIDByExtSystem = @party_new
*                INTO @DATA(wa_data_party).

      SELECT SINGLE c~businesspartner,c~BusinessPartnerIDByExtSystem,d~CustomerAccountGroup
    FROM zdt_usdatamst1 AS a
    LEFT JOIN I_BusinessPartner AS c ON a~impartycode = c~BusinessPartnerIDByExtSystem
    LEFT JOIN I_Customer AS d ON c~BusinessPartner = d~Customer
    WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~imfyear = @wa_head-imfyear AND  a~imtype = @wa_head-imtype
        AND a~imno = @wa_head-imno
    INTO  @DATA(wa_data_party).

      " Find Salesorder - soldtoparty, documentDate, Customer Referenceno
      DATA : custref TYPE string.

      CONCATENATE  wa_head-plant wa_head-imfyear wa_head-imtype 'U' wa_head-imno INTO custref SEPARATED BY '-'.

      SELECT SINGLE FROM I_CustomerReturn AS a
      FIELDS a~CustomerReturn
      WHERE a~SoldToParty = @wa_data_party-BusinessPartner AND a~CustomerReturnDate = @wa_head-imdate AND a~PurchaseOrderByCustomer = @custref
      INTO @DATA(wa_customer).

      DATA : mat_false TYPE i VALUE 0.

      IF wa_customer IS NOT INITIAL.

        SELECT SINGLE FROM I_CustomerReturnItem AS a
              FIELDS SUM( a~NetAmount + a~TaxAmount ) AS TotalNetAmount
              WHERE a~CustomerReturn = @wa_customer
              INTO @TotalNetAmount.

       if TotalNetAmount = wa_head-imnetamtro.
            UPDATE zdt_usdatamst1 SET
            processed = 'X',
            orderamount = @TotalNetAmount,
            reference_doc = @wa_customer,
            status = 'Sales Return Created',
            error_log = ''
            WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
        endif.
        CLEAR:wa_customer.
      ELSE.
*    *********************************************************************
        SELECT
          FROM zdt_usdatadata1 AS a
          FIELDS SUM( a~idprdamt ) AS lineamount, MAX( a~idaid ) AS srno
          WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~idfyear = @wa_head-imfyear AND  a~idtype = @wa_head-imtype
              AND a~idno = @wa_head-imno
          INTO TABLE @DATA(it_datasum).


        LOOP AT it_datasum INTO DATA(wa_datasum).
          DATA : lv_roundamount TYPE p DECIMALS 2.
*          lv_roundamount = wa_head-imnetamtro - wa_datasum-lineamount.
          lv_roundamount = wa_head-imnetamtro - wa_head-imnetamt.
          SELECT SINGLE FROM zdt_usdatadata1
           fields idprdcode,idno,idfyear,comp_code,plant
              WHERE comp_code = @wa_head-comp_code
                AND plant     = @wa_head-plant
                AND idfyear   = @wa_head-imfyear
                AND idtype    = @wa_head-imtype
                AND idno      = @wa_head-imno
                AND idprdcode = @roundoffproduct
              INTO @DATA(lv_existing).

          IF lv_roundamount <> 0 and lv_existing is INITIAL.

            DATA: wa_new_row TYPE zdt_usdatadata1.
            CLEAR wa_new_row.

            wa_new_row-comp_code      = wa_head-comp_code.
            wa_new_row-plant          = wa_head-plant.
            wa_new_row-idfyear        = wa_head-imfyear.
            wa_new_row-idtype         = wa_head-imtype.
            wa_new_row-idno           = wa_head-imno.
            wa_new_row-idaid          = wa_datasum-srno + 1.
            wa_new_row-idprdrate      = lv_roundamount.
            wa_new_row-idnoseries     = ''.
            wa_new_row-iddate         = wa_head-imdate.
            wa_new_row-idpartycode    = wa_head-impartycode.
            wa_new_row-idroutecode    = ''.
            wa_new_row-idsalesmancode = ''.
            wa_new_row-iddealercode   = ''.
            wa_new_row-idprdcode      = roundoffproduct.
            wa_new_row-idprdasgncode  = roundoffproduct.
            wa_new_row-idprdqty       = 1.
            wa_new_row-idprdqtyf      = 0.
            wa_new_row-idprdqtyr      = 0.
            wa_new_row-iddiscrate     = 0.
            wa_new_row-idprdamt       = lv_roundamount.
            wa_new_row-idremarks      = ''.
            wa_new_row-iduserid       = ''.
            wa_new_row-iddfdt         = '00000000'.
            wa_new_row-iddudt         = '00000000'.
            wa_new_row-idwsb1         = 0.
            wa_new_row-idwsb2         = 0.
            wa_new_row-idrdc1         = 0.
            wa_new_row-idwsb3         = 0.
            wa_new_row-idtxbamt       = 0.
            wa_new_row-idcgstrate     = 0.
            wa_new_row-idsgstrate     = 0.
            wa_new_row-idigstrate     = 0.
            wa_new_row-idcgstamount   = 0.
            wa_new_row-idsgstamount   = 0.
            wa_new_row-idigstamount   = 0.
            wa_new_row-idprdhsncode   = ''.
            wa_new_row-idforqty       = 0.
            wa_new_row-idfreeqty      = 0.
            wa_new_row-idonbillos     = 0.
            wa_new_row-idoffbillos    = 0.
            wa_new_row-idoffbillcrdo  = 0.
            wa_new_row-idtgtqty       = 0.
            wa_new_row-idver          = 0.
            wa_new_row-error_log      = ''.
            wa_new_row-remarks        = ''.
            wa_new_row-processed      = ''.
            wa_new_row-reference_doc  = ''.
            wa_new_row-idtotaldiscamount = 0.
            wa_new_row-idprdqtyc         = 0.
            wa_new_row-ztime             = '000000'.
            wa_new_row-idtxncd     = ''.
            wa_new_row-idsntag     = ''.
            wa_new_row-idprdbatch  = ''.
            wa_new_row-iddeltag    = ''.
            wa_new_row-idreplrate  = 0.
            wa_new_row-idreplrate1 = 0.
            wa_new_row-idcmpcode         = ''.
            wa_new_row-created_by        = ''.
            wa_new_row-created_at        = ''.
            wa_new_row-last_changed_by   = ''.
            wa_new_row-last_changed_at   = ''.
            wa_new_row-local_last_changed_at = ''.


            INSERT INTO zdt_usdatadata1 VALUES @wa_new_row.

          ENDIF.
           clear : wa_datasum,lv_existing,lv_roundamount.
        ENDLOOP.

        CLEAR: it_datasum.
        SELECT  a~remarks, a~idno, a~idpartycode, a~idprdcode, a~idprdqty,a~idprdrate,a~idprdqtyf,
          a~Idtotaldiscamount,a~idprdasgncode,a~idcgstrate,a~idcgstamount,a~idsgstrate,a~idsgstamount,a~idigstrate,a~idigstamount,a~idprdbatch,
          a~idtcsrate,a~idtcsamt,
          CASE
            WHEN a~idprdrate = 0 THEN 'CRXN'  " Replace with your other value
            END AS ItemCatagory
          FROM zdt_usdatadata1 AS a
          WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~idfyear = @wa_head-imfyear AND  a~idtype = @wa_head-imtype
          AND a~idno = @wa_head-imno
          INTO TABLE @DATA(it_data).

        SELECT SINGLE FROM zintegration_tab AS a
        FIELDS a~intgmodule,a~intgpath
        WHERE a~intgmodule = 'FGSTORAGELOCATION'
        INTO @DATA(StLoc).

*          SELECT a~idqtybag, a~remarks, a~idcat, a~idid, a~idno, a~idpartycode, a~idprdcode, a~idprdqty,a~idprdrate,a~idprdqtyf,
*            a~idtdiscamt,a~idprdbatch,a~idtotaldiscamt,a~idprdasgncode,a~idcgstrate,a~idcgstamount,a~idsgstrate,a~idsgstamount,a~idigstrate,a~idigstamount
*            FROM zinvoicedatatab1 AS a
*            WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~idfyear = @wa_head-imfyear AND  a~idtype = @wa_head-imtype
*            AND a~idno = @wa_head-imno
*            INTO TABLE @DATA(it_data).

        DATA: var_sales_org TYPE string,
              var_org_div   TYPE string,
              party_code    TYPE string,
              mycid         TYPE string.

        var_sales_org = wa_head-comp_code(2) && '00'.

        DATA : var_dist TYPE string,
               storage  TYPE string.

*         IF wa_head-scrapbill = 'N'.
*           var_dist = 'GT'.
*           var_org_div = 'B1'.
*           storage = ''.
*        ELSEIF wa_head-scrapbill = 'Y'.
*          var_dist = 'SS'.
*          var_org_div = 'S1'.
*          storage = 'SC01'.
*        ENDIF.

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

        party_code = wa_data_party-BusinessPartner.

        DATA : final_rate TYPE p DECIMALS 2.


**************************** rate calc  not  required now
        LOOP AT it_data INTO DATA(wa_rate).
          wa_rate-idprdqty =  wa_rate-idprdqty + wa_rate-idprdqtyf.
          final_rate = ( wa_rate-idprdrate - ( wa_rate-Idtotaldiscamount / wa_rate-idprdqty ) ) * 100.
          wa_rate-idprdrate = final_rate.
          MODIFY it_data FROM wa_rate.
        ENDLOOP.

*    **********************************************************************************************************

*****************************qty changes*****************

*        LOOP AT it_data INTO DATA(wa_rate).
*          wa_rate-idprdqty =  wa_rate-idprdqty + wa_rate-idprdqtyf.
*          MODIFY it_data FROM wa_rate.
*        ENDLOOP.

*********************************************************

**********order reason**********

 data : order_reason type c length 3.

    if wa_head-order_reason = 'Z1'.
      order_reason = 'Z1'.
    elseif  wa_head-order_reason = 'Z2'.
      order_reason = 'Z2'.
    else.
      order_reason = '009'.
    endif.
********************************


        IF wa_head-reference_doc IS INITIAL AND mat_false = 0.
            IF var_dist ne 'SS'.
          mycid = |H001{ custref }|.
          MODIFY ENTITIES OF i_customerreturntp
            ENTITY customerreturn
            CREATE
              FIELDS (
                customerreturntype
                salesorganization
                distributionchannel
                organizationdivision
                soldtoparty
                purchaseorderbycustomer
                CustomerPaymentTerms
                SDDocumentReason
                HeaderBillingBlockReason
                PricingDate
                RequestedDeliveryDate
                CustomerReturnDate
              )
              WITH VALUE #(
                ( %cid = mycid
                  %data = VALUE #(
                    customerreturntype = 'CBRE'
                    salesorganization = var_sales_org
                    distributionchannel = var_dist
                    organizationdivision = var_org_div
                    soldtoparty = |{ party_code ALPHA = IN }|
                    purchaseorderbycustomer = custref
                    CustomerPaymentTerms = '0001'
                    SDDocumentReason = order_reason
                    HeaderBillingBlockReason = ''
                    PricingDate = wa_head-imdate
                    RequestedDeliveryDate = wa_head-imdate
                    CustomerReturnDate = wa_head-imdate
                  )
                )
              )

          CREATE BY \_item
            FIELDS (
              Product
              RequestedQuantity
              CustomerReturnItemCategory
              Plant
              batch
              StorageLocation
            )
            WITH VALUE #(
              ( %cid_ref = mycid
                CustomerReturn = space
                %target = VALUE #(
                  FOR wa_data IN it_data INDEX INTO i (
                    %cid = |I{ i WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                    product = wa_data-idprdcode
                    requestedquantity = wa_data-idprdqty
                    CustomerReturnItemCategory = wa_data-itemcatagory
                    Plant = wa_head-plant
                    batch = wa_data-idprdbatch
                    StorageLocation = stloc-intgpath
                  )
                )
              )
            )

          ENTITY CustomerReturnItem
            CREATE BY \_itempricingelement
            FIELDS (
              conditiontype
              conditionrateamount
              conditioncurrency
              conditionquantity
            )
            WITH VALUE #(
              FOR wa_data1 IN it_data INDEX INTO j (
                %cid_ref = |I{ j WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                CustomerReturn = space
                CustomerReturnItem = space
                %target = VALUE #(
                  ( %cid = |ITPRELM{ j }_01|
                   conditiontype = 'ZBNP'
                   conditionrateamount = wa_data1-idprdrate
                   conditioncurrency = 'INR'
                   conditionquantity = 100
                  )
                )
              )
            )

          MAPPED DATA(ls_mapped)
          FAILED DATA(ls_failed)
          REPORTED DATA(ls_reported).

          Elseif var_dist = 'SS'.

             mycid = |H001{ custref }|.
          MODIFY ENTITIES OF i_customerreturntp
            ENTITY customerreturn
            CREATE
              FIELDS (
                customerreturntype
                salesorganization
                distributionchannel
                organizationdivision
                soldtoparty
                purchaseorderbycustomer
                CustomerPaymentTerms
                SDDocumentReason
                HeaderBillingBlockReason
                PricingDate
                RequestedDeliveryDate
                CustomerReturnDate
              )
              WITH VALUE #(
                ( %cid = mycid
                  %data = VALUE #(
                    customerreturntype = 'CBRE'
                    salesorganization = var_sales_org
                    distributionchannel = var_dist
                    organizationdivision = var_org_div
                    soldtoparty = |{ party_code ALPHA = IN }|
                    purchaseorderbycustomer = custref
                    CustomerPaymentTerms = '0001'
                    SDDocumentReason = order_reason
                    HeaderBillingBlockReason = ''
                    PricingDate = wa_head-imdate
                    RequestedDeliveryDate = wa_head-imdate
                    CustomerReturnDate = wa_head-imdate
                  )
                )
              )

          CREATE BY \_item
            FIELDS (
              Product
              RequestedQuantity
              CustomerReturnItemCategory
              Plant
              batch
              StorageLocation
            )
            WITH VALUE #(
              ( %cid_ref = mycid
                CustomerReturn = space
                %target = VALUE #(
                  FOR wa_data IN it_data INDEX INTO i (
                    %cid = |I{ i WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                    product = wa_data-idprdcode
                    requestedquantity = wa_data-idprdqty
                    CustomerReturnItemCategory = wa_data-itemcatagory
                    Plant = wa_head-plant
                    batch = wa_data-idprdbatch
                    StorageLocation = storage
                  )
                )
              )
            )

          ENTITY CustomerReturnItem
            CREATE BY \_itempricingelement
            FIELDS (
              conditiontype
              conditionrateamount
              conditioncurrency
              conditionquantity
            )
            WITH VALUE #(
              FOR wa_data1 IN it_data INDEX INTO j (
                %cid_ref = |I{ j WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                CustomerReturn = space
                CustomerReturnItem = space
                %target = VALUE #(
                  ( %cid = |ITPRELM{ j }_01|
                   conditiontype = 'ZBNP'
                   conditionrateamount = wa_data1-idprdrate
                   conditioncurrency = 'INR'
                   conditionquantity = 100
                  )
                  ( %cid = |ITPRELM{ j }_02|
                  conditiontype = 'ZSCP'
                  conditionrateamount = wa_data1-IdTcsAmt
                  conditioncurrency = 'INR'
                  conditionquantity = wa_data1-idprdqty
                )
                )
              )
            )

          MAPPED DATA(ls_mapped1)
          FAILED DATA(ls_failed1)
          REPORTED DATA(ls_reported1).
          ENDIF.



          COMMIT ENTITIES BEGIN
           RESPONSE OF i_customerreturntp
           FAILED DATA(ls_save_failed)
           REPORTED DATA(ls_save_reported).
          COMMIT ENTITIES END.

          IF ls_save_failed IS INITIAL.
            SELECT SINGLE FROM I_CustomerReturn AS a
            FIELDS a~CustomerReturn
            WHERE a~SoldToParty = @wa_data_party-BusinessPartner AND a~CustomerReturnDate = @wa_head-imdate AND a~PurchaseOrderByCustomer = @custref
            INTO @DATA(return_order).

            SELECT SINGLE FROM I_CustomerReturnItem AS a
            FIELDS SUM( a~NetAmount + a~TaxAmount ) AS TotalNetAmount
            WHERE a~CustomerReturn = @return_order
            INTO @TotalNetAmount.

            UPDATE zdt_usdatamst1 SET
            processed = 'X',
            reference_doc = @return_order,
            orderamount = @TotalNetAmount,
            status = 'Sales Return Created',
            error_log = ''
            WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
            CLEAR: return_order.
          ENDIF.


        ENDIF.
        CLEAR: wa_head, lv_vbeln,it_data,order_reason.
      ENDIF.
      mat_false = 0.
    ENDLOOP.


  ENDMETHOD.


      METHOD if_apj_dt_exec_object~get_parameters.

      ENDMETHOD.


      METHOD if_apj_rt_exec_object~execute.

          createso(  ).

      ENDMETHOD.


      METHOD if_oo_adt_classrun~main.

         createso(  ).

      ENDMETHOD.
ENDCLASS.
