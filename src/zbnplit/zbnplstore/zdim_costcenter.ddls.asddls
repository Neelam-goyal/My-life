@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Dim Table for Cost Center'

@ObjectModel: {
                usageType: {
                              sizeCategory: #S,
                              serviceQuality: #A,
                              dataClass:#CUSTOMIZING
                            },
                representativeKey: 'CostCenter'
              }
@Analytics: {
              dataCategory: #DIMENSION,
              internalName: #LOCAL
            }
@Search.searchable: true
@Metadata: {
             ignorePropagatedAnnotations: true
           }
define view entity ZDIM_CostCenter
  as select from I_CostCenterText
{
      @ObjectModel: {
                        text: {
                                element:['CostCenterName']
                              }
                      }
      @Search: {
                 defaultSearchElement: true,
                 fuzzinessThreshold: 0.8,
                 ranking: #HIGH
               }
  key CostCenter,
      @Semantics.text: true
      CostCenterName
}
where
      Language        = 'E'
  and ControllingArea = 'A000'
