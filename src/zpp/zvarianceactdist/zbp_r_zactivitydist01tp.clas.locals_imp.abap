CLASS lhc_zactivitydist DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zactivitydist RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zactivitydist RESULT result.

    METHODS calculatevariance FOR MODIFY
      IMPORTING keys FOR ACTION zactivitydist~calculatevariance RESULT result.

    METHODS createvariancedata FOR MODIFY
      IMPORTING keys FOR ACTION zactivitydist~createvariancedata RESULT result.

    METHODS postvariance FOR MODIFY
      IMPORTING keys FOR ACTION zactivitydist~postvariance RESULT result.

ENDCLASS.

CLASS lhc_zactivitydist IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zr_zactivitydist01tp IN LOCAL MODE
      ENTITY zactivitydist
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(activitydistlist).

    result = VALUE #( FOR activitydistline IN activitydistlist
                        LET
                          is_cancelled = COND #( WHEN activitydistline-Varianceposted = 1
                                                 THEN if_abap_behv=>fc-o-disabled
                                                 ELSE if_abap_behv=>fc-o-enabled  )
                        IN
                            ( %tky                      = activitydistline-%tky
                              %action-calculateVariance = is_cancelled ) ).

    result = VALUE #( FOR activitydistline IN activitydistlist
                        LET
                          is_cancelled = COND #( WHEN activitydistline-Varianceposted = 1
                                                 THEN if_abap_behv=>fc-o-disabled
                                                 ELSE if_abap_behv=>fc-o-enabled  )
                        IN
                            ( %tky                      = activitydistline-%tky
                              %action-postVariance = is_cancelled ) ).

  ENDMETHOD.

  METHOD calculateVariance.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_actvariance' ##NO_TEXT.

    DATA prodorderdate TYPE d .
    DATA plantno TYPE char05.
    DATA companycode TYPE char05.
    DATA distlineno TYPE int2.
    DATA totalcpower TYPE P DECIMALS 3.
    DATA totalcfuel TYPE P DECIMALS 3.
    DATA totalclabour TYPE P DECIMALS 3.
    DATA totalcoverhead TYPE P DECIMALS 3.
    DATA totalcrepair TYPE P DECIMALS 3.
    DATA dpower TYPE P DECIMALS 3.
    DATA dfuel TYPE P DECIMALS 3.
    DATA dlabour TYPE P DECIMALS 3.
    DATA doverhead TYPE P DECIMALS 3.
    DATA drepair TYPE P DECIMALS 3.
    DATA varpower TYPE P DECIMALS 3.
    DATA varfuel TYPE P DECIMALS 3.
    DATA varlabour TYPE P DECIMALS 3.
    DATA varoverhead TYPE P DECIMALS 3.
    DATA varrepair TYPE P DECIMALS 3.

