CLASS lhc_materialdist DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR materialdist RESULT result.

    METHODS createvariancedata FOR MODIFY
      IMPORTING keys FOR ACTION materialdist~createVarianceData RESULT result.
    METHODS calculateVariance FOR MODIFY
      IMPORTING keys FOR ACTION materialdist~calculateVariance RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR materialdist RESULT result.

    METHODS postVariance FOR MODIFY
      IMPORTING keys FOR ACTION materialdist~postVariance RESULT result.


ENDCLASS.

CLASS lhc_materialdist IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD createVarianceData.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvariance' ##NO_TEXT.

    DATA prodorderdate TYPE datum.
    DATA prodordertodate TYPE datn.
    DATA plantno TYPE char05.
    DATA companycode TYPE char05.
    DATA productdesc TYPE char72.
    DATA productcode TYPE char72.
    DATA distlineno TYPE int2.
    DATA totalconsumedqty TYPE p DECIMALS 3.
    DATA stockqty TYPE p DECIMALS 3.
    DATA stockvarqty TYPE p DECIMALS 3.
    DATA calcvarqty TYPE p DECIMALS 3.
    DATA isconsumed TYPE int1.

    DATA create_matdist TYPE STRUCTURE FOR CREATE ZR_materialdist01TP.
    DATA create_matdisttab TYPE TABLE FOR CREATE ZR_materialdist01TP.
    DATA upd_matdisttab TYPE TABLE FOR UPDATE ZR_materialdist01TP.

    DATA create_matdistline TYPE STRUCTURE FOR CREATE ZR_matdistlines.
    DATA create_matdistlinetab TYPE TABLE FOR CREATE ZR_matdistlines.
    DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlines.


    LOOP AT keys INTO DATA(ls_key).
      TRY.
          plantno = ls_key-%param-PlantNo .
          prodorderdate = ls_key-%param-prodorderdate .
          prodordertodate = ls_key-%param-prodordertodate .

          IF plantno = ''.
            APPEND VALUE #( %cid     = ls_key-%cid ) TO failed-materialdist.
            APPEND VALUE #( %cid     = ls_key-%cid
                            %msg     = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = 'Plant No. cannot be blank.' )
                          ) TO reported-materialdist.
            RETURN.
          ENDIF.
      ENDTRY.

      plantno = to_upper( plantno ).

      SELECT SINGLE FROM ztable_plant FIELDS comp_code
      WHERE plant_code = @plantno INTO @DATA(lv_companycode2).
      companycode = lv_companycode2.

      SELECT FROM zmaterialdist
      FIELDS bukrs, plantcode, varianceposted, declarecdate
      WHERE bukrs = @companycode AND plantcode = @plantno
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
                                    Bukrs              = companycode
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

        MODIFY ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
        ENTITY materialdist
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

            SELECT FROM ZR_matdistlines
            FIELDS Bukrs, Plantcode, Declarecdate, Shiftnumber, Distlineno
            WHERE bukrs = @lv_companycode2 AND plantcode = @plantno AND declarecdate = @walines-declarecdate
            INTO TABLE @DATA(ltcheck).

            MODIFY ENTITIES OF ZR_matdistlines
            ENTITY ZR_matdistlines
            DELETE FROM VALUE #(
                                    FOR line IN ltcheck (
                                                            Bukrs = line-bukrs
                                                            plantcode = line-plantcode
                                                            declarecdate = line-declarecdate
                                                            shiftnumber = line-shiftnumber
                                                            distlineno = line-distlineno )
            )
            MAPPED DATA(mapped1)
            FAILED DATA(failed1)
            REPORTED DATA(reported1).

          ELSE.
            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-materialdist.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = 'Variance already posted.' )
                        ) TO reported-materialdist.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDIF.

      distlineno = 0.
      "Loop for unique item declaration
      SELECT FROM zmaterialdecl AS md
      FIELDS DISTINCT md~productcode
      WHERE md~bukrs = @companycode AND md~plantcode = @plantno AND md~declaredate >= @prodorderdate
      AND md~declaredate <= @prodordertodate AND md~stockquantity <> 0
      INTO TABLE @DATA(ltItems).

      LOOP AT ltitems INTO DATA(waItem).
        totalconsumedqty = 0.
        stockqty = 0.
        stockvarqty = 0.
        isconsumed = 0.

        productdesc = ''.
        productcode = waitem-productcode.
        productcode = |{ productcode  WIDTH = 18 ALIGN = RIGHT  PAD = '0' }|.

        SELECT FROM I_ProductDescription AS pd
        FIELDS pd~Product, pd~ProductDescription
        WHERE ( pd~Product = @waitem-productcode OR pd~Product = @productcode ) AND pd~LanguageISOCode = 'EN'
        INTO TABLE @DATA(Itlines).

        DATA: ls_Itlines LIKE LINE OF Itlines.

        READ TABLE Itlines WITH KEY Product = productcode INTO ls_Itlines.
        IF sy-subrc = 0.
          productcode = ls_Itlines-Product.
          productdesc = ls_Itlines-ProductDescription.
        ELSE.
          READ TABLE Itlines WITH KEY Product = waitem-productcode INTO ls_Itlines.
          IF sy-subrc = 0.
            productcode = ls_Itlines-Product.
            productdesc = ls_Itlines-ProductDescription.
          ENDIF.
        ENDIF.

        TYPES: BEGIN OF ty_sum,
                 plant       TYPE c LENGTH 4,
                 postingdate TYPE datn,
                 material    TYPE c LENGTH 40,
                 mfgOrder    TYPE c LENGTH 12,
                 batch       TYPE c LENGTH 10,
                 lgort       TYPE c LENGTH 10,
                 shiftno     TYPE c LENGTH 4,
                 qty         TYPE I_MaterialDocumentItem_2-QuantityInEntryUnit,
               END OF ty_sum.
        DATA: it_qty TYPE TABLE OF ty_sum,
              wa_qty TYPE ty_sum.

        SELECT FROM I_MaterialDocumentItem_2 AS a
        LEFT JOIN I_ProductText AS b ON a~Material =  b~Product AND b~Language = 'E'
        LEFT JOIN i_mfgorderconfmatldocitem AS e ON e~materialdocument = a~materialdocument AND e~materialdocumentitem = a~materialdocumentitem
                                                      AND  e~materialdocumentyear = a~materialdocumentyear
        LEFT JOIN I_mfgorderconfirmation AS c ON  c~manufacturingorder = a~manufacturingorder AND c~mfgorderconfirmation = e~mfgorderconfirmation
        FIELDS a~ManufacturingOrder,
        a~MaterialDocument, a~MaterialDocumentItem, a~MaterialDocumentYear, a~ReversedMaterialDocument,
        a~Material , a~Plant, a~StorageLocation, a~QuantityInEntryUnit, a~PostingDate, a~GoodsMovementType,
        a~MaterialBaseUnit, a~Batch, b~ProductName, c~ShiftDefinition
        WHERE a~GoodsMovementType IN ( '261', '262' )
        AND a~Plant = @plantno AND a~Material = @productcode
        AND a~PostingDate >= @prodorderdate AND a~PostingDate <= @prodordertodate
        AND a~Material IS NOT INITIAL
        INTO TABLE @DATA(lt_final) PRIVILEGED ACCESS.

        SORT lt_final BY Plant Material ManufacturingOrder PostingDate ShiftDefinition.

        LOOP AT lt_final ASSIGNING FIELD-SYMBOL(<wa_final>).

          wa_qty-plant           = <wa_final>-Plant.
          wa_qty-postingdate     = <wa_final>-PostingDate.
          wa_qty-material        = <wa_final>-Material.
          wa_qty-mfgorder        = <wa_final>-ManufacturingOrder.
          wa_qty-batch           = <wa_final>-Batch.
          wa_qty-lgort           = <wa_final>-StorageLocation.
          wa_qty-shiftno         = <wa_final>-ShiftDefinition.
          IF <wa_final>-GoodsMovementType = '262'.
            wa_qty-qty -= <wa_final>-QuantityInEntryUnit.
          ELSE.
            wa_qty-qty  = <wa_final>-QuantityInEntryUnit.
          ENDIF.

          COLLECT wa_qty INTO it_qty.
          CLEAR wa_qty.
        ENDLOOP.

        SELECT FROM I_MfgOrderConfirmation AS a
        JOIN i_prodnordconfmatldocitemtp AS b ON a~ManufacturingOrder = b~OrderID AND a~MfgOrderConfirmationGroup = b~ConfirmationGroup
        AND a~MfgOrderConfirmation = b~ConfirmationCount
        FIELDS a~ManufacturingOrder, b~StorageLocation, b~Batch, a~ShiftDefinition, a~ShiftGrouping, a~MfgOrderConfirmationGroup,
        a~ManufacturingOrderSequence, a~PostingDate, a~Plant, b~EntryUnit, b~Material, SUM( b~QuantityInEntryUnit ) AS qty
        WHERE a~Plant = @plantno AND a~PostingDate >= @prodorderdate AND a~PostingDate <= @prodordertodate
        AND b~Material = @productcode AND a~IsReversal NE 'X' AND a~IsReversed NE 'X'
        GROUP BY a~ManufacturingOrder, b~StorageLocation, b~Batch, a~ShiftDefinition, a~ShiftGrouping,
        a~MfgOrderConfirmationGroup, a~ManufacturingOrderSequence, a~PostingDate, a~Plant, b~EntryUnit, b~Material
        INTO TABLE @DATA(ltmatlines).

        LOOP AT ltmatlines INTO DATA(wamatline).
          "Insert Shift wise consumption record
          distlineno = distlineno + 1.
          READ TABLE it_qty INTO DATA(wa_qty2) WITH KEY plant = wamatline-Plant material = wamatline-Material
                                                        postingdate = wamatline-PostingDate mfgorder = wamatline-ManufacturingOrder
                                                        batch = wamatline-Batch lgort = wamatline-StorageLocation
                                                        shiftno = wamatline-ShiftDefinition.
