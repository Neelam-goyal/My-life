@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forzmaterialdist'
define root view entity ZR_materialdist01TP
  as select from zmaterialdist as zmaterialdist
  composition [0..*] of ZR_matdistlinesTP as _matdistlines
{
      @EndUserText.label: 'Company'
  key bukrs                 as Bukrs,
      @EndUserText.label: 'Plant'
  key plantcode             as Plantcode,
      @EndUserText.label: 'Declare Cdate'
  key declarecdate          as Declarecdate,
      @EndUserText.label: 'Variance Posting Cdate'
      variancepostdate      as Variancepostdate,
      @EndUserText.label: 'Declare date'
      declaredate           as Declaredate,
      @EndUserText.label: 'Variance Calculated'
      variancecalculated    as Variancecalculated,
      @EndUserText.label: 'Variance Posted'
      varianceposted        as Varianceposted,
      @EndUserText.label: 'Total Job Run'
      totaljobrun           as Totaljobrun,
      @EndUserText.label: 'Variance Closed'
      varianceclosed        as Varianceclosed,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _matdistlines

}
