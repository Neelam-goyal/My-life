@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forzactdistlines'
define view entity ZR_zactdistlinesTP
  as select from zactdistlines as zactdistlines
  association to parent ZR_ZACTIVITYDIST01TP as _ZACTIVITYDIST on $projection.Bukrs = _ZACTIVITYDIST.Bukrs 
    and $projection.Plantcode = _ZACTIVITYDIST.Plantcode and $projection.Declarecdate = _ZACTIVITYDIST.Declarecdate 
{
  key bukrs as Bukrs,
  key plantcode as Plantcode,
  key declarecdate as Declarecdate,
  key distlineno as Distlineno,
  shiftnumber as Shiftnumber,
  workcenterid as Workcenterid,
  workcenter as Workcenter,
  declaredate as Declaredate,
  productionorder as Productionorder,
  productionorderline as Productionorderline,
  orderconfirmationgroup as Orderconfirmationgroup,
  ordersequence as Ordersequence,
  clabour as Clabour,
  cpower as Cpower,
  cfuel as Cfuel,
  crepair as Crepair,
  coverheads as Coverheads,
  vlabour as Vlabour,
  vpower as Vpower,
  vfuel as Vfuel,
  vrepair as Vrepair,
  voverheads as Voverheads,
  varianceposted as Varianceposted,
  shiftgroup as Shiftgroup,
  _ZACTIVITYDIST
  
}
