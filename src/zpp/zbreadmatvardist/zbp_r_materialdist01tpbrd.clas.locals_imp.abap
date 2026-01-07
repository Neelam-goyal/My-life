CLASS lhc_materialdistbrdbrd DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR materialdistbrd RESULT result.

    METHODS createvariancedata FOR MODIFY
      IMPORTING keys FOR ACTION materialdistbrd~createVarianceData RESULT result.
    METHODS calculateVariance FOR MODIFY
      IMPORTING keys FOR ACTION materialdistbrd~calculateVariance RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR materialdistbrd RESULT result.

    METHODS postVariance FOR MODIFY
      IMPORTING keys FOR ACTION materialdistbrd~postVariance RESULT result.


ENDCLASS.

CLASS lhc_materialdistbrdbrd IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD createVarianceData.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvariance' ##NO_TEXT.

    DATA prodorderdate TYPE datum.
    DATA prodordertodate TYPE datn.
    DATA plantno TYPE char05.
    DATA distlineno TYPE int2.

    DATA create_matdist TYPE STRUCTURE FOR CREATE ZR_materialdist01TPBRD.
    DATA create_matdisttab TYPE TABLE FOR CREATE ZR_materialdist01TPBRD.
    DATA upd_matdisttab TYPE TABLE FOR UPDATE ZR_materialdist01TPBRD.

    DATA create_matdistline TYPE STRUCTURE FOR CREATE ZR_matdistlinesbrd.
    DATA create_matdistlinetab TYPE TABLE FOR CREATE ZR_matdistlinesbrd.
    DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlinesbrd.


    LOOP AT keys INTO DATA(ls_key).
      TRY.
          plantno = ls_key-%param-PlantNo .
          prodorderdate = ls_key-%param-prodorderdate .
          prodordertodate = ls_key-%param-prodordertodate .

          IF plantno = ''.
            APPEND VALUE #( %cid     = ls_key-%cid ) TO failed-materialdistbrd.
            APPEND VALUE #( %cid     = ls_key-%cid
                            %msg     = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = 'Plant No. cannot be blank.' )
                          ) TO reported-materialdistbrd.
            RETURN.
          ENDIF.
      ENDTRY.

      plantno = to_upper( plantno ).

      SELECT SINGLE FROM ztable_plant FIELDS comp_code
      WHERE plant_code = @plantno INTO @DATA(lv_companycode2).

      SELECT FROM zmaterialdistbrd
      FIELDS bukrs, plantcode, varianceposted, declarecdate
      WHERE bukrs = @lv_companycode2 AND plantcode = @plantno
      AND declaredate >= @prodorderdate AND declaredate <= @prodordertodate
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

          create_matdist = VALUE #( %cid               = |{ ls_key-%cid }_{ lv_cnt } |
                                    Bukrs              = lv_companycode2
                                    plantcode          = plantno
                                    declarecdate       = |{ lv_curr_date }|
                                    declaredate        = lv_curr_date
                                    variancecalculated = 0
                                    varianceposted     = 0
                                    varianceclosed     = 0
                          ).
          APPEND create_matdist TO create_matdisttab.
          lv_curr_date = lv_curr_date + 1.
          lv_cnt += 1.
        ENDWHILE.

        MODIFY ENTITIES OF ZR_materialdist01TPBRD IN LOCAL MODE
        ENTITY materialdistbrd
        CREATE FIELDS ( bukrs plantcode declarecdate declaredate variancecalculated varianceposted varianceclosed )
        WITH create_matdisttab
        MAPPED   mapped
        FAILED   failed
        REPORTED reported.

        CLEAR : create_matdisttab, create_matdist.
      ELSE.
        "Check if further processed
        LOOP AT ltlines INTO DATA(walines).
          IF walines-varianceposted = 0.