*          IF wa_qty2 IS NOT INITIAL.
          create_matdistline = VALUE #( %cid             = ls_key-%cid
                                        Bukrs            = companycode
                                        plantcode        = plantno
                                        declarecdate     = wamatline-PostingDate
                                        shiftnumber      = wamatline-ShiftDefinition
                                        distlineno       = distlineno
                                        declaredate      = wamatline-PostingDate
                                        productionorder  = wamatline-ManufacturingOrder
                                        productionorderline    = 1
                                        Orderconfirmationgroup = wamatline-MfgOrderConfirmationGroup
                                        Ordersequence    = wamatline-ManufacturingOrderSequence
                                        storagelocation  = wamatline-StorageLocation
                                        productcode      = productcode
                                        batchno          = wamatline-Batch
                                        productdesc      = productdesc
                                        consumedqty      = abs( wa_qty2-qty )
                                        varianceqty      = 0
                                        varianceposted   = 0
                                        Entryuom         = wamatline-EntryUnit
                                        Shiftgroup       = wamatline-ShiftGrouping
                                        Variancepostlinedate   = wamatline-PostingDate
                      ).
          APPEND create_matdistline TO create_matdistlinetab.
          totalconsumedqty = totalconsumedqty + wamatline-qty.
          isconsumed = 1.

          MODIFY ENTITIES OF ZR_matdistlines
          ENTITY ZR_matdistlines
          CREATE FIELDS ( bukrs plantcode declarecdate shiftnumber Distlineno declaredate Productionorder Productionorderline
          Orderconfirmationgroup Ordersequence Storagelocation
          Productcode Batchno Productdesc Consumedqty Varianceqty Varianceposted Entryuom Shiftgroup Variancepostlinedate )
          WITH create_matdistlinetab.
