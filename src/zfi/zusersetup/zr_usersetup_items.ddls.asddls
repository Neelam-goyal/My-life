@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'User Setup Items CDS'
define view entity zr_usersetup_items
  as select from zdt_user_item as usersetupitems
  association to parent zr_usersetup as _usersetup on $projection.Userid = _usersetup.Userid

{
  key usersetupitems.userid                as Userid,
  key usersetupitems.plant                 as Plant,
      usersetupitems.username              as Username,
      usersetupitems.remarks               as Remarks,
      usersetupitems.tcode                 as Tcode,
      @Semantics.user.createdBy: true
      usersetupitems.local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      usersetupitems.local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      usersetupitems.local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      usersetupitems.local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      usersetupitems.last_changed_at       as LastChangedAt,
      _usersetup
}
