CLASS zcl_materialvariance DEFINITION
      PUBLIC
      FINAL
      CREATE PUBLIC .

      PUBLIC SECTION.

        INTERFACES if_rap_query_provider .

        TYPES: BEGIN OF ty_product,
                 product                    TYPE i_product-product,
                 plant                      TYPE i_productplantbasic-plant,
                 ProductDescription         TYPE i_productdescription_2-ProductDescription,
                 billofmaterialheader       TYPE i_billofmaterialtp_2-bomheaderquantityinbaseunit,
                 billofmaterialcomponent    TYPE i_billofmaterialitembasic-billofmaterialcomponent,
                 BillOfMaterialItemQuantity TYPE i_billofmaterialitembasic-billofmaterialitemquantity,
                 quntity                    TYPE p LENGTH 16 DECIMALS 8,
               END OF ty_product.

        DATA: it_product TYPE STANDARD TABLE OF ty_product,
              wa_product TYPE ty_product.


        TYPES: BEGIN OF ty_material,
                 ProductionOrder  TYPE I_ProductionOrderOpComponentTP-ProductionOrder,
                 BomComponentCode TYPE i_product-product,
                 counter          TYPE i,
               END OF  ty_material.
        DATA: it_material TYPE STANDARD TABLE OF ty_material,
              wa_material TYPE ty_material.


        TYPES: BEGIN OF ty_confirmation_yield,
                 OrderID                   TYPE i_productionordconfirmationtp-OrderID,
                 Plant                     TYPE i_productionordconfirmationtp-Plant,
                 Material                  TYPE i_productionordconfirmationtp-Material,
                 PostingDate               TYPE i_productionordconfirmationtp-PostingDate,
                 ConfirmationYieldQuantity TYPE i_productionordconfirmationtp-ConfirmationYieldQuantity,
                 ConfirmationScrapQuantity type i_productionordconfirmationtp-ConfirmationScrapQuantity,
                 ConfirmationReworkQuantity type i_productionordconfirmationtp-ConfirmationReworkQuantity,
                 ShiftDefinition           TYPE i_productionordconfirmationtp-ShiftDefinition,
                 BillOfMaterialComponent   TYPE i_billofmaterialitembasic-BillOfMaterialComponent,
                 BomStdConsumtion          TYPE i_productionordconfirmationtp-confirmationyieldquantity,
                 totalamountincocodecrcy   TYPE i_mfgorderdocdgoodsmovement-TotalGoodsMvtAmtInCCCrcy,
                 costingdate               TYPE i_productcostestimateitem-CostingDate,
                 BomSTDAmtCurr             TYPE i_productcostestimateitem-TotalAmountInCoCodeCrcy,
                 BaseUnit                  TYPE i_mfgorderdocdgoodsmovement-BaseUnit,
               END OF ty_confirmation_yield.

        TYPES: BEGIN OF ty_sum_yield,
                 PostingDate               TYPE i_productionordconfirmationtp-PostingDate,
                 ConfirmationYieldQuantity TYPE i_productionordconfirmationtp-ConfirmationYieldQuantity,
                 BillOfMaterialComponent   TYPE i_billofmaterialitembasic-BillOfMaterialComponent,
               END OF ty_sum_yield.


        DATA: it_confirmationyield TYPE STANDARD TABLE OF ty_confirmation_yield,
              wa_confirmationyield TYPE ty_confirmation_yield.
        DATA: lt_raw        TYPE STANDARD TABLE OF ty_confirmation_yield,
              lt_aggregated TYPE STANDARD TABLE OF ty_confirmation_yield,
              ls_aggregated TYPE ty_confirmation_yield.

      PROTECTED SECTION.
      PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MATERIALVARIANCE IMPLEMENTATION.


      METHOD if_rap_query_provider~select.
        DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
        DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
        DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

        DATA(lt_parameters)  = io_request->get_parameters( ).
        DATA(lt_fileds)  = io_request->get_requested_elements( ).
        DATA(lt_sort)          = io_request->get_sort_elements( ).

        TRY.
            DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
            CLEAR lt_Filter_cond.
        ENDTRY.


        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          IF ls_filter_cond-name = to_upper( 'comp_code' ).
            DATA(lt_comp) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'plant_code' ).
            DATA(lt_plant) = ls_FILTER_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'work_center' ).
            DATA(lt_work) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'GoodsMovementType' ).
            DATA(lt_goodsmovement) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'ProductionOrder' ).
            DATA(lt_order) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'PostingDate' ).
            DATA(lt_date) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'Shift' ).
            DATA(lt_shift) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'Product' ).
            DATA(lt_product) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'ProductDesc' ).
            DATA(lt_productdesc) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'BomComponentCode' ).
            DATA(lt_bomcompcode) = ls_filter_cond-range[].
          ENDIF.
        ENDLOOP.


        IF lt_order IS NOT INITIAL.
          LOOP AT lt_order INTO DATA(wa_PRD_ORDER).

            DATA : var1 TYPE I_ProductionOrderTP-ProductionOrder.

            IF wa_PRD_ORDER-low IS NOT INITIAL.
              var1 = wa_PRD_ORDER-low.
              wa_PRD_ORDER-low = |{ var1 ALPHA = IN }|.
            ENDIF.

            IF wa_PRD_ORDER-high IS NOT INITIAL.
              CLEAR var1.
              var1 = wa_PRD_ORDER-high.
              wa_PRD_ORDER-high = |{ var1 ALPHA = IN }|.
            ENDIF.
            MODIFY lt_order FROM wa_PRD_ORDER.
          ENDLOOP.
        ENDIF.





        DATA lv_productioorder TYPE c LENGTH 12.

        DATA: lt_result      TYPE  TABLE OF zcds_materialvariance,
              ls_line        TYPE zcds_materialvariance,
              lt_responseout LIKE lt_result,
              ls_responseout LIKE LINE OF lt_responseout,
              lt_response1   LIKE lt_result.


        SELECT FROM ztable_plant AS a
        LEFT JOIN i_mfgorderconfirmation AS c ON a~plant_code = c~Plant
        LEFT JOIN I_ProductionOrderTP AS j ON c~ManufacturingOrder = j~ProductionOrder
         LEFT JOIN i_workcenter AS i ON c~WorkCenterInternalID = i~WorkCenterInternalID
         LEFT JOIN i_productdescription_2 AS d ON j~Product = d~Product
        FIELDS
        c~manufacturingorder AS OrderID,
        c~postingdate,
        c~ShiftDefinition
         WHERE a~comp_code IN @lt_comp
         AND a~plant_code IN @lt_plant
         AND i~WorkCenter IN @lt_work
         AND c~PostingDate IN @lt_date
         AND j~product IN @lt_product
         AND c~ShiftDefinition IN @lt_shift
         AND c~ManufacturingOrder IN @lt_order
         AND d~Product IN @lt_product
        AND c~IsReversal IS INITIAL AND c~IsReversed  IS INITIAL
        INTO TABLE @DATA(it_data).

        SELECT FROM ztable_plant AS a
          INNER JOIN i_mfgorderconfirmation AS c ON a~plant_code = c~Plant
           LEFT JOIN i_productionorderopcomponenttp AS e ON c~ManufacturingOrder = e~ProductionOrder
          LEFT JOIN I_ProductionOrderTP AS j ON c~ManufacturingOrder = j~ProductionOrder
          LEFT JOIN i_workcenter AS i ON c~WorkCenterInternalID = i~WorkCenterInternalID
          LEFT JOIN i_productdescription_2 AS d ON j~Product = d~Product