*    DATA calcvarqty TYPE P DECIMALS 3.
*    DATA isconsumed TYPE int1.

    DATA upd_actdisttab TYPE TABLE FOR UPDATE zr_zactivitydist01tp.

    DATA upd_actdistlinetab TYPE TABLE FOR UPDATE ZR_actdistlines.


    READ ENTITIES OF zr_zactivitydist01tp IN LOCAL MODE
      ENTITY zactivitydist
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(activitydistline).

    LOOP AT activitydistline INTO DATA(wadistline).
        companycode = wadistline-Bukrs.
        plantno = wadistline-Plantcode.
        prodorderdate = wadistline-declaredate.

        SELECT FROM zactdistlines as actdlines
            FIELDS DISTINCT actdlines~productionorder
            WHERE actdlines~bukrs = @companycode AND actdlines~plantcode = @plantno
            AND actdlines~declaredate = @prodorderdate
            AND actdlines~varianceposted = 1
            INTO TABLE @DATA(ltcheck).
        IF ltcheck IS NOT INITIAL.
            APPEND VALUE #( %cid = mycid ) TO failed-zactivitydist.
            APPEND VALUE #( %cid = mycid
                    %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = 'Variance already posted.' )
                    ) TO reported-zactivitydist.

            READ ENTITIES OF zr_zactivitydist01tp IN LOCAL MODE
              ENTITY zactivitydist
              ALL FIELDS WITH CORRESPONDING #( keys )
              RESULT DATA(activitydistlinesr).

            result = VALUE #( FOR actdistline IN activitydistlinesr
                            ( %tky   = actdistline-%tky
                              %param = actdistline ) ).
            RETURN.
        ENDIF.


        upd_actdistlinetab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ prodorderdate }| Vlabour = 0
            Vpower = 0 Vfuel = 0 Vrepair = 0 Voverheads = 0 ) ).

        MODIFY ENTITY ZR_actdistlines
            UPDATE FIELDS ( Vlabour Vpower Vfuel Vrepair Voverheads )
            WITH upd_actdistlinetab.

        CLEAR : upd_actdistlinetab.

        SELECT FROM zactdistlines as actlines
            FIELDS DISTINCT actlines~shiftnumber, actlines~workcenterid
            WHERE actlines~bukrs = @companycode AND actlines~plantcode = @plantno
            AND actlines~declaredate = @prodorderdate
            INTO TABLE @DATA(ltdActivity).
        LOOP AT ltdActivity INTO DATA(wadActivity).
            totalclabour = 0.
            totalcpower = 0.
            totalcfuel = 0.
            totalcrepair = 0.
            totalcoverhead = 0.

            SELECT FROM zactdistlines as actlines
                FIELDS sum( actlines~clabour ) as labour, sum( actlines~cpower ) as power, sum( actlines~cfuel ) as fuel,
                sum( actlines~crepair ) as repair, sum( actlines~coverheads ) as overheads
                WHERE actlines~bukrs = @companycode AND actlines~plantcode = @plantno
                AND actlines~declaredate = @prodorderdate
                AND actlines~shiftnumber = @wadactivity-shiftnumber AND actlines~workcenterid = @wadactivity-workcenterid
                INTO TABLE @DATA(ltdActivitySum).
            IF ltdActivitySum IS NOT INITIAL.
                LOOP AT ltdActivitySum INTO DATA(wadActivitySum).
                    totalclabour    = wadActivitySum-labour.
                    totalcpower     = wadActivitySum-power.
                    totalcfuel      = wadActivitySum-fuel.
                    totalcrepair    = wadActivitySum-repair.
                    totalcoverhead  = wadActivitySum-overheads.
                ENDLOOP.
            ENDIF.
            CLEAR : ltdActivitySum.

            dlabour = 0.
            dpower = 0.
            dfuel = 0.
            drepair = 0.
            doverhead = 0.

            "Labour - Z_LAB - LABOUR
            SELECT FROM zactivitydecl as ad
                FIELDS sum( ad~actualconsumption ) as consumption
                WHERE ad~bukrs = @companycode AND ad~plantcode = @plantno
                AND ad~declaredate = @prodorderdate
                AND ad~shiftnumber = @wadActivity-shiftnumber AND ad~workcenterid = @wadActivity-workcenterid
                AND ad~costctractivitytype = 'LABOUR'
                INTO TABLE @DATA(ltactdecl1).
            IF ltactdecl1 IS NOT INITIAL.
                LOOP AT ltactdecl1 INTO DATA(waltactdecl1).
                    dlabour = waltactdecl1-consumption.
                ENDLOOP.
            ENDIF.

            "Power - Z_POW - POWER
            SELECT FROM zactivitydecl as ad
                FIELDS sum( ad~actualconsumption ) as consumption
                WHERE ad~bukrs = @companycode AND ad~plantcode = @plantno
                AND ad~declaredate = @prodorderdate
                AND ad~shiftnumber = @wadActivity-shiftnumber AND ad~workcenterid = @wadActivity-workcenterid
                AND ad~costctractivitytype = 'POWER'
                INTO TABLE @DATA(ltactdecl2).
            IF ltactdecl2 IS NOT INITIAL.
                LOOP AT ltactdecl2 INTO DATA(waltactdecl2).
                    dpower = waltactdecl2-consumption.
                ENDLOOP.
            ENDIF.

            "Fuel - Z_FUE - FUEL
            SELECT FROM zactivitydecl as ad
                FIELDS sum( ad~actualconsumption ) as consumption
                WHERE ad~bukrs = @companycode AND ad~plantcode = @plantno
                AND ad~declaredate = @prodorderdate
                AND ad~shiftnumber = @wadActivity-shiftnumber AND ad~workcenterid = @wadActivity-workcenterid
                AND ad~costctractivitytype = 'FUEL'
                INTO TABLE @DATA(ltactdecl3).
            IF ltactdecl3 IS NOT INITIAL.
                LOOP AT ltactdecl3 INTO DATA(waltactdecl3).
                    dfuel = waltactdecl3-consumption.
                ENDLOOP.
            ENDIF.

            "Repair - Z_REP - REPAIR
            SELECT FROM zactivitydecl as ad
                FIELDS sum( ad~actualconsumption ) as consumption
                WHERE ad~bukrs = @companycode AND ad~plantcode = @plantno
                AND ad~declaredate = @prodorderdate
                AND ad~shiftnumber = @wadActivity-shiftnumber AND ad~workcenterid = @wadActivity-workcenterid
                AND ad~costctractivitytype = 'REPAIR'
                INTO TABLE @DATA(ltactdecl4).
            IF ltactdecl4 IS NOT INITIAL.
                LOOP AT ltactdecl4 INTO DATA(waltactdecl4).
                    drepair = waltactdecl4-consumption.
                ENDLOOP.
            ENDIF.

            "Overheads - Z_OVH - OHEADS
            SELECT FROM zactivitydecl as ad
                FIELDS sum( ad~actualconsumption ) as consumption
                WHERE ad~bukrs = @companycode AND ad~plantcode = @plantno
                AND ad~declaredate = @prodorderdate
                AND ad~shiftnumber = @wadActivity-shiftnumber AND ad~workcenterid = @wadActivity-workcenterid
                AND ad~costctractivitytype = 'OHEADS'
                INTO TABLE @DATA(ltactdecl5).
            IF ltactdecl5 IS NOT INITIAL.
                LOOP AT ltactdecl5 INTO DATA(waltactdecl5).
                    doverhead = waltactdecl5-consumption.
                ENDLOOP.
            ENDIF.

            CLEAR : ltactdecl1, ltactdecl2, ltactdecl3, ltactdecl4, ltactdecl5.

            varlabour   = 0.
            varpower    = 0.
            varfuel     = 0.
            varrepair   = 0.
            varoverhead = 0.

            IF dlabour <> 0.
                varlabour     = dlabour - totalclabour.
            ENDIF.
            IF dpower <> 0.
                varpower      = dpower - totalcpower.
            ENDIF.
            IF dfuel <> 0.
                varfuel       = dfuel - totalcfuel.
            ENDIF.
            IF drepair <> 0.
                varrepair     = drepair - totalcrepair.
            ENDIF.
            IF doverhead <> 0.
                varoverhead   = doverhead - totalcoverhead.
            ENDIF.

            "Distribute variance
            SELECT FROM zactdistlines as adlines
                FIELDS adlines~declarecdate, adlines~distlineno, adlines~clabour, adlines~cpower,
                adlines~cfuel, adlines~crepair, adlines~coverheads
                WHERE adlines~Bukrs = @companycode AND adlines~plantcode = @plantno AND adlines~declaredate = @prodorderdate
                    AND adlines~shiftnumber = @wadActivity-shiftnumber AND adlines~workcenterid = @wadActivity-workcenterid
                INTO TABLE @DATA(ltdlineActUpd).
            LOOP AT ltdlineActUpd INTO DATA(waltdlineActUpd).

                upd_actdistlinetab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = waltdlineActUpd-declarecdate
                            shiftnumber = wadActivity-shiftnumber Workcenterid = wadActivity-workcenterid
                            distlineno = waltdlineActUpd-distlineno
                            Vlabour = varlabour * waltdlineActUpd-clabour / totalclabour
                            Vpower  = varpower * waltdlineActUpd-cpower / totalcpower
                            Vfuel = varfuel * waltdlineActUpd-cfuel / totalcfuel
                            Vrepair = varrepair * waltdlineActUpd-crepair / totalcrepair
                            Voverheads = varoverhead * waltdlineActUpd-coverheads / totalcoverhead
                            ) ).

                MODIFY ENTITY ZR_actdistlines
                    UPDATE FIELDS ( Vlabour Vpower Vfuel Vrepair Voverheads )
                    WITH upd_actdistlinetab.
                CLEAR : upd_actdistlinetab.
            ENDLOOP.

        ENDLOOP.

        upd_actdisttab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ prodorderdate }| Variancecalculated = 1 ) ).
        MODIFY ENTITIES OF zr_zactivitydist01tp IN LOCAL MODE
        ENTITY zactivitydist
            UPDATE FIELDS ( Variancecalculated )
            WITH upd_actdisttab.
        CLEAR : upd_actdisttab.

    ENDLOOP.

    APPEND VALUE #( %cid = mycid
                    %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-success
                    text     = 'Variance Calculated.' )
                    ) TO reported-zactivitydist.

    READ ENTITIES OF zr_zactivitydist01tp IN LOCAL MODE
      ENTITY zactivitydist
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(activitydistlines).

    result = VALUE #( FOR actdistline IN activitydistlines
                    ( %tky   = actdistline-%tky
                      %param = actdistline ) ).


  ENDMETHOD.

  METHOD createVarianceData.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_actvariance' ##NO_TEXT.

    DATA prodorderdate TYPE datum.
    DATA prodordertodate TYPE datn.
    DATA plantno TYPE char05.
    DATA companycode TYPE char05.
    DATA distlineno TYPE int2.
    DATA totalconsumedqty TYPE p DECIMALS 3.
    DATA clabour TYPE p DECIMALS 3.
    DATA cpower TYPE p DECIMALS 3.
    DATA cfuel TYPE p DECIMALS 3.
    DATA crepair TYPE p DECIMALS 3.
    DATA coverhead TYPE p DECIMALS 3.
    DATA vlabour TYPE p DECIMALS 3.
    DATA vpower TYPE p DECIMALS 3.
    DATA vfuel TYPE p DECIMALS 3.
    DATA vrepair TYPE p DECIMALS 3.
    DATA voverhead TYPE p DECIMALS 3.
    DATA isconsumed TYPE int1.

    DATA create_actdist TYPE STRUCTURE FOR CREATE zr_zactivitydist01tp.
    DATA create_actdisttab TYPE TABLE FOR CREATE zr_zactivitydist01tp.
    DATA upd_actdisttab TYPE TABLE FOR UPDATE zr_zactivitydist01tp.

    DATA create_actdistline TYPE STRUCTURE FOR CREATE ZR_actdistlines.
    DATA create_actdistlinetab TYPE TABLE FOR CREATE ZR_actdistlines.
    DATA upd_actdistlinetab TYPE TABLE FOR UPDATE ZR_actdistlines.

    LOOP AT keys INTO DATA(ls_key).
      TRY.
          plantno = ls_key-%param-PlantNo .
          prodorderdate = ls_key-%param-prodorderdate .
          prodordertodate = ls_key-%param-prodordertodate.

          IF plantno = ''.
            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-zactivitydist.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text     = 'Plant No. cannot be blank.' )
                          ) TO reported-zactivitydist.
            RETURN.
          ENDIF.
      ENDTRY.

      SELECT SINGLE FROM ztable_plant AS pl
          FIELDS pl~comp_code
          WHERE pl~plant_code = @plantno
          INTO @DATA(companycode2).
      companycode = companycode2.

      SELECT FROM zactivitydist AS md
      FIELDS md~bukrs, md~plantcode, md~varianceposted,md~declarecdate,md~declaredate
      WHERE md~bukrs = @companycode AND md~plantcode = @plantno
       AND md~declaredate >= @prodorderdate  AND md~declaredate <= @prodordertodate
         INTO TABLE @DATA(ltlines).

      IF ltlines IS INITIAL.
        "Insert Master record
        DATA lv_date_len TYPE i.
        DATA lv_cnt TYPE i.
        DATA lv_curr_date TYPE datn.
        lv_date_len = prodordertodate - prodorderdate.
        lv_curr_date = prodorderdate.
        lv_cnt = 1.

        WHILE lv_curr_date <= prodordertodate.
          create_actdist = VALUE #( %cid      = |{ ls_key-%cid }_{ lv_cnt } |
                          Bukrs = companycode
                          plantcode = plantno
                          declarecdate = |{ lv_curr_date }|
                          declaredate = lv_curr_date
                          variancecalculated = 0
                          varianceposted = 0
                          varianceclosed = 0
                          ).
          APPEND create_actdist TO create_actdisttab.
          lv_curr_date = lv_curr_date + 1.
          lv_cnt += 1.
        ENDWHILE.

        MODIFY ENTITIES OF zr_zactivitydist01tp IN LOCAL MODE
            ENTITY zactivitydist
            CREATE FIELDS ( bukrs plantcode declarecdate declaredate variancecalculated varianceposted varianceclosed )
            WITH create_actdisttab
            MAPPED   mapped
            FAILED   failed
            REPORTED reported.

        CLEAR : create_actdisttab, create_actdist.
      ELSE.
        "Check if further processed
        LOOP AT ltlines INTO DATA(walines).
          IF walines-varianceposted = 0.
            MODIFY ENTITY ZR_actdistlines
                DELETE FROM VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ walines-declarecdate }| ) ).
          ELSE.
            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-zactivitydist.
            APPEND VALUE #( %cid = ls_key-%cid
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'Variance already posted.' )
                        ) TO reported-zactivitydist.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDIF.

      "Process for each date in the range
      lv_curr_date = prodorderdate.
      WHILE lv_curr_date <= prodordertodate.
        distlineno = 0.

        "Loop for Order Confirmations for the current date
        SELECT FROM I_MfgOrderConfirmation AS mconf
            JOIN I_WorkCenter AS wc ON mconf~WorkCenterInternalID = wc~WorkCenterInternalID
            FIELDS mconf~ManufacturingOrder, mconf~ShiftDefinition, mconf~ShiftGrouping, mconf~MfgOrderConfirmationGroup,
                mconf~ManufacturingOrderSequence, mconf~WorkCenterInternalID, wc~WorkCenter,
                SUM( mconf~OpConfirmedWorkQuantity1 ) AS labour, SUM( mconf~OpConfirmedWorkQuantity2 ) AS power,
                SUM( mconf~OpConfirmedWorkQuantity3 ) AS fuel, SUM( mconf~OpConfirmedWorkQuantity4 ) AS repair,
                SUM( mconf~OpConfirmedWorkQuantity5 ) AS overhead
                WHERE mconf~Plant = @plantno
                AND mconf~PostingDate = @lv_curr_date
                AND mconf~IsReversal NE 'X'
                AND mconf~IsReversed NE 'X'
                GROUP BY mconf~ManufacturingOrder, mconf~ShiftDefinition, mconf~ShiftGrouping, mconf~MfgOrderConfirmationGroup,
                mconf~ManufacturingOrderSequence, mconf~WorkCenterInternalID, wc~WorkCenter
                INTO TABLE @DATA(ltactlines).

        LOOP AT ltactlines INTO DATA(waactline).
          "Insert Shift wise consumption record
          distlineno = distlineno + 1.
          create_actdistline = VALUE #( %cid      = |{ ls_key-%cid }_{ lv_curr_date }_{ distlineno }|
                      Bukrs = companycode
                      plantcode = plantno
                      declarecdate = |{ lv_curr_date }|
                      shiftnumber = waactline-ShiftDefinition
                      Workcenterid = waactline-WorkCenterInternalID
                      Workcenter = waactline-WorkCenter
                      distlineno = distlineno
                      declaredate = lv_curr_date
                      productionorder = waactline-ManufacturingOrder
                      productionorderline = 1
                      Orderconfirmationgroup = waactline-MfgOrderConfirmationGroup
                      Ordersequence = waactline-ManufacturingOrderSequence
                      Clabour = waactline-labour
                      Cpower = waactline-power
                      Cfuel = waactline-fuel
                      Crepair = waactline-repair
                      Coverheads = waactline-overhead
                      Vlabour = 0
                      Vpower = 0
                      Vfuel = 0
                      Vrepair = 0
                      Voverheads = 0
                      varianceposted = 0
                      Shiftgroup = waactline-ShiftGrouping
                      ).
          APPEND create_actdistline TO create_actdistlinetab.
        ENDLOOP.

        IF create_actdistlinetab IS NOT INITIAL.
          MODIFY ENTITIES OF ZR_actdistlines
              ENTITY ZR_actdistlines
              CREATE FIELDS ( bukrs plantcode declarecdate shiftnumber Workcenterid Workcenter Distlineno declaredate
                      Productionorder Productionorderline Orderconfirmationgroup Ordersequence Clabour Cpower Cfuel Crepair Coverheads
                      Vlabour Vpower Vfuel Vrepair Voverheads Varianceposted Shiftgroup )
                    WITH create_actdistlinetab.
          CLEAR create_actdistlinetab.
        ENDIF.

        lv_curr_date = lv_curr_date + 1.
      ENDWHILE.

      APPEND VALUE #( %cid = ls_key-%cid
                      %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text     = 'Data Generated Successfuly.' )
                      ) TO reported-zactivitydist.
      RETURN.

    ENDLOOP.
