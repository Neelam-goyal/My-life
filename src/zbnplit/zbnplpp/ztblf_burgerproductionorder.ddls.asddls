@EndUserText.label: 'Table Valued Func Burger Production Data'
@ClientHandling.type:  #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl.authorizationCheck: #NOT_REQUIRED
define table function ZTBLF_BurgerProductionOrder
  with parameters
    pCompany   : abap.char(4),
    pPrdnPlant : abap.char(4),
    pFromDate  : abap.dats,
    pToDate    : abap.dats
returns
{
  Client                         : mandt;

  ManufacturingOrder             : aufnr;
  ManufacturingOrderItem         : co_posnr;
  ManufacturingOrderCategory     : auftyp;
  ManufacturingOrderType         : aufart;
  OrderCreationDate              : datum;

  ProductGroup                   : matkl;
  Product                        : matnr;
  ProductionPlant                : werks_d;

  BOM                            : abap.char(13);
  CompanyCode                    : bukrs;
  ControllingArea                : kokrs;
  ProfitCenter                   : prctr;
  CostingSheet                   : aufkalsm;
  StorageLocation                : lgort_d;
  MfgOrderActualStartDate        : datum;
  MfgOrderItemActualDeliveryDate : datum;
  PostingDate                    : budat;
  GoodsMovement                  : mblnr;
  GoodsMovementYear              : gjahr;
  MfgOrderConfirmationGroup      : co_rueck;
  MfgOrderConfirmation           : cim_count;
  WorkCenterText                 : abap.char(40);
  ShiftDefinition                : abap.char(5);
  SPBUnit                        : meins;
  SFGStdSPB                      : basmn;
  SFGUnit                        : erfme;
  SFGProducedQty                 : abap.quan(13,3);
  RMUnit                         : erfme;
  RMConsumedQty                  : abap.quan(13,3);
  BagsConsumedQty                : abap.dec(13,3);
  WstgUnit                       : erfme;
  WstgProducedQty                : abap.quan(13,3);

}
implemented by method
  zcl_burgerproductionorder=>BurgerProductionData;