@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Goods Movement Type'

@ObjectModel: {
                usageType: {
                              sizeCategory: #S,
                              serviceQuality: #A,
                              dataClass:#CUSTOMIZING
                            },
                representativeKey: 'GoodsMovementType'
              }
@Analytics: {
              dataCategory: #DIMENSION,
              internalName: #LOCAL
            }
@Search.searchable: true
@Metadata: {
             ignorePropagatedAnnotations: true
           }
define view entity ZDIM_GoodsMovementType
  as select from I_GoodsMovementType
{
      @ObjectModel: {
                        text: {
                                element:['GoodsMovementTypeName']
                              }
                      }
      @Search: {
                 defaultSearchElement: true,
                 fuzzinessThreshold: 0.8,
                 ranking: #HIGH
               }
  key GoodsMovementType,
      @Semantics.text: true
      _Text[1:Language=$session.system_language].GoodsMovementTypeName
}
