@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'value help for company code'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_companyCodeVH as select from I_CompanyCode

{
    key CompanyCode,
    CompanyCodeName,
    /* Associations */

    _CompanyCodeHierNode
 }
