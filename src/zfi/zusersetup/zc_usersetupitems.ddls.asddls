@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Consumption view for User Setup Items'
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'Plant' ]
@Search.searchable: true
define view entity zc_usersetupitems
  as projection on zi_usersetupitems
{
  key Userid,
      @Search.defaultSearchElement: true
  key Plant,
      Username,
      Remarks,
      Tcode,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      _usersetup : redirected to parent zc_usersetup
}