*          ENDIF.
          CLEAR : create_matdistline, create_matdistlinetab, wa_qty2.
        ENDLOOP.
        CLEAR it_qty.
      ENDLOOP.

      APPEND VALUE #( %cid = ls_key-%cid
                      %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text     = 'Variance Data Created.' )
                      ) TO reported-materialdist.
      RETURN.

    ENDLOOP.
  ENDMETHOD.


  METHOD calculateVariance.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvariance' ##NO_TEXT.

    DATA prodorderdate TYPE datum.
    DATA plantno TYPE char05.
    DATA companycode TYPE char05.
    DATA productdesc TYPE char72.
    DATA productcode TYPE char72.
    DATA distlineno TYPE int2.
    DATA totalconsumedqty TYPE p DECIMALS 3.
    DATA stockqty TYPE p DECIMALS 3.
    DATA stockvarqty TYPE p DECIMALS 3.
    DATA calcvarqty TYPE p DECIMALS 3.
    DATA isconsumed TYPE int1.
    DATA upd_matdisttab TYPE TABLE FOR UPDATE ZR_materialdist01TP.
    DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlines.

    READ ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
    ENTITY materialdist
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(it_materialdist).

    LOOP AT it_materialdist INTO DATA(wadistline).
      companycode   = wadistline-Bukrs.
      plantno       = wadistline-Plantcode.
      prodorderdate = wadistline-declaredate.

      SELECT FROM zmatdistlines AS mdlines
      FIELDS DISTINCT mdlines~productionorder
      WHERE mdlines~bukrs = @companycode AND mdlines~plantcode = @plantno
      AND mdlines~declaredate = @prodorderdate
      AND mdlines~varianceqty <> 0 AND mdlines~varianceposted = 1
      INTO TABLE @DATA(ltcheck).

      IF ltcheck IS NOT INITIAL.
        APPEND VALUE #( %cid = mycid ) TO failed-materialdist.
        APPEND VALUE #( %cid = mycid
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Variance already posted.' )
                ) TO reported-materialdist.

        READ ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
        ENTITY materialdist
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(it_materialdists).

        result = VALUE #( FOR matdistline IN it_materialdists
                ( %tky   = matdistline-%tky
                  %param = matdistline ) ).

        RETURN.
      ENDIF.

      upd_matdistlinetab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ prodorderdate }| varianceqty = 0 ) ).
      MODIFY ENTITY ZR_matdistlines
      UPDATE FIELDS ( varianceqty )
      WITH upd_matdistlinetab.
      CLEAR : upd_matdistlinetab.

      SELECT FROM zmaterialdecl AS md
      FIELDS DISTINCT md~productcode
      WHERE md~bukrs = @companycode AND md~plantcode = @plantno
      AND md~declaredate = @prodorderdate AND md~stockquantity <> 0
      INTO TABLE @DATA(ltItems).

      LOOP AT ltitems INTO DATA(waItem).
        productcode = waItem-productcode.
        productcode = |{ productcode  WIDTH = 18 ALIGN = RIGHT  PAD = '0' }|.

        SELECT FROM I_ProductDescription AS pd
        FIELDS pd~Product, pd~ProductDescription
        WHERE ( pd~Product = @waitem-productcode OR pd~Product = @productcode ) AND pd~LanguageISOCode = 'EN'
        INTO TABLE @DATA(Itlines).

        DATA: ls_Itlines LIKE LINE OF Itlines.

        READ TABLE Itlines WITH KEY Product = productcode INTO ls_Itlines.
        IF sy-subrc = 0.
          productcode = ls_Itlines-Product.
        ELSE.
          READ TABLE Itlines WITH KEY Product = waitem-productcode INTO ls_Itlines.
          IF sy-subrc = 0.
            productcode = ls_Itlines-Product.
          ENDIF.
        ENDIF.
        totalconsumedqty = 0.
        stockqty = 0.
        stockvarqty = 0.

        SELECT FROM zmaterialdecl AS a
        FIELDS a~productcode, SUM( a~stockquantity ) AS qty
        WHERE a~bukrs = @companycode AND a~plantcode = @plantno
        AND a~declaredate = @prodorderdate AND a~productcode = @waitem-productcode
        GROUP BY a~productcode
        INTO TABLE @DATA(ltStock).

        LOOP AT ltStock INTO DATA(waltStock).
          stockvarqty = 0.
          SELECT FROM zmatdistlines AS mdlines
          FIELDS SUM( mdlines~consumedqty ) AS consumedqty
          WHERE mdlines~Bukrs = @companycode AND mdlines~plantcode = @plantno AND mdlines~declaredate = @prodorderdate
          AND mdlines~productcode = @productcode "AND mdlines~batchno = @waltStock-batchno
          INTO TABLE @DATA(ltdlineStock).

          LOOP AT ltdlineStock INTO DATA(waltdlineStock).
            stockvarqty = waltStock-qty - waltdlineStock-consumedqty.
          ENDLOOP.
          IF stockvarqty <> 0.
            "Distribute variance
            SELECT FROM zmatdistlines AS mdlines
            FIELDS mdlines~shiftnumber, mdlines~declarecdate, mdlines~distlineno, mdlines~consumedqty
            WHERE mdlines~Bukrs = @companycode AND mdlines~plantcode = @plantno AND mdlines~declaredate = @prodorderdate
            AND mdlines~productcode = @productcode "AND mdlines~batchno = @waltStock-batchno
            INTO TABLE @DATA(ltdlineStockUpd).

            LOOP AT ltdlineStockUpd INTO DATA(waltdlineStockUpd).

              calcvarqty         = stockvarqty * waltdlineStockUpd-consumedqty / waltdlineStock-consumedqty.
              upd_matdistlinetab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = waltdlineStockUpd-declarecdate
                                              shiftnumber = waltdlineStockUpd-shiftnumber distlineno = waltdlineStockUpd-distlineno varianceqty = calcvarqty ) ).
              MODIFY ENTITY ZR_matdistlines
              UPDATE FIELDS ( varianceqty )
              WITH upd_matdistlinetab.
              CLEAR : upd_matdistlinetab.
            ENDLOOP.

          ENDIF.
        ENDLOOP.
      ENDLOOP.

      SELECT shiftnumber, COUNT( DISTINCT productionorder ) AS aufnr
      FROM zmatdistlines
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
      MODIFY ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
      ENTITY materialdist
      UPDATE FIELDS ( Variancecalculated Totaljobrun )
      WITH upd_matdisttab.
      CLEAR : upd_matdisttab, lt_shift_count, lv_jobcount.
    ENDLOOP.

    APPEND VALUE #( %cid     = mycid
                    %msg     = new_message_with_text(
                    severity = if_abap_behv_message=>severity-success
                    text     = 'Variance Calculated.' )
                    ) TO reported-materialdist.

    READ ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
    ENTITY materialdist
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(it_materialdists2).

    result = VALUE #( FOR matdistline IN it_materialdists2
                    ( %tky   = matdistline-%tky
                      %param = matdistline ) ).

  ENDMETHOD.

  METHOD get_instance_features.
