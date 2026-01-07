CLASS zcl_validatestaging DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .

    CLASS-METHODS runjob
      IMPORTING paramno TYPE c.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VALIDATESTAGING IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Validate Staging Data Parameter'   lowercase_ind = abap_true changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Validate Staging Data Parameter' )
    ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA p_descr TYPE c LENGTH 80.

    " Getting the actual parameter values
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'P_DESCR'. p_descr = ls_parameter-low.
      ENDCASE.
    ENDLOOP.

    runjob( p_descr ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    runjob( 'MT000300' ).
  ENDMETHOD.


  METHOD runjob.
    DATA : purchaseplant TYPE string.
    DATA : localparamno TYPE string.
    "    DATA : it_head TYPE TABLE OF zinv_mst.
    DATA : errorexists TYPE int1.
    DATA: var_sales_org TYPE string.

    TYPES: BEGIN OF it_headstr,
             comp_code       TYPE c LENGTH 10,
             plant           TYPE c LENGTH 4,
             imfyear         TYPE c LENGTH 4,
             imtype          TYPE c LENGTH 2,
             imno            TYPE c LENGTH 8,
             impartycode     TYPE c LENGTH 10,
             po_tobe_created TYPE i,
             datavalidated   TYPE i,
             error_log       TYPE c LENGTH 210,
             scrapbill       TYPE c length 2,
           END OF it_headstr.

    DATA : it_head TYPE TABLE OF it_headstr.
    DATA : datavalidated TYPE i VALUE '0'.


    "Validate zinv_mst & zinvoicedatatab1
    localparamno = paramno.
    IF localparamno = ''.
      SELECT a~comp_code, a~plant, a~imfyear, a~imtype, a~imno, a~impartycode, a~po_tobe_created, a~datavalidated, a~error_log,a~scrapbill
          FROM zinv_mst AS a
              WHERE a~datavalidated = @datavalidated
*              AND error_log is INITIAL
          ORDER BY a~comp_code, a~plant, a~imfyear, a~imtype, a~imno
          INTO TABLE @it_head.
    ELSE.
      SELECT a~comp_code, a~plant, a~imfyear, a~imtype, a~imno, a~impartycode, a~po_tobe_created, a~datavalidated, a~error_log,a~scrapbill
          FROM zinv_mst AS a
              WHERE a~datavalidated = @datavalidated  AND a~imno = @localparamno
          ORDER BY a~comp_code, a~plant, a~imfyear, a~imtype, a~imno
          INTO TABLE @it_head.
    ENDIF.
    LOOP AT it_head INTO DATA(wa_head).
      errorexists = 0.

      SELECT SINGLE c~businesspartner,c~businesspartneridbyextsystem,d~customeraccountgroup
        FROM zinv_mst AS a
        LEFT JOIN i_businesspartner AS c ON a~impartycode = c~businesspartneridbyextsystem
        LEFT JOIN i_customer AS d ON c~businesspartner = d~customer
        inner JOIN I_customercompany AS e ON d~Customer = e~Customer
        "and e~CompanyCode = a~comp_code
        WHERE e~CompanyCode = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~imfyear = @wa_head-imfyear AND  a~imtype = @wa_head-imtype
            AND a~imno = @wa_head-imno
        INTO  @DATA(wa_data_party).
      IF wa_data_party IS INITIAL.
        wa_head-error_log = |Customer not defined - { wa_head-impartycode }|.

        UPDATE zinv_mst SET
            error_log = @wa_head-error_log,
            datavalidated = 0
        WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
        COMMIT WORK.
        errorexists = 1.
      ELSE.
        IF wa_data_party-customeraccountgroup = 'Z004'.
          wa_head-po_tobe_created = 1.
        ELSE.
          wa_head-po_tobe_created = 0.
        ENDIF.
      ENDIF.

      "Check Customer Sales Area
      IF errorexists = 0.
        var_sales_org = wa_head-comp_code(2) && '00'.

         DATA(lv_distr_chnl) = COND #( WHEN wa_head-scrapbill = 'SS' THEN 'SS' ELSE wa_head-scrapbill ).
         DATA(lv_division) = COND #(
            WHEN wa_head-scrapbill = 'SS' THEN 'S1'
            WHEN wa_head-scrapbill = 'OS' THEN 'R2'
            ELSE 'B1'
        ).

        SELECT SINGLE a~Customer
          FROM I_CustomerSalesArea AS a
          WHERE a~Customer = @wa_data_party-BusinessPartner AND a~SalesOrganization  = @var_sales_org AND a~DistributionChannel = @lv_distr_chnl AND  a~Division = @lv_division
          INTO  @DATA(wa_data_salesarea).
        IF wa_data_salesarea IS INITIAL.
          wa_head-error_log = |Customer sales area not defined - { wa_data_party-BusinessPartner }|.

          UPDATE zinv_mst SET
              error_log = @wa_head-error_log
          WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
          COMMIT WORK.
          errorexists = 1.
        ENDIF.
      ENDIF.

      IF errorexists = 0.
        UPDATE zinvoicedatatab1 SET
            idprdcode = ''
            WHERE comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND idfyear = @wa_head-imfyear AND idtype = @wa_head-imtype
            AND idno = @wa_head-imno.

        "****Actual product code
        SELECT FROM zinvoicedatatab1 AS a
            INNER JOIN I_Product AS b ON a~idprdasgncode = b~product
            FIELDS a~idaid, b~product
            WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~idfyear = @wa_head-imfyear AND  a~idtype = @wa_head-imtype
            AND a~idno = @wa_head-imno
            INTO TABLE @DATA(it_prod).

            IF it_prod IS NOT INITIAL.
              SELECT FROM @it_prod AS a
                INNER JOIN I_ProductPlantBasic AS b ON a~Product = b~Product
                fields b~Product, a~idaid
                where b~Plant = @wa_head-plant
                INTO TABLE @DATA(act_prod).
            ENDIF.

            LOOP AT act_prod INTO DATA(wa_prod).
              UPDATE zinvoicedatatab1 SET
                    idprdcode = @wa_prod-product
              WHERE comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND idfyear = @wa_head-imfyear AND idtype = @wa_head-imtype
              AND idno = @wa_head-imno AND idaid = @wa_prod-idaid.
              clear : wa_prod.
            ENDLOOP.
            CLEAR: act_prod,it_prod.