*          Left join I_MFGORDERCONFMATLDOCITEM as b on c~ManufacturingOrder = b~ManufacturingOrder
*                                                   AND c~MfgOrderConfirmation = b~MfgOrderConfirmation
*                                                   AND C~MfgOrderConfirmationGroup = b~MfgOrderConfirmationGroup

          LEFT JOIN i_mfgorderdocdgoodsmovement AS h ON c~ManufacturingOrder = h~ManufacturingOrder
                                                     AND c~MaterialDocument = h~GoodsMovement
                                                     AND e~GoodsMovementType = h~GoodsMovementType
                                                     AND e~Material = h~Material
*                                                    AND e~ReservationItem = h~ReservationItem

          LEFT JOIN I_ProductValuationBasic WITH PRIVILEGED ACCESS AS g ON
           e~Material = g~Product AND
           a~plant_code = g~ValuationArea
          LEFT JOIN i_productdescription_2 AS f ON e~material = f~Product
          FIELDS
            a~comp_code,
            a~plant_code,
            c~ConfirmationYieldQuantity,
            c~ConfirmationReworkQuantity,
            c~ConfirmationScrapQuantity,
            i~WorkCenter,
            c~shiftdefinition,
            c~PostingDate,
            j~Product,
            c~ManufacturingOrder,
            d~ProductDescription,
            e~Material AS BomComponentCode,
            f~productdescription AS BomComponentName,
            e~GoodsMovementType,
            e~Currency AS ExternalProcessingUnit,
            g~InventoryValuationProcedure AS valuationprocedure,
            g~MovingAveragePrice  AS ExternalProcessingPrice,