*               MODIFY ENTITY ZR_matdistlines
*            DELETE FROM VALUE #( ( bukrs = lv_companycode2 plantcode = plantno declarecdate = |{ prodorderdate }| ) ).

            SELECT FROM ZR_matdistlinesbrd
            FIELDS Bukrs, Plantcode, Declarecdate, Shiftnumber, Distlineno, Productcode
            WHERE bukrs = @lv_companycode2 AND plantcode = @plantno AND declarecdate = @walines-declarecdate
                  AND Varianceposted = 0
            INTO TABLE @DATA(ltcheck).

            MODIFY ENTITIES OF ZR_matdistlinesbrd
            ENTITY matdistlinesbrd
            DELETE FROM VALUE #(
                                    FOR line IN ltcheck (
                                                            Bukrs = line-bukrs
                                                            plantcode = line-plantcode
                                                            declarecdate = line-declarecdate
                                                            shiftnumber = line-shiftnumber
                                                            Productcode = line-productcode
                                                            distlineno = line-distlineno )
            )
            MAPPED DATA(mapped1)
            FAILED DATA(failed1)
            REPORTED DATA(reported1).
          ELSE.
            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-materialdistbrd.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = 'Variance already posted.' )
                        ) TO reported-materialdistbrd.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDIF.

      distlineno = 0.
      "Loop for unique item declaration


      SELECT FROM zr_matvarbread AS md
      FIELDS plantcode,product, productdesc,creationdate, um,productionorder, postingdate,shift, actualconsumption,
             confirmationgroup, Shiftgroup, Distlineno, confirmationyieldquantity, confirmationcount,
             materialdocument, bomcomponentcode, bomcomponentname
      WHERE md~plantcode = @plantno AND md~creationdate >= @prodorderdate AND md~creationdate <= @prodordertodate
      AND md~actualconsumption NE 0
*      GROUP BY plantcode,md~product, md~productdesc, md~creationdate, um, md~productionorder, md~shift, postingdate, confirmationgroup, Shiftgroup, Distlineno
      INTO TABLE @DATA(ltItems) PRIVILEGED ACCESS.

      LOOP AT ltItems INTO DATA(waItem).

*       Makes sure same lines wont appear again
*        SELECT SINGLE FROM ZR_matdistlinesbrd
*        FIELDS Distlineno
*        WHERE bukrs = @lv_companycode2 AND plantcode = @plantno AND Productcode = @waItem-Product
*           AND Distlineno = @waItem-Distlineno
*           AND declarecdate = @waItem-creationdate AND Varianceposted = 1
*        INTO @DATA(ls_existing).
*
*        IF ls_existing IS NOT INITIAL.
*          CONTINUE.
*        ENDIF.

*       makes sure variance that is posted not comes back again
        SELECT SINGLE FROM zr_repmatbread
        FIELDS VarPosted
        WHERE plant = @waItem-Plantcode AND material = @waItem-Product
            AND rangedate <= @waItem-creationdate AND todate >= @waItem-creationdate
            INTO @DATA(wa_matcheck).

        IF wa_matcheck IS NOT INITIAL.
          CONTINUE.
        ENDIF.


        distlineno = distlineno + 1.

*        check if by any chance

        IF waItem-shift = 'DAY'.
          waItem-shift = '1'.
        ELSEIF waItem-shift = 'NIGHT'.
          waItem-shift = '2'.
        ELSE.
          waItem-shift = ''.
        ENDIF.

        create_matdistline = VALUE #( %cid             = ls_key-%cid
                                  Bukrs            = lv_companycode2
                                  plantcode        = plantno
                                  declarecdate     = waItem-creationdate
                                  shiftnumber      = waItem-shift
                                  distlineno       = distlineno
                                  declaredate      = waItem-PostingDate
                                  productionorder  = waItem-productionorder
                                  productionorderline    = 1
                                  productcode      = waItem-product
                                  productdesc      = waItem-productdesc
                                  consumedqty      = abs( waItem-actualconsumption )
                                  Confirmationcount = waItem-confirmationcount
                                  varianceqty      = 0
                                  varianceposted   = 0
                                  Entryuom         = waItem-um
                                  Variancepostlinedate   = waItem-postingdate
                                  Orderconfirmationgroup = waItem-confirmationgroup
                                  Shiftgroup       = waItem-Shiftgroup
                ).
        APPEND create_matdistline TO create_matdistlinetab.

        MODIFY ENTITIES OF ZR_matdistlinesbrd
        ENTITY matdistlinesbrd
        CREATE FIELDS (
                Bukrs plantcode declarecdate shiftnumber Distlineno declaredate Productionorder Productionorderline Confirmationcount
                Productcode Productdesc Consumedqty Varianceqty Varianceposted Entryuom Variancepostlinedate Orderconfirmationgroup Shiftgroup
        )
        WITH create_matdistlinetab
        FAILED   DATA(ls_failed)
        REPORTED DATA(ls_reported).

        IF ls_failed IS NOT INITIAL.
          DATA lv_errmsg TYPE string.
          lv_errmsg = ls_reported-matdistlinesbrd[ 1 ]-%msg->if_message~get_longtext(  ).
        ENDIF.

