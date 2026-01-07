@EndUserText.label: 'Table Function Debtor Aging'
@ClientHandling.type:  #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl.authorizationCheck: #NOT_REQUIRED
define table function ZTBLF_DebtorAging
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
  zcl_debtoraging=>get_data_debtoraging;