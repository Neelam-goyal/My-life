CLASS zc_stockpurchase DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .

    CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
    CLASS-METHODS runJob.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZC_STOCKPURCHASE IMPLEMENTATION.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 80
        param_text = 'Create Interbranch PO' lowercase_ind = abap_true changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter sign = 'I' option = 'EQ'
        low = 'Create Interbranch PO' )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    runJob( ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    runJob( ).
  ENDMETHOD.


  METHOD runJob.


    " Get integration path for sales filter
    SELECT SINGLE FROM zintegration_tab
    FIELDS intgpath
    WHERE intgmodule = 'SALESFILTER'
    INTO @DATA(it_integration).

    " Get PO list based on filter condition
    IF it_integration IS NOT INITIAL AND it_integration NE ''.
      SELECT a~imno, a~comp_code, a~plant, a~imfyear, a~imtype, a~po_no,
             a~cust_code, a~imdate, a~error_log, a~vehicleno
        FROM zinv_mst AS a
        INNER JOIN zinv_mst_filter AS b
        ON a~comp_code = b~comp_code
        AND a~plant = b~plant
        AND a~imfyear = b~imfyear
        AND a~imtype = b~imtype
        AND a~imno = b~imno
        INNER JOIN ztable_plant AS c ON a~plant = c~plant_code
        WHERE a~po_tobe_created = 1 AND a~po_processed = 0 AND a~datavalidated = 1 AND c~stpocreationenabled = 'X'
        ORDER BY a~comp_code, a~plant, a~imfyear, a~imtype, a~imno
        INTO TABLE @DATA(polist).
    ELSE.
      SELECT a~imno, a~comp_code, a~plant, a~imfyear, a~imtype, a~po_no,
             a~cust_code, a~imdate, a~error_log, a~vehicleno
        FROM zinv_mst AS a
         INNER JOIN ztable_plant AS c ON a~plant = c~plant_code
        WHERE a~po_tobe_created = 1 AND a~po_processed = 0 AND a~datavalidated = 1 AND c~stpocreationenabled = 'X'
        ORDER BY a~comp_code, a~plant, a~imfyear, a~imtype, a~imno
        INTO TABLE @polist.
    ENDIF.

    " Get roundoff product code
    DATA: roundoffproduct TYPE c LENGTH 40.
    SELECT SINGLE FROM zintegration_tab AS a
    FIELDS a~intgmodule, a~intgpath
    WHERE a~intgmodule = 'ROUNDOFFSALES'
    INTO @DATA(wa_integration2).

    IF wa_integration2-intgmodule = 'ROUNDOFFSALES' AND wa_integration2 IS NOT INITIAL.
      roundoffproduct = wa_integration2-intgpath.
    ENDIF.

    " Process each PO
    LOOP AT polist INTO DATA(podetails).
      CONCATENATE 'CV' podetails-plant INTO DATA(supplier).
      DATA: custref  TYPE string,
            lv_error TYPE string.
      DATA: mat_false TYPE i VALUE 0.

      " Check if PO already exists
      custref = |{ podetails-imfyear+0(2) }{ podetails-imtype }{ podetails-imno }|.
      SELECT SINGLE FROM I_PurchaseOrderAPI01 AS a
      FIELDS a~PurchaseOrder
      WHERE a~Supplier = @supplier
        AND a~PurchaseOrderDate = @podetails-imdate
        AND a~CorrespncExternalReference = @custref
      INTO @DATA(wa_purchaseorderid).

      IF wa_purchaseorderid IS NOT INITIAL.


*        CALL METHOD zcl_creategateentry=>creategateentry
*          EXPORTING
*            iv_po      = wa_purchaseorderid
*            iv_ref     = custref
*            iv_vehicle = podetails-vehicleno
*            entrydate  = podetails-imdate
*          IMPORTING
*            gate_entry = DATA(gate_entry)
*            message    = DATA(lv_error).

        " Update existing PO
        UPDATE zinv_mst SET po_processed = 1, po_no = @wa_purchaseorderid, error_log = @lv_error
          WHERE imno = @podetails-imno
          AND comp_code = @podetails-comp_code
          AND plant = @podetails-plant
          AND imfyear = @podetails-imfyear
          AND imtype = @podetails-imtype.

        CLEAR wa_purchaseorderid.
      ELSE.
        " Create new PO
        SELECT FROM zinvoicedatatab1
        FIELDS idqtybag, idprdcode, remarks, idcat, idid, idno,
               idpartycode, idprdqty, idprdrate, idtdiscamt, scrap_prd,
               idtotaldiscamt, idprdbatch, idprdqtyf,input_tax
        WHERE comp_code = @podetails-comp_code
          AND plant = @podetails-plant
          AND idfyear = @podetails-imfyear
          AND idtype = @podetails-imtype
          AND idno = @podetails-imno
          AND idprdcode NE @roundoffproduct
        INTO TABLE @DATA(po_lines).

        " Get purchasing organization
        REPLACE ALL OCCURRENCES OF 'CV' IN podetails-cust_code WITH ''.

        SELECT SINGLE FROM i_plantpurchasingorganization
        FIELDS PurchasingOrganization
        WHERE Plant = @podetails-cust_code
        INTO @DATA(purchasingorganization).

        SELECT SINGLE FROM ztable_plant
        FIELDS comp_code, stporeceiveenabled, purchasecostcenter
        WHERE plant_code = @podetails-cust_code
        INTO @DATA(compcode).

        IF compcode-stporeceiveenabled IS INITIAL.
          podetails-error_log = |PO Receiving not enabled for plant { podetails-cust_code }|.
          UPDATE zinv_mst SET error_log = @podetails-error_log WHERE imno = @podetails-imno AND comp_code = @podetails-comp_code
                                                                AND plant = @podetails-plant AND imfyear = @podetails-imfyear
                                                                AND imtype = @podetails-imtype.
          CONTINUE.
        ENDIF.

        LOOP AT po_lines INTO DATA(pol).
          pol-idprdqty = pol-idprdqty + pol-idprdqtyf.
          pol-idprdrate = ( pol-idprdrate - ( pol-idtotaldiscamt / pol-idprdqty ) ) * 100.
          MODIFY po_lines FROM pol.
          CLEAR : pol.
        ENDLOOP.

        DATA: mycid TYPE string.
        IF mat_false = 0.
          mycid = |H001{ custref }|.
          " Create PO using RAP

          IF po_lines[ 1 ]-scrap_prd = 'S1'.

            SELECT SINGLE FROM zr_integration_tab
            FIELDS intgpath
            WHERE intgmodule = 'SCRAP-PURCHASE-GL'
            INTO @DATA(scrap_gl).

            MODIFY ENTITIES OF i_purchaseordertp_2
              ENTITY PurchaseOrder
                  CREATE FIELDS ( PurchaseOrderType CompanyCode PurchasingOrganization PurchasingGroup Supplier PurchaseOrderDate CorrespncExternalReference )
                  WITH VALUE #( (
                      %cid = mycid
                      %data = VALUE #(
                          PurchaseOrderType = 'ZSCP'
                          CompanyCode = compcode-comp_code
                          PurchasingOrganization = purchasingorganization
                          PurchasingGroup = '106'
                          Supplier = supplier
                          PurchaseOrderDate = podetails-imdate
                          CorrespncExternalReference = custref
                      )
                      %control = VALUE #(
                             purchaseordertype      = cl_abap_behv=>flag_changed
                             companycode            = cl_abap_behv=>flag_changed
                             purchasingorganization = cl_abap_behv=>flag_changed
                             purchasinggroup        = cl_abap_behv=>flag_changed
                             supplier               = cl_abap_behv=>flag_changed
                             purchaseorderdate     = cl_abap_behv=>flag_changed
                             correspncexternalreference = cl_abap_behv=>flag_changed
                      )
                  ) )

              CREATE BY \_purchaseorderitem
                   FROM VALUE #( ( %cid_ref = mycid
                        PurchaseOrder = space
                        %target = VALUE #( FOR po_line IN po_lines INDEX INTO i (
                              %cid =  |I{ i WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                              Material = po_line-idprdcode
                              OrderQuantity = po_line-idprdqty
                              Plant = podetails-cust_code
                              Batch = po_line-idprdbatch
                              PurgDocPriceDate = podetails-imdate
                              TaxCode = po_line-input_tax
                              AccountAssignmentCategory = 'K'
                              StorageLocation = 'SC01'
                              %control = VALUE #(
                                      plant                     = cl_abap_behv=>flag_changed
                                      orderquantity             = cl_abap_behv=>flag_changed
                                      purchaseorderitem         = cl_abap_behv=>flag_changed
                                      batch                     = cl_abap_behv=>flag_changed
                                      purgdocpricedate          = cl_abap_behv=>flag_changed
                                      TaxCode                   = cl_abap_behv=>flag_changed
                                      accountassignmentcategory = cl_abap_behv=>flag_changed
                                      storagelocation           = cl_abap_behv=>flag_changed
                              )
                          ) )
                       ) )
               ENTITY PurchaseOrderItem
              CREATE BY \_PurOrdPricingElement
              FIELDS ( conditiontype conditionrateamount conditioncurrency conditionquantity )
              WITH VALUE #(
                FOR po_line IN po_lines INDEX INTO j
                (
                  %cid_ref = |I{ j WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                  PurchaseOrder = space
                  PurchaseOrderItem = space
                  %target = VALUE #(
                  ( %cid =  |ITMPUR{ j }_01|
                      conditiontype = 'PMP0'
                      conditionrateamount = po_line-idprdrate "( po_line-idprdrate - ( po_line-idtotaldiscamt / po_line-idprdqty ) ) * 100
                      conditioncurrency = 'INR'
                      conditionquantity = 100
                    )
                  )
                )
              )
              ENTITY PurchaseOrderItem
              CREATE BY \_PurOrdAccountAssignment
              FIELDS ( CostCenter GLAccount AccountAssignmentNumber FunctionalArea ControllingArea )
              WITH VALUE #(
                FOR po_line IN po_lines INDEX INTO j
                (
                  %cid_ref = |I{ j WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                  PurchaseOrder = space
                  PurchaseOrderItem = space
                  %target = VALUE #(
                  ( %cid =  |ITMPURACC{ j }_01|
                      CostCenter = compcode-purchasecostcenter
                      GLAccount = |{ scrap_gl ALPHA = IN }|
                      AccountAssignmentNumber = |{ j WIDTH = 1 ALIGN = RIGHT PAD = '0' }|
                      FunctionalArea = 'YB40'
*                      ControllingArea = 'A000'
                    )
                  )
                )
              )

              REPORTED DATA(ls_po_reported)
              FAILED DATA(ls_po_failed)
              MAPPED DATA(ls_po_mapped).
          ELSE.

            MODIFY ENTITIES OF i_purchaseordertp_2
              ENTITY PurchaseOrder
                  CREATE FIELDS ( PurchaseOrderType CompanyCode PurchasingOrganization PurchasingGroup Supplier PurchaseOrderDate CorrespncExternalReference )
                  WITH VALUE #( (
                      %cid = mycid
                      %data = VALUE #(
                          PurchaseOrderType = 'ZSTO'
                          CompanyCode = compcode-comp_code
                          PurchasingOrganization = purchasingorganization
                          PurchasingGroup = '106'
                          Supplier = supplier
                          PurchaseOrderDate = podetails-imdate
                          CorrespncExternalReference = custref
                      )
                      %control = VALUE #(
                             purchaseordertype      = cl_abap_behv=>flag_changed
                             companycode            = cl_abap_behv=>flag_changed
                             purchasingorganization = cl_abap_behv=>flag_changed
                             purchasinggroup        = cl_abap_behv=>flag_changed
                             supplier               = cl_abap_behv=>flag_changed
                             purchaseorderdate     = cl_abap_behv=>flag_changed
                             correspncexternalreference = cl_abap_behv=>flag_changed
                      )
                  ) )

              CREATE BY \_purchaseorderitem
                   FROM VALUE #( ( %cid_ref = mycid
                        PurchaseOrder = space
                        %target = VALUE #( FOR po_line IN po_lines INDEX INTO i (
                              %cid =  |I{ i WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                              Material = po_line-idprdcode
                              OrderQuantity = po_line-idprdqty
                              Plant = podetails-cust_code
                              Batch = po_line-idprdbatch
                              PurgDocPriceDate = podetails-imdate
                              TaxCode = po_line-input_tax
                              %control = VALUE #(
                                      plant             = cl_abap_behv=>flag_changed
                                      orderquantity     = cl_abap_behv=>flag_changed
                                      purchaseorderitem = cl_abap_behv=>flag_changed
                                      batch             = cl_abap_behv=>flag_changed
                                      purgdocpricedate  = cl_abap_behv=>flag_changed
                                      TaxCode           = cl_abap_behv=>flag_changed
                              )
                          ) )
                       ) )
              ENTITY PurchaseOrderItem
              CREATE BY \_PurOrdPricingElement
              FIELDS ( conditiontype conditionrateamount conditioncurrency conditionquantity )
              WITH VALUE #(
                FOR po_line IN po_lines INDEX INTO j
                (
                  %cid_ref = |I{ j WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                  PurchaseOrder = space
                  PurchaseOrderItem = space
                  %target = VALUE #(
                  ( %cid =  |ITMPUR{ j }_01|
                      conditiontype = 'PMP0'
                      conditionrateamount = po_line-idprdrate "( po_line-idprdrate - ( po_line-idtotaldiscamt / po_line-idprdqty ) ) * 100
                      conditioncurrency = 'INR'
                      conditionquantity = 100
                    )
                  )
                )
              )
              REPORTED ls_po_reported
              FAILED ls_po_failed
              MAPPED ls_po_mapped.
          ENDIF.


          COMMIT ENTITIES BEGIN
             RESPONSE OF i_purchaseordertp_2
             FAILED DATA(ls_save_failed)
             REPORTED DATA(ls_save_reported).
          COMMIT ENTITIES END.

          IF ls_po_failed IS INITIAL.
            " PO created successfully - update record
            SELECT SINGLE FROM i_purchaseorderapi01 AS a
            FIELDS a~PurchaseOrder
            WHERE a~Supplier = @supplier
            "  AND a~PurchaseOrderDate = @podetails-imdate
              AND a~CorrespncExternalReference = @custref
            INTO @DATA(purchase_order).

