CLASS zcl_postmatvariance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .

    CLASS-METHODS getDate
      IMPORTING datestr       TYPE string
      RETURNING VALUE(result) TYPE d.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_POSTMATVARIANCE IMPLEMENTATION.


  METHOD getDate.
    DATA: lv_date_str TYPE string,
          lv_date     TYPE d.
    DATA: lv_date_part TYPE c LENGTH 10."= .  " '27/03/2025'

    lv_date_part = datestr(10).
    DATA: lv_day   TYPE c LENGTH 2,
          lv_month TYPE c LENGTH 2,
          lv_year  TYPE c LENGTH 4.

    lv_day   = lv_date_part(2).
    lv_month = lv_date_part+3(2).
    lv_year  = lv_date_part+6(4).
    CONCATENATE lv_year lv_month lv_day INTO result.
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Post Material Variance'   lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'P_DATE'  kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 10 param_text = 'Declaration Date'   lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'P_PLANT'  kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 4 param_text = 'Plant'   lowercase_ind = abap_true changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Post Material Variance' )
*      ( selname = 'P_DATE'  kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = cl_abap_context_info=>get_system_date( ) )
*      ( selname = 'P_PLANT'  kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'BBPL' )
    ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    TYPES ty_id TYPE c LENGTH 10.

    DATA s_id    TYPE RANGE OF ty_id.
    DATA p_descr TYPE c LENGTH 80.
    DATA p_count TYPE i.
    DATA p_simul TYPE abap_boolean.

    DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
    DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
    DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA: template  TYPE cl_apj_rt_api=>ty_template_name.
    DATA: p_date TYPE datn.
    DATA: p_plant TYPE c LENGTH 4.
    DATA prodorderdate TYPE datum.
    DATA plantno TYPE c LENGTH 4.
    DATA companycode TYPE c LENGTH 4.
    DATA productdesc TYPE char72.
    DATA productcode TYPE char72.
    DATA productbatch TYPE char72.
    DATA lt_confirmation TYPE TABLE FOR CREATE i_productionordconfirmationtp.
    DATA lt_matldocitm TYPE TABLE FOR CREATE i_productionordconfirmationtp\_prodnordconfmatldocitm.
    DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlines.

    FIELD-SYMBOLS <ls_matldocitm> LIKE LINE OF lt_matldocitm.
    DATA lt_target LIKE <ls_matldocitm>-%target.


    LOOP AT it_parameters INTO DATA(wa_parameter).
      CASE wa_parameter-selname.
        WHEN 'P_DATE'.
          p_date = wa_parameter-low.
        WHEN 'P_PLANT'  .
          p_plant =  wa_parameter-low.
      ENDCASE.
    ENDLOOP.

    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvariance' ##NO_TEXT.

    "Material Variance Posting
    IF p_plant IS NOT INITIAL AND p_date = '0'.
      SELECT SINGLE FROM zmaterialdist
      FIELDS bukrs, plantcode, declaredate, variancepostdate
      WHERE plantcode = @p_plant AND variancecalculated = 1 AND varianceposted = 1 AND varianceclosed = 0
      INTO @DATA(materialdistline).
    ELSEIF p_date IS NOT INITIAL AND p_plant IS NOT INITIAL.
      SELECT SINGLE FROM zmaterialdist
      FIELDS bukrs, plantcode, declaredate, variancepostdate
      WHERE  plantcode = @p_plant AND variancecalculated = 1 AND varianceposted = 1 AND varianceclosed = 0
      AND declaredate = @p_date
      INTO @materialdistline.
    ENDIF.

    companycode   = materialdistline-Bukrs.
    plantno       = materialdistline-Plantcode.
    prodorderdate = materialdistline-declaredate.

    SELECT SINGLE FROM zmatdistlines FIELDS productionorder , shiftnumber
    WHERE Bukrs = @companycode AND plantcode = @plantno AND declaredate = @prodorderdate
    AND varianceqty <> 0 AND varianceposted = 0
    INTO @DATA(wa_prdorder) PRIVILEGED ACCESS.