*            h~BaseUnit,
****************************            change one
            g~standardprice  AS standardprice,
            e~requiredquantity AS BomComponentRequiredQuantity,
            h~QuantityInEntryUnit AS ActualConsumption,
            h~TotalGoodsMvtAmtInCCCrcy AS ActualCost

          WHERE a~comp_code IN @lt_comp
            AND a~plant_code IN @lt_plant
            AND i~WorkCenter IN @lt_work
            AND c~PostingDate IN @lt_date
            AND e~Material IN @lt_bomcompcode
            AND c~shiftdefinition IN @lt_shift
            AND c~ManufacturingOrder IN @lt_order
            AND j~Product IN @lt_product
            AND h~GoodsMovementType IN @lt_goodsmovement
            AND c~IsReversal IS INITIAL AND c~IsReversed  IS INITIAL
            AND ( h~GoodsMovementType = '261' OR h~GoodsMovementType = '531' )
          GROUP BY
            a~comp_code,
            a~plant_code,
            i~WorkCenter,
            c~PostingDate,
            c~shiftdefinition,
            c~ManufacturingOrder,
            c~ConfirmationYieldQuantity,
            c~ConfirmationReworkQuantity,
            c~ConfirmationScrapQuantity,
            j~Product,
            d~ProductDescription,
            e~GoodsMovementType,
            e~Material,
            f~productdescription,
            e~Currency,
            g~InventoryValuationProcedure,
            g~MovingAveragePrice,
            h~GoodsMovementType,
            g~standardprice,
            e~requiredquantity,
            h~QuantityInEntryUnit,
            h~TotalGoodsMvtAmtInCCCrcy
*            b~QuantityInEntryUnit
*            h~BaseUnit
            INTO TABLE @DATA(it).

********************************************************************************************************* added on03-05-2025 by vinay
**********where confirmationyeildquantity is initial and goods movement type is 261 or 531
        SELECT FROM ztable_plant AS a
               LEFT JOIN i_mfgorderconfirmation AS b ON a~plant_code = b~Plant AND b~confirmationyieldquantity IS INITIAL
               LEFT JOIN i_mfgorderdocdgoodsmovement AS c ON        b~ManufacturingOrder = c~ManufacturingOrder AND
                                                                     b~materialdocument = c~GoodsMovement
               LEFT JOIN i_workcenter AS d ON b~WorkCenterInternalID = d~WorkCenterInternalID
               LEFT JOIN i_productdescription_2 AS e ON c~material = e~Product
               FIELDS
                     a~comp_code,
                     a~plant_code,
                     b~ManufacturingOrder,
                     b~MaterialDocument,
                     b~ConfirmationYieldQuantity,
                     b~ConfirmationScrapQuantity,
                     b~ConfirmationReworkQuantity,
                     d~WorkCenter,
                     e~ProductDescription,
                     CASE
                        WHEN b~ShiftDefinition = '1' THEN 'DAY'
                        WHEN b~ShiftDefinition = '2' THEN 'NIGHT'
                        ELSE 'Unknown'
                     END AS ShiftDefinition,
                     c~Material,
                     c~GoodsMovementType,
                     c~PostingDate,
                     c~QuantityInEntryUnit,
                     c~TotalGoodsMvtAmtInCCCrcy

               WHERE    b~ConfirmationYieldQuantity IS INITIAL
                     AND a~comp_code IN @lt_comp
                     AND c~ManufacturingOrder IN @lt_order
                     AND a~plant_code IN @lt_plant
                     AND c~PostingDate IN @lt_date
*                     AND d~WorkCenter IN @lt_work
                     AND c~Material IN @lt_bomcompcode
                     AND b~shiftdefinition IN @lt_shift
                     AND b~IsReversal IS INITIAL
                     AND b~IsReversed IS INITIAL
                     AND c~GoodsMovementType IN @lt_goodsmovement
*                     AND ( c~GoodsMovementType = '261' OR c~GoodsMovementType = '531' )
                    AND c~GoodsMovementType IN ('261', '531')

               INTO TABLE @DATA(it_data1).