*            CALL METHOD zcl_creategateentry=>creategateentry
*              EXPORTING
*                iv_po      = purchase_order
*                iv_ref     = custref
*                iv_vehicle = podetails-vehicleno
*                entrydate  = podetails-imdate
*              IMPORTING
*                gate_entry = gate_entry
*                message    = lv_error.

            UPDATE zinv_mst SET po_processed = 1, po_no = @purchase_order,   error_log = @lv_error
                WHERE imno = @podetails-imno
                AND comp_code = @podetails-comp_code
                AND plant = @podetails-plant
                AND imfyear = @podetails-imfyear
                AND imtype = @podetails-imtype.

          ELSE.
            " Handle errors
            CLEAR lv_error.

            IF lines( ls_save_reported-purchaseorder ) > 0.
              lv_error = |{ Sy-msgid } { sy-msgno }|.
            ENDIF.

            LOOP AT ls_save_reported-purchaseorder ASSIGNING FIELD-SYMBOL(<fs_error>).
              lv_error = lv_error && | { <fs_error>-%msg->if_message~get_text( ) } |.
            ENDLOOP.

            LOOP AT ls_po_reported-purchaseorderaccountassignment ASSIGNING FIELD-SYMBOL(<fs_error1>).
              lv_error = lv_error && | { <fs_error1>-%msg->if_message~get_text( ) } |.
            ENDLOOP.


            podetails-error_log = lv_error.
            UPDATE zinv_mst SET error_log = @podetails-error_log WHERE imno = @podetails-imno AND comp_code = @podetails-comp_code
                                                                 AND plant = @podetails-plant AND imfyear = @podetails-imfyear
                                                                 AND imtype = @podetails-imtype.
          ENDIF.


        ELSE.
          podetails-error_log = |Roundoff product not found for { podetails-imno }|.
          UPDATE zinv_mst SET error_log = @podetails-error_log WHERE imno = @podetails-imno AND comp_code = @podetails-comp_code
                                                                AND plant = @podetails-plant AND imfyear = @podetails-imfyear
                                                                AND imtype = @podetails-imtype.
        ENDIF.
        CLEAR: po_lines, purchase_order.
      ENDIF.
      mat_false = 0.
      CLEAR : podetails.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
