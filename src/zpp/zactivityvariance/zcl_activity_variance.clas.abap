CLASS  zcl_activity_variance  DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
  INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ACTIVITY_VARIANCE IMPLEMENTATION.


   METHOD if_rap_query_provider~select.

     DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
     DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
     DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

     DATA(lt_parameters)  = io_request->get_parameters( ).
     DATA(lt_fileds)  = io_request->get_requested_elements( ).
     DATA(lt_sort)  = io_request->get_sort_elements( ).

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
       ELSEIF ls_filter_cond-name = to_upper( 'ProductionOrder' ).
         DATA(lt_order) = ls_filter_cond-range[].
       ELSEIF ls_filter_cond-name = to_upper( 'PostingDate' ).
         DATA(lt_date) = ls_filter_cond-range[].
       ELSEIF ls_filter_cond-name = to_upper( 'work_center' ).
         DATA(lt_work) = ls_filter_cond-range[].
       ELSEIF ls_filter_cond-name = to_upper( 'Shift' ).
         DATA(lt_shift) = ls_filter_cond-range[].
       ELSEIF ls_filter_cond-name = to_upper( 'Product' ).
         DATA(lt_pro) = ls_filter_cond-range[].
       ELSEIF ls_filter_cond-name = to_upper( 'Activity' ).
         DATA(lt_act) = ls_filter_cond-range[].
       ENDIF.
     ENDLOOP.

     DATA: lt_response    TYPE TABLE OF zdd_activity_variance,
           ls_line        LIKE LINE OF lt_response,
           lt_responseout LIKE lt_response,
           ls_responseout LIKE LINE OF lt_responseout,
           lt_response1 like lt_response.

     SELECT
     FROM ztable_plant AS a
        INNER JOIN i_productionordconfirmationtp AS b
            ON a~plant_code = b~Plant
        INNER JOIN I_ProductDescription_2 AS d
            ON b~Material = d~Product AND d~Language = 'E'
        INNER JOIN i_mfgorderconfirmation AS c
            ON b~OrderID = c~ManufacturingOrder
             AND b~ConfirmationCount = c~MfgOrderConfirmation
            FIELDS
         b~OrderID,
         c~PostingDate,
         b~Material,
         a~comp_code,
         a~plant_code,
         b~WorkCenter,
         c~ShiftDefinition,
         d~ProductDescription,
         c~OpWorkQuantityUnit1,
         c~OpWorkQuantityUnit2,
         c~OpWorkQuantityUnit3,
         c~OpWorkQuantityUnit4,
         c~OpWorkQuantityUnit5,
         c~OpWorkQuantityUnit6,
         SUM( c~ConfYieldQtyInProductionUnit ) AS Confirm,
         SUM( c~OpConfirmedWorkQuantity1 ) AS Labour,
         SUM( c~OpConfirmedWorkQuantity2 ) AS Power,
         SUM( c~OpConfirmedWorkQuantity3 ) AS Fuel,
         SUM( c~OpConfirmedWorkQuantity4 ) AS Mach,
         SUM( c~OpConfirmedWorkQuantity5 ) AS Repair,
         SUM( c~OpConfirmedWorkQuantity6 ) AS Misc
        WHERE a~comp_code       IN @lt_comp
        AND a~plant_code      IN @lt_plant
        AND b~OrderID         IN @lt_order
        AND c~PostingDate     IN @lt_date
        AND b~WorkCenter      IN @lt_work
        AND b~ShiftDefinition IN @lt_shift
        AND b~Material        IN @lt_pro
        AND c~IsReversal is initial and c~IsReversed is INITIAL and b~IsReversed is initial
        GROUP BY
             b~OrderID,
             c~PostingDate,
             b~Material,
             a~comp_code,
             a~plant_code,
             b~WorkCenter,
             c~ShiftDefinition,
             d~ProductDescription,
             c~OpWorkQuantityUnit1,
             c~OpWorkQuantityUnit2,
             c~OpWorkQuantityUnit3,
             c~OpWorkQuantityUnit4,
             c~OpWorkQuantityUnit5,
             c~OpWorkQuantityUnit6
             INTO TABLE @DATA(it).



     LOOP AT it INTO DATA(wa).

        SELECT SINGLE
         a~OperationReferenceQuantity,
         b~OpPlannedTotalQuantity,
         WorkCenterStandardWorkQty1,WorkCenterStandardWorkQty2,WorkCenterStandardWorkQty3,WorkCenterStandardWorkQty4,
         WorkCenterStandardWorkQty5,WorkCenterStandardWorkQty6
          FROM I_ProductionOrderOperationTP as a
          left join I_MFGORDERCONFIRMATION as b on a~ProductionOrder = b~ManufacturingOrder and a~OrderOperationInternalID = b~OrderOperationInternalID
          WHERE ProductionOrder = @wa-OrderID
           INTO @DATA(ls_oper).

       IF wa-Labour IS NOT INITIAL.
         ls_line-comp_code        = wa-comp_code.
         ls_line-plant_code       = wa-plant_code.
         ls_line-work_center      = wa-WorkCenter.
         ls_line-PostingDate      = wa-PostingDate.
         ls_line-Shift            = wa-ShiftDefinition.
         ls_line-ProductionOrder  = wa-OrderID.
         ls_line-Product          = wa-Material.
         ls_line-ProductDesc      = wa-ProductDescription.
         ls_line-Activity = 'LABOUR'.
         ls_line-YieldQuantity = wa-Confirm.
         ls_line-ActualConsumption = wa-Labour.
         ls_line-ActConsUnit = wa-OpWorkQuantityUnit1.
         ls_line-StandardConsumption = ( ls_oper-WorkCenterStandardWorkQty1 / ls_oper-OperationReferenceQuantity ) * wa-Confirm.
         ls_line-Qty_diff = ls_line-StandardConsumption - ls_line-ActualConsumption.
         ls_line-standardunit = wa-OpWorkQuantityUnit1.
         ls_line-diff_unit = wa-OpWorkQuantityUnit1.
         APPEND ls_line TO lt_response.
         CLEAR ls_line-Activity.
         CLEAR ls_line-ActualConsumption.
         CLEAR ls_line-ActConsUnit.
       ENDIF.

       IF wa-Power IS NOT INITIAL.
         ls_line-comp_code        = wa-comp_code.
         ls_line-plant_code       = wa-plant_code.
         ls_line-work_center      = wa-WorkCenter.
         ls_line-PostingDate      = wa-PostingDate.
         ls_line-Shift            = wa-ShiftDefinition.
         ls_line-ProductionOrder  = wa-OrderID.
         ls_line-Product          = wa-Material.
         ls_line-ProductDesc      = wa-ProductDescription.
         ls_line-Activity = 'POWER'.
          ls_line-YieldQuantity = wa-Confirm.
         ls_line-ActualConsumption = wa-Power.
         ls_line-ActConsUnit = wa-OpWorkQuantityUnit2.
         ls_line-StandardConsumption = ( ls_oper-WorkCenterStandardWorkQty2 / ls_oper-OperationReferenceQuantity ) * wa-Confirm .
         ls_line-Qty_diff = ls_line-StandardConsumption - ls_line-ActualConsumption.
          ls_line-standardunit = wa-OpWorkQuantityUnit2.
         ls_line-diff_unit = wa-OpWorkQuantityUnit2.
         APPEND ls_line TO lt_response.
         CLEAR ls_line-Activity.
         CLEAR ls_line-ActualConsumption.
         CLEAR ls_line-ActConsUnit.
       ENDIF.

       IF wa-Fuel IS NOT INITIAL.
         ls_line-comp_code        = wa-comp_code.
         ls_line-plant_code       = wa-plant_code.
         ls_line-work_center      = wa-WorkCenter.
         ls_line-PostingDate      = wa-PostingDate.
         ls_line-Shift            = wa-ShiftDefinition.
         ls_line-ProductionOrder  = wa-OrderID.
         ls_line-Product          = wa-Material.
         ls_line-ProductDesc      = wa-ProductDescription.
         ls_line-Activity = 'FUEL'.
          ls_line-YieldQuantity = wa-Confirm.
         ls_line-ActualConsumption = wa-Fuel.
         ls_line-ActConsUnit = wa-OpWorkQuantityUnit3.
         ls_line-StandardConsumption = ( ls_oper-WorkCenterStandardWorkQty3 / ls_oper-OperationReferenceQuantity ) * wa-Confirm .
         ls_line-Qty_diff = ls_line-StandardConsumption - ls_line-ActualConsumption.
          ls_line-standardunit = wa-OpWorkQuantityUnit3.
         ls_line-diff_unit = wa-OpWorkQuantityUnit3.
         APPEND ls_line TO lt_response.
         CLEAR ls_line-Activity.
         CLEAR ls_line-ActualConsumption.
         CLEAR ls_line-ActConsUnit.
       ENDIF.

       IF wa-Mach IS NOT INITIAL.
         ls_line-comp_code        = wa-comp_code.
         ls_line-plant_code       = wa-plant_code.
         ls_line-work_center      = wa-WorkCenter.
         ls_line-PostingDate      = wa-PostingDate.
         ls_line-Shift            = wa-ShiftDefinition.
         ls_line-ProductionOrder  = wa-OrderID.
         ls_line-Product          = wa-Material.
         ls_line-ProductDesc      = wa-ProductDescription.
         ls_line-Activity = 'MACHINE'.
          ls_line-YieldQuantity = wa-Confirm.
         ls_line-ActualConsumption = wa-Mach.
         ls_line-ActConsUnit = wa-OpWorkQuantityUnit4.
         ls_line-StandardConsumption = ( ls_oper-WorkCenterStandardWorkQty4 / ls_oper-OperationReferenceQuantity ) * wa-Confirm .
         ls_line-Qty_diff = ls_line-StandardConsumption - ls_line-ActualConsumption.
          ls_line-standardunit = wa-OpWorkQuantityUnit4.
         ls_line-diff_unit = wa-OpWorkQuantityUnit4.
         APPEND ls_line TO lt_response.
         CLEAR ls_line-Activity.
         CLEAR ls_line-ActualConsumption.
         CLEAR ls_line-ActConsUnit.
       ENDIF.

       IF wa-Repair IS NOT INITIAL.
         ls_line-comp_code        = wa-comp_code.
         ls_line-plant_code       = wa-plant_code.
         ls_line-work_center      = wa-WorkCenter.
         ls_line-PostingDate      = wa-PostingDate.
         ls_line-Shift            = wa-ShiftDefinition.
         ls_line-ProductionOrder  = wa-OrderID.
         ls_line-Product          = wa-Material.
         ls_line-ProductDesc      = wa-ProductDescription.
         ls_line-Activity = 'REPAIR'.
          ls_line-YieldQuantity = wa-Confirm.
         ls_line-ActualConsumption = wa-Repair.
         ls_line-ActConsUnit = wa-OpWorkQuantityUnit5.
         ls_line-StandardConsumption = ( ls_oper-WorkCenterStandardWorkQty5 / ls_oper-OperationReferenceQuantity ) * wa-Confirm .
         ls_line-Qty_diff = ls_line-StandardConsumption - ls_line-ActualConsumption.
          ls_line-standardunit = wa-OpWorkQuantityUnit5.
         ls_line-diff_unit = wa-OpWorkQuantityUnit5.
         APPEND ls_line TO lt_response.
         CLEAR ls_line-Activity.
         CLEAR ls_line-ActualConsumption.
         CLEAR ls_line-ActConsUnit.
       ENDIF.

       IF wa-Misc IS NOT INITIAL.
         ls_line-comp_code        = wa-comp_code.
         ls_line-plant_code       = wa-plant_code.
         ls_line-work_center      = wa-WorkCenter.
         ls_line-PostingDate      = wa-PostingDate.
         ls_line-Shift            = wa-ShiftDefinition.
         ls_line-ProductionOrder  = wa-OrderID.
         ls_line-Product          = wa-Material.
         ls_line-ProductDesc      = wa-ProductDescription.
         ls_line-Activity = 'MISC'.
          ls_line-YieldQuantity = wa-Confirm.
         ls_line-ActualConsumption = wa-Misc.
         ls_line-ActConsUnit = wa-OpWorkQuantityUnit6.
         ls_line-StandardConsumption = ( ls_oper-WorkCenterStandardWorkQty6 / ls_oper-OperationReferenceQuantity ) * wa-Confirm .
         ls_line-Qty_diff = ls_line-StandardConsumption - ls_line-ActualConsumption.
         ls_line-standardunit = wa-OpWorkQuantityUnit6.
         ls_line-diff_unit = wa-OpWorkQuantityUnit6.
         APPEND ls_line TO lt_response.
         CLEAR ls_line-Activity.
         CLEAR ls_line-ActualConsumption.
         CLEAR ls_line-ActConsUnit.
       ENDIF.
     ENDLOOP.

    Select from ztable_plant as a
     inner JOIN i_productionordconfirmationtp AS b on a~plant_code = b~Plant
    inner join I_PRODUCTIONORDEROPERATIONTP as c on b~WorkCenter = c~WorkCenter and b~OrderID = c~ProductionOrder
    inner join I_WorkCenterCostCenter as d on d~WorkCenterInternalID = c~WorkCenterInternalID
    inner join I_PLANCOSTRATETP as f on d~CostCenter = f~CostCenter and d~CostCtrActivityType = f~ActivityType
    fields f~CostRateFixedAmount,  d~WorkCenterInternalID,b~OrderID,c~WorkCenter,d~CostCtrActivityType,b~PostingDate,f~ActivityType,
    VALIDITYSTARTFISCALYEAR,VALIDITYSTARTFISCALPERIOD,VALIDITYENDFISCALYEAR,VALIDITYENDFISCALPERIOD,f~CostRateScaleFactor
     WHERE a~comp_code       IN @lt_comp
        AND a~plant_code      IN @lt_plant
        AND b~OrderID         IN @lt_order
        AND b~PostingDate     IN @lt_date
        AND b~WorkCenter      IN @lt_work
        AND b~ShiftDefinition IN @lt_shift
        AND b~Material        IN @lt_pro