*    READ ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
*      ENTITY materialdist
*      ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(materialdistlist).
*
*    result = VALUE #( FOR it_materialdist IN materialdistlist
*                        LET
*                          is_cancelled = COND #( WHEN it_materialdist-Varianceposted = 1
*                                                 THEN if_abap_behv=>fc-o-disabled
*                                                 ELSE if_abap_behv=>fc-o-enabled  )
*                        IN
*                            ( %tky                      = it_materialdist-%tky
*                              %action-calculateVariance = is_cancelled ) ).
*
*    result = VALUE #( FOR it_materialdist IN materialdistlist
*                        LET
*                          is_cancelled = COND #( WHEN it_materialdist-Varianceposted = 1
*                                                 THEN if_abap_behv=>fc-o-disabled
*                                                 ELSE if_abap_behv=>fc-o-enabled  )
*                        IN
*                            ( %tky                      = it_materialdist-%tky
*                              %action-postVariance = is_cancelled ) ).
  ENDMETHOD.

  METHOD postVariance.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvarpost' ##NO_TEXT.

    DATA upd_matdisttab TYPE TABLE FOR UPDATE ZR_materialdist01TP.
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

    SELECT FROM ZR_materialdist01TP
    FIELDS bukrs, Plantcode, Declaredate, Varianceposted, Variancecalculated
    WHERE Bukrs = @wa_param-bukrs AND Plantcode = @wa_param-werks
    AND Declarecdate LIKE @lv_date AND Variancecalculated = 1 AND Varianceposted = 0
    INTO TABLE @DATA(it_materialdist) PRIVILEGED ACCESS.

    LOOP AT it_materialdist INTO DATA(wa_materialdist).

      companycode           = wa_materialdist-Bukrs.
      plantno               = wa_materialdist-Plantcode.
      prodorderdate         = wa_materialdist-declaredate.
      lv_postvariancedate   = keys[ 1 ]-%param-declarecdate.

      IF wa_materialdist-declaredate >= keys[ 1 ]-%param-declarecdate.
        prodorderdate       = keys[ 1 ]-%param-declarecdate .
      ENDIF.

      IF wa_materialdist-Varianceposted = 0 AND wa_materialdist-Variancecalculated = 1.

        upd_matdisttab = VALUE #( ( bukrs = companycode plantcode = plantno declarecdate = |{ prodorderdate }|
                                    Variancepostdate = lv_postvariancedate Varianceposted = 1 ) ).
        MODIFY ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
        ENTITY materialdist
        UPDATE FIELDS ( Varianceposted  Variancepostdate )
        WITH upd_matdisttab.
        CLEAR : upd_matdisttab.

        DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlines.

        SELECT FROM ZR_matdistlinesTP
        FIELDS bukrs, Plantcode, Declarecdate, Shiftnumber, Distlineno
        WHERE Bukrs = @wa_materialdist-Bukrs AND Plantcode = @wa_materialdist-Plantcode
        AND Declarecdate = @prodorderdate AND Varianceposted = 0
        INTO TABLE @DATA(it_materialdistline) PRIVILEGED ACCESS.

        LOOP AT it_materialdistline INTO DATA(wa_materialdistline).

          upd_matdistlinetab = VALUE #( ( bukrs                 = wa_materialdistline-Bukrs
                                          Plantcode             = wa_materialdistline-Plantcode
                                          declarecdate          = wa_materialdistline-Declarecdate
                                          Shiftnumber           = wa_materialdistline-Shiftnumber
                                          Distlineno            = wa_materialdistline-Distlineno
                                          Variancepostlinedate  = lv_postvariancedate ) ).
          MODIFY ENTITY ZR_matdistlines
          UPDATE FIELDS ( Variancepostlinedate )
          WITH upd_matdistlinetab.

          CLEAR : upd_matdistlinetab, wa_materialdistline.
        ENDLOOP.
        CLEAR it_materialdistline.

      ELSE.
        APPEND VALUE #( %cid     = mycid ) TO failed-materialdist.
        APPEND VALUE #( %cid     = mycid
                        %msg     = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Variance cannot be posted.' )
                    ) TO reported-materialdist.
        RETURN.
      ENDIF.

      CLEAR : wa_materialdist.
    ENDLOOP.

    APPEND VALUE #( %cid     = mycid
                    %msg     = new_message_with_text(
                    severity = if_abap_behv_message=>severity-success
                    text     = 'Variance Posting scheduled.' )
                    ) TO reported-materialdist.

    READ ENTITIES OF ZR_materialdist01TP IN LOCAL MODE
    ENTITY materialdist
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(it_materialdists).

    result = VALUE #( FOR matdistline IN it_materialdists
                    ( %param = matdistline ) ).
  ENDMETHOD.

ENDCLASS.
