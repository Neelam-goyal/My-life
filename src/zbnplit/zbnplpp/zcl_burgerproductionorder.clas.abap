CLASS zcl_burgerproductionorder DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.
    CLASS-METHODS BurgerProductionData FOR TABLE FUNCTION ZTBLF_BurgerProductionOrder.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BURGERPRODUCTIONORDER IMPLEMENTATION.


  METHOD burgerproductiondata
         BY DATABASE FUNCTION
         FOR HDB
         LANGUAGE SQLSCRIPT
         OPTIONS READ-ONLY
         USING ZR_BurgerProductionOrder.

    Cte_ZR_BurgerProductionOrder =
        Select ManufacturingOrder,ManufacturingOrderItem,ManufacturingOrderCategory,ManufacturingOrderType,
            OrderCreationDate,ProductGroup,Product,MfgOrderInternalID,ProductionPlant,
            Reservation,bom,CompanyCode,ControllingArea,ProfitCenter,CostingSheet,StorageLocation,
            MfgOrderActualStartDate,MfgOrderItemActualDeliveryDate,PostingDate,GoodsMovement,GoodsMovementYear,
            MfgOrderConfirmationGroup, MfgOrderConfirmation, WorkCenterText, ShiftDescription,BOMHeaderBaseUnit, BOMHeaderQuantityInBaseUnit,EntryUnit,
            SFGProducedQty,RMConsumedQty,WstgProducedQty
        From
         ZR_BurgerProductionOrder
        Where CompanyCode = :pCompany
        and ProductionPlant = :pPrdnPlant
        and OrderCreationDate >= :pFromDate
        and OrderCreationDate <= :pToDate;

    SFG_Produced =
          SELECT ManufacturingOrder,ManufacturingOrderItem,ManufacturingOrderCategory,ManufacturingOrderType,
            OrderCreationDate,ProductGroup,Product,MfgOrderInternalID,ProductionPlant,
            Reservation,bom,CompanyCode,ControllingArea,ProfitCenter,CostingSheet,StorageLocation,
            MfgOrderActualStartDate,MfgOrderItemActualDeliveryDate,PostingDate,GoodsMovement,GoodsMovementYear,
            MfgOrderConfirmationGroup, MfgOrderConfirmation,WorkCenterText, ShiftDescription,BOMHeaderBaseUnit, BOMHeaderQuantityInBaseUnit,
            EntryUnit,SFGProducedQty
          from :Cte_ZR_BurgerProductionOrder as rawdata
          where SFGProducedQty <> '0';

    RM_Cons = SELECT
               manufacturingorder,
               manufacturingorderitem,
               companycode,
               goodsmovement,
               goodsmovementyear,
               EntryUnit,
               Sum(RMConsumedQty)  as RMConsumedQty
          from :Cte_ZR_BurgerProductionOrder as rawdata
          where RMConsumedQty <> '0'
          Group By manufacturingorder,
               manufacturingorderitem,
               companycode,
               goodsmovement,
               goodsmovementyear,
               EntryUnit;

    Wstg_Cons = SELECT
               manufacturingorder,
               manufacturingorderitem,
               companycode,
               goodsmovement,
               goodsmovementyear,
               EntryUnit,
               Sum(WstgProducedQty)  as WstgProducedQty
          from :Cte_ZR_BurgerProductionOrder as rawdata
          where WstgProducedQty <> '0'
          Group By manufacturingorder,
               manufacturingorderitem,
               companycode,
               goodsmovement,
               goodsmovementyear,
               EntryUnit;

RETURN
        Select
        100 as CLIENT,
        sfg.ManufacturingOrder,
        sfg.ManufacturingOrderItem,
        sfg.ManufacturingOrderCategory,
        sfg.ManufacturingOrderType,
        sfg.OrderCreationDate,

        sfg.ProductGroup,
        sfg.Product,
        sfg.ProductionPlant,

        sfg.bom  ,
        sfg.CompanyCode,
        sfg.ControllingArea,
        sfg.ProfitCenter,
        sfg.CostingSheet,
        sfg.StorageLocation,
        sfg.MfgOrderActualStartDate,
        sfg.MfgOrderItemActualDeliveryDate,
        sfg.PostingDate,
        sfg.GoodsMovement,
        sfg.GoodsMovementYear,
        sfg.MfgOrderConfirmationGroup,
        sfg.MfgOrderConfirmation,
        sfg.WorkCenterText,
        sfg.ShiftDescription as ShiftDefinition,
        sfg.BOMHeaderBaseUnit as SPBUnit,
        sfg.BOMHeaderQuantityInBaseUnit as SFGStdSPB,
        sfg.EntryUnit as SFGUnit,
        sfg.SFGProducedQty,
        rm.EntryUnit as RMUnit,
        rm.RMConsumedQty,
        cast(case when rm.RMConsumedQty is null then 0 else rm.RmConsumedQty end / 90.000 as DEC (13,3)) as BagsConsumedQty,
        wstg.EntryUnit as WstgUnit,
        wstg.WstgProducedQty

        From :SFG_Produced as sfg
        Left outer join :RM_Cons as rm
            on sfg.manufacturingorder = rm.manufacturingorder and
               sfg.manufacturingorderitem = rm.manufacturingorderitem and
               sfg.companycode = rm.companycode and
               sfg.goodsmovement = rm.goodsmovement and
               sfg.goodsmovementyear = rm.goodsmovementyear
         left outer join :Wstg_Cons as wstg
            on sfg.manufacturingorder = wstg.manufacturingorder and
               sfg.manufacturingorderitem = wstg.manufacturingorderitem and
               sfg.companycode = wstg.companycode and
               sfg.goodsmovement = wstg.goodsmovement and
               sfg.goodsmovementyear = wstg.goodsmovementyear;

  endmethod.
ENDCLASS.
