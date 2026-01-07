CLASS zcl_breadmatupd DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .

    CLASS-METHODS runJob
      IMPORTING p_json  TYPE string.

       CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BREADMATUPD IMPLEMENTATION.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD runJob.

    SELECT FROM zr_repmatbread
        FIELDS Plant, Material, Rangedate, Todate, Shift, Quantity, Um, ActualQty,
                 Storagelocation, MatDesc, Batch
        WHERE Idfier = @p_json
        INTO TABLE @DATA(tt_json_structure).

    TRY.
        DATA message TYPE string.

        LOOP AT tt_json_structure INTO DATA(wa).
          DATA: shift    TYPE c LENGTH 1,
                material TYPE c LENGTH 18.

          material = |{ wa-material ALPHA = IN }|.
          wa-material = material.

          IF wa-shift = 'DAY'.
            shift = '1'.
          ELSEIF wa-shift = 'NIGHT'.
            shift = '2'.
          ENDIF.

          SELECT FROM I_ProductionOrder AS a
            INNER JOIN I_mfgorderconfirmation AS c ON a~ProductionOrder = c~ManufacturingOrder
            LEFT JOIN i_mfgorderconfmatldocitem AS e ON e~MfgOrderConfirmation = c~MfgOrderConfirmation AND e~MfgOrderConfirmationGroup = c~MfgOrderConfirmationGroup

            LEFT JOIN I_MaterialDocumentItem_2 AS d ON e~MaterialDocument = d~MaterialDocument AND e~MaterialDocumentYear = d~MaterialDocumentYear
                                                        AND e~materialdocumentitem = d~materialdocumentitem
            LEFT JOIN I_ProductText AS b ON d~Material = b~Product AND b~Language = 'E'
           FIELDS a~ProductionOrder, d~MaterialDocument, d~MaterialDocumentYear, c~MfgOrderConfirmation, c~MfgOrderConfirmationGroup,
                     d~Material, d~Plant, d~QuantityInEntryUnit, d~PostingDate, d~GoodsMovementType,
                 d~MaterialBaseUnit,b~ProductName, c~ShiftDefinition, a~CreationDate,a~CompanyCode, d~Batch,
                 c~ConfirmationScrapQuantity, c~ConfirmationReworkQuantity,c~ConfirmationYieldQuantity,c~WorkCenterInternalID, c~ShiftGrouping
           WHERE d~GoodsMovementType IN ( '261', '262' )
           AND d~Plant = @wa-plant AND d~Material = @wa-material
           AND a~CreationDate >= @wa-rangedate AND a~CreationDate <= @wa-todate
           AND ( @shift IS INITIAL OR c~ShiftDefinition = @shift )
           AND c~IsReversed = ''
           AND a~ProductionOrderType NOT IN ( 'Z119' )
           AND d~ReversedMaterialDocument IS INITIAL
           AND c~ConfirmationYieldQuantity IS NOT INITIAL
           INTO TABLE @DATA(lt_final) PRIVILEGED ACCESS.


          DATA: wa_matvar TYPE zmatvarbread.

          LOOP AT lt_final ASSIGNING FIELD-SYMBOL(<wa_final>).
            wa_matvar-plant_code                = <wa_final>-Plant.
            wa_matvar-comp_code                 = <wa_final>-CompanyCode.
            wa_matvar-productionorder           = <wa_final>-ProductionOrder.
            wa_matvar-postingdate               = <wa_final>-PostingDate.
            wa_matvar-creationdate              = <wa_final>-CreationDate.
            wa_matvar-product                   = <wa_final>-Material.
            wa_matvar-confirmation_count        = <wa_final>-MfgOrderConfirmation.
            wa_matvar-confirmation_group        = <wa_final>-MfgOrderConfirmationGroup.
*            wa_matvar-batch                     = <wa_final>-Batch.

            SELECT SINGLE FROM I_UnitOfMeasure
              FIELDS UnitOfMeasure_E
              WHERE UnitOfMeasure = @<wa_final>-MaterialBaseUnit
              INTO @DATA(lv_um).

            wa_matvar-um                        = lv_um.