*    SELECT FROM zmatdistlines FIELDS productionorder, orderconfirmationgroup,
*    shiftnumber, shiftgroup, productcode, SUM( varianceqty ) AS varqty
*    WHERE Bukrs = @companycode AND plantcode = @plantno AND declaredate = @prodorderdate
*    AND varianceqty <> 0 AND varianceposted = 0 AND productionorder = @wa_prdorder-productionorder
*    AND shiftnumber = @wa_prdorder-shiftnumber
*    GROUP BY productionorder, orderconfirmationgroup, shiftnumber, shiftgroup, productcode
*    INTO TABLE @DATA(ltdlinegrp) PRIVILEGED ACCESS.

    SELECT SINGLE FROM zmatdistlines FIELDS productionorder, orderconfirmationgroup,
    shiftnumber, shiftgroup, productcode, varianceqty "SUM( varianceqty ) AS varqty
    WHERE Bukrs = @companycode AND plantcode = @plantno AND declaredate = @prodorderdate
    AND varianceqty <> 0 AND varianceposted = 0 AND productionorder = @wa_prdorder-productionorder
    AND shiftnumber = @wa_prdorder-shiftnumber
    GROUP BY productionorder, orderconfirmationgroup, shiftnumber, shiftgroup, productcode, varianceqty
    INTO @DATA(wadlinegrp) PRIVILEGED ACCESS.


*    SORT ltdlinegrp BY productionorder orderconfirmationgroup shiftnumber shiftgroup productcode.