*        group by VALIDITYSTARTFISCALYEAR,
*        VALIDITYSTARTFISCALPERIOD
       into table @data(costing).

       sort costing by postingdate CostCtrActivityType.
       delete ADJACENT DUPLICATES FROM costing comparing all fields.

       data : lv_month type string,
              lv_year type string,
              lv_period type string.
       data : costing2 like costing,
       wa_posting2 like line of costing.

       loop at costing into data(wa_posting).

       lv_year = wa_posting-PostingDate+0(4).
       lv_month = wa_posting-PostingDate+4(2).
        IF lv_month < '04' .
           lv_year = lv_year - 1.
        ENDIF.
       lv_period = ( lv_month + 8 ) MOD 12 + 1.
       lv_period = |{ lv_period WIDTH = 4 ALIGN = RIGHT PAD = '0'  }|.

       if lv_period = wa_posting-ValidityStartFiscalPeriod and lv_year = wa_posting-ValidityStartFiscalYear.
         wa_posting2-CostRateFixedAmount =  wa_posting-CostRateFixedAmount.
         wa_posting2-ActivityType = wa_posting-ActivityType.
         wa_posting2-ValidityStartFiscalPeriod =  wa_posting-ValidityStartFiscalPeriod.
         wa_posting2-ValidityStartFiscalYear = wa_posting-ValidityStartFiscalYear.
         wa_posting2-PostingDate = wa_posting-PostingDate.
         wa_posting2-CostRateScaleFactor = wa_posting-CostRateScaleFactor.
         append wa_posting2 to costing2.
       endif.

       ENDLOOP.