*         ***********Old product code
        SELECT FROM zinvoicedatatab1 AS a
            INNER JOIN i_product AS b ON a~idprdasgncode = b~productoldid
            FIELDS a~idaid, b~product
            WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~idfyear = @wa_head-imfyear AND  a~idtype = @wa_head-imtype
            AND a~idno = @wa_head-imno AND a~idprdcode = ''
            INTO TABLE @DATA(it_prodold).

             IF it_prodold IS NOT INITIAL.
              SELECT FROM @it_prodold AS a
                INNER JOIN I_ProductPlantBasic AS b ON a~Product = b~Product
                fields b~Product, a~idaid
                where b~Plant = @wa_head-plant
                INTO TABLE @DATA(old_prod).
            ENDIF.

            LOOP AT old_prod INTO DATA(wa_prodold).
              UPDATE zinvoicedatatab1 SET
                  idprdcode = @wa_prodold-product
              WHERE comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND idfyear = @wa_head-imfyear AND idtype = @wa_head-imtype
              AND idno = @wa_head-imno AND idaid = @wa_prodold-idaid.
              clear : wa_prodold.
            ENDLOOP.
            CLEAR: it_prodold,old_prod.

        "***blank product code
        SELECT FROM zinvoicedatatab1 AS a
            FIELDS a~idaid, a~idprdcode, a~idprdasgncode
            WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~idfyear = @wa_head-imfyear AND  a~idtype = @wa_head-imtype
            AND a~idno = @wa_head-imno AND a~idprdcode = ''
            INTO TABLE @DATA(it_prodblank).

        IF it_prodblank IS NOT INITIAL.
          LOOP AT it_prodblank INTO DATA(wa_prodblank).
            wa_head-error_log = |Product not defined - { wa_prodblank-idprdasgncode }|.

            UPDATE zinv_mst SET
                cust_code = @wa_data_party-businesspartner,
                po_tobe_created = @wa_head-po_tobe_created,
                error_log = @wa_head-error_log
            WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
            COMMIT WORK.
            errorexists = 1.
            clear : wa_prodblank.
            EXIT.

          ENDLOOP.
        ENDIF.
        CLEAR: it_prodblank.
      ENDIF.

      IF errorexists = 0.
        "***Product Plant Sales extension
        SELECT FROM zinvoicedatatab1 AS a
            LEFT JOIN i_productplantsales AS b ON a~idprdcode = b~product AND b~plant = a~plant
            FIELDS a~idaid, a~idprdcode, b~loadinggroup
            WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~idfyear = @wa_head-imfyear AND  a~idtype = @wa_head-imtype
            AND a~idno = @wa_head-imno AND ( b~Product IS INITIAL or  b~loadinggroup IS INITIAL OR b~isactiveentity IS INITIAL )
            INTO TABLE @DATA(it_prodbasic).

        IF it_prodbasic IS NOT INITIAL.
          LOOP AT it_prodbasic INTO DATA(wa_prodbasic).
            wa_head-error_log = |Product not extended - { wa_prodbasic-idprdcode } in { wa_head-plant }|.

            UPDATE zinv_mst SET
                cust_code = @wa_data_party-businesspartner,
                po_tobe_created = @wa_head-po_tobe_created,
                error_log = @wa_head-error_log
            WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
            COMMIT WORK.
            errorexists = 2.
            clear : wa_prodbasic.
            EXIT.

          ENDLOOP.
        ENDIF.
        CLEAR: it_prodbasic.
      ENDIF.



      "***Product Plant Purchase extension
      IF errorexists = 0.
        IF wa_head-po_tobe_created = 1.
          CONCATENATE 'CV' wa_head-plant INTO DATA(supplier).
          purchaseplant = wa_data_party-businesspartner.
          REPLACE ALL OCCURRENCES OF 'CV' IN purchaseplant WITH ''.

          SELECT FROM zinvoicedatatab1 AS a
              LEFT JOIN i_productplantprocurement AS b ON a~idprdcode = b~product AND b~plant = @purchaseplant
              FIELDS a~idaid, a~idprdcode
              WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~idfyear = @wa_head-imfyear AND  a~idtype = @wa_head-imtype
              AND a~idno = @wa_head-imno AND ( b~plant IS INITIAL OR b~isactiveentity IS INITIAL )
              INTO TABLE @DATA(it_prodpurchase).
          IF it_prodpurchase IS NOT INITIAL.
            LOOP AT it_prodpurchase INTO DATA(wa_prodpurchase).
              wa_head-error_log = |Product not extended - { wa_prodpurchase-idprdcode } in { purchaseplant }|.

              UPDATE zinv_mst SET
                  cust_code = @wa_data_party-businesspartner,
                  po_tobe_created = @wa_head-po_tobe_created,
                  error_log = @wa_head-error_log
              WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
              COMMIT WORK.
              errorexists = 3.
              clear : wa_prodpurchase.
              EXIT.
            ENDLOOP.
          ENDIF.
          CLEAR: it_prodbasic.
        ENDIF.
      ENDIF.

