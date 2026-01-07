@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'VALUE HELP FOR BANKRECO ID'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZBANKRECOID_VH as select from zbank_reco
{
    key bankrecoid,
    bank,
    company,
    concat(
        substring(statementdate, 7, 2),  
        concat('-', 
            concat(
                substring(statementdate, 5, 2), 
                concat('-', substring(statementdate, 1, 4)) 
            )
        )
    ) as statementdate,
    status
    
    
}
