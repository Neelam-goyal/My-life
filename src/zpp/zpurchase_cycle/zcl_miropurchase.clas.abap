CLASS zcl_miropurchase DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .

    CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

    CLASS-METHODS runJob
      IMPORTING imno TYPE zinv_mst-imno.
    CLASS-METHODS update_document
      IMPORTING imno TYPE zinv_mst-imno.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_miropurchase IMPLEMENTATION.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.

    " Define supported selection parameters
    et_parameter_def = VALUE #(
      ( selname        = 'P_DESCR'
        kind           = if_apj_dt_exec_object=>parameter
        datatype       = 'C'
        length         = 80
        param_text     = 'Purchase Order MIRO'
        lowercase_ind  = abap_true
        changeable_ind = abap_true )
    ).

    " Set default parameter values
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR'
        kind    = if_apj_dt_exec_object=>parameter
        sign    = 'I'
        option  = 'EQ'
        low     = 'Purchase Order MIRO' )
    ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA p_descr TYPE c LENGTH 8.

    " Getting the actual parameter values
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'P_DESCR'. p_descr = ls_parameter-low.
      ENDCASE.
    ENDLOOP.
    update_document( p_descr ).
    runJob( p_descr ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main .
    update_document( '' ).
    runJob( '' ).
  ENDMETHOD.


  METHOD runjob.
    DATA refno TYPE string.
    DATA timestamp TYPE timestampl.

    SELECT SINGLE FROM zintegration_tab
      FIELDS intgpath
      WHERE intgmodule  = 'SALESFILTER'
      INTO  @DATA(it_integration).

    SELECT SINGLE FROM zintegration_tab AS a
        FIELDS a~intgpath
        WHERE a~intgmodule = 'FGSTORAGELOCATION'
        INTO @DATA(wa_fgstoragelocation).

    IF it_integration IS NOT INITIAL AND it_integration NE ''.
      SELECT a~imno,a~comp_code,a~plant,a~imfyear,
      a~imtype,a~po_no,a~migo_no ,a~cust_code, a~imdate,a~gate_entry_no,
      a~imvogamt , c~paymentterms , a~imnetamtro
      FROM zinv_mst AS a
      LEFT JOIN I_PurchaseOrderAPI01 AS c ON a~po_no = c~PurchaseOrder
      INNER JOIN zinv_mst_filter AS b
      ON a~comp_code  = b~comp_code
       AND a~plant      = b~plant
       AND a~imfyear    = b~imfyear
       AND a~imtype     = b~imtype
       AND a~imno       = b~imno
       WHERE a~po_processed = 1 AND a~migo_processed = 1 AND a~miro_processed = 0
       AND ( a~imno = @imno OR @imno = '' )
       ORDER BY a~last_changed_at ASCENDING
       INTO TABLE @DATA(MIROList).

    ELSE.

      SELECT imno,comp_code,plant,imfyear,imtype,
             po_no,migo_no,cust_code, imdate,
             gate_entry_no,imvogamt ,
             c~paymentterms , a~imnetamtro
             FROM zinv_mst AS a
             LEFT JOIN I_PurchaseOrderAPI01 AS c ON a~po_no = c~PurchaseOrder
              WHERE po_processed = 1 AND migo_processed = 1 AND miro_processed = 0
              AND ( a~imno = @imno OR @imno = '' )
              ORDER BY last_changed_at ASCENDING
              INTO TABLE @MIROList.
    ENDIF.

    DATA ls_invoice TYPE STRUCTURE FOR ACTION IMPORT i_supplierinvoicetp~create.
    DATA lt_invoice TYPE TABLE FOR ACTION IMPORT i_supplierinvoicetp~create.

    LOOP AT mirolist INTO DATA(MIRODetails).

      SELECT SINGLE FROM i_materialdocumentitem_2 AS a
          FIELDS a~ReversedMaterialDocument
           WHERE a~ReversedMaterialDocument = @mirodetails-migo_no
           INTO @DATA(material_document).

      IF material_document IS NOT INITIAL.

        DATA(err) = |MIRO not created: Material document { mirodetails-migo_no } is cancelled.|.

        DATA(lv_timestamp) =
          cl_abap_context_info=>get_system_date( ) &&
          cl_abap_context_info=>get_system_time( ).

        UPDATE zinv_mst
          SET error_log       = @err,
              last_changed_at = @lv_timestamp
          WHERE comp_code = @mirodetails-comp_code
            AND plant     = @mirodetails-plant
            AND imno      = @mirodetails-imno
            AND imtype    = @mirodetails-imtype
            AND imfyear   = @mirodetails-imfyear.

        CONTINUE.
      ENDIF.


*      CONCATENATE mirodetails-plant mirodetails-migo_no INTO refno.

*          Getting Line Details
      SELECT FROM zinvoicedatatab1 AS a
          JOIN I_PurchaseOrderItemAPI01 AS b ON a~idprdcode = b~Material
          FIELDS a~idqtybag, a~remarks, a~idcat,
           a~idid, a~idno, a~idpartycode, a~idprdbatch,
           a~idprdcode, a~idprdqty, a~idprdqtyf,
           a~idprdrate, a~idtdiscamt, a~idprdamt,
           a~idprdnamt,a~input_tax, a~idfyear,
           b~PurchaseOrderItem, b~PurchaseOrderQuantityUnit , a~scrap_prd
          WHERE a~comp_code = @mirodetails-comp_code
          AND a~plant = @mirodetails-plant
          AND a~idfyear = @mirodetails-imfyear
          AND a~idtype = @mirodetails-imtype
          AND a~idno = @mirodetails-imno AND b~PurchaseOrder = @mirodetails-po_no
          INTO TABLE @DATA(miro_lines).


      DATA(miro_tobe_process) = 1.

      LOOP AT miro_lines INTO DATA(miro_item).

        IF miro_item-scrap_prd = 'S1' OR miro_item-scrap_prd = 'R2'.
          miro_tobe_process = 0.
        ENDIF.

        CLEAR : miro_item.

      ENDLOOP.

      IF miro_tobe_process = 1.

*      Getting Plant
        REPLACE ALL OCCURRENCES OF 'CV' IN MIRODetails-cust_code WITH ''.
        CONCATENATE 'CV' MIRODetails-plant INTO DATA(Supplier).

        SELECT SINGLE FROM ztable_plant AS a
        FIELDS comp_code
        WHERE a~plant_code = @mirodetails-cust_code
        INTO @DATA(companycode_po).

        SELECT SINGLE FROM i_materialdocumentitem_2 AS a
        FIELDS a~MaterialDocumentYear
        WHERE  a~MaterialDocument = @mirodetails-migo_no
        INTO @DATA(material_document_year).

*        DATA(lv_year) = fiscal_year(4).   " -> '2025' IN consideration

*     Creating MIRO
        DATA(MIROcid) = getCID(  ).
        ls_invoice-%cid = MIROcid.
        ls_invoice-%param-supplierinvoiceiscreditmemo = abap_false.
        ls_invoice-%param-companycode = companycode_po.
        ls_invoice-%param-invoicingparty = Supplier.
        ls_invoice-%param-postingdate = mirodetails-imdate.
        ls_invoice-%param-documentdate = mirodetails-imdate.
        ls_invoice-%param-documentcurrency = 'INR'.
        ls_invoice-%param-invoicegrossamount = mirodetails-imnetamtro.
        ls_invoice-%param-taxiscalculatedautomatically = abap_true.
        ls_invoice-%param-taxdeterminationdate = mirodetails-imdate.
        ls_invoice-%param-BusinessSectionCode = companycode_po.
        ls_invoice-%param-assignmentreference = mirodetails-migo_no.
        ls_invoice-%param-supplierinvoiceidbyinvcgparty = |{ mirodetails-imfyear }{ mirodetails-imno }|.

*      IF mirodetails-comp_code = companycode_po.
*
*        ls_invoice-%param-_withholdingtaxes = VALUE #(
*          ( WithholdingTaxType = '4Q'
*            WithholdingTaxCode = ''
*            DocumentCurrency = 'INR'
*            WhldgTxBaseAmtInDocCry = ''
*            MnllyEnteredWhldgTxAmtInDocCry = ''
*
*        ) ).
*
*      ENDIF.

        ls_invoice-%param-_itemswithporeference = VALUE #( FOR miro_line IN miro_lines INDEX INTO i

       ( supplierinvoiceitem = |{ i WIDTH = 5 ALIGN = RIGHT PAD = '0' }|
         purchaseorder = mirodetails-po_no
         purchaseorderitem = miro_line-PurchaseOrderItem
         documentcurrency = 'INR'
         supplierinvoiceitemamount = miro_line-idprdamt
         purchaseorderquantityunit = miro_line-PurchaseOrderQuantityUnit
         quantityinpurchaseorderunit = miro_line-idprdqty
         taxcode = miro_line-input_tax
         referencedocument = mirodetails-migo_no
         referencedocumentfiscalyear = material_document_year
         referencedocumentitem = |{ i WIDTH = 4 ALIGN = RIGHT PAD = '0' }|
            )
                ).

        INSERT ls_invoice INTO TABLE lt_invoice.

        "Register the action
        MODIFY ENTITIES OF i_supplierinvoicetp
        ENTITY supplierinvoice
        EXECUTE create FROM lt_invoice
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported)
        MAPPED DATA(ls_mapped).

        "Execution the action
        COMMIT ENTITIES BEGIN
         RESPONSE OF i_supplierinvoicetp
         FAILED DATA(ls_commit_failed)
         REPORTED DATA(ls_commit_reported).
        COMMIT ENTITIES END.

        IF ls_failed IS NOT INITIAL OR ls_commit_failed IS NOT INITIAL.

          DATA error TYPE string.

          LOOP AT ls_reported-supplierinvoice ASSIGNING FIELD-SYMBOL(<fs_error>).
            DATA(error1) = | { <fs_error>-%msg->if_message~get_text( ) } |.
            CONCATENATE error error1 INTO error SEPARATED BY ' '.
          ENDLOOP.

          LOOP AT ls_commit_reported-supplierinvoice ASSIGNING FIELD-SYMBOL(<fs_error3>).
            DATA(error2) = | { <fs_error3>-%msg->if_message~get_text( ) } |.
            CONCATENATE error error2 INTO error SEPARATED BY ' '.
          ENDLOOP.

          DATA(current_timestamp) = cl_abap_context_info=>get_system_date(  ) && cl_abap_context_info=>get_system_time(  ).

          UPDATE zinv_mst SET error_log = @error , last_changed_at = @current_timestamp
          WHERE comp_code = @MIRODetails-comp_code AND plant = @MIRODetails-plant
                      AND imno = @MIRODetails-imno AND imtype = @MIRODetails-imtype
                      AND imfyear = @MIRODetails-imfyear.

        ELSE.

          IF ls_commit_reported IS NOT INITIAL.
            LOOP AT ls_commit_reported-supplierinvoice ASSIGNING FIELD-SYMBOL(<ls_invoice>).
              IF <ls_invoice>-supplierinvoice IS NOT INITIAL AND
              <ls_invoice>-supplierinvoicefiscalyear IS NOT INITIAL.
                DATA(miro) = <ls_invoice>-supplierinvoice .
              ENDIF.
            ENDLOOP.
          ENDIF.

          UPDATE zinv_mst SET miro_processed = 1, miro_no = @miro, error_log = ''
          WHERE comp_code = @MIROdetails-comp_code AND plant = @MIROdetails-plant
                  AND imno = @MIROdetails-imno AND imtype = @MIROdetails-imtype
                  AND imfyear = @MIROdetails-imfyear.

        ENDIF.

        CLEAR : ls_invoice , lt_invoice , miro , companycode_po.

      ELSE .