*        MODIFY ENTITIES OF zr_matvarbread
*        ENTITY ZrMatvarbread
*        UPDATE FIELDS ( Distlineno )
*        WITH VALUE #( (
*                        CompCode = lv_companycode2
*                        plantcode = waItem-plantcode
*                        Productionorder = waItem-productionorder
*                        Shift = waItem-shift
*                        Confirmationyieldquantity = waItem-confirmationyieldquantity
*                        Confirmationcount = waItem-confirmationcount
*                        ConfirmationGroup = waItem-confirmationgroup
*                        Materialdocument = waItem-materialdocument
*                        Actualconsumption = waItem-actualconsumption
*                        Bomcomponentcode = waItem-bomcomponentcode
*                        Bomcomponentname = waItem-bomcomponentname
*                        Distlineno = distlineno
*                      ) )
*        FAILED   DATA(ls_failed1)
*        REPORTED DATA(ls_reported1).
*
*        IF ls_failed1 IS NOT INITIAL.
*          lv_errmsg = ls_reported1-zrmatvarbread[ 1 ]-%msg->if_message~get_longtext(  ).
*        ENDIF.

        CLEAR : create_matdistline, create_matdistlinetab, lv_errmsg.

      ENDLOOP.
    ENDLOOP.
    APPEND VALUE #( %cid = ls_key-%cid
                         %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-success
                         text     = 'Variance Data Created.' )
                         ) TO reported-materialdistbrd.
    RETURN.

  ENDMETHOD.


  METHOD calculateVariance.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvariance' ##NO_TEXT.

    DATA prodorderdate TYPE datum.
    DATA plantno TYPE char05.
    DATA shiftn TYPE c LENGTH 6.
    DATA companycode TYPE char05.
    DATA productdesc TYPE char72.
    DATA productcode TYPE char72.
    DATA distlineno TYPE int2.
    DATA totalconsumedqty TYPE p DECIMALS 3.
    DATA stockqty TYPE p DECIMALS 3.
    DATA stockvarqty TYPE p DECIMALS 3.
    DATA calcvarqty TYPE p DECIMALS 3.
    DATA isconsumed TYPE int1.
    DATA upd_matdisttab TYPE TABLE FOR UPDATE ZR_materialdist01TPBRD.
    DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlinesbrd.

    TYPES: BEGIN OF ty_pcItemsCalc,
             qty         TYPE  ZR_matdistlinesTPBRD-Varianceqty ,
             productcode TYPE  ZR_matdistlinesTPBRD-Productcode,
           END OF ty_pcItemsCalc.


    DATA: ltPCItems TYPE STANDARD TABLE OF ty_pcItemsCalc WITH KEY productcode.

    READ ENTITIES OF ZR_materialdist01TPBRD IN LOCAL MODE
    ENTITY materialdistbrd
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(it_materialdistbrd).

    LOOP AT it_materialdistbrd INTO DATA(wadistline).
      companycode   = wadistline-Bukrs.
      plantno       = wadistline-Plantcode.
      prodorderdate = wadistline-declaredate.

