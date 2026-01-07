@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for User Setup'
define root view entity zi_usersetup
  provider contract transactional_interface
  as projection on zr_usersetup
{
  key Userid,
      Username,
      Pastdays,
      Futuredays,
      Remarks,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      _zusersetupitems : redirected to composition child zi_usersetupitems
}
