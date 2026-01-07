CLASS zc_grnpurchase DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

   PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .


    INTERFACES if_oo_adt_classrun .

   CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

   CLASS-METHODS runJob  .
   CLASS-METHODS update_document.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZC_GRNPURCHASE IMPLEMENTATION.


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
          ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Purchase Order GRN'   lowercase_ind = abap_true changeable_ind = abap_true )
        ).

        " Return the default parameters values here
        et_parameter_val = VALUE #(
          ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Purchase Order GRN' )
        ).

    ENDMETHOD.


    METHOD if_apj_rt_exec_object~execute.
        update_document(  ).
        runJob(  ).
    ENDMETHOD.


    METHOD if_oo_adt_classrun~main .
        update_document(  ).
        runJob(  ).
    ENDMETHOD.


    METHOD runJob.
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
        SELECT a~imno,a~comp_code,a~plant,a~imfyear,a~imtype,a~po_no,a~cust_code, a~imdate,a~gate_entry_no FROM zinv_mst AS a
           INNER JOIN zinv_mst_filter AS b
           ON a~comp_code  = b~comp_code
            AND a~plant      = b~plant
            AND a~imfyear    = b~imfyear
            AND a~imtype     = b~imtype
            AND a~imno       = b~imno
            WHERE a~po_processed = 1 AND a~migo_processed = 0 AND a~gate_entry_no NE ''
            ORDER BY a~last_changed_at ASCENDING
            INTO TABLE @DATA(GRNList).

      ELSE.
        SELECT imno,comp_code,plant,imfyear,imtype,po_no,cust_code, imdate, gate_entry_no FROM zinv_mst
            WHERE po_processed = 1 AND migo_processed = 0 AND gate_entry_no NE ''
            ORDER BY last_changed_at ASCENDING
            INTO TABLE @GRNList.
      ENDIF.

      LOOP AT GRNList INTO DATA(GRNDetails).

        CONCATENATE  GRNDetails-plant GRNDetails-imfyear GRNDetails-imno INTO refno .

*           Getting Line Details
        SELECT FROM zinvoicedatatab1 AS a
            JOIN I_PurchaseOrderItemAPI01 AS b ON a~idprdcode = b~Material
            FIELDS a~scrap_prd, a~idqtybag, a~remarks, a~idcat, a~idid, a~idno, a~idpartycode, a~idprdbatch, a~idprdcode, a~idprdqty, a~idprdqtyf,a~idprdrate, a~idtdiscamt, b~PurchaseOrderItem, b~PurchaseOrderQuantityUnit
            WHERE a~comp_code = @GRNDetails-comp_code AND a~plant = @GRNDetails-plant AND a~idfyear = @GRNDetails-imfyear AND  a~idtype = @GRNDetails-imtype
            AND a~idno = @GRNDetails-imno AND b~PurchaseOrder = @GRNDetails-po_no
            INTO TABLE @DATA(grn_lines).


*           Getting Plant
        REPLACE ALL OCCURRENCES OF 'CV' IN GRNDetails-cust_code WITH ''.
        CONCATENATE 'CV' GRNDetails-plant INTO DATA(Supplier).

*           Creating MIGO
        DATA(MIGOcid) = getCID(  ).
        MODIFY ENTITIES OF i_materialdocumenttp
        ENTITY materialdocument
        CREATE FROM VALUE #( (
            %cid                          =  MIGOcid
            postingdate                   =  GRNDetails-imdate
            documentdate                  =  GRNDetails-imdate      "cl_abap_context_info=>get_system_date(  )
            GoodsMovementCode             =  '01'
*                ReferenceDocument             =  GRNDetails-po_no
            MaterialDocumentHeaderText    =  grndetails-gate_entry_no
            ReferenceDocument             =  refno

            %control = VALUE #(
                postingdate                         = cl_abap_behv=>flag_changed
                documentdate                        = cl_abap_behv=>flag_changed
                ReferenceDocument                   = cl_abap_behv=>flag_changed
                GoodsMovementCode                   = cl_abap_behv=>flag_changed
                MaterialDocumentHeaderText          = cl_abap_behv=>flag_changed
                )
            ) )
            CREATE BY \_materialdocumentitem
            FROM VALUE #( (
                    %cid_ref = MIGOcid
                    %target = VALUE #( FOR po_line IN GRN_lines INDEX INTO i (
                        %cid =  |{ MIGOcid }{ i WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                         plant                              =  GRNDetails-cust_code
                         Material                           =  po_line-idprdcode
                         goodsmovementtype                  =  '101'
                         storagelocation                    =  COND #(
                                                                        WHEN po_line-scrap_prd = 'S1' THEN 'SC01'
                                                                        ELSE wa_fgstoragelocation
                                                               )
                         PurchaseOrder                      =  GRNDetails-po_no
                         GoodsMovementRefDocType            =  'B'
                         PurchaseOrderItem                  =  po_line-PurchaseOrderItem
                         Supplier                           =  Supplier
                         Batch                              =  po_line-idprdbatch
                         Quantityinentryunit                =  po_line-idprdqty + po_line-idprdqtyf
                         entryunit                          =  po_line-PurchaseOrderQuantityUnit
                         materialdocumentitemtext           =  refno
                         %control = VALUE #(
                                plant                       = cl_abap_behv=>flag_changed
                                Material                    = cl_abap_behv=>flag_changed
                                storagelocation             = cl_abap_behv=>flag_changed
                                GoodsMovementType           = cl_abap_behv=>flag_changed
                                PurchaseOrder               = cl_abap_behv=>flag_changed
                                purchaseorderitem           = cl_abap_behv=>flag_changed
                                Supplier                    = cl_abap_behv=>flag_changed
                                Quantityinentryunit         = cl_abap_behv=>flag_changed
                                EntryUnit                   = cl_abap_behv=>flag_changed
                                GoodsMovementRefDocType     = cl_abap_behv=>flag_changed
                                materialdocumentitemtext    = cl_abap_behv=>flag_changed
                        )
                    ) )
                 ) )
        MAPPED   DATA(ls_create_mappedi2)
        FAILED   DATA(ls_create_failedi2)
        REPORTED DATA(ls_create_reportedi2).

        COMMIT ENTITIES BEGIN
        RESPONSE OF i_materialdocumenttp
        FAILED DATA(commit_failedi2)
        REPORTED DATA(commit_reportedi2).

