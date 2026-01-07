CLASS zcl_materialvariance_02 DEFINITION
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
             ComponentDescription       type i_productdescription_2-productdescription,
           END OF ty_product.

    TYPES: BEGIN OF ty_confirmation_yield,
             OrderID                    TYPE i_productionordconfirmationtp-OrderID,
             Plant                      TYPE i_productionordconfirmationtp-Plant,
             Material                   TYPE i_productionordconfirmationtp-Material,
             PostingDate                TYPE i_productionordconfirmationtp-PostingDate,
             ConfirmationYieldQuantity  TYPE i_productionordconfirmationtp-ConfirmationYieldQuantity,
             ConfirmationScrapQuantity  TYPE i_productionordconfirmationtp-ConfirmationScrapQuantity,
             ConfirmationReworkQuantity TYPE i_productionordconfirmationtp-ConfirmationReworkQuantity,
             ShiftDefinition            TYPE i_productionordconfirmationtp-ShiftDefinition,
             BillOfMaterialComponent    TYPE i_billofmaterialitembasic-BillOfMaterialComponent,
             BomStdConsumtion           TYPE i_productionordconfirmationtp-confirmationyieldquantity,
             totalamountincocodecrcy    TYPE i_mfgorderdocdgoodsmovement-TotalGoodsMvtAmtInCCCrcy,
             costingdate                TYPE i_productcostestimateitem-CostingDate,
             BomSTDAmtCurr              TYPE i_productcostestimateitem-TotalAmountInCoCodeCrcy,
             BaseUnit                   TYPE i_mfgorderdocdgoodsmovement-BaseUnit,
           END OF ty_confirmation_yield.

  TYPES: BEGIN OF ty_actual_cost,
         ManufacturingOrder       TYPE i_mfgorderdocdgoodsmovement-ManufacturingOrder,
         Material                 TYPE i_mfgorderdocdgoodsmovement-Material,
         GoodsMovementType        TYPE i_mfgorderdocdgoodsmovement-GoodsMovementType,
         TotalGoodsMvtAmtInCCCrcy TYPE i_mfgorderdocdgoodsmovement-TotalGoodsMvtAmtInCCCrcy,
         BomStdCost               TYPE i_mfgorderdocdgoodsmovement-TotalGoodsMvtAmtInCCCrcy,
       END OF ty_actual_cost.

PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MATERIALVARIANCE_02 IMPLEMENTATION.


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

    DATA: lt_result      TYPE  TABLE OF ZCDS_MaterialVariance_02,
          ls_line        TYPE ZCDS_MaterialVariance_02,
          lt_responseout LIKE lt_result,
          ls_responseout LIKE LINE OF lt_responseout,
          lt_response1   LIKE lt_result.


    DATA: it_product TYPE TABLE OF ty_product,
          wa_product TYPE ty_product.

    SELECT FROM ztable_plant AS a
      INNER JOIN i_mfgorderconfirmation AS c ON a~plant_code = c~Plant
      LEFT JOIN i_mfgorderconfmatldocitem AS e ON c~ManufacturingOrder = e~ManufacturingOrder
                                               AND c~MfgOrderConfirmation = e~MfgOrderConfirmation
                                               AND c~MfgOrderConfirmationGroup = e~MfgOrderConfirmationGroup
********************************************************************************************************************************
      LEFT JOIN I_MfgOrderConfMatlDocItem AS b ON c~ManufacturingOrder = b~ManufacturingOrder
                                                AND c~MfgOrderConfirmation = b~MfgOrderConfirmation
                                                AND c~MfgOrderConfirmationGroup = b~MfgOrderConfirmationGroup
                                                AND e~GoodsMovementType = b~GoodsMovementType