*      SELECT FROM zmatdistlinesbrd AS mdlines
*      FIELDS DISTINCT mdlines~productionorder
*      WHERE mdlines~bukrs = @companycode AND mdlines~plantcode = @plantno
*      AND mdlines~declaredate = @prodorderdate
*      AND mdlines~varianceqty <> 0 AND mdlines~varianceposted = 1
*      INTO TABLE @DATA(ltcheck).
*
*      IF ltcheck IS NOT INITIAL.
*        APPEND VALUE #( %cid = mycid ) TO failed-materialdistbrd.
*        APPEND VALUE #( %cid = mycid
*                        %msg = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text     = 'Variance already posted.' )
*                ) TO reported-materialdistbrd.
*
*        READ ENTITIES OF ZR_materialdist01TPBRD IN LOCAL MODE
*        ENTITY materialdistbrd
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(it_materialdistbrds).
*
*        result = VALUE #( FOR matdistline IN it_materialdistbrds
*                ( %tky   = matdistline-%tky
*                  %param = matdistline ) ).
*
*        RETURN.
*      ENDIF.
*
*      upd_matdistlinetab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ prodorderdate }| varianceqty = 0 ) ).
*      MODIFY ENTITY ZR_matdistlinesbrd
*      UPDATE FIELDS ( varianceqty )
*      WITH upd_matdistlinetab.
*      CLEAR : upd_matdistlinetab.


      SELECT FROM ZR_matdistlinesTPBRD
      FIELDS Productcode, Plantcode, Shiftnumber,Declarecdate AS creationdate, Consumedqty, Distlineno, Entryuom, Bukrs
      WHERE bukrs = @companycode AND plantcode = @plantno AND declarecdate = @prodorderdate AND Varianceposted = 0
      INTO TABLE @DATA(ltItems) PRIVILEGED ACCESS.

      LOOP AT ltItems INTO DATA(waItem).

        IF waItem-shiftnumber = '1'.
          shiftn = 'DAY'.
        ELSEIF waItem-shiftnumber = '2'.
          shiftn = 'NIGHT'.
        ELSE.
          shiftn = ''.
        ENDIF.

        SELECT SINGLE FROM zr_repmatbread
        FIELDS difference,quantity,storagelocation, batch, Rangedate, Todate
        WHERE plant = @waItem-Plantcode AND material = @waItem-Productcode
            AND ( shift = @shiftn OR shift IS INITIAL )
            AND rangedate <= @waItem-creationdate AND todate >= @waItem-creationdate
            INTO @DATA(wa_diff).

        IF waItem-Entryuom = 'PC'.

*          read from internal table first and find according the product code
          READ TABLE ltPCItems INTO DATA(wa_pcitem) WITH KEY productcode = waItem-Productcode.

          IF wa_pcitem-productcode NE waItem-Productcode.
            wa_pcitem = VALUE ty_pcItemsCalc( ).
          ENDIF.

          IF wa_pcitem IS INITIAL.
            SELECT SINGLE SUM( Varianceqty ) AS qty, productcode FROM ZR_matdistlinesTPBRD
            WHERE bukrs = @companycode AND plantcode = @plantno
            AND declarecdate BETWEEN @wa_diff-Rangedate AND @wa_diff-Todate
            AND productcode = @waItem-Productcode AND Varianceposted = 0
            GROUP BY productcode
            INTO @DATA(lt_pcvarqty) PRIVILEGED ACCESS.

            IF lt_pcvarqty IS NOT INITIAL.
              APPEND VALUE #( qty = lt_pcvarqty-qty productcode = lt_pcvarqty-productcode ) TO ltPCItems.
            ENDIF.
          ELSE.
            lt_pcvarqty = wa_pcitem.
          ENDIF.

          IF lt_pcvarqty-qty = wa_diff-Difference.
            CONTINUE.
          ELSE.
            calcvarqty   = ( waItem-Consumedqty / wa_diff-quantity ) * wa_diff-difference.
            IF wa_diff-difference < 0.
              calcvarqty = floor( calcvarqty ).
            ELSE.
              calcvarqty = ceil( calcvarqty ).
            ENDIF.
            IF abs( calcvarqty + lt_pcvarqty-qty ) > abs( wa_diff-difference ).

              IF wa_diff-difference < 0.
                calcvarqty = - abs( wa_diff-difference - lt_pcvarqty-qty ).
              ELSE.
                calcvarqty = abs( wa_diff-difference - lt_pcvarqty-qty ).
              ENDIF.

              calcvarqty = wa_diff-difference - lt_pcvarqty-qty.
            ENDIF.

