@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for CRUD operations'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_actdistlines as select from zactdistlines
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
    shiftgroup as Shiftgroup
}