*************************************UPPER CODE COMMENTED BECOZ WARNING IN TR RELEASE**************************************
        IF it IS NOT INITIAL.
          SELECT
            p~Material,
            p~ProductionOrder,
            p~GoodsMovementType,
            p~ReservationItem
          FROM i_productionorderopcomponenttp AS p
          WHERE EXISTS (
            SELECT 1 FROM @it AS i
            WHERE i~ManufacturingOrder = p~ProductionOrder
          )
          INTO TABLE @DATA(lt_components).
        ENDIF.

        SELECT FROM i_product AS a
        INNER JOIN i_productplantbasic AS b ON a~Product = b~Product
        INNER JOIN i_productdescription_2 AS f ON a~Product = f~Product
        INNER JOIN i_billofmaterialtp_2 AS c ON a~product = c~Material AND b~plant = c~plant
        INNER JOIN ztable_plant AS g ON b~plant = c~Plant
        INNER JOIN i_billofmaterialitembasic AS d ON c~billofmaterial = d~billofmaterial
            FIELDS a~Product,f~ProductDescription , b~plant, c~BOMHeaderQuantityInBaseUnit AS billofmaterialheader , d~BillOfMaterialComponent , d~BillOfMaterialItemQuantity
            WHERE g~comp_code IN @lt_comp
            AND b~plant IN @lt_plant
            AND b~Product IN @lt_product

            INTO CORRESPONDING FIELDS OF TABLE @it_product.

        SORT it_product BY plant product.
        DELETE ADJACENT DUPLICATES FROM it_product COMPARING ALL FIELDS.


        DATA: lv_temp_quntity TYPE p LENGTH 16 DECIMALS 8.
        LOOP AT it_product INTO wa_product.
          IF wa_product-billofmaterialheader IS NOT INITIAL.
            lv_temp_quntity = wa_product-BillOfMaterialItemQuantity / wa_product-billofmaterialheader.
            wa_product-quntity = lv_temp_quntity.
          ELSE.
            wa_product-quntity = 0.
          ENDIF.
          MODIFY it_product FROM wa_product.
        ENDLOOP.

        DATA: lt_temp_product TYPE STANDARD TABLE OF ty_product.

        lt_temp_product = it_product.

        DATA: costingamt TYPE TABLE OF i_productcostestimateitem .

        IF it_product IS NOT INITIAL.
          SELECT a~manufacturingorder,
                 a~Plant,
                 a~manufacturingorder AS OrderID,
                 b~Material,
                 a~PostingDate,
                 a~shiftdefinition,
                 a~ConfirmationYieldQuantity,
                 a~confirmationScrapQuantity,
                 a~ConfirmationReworkQuantity,
                 c~billofmaterialcomponent,
                 c~billofmaterialitemunit AS BaseUnit
            FROM  I_MfgOrderConfirmation AS a
            LEFT JOIN I_ProductionOrderTP AS j ON a~ManufacturingOrder = j~ProductionOrder
            LEFT JOIN i_workcenter AS i ON a~WorkCenterInternalID = i~WorkCenterInternalID
            INNER JOIN i_billofmaterialtp_2 AS b ON j~Product = b~Material AND b~plant = b~plant
            INNER JOIN i_billofmaterialitembasic AS c ON b~billofmaterial = c~billofmaterial
            FOR ALL ENTRIES IN @it_product
            WHERE j~Product = @it_product-product
            AND i~WorkCenter IN @lt_work
            AND c~BillOfMaterialComponent IN @lt_bomcompcode
            AND a~PostingDate IN @lt_date
            AND a~ShiftDefinition IN @lt_shift
            AND a~ManufacturingOrder IN @lt_order

            INTO CORRESPONDING FIELDS OF TABLE @it_confirmationyield.
        ENDIF.


        DATA: lt_final TYPE STANDARD TABLE OF ty_confirmation_yield,
              ls_final TYPE ty_confirmation_yield.

************************************************ change on 15-05-2025 by vinay
        DATA:lv_quan TYPE ty_confirmation_yield-confirmationyieldquantity.
        lt_final = it_confirmationyield.

************************************************************************ Modified on 15-05-2025  by vinay
        LOOP AT lt_final INTO ls_final.
          READ TABLE it_product INTO wa_product
            WITH KEY billofmaterialcomponent = ls_final-billofmaterialcomponent product = ls_final-material.
          IF sy-subrc = 0.
            IF ls_final-baseunit = 'ST'.
              ls_final-bomstdconsumtion = round( val = wa_product-quntity * ls_final-confirmationyieldquantity
                                                                                                     dec = 0 ).
            ELSE.
              ls_final-bomstdconsumtion = wa_product-quntity * ls_final-confirmationyieldquantity.
            ENDIF.
            MODIFY lt_final FROM ls_final.
            CLEAR: ls_final-bomstdconsumtion.
          ENDIF.
        ENDLOOP.

        LOOP AT lt_final INTO ls_final.
          DATA(lv_first_day_of_month) = |{ ls_final-postingdate+0(6) }01|.
          SELECT SINGLE FROM i_productcostestimateitem AS a
            FIELDS a~totalamountincocodecrcy, a~costingdate
            WHERE a~product      = @ls_final-billofmaterialcomponent
              AND a~plant       = @ls_final-plant
              AND a~costingdate = @lv_first_day_of_month
             AND  a~CostingItemCategory = 'I'
            INTO (@ls_final-totalamountincocodecrcy, @ls_final-costingdate).

          MODIFY lt_final FROM ls_final.
        ENDLOOP.

