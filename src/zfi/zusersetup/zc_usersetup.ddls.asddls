@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Consumption view for User Setup'
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'Userid' ]
@Search.searchable: true
define root view entity zc_usersetup
  provider contract transactional_query
  as projection on zi_usersetup
{
      @Search.defaultSearchElement: true
      @EndUserText.label: 'User ID'
  key Userid,
      Username,
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Past Days'
      Pastdays,
      @EndUserText.label: 'Future Days'
      Futuredays,
      @EndUserText.label: 'Remarks'
      Remarks,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      _zusersetupitems : redirected to composition child zc_usersetupitems
}