************Plant not extened in sales org and dist chnnl****

 IF errorexists = 0.
        DATA: lv_salesorg type c length 4.

         DATA : error_org_item TYPE string.
         DATA : error_org_hdr TYPE string.

         lv_salesorg = wa_head-comp_code(2) && '00'.
         DATA(lv_dist_chnl) = wa_head-scrapbill.

            SELECT FROM zinvoicedatatab1 AS a
            FIELDS a~idaid, a~idprdcode
            WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant AND a~idfyear = @wa_head-imfyear AND  a~idtype = @wa_head-imtype
            AND a~idno = @wa_head-imno
            INTO table @DATA(it_prodorg).

        IF it_prodorg IS NOT INITIAL.
            Loop at it_prodorg into data(wa_prodorg).
                    SELECT SINGLE FROM  I_ProductSalesDelivery AS b
                    FIELDS b~ProductSalesOrg,b~ProductDistributionChnl,b~product
                    WHERE b~Product = @wa_prodorg-idprdcode and b~ProductSalesOrg = @lv_salesorg and b~ProductDistributionChnl = @lv_dist_chnl
                    INTO @DATA(wa_org).

                    IF wa_org is INITIAL.
                        error_org_item = |Product not extended in Sales Org - { lv_salesorg } and Dist Chnnl - { lv_dist_chnl }|.
                        error_org_hdr  = |Product not extended in Sales Org - { lv_salesorg } and Dist Chnnl - { lv_dist_chnl }|.

                          UPDATE zinvoicedatatab1 SET
                          error_log = @error_org_item
                          WHERE comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND idfyear = @wa_head-imfyear AND idtype = @wa_head-imtype
                          AND idno = @wa_head-imno AND idprdcode = @wa_prodorg-idprdcode and idaid = @wa_prodorg-idaid.

                        UPDATE zinv_mst SET
                            error_log = @error_org_hdr,
                            datavalidated = 0
                        WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.
                    errorexists = 1.
                    ELSE.
                       error_org_item = ''.
                        error_org_hdr  = ''.

                          UPDATE zinvoicedatatab1 SET
                          error_log = @error_org_item
                          WHERE comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND idfyear = @wa_head-imfyear AND idtype = @wa_head-imtype
                          AND idno = @wa_head-imno AND idprdcode = @wa_prodorg-idprdcode and idaid = @wa_prodorg-idaid.

                    ENDIF.
             clear : wa_prodorg,wa_org,error_org_item,error_org_hdr.
            ENDLOOP.
            COMMIT WORK.
        ENDIF.
   ENDIF.