*            wa_matvar-storagelocation           = <wa_final>-StorageLocation.
            wa_matvar-productdesc               = <wa_final>-ProductName.
            wa_matvar-batch                     = <wa_final>-Batch.
            wa_matvar-materialdocument          = <wa_final>-MaterialDocument.
            wa_matvar-shiftgroup                = <wa_final>-ShiftGrouping.
            wa_matvar-goodsmovementtype         = <wa_final>-GoodsMovementType.
            wa_matvar-actualconsumption         = <wa_final>-QuantityInEntryUnit.
            wa_matvar-confirmationyieldquantity = <wa_final>-ConfirmationReworkQuantity +  <wa_final>-ConfirmationScrapQuantity
                                                  +  <wa_final>-ConfirmationYieldQuantity.

            SELECT SINGLE FROM I_workcenter AS a
                FIELDS a~WorkCenter
                WHERE a~WorkCenterInternalID = @<wa_final>-WorkCenterInternalID
                INTO @DATA(lv_workcenter).

            wa_matvar-work_center = lv_workcenter.

            SELECT SINGLE FROM i_mfgorderdocdgoodsmovement
                FIELDS TotalGoodsMvtAmtInCCCrcy
                WHERE ManufacturingOrder = @<wa_final>-ProductionOrder
                      AND GoodsMovement = @<wa_final>-MaterialDocument
                      AND QuantityInEntryUnit = @<wa_final>-QuantityInEntryUnit
                      AND GoodsMovementType = @<wa_final>-GoodsMovementType
                      AND Material = @<wa_final>-Material
                INTO @DATA(lv_qty).

            wa_matvar-actualcost                = lv_qty.

            SELECT SINGLE FROM i_productionorderopcomponenttp AS a
            INNER JOIN I_ProductDescription_2 AS b ON a~Material = b~Product AND b~Language = 'E'
            FIELDS a~Material,b~ProductDescription,a~RequiredQuantity
            WHERE a~ProductionOrder = @<wa_final>-ProductionOrder AND
                  a~Material = @<wa_final>-Material
            INTO @DATA(wa_matvarbom).

            wa_matvar-bomcomponentcode                = wa_matvarbom-Material.
            wa_matvar-bomcomponentname                = wa_matvarbom-ProductDescription.
            wa_matvar-bomcomponentrequiredquantity    = wa_matvarbom-RequiredQuantity.

            SELECT SINGLE FROM I_ProductValuationBasic WITH PRIVILEGED ACCESS
               FIELDS Currency
               WHERE Product = @<wa_final>-Material
               AND ValuationArea = @<wa_final>-Plant
               INTO @DATA(lv_currency).

            wa_matvar-bomamtcurr = lv_currency.

            IF <wa_final>-ShiftDefinition IS INITIAL.
              wa_matvar-Shift = ''.
            ELSEIF <wa_final>-ShiftDefinition EQ '1'.
              wa_matvar-Shift = 'DAY'.
            ELSEIF <wa_final>-ShiftDefinition EQ '2'.
              wa_matvar-Shift = 'NIGHT' .
            ENDIF.

            IF wa_matvar-GoodsMovementType = '531' AND ( wa_matvar-BomComponentRequiredQuantity < 0 AND wa_matvar-ActualConsumption > 0 ).
              wa_matvar-qtydiff = wa_matvar-BomComponentRequiredQuantity + wa_matvar-ActualConsumption.
            ELSE.
              wa_matvar-qtydiff = wa_matvar-BomComponentRequiredQuantity - wa_matvar-ActualConsumption.
            ENDIF.
