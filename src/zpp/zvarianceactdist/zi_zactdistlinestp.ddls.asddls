@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forzactdistlines'
define view entity ZI_zactdistlinesTP
  as projection on ZR_zactdistlinesTP as zactdistlines
{
  key Bukrs,
  key Plantcode,
  key Declarecdate,
  key Distlineno,
  Shiftnumber,
  Workcenterid,
  Workcenter,
  Declaredate,
  Productionorder,
  Productionorderline,
  Orderconfirmationgroup,
  Ordersequence,
  Clabour,
  Cpower,
  Cfuel,
  Crepair,
  Coverheads,
  Vlabour,
  Vpower,
  Vfuel,
  Vrepair,
  Voverheads,
  Varianceposted,
  Shiftgroup,
  _ZACTIVITYDIST : redirected to parent ZI_ZACTIVITYDIST01TP
  
}