*      IF wadlinegrp IS NOT INITIAL.
*      LOOP AT ltdlinegrp INTO DATA(wadlinegrp).
    IF wadlinegrp IS NOT INITIAL AND wadlinegrp-varianceqty IS NOT INITIAL.

      "read proposals and corresponding times for given quantity
      READ ENTITIES OF i_productionordconfirmationtp
      ENTITY productionorderconfirmation
      EXECUTE getconfproposal
      FROM VALUE #( ( confirmationgroup = wadlinegrp-orderconfirmationgroup
      %param-confirmationyieldquantity = 1 ) )
      RESULT DATA(lt_confproposal)
      REPORTED DATA(lt_reported_conf).

      LOOP AT lt_confproposal ASSIGNING FIELD-SYMBOL(<ls_confproposal>).
        " convert proposals to confirmations with goodsmovement
        APPEND INITIAL LINE TO lt_confirmation ASSIGNING FIELD-SYMBOL(<ls_confirmation>).
        <ls_confirmation>-%cid                      = 'Conf' && sy-tabix.
        <ls_confirmation>-%data                     = CORRESPONDING #( <ls_confproposal>-%param ).
        <ls_confirmation>-PostingDate               = materialdistline-variancepostdate.
        <ls_confirmation>-ConfirmationYieldQuantity = 0.
        <ls_confirmation>-OpConfirmedWorkQuantity1  = 0.
        <ls_confirmation>-OpConfirmedWorkQuantity2  = 0.
        <ls_confirmation>-OpConfirmedWorkQuantity3  = 0.
        <ls_confirmation>-OpConfirmedWorkQuantity4  = 0.
        <ls_confirmation>-OpConfirmedWorkQuantity5  = 0.
        <ls_confirmation>-OpConfirmedWorkQuantity6  = 0.
        <ls_confirmation>-ShiftDefinition           = wadlinegrp-shiftnumber.
        <ls_confirmation>-ShiftGrouping             = wadlinegrp-shiftgroup.

        " read proposals for corresponding goods movements for proposed quantity
        READ ENTITIES OF i_productionordconfirmationtp
        ENTITY productionorderconfirmation
        EXECUTE getgdsmvtproposal
        FROM VALUE #( ( confirmationgroup = <ls_confproposal>-confirmationgroup
        %param-confirmationyieldquantity = <ls_confproposal>-%param-confirmationyieldquantity ) )
        RESULT DATA(lt_gdsmvtproposal)
        REPORTED DATA(lt_reported_gdsmvt).

        CHECK lt_gdsmvtproposal[] IS NOT INITIAL.

        CLEAR lt_target[].


        LOOP AT lt_gdsmvtproposal ASSIGNING FIELD-SYMBOL(<ls_gdsmvtproposal>) WHERE confirmationgroup = <ls_confproposal>-confirmationgroup.

          SELECT FROM zmatdistlines AS mdlines
          FIELDS productionorder, orderconfirmationgroup, productcode, storagelocation, batchno, varianceqty, entryuom, shiftnumber
          WHERE mdlines~Bukrs = @companycode AND mdlines~plantcode = @plantno AND mdlines~declaredate = @prodorderdate
          AND mdlines~productionorder = @<ls_confirmation>-OrderID AND mdlines~orderconfirmationgroup = @<ls_confirmation>-ConfirmationGroup
          AND mdlines~shiftnumber = @<ls_confirmation>-ShiftDefinition
          AND mdlines~varianceqty <> 0 AND mdlines~varianceposted = 0
          INTO TABLE @DATA(ltdline).

          LOOP AT ltdline INTO DATA(waltdline).
            DATA lv_matnr TYPE I_Product-Product.
            lv_matnr = |{ waltdline-productcode ALPHA = OUT }| .
            SELECT FROM zmaterialdecl AS md
            FIELDS md~productcode, md~batchno, SUM( md~stockquantity ) AS qty
            WHERE md~bukrs = @companycode AND md~plantcode = @plantno
            AND md~declaredate = @prodorderdate AND md~productcode = @lv_matnr
            GROUP BY md~productcode, md~batchno
            INTO TABLE @DATA(ltStock).

            LOOP AT ltStock INTO DATA(waltStock).
              productbatch = waltstock-batchno.
            ENDLOOP.

            CLEAR lv_matnr .
            APPEND INITIAL LINE TO lt_target ASSIGNING FIELD-SYMBOL(<ls_target>).
            <ls_target>                       = CORRESPONDING #( <ls_gdsmvtproposal>-%param ).
            <ls_target>-%cid                  = 'Item' && sy-tabix.
            <ls_target>-Material              = waltdline-productcode.
            <ls_target>-StorageLocation       = waltdline-storagelocation.
            <ls_target>-GoodsMovementRefDocType = ''.
            <ls_target>-OrderItem             = '0'.
            <ls_target>-EntryUnit             = waltdline-entryuom.

            IF waltdline-varianceqty > 0.
              <ls_target>-GoodsMovementType   = '261'.
              <ls_target>-QuantityInEntryUnit = waltdline-varianceqty.
              <ls_target>-Batch               = productbatch.
            ELSE.
              <ls_target>-GoodsMovementType   = '262'.
              <ls_target>-QuantityInEntryUnit = -1 * waltdline-varianceqty.
              <ls_target>-Batch               = waltdline-batchno.
            ENDIF.

          ENDLOOP.

          CLEAR : ltdline.
        ENDLOOP.

        APPEND VALUE #( %cid_ref = <ls_confirmation>-%cid
            %target = lt_target
            confirmationgroup = <ls_confproposal>-confirmationgroup ) TO lt_matldocitm.
      ENDLOOP.

      MODIFY ENTITIES OF i_productionordconfirmationtp
      ENTITY productionorderconfirmation
      CREATE FROM lt_confirmation
      CREATE BY \_prodnordconfmatldocitm FROM lt_matldocitm
      MAPPED DATA(lt_mapped)
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

      COMMIT ENTITIES.

      UPDATE zmatdistlines
      SET varianceposted = 1
      WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| )
      AND shiftnumber = @wadlinegrp-shiftnumber AND Productionorder = @wadlinegrp-productionorder
      AND Orderconfirmationgroup = @wadlinegrp-orderconfirmationgroup.

      UPDATE zmatdistlines
      SET varianceposted = 1
      WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| )
      AND shiftnumber = @wadlinegrp-shiftnumber
      AND varianceqty = 0 AND varianceposted = 0.

      "Check for Day Close
      SELECT FROM zmatdistlines AS mdlines
      FIELDS productionorder
      WHERE mdlines~Bukrs = @companycode AND mdlines~plantcode = @plantno AND mdlines~declaredate = @prodorderdate
      AND mdlines~varianceposted = 0
      INTO TABLE @DATA(ltdlinecheck).

      IF ltdlinecheck IS INITIAL.
        UPDATE zmaterialdist
        SET varianceclosed = 1
        WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| ).
      ENDIF.

      CLEAR : lt_confproposal, lt_confirmation, lt_gdsmvtproposal, lt_target, lt_matldocitm, lt_mapped, lt_failed, lt_reported.
    ENDIF.
