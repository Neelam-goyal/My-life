@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for User Setup Items'
define view entity zi_usersetupitems
  as projection on zr_usersetup_items
{
  key Userid,
  key Plant,
      Username,
      Remarks,
      Tcode,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      _usersetup : redirected to parent zi_usersetup
}
