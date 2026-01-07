@AbapCatalog.sqlViewName: 'Z_BUSPARVH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Defination for Business PArtner'
@Metadata.ignorePropagatedAnnotations: true
define view Z_BUSINESS_PARTNER as select from I_BusinessPartner
{
    key BusinessPartner,
    BusinessPartnerCategory,
    AuthorizationGroup,
    BusinessPartnerFullName,
    /* Associations */
    
    _BPCreditWorthiness,
    _BPDataController,
    _BPEmployment,
    _BPFinancialServicesExt,
    _BPFinancialServicesExtn,
    _BPRating,
    _BPRelationship,
    _BuPaIdentification,
    _BusinessPartnerIndustry,
    _BusinessPartnerRole,
    _CurrentDefaultAddress,
    _DefaultAddress,
    _Paymentcard
}
where I_BusinessPartner.BusinessPartnerGrouping='Z005';