*      ENDLOOP.
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    TYPES ty_id TYPE c LENGTH 10.

    DATA s_id    TYPE RANGE OF ty_id.
    DATA p_descr TYPE c LENGTH 80.
    DATA p_count TYPE i.
    DATA p_simul TYPE abap_boolean.
    DATA jobname   TYPE cl_apj_rt_api=>ty_jobname.
    DATA jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
    DATA catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA template  TYPE cl_apj_rt_api=>ty_template_name.
    DATA p_date TYPE datn.
    DATA p_plant TYPE c LENGTH 4.
    DATA prodorderdate TYPE datn.
    DATA plantno TYPE char05.
    DATA companycode TYPE char05.
    DATA productdesc TYPE char72.
    DATA productcode TYPE char72.
    DATA productbatch TYPE char72.

    DATA lt_confirmation TYPE TABLE FOR CREATE i_productionordconfirmationtp.
    DATA lt_matldocitm TYPE TABLE FOR CREATE i_productionordconfirmationtp\_prodnordconfmatldocitm.
    DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlines.

    DATA : dates  TYPE datn.
    dates = cl_abap_context_info=>get_system_date( ).

    p_date = '20250703'.
    p_plant = 'BB02'.

    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvariance' ##NO_TEXT.

    FIELD-SYMBOLS <ls_matldocitm> LIKE LINE OF lt_matldocitm.
    DATA lt_target LIKE <ls_matldocitm>-%target.

    "Material Variance Posting
    IF p_plant IS NOT INITIAL AND p_date = '0'.
      SELECT SINGLE FROM zmaterialdist
      FIELDS bukrs, plantcode, declaredate, variancepostdate
      WHERE plantcode = @p_plant AND variancecalculated = 1 AND varianceposted = 1 AND varianceclosed = 0
      INTO @DATA(materialdistline).
    ELSEIF p_date IS NOT INITIAL AND p_plant IS NOT INITIAL.
      SELECT SINGLE FROM zmaterialdist
      FIELDS bukrs, plantcode, declaredate, variancepostdate
      WHERE  plantcode = @p_plant AND variancecalculated = 1 AND varianceposted = 1 AND varianceclosed = 0
      AND declaredate = @p_date
      INTO @materialdistline.
    ENDIF.

    companycode   = materialdistline-Bukrs.
    plantno       = materialdistline-Plantcode.
    prodorderdate = materialdistline-declaredate.

    SELECT SINGLE FROM zmatdistlines FIELDS productionorder , shiftnumber
    WHERE Bukrs = @companycode AND plantcode = @plantno AND declaredate = @prodorderdate
    AND varianceqty <> 0 AND varianceposted = 0
    INTO @DATA(wa_prdorder) PRIVILEGED ACCESS.

*    SELECT FROM zmatdistlines FIELDS productionorder, orderconfirmationgroup,
*    shiftnumber, shiftgroup, productcode, SUM( varianceqty ) AS varqty
*    WHERE Bukrs = @companycode AND plantcode = @plantno AND declaredate = @prodorderdate
*    AND varianceqty <> 0 AND varianceposted = 0 AND productionorder = @wa_prdorder-productionorder
*    AND shiftnumber = @wa_prdorder-shiftnumber
*    GROUP BY productionorder, orderconfirmationgroup, shiftnumber, shiftgroup, productcode
*    INTO TABLE @DATA(ltdlinegrp) PRIVILEGED ACCESS.

    SELECT SINGLE FROM zmatdistlines FIELDS productionorder, orderconfirmationgroup,
    shiftnumber, shiftgroup, productcode, varianceqty "SUM( varianceqty ) AS varqty
    WHERE Bukrs = @companycode AND plantcode = @plantno AND declaredate = @prodorderdate
    AND varianceqty <> 0 AND varianceposted = 0 AND productionorder = @wa_prdorder-productionorder
    AND shiftnumber = @wa_prdorder-shiftnumber
    GROUP BY productionorder, orderconfirmationgroup, shiftnumber, shiftgroup, productcode, varianceqty
    INTO @DATA(wadlinegrp) PRIVILEGED ACCESS.