ENDMETHOD.


  METHOD postVariance.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvarpost' ##NO_TEXT.

    DATA upd_actdisttab TYPE TABLE FOR UPDATE zr_zactivitydist01tp.
    DATA upd_actdistlinetab TYPE TABLE FOR UPDATE ZR_actdistlines.
    DATA prodorderdate TYPE datum.
    DATA plantno TYPE char05.
    DATA companycode TYPE char05.

    DATA lt_confirmation TYPE TABLE FOR CREATE i_productionordconfirmationtp.
    DATA lt_matldocitm TYPE TABLE FOR CREATE i_productionordconfirmationtp\_prodnordconfmatldocitm.

    READ ENTITIES OF zr_zactivitydist01tp IN LOCAL MODE
      ENTITY zactivitydist
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(activitydistline).

    LOOP AT activitydistline INTO DATA(wadistline).
        companycode = wadistline-Bukrs.
        plantno = wadistline-Plantcode.
        prodorderdate = wadistline-declaredate.

        IF wadistline-Varianceposted = 0 AND wadistline-Variancecalculated = 1.
            upd_actdisttab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ prodorderdate }| Varianceposted = 1 ) ).
            MODIFY ENTITIES OF zr_zactivitydist01tp IN LOCAL MODE
            ENTITY zactivitydist
                UPDATE FIELDS ( Varianceposted )
                WITH upd_actdisttab.
            CLEAR : upd_actdisttab.
        ELSE.
            APPEND VALUE #( %cid = mycid ) TO failed-zactivitydist.
            APPEND VALUE #( %cid = mycid
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'Variance cannot be posted.' )
                        ) TO reported-zactivitydist.
            RETURN.
        ENDIF.

    ENDLOOP.

    APPEND VALUE #( %cid = mycid
                    %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-success
                    text     = 'Variance Posting scheduled.' )
                    ) TO reported-zactivitydist.

    READ ENTITIES OF zr_zactivitydist01tp IN LOCAL MODE
      ENTITY zactivitydist
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(activitydistlines).

    result = VALUE #( FOR actdistline IN activitydistlines
                    ( %tky   = actdistline-%tky
                      %param = actdistline ) ).


  ENDMETHOD.

ENDCLASS.
