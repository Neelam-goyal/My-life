@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'User Setup Header CDS'
define root view entity zr_usersetup
  as select from zdt_usersetup as UserSetup
  composition [0..*] of zr_usersetup_items as _zusersetupitems
{
  key UserSetup.userid                as Userid,
      UserSetup.username              as Username,
      UserSetup.pastdays              as Pastdays,
      UserSetup.futuredays            as Futuredays,
      UserSetup.remarks               as Remarks,
      @Semantics.user.createdBy: true
      UserSetup.local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      UserSetup.local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      UserSetup.local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      UserSetup.local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      UserSetup.last_changed_at       as LastChangedAt,
      _zusersetupitems // Make association public
}
