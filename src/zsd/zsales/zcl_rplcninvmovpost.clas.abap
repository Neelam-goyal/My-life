CLASS zcl_rplcninvmovpost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.


    TYPES: BEGIN OF ty_item_list,
             Material          TYPE string,
             quantityinentryunit             TYPE P length 13 decimals 3,
             storageloc  type zdt_rplcrnote-location,
           END OF ty_item_list.
    CLASS-DATA itemList TYPE TABLE OF ty_item_list.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .
    CLASS-METHODS runJob
        IMPORTING paramcmno TYPE C.


    CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_RPLCNINVMOVPOST IMPLEMENTATION.


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
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Post Scrap Generation'   lowercase_ind = abap_true changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Post Scrap Generation' )
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


  METHOD if_oo_adt_classrun~main .
    runjob( '' ).
  ENDMETHOD.


  METHOD runjob.
    DATA: lt_cratesdata     TYPE TABLE OF zcratesdata.
    FIELD-SYMBOLS <ls_cratesdata> LIKE LINE OF lt_cratesdata.
    DATA plantno TYPE char05.
    DATA companycode TYPE c LENGTH 5.
    DATA cmno       TYPE  c LENGTH 10.
    DATA cmfyear    TYPE  c LENGTH 4.
    DATA cmtype     TYPE  c LENGTH 2.
    DATA wa_items TYPE ty_item_list.

    DATA refno TYPE string.
    DATA localparamno TYPE c LENGTH 20.

**********************************************************************

    SELECT SINGLE FROM zintegration_tab AS a
        FIELDS a~intgpath
        WHERE a~intgmodule = 'FGSTORAGELOCATION'
        INTO @DATA(wa_fgstoragelocation).

*   "Post Scrap Generation Data
    DATA : ltcrdata TYPE TABLE OF zdt_rplcrnote.
    localparamno = paramcmno.
    IF localparamno = ''.
      SELECT * FROM zdt_rplcrnote
          WHERE processed = ''
      INTO TABLE @ltcrdata.
    ELSE.
      SELECT * FROM zdt_rplcrnote
          WHERE processed = '' AND imno = @localparamno
      INTO TABLE @ltcrdata.
    ENDIF.

    LOOP AT ltcrdata INTO DATA(ls_crdata).
      IF ls_crdata-imwrapperwt <> 0 AND ls_crdata-imbreadwt <> 0.
        companycode = ls_crdata-comp_code.
        plantno = ls_crdata-implant.
        cmno    = ls_crdata-imno.
        cmfyear = ls_crdata-imfyear.

        DATA(Mycid2) = getCID(  ).
        CONCATENATE  ls_crdata-implant ls_crdata-imfyear ls_crdata-imtype ls_crdata-imno ls_crdata-imdealercode INTO refno SEPARATED BY '-'.

      DATA refno_limited TYPE C LENGTH 25.
      IF strlen( refno ) >= 25.
      refno_limited = refno+0(25).
      ELSE.
      refno_limited = refno.
      ENDIF.

      SELECT SINGLE FROM i_materialdocumenttp
      FIELDS MaterialDocument
      WHERE MaterialDocumentHeaderText = @refno_limited
      INTO @DATA(lv_mat_doc).

      IF lv_mat_doc IS NOT INITIAL.

       UPDATE zdt_rplcrnote
            SET processed = '1',
            error_log = '',
            scrapindoc = @lv_mat_doc
            WHERE comp_code = @companycode AND implant = @plantno AND imno = @cmno
            AND imfyear = @cmfyear AND imtype = @ls_crdata-imtype AND imdealercode = @ls_crdata-imdealercode.

              CLEAR lv_mat_doc.
        CONTINUE.
          ENDIF.

        IF ls_crdata-imbreadwt > 0.
          SELECT SINGLE FROM I_ProductStdVH
              FIELDS Product
              WHERE ProductExternalID = @ls_crdata-imbreadcode
              INTO @DATA(pcodeBread).

          IF pcodeBread IS NOT INITIAL.
            wa_items-Material                           =  pcodeBread.
            wa_items-quantityinentryunit                =  ls_crdata-imbreadwt.
            wa_items-storageloc                         =  ls_crdata-location.
            APPEND wa_items TO itemList.
            CLEAR: wa_items.
          ENDIF.
        ENDIF.

        IF ls_crdata-imwrapperwt > 0.
          SELECT SINGLE FROM I_ProductStdVH
              FIELDS Product
              WHERE ProductExternalID = @ls_crdata-imwrappercode
              INTO @DATA(pcodeWrapper).

          IF pcodeWrapper IS NOT INITIAL.
            wa_items-Material                           =  pcodeWrapper.
            wa_items-quantityinentryunit                =  ls_crdata-imwrapperwt.
            wa_items-storageloc                         =  ls_crdata-location.
            APPEND wa_items TO itemList.
            CLEAR: wa_items.
          ENDIF.
        ENDIF.


        IF lines( itemList ) > 0.

          MODIFY ENTITIES OF i_materialdocumenttp
          ENTITY materialdocument
          CREATE FROM VALUE #( ( %cid       = Mycid2
              goodsmovementcode             = '01'
              postingdate                   =  ls_crdata-imdate
              documentdate                  =  ls_crdata-imdate
              MaterialDocumentHeaderText    =  refno_limited
              %control = VALUE #(
                           postingdate                         = cl_abap_behv=>flag_changed
                           documentdate                        = cl_abap_behv=>flag_changed
                           GoodsMovementCode                   = cl_abap_behv=>flag_changed
                           MaterialDocumentHeaderText          = cl_abap_behv=>flag_changed
                           )
                       ) )
              CREATE BY \_materialdocumentitem
              FROM VALUE #( (
                      %cid_ref = Mycid2
                      %target =  VALUE #( FOR po_line IN itemList INDEX INTO i (
                                   %cid =  |{ Mycid2 }{ i WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                                    plant                              =  plantno
                                    Material                           =  po_line-Material
                                    goodsmovementtype                  =  '501'
                                    storagelocation                    =  po_line-storageloc
                                    Quantityinentryunit                =  po_line-QuantityInEntryUnit
                                    materialdocumentitemtext           =  refno
                                    %control = VALUE #(
                                           plant                       = cl_abap_behv=>flag_changed
                                           Material                    = cl_abap_behv=>flag_changed
                                           storagelocation             = cl_abap_behv=>flag_changed
                                           GoodsMovementType           = cl_abap_behv=>flag_changed
                                           Quantityinentryunit         = cl_abap_behv=>flag_changed
                                           materialdocumentitemtext    = cl_abap_behv=>flag_changed
                                   )
                               ) )
                            ) )

              MAPPED   DATA(ls_create_mappedcr)
              FAILED   DATA(ls_create_failedcr)
              REPORTED DATA(ls_create_reportedcr).

          COMMIT ENTITIES BEGIN
            RESPONSE OF i_materialdocumenttp
            FAILED DATA(commit_failedcr)
            REPORTED DATA(commit_reportedcr).
          ...
          COMMIT ENTITIES END.

          IF commit_failedcr IS INITIAL.
            SELECT SINGLE FROM I_MaterialDocumentHeader_2
              FIELDS MaterialDocument
              WHERE MaterialDocumentHeaderText = @refno_limited
              AND Plant = @plantno
              AND PostingDate = @ls_crdata-imdate
              INTO @DATA(mdit).