*************************************************************
      IF errorexists = 0.
***************************     Batch is not active
        SELECT FROM zinvoicedatatab1 AS a
        inner JOIN I_ProductPlantBasic AS b ON a~idprdcode = b~product AND a~plant = b~plant
        FIELDS b~product, b~plant , b~IsBatchManagementRequired
        WHERE a~comp_code = @wa_head-comp_code AND a~plant = @wa_head-plant and a~idfyear =  @wa_head-imfyear and a~idtype = @wa_head-imtype
        and a~idno = @wa_head-imno and a~idprdbatch is not initial
        INTO TABLE @DATA(it_batachActivation).

        DATA : error_string TYPE string.
         DATA : error_string1 TYPE string.
        LOOP AT it_batachActivation INTO DATA(wa_batchActivatoin).
          IF wa_batchActivatoin-IsBatchManagementRequired IS NOT INITIAL  AND wa_batchactivatoin-Product IS NOT INITIAL.
            CONTINUE.
          ELSEIF  wa_batchActivatoin-IsBatchManagementRequired IS INITIAL.
            error_string = |Batch not active - { wa_batchActivatoin-Product } in { wa_head-plant }|.
             error_string1 = |Batch is not active |.
            UPDATE zinvoicedatatab1 SET
                error_log = @error_string
                WHERE comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND idfyear = @wa_head-imfyear AND idtype = @wa_head-imtype
                AND idno = @wa_head-imno AND idprdcode = @wa_batchActivatoin-Product.

            UPDATE zinv_mst SET
               error_log = @error_string1,
               datavalidated = 0
               WHERE comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype
               AND imno = @wa_head-imno.
               errorexists = 1.
          ENDIF.
        CLEAR: error_string,wa_batchactivatoin,error_string1.
        ENDLOOP.
            COMMIT WORK.
      ENDIF.


      IF errorexists = 0.
***************************     Batch Number Not Available
       SELECT FROM zinvoicedatatab1 AS a
      FIELDS a~idprdcode, a~idprdbatch, a~plant,a~comp_code,a~idfyear,a~idtype,a~idno
      WHERE a~comp_code = @wa_head-comp_code
        AND a~plant = @wa_head-plant
        AND a~idfyear = @wa_head-imfyear
        AND a~idtype = @wa_head-imtype
        AND a~idno = @wa_head-imno
        AND a~idprdbatch IS NOT INITIAL
      INTO TABLE @DATA(it_items).

     LOOP AT it_items INTO DATA(wa_item).

          SELECT SINGLE b~Batch
            FROM i_batch AS b
            WHERE b~Material = @wa_item-idprdcode
              AND b~Plant = @wa_item-plant
              AND b~Batch = @wa_item-idprdbatch
            INTO @DATA(lv_batch_check).

      IF lv_batch_check is INITIAL.
        error_string = |No Batch For { wa_item-idprdcode } in { wa_item-plant }|.
        error_string1 = |Batch number is not available |.

        UPDATE zinvoicedatatab1 SET
            error_log = @error_string
            WHERE comp_code = @wa_item-comp_code
              AND plant = @wa_item-plant
              AND idfyear = @wa_item-idfyear
              AND idtype = @wa_item-idtype
              AND idno = @wa_item-idno
              AND idprdcode = @wa_item-idprdcode.

        UPDATE zinv_mst SET
            error_log = @error_string1,
            datavalidated = 0
            WHERE comp_code = @wa_item-comp_code
              AND plant = @wa_item-plant
              AND imfyear = @wa_item-idfyear
              AND imtype = @wa_item-idtype
              AND imno = @wa_item-idno.

        errorexists = 1.
      ENDIF.
    clear : error_string,error_string1,wa_item.
    ENDLOOP.
    COMMIT WORK.
  ENDIF.

      IF errorexists = 0.
