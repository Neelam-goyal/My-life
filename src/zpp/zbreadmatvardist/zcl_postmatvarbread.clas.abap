CLASS zcl_postmatvarbread DEFINITION
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

    CLASS-METHODS runJob
      IMPORTING p_date TYPE datn
                p_plant TYPE werks_d.
PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_POSTMATVARBREAD IMPLEMENTATION.


  METHOD runJob.

    DATA lt_confirmation TYPE TABLE FOR CREATE i_productionordconfirmationtp.
    DATA lt_matldocitm TYPE TABLE FOR CREATE i_productionordconfirmationtp\_prodnordconfmatldocitm.

    DATA productbatch TYPE char72.
    FIELD-SYMBOLS <ls_matldocitm> LIKE LINE OF lt_matldocitm.
    DATA lt_target LIKE <ls_matldocitm>-%target.

    DATA(pplant) = p_plant.
    DATA(pdate)  = p_date.

    IF pplant IS NOT INITIAL AND pdate = '0'.
      SELECT SINGLE FROM ZR_materialdist01TPbrd
      FIELDS bukrs, plantcode, declareCdate, variancepostdate
      WHERE plantcode = @pplant AND variancecalculated = 1 AND varianceposted = 1 AND varianceclosed = 0
      INTO @DATA(materialdistline).
    ELSEIF pdate IS NOT INITIAL AND pplant IS NOT INITIAL.
      SELECT SINGLE FROM ZR_materialdist01TPbrd
      FIELDS bukrs, plantcode, declareCdate, variancepostdate
      WHERE  plantcode = @pplant AND variancecalculated = 1 AND varianceposted = 1 AND varianceclosed = 0
      AND declaredate = @pdate
      INTO @materialdistline.
    ENDIF.

    DATA(companycode)   = materialdistline-Bukrs.
    DATA(plantno)       = materialdistline-Plantcode.
    DATA(prodorderdate) = materialdistline-declareCdate.

    SELECT SINGLE FROM ZR_matdistlinesbrd FIELDS productionorder , shiftnumber
    WHERE Bukrs = @companycode AND plantcode = @plantno AND declarecdate = @prodorderdate
    AND varianceqty <> 0 AND varianceposted = 0
    INTO @DATA(wa_prdorder) PRIVILEGED ACCESS.

    SELECT SINGLE FROM ZR_matdistlinesbrd
    FIELDS productionorder, shiftnumber, productcode, varianceqty, Orderconfirmationgroup, Shiftgroup
    WHERE Bukrs = @companycode
          AND plantcode = @plantno
          AND declarecdate = @prodorderdate
          AND varianceqty <> 0
          AND varianceposted = 0
          AND productionorder = @wa_prdorder-productionorder
          AND shiftnumber = @wa_prdorder-shiftnumber
    GROUP BY productionorder, shiftnumber, productcode, varianceqty, Orderconfirmationgroup, Shiftgroup
    INTO @DATA(wadlinegrp) PRIVILEGED ACCESS.


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
        <ls_confirmation>-ShiftGrouping             = wadlinegrp-Shiftgroup.

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

          SELECT FROM ZR_matdistlinesTPBRD AS mdlines
          FIELDS productionorder, orderconfirmationgroup, productcode, storagelocation, batchno, varianceqty, entryuom, shiftnumber
          WHERE mdlines~Bukrs = @companycode AND mdlines~plantcode = @plantno AND mdlines~declarecdate = @prodorderdate
          AND mdlines~productionorder = @<ls_confirmation>-OrderID AND mdlines~orderconfirmationgroup = @<ls_confirmation>-ConfirmationGroup
          AND mdlines~shiftnumber = @<ls_confirmation>-ShiftDefinition
          AND mdlines~varianceqty <> 0 AND mdlines~varianceposted = 0
          INTO TABLE @DATA(ltdline).

          LOOP AT ltdline INTO DATA(waltdline).
            DATA: lv_matnr TYPE c LENGTH 18,
                  shift    TYPE c LENGTH 8.

            lv_matnr = |{ waltdline-productcode ALPHA = OUT }| .


            IF waltdline-Shiftnumber = '1'.
              shift = 'DAY'.
            ELSEIF waltdline-Shiftnumber = '2'.
              shift = 'NIGHT'.
            ENDIF.


            SELECT FROM zr_matvarbread AS md
                FIELDS md~Product, md~batch
                WHERE md~PlantCode = @plantno AND md~Creationdate = @prodorderdate
                        AND md~Product = @lv_matnr AND md~Shift = @shift
                GROUP BY md~Product, md~batch
                INTO TABLE @DATA(ltStock).

            LOOP AT ltStock INTO DATA(waltStock).
              productbatch = waltstock-batch.
            ENDLOOP.

            lv_matnr = |{ waltdline-productcode ALPHA = IN }|.
            APPEND INITIAL LINE TO lt_target ASSIGNING FIELD-SYMBOL(<ls_target>).
            <ls_target>                       = CORRESPONDING #( <ls_gdsmvtproposal>-%param ).
            <ls_target>-%cid                  = 'Item' && sy-tabix.
            <ls_target>-Material              = lv_matnr.
            <ls_target>-StorageLocation       = waltdline-storagelocation.
            <ls_target>-GoodsMovementRefDocType = ''.
            <ls_target>-OrderItem             = '0'.
            <ls_target>-EntryUnit             = waltdline-entryuom.

            IF waltdline-varianceqty > 0.
              <ls_target>-GoodsMovementType   = '261'.
              <ls_target>-QuantityInEntryUnit = waltdline-varianceqty.
              <ls_target>-Batch               = waltdline-batchno.
            ELSE.
              <ls_target>-GoodsMovementType   = '262'.
              <ls_target>-QuantityInEntryUnit = -1 * waltdline-varianceqty.
              <ls_target>-Batch               = productbatch.
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

      IF  ( sy-msgty = 'E'
              AND
              ( sy-msgid NE 'FL' AND sy-msgno NE '651' AND sy-msgv1 NE 'BP_COVER_EL_INIT' )
          )
          OR ( sy-msgty = 'I' AND sy-msgid = 'RU' AND sy-msgno = '505' ).

        RETURN.
      ENDIF.


      SELECT SINGLE FROM I_ManufacturingOrder AS a
          INNER JOIN I_ManufacturingOrderOperation AS c ON a~MfgOrderInternalID = c~MfgOrderInternalID
          FIELDS a~ManufacturingOrder,c~ManufacturingOrderOperation_2
          WHERE a~ManufacturingOrder = @wa_prdorder-productionorder
          INTO @DATA(mfg_order_basic).

      SELECT SINGLE FROM I_MfgOrderConfirmation AS a
        FIELDS MAX( a~MfgOrderConfirmation ) AS MfgOrderConfirmation
        WHERE ManufacturingOrder = @mfg_order_basic-ManufacturingOrder
        AND ManufacturingOrderOperation_2 = @mfg_order_basic-ManufacturingOrderOperation_2
        INTO @DATA(mfg_order_confirmation).


      UPDATE zmatdistlinesbrd
      SET varianceposted = 1, varianceconfirmationcount = @mfg_order_confirmation
      WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| )
      AND shiftnumber = @wadlinegrp-shiftnumber AND Productionorder = @wadlinegrp-productionorder
      AND Orderconfirmationgroup = @wadlinegrp-orderconfirmationgroup.

      UPDATE zmatdistlinesbrd
      SET varianceposted = 1, varianceconfirmationcount = @mfg_order_confirmation
      WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| )
      AND shiftnumber = @wadlinegrp-shiftnumber
      AND varianceqty = 0 AND varianceposted = 0.

      "Check for Day Close
      SELECT FROM zmatdistlinesbrd AS mdlines
      FIELDS productionorder
      WHERE mdlines~Bukrs = @companycode AND mdlines~plantcode = @plantno AND mdlines~declarecdate = @prodorderdate
      AND mdlines~varianceposted = 0
      INTO TABLE @DATA(ltdlinecheck).

      IF ltdlinecheck IS INITIAL.
        UPDATE zmaterialdistbrd
        SET varianceclosed = 1
        WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| ).
      ENDIF.

      CLEAR : lt_confproposal, lt_confirmation, lt_gdsmvtproposal, lt_target, lt_matldocitm, lt_mapped, lt_failed, lt_reported.
    ENDIF.