*            update the table
            READ TABLE ltPCItems INTO wa_pcitem WITH KEY productcode = waItem-Productcode.
            IF wa_pcitem IS NOT INITIAL.
              wa_pcitem-qty = wa_pcitem-qty + calcvarqty.
              MODIFY TABLE ltPCItems FROM wa_pcitem.
            ENDIF.

          ENDIF.
        ELSE.
          calcvarqty   = ( waItem-Consumedqty / wa_diff-quantity ) * wa_diff-difference.
        ENDIF.


        MODIFY ENTITIES OF ZR_matdistlinesbrd
        ENTITY matdistlinesbrd
        UPDATE FIELDS ( varianceqty Storagelocation BatchNo )
        WITH VALUE #( (
                                Bukrs          = waItem-Bukrs
                                plantcode      = waItem-Plantcode
                                declarecdate   = waItem-creationdate
                                shiftnumber    = waItem-shiftnumber
                                distlineno     = waItem-distlineno
                                Productcode    = waItem-Productcode
                                varianceqty    = calcvarqty
                                Storagelocation = wa_diff-storagelocation
                                BatchNo        = wa_diff-batch
                              ) )
        FAILED   DATA(ls_failed)
        REPORTED DATA(ls_reported).


        IF ls_failed IS NOT INITIAL.
          DATA lv_errmsg TYPE string.
          lv_errmsg = ls_reported-matdistlinesbrd[ 1 ]-%msg->if_message~get_longtext(  ).
        ENDIF.
        CLEAR : upd_matdistlinetab, wa_pcitem, lt_pcvarqty, lv_errmsg, calcvarqty.
      ENDLOOP.

      SELECT shiftnumber, COUNT( DISTINCT productionorder ) AS aufnr
         FROM ZR_matdistlinesbrd
         WHERE bukrs = @wadistline-Bukrs
         AND plantcode = @wadistline-Plantcode
         AND declarecdate = @wadistline-Declaredate
         GROUP BY shiftnumber
         INTO TABLE @DATA(lt_shift_count).

      DATA lv_jobcount TYPE i.
      LOOP AT lt_shift_count ASSIGNING FIELD-SYMBOL(<wa_jobcount>).
        lv_jobcount += <wa_jobcount>-aufnr.
      ENDLOOP.

      upd_matdisttab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ prodorderdate }|
                                  Variancecalculated = 1 Totaljobrun = lv_jobcount ) ).
      MODIFY ENTITIES OF ZR_materialdist01TPbrd IN LOCAL MODE
      ENTITY materialdistbrd
      UPDATE FIELDS ( Variancecalculated Totaljobrun )
      WITH upd_matdisttab.
      CLEAR : upd_matdisttab, lt_shift_count, lv_jobcount, ltpcitems.

    ENDLOOP.

    APPEND VALUE #( %cid     = mycid
                    %msg     = new_message_with_text(
                    severity = if_abap_behv_message=>severity-success
                    text     = 'Variance Calculated.' )
                    ) TO reported-materialdistbrd.

    READ ENTITIES OF ZR_materialdist01TPBRD IN LOCAL MODE
    ENTITY materialdistbrd
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(it_materialdistbrds2).

    result = VALUE #( FOR matdistline IN it_materialdistbrds2
                    ( %tky   = matdistline-%tky
                      %param = matdistline ) ).

  ENDMETHOD.

  METHOD get_instance_features.
 ENDMETHOD.

  METHOD postVariance.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvarpost' ##NO_TEXT.

    DATA upd_matdisttab TYPE TABLE FOR UPDATE ZR_materialdist01TPBRD.
    DATA prodorderdate TYPE datn.
    DATA lv_postvariancedate TYPE datn.
    DATA plantno TYPE char05.
    DATA companycode TYPE char05.
    DATA(wa_param) = keys[ 1 ]-%param.
    DATA lv_date TYPE c LENGTH 10.
    DATA lv_linedate TYPE c LENGTH 10.
    DATA lv_month TYPE c LENGTH 2.
    DATA lv_year TYPE c LENGTH 4.

    lv_month = wa_param-declarecdate+4(2).
    lv_year = wa_param-declarecdate+0(4).
    lv_date = |{ lv_year }{ lv_month }| && '%'.

    SELECT FROM ZR_materialdist01TPBRD
    FIELDS bukrs, Plantcode, Declaredate, Varianceposted, Variancecalculated
    WHERE Bukrs = @wa_param-bukrs AND Plantcode = @wa_param-werks
    AND Declarecdate LIKE @lv_date AND Variancecalculated = 1 AND Varianceposted = 0
    INTO TABLE @DATA(it_materialdistbrd) PRIVILEGED ACCESS.

    LOOP AT it_materialdistbrd INTO DATA(wa_materialdistbrd).

      companycode           = wa_materialdistbrd-Bukrs.
      plantno               = wa_materialdistbrd-Plantcode.
      prodorderdate         = wa_materialdistbrd-declaredate.
      lv_postvariancedate   = keys[ 1 ]-%param-declarecdate.

      IF wa_materialdistbrd-declaredate >= keys[ 1 ]-%param-declarecdate.
        prodorderdate       = keys[ 1 ]-%param-declarecdate .
      ENDIF.

      IF wa_materialdistbrd-Varianceposted = 0 AND wa_materialdistbrd-Variancecalculated = 1.

        upd_matdisttab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ prodorderdate }|
                                    Variancepostdate = lv_postvariancedate Varianceposted = 1 ) ).
        MODIFY ENTITIES OF ZR_materialdist01TPBRD IN LOCAL MODE
        ENTITY materialdistbrd
        UPDATE FIELDS ( Varianceposted  Variancepostdate )
        WITH upd_matdisttab.
        CLEAR : upd_matdisttab.

        DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlinesbrd.

        SELECT FROM ZR_matdistlinesTPBRD
        FIELDS bukrs, Plantcode, Declarecdate, Shiftnumber, Distlineno, Productcode
        WHERE Bukrs = @wa_materialdistbrd-Bukrs AND Plantcode = @wa_materialdistbrd-Plantcode
        AND Declarecdate = @prodorderdate AND Varianceposted = 0
        INTO TABLE @DATA(it_materialdistbrdline) PRIVILEGED ACCESS.

        LOOP AT it_materialdistbrdline INTO DATA(wa_materialdistbrdline).

          upd_matdistlinetab = VALUE #( ( bukrs                 = wa_materialdistbrdline-Bukrs
                                          Plantcode             = wa_materialdistbrdline-Plantcode
                                          declarecdate          = wa_materialdistbrdline-Declarecdate
                                          Shiftnumber           = wa_materialdistbrdline-Shiftnumber
                                          Distlineno            = wa_materialdistbrdline-Distlineno
                                          Productcode           = wa_materialdistbrdline-Productcode
                                          Variancepostlinedate  = lv_postvariancedate ) ).
          MODIFY ENTITY ZR_matdistlinesbrd
          UPDATE FIELDS ( Variancepostlinedate )
          WITH upd_matdistlinetab.

          CLEAR : upd_matdistlinetab, wa_materialdistbrdline.
        ENDLOOP.
        CLEAR it_materialdistbrdline.

      ELSE.
        APPEND VALUE #( %cid     = mycid ) TO failed-materialdistbrd.
        APPEND VALUE #( %cid     = mycid
                        %msg     = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Variance cannot be posted.' )
                    ) TO reported-materialdistbrd.
        RETURN.
      ENDIF.

      CLEAR : wa_materialdistbrd.
    ENDLOOP.

    APPEND VALUE #( %cid     = mycid
                    %msg     = new_message_with_text(
                    severity = if_abap_behv_message=>severity-success
                    text     = 'Variance Posting scheduled.' )
                    ) TO reported-materialdistbrd.

    READ ENTITIES OF ZR_materialdist01TPBRD IN LOCAL MODE
    ENTITY materialdistbrd
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(it_materialdistbrds).

    result = VALUE #( FOR matdistline IN it_materialdistbrds
                    ( %param = matdistline ) ).
  ENDMETHOD.

ENDCLASS.