*       sort costing2 by ActivityType CostRateFixedAmount ValidityStartFiscalPeriod ValidityStartFiscalYear.
*       delete ADJACENT DUPLICATES FROM costing2 COMPARING ActivityType ValidityStartFiscalPeriod ValidityStartFiscalYear .


    loop at lt_response ASSIGNING FIELD-SYMBOL(<ls_response1>).
    if <ls_response1>-Activity in lt_act.
    append <ls_response1> to lt_response1.
    endif.
    endloop.

    Loop at lt_response1 ASSIGNING FIELD-SYMBOL(<wa_modify>).

        SELECT SINGLE UnitOfMeasureTechnicalName,UnitOfMeasure
        FROM I_UnitOfMeasureText
        WHERE UnitOfMeasure = @<wa_modify>-ActConsUnit
        AND Language = 'E'
        INTO @DATA(lv_uom).

      <wa_modify>-ActConsUnit = to_upper( lv_uom-UnitOfMeasureTechnicalName ).
      <wa_modify>-standardunit = to_upper( lv_uom-UnitOfMeasureTechnicalName ).
      <wa_modify>-diff_unit = to_upper( lv_uom-UnitOfMeasureTechnicalName ).

      if <wa_modify>-Shift eq '1'.
      <wa_modify>-Shift = 'DAY'.
      elseif <wa_modify>-Shift eq '2'.
      <wa_modify>-Shift = 'NIGHT'.
      endif.
     loop at costing2 ASSIGNING FIELD-SYMBOL(<fs_group>) WHERE PostingDate = <wa_modify>-PostingDate.

     if <fs_group>-ActivityType eq 'POWER' and <wa_modify>-Activity = 'POWER'.
         <wa_modify>-scost = <wa_modify>-StandardConsumption * ( <fs_group>-CostRateFixedAmount / <fs_group>-CostRateScaleFactor ).
         <wa_modify>-acost = <wa_modify>-ActualConsumption * ( <fs_group>-CostRateFixedAmount / <fs_group>-CostRateScaleFactor ).
         <wa_modify>-amt_diff =  <wa_modify>-scost  - <wa_modify>-acost .
     endif.
     if <fs_group>-ActivityType eq 'FUEL' and <wa_modify>-Activity = 'FUEL' .
          <wa_modify>-scost = <wa_modify>-StandardConsumption * ( <fs_group>-CostRateFixedAmount / <fs_group>-CostRateScaleFactor ).
         <wa_modify>-acost = <wa_modify>-ActualConsumption * ( <fs_group>-CostRateFixedAmount / <fs_group>-CostRateScaleFactor ).
         <wa_modify>-amt_diff =  <wa_modify>-scost  - <wa_modify>-acost .
     endif.
      if <fs_group>-ActivityType eq 'LABOUR' and <wa_modify>-Activity = 'LABOUR' .
         <wa_modify>-scost = <wa_modify>-StandardConsumption * ( <fs_group>-CostRateFixedAmount / <fs_group>-CostRateScaleFactor ).
         <wa_modify>-acost = <wa_modify>-ActualConsumption * ( <fs_group>-CostRateFixedAmount / <fs_group>-CostRateScaleFactor ).
         <wa_modify>-amt_diff =  <wa_modify>-scost  - <wa_modify>-acost .
     endif.
      if <fs_group>-ActivityType eq 'REPAIR' and <wa_modify>-Activity = 'REPAIR' .
        <wa_modify>-scost = <wa_modify>-StandardConsumption * ( <fs_group>-CostRateFixedAmount / <fs_group>-CostRateScaleFactor ).
         <wa_modify>-acost = <wa_modify>-ActualConsumption * ( <fs_group>-CostRateFixedAmount / <fs_group>-CostRateScaleFactor ).
         <wa_modify>-amt_diff =  <wa_modify>-scost  - <wa_modify>-acost .
     endif.
      if <fs_group>-ActivityType eq 'MISC' and <wa_modify>-Activity = 'MISC' .
         <wa_modify>-scost = <wa_modify>-StandardConsumption * ( <fs_group>-CostRateFixedAmount / <fs_group>-CostRateScaleFactor ).
         <wa_modify>-acost = <wa_modify>-ActualConsumption * ( <fs_group>-CostRateFixedAmount / <fs_group>-CostRateScaleFactor ).
         <wa_modify>-amt_diff =  <wa_modify>-scost  - <wa_modify>-acost .
     endif.
     if <fs_group>-ActivityType eq 'MACH' and <wa_modify>-Activity = 'MACHINE' .
         <wa_modify>-scost = <wa_modify>-StandardConsumption * ( <fs_group>-CostRateFixedAmount / <fs_group>-CostRateScaleFactor ).
         <wa_modify>-acost = <wa_modify>-ActualConsumption * ( <fs_group>-CostRateFixedAmount / <fs_group>-CostRateScaleFactor ).
         <wa_modify>-amt_diff =  <wa_modify>-scost  - <wa_modify>-acost .
     endif.
     Endloop.

    SHIFT <wa_modify>-Product LEFT DELETING LEADING '0'.
    shift <wa_modify>-ProductionOrder LEFT DELETING LEADING '0'.

    MODIFY lt_response1 from <wa_modify>.
    ENDLOOP.

     lv_max_rows = lv_skip + lv_top.
     IF lv_skip > 0.
       lv_skip = lv_skip + 1.
     ENDIF.

     CLEAR lt_responseout.
     LOOP AT lt_response1 ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
       ls_responseout = <lfs_out_line_item>.
       APPEND ls_responseout TO lt_responseout.
     ENDLOOP.

     io_response->set_total_number_of_records( lines( lt_response1 ) ).
     io_response->set_data( lt_responseout ).


   ENDMETHOD.
ENDCLASS.