*    SORT ltdlinegrp BY productionorder orderconfirmationgroup shiftnumber shiftgroup productcode.

*    IF ltdlinegrp IS NOT INITIAL.
*      LOOP AT ltdlinegrp INTO DATA(wadlinegrp).
    IF wadlinegrp IS NOT INITIAL AND wadlinegrp-varianceqty IS NOT INITIAL.

      "read proposals and corresponding times for given quantity
      READ ENTITIES OF i_productionordconfirmationtp
      ENTITY productionorderconfirmation
      EXECUTE getconfproposal
      FROM VALUE #( ( confirmationgroup = wadlinegrp-orderconfirmationgroup
      %param-confirmationyieldquantity = 1 ) )
      RESULT DATA(lt_confproposal)
      REPORTED DATA(lt_reported_conf).

      LOOP AT lt_confproposal ASSIGNING FIELD-SYMBOL(<ls_confproposal>).
        " convert proposals to confirmations with goodsmovement
        APPEND INITIAL LINE TO lt_confirmation ASSIGNING FIELD-SYMBOL(<ls_confirmation>).
        <ls_confirmation>-%cid                      = 'Conf' && sy-tabix.
        <ls_confirmation>-%data                     = CORRESPONDING #( <ls_confproposal>-%param ).
        <ls_confirmation>-PostingDate               = materialdistline-variancepostdate.
        <ls_confirmation>-ConfirmationYieldQuantity = 0.
        <ls_confirmation>-OpConfirmedWorkQuantity1  = 0.
        <ls_confirmation>-OpConfirmedWorkQuantity2  = 0.
        <ls_confirmation>-OpConfirmedWorkQuantity3  = 0.
        <ls_confirmation>-OpConfirmedWorkQuantity4  = 0.
        <ls_confirmation>-OpConfirmedWorkQuantity5  = 0.
        <ls_confirmation>-OpConfirmedWorkQuantity6  = 0.
        <ls_confirmation>-ShiftDefinition           = wadlinegrp-shiftnumber.
        <ls_confirmation>-ShiftGrouping             = wadlinegrp-shiftgroup.

        " read proposals for corresponding goods movements for proposed quantity
        READ ENTITIES OF i_productionordconfirmationtp
        ENTITY productionorderconfirmation
        EXECUTE getgdsmvtproposal
        FROM VALUE #( ( confirmationgroup = <ls_confproposal>-confirmationgroup
        %param-confirmationyieldquantity = <ls_confproposal>-%param-confirmationyieldquantity ) )
        RESULT DATA(lt_gdsmvtproposal)
        REPORTED DATA(lt_reported_gdsmvt).

        CHECK lt_gdsmvtproposal[] IS NOT INITIAL.
        CLEAR lt_target[].

        LOOP AT lt_gdsmvtproposal ASSIGNING FIELD-SYMBOL(<ls_gdsmvtproposal>) WHERE confirmationgroup = <ls_confproposal>-confirmationgroup.

          SELECT FROM zmatdistlines AS mdlines
          FIELDS productionorder, orderconfirmationgroup, productcode, storagelocation, batchno, varianceqty, entryuom, shiftnumber
          WHERE mdlines~Bukrs = @companycode AND mdlines~plantcode = @plantno AND mdlines~declaredate = @prodorderdate
          AND mdlines~productionorder = @<ls_confirmation>-OrderID AND mdlines~orderconfirmationgroup = @<ls_confirmation>-ConfirmationGroup
          AND mdlines~shiftnumber = @<ls_confirmation>-ShiftDefinition
          AND mdlines~varianceqty <> 0 AND mdlines~varianceposted = 0
          INTO TABLE @DATA(ltdline).

          LOOP AT ltdline INTO DATA(waltdline).
            DATA lv_matnr TYPE I_Product-Product.
            lv_matnr = |{ waltdline-productcode ALPHA = OUT }| .
            SELECT FROM zmaterialdecl AS md
            FIELDS md~productcode, md~batchno, SUM( md~stockquantity ) AS qty
            WHERE md~bukrs = @companycode AND md~plantcode = @plantno
            AND md~declaredate = @prodorderdate AND md~productcode = @lv_matnr
            GROUP BY md~productcode, md~batchno
            INTO TABLE @DATA(ltStock).

            LOOP AT ltStock INTO DATA(waltStock).
              productbatch = waltstock-batchno.
            ENDLOOP.

            CLEAR lv_matnr .
            APPEND INITIAL LINE TO lt_target ASSIGNING FIELD-SYMBOL(<ls_target>).
            <ls_target>                       = CORRESPONDING #( <ls_gdsmvtproposal>-%param ).
            <ls_target>-%cid                  = 'Item' && sy-tabix.
            <ls_target>-Material              = waltdline-productcode.
            <ls_target>-StorageLocation       = waltdline-storagelocation.
            <ls_target>-GoodsMovementRefDocType = ''.
            <ls_target>-OrderItem             = '0'.
            <ls_target>-EntryUnit             = waltdline-entryuom.

            IF waltdline-varianceqty > 0.
              <ls_target>-GoodsMovementType   = '261'.
              <ls_target>-QuantityInEntryUnit = waltdline-varianceqty.
              <ls_target>-Batch               = productbatch.
            ELSE.
              <ls_target>-GoodsMovementType   = '262'.
              <ls_target>-QuantityInEntryUnit = -1 * waltdline-varianceqty.
              <ls_target>-Batch               = waltdline-batchno.
            ENDIF.

          ENDLOOP.
          CLEAR : ltdline.
        ENDLOOP.

        APPEND VALUE #( %cid_ref = <ls_confirmation>-%cid
            %target = lt_target
            confirmationgroup = <ls_confproposal>-confirmationgroup ) TO lt_matldocitm.
      ENDLOOP.

      MODIFY ENTITIES OF i_productionordconfirmationtp
      ENTITY productionorderconfirmation
      CREATE FROM lt_confirmation
      CREATE BY \_prodnordconfmatldocitm FROM lt_matldocitm
      MAPPED DATA(lt_mapped)
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

      COMMIT ENTITIES.

      UPDATE zmatdistlines
      SET varianceposted = 1
      WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| )
      AND shiftnumber = @wadlinegrp-shiftnumber AND Productionorder = @wadlinegrp-productionorder
      AND Orderconfirmationgroup = @wadlinegrp-orderconfirmationgroup.

      UPDATE zmatdistlines
      SET varianceposted = 1
      WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| )
      AND shiftnumber = @wadlinegrp-shiftnumber
      AND varianceqty = 0 AND varianceposted = 0.

      "Check for Day Close
      SELECT FROM zmatdistlines AS mdlines
      FIELDS productionorder
      WHERE mdlines~Bukrs = @companycode AND mdlines~plantcode = @plantno AND mdlines~declaredate = @prodorderdate
      AND mdlines~varianceposted = 0
      INTO TABLE @DATA(ltdlinecheck).

      IF ltdlinecheck IS INITIAL.
        UPDATE zmaterialdist
        SET varianceclosed = 1
        WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| ).
      ENDIF.

      CLEAR : lt_confproposal, lt_confirmation, lt_gdsmvtproposal, lt_target, lt_matldocitm, lt_mapped, lt_failed, lt_reported.
    ENDIF.
*      ENDLOOP.
*    ENDIF.
  ENDMETHOD.
ENDCLASS.
