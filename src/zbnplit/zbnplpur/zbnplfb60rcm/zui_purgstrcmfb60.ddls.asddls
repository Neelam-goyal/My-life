@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'UI FB60 Purchase GST Report'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZUI_PurGSTRCMFB60
  with parameters
    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompanyCode : bukrs,

    @EndUserText.label: 'From (Posting Date)'
    //    @Consumption.derivation: { lookupEntity: 'I_FiscalCalendarDate',
    //    resultElement: 'FiscalYearStartDate',
    //    binding: [
    //    { targetElement : 'FiscalYearVariant' , type : #CONSTANT, value : 'V3' },
    //    { targetElement : 'CalendarDate' , type : #PARAMETER, value : 'pToDate' }
    //
    //     ]
    //    }
    @Consumption.defaultValue: '20250401'
    pFromDate    : calendardate,
    @EndUserText.label: 'To (Posting Date)'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
    resultElement: 'UserLocalDate', binding: [
    { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
    }
    pToDate      : calendardate


  as select from ZTBLF_PurGSTRCMFB60 (pCompanyCode:$parameters.pCompanyCode,
                                      pFromDate:$parameters.pFromDate,
                                      pToDate:$parameters.pToDate
                                        ) as record
  association [1..1] to I_JournalEntry               as _JournalEntry               on  $projection.company_code = _JournalEntry.CompanyCode
                                                                                    and $projection.fiscalyear   = _JournalEntry.FiscalYear
                                                                                    and $projection.mrn_no       = _JournalEntry.AccountingDocument
  association        to I_AccountingDocumentTypeText as _AccountingDocumentTypeText on  $projection.doc_type                 = _AccountingDocumentTypeText.AccountingDocumentType
                                                                                    and _AccountingDocumentTypeText.Language = $session.system_language

{
  key mrn_no,
  key company_code,
  key record.fiscalyear,
  key record.item_sr,

      @ObjectModel.foreignKey.association: '_AccountingDocumentTypeText'
      @ObjectModel.text.element: [ 'AccountingDocumentTypeName' ]
      cast(doc_type as blart preserving type ) as doc_type,
      _AccountingDocumentTypeText.AccountingDocumentTypeName,
      _AccountingDocumentTypeText,
      hsn_code,
      bill_no,
      supplier_code,
      mrn_date,
      bill_date,
      plant_code,
      pass_tag,
      location,
      productname,
      suppliername,
      suppliergstno,
      localcentre,
      supplierstate,
      purpostingcode,
      purpostinghead,
      taxcode,
      gstrate,
      qty,
      uom,
      rate,
      amount,
      igstamount,
      cgstamount,
      sgstamount,
      rigstamount,
      rcgstamount,
      rsgstamount,
      gstcess
}