*      ENDLOOP.
*      ENDIF.
*    ENDLOOP.
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
    ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    TYPES ty_id TYPE c LENGTH 10.

    DATA: p_date TYPE datn.
    DATA: p_plant TYPE c LENGTH 4.

    LOOP AT it_parameters INTO DATA(wa_parameter).
      CASE wa_parameter-selname.
        WHEN 'P_DATE'.
          p_date = wa_parameter-low.
        WHEN 'P_PLANT'  .
          p_plant =  wa_parameter-low.
      ENDCASE.
    ENDLOOP.

    runJob( p_date = p_date p_plant = p_plant ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    DATA do_update TYPE c LENGTH 1 VALUE ''.

    IF do_update = 'X'.

      DATA dte TYPE d.
      DATA plnt TYPE werks_d VALUE 'CA03'.
      DATA fromdate TYPE d VALUE '20250921'.
      DATA todate TYPE d VALUE '20250930'.

      DATA update_hdr TYPE c LENGTH 1 VALUE ''.
      DATA update_line TYPE c LENGTH 1 VALUE ''.
      DATA delete_line TYPE c LENGTH 1 VALUE ''.

      IF update_hdr = 'X'.
        UPDATE zmaterialdistbrd SET varianceposted = 0, variancepostdate = @dte, varianceclosed = 0, variancecalculated = 0
        WHERE plantcode = @plnt AND declarecdate BETWEEN @fromdate AND @todate.
      ENDIF.

      IF update_line = 'X'.
        UPDATE zmatdistlinesbrd SET varianceqty = 0, varianceposted = 0
        WHERE plantcode = @plnt AND declarecdate BETWEEN @fromdate AND @todate and varianceposted = 0.
      ENDIF.

      IF delete_line = 'X'.
        DELETE FROM zmatdistlinesbrd WHERE plantcode = @plnt AND declarecdate BETWEEN @fromdate AND @todate and varianceposted = 0.
      ENDIF.


    ENDIF.
    runJob( p_date = '20250820' p_plant = 'BN02' ).

  ENDMETHOD.


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
ENDCLASS.
