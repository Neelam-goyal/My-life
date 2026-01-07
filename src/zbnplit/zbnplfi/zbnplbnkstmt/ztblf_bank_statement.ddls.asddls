@EndUserText.label: 'TABLE VALUED FUNCTION BANK STATEMENT'
@ClientHandling.type:  #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl.authorizationCheck: #NOT_REQUIRED
define table function ZTBLF_BANK_STATEMENT
  with parameters
    //    @Environment.systemField: #CLIENT
    //    pClient      : mandt,
    pCompanyCode : abap.char(4),
    pBankAccountInternalId : zbnkacintid,
    pFromDate    : abap.dats,
    pToDate      : abap.dats,
    @Consumption.defaultValue: 'N'
    pIsRevDoc    : abap.char(1)
returns
{
  CLIENT                      : mandt;
  FISCALYEAR                  : abap.numc(4);
  COMPANYCODE                 : abap.char(4);
  BankCode                    : zbnkacintid;

  GLACCOUNT                   : abap.char(10);

  SRNO                        : abap.int4;
  POSTINGDATE                 : abap.dats;
  DOCUMENTDATE                : abap.dats;
  ACCOUNTINGDOCUMENTTYPE      : abap.char(2);
  ACCOUNTINGDOCUMENT          : abap.char(10);

  REFERENCEDOCUMENTTYPE       : abap.char(5);
  ORIGINALREFERENCEDOCUMENT   : abap.char(20);
  DOCUMENTITEMTEXT            : abap.char(500);

  BusinessTransactionType     : abap.char(4);
  CostCenter                  : kostl;
  ProfitCenter                : prctr;
  FunctionalArea              : fkber;
  BusinessArea                : gsber;
  BusinessPlace               : abap.char(4);
  Segment                     : fb_segment;
  Plant                       : abap.char(4);
  ControllingArea             : abap.char(4);

  ReversalReason              : stgrd;
  IsReversal                  : abap.char(1);
  IsReversed                  : abap.char(1);
  ReversedReferenceDocument   : abap.char(10);
  ReversalReferenceDocument   : abap.char(10);
  ReversedDocument            : abap.char(10);
  ReverseDocument             : abap.char(10);

  COMPANYCODECURRENCY         : abap.cuky(5);
  DEBITCREDITCODE             : abap.char(1);
  AMOUNTINCOMPANYCODECURRENCY : abap.curr(23,2);
  CREDITAMOUNTINCMPCDCRCY     : abap.curr(23,2);
  DEBITAMOUNTINCMPCDCRCY      : abap.curr(23,2);
  RUNNINGBALANCE              : abap.curr(23,2);

}
implemented by method
  zcl_bank_fiscal_stmt=>GET_DATA_BANK_STATEMENT;