********************************************************************************************************************************
      LEFT JOIN I_ProductionOrderTP AS j ON c~ManufacturingOrder = j~ProductionOrder
      LEFT JOIN i_workcenter AS i ON c~WorkCenterInternalID = i~WorkCenterInternalID
      LEFT JOIN i_productdescription_2 AS d ON j~Product = d~Product
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
        c~MfgOrderConfirmation,
        c~MfgOrderConfirmationGroup,
        i~WorkCenter,
        c~ShiftDefinition AS ShiftDefinition,
        c~PostingDate,
        j~Product,
        c~ManufacturingOrder,
        d~ProductDescription,
        e~Material AS BomComponentCode,
        f~productdescription AS BomComponentName,
        e~GoodsMovementType,
        b~MaterialDocument,
        e~BaseUnit,
        e~QuantityInBaseUnit AS BomComponentRequiredQuantity,
        e~QuantityInEntryUnit AS ActualConsumption

      WHERE a~comp_code IN @lt_comp
        AND a~plant_code IN @lt_plant
        AND i~WorkCenter IN @lt_work
        AND c~PostingDate IN @lt_date
        AND e~Material IN @lt_bomcompcode
        AND c~shiftdefinition IN @lt_shift
        AND c~ManufacturingOrder IN @lt_order
        AND j~Product IN @lt_product
        AND e~GoodsMovementType IN @lt_goodsmovement
        AND c~IsReversal IS INITIAL AND c~IsReversed  IS INITIAL
        AND ( e~GoodsMovementType = '261' OR e~GoodsMovementType = '531' )
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
        c~MfgOrderConfirmation,
        c~MfgOrderConfirmationGroup,
        j~Product,
        d~ProductDescription,
        e~GoodsMovementType,
        e~Material,
        f~productdescription,
        e~GoodsMovementType,
        e~QuantityInBaseUnit,
        e~QuantityInEntryUnit,
        e~BaseUnit,
        b~MaterialDocument
        INTO TABLE @DATA(it).

    IF it IS NOT INITIAL.

      SELECT
        k~ManufacturingOrder,
        k~Material,
        k~GoodsMovementType,
        k~TotalGoodsMvtAmtInCCCrcy
        FROM i_mfgorderdocdgoodsmovement WITH PRIVILEGED ACCESS AS k
        INNER JOIN @it AS b ON  k~ManufacturingOrder  = b~ManufacturingOrder
                            AND k~GoodsMovement       = b~MaterialDocument
                            AND k~Material            = b~BomComponentCode
                            AND k~GoodsMovementType   = b~GoodsMovementType
        INTO TABLE @DATA(it_actualCost).

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

      SELECT FROM i_product AS a
        INNER JOIN i_productplantbasic AS b ON a~Product = b~Product
        INNER JOIN i_productdescription_2 AS f ON a~Product = f~Product
        INNER JOIN i_billofmaterialtp_2 AS c ON a~product = c~Material AND b~plant = c~plant
        INNER JOIN ztable_plant AS g ON b~plant = c~Plant
        INNER JOIN i_billofmaterialitembasic AS d ON c~billofmaterial = d~billofmaterial
        INNER JOIN i_productdescription_2 AS h ON d~BillOfMaterialComponent = h~Product
        INNER JOIN @IT AS I ON G~comp_code = I~comp_code
                        AND b~plant = I~plant_code
                            AND b~Product = I~Product
        FIELDS a~Product,
               f~ProductDescription,
               b~plant,
               c~BOMHeaderQuantityInBaseUnit AS billofmaterialheader,
               d~BillOfMaterialComponent,
               d~BillOfMaterialItemQuantity,
               h~ProductDescription AS ComponentDescription
        INTO CORRESPONDING FIELDS OF TABLE @it_product.

    ENDIF.
*    IF it_product IS NOT INITIAL.
*
*      SELECT DISTINCT b~Product,
*                 b~ProductDescription
*   FROM @it_product AS a
*   INNER JOIN i_productdescription_2 AS b
*           ON b~Product = a~BillOfMaterialComponent
*   INTO TABLE @DATA(it_productiondec).

*      SELECT FROM  i_productdescription_2
*      FIELDS Product, ProductDescription
*      FOR ALL ENTRIES IN @it_product
*      WHERE Product = @it_product-BillOfMaterialComponent
*      INTO TABLE @DATA(it_productiondec).

