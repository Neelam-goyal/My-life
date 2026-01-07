@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help For Employee'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_EMPLOYEEVH as select from I_BusinessPartner as BP 
//inner join I_BusinessPartnerRoleTP as BPRole on BP.BusinessPartner = BPRole.BusinessPartner


{
    @EndUserText.label: 'Code'
    key BP.BusinessPartner as Employee,
    @EndUserText.label: 'Name'
    BP.BusinessPartnerFullName as Name
}
where BP.BusinessPartnerGrouping = 'BPEE'
or BP.BusinessPartnerGrouping = 'Z005'
//where BPRole.BusinessPartnerRole = 'BUP003'
//   or BPRole.BusinessPartnerRole = 'BUP010' // Employment
//   or BPRole.BusinessPartnerRole = 'BUP011' // External Employment
//   or BPRole.BusinessPartnerRole = 'BBP005'
//   or BPRole.BusinessPartnerRole = 'BBP010'
