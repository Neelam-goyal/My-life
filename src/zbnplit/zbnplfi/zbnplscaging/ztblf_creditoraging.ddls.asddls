@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Table Function Creditor Aging'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ClientHandling.type:  #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE

define table function ZTBLF_CreditorAging
  with parameters
    pCompany  : abap.char(4),
    pAsOnDate : abap.dats,
    pDaysStr  : abap.char(40)
returns
{
  Client                 : abap.clnt;
  PartyCode              : abap.char(10);
  PartyName              : abap.char(220);
  PostingDate            : abap.dats;
  NetDueDate             : abap.dats;
  CompanyCode            : abap.char(4);
  FiscalYear             : abap.numc(4);
  AccountingDocument     : belnr_d;
  AccountingDocumentType : abap.char(2);
  DocumentReferenceID    : abap.char(16);
  Balance                : abap.dec(18,2);
  DocAmt                 : abap.dec(18,2);
  VutRefRcptAmt          : abap.dec(18,2);
  DueAmt                 : abap.dec(18,2);
  NoDueAmt               : abap.dec(18,2);
  DueDays                : abap.int4;
  Range                  : abap.char(30);
}
implemented by method
  zcl_Creditoraging=>get_data_Creditoraging;