***************************    Stock IS Not Available
        SELECT FROM zinvoicedatatab1 AS a
        FIELDS a~idprdcode, a~idprdbatch, a~plant,a~comp_code,a~idfyear,a~idtype,a~idno,a~idprdqty,a~idprdqtyf
        WHERE a~comp_code = @wa_head-comp_code
        AND a~plant = @wa_head-plant
        AND a~idfyear = @wa_head-imfyear
        AND a~idtype = @wa_head-imtype
        AND a~idno = @wa_head-imno
*        AND a~idprdbatch IS NOT INITIAL
        INTO TABLE @DATA(item).

       Loop at item into data(wa_item1).

            SELECT single FROM I_StockQuantityCurrentValue_2( p_displaycurrency = 'INR' ) AS b
            FIELDS b~Product,b~Batch ,b~MatlWrhsStkQtyInMatlBaseUnit
            WHERE  b~plant = @wa_item1-plant and b~Product = @wa_item1-idprdcode and b~Batch = @wa_item1-idprdbatch
            and b~MatlWrhsStkQtyInMatlBaseUnit ge ( @wa_item1-idprdqty + @wa_item1-idprdqtyf  )
            INTO @DATA(wa_stockavailability).

         IF wa_stockavailability-MatlWrhsStkQtyInMatlBaseUnit lt ( wa_item1-idprdqty + wa_item1-idprdqtyf  ).
           error_string = |Stock Deficit { wa_item1-idprdcode } in { wa_item1-plant }|.
           error_string1 = |Stock is not available |.

          UPDATE zinvoicedatatab1 SET
            error_log = @error_string
            WHERE comp_code = @wa_item1-comp_code
              AND plant = @wa_item1-plant
              AND idfyear = @wa_item1-idfyear
              AND idtype = @wa_item1-idtype
              AND idno = @wa_item1-idno
              AND idprdcode = @wa_item1-idprdcode.

          UPDATE zinv_mst SET
            error_log = @error_string1,
            datavalidated = 0
            WHERE comp_code = @wa_item1-comp_code
              AND plant = @wa_item1-plant
              AND imfyear = @wa_item1-idfyear
              AND imtype = @wa_item1-idtype
              AND imno = @wa_item1-idno.

        errorexists = 1.
      ENDIF.
       CLEAR: error_string,error_string1,wa_item1,wa_stockavailability.
       Endloop.
       COMMIT WORK.
      ENDIF.


      IF errorexists = 0.
        UPDATE zinv_mst SET
            cust_code = @wa_data_party-businesspartner,
            po_tobe_created = @wa_head-po_tobe_created,
            error_log = '',
            datavalidated = 1
        WHERE imno = @wa_head-imno AND comp_code = @wa_head-comp_code AND plant = @wa_head-plant AND imfyear = @wa_head-imfyear AND imtype = @wa_head-imtype.

        UPDATE zinvoicedatatab1 SET
            error_log = ''
            WHERE comp_code = @wa_head-comp_code
              AND plant = @wa_head-plant
              AND idfyear = @wa_head-imfyear
              AND idtype = @wa_head-imtype
              AND idno = @wa_head-imno.
        COMMIT WORK.
      ENDIF.

     clear : wa_head,wa_data_party,wa_data_salesarea,lv_distr_chnl,lv_division,lv_dist_chnl,lv_salesorg.
    ENDLOOP.


    "**************************************************************************************************************
    TYPES: BEGIN OF it_headusstr,
             comp_code     TYPE c LENGTH 10,
             plant         TYPE c LENGTH 4,
             imfyear       TYPE c LENGTH 4,
             imtype        TYPE c LENGTH 2,
             imno          TYPE c LENGTH 9,
             impartycode   TYPE c LENGTH 10,
             datavalidated TYPE i,
             error_log     TYPE c LENGTH 210,
             scrapbill       TYPE c length 2,
           END OF it_headusstr.

    DATA : it_headus TYPE TABLE OF it_headusstr.


    "Validate zdt_usdatamst1 & zdt_usdatadata1
    localparamno = paramno.
    IF localparamno = ''.
      SELECT a~comp_code, a~plant, a~imfyear, a~imtype, a~imno, a~impartycode, a~datavalidated, a~error_log,a~scrapbill
          FROM zdt_usdatamst1 AS a
              WHERE a~datavalidated = 0
          ORDER BY a~comp_code, a~plant, a~imfyear, a~imtype, a~imno
          INTO TABLE @it_headus.
    ELSE.
      SELECT a~comp_code, a~plant, a~imfyear, a~imtype, a~imno, a~impartycode, a~datavalidated, a~error_log,a~scrapbill
          FROM zdt_usdatamst1 AS a
              WHERE a~datavalidated = 0 AND a~imno = @localparamno
          ORDER BY a~comp_code, a~plant, a~imfyear, a~imtype, a~imno
          INTO TABLE @it_headus.
    ENDIF.
    LOOP AT it_headus INTO DATA(wa_headus).
      errorexists = 0.

      SELECT SINGLE c~businesspartner,c~businesspartneridbyextsystem,d~customeraccountgroup
        FROM i_businesspartner AS c
        LEFT JOIN i_customer AS d ON c~businesspartner = d~customer
        LEFT JOIN I_customercompany AS e ON d~Customer = e~Customer
        WHERE c~businesspartneridbyextsystem = @wa_headus-impartycode and e~CompanyCode = @wa_headus-comp_code
        INTO  @DATA(wa_data_partyus).
      IF wa_data_partyus IS INITIAL.
        wa_headus-error_log = |Customer not defined - { wa_headus-impartycode }|.

        UPDATE zdt_usdatamst1 SET
            error_log = @wa_headus-error_log
        WHERE imno = @wa_headus-imno AND comp_code = @wa_headus-comp_code AND plant = @wa_headus-plant AND imfyear = @wa_headus-imfyear AND imtype = @wa_headus-imtype.
        COMMIT WORK.
        errorexists = 1.
      ENDIF.
      "Check Customer Sales Area
      IF errorexists = 0.
        var_sales_org = wa_headus-comp_code(2) && '00'.
         DATA(lv_distr_chnl1) = COND #( WHEN wa_headus-scrapbill = 'SS' THEN 'SS' ELSE wa_headus-scrapbill ).
        DATA(lv_division1) = COND #(
            WHEN wa_headus-scrapbill = 'SS' THEN 'S1'
            WHEN wa_headus-scrapbill = 'OS' THEN 'R2'
            ELSE 'B1'
        ).

        SELECT SINGLE a~Customer
          FROM I_CustomerSalesArea AS a
          WHERE a~Customer = @wa_data_partyus-BusinessPartner AND a~SalesOrganization  = @var_sales_org AND a~DistributionChannel = @lv_distr_chnl1 AND  a~Division = @lv_division1
          INTO  @DATA(wa_data_salesareaus).
        IF wa_data_salesareaus IS INITIAL.
          wa_headus-error_log = |Customer sales area not defined - { wa_data_partyus-BusinessPartner }|.

          UPDATE zdt_usdatamst1 SET
              error_log = @wa_headus-error_log
          WHERE imno = @wa_headus-imno AND comp_code = @wa_headus-comp_code AND plant = @wa_headus-plant AND imfyear = @wa_headus-imfyear AND imtype = @wa_headus-imtype.
          COMMIT WORK.
          errorexists = 1.
        ENDIF.
      ENDIF.


      IF errorexists = 0.
        UPDATE zdt_usdatadata1 SET
            idprdcode = ''
            WHERE comp_code = @wa_headus-comp_code AND plant = @wa_headus-plant AND idfyear = @wa_headus-imfyear AND idtype = @wa_headus-imtype
            AND idno = @wa_headus-imno.

        "****Actual product code
        SELECT FROM zdt_usdatadata1 AS a
            INNER JOIN i_product AS b ON a~idprdasgncode = b~product
            FIELDS a~idaid, b~product
            WHERE a~comp_code = @wa_headus-comp_code AND a~plant = @wa_headus-plant AND a~idfyear = @wa_headus-imfyear AND  a~idtype = @wa_headus-imtype
            AND a~idno = @wa_headus-imno
            INTO TABLE @DATA(it_produs).

            IF it_produs IS NOT INITIAL.
              SELECT FROM @it_produs AS a
                INNER JOIN I_ProductPlantBasic AS b ON a~Product = b~Product
                fields b~Product, a~idaid
                where b~Plant = @wa_headus-plant
                INTO TABLE @DATA(act_prod_ret).
            ENDIF.

        LOOP AT act_prod_ret INTO DATA(wa_produs).
          UPDATE zdt_usdatadata1 SET
                idprdcode = @wa_produs-product
          WHERE comp_code = @wa_headus-comp_code AND plant = @wa_headus-plant AND idfyear = @wa_headus-imfyear AND idtype = @wa_headus-imtype
          AND idno = @wa_headus-imno AND idaid = @wa_produs-idaid.
          clear : wa_produs.
        ENDLOOP.
        CLEAR: it_produs,act_prod_ret.
