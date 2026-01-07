@EndUserText.label: 'Material Variance Report TBLF'
@ClientHandling.type:  #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl.authorizationCheck: #NOT_REQUIRED
define table function ZTBLF_MaterialVarianceRep
  with parameters
    pCompany   : abap.char(4),
    pPrdnPlant : abap.char(4),
    pFromDate  : abap.dats,
    pToDate    : abap.dats
returns
{
  Client                       : mandt;
  ManufacturingOrder           : abap.char(12);
  CompanyCode                  : abap.char(4);
  ProductionPlant              : abap.char(4);
  MfgOrderDate                 : abap.dats(8);
  ManufacturingOrderType       : abap.char(4);
  MfgProduct                   : abap.char(40);
  MfgProductName               : abap.char(40);
  BOM                          : abap.char(13);
  BusinessArea                 : abap.char(4);
  ControllingArea              : abap.char(4);
  WorkCenterInternalID         : abap.numc(8);
  WorkCenterText               : abap.char(40);
  ProfitCenter                 : abap.char(10);
  CostingSheet                 : abap.char(6);
  ProductionUnit               : abap.unit(3);
  MfgOrderPlannedTotalQty      : abap.quan(13,3);
  MfgOrderConfirmedYieldQty    : abap.quan(13,3);
  ActualDeliveredQuantity      : abap.quan(13,3);
  MfgOrderConfirmationGroup    : abap.numc(10);
  MfgOrderConfirmation         : abap.numc(8);
  MaterialDocument             : abap.char(10);
  MaterialDocumentYear         : abap.numc(4);
  ManufacturingOrderCategory   : abap.numc(2);
  PostingDate                  : abap.dats(8);
  ConfirmationUnit             : abap.unit(3);
  ConfirmationYieldQuantity    : abap.quan(13,3);
  ConfirmationScrapQuantity    : abap.quan(13,3);
  ConfirmationReworkQuantity   : abap.quan(13,3);
  ConfirmationTotalQuantity    : abap.quan(13,3);
  ConfYieldQtyInProductionUnit : abap.quan(13,3);
  MaterialDocumentDate         : abap.dats(8);

  Material                     : abap.char(40);
  GoodsMovementType            : abap.char(3);
  UnitOfMeasurement            : abap.unit( 3 );
  RequiredQty                  : abap.quan(13,3);

  ActualQty                    : abap.quan(13,3);
  DiffQty                      : abap.quan(13,3);

  Currency                     : abap.cuky( 5 );
  RequiredAmt                  : abap.dec(13,2);
  ActualAmt                    : abap.dec(13,2);
  DiffAmt                      : abap.dec(13,2);
  RId                          : abap.int4;
}
implemented by method
  zcl_materialvariancerep=>GetMaterialVarianceRep;