*            IF lines( ls_create_mappedi2-materialdocument ) > 0.
*                LOOP AT ls_create_mappedi2-materialdocument ASSIGNING FIELD-SYMBOL(<fs_migo>).
*                  CONVERT KEY OF i_materialdocumenttp FROM <fs_migo>-%pid TO <fs_migo>-%key.
*                  DATA(migo_no) = <fs_migo>-%key-MaterialDocument.
*                ENDLOOP.
*            ENDIF.

        COMMIT ENTITIES END.

        IF ls_create_failedi2 IS NOT INITIAL OR commit_failedi2 IS NOT INITIAL.

          DATA error TYPE string.

          LOOP AT ls_create_reportedi2-materialdocument ASSIGNING FIELD-SYMBOL(<fs_error>).
            error = | { <fs_error>-%msg->if_message~get_text( ) } |.
          ENDLOOP.

          LOOP AT ls_create_reportedi2-materialdocumentitem ASSIGNING FIELD-SYMBOL(<fs_error2>).
            error = | { <fs_error2>-%msg->if_message~get_text( ) } |.
          ENDLOOP.

          LOOP AT commit_reportedi2-materialdocument ASSIGNING FIELD-SYMBOL(<fs_error3>).
            error = | { <fs_error3>-%msg->if_message~get_text( ) } |.
          ENDLOOP.

          LOOP AT commit_reportedi2-materialdocumentitem ASSIGNING FIELD-SYMBOL(<fs_error4>).
            error = | { <fs_error4>-%msg->if_message~get_text( ) } |.
          ENDLOOP.

          DATA(current_timestamp) = cl_abap_context_info=>get_system_date(  ) && cl_abap_context_info=>get_system_time(  ).

          UPDATE zinv_mst SET error_log = @error , last_changed_at = @current_timestamp
          WHERE comp_code = @GRNDetails-comp_code AND plant = @GRNDetails-plant
                      AND imno = @GRNDetails-imno AND imtype = @GRNDetails-imtype
                      AND imfyear = @GRNDetails-imfyear.

          EXIT.

        ELSE.
          SELECT SINGLE FROM I_MaterialDocumentHeader_2
          FIELDS MaterialDocument
          WHERE ReferenceDocument = @refno
          AND MaterialDocumentHeaderText = @grndetails-gate_entry_no
          AND Plant = @GRNDetails-cust_code
          AND PostingDate = @GRNDetails-imdate
          INTO @DATA(mdit).


          UPDATE zinv_mst SET migo_processed = 1, migo_no = @mdit, error_log = ''
          WHERE comp_code = @GRNDetails-comp_code AND plant = @GRNDetails-plant AND imno = @GRNDetails-imno
          AND imtype = @GRNDetails-imtype AND imfyear = @GRNDetails-imfyear.
        ENDIF.

      ENDLOOP.

    ENDMETHOD.


    METHOD update_document.

      SELECT imno,comp_code,plant,imfyear,imtype,po_no,cust_code, imdate, gate_entry_no FROM zinv_mst
             WHERE po_processed = 1 AND migo_processed = 0 and gate_entry_no NE ''
             INTO TABLE @DATA(GRNList).

      LOOP AT GRNList INTO DATA(GRNDetails).

        REPLACE ALL OCCURRENCES OF 'CV' IN GRNDetails-cust_code WITH ''.

        SELECT SINGLE FROM I_MaterialDocumentHeader_2
          FIELDS MaterialDocument
          WHERE MaterialDocumentHeaderText = @GRNDetails-gate_entry_no
          AND Plant = @GRNDetails-cust_code
          AND PostingDate = @GRNDetails-imdate
          INTO @DATA(mdit).

        IF mdit IS INITIAL.
          CONTINUE.
        ENDIF.

        UPDATE zinv_mst SET migo_processed = 1, migo_no = @mdit, error_log = ''
        WHERE comp_code = @GRNDetails-comp_code AND plant = @GRNDetails-plant AND imno = @GRNDetails-imno
        AND imtype = @GRNDetails-imtype AND imfyear = @GRNDetails-imfyear.
        CLEAR mdit.

      ENDLOOP.

    ENDMETHOD.
ENDCLASS.