*        DATA(error_miro) = 'Miro Can not be created'.
*        UPDATE zinv_mst SET error_log = @error_miro , last_changed_at = @current_timestamp
*        WHERE comp_code = @MIRODetails-comp_code AND plant = @MIRODetails-plant
*                  AND imno = @MIRODetails-imno AND imtype = @MIRODetails-imtype
*                  AND imfyear = @MIRODetails-imfyear.

        miro_tobe_process = 0.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD update_document.
    SELECT imno,comp_code,plant,imfyear,imtype,po_no,
    cust_code, imdate , migo_no
    FROM zinv_mst
         WHERE po_processed = 1 AND migo_processed = 1 AND miro_processed = 0
         AND ( imno = @imno OR @imno = '' )
         INTO TABLE @DATA(MIROList).

    LOOP AT MIROList INTO DATA(MIRODetails).

*      CONCATENATE mirodetails-plant mirodetails-migo_no INTO refno.
      REPLACE ALL OCCURRENCES OF 'CV' IN MIRODetails-cust_code WITH ''.
      DATA(refno) = |{ mirodetails-imfyear }{ mirodetails-imno }|.

      SELECT SINGLE FROM I_SupplierInvoiceAPI01
         FIELDS SupplierInvoice
         WHERE SupplierInvoiceIDByInvcgParty = @refno
         AND ReverseDocument IS INITIAL
         AND PostingDate = @MIROdetails-imdate
         INTO @DATA(miro).

      IF miro IS INITIAL.
        CONTINUE.
      ENDIF.

      UPDATE zinv_mst SET miro_processed = 1, miro_no = @miro, error_log = ''
      WHERE comp_code = @MIRODetails-comp_code AND plant = @MIRODetails-plant AND imno = @MIRODetails-imno
      AND imtype = @MIRODetails-imtype AND imfyear = @MIRODetails-imfyear.
      CLEAR miro.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