*         ***********Old product code
        SELECT FROM zdt_usdatadata1 AS a
            INNER JOIN i_product AS b ON a~idprdasgncode = b~productoldid
            FIELDS a~idaid, b~product
            WHERE a~comp_code = @wa_headus-comp_code AND a~plant = @wa_headus-plant AND a~idfyear = @wa_headus-imfyear AND  a~idtype = @wa_headus-imtype
            AND a~idno = @wa_headus-imno AND a~idprdcode = ''
            INTO TABLE @DATA(it_prodoldus).

          IF it_prodoldus IS NOT INITIAL.
              SELECT FROM @it_prodoldus AS a
                INNER JOIN I_ProductPlantBasic AS b ON a~Product = b~Product
                fields b~Product, a~idaid
                where b~Plant = @wa_headus-plant
                INTO TABLE @DATA(old_produs).
            ENDIF.


        LOOP AT old_produs INTO DATA(wa_prodoldus).
          UPDATE zdt_usdatadata1 SET
              idprdcode = @wa_prodoldus-product
          WHERE comp_code = @wa_headus-comp_code AND plant = @wa_headus-plant AND idfyear = @wa_headus-imfyear AND idtype = @wa_headus-imtype
          AND idno = @wa_headus-imno AND idaid = @wa_prodoldus-idaid.
          clear : wa_prodoldus.
        ENDLOOP.
        CLEAR: it_prodoldus,old_produs.

        "***blank product code
        SELECT FROM zdt_usdatadata1 AS a
            FIELDS a~idaid, a~idprdcode, a~idprdasgncode
            WHERE a~comp_code = @wa_headus-comp_code AND a~plant = @wa_headus-plant AND a~idfyear = @wa_headus-imfyear AND  a~idtype = @wa_headus-imtype
            AND a~idno = @wa_headus-imno AND a~idprdcode = ''
            INTO TABLE @DATA(it_prodblankus).
        IF it_prodblankus IS NOT INITIAL.
          LOOP AT it_prodblankus INTO DATA(wa_prodblankus).
            wa_headus-error_log = |Product not defined - { wa_prodblankus-idprdasgncode }|.

            UPDATE zdt_usdatamst1 SET
                cust_code = @wa_data_partyus-businesspartner,
                error_log = @wa_headus-error_log
            WHERE imno = @wa_headus-imno AND comp_code = @wa_headus-comp_code AND plant = @wa_headus-plant AND imfyear = @wa_headus-imfyear AND imtype = @wa_headus-imtype.
            COMMIT WORK.
            errorexists = 1.
            clear : wa_prodoldus.
            EXIT.
          ENDLOOP.
        ENDIF.
        CLEAR: it_prodblankus.
      ENDIF.

      IF errorexists = 0.
        "***Product Plant Sales extension
        SELECT FROM zdt_usdatadata1 AS a
            LEFT JOIN i_productplantsales AS b ON a~idprdcode = b~product AND b~plant = a~plant
            FIELDS a~idaid, a~idprdcode, b~loadinggroup
            WHERE a~comp_code = @wa_headus-comp_code AND a~plant = @wa_headus-plant AND a~idfyear = @wa_headus-imfyear AND  a~idtype = @wa_headus-imtype
            AND a~idno = @wa_headus-imno AND ( b~loadinggroup IS INITIAL OR b~isactiveentity IS INITIAL )
            INTO TABLE @DATA(it_prodbasicus).
        IF it_prodbasicus IS NOT INITIAL.
          LOOP AT it_prodbasicus INTO DATA(wa_prodbasicus).
            wa_headus-error_log = |Product not extended - { wa_prodbasicus-idprdcode } in { wa_headus-plant }|.

            UPDATE zdt_usdatamst1 SET
                cust_code = @wa_data_partyus-businesspartner,
                error_log = @wa_headus-error_log
            WHERE imno = @wa_headus-imno AND comp_code = @wa_headus-comp_code AND plant = @wa_headus-plant AND imfyear = @wa_headus-imfyear AND imtype = @wa_headus-imtype.
            COMMIT WORK.
            errorexists = 2.
            clear : wa_prodbasicus.
            EXIT.
          ENDLOOP.
        ENDIF.
        CLEAR: it_prodbasicus.
      ENDIF.

