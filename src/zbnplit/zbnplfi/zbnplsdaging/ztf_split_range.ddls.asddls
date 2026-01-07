@EndUserText.label: 'Split Range Table Function'
@ClientHandling.type:  #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl.authorizationCheck: #NOT_REQUIRED
define table function ZTF_SPLIT_RANGE
  with parameters
    input_str : abap.string
returns
{
  Client    : abap.clnt;
  SrNo      : abap.int2;
  Min_value : abap.int2;
  Max_value : abap.int2;
}
implemented by method
  ZCL_DEBTORAGING=>SPLIT_RANGE;