******************************************************************************** added on 15-05-2025
        LOOP AT lt_final INTO ls_final.
          READ TABLE it_product INTO wa_product
            WITH KEY billofmaterialcomponent = ls_final-billofmaterialcomponent.
          IF sy-subrc = 0.
            ls_final-bomstdamtcurr = ls_final-bomstdconsumtion * ls_final-totalamountincocodecrcy.
            MODIFY lt_final FROM ls_final.
            CLEAR: ls_final-bomstdamtcurr.
          ENDIF.
        ENDLOOP.

        LOOP AT it INTO DATA(wa).
          ls_line-comp_code = wa-comp_code.
          ls_line-plant_code = wa-plant_code.
          ls_line-work_center = wa-WorkCenter.
          ls_line-PostingDate = wa-PostingDate.
          ls_line-GoodsMovementType = wa-GoodsMovementType.
          ls_line-confirmationyieldquantity = wa-ConfirmationYieldQuantity + wa-ConfirmationScrapQuantity + wa-ConfirmationReworkQuantity.
          READ TABLE it_data INTO DATA(wa_data) WITH KEY PostingDate = wa-PostingDate OrderID = wa-ManufacturingOrder .

          IF sy-subrc = 0.
            ls_line-ProductionOrder = wa_data-OrderID.
          ENDIF.

          ls_line-Product = wa-product.
          ls_line-ProductDesc = wa-ProductDescription.
          ls_line-BomComponentCode = wa-BomComponentCode.
          ls_line-BomComponentName = wa-BomComponentName.
          READ TABLE lt_final INTO ls_final WITH KEY billofmaterialcomponent = wa-BomComponentCode
                                                       plant = wa-plant_code
                                                       orderid = wa-ManufacturingOrder
                                                       postingdate = wa-PostingDate
                                                       confirmationyieldquantity = wa-ConfirmationYieldQuantity
                                                       shiftdefinition = wa-ShiftDefinition .
          IF sy-subrc = 0.
            ls_line-BomComponentRequiredQuantity = ls_final-bomstdconsumtion.
            ls_line-BomComponentAmt = ls_final-bomstdamtcurr.
**************************************************************************** Added on 15-05-2025 by vinay
          ENDIF.
          IF wa-ShiftDefinition EQ '1'.
            ls_line-Shift = 'DAY'.
          ELSEIF wa-ShiftDefinition EQ '2'.
            ls_line-Shift = 'NIGHT' .
          ENDIF.

          ls_line-BomAmtCurr = wa-ExternalProcessingUnit.
          ls_line-ActualConsumption = wa-ActualConsumption.
          ls_line-ActualCost = wa-ActualCost.

          IF ls_line-GoodsMovementType = '531' AND ( ls_line-BomComponentRequiredQuantity < 0 AND ls_line-ActualConsumption > 0 ).
            ls_line-qtydiff = ls_line-BomComponentRequiredQuantity + ls_line-ActualConsumption.
          ELSE.
            ls_line-qtydiff = ls_line-BomComponentRequiredQuantity - ls_line-ActualConsumption.
          ENDIF.
          ls_line-AmtDiff = ls_line-BomComponentAmt - wa-ActualCost.
          ls_line-AmtDiffActualRate =  ls_line-qtydiff * ( ls_line-ActualCost / ls_line-ActualConsumption ).
          SHIFT ls_line-Product LEFT DELETING LEADING '0'.
          APPEND ls_line TO lt_result.
          CLEAR: ls_line , ls_final.
          CLEAR wa.
        ENDLOOP.


******************************************************************************
        DATA : wa_it1 LIKE LINE OF lt_result.
        CLEAR it_material.
        DATA: lt_result1 LIKE lt_result.
        MOVE-CORRESPONDING lt_result TO lt_result1.