*    ENDIF.

    DATA: lv_temp_quntity TYPE p LENGTH 16 DECIMALS 8.

    LOOP AT it_product ASSIGNING FIELD-SYMBOL(<wa_PRODUCT>).
      <wa_PRODUCT>-quntity = COND #(
                         WHEN <wa_PRODUCT>-billofmaterialheader IS NOT INITIAL
                         THEN <wa_PRODUCT>-BillOfMaterialItemQuantity / <wa_PRODUCT>-billofmaterialheader
                         ELSE 0 ).
    ENDLOOP.

    DATA: it_confirmationyield TYPE STANDARD TABLE OF ty_confirmation_yield,
          it_final             TYPE STANDARD TABLE OF ty_confirmation_yield.

    IF it_product IS NOT INITIAL.

      SELECT FROM  ztable_plant AS a
      INNER JOIN i_mfgorderconfirmation AS b ON a~plant_code = b~Plant
     LEFT JOIN I_ProductionOrderTP AS d ON b~ManufacturingOrder = d~ProductionOrder
      LEFT JOIN I_MfgOrderConfMatlDocItem AS c ON c~ManufacturingOrder = b~ManufacturingOrder
                                               AND c~MfgOrderConfirmation = b~MfgOrderConfirmation
                                               AND c~MfgOrderConfirmationGroup = b~MfgOrderConfirmationGroup
      FIELDS
      b~Plant,
      b~manufacturingorder AS OrderID,
      b~PostingDate,
      b~shiftdefinition,
      b~ConfirmationYieldQuantity,
      b~confirmationScrapQuantity,
      b~ConfirmationReworkQuantity,
      d~Product AS material,
      c~Material AS billofmaterialcomponent,
      c~BaseUnit

      WHERE a~comp_code IN @lt_comp
       AND a~plant_code IN @lt_plant
       AND c~PostingDate IN @lt_date
       AND c~Material IN @lt_bomcompcode
       AND b~shiftdefinition IN @lt_shift
       AND b~ManufacturingOrder IN @lt_order
       AND d~Product IN @lt_product
       AND c~GoodsMovementType IN @lt_goodsmovement
       AND c~IsReversal IS INITIAL AND c~IsReversed  IS INITIAL
       AND ( c~GoodsMovementType = '261' OR c~GoodsMovementType = '531' )
         INTO CORRESPONDING FIELDS OF TABLE @it_confirmationyield.
    ENDIF.

    it_final = it_confirmationyield.

    LOOP AT it_final ASSIGNING FIELD-SYMBOL(<wa_final>).
      READ TABLE it_product ASSIGNING FIELD-SYMBOL(<wa_PRODUCT1>) WITH KEY product = <wa_final>-material
                                                                           plant = <wa_final>-plant
                                                                           billofmaterialcomponent = <wa_final>-billofmaterialcomponent.
      IF sy-subrc = 0.
        IF <wa_final>-baseunit = 'ST'.
          <wa_final>-bomstdconsumtion = round( val = <wa_PRODUCT1>-quntity * <wa_final>-confirmationyieldquantity
                                                                                                       dec = 0 ).
        ELSE.
          <wa_final>-bomstdconsumtion = <wa_PRODUCT1>-quntity * <wa_final>-confirmationyieldquantity.
        ENDIF.
      ENDIF.
    ENDLOOP.

    UNASSIGN <wa_final>.

    LOOP AT it_final ASSIGNING <wa_final>.
      DATA(lv_first_day_of_month) = |{ <wa_final>-postingdate+0(6) }01|.
      SELECT SINGLE FROM i_productcostestimateitem AS a
        FIELDS a~totalamountincocodecrcy, a~costingdate
        WHERE a~product      = @<wa_final>-billofmaterialcomponent
          AND a~plant       = @<wa_final>-plant
          AND a~costingdate = @lv_first_day_of_month
         AND  a~CostingItemCategory = 'I'
        INTO (@<wa_final>-totalamountincocodecrcy, @<wa_final>-costingdate).
    ENDLOOP.

    LOOP AT it_final ASSIGNING <wa_final>.
      READ TABLE it_product ASSIGNING <wa_PRODUCT1>
        WITH KEY billofmaterialcomponent = <wa_final>-billofmaterialcomponent.
      IF sy-subrc = 0.
        <wa_final>-bomstdamtcurr = <wa_final>-bomstdconsumtion * <wa_final>-totalamountincocodecrcy.
      ENDIF.
    ENDLOOP.

    SORT it_final BY  billofmaterialcomponent orderid postingdate shiftdefinition.
    SORT it_actualcost BY ManufacturingOrder Material GoodsMovementType.

    LOOP AT it ASSIGNING FIELD-SYMBOL(<wa>).
      ls_line-comp_code                 = <wa>-comp_code.
      ls_line-plant_code                = <wa>-plant_code.
      ls_line-work_center               = <wa>-WorkCenter.
      ls_line-PostingDate               = <wa>-PostingDate.
      ls_line-GoodsMovementType         = <wa>-GoodsMovementType.
      ls_line-confirmationyieldquantity = <wa>-ConfirmationYieldQuantity + <wa>-ConfirmationScrapQuantity + <wa>-ConfirmationReworkQuantity.
      ls_line-ProductionOrder           = <wa>-ManufacturingOrder.
      ls_line-Product                   = <wa>-Product.
      ls_line-ProductDesc               = <wa>-ProductDescription.
      ls_line-BomComponentCode          = <wa>-BomComponentCode.
      ls_line-BomComponentName          = <wa>-BomComponentName.
      ls_line-Confirmation_group        = <wa>-MfgOrderConfirmationGroup.
      ls_line-Confirmation_Count        = <wa>-MfgOrderConfirmation.
      ls_line-materialdocument          = <wa>-MaterialDocument.

      READ TABLE it_actualcost ASSIGNING FIELD-SYMBOL(<wa_actualcost>) WITH KEY ManufacturingOrder = <wa>-ManufacturingOrder
                                                                                  Material = <wa>-BomComponentCode
                                                                                  GoodsMovementType = <wa>-GoodsMovementType BINARY SEARCH.

      ls_line-actualcost                = <wa_actualcost>-TotalGoodsMvtAmtInCCCrcy.
      READ TABLE it_final ASSIGNING <wa_final> WITH KEY billofmaterialcomponent   = <wa>-bomcomponentcode
                                                        plant                     = <wa>-plant_code
                                                        orderid                   = <wa>-ManufacturingOrder
                                                        postingdate               = <wa>-PostingDate
                                                        confirmationyieldquantity = <wa>-ConfirmationYieldQuantity
                                                        shiftdefinition           = <wa>-shiftdefinition BINARY SEARCH.
      IF sy-subrc = 0.
        ls_line-BomComponentRequiredQuantity = <wa_final>-bomstdconsumtion.
        ls_line-BomStdcost                = <wa_final>-bomstdamtcurr.
        CASE <wa>-shiftdefinition.
          WHEN '1'.
            ls_line-Shift = 'DAY'.
          WHEN '2'.
            ls_line-Shift = 'NIGHT'.
          WHEN OTHERS.
            ls_line-Shift = ' '.
        ENDCASE.
      ENDIF.

      ls_line-ActualConsumption = <wa>-actualconsumption.

      IF ls_line-GoodsMovementType = '531' AND ( ls_line-BomComponentRequiredQuantity < 0 AND ls_line-ActualConsumption > 0 ).
        ls_line-qtydiff = ls_line-BomComponentRequiredQuantity + ls_line-ActualConsumption.
      ELSE.
        ls_line-qtydiff = ls_line-BomComponentRequiredQuantity - ls_line-ActualConsumption.
      ENDIF.

      ls_line-amtdiff = ls_line-BomStdcost - ls_line-actualcost.
      ls_line-AmtDiffActualRate =  ls_line-qtydiff * ( ls_line-ActualCost / ls_line-ActualConsumption ).
      SHIFT ls_line-Product LEFT DELETING LEADING '0'.
      APPEND ls_line TO lt_result.
      CLEAR: ls_line .
    ENDLOOP.

    DATA : wa_it1 LIKE LINE OF lt_result.
    DATA: lt_result1 LIKE lt_result.
    MOVE-CORRESPONDING lt_result TO lt_result1.

    SORT lt_result BY ProductionOrder bomcomponentcode PostingDate Shift.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_response1>).

      SHIFT <ls_response1>-ProductionOrder LEFT DELETING LEADING '0'.
      SHIFT <ls_response1>-BomComponentCode LEFT DELETING LEADING '0'.
      SHIFT <ls_response1>-Confirmation_group LEFT DELETING LEADING '0'.
      SHIFT <ls_response1>-Confirmation_Count LEFT DELETING LEADING '0'.
      APPEND  <ls_response1> TO lt_response1.
    ENDLOOP.

    DELETE lt_response1 WHERE BomComponentRequiredQuantity = 0 AND ActualConsumption = 0 .

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

        WHEN 'QTYDIFF'.
          SORT lt_response1 BY qtydiff ASCENDING.
          IF ls_sort-descending = abap_true.
            SORT lt_response1 BY qtydiff DESCENDING.
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
