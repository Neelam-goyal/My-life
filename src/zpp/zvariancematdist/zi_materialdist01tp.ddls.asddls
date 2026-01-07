@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for zmaterialdist'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_materialdist01TP
  provider contract transactional_interface
  as projection on ZR_materialdist01TP as zmaterialdist
{
  key Bukrs,
  key Plantcode,
  key Declarecdate,
      Variancepostdate,
      Declaredate,
      Variancecalculated,
      Varianceposted,
      Varianceclosed,
      Totaljobrun,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _matdistlines : redirected to composition child ZI_matdistlinesTP
}