*           SELECT SINGLE FROM I_MaterialDocumentItem_2
*              FIELDS MaterialDocument
*              WHERE MaterialDocumentItemText = @refno
*              AND CompanyCode = @companycode AND Plant = @plantno
*              AND PostingDate = @ls_crdata-imdate
*              INTO @DATA(mdit).

            UPDATE zdt_rplcrnote
                SET processed = '1',
                error_log = '',
                scrapindoc = @mdit
                WHERE comp_code = @companycode AND implant = @plantno AND imno = @cmno
                AND imfyear = @cmfyear AND imtype = @ls_crdata-imtype AND imdealercode = @ls_crdata-imdealercode.
          ELSE.

            DATA: lv_cust_result TYPE char256.
            IF lines( commit_reportedcr-materialdocument ) > 0.
              lv_cust_result = |{ Sy-msgid } { sy-msgno }|.
            ELSEIF lines( commit_reportedcr-materialdocumentitem ) > 0.
              lv_cust_result = |{ Sy-msgid } { sy-msgno }|.
            ENDIF.

            UPDATE zdt_rplcrnote
                SET error_log = @lv_cust_result
                WHERE comp_code = @companycode AND implant = @plantno AND imno = @cmno
                AND imfyear = @cmfyear AND imtype = @ls_crdata-imtype AND imdealercode = @ls_crdata-imdealercode.
            CLEAR: lv_cust_result.
          ENDIF.
        ELSE.

          DATA: error_log TYPE string.
          IF pcodeWrapper IS INITIAL AND pcodeBread IS INITIAL.
            error_log = 'Product Not Found'.
          ELSEIF pcodeWrapper IS INITIAL.
            error_log = 'Zero Qty.'.
          ENDIF.
          UPDATE zdt_rplcrnote
              SET error_log = @error_log, processed = '1'
              WHERE comp_code = @companycode AND implant = @plantno AND imno = @cmno
              AND imfyear = @cmfyear AND imtype = @ls_crdata-imtype AND imdealercode = @ls_crdata-imdealercode.
        ENDIF.
        CLEAR:  refno ,refno_limited, pcodeBread, pcodeWrapper, commit_failedcr ,itemlist,commit_reportedcr, ls_create_mappedcr, ls_create_failedcr,ls_create_reportedcr,error_log,ls_crdata.

      ELSE.
        UPDATE zdt_rplcrnote
            SET processed = '1',
               error_log = '',
              scrapindoc = ''
            WHERE comp_code = @ls_crdata-comp_code AND implant = @ls_crdata-implant AND imno = @ls_crdata-imno
            AND imfyear = @ls_crdata-imfyear AND imtype = @ls_crdata-imtype AND imdealercode = @ls_crdata-imdealercode.
      ENDIF.
      CLEAR : lv_cust_result,mdit.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
