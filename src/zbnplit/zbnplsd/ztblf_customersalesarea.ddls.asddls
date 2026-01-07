@EndUserText.label: 'Customer with Sales Area'
@ClientHandling.type:  #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl.authorizationCheck: #NOT_REQUIRED
define table function ZTBLF_CUSTOMERSALESAREA

returns
{
  key Client       : abap.clnt;
  key SalesOrg     : vkorg;
  key Customer     : kunnr;
      CustomerName : text80;
      GSTIN        : stcd3;
      City         : text35;
      State        : abap.char(20);
      Country      : abap.char(3);

      DistChannel  : vtweg;
      Division     : spart;
      SSCode       : abap.numc( 7 );
}
implemented by method
  ZCL_CUSTOMERSALESAREA=>GetData;