************Plant not extened in sales org and dist chnnl****

 IF errorexists = 0.
        DATA: lv_salesorg_ret type c length 4.

         DATA : error_org_item_ret TYPE string.
         DATA : error_org_hdr_ret TYPE string.

         lv_salesorg_ret = wa_headus-comp_code(2) && '00'.
         DATA(lv_dist_chnl_ret) = wa_headus-scrapbill.

            SELECT FROM zdt_usdatadata1 AS a
            FIELDS a~idaid, a~idprdcode
            WHERE a~comp_code = @wa_headus-comp_code AND a~plant = @wa_headus-plant AND a~idfyear = @wa_headus-imfyear AND  a~idtype = @wa_headus-imtype
            AND a~idno = @wa_headus-imno
            INTO table @DATA(it_prodorg_ret).

        IF it_prodorg_ret IS NOT INITIAL.
            Loop at it_prodorg_ret into data(wa_prodorg_ret).
                    SELECT SINGLE FROM  I_ProductSalesDelivery AS b
                    FIELDS b~ProductSalesOrg,b~ProductDistributionChnl,b~product
                    WHERE b~Product = @wa_prodorg_ret-idprdcode and b~ProductSalesOrg = @lv_salesorg_ret and b~ProductDistributionChnl = @lv_dist_chnl_ret
                    INTO @DATA(wa_org_ret).

                    IF wa_org_ret is INITIAL.
                        error_org_item_ret = |Product not extended in Sales Org - { lv_salesorg_ret } and Dist Chnnl - { lv_dist_chnl_ret }|.
                        error_org_hdr_ret  = |Product not extended in Sales Org - { lv_salesorg_ret } and Dist Chnnl - { lv_dist_chnl_ret }|.

                          UPDATE zdt_usdatadata1 SET
                          error_log = @error_org_item_ret
                          WHERE comp_code = @wa_headus-comp_code AND plant = @wa_headus-plant AND idfyear = @wa_headus-imfyear AND idtype = @wa_headus-imtype
                          AND idno = @wa_headus-imno AND idprdcode = @wa_prodorg_ret-idprdcode and idaid = @wa_prodorg_ret-idaid.

                        UPDATE zdt_usdatamst1 SET
                            error_log = @error_org_hdr_ret,
                            datavalidated = 0
                        WHERE imno = @wa_headus-imno AND comp_code = @wa_headus-comp_code AND plant = @wa_headus-plant AND imfyear = @wa_headus-imfyear AND imtype = @wa_headus-imtype.
                    errorexists = 1.
                    ELSE.
                       error_org_item_ret = ''.
                        error_org_hdr_ret  = ''.

                          UPDATE zdt_usdatadata1 SET
                          error_log = @error_org_item_ret
                          WHERE comp_code = @wa_headus-comp_code AND plant = @wa_headus-plant AND idfyear = @wa_headus-imfyear AND idtype = @wa_headus-imtype
                          AND idno = @wa_headus-imno AND idprdcode = @wa_prodorg_ret-idprdcode and idaid = @wa_prodorg_ret-idaid.

                    ENDIF.
             clear : wa_prodorg_ret,wa_org_ret,error_org_item_ret,error_org_hdr_ret.
            ENDLOOP.
            COMMIT WORK.
        ENDIF.
   ENDIF.

*************************************************************

      IF errorexists = 0.
        UPDATE zdt_usdatamst1 SET
            cust_code = @wa_data_partyus-businesspartner,
            error_log = '',
            datavalidated = 1
        WHERE imno = @wa_headus-imno AND comp_code = @wa_headus-comp_code AND plant = @wa_headus-plant AND imfyear = @wa_headus-imfyear AND imtype = @wa_headus-imtype.
        COMMIT WORK.
      ENDIF.
       clear : wa_headus,wa_data_partyus, wa_data_salesareaus,lv_division1,lv_distr_chnl1,lv_salesorg_ret,lv_dist_chnl_ret.
    ENDLOOP.



  ENDMETHOD.
ENDCLASS.