*********************************************************************15-05-2025

        SELECT FROM ztable_plant AS a
            INNER JOIN i_mfgorderconfirmation AS c ON a~plant_code = c~Plant
            LEFT JOIN I_ProductionOrderTP AS j ON c~ManufacturingOrder = j~ProductionOrder
            LEFT JOIN i_workcenter AS i ON c~WorkCenterInternalID = i~WorkCenterInternalID
            LEFT JOIN i_productdescription_2 AS d ON j~Product = d~Product
            LEFT JOIN i_productionorderopcomponenttp AS e ON c~ManufacturingOrder = e~ProductionOrder
            LEFT JOIN I_ProductValuationBasic WITH PRIVILEGED ACCESS AS g ON
             e~Material = g~Product AND
             a~plant_code = g~ValuationArea
            LEFT JOIN i_productdescription_2 AS f ON e~material = f~Product
            FIELDS f~product, f~ProductDescription , c~Plant
              WHERE a~comp_code IN @lt_comp
              AND a~plant_code IN @lt_plant
              AND i~WorkCenter IN @lt_work
              AND c~PostingDate IN @lt_date
              AND e~Material IN @lt_bomcompcode
              AND c~shiftdefinition IN @lt_shift
              AND c~ManufacturingOrder IN @lt_order
              AND j~Product IN @lt_product
              AND c~IsReversal IS INITIAL AND c~IsReversed  IS INITIAL
             INTO TABLE @DATA(it_productiondec).

*********************************************************************15-05-2025

        SORT lt_result1 BY ProductionOrder BomComponentCode.

        LOOP AT lt_result1 INTO DATA(wa_itresults).

          LOOP AT lt_components INTO DATA(wa_components) WHERE ProductionOrder = wa_itresults-ProductionOrder.
            READ TABLE lt_result INTO DATA(wa_itresult) WITH KEY ProductionOrder = wa_components-ProductionOrder
                                                                 bomcomponentcode = wa_components-Material
                                                                 PostingDate = wa_itresults-PostingDate
                                                                 Shift = wa_itresults-shift .
            IF sy-subrc NE 0.
              CLEAR wa_it1.
              wa_it1-comp_code = wa_itresults-comp_code.
              wa_it1-plant_code = wa_itresults-plant_code.
              wa_it1-ConfirmationYieldQuantity = wa_itresults-ConfirmationYieldQuantity.
              wa_it1-work_center = wa_itresults-work_center.
              wa_it1-PostingDate = wa_itresults-PostingDate.
              wa_it1-ProductDesc = wa_itresults-ProductDesc.
              wa_it1-Shift = wa_itresults-Shift.
              wa_it1-Product = wa_itresults-Product.
              wa_it1-ProductionOrder = wa_components-ProductionOrder.
              wa_it1-BomComponentCode = wa_components-Material.
              wa_it1-GoodsMovementType = wa_components-GoodsMovementType.
              wa_it1-BomAmtCurr = wa_itresults-BomAmtCurr.
              wa_it1-ActualConsumption = 0.
              wa_it1-ActualCost = 0.
              READ TABLE it_productiondec INTO DATA(wa_produc) WITH KEY Product = wa_components-Material.
              wa_it1-BomComponentName = wa_produc-ProductDescription.

              READ TABLE lt_final INTO DATA(wa_final4) WITH KEY billofmaterialcomponent = wa_components-Material
                                                               plant = wa_itresults-plant_code
                                                               orderid = wa_components-ProductionOrder
                                                               postingdate = wa_itresults-PostingDate .
              wa_it1-BomComponentRequiredQuantity = wa_final4-bomstdconsumtion.

              wa_it1-BomComponentAmt = wa_final4-bomstdamtcurr.