*        wa_matvar-BomComponentAmt = 0.
*        wa_matvar-AmtDiff = wa_matvar-BomComponentAmt - wa_matvar-ActualCost.
            wa_matvar-AmtDiffActualRate =  wa_matvar-qtydiff * ( wa_matvar-ActualCost / wa_matvar-ActualConsumption ).

            SHIFT wa_matvar-Product LEFT DELETING LEADING '0'.

            MODIFY ENTITIES OF zr_matvarbread
            ENTITY ZrMatvarbread
            CREATE FIELDS (
              PlantCode
              CompCode
              ProductionOrder
              Materialdocument
              PostingDate
              CreationDate
              Product
              Um
              ProductDesc
              GoodsMovementType
              ConfirmationYieldQuantity
              WorkCenter
              ActualConsumption
              ActualCost
              BomComponentCode
              BomComponentName
              BomComponentRequiredQuantity
              BomAmtCurr
              Shift
              Shiftgroup
              Batch
              QtyDiff
              AmtDiffActualRate
              ConfirmationCount
              ConfirmationGroup
            )
            WITH VALUE #( (
                %cid = getCID( )
                PlantCode = wa_matvar-plant_code
                CompCode = wa_matvar-comp_code
                ProductionOrder = wa_matvar-productionorder
                Materialdocument = wa_matvar-materialdocument
                PostingDate = wa_matvar-postingdate
                CreationDate = wa_matvar-creationdate
                Product = wa_matvar-product
                Um = wa_matvar-um
                ProductDesc = wa_matvar-productdesc
                GoodsMovementType = wa_matvar-goodsmovementtype
                ConfirmationYieldQuantity = wa_matvar-confirmationyieldquantity
                WorkCenter = wa_matvar-work_center
                ActualConsumption = wa_matvar-actualconsumption
                Actualcost = wa_matvar-actualcost
                BomComponentCode = wa_matvar-bomcomponentcode
                BomComponentName = wa_matvar-bomcomponentname
                BomComponentRequiredQuantity = wa_matvar-bomcomponentrequiredquantity
                BomAmtCurr = wa_matvar-bomamtcurr
                Shift = wa_matvar-shift
                Shiftgroup = wa_matvar-shiftgroup
                Batch = wa_matvar-batch
                QtyDiff = wa_matvar-qtydiff
                AmtDiffActualRate = wa_matvar-amtdiffactualrate
                ConfirmationCount = wa_matvar-confirmation_count
                ConfirmationGroup = wa_matvar-confirmation_group
             ) )
                REPORTED DATA(ls_po_reported)
                  FAILED   DATA(ls_po_failed)
                  MAPPED   DATA(ls_po_mapped).

            COMMIT ENTITIES BEGIN
               RESPONSE OF zr_matvarbread
               FAILED DATA(ls_save_failed)
               REPORTED DATA(ls_save_reported).

            IF ls_po_failed IS NOT INITIAL OR ls_save_failed IS NOT INITIAL.
              message = 'Failed to save data'.
            ELSE.
              message = 'Data saved successfully'.
            ENDIF.

            COMMIT ENTITIES END.
          ENDLOOP.


          MODIFY ENTITIES OF zr_repmatbread
            ENTITY zrrepmatbread
            UPDATE FIELDS ( Loadcompleted )
           WITH VALUE #( (
                Plant = wa-plant
                Material = |{ wa-material ALPHA = OUT }|
                Rangedate = wa-rangedate
                Todate = wa-todate
                Shift = wa-shift
                Loadcompleted  = abap_true
          ) )
          REPORTED DATA(ls_po_reported1)
          FAILED   DATA(ls_po_failed1)
          MAPPED   DATA(ls_po_mapped1).

          COMMIT ENTITIES BEGIN
             RESPONSE OF zr_repmatbread
             FAILED DATA(ls_save_failed1)
             REPORTED DATA(ls_save_reported1).

          IF ls_po_failed1 IS NOT INITIAL OR ls_save_failed1 IS NOT INITIAL.
            message = 'Failed to save data'.
          ELSE.
            message = 'Data saved successfully'.
          ENDIF.

          COMMIT ENTITIES END.
        ENDLOOP.

      CATCH cx_root INTO DATA(lx_root).
        message = |General Error: { lx_root->get_text( ) }|.
    ENDTRY.


  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    runJob( '42010A0B-8142-1FD0-B1A3-6E49E429716D' ).
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_IDFIER'  kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 40 param_text = 'Identifier'   lowercase_ind = abap_true changeable_ind = abap_true )
    ).


    et_parameter_val = VALUE #(
         ( selname = 'P_IDFIER' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = '' )
       ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    TYPES ty_id TYPE c LENGTH 10.

    DATA: p_json TYPE string.

    LOOP AT it_parameters INTO DATA(wa_parameter).
      CASE wa_parameter-selname.
        WHEN 'P_IDFIER'.
          p_json = wa_parameter-low.
      ENDCASE.
    ENDLOOP.

    runJob( p_json = p_json  ).
  ENDMETHOD.
ENDCLASS.