********************************************************************************************************** ADDED ON 15-05-2025 BY VINAY
              IF wa_it1-GoodsMovementType = '531' AND ( wa_it1-BomComponentRequiredQuantity < 0 AND wa_it1-ActualConsumption > 0 ).
                wa_it1-qtydiff = wa_it1-BomComponentRequiredQuantity + wa_it1-ActualConsumption.
              ELSE.
                wa_it1-qtydiff = wa_it1-BomComponentRequiredQuantity - wa_it1-ActualConsumption.
              ENDIF.
              wa_it1-AmtDiff = wa_it1-BomComponentAmt - wa_it1-ActualCost.
              wa_it1-AmtDiffActualRate =  wa_it1-qtydiff * ( wa_it1-ActualCost / wa_it1-ActualConsumption ).
              APPEND wa_it1 TO lt_result.
              CLEAR wa_it1.
            ENDIF.
          ENDLOOP.
        ENDLOOP.


        IF it_data1 IS NOT INITIAL.

          LOOP AT it_data1 INTO DATA(wa_data1).
            READ TABLE lt_result1 INTO DATA(wa_result1)
                 WITH KEY plant_code      = wa_data1-plant_code
                          shift           = wa_data1-shiftdefinition
                          ProductionOrder = wa_data1-ManufacturingOrder.

            IF sy-subrc = 0.
              IF wa_data1-ConfirmationYieldQuantity = 0.
                READ TABLE lt_result WITH KEY BomComponentCode = wa_data1-Material
                                             PostingDate      = wa_data1-postingdate
                                             confirmationyieldquantity = wa_data1-ConfirmationYieldQuantity
                                             Shift            = wa_data1-shiftdefinition
                                             ProductionOrder  = wa_data1-ManufacturingOrder
                                             TRANSPORTING NO FIELDS.

                IF sy-subrc <> 0.
                  CLEAR wa_it1.
                  wa_it1-comp_code               = wa_data1-comp_code.
                  wa_it1-plant_code              = wa_data1-plant_code.
                  wa_it1-PostingDate             = wa_data1-postingdate.
                  wa_it1-Shift                   = wa_data1-shiftdefinition.
                  wa_it1-Product                 = wa_result1-Product.
                  wa_it1-confirmationyieldquantity = wa_data1-ConfirmationYieldQuantitY + wa_data1-ConfirmationScrapQuantity + wa_data1-ConfirmationReworkQuantity.
                  wa_it1-ProductDesc             = wa_result1-ProductDesc.
                  wa_it1-ProductionOrder         = wa_data1-ManufacturingOrder.
                  wa_it1-BomComponentCode        = wa_data1-Material.
                  wa_it1-GoodsMovementType       = wa_data1-GoodsMovementType.
                  wa_it1-BomAmtCurr              = wa_result1-BomAmtCurr.
                  wa_it1-ActualConsumption       = wa_data1-QuantityInEntryUnit.
                  wa_it1-ActualCost              = wa_data1-TotalGoodsMvtAmtInCCCrcy.
                  wa_it1-work_center             = wa_data1-WorkCenter.
                  wa_it1-BomComponentName        = wa_data1-ProductDescription.

                  APPEND wa_it1 TO lt_result.
                ENDIF.

              ENDIF.
            ENDIF.

          ENDLOOP.

        ENDIF.

        LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_response1>).

          SHIFT <ls_response1>-ProductionOrder LEFT DELETING LEADING '0'.
          SHIFT <ls_response1>-BomComponentCode LEFT DELETING LEADING '0'.
          APPEND  <ls_response1> TO lt_response1.
        ENDLOOP.

        DELETE lt_response1 WHERE BomComponentRequiredQuantity = 0 AND ActualConsumption = 0 .


        DATA: lt_keep TYPE STANDARD TABLE OF zcds_materialvariance,
              wa_temp TYPE zcds_materialvariance,
              wa_next TYPE zcds_materialvariance.

        SORT lt_response1 BY comp_code plant_code work_center postingdate shift
                           productionorder confirmationyieldquantity product productdesc
                           bomcomponentcode bomcomponentname actualconsumption
                           goodsmovementtype actualcost.

        DATA(lv_lines) = lines( lt_response1 ).
        DATA(lv_idx)   = 1.

        WHILE lv_idx <= lv_lines.

          READ TABLE lt_response1 INTO wa_temp INDEX lv_idx.
          READ TABLE lt_response1 INTO wa_next INDEX lv_idx + 1.

          IF sy-subrc = 0 AND
             wa_temp-comp_code            = wa_next-comp_code AND
             wa_temp-plant_code           = wa_next-plant_code AND
             wa_temp-work_center          = wa_next-work_center AND
             wa_temp-postingdate          = wa_next-postingdate AND
             wa_temp-shift                = wa_next-shift AND
             wa_temp-productionorder      = wa_next-productionorder AND
             wa_temp-confirmationyieldquantity = wa_next-confirmationyieldquantity AND
             wa_temp-product              = wa_next-product AND
             wa_temp-productdesc          = wa_next-productdesc AND
             wa_temp-bomcomponentcode     = wa_next-bomcomponentcode AND
             wa_temp-bomcomponentname     = wa_next-bomcomponentname AND
             wa_temp-actualconsumption    = wa_next-actualconsumption AND
             wa_temp-goodsmovementtype    = wa_next-goodsmovementtype AND
             wa_temp-actualcost           = wa_next-actualcost.

            IF wa_temp-qtydiff <> 0 OR wa_temp-amtdiff <> 0 OR wa_temp-amtdiffactualrate <> 0.
              APPEND wa_temp TO lt_keep.
            ELSEIF wa_next-qtydiff <> 0 OR wa_next-amtdiff <> 0 OR wa_next-amtdiffactualrate <> 0.
              APPEND wa_next TO lt_keep.
            ENDIF.

            ADD 2 TO lv_idx.

          ELSE.
            APPEND wa_temp TO lt_keep.
            ADD 1 TO lv_idx.
          ENDIF.

        ENDWHILE.

        lt_response1 = lt_keep.



        SORT lt_response1 BY comp_code.
        LOOP AT lt_sort INTO DATA(ls_sort).
          CASE ls_sort-element_name.
            WHEN 'COMP_CODE'.
              SORT lt_response1 BY comp_code ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY comp_code DESCENDING.
              ENDIF.

            WHEN 'BOMCOMPONENTNAME'.
              SORT lt_response1 BY  BomComponentName ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY BomComponentName DESCENDING.
              ENDIF.


            WHEN 'PLANT_CODE'.
              SORT lt_response1 BY  plant_code ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY plant_code DESCENDING.
              ENDIF.


            WHEN 'WORK_CENTER'.
              SORT lt_response1  BY work_center ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1  BY work_center DESCENDING.
              ENDIF.


            WHEN 'POSTINGDATE'.
              SORT lt_response1 BY PostingDate ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY PostingDate DESCENDING.
              ENDIF.

            WHEN 'SHIFT'.
              SORT lt_response1 BY shift ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY shift DESCENDING.
              ENDIF.

            WHEN 'PRODUCTIONORDER'.
              SORT lt_response1 BY productionorder ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY productionorder DESCENDING.
              ENDIF.


            WHEN 'CONFIRMATIONYIELDQUANTITY'.
              SORT lt_response1 BY confirmationyieldquantity ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY confirmationyieldquantity DESCENDING.
              ENDIF.


            WHEN 'PRODUCT'.
              SORT lt_response1 BY product ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY product DESCENDING.
              ENDIF.


            WHEN 'PRODUCTDESC'.
              SORT lt_response1 BY productdesc ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY productdesc DESCENDING.
              ENDIF.


            WHEN 'BOMCOMPONENTCODE'.
              SORT lt_response1 BY bomcomponentcode ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY bomcomponentcode DESCENDING.
              ENDIF.

            WHEN 'BOMCOMPONENTREQUIREDQUANTITY'.
              SORT lt_response1 BY bomcomponentrequiredquantity ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY bomcomponentrequiredquantity DESCENDING.
              ENDIF.



            WHEN 'BOMCOMPONENTAMT'.
              SORT lt_response1 BY BomComponentAmt ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY BomComponentAmt DESCENDING.
              ENDIF.



            WHEN 'ACTUALCONSUMPTION'.
              SORT lt_response1 BY actualconsumption ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY actualconsumption DESCENDING.
              ENDIF.

            WHEN 'GOODSMOVEMENTTYPE'.
              SORT lt_response1 BY goodsmovementtype ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY goodsmovementtype DESCENDING.
              ENDIF.


            WHEN 'BOMAMTCURR'.
              SORT lt_response1 BY bomamtcurr ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY bomamtcurr DESCENDING.
              ENDIF.

            WHEN 'ACTUALCOST'.
              SORT lt_response1 BY actualcost ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY actualcost DESCENDING.
              ENDIF.

            WHEN 'QTYDIFF'.
              SORT lt_response1 BY qtydiff ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY qtydiff DESCENDING.
              ENDIF.

            WHEN 'AMTDIFF'.
              SORT lt_response1 BY amtdiff ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY amtdiff DESCENDING.
              ENDIF.

            WHEN 'AMTDIFFACTUALRATE'.
              SORT lt_response1 BY amtdiffactualrate ASCENDING.
              IF ls_sort-descending = abap_true.
                SORT lt_response1 BY amtdiffactualrate DESCENDING.
              ENDIF.
          ENDCASE.
        ENDLOOP.

        lv_max_rows = lv_skip + lv_top.
        IF lv_skip > 0.
          lv_skip = lv_skip + 1.
        ENDIF.

        CLEAR lt_responseout.
        LOOP AT lt_response1 ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
          ls_responseout = <lfs_out_line_item>.
          APPEND ls_responseout TO lt_responseout.
          CLEAR : ls_responseout.
        ENDLOOP.
        io_response->set_total_number_of_records( lines( lt_response1 ) ).
        io_response->set_data( lt_responseout ).



      ENDMETHOD.
ENDCLASS.
