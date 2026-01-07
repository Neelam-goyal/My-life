@EndUserText.label: 'FB60 Purchase GST Report'
@ClientHandling.type:  #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl.authorizationCheck: #NOT_REQUIRED
define table function ZTBLF_PurGSTRCMFB60
  with parameters
    pCompanyCode : abap.char(4),
    pFromDate    : abap.dats,
    pToDate      : abap.dats

returns
{
  CLIENT         : mandt;
  fiscalyear     : abap.char(4);
  doc_type       : abap.char(2);
  mrn_no         : abap.numc(10);
  item_sr        : abap.int4;
  hsn_code       : abap.numc(10);
  bill_no        : abap.char(20);
  supplier_code  : abap.numc(10);
  mrn_date       : abap.dats(8);
  bill_date      : abap.dats(8);
  company_code   : abap.char(4);
  plant_code     : abap.char(4);
  pass_tag       : abap.char(4);
  location       : abap.char(30);
  productname    : abap.char(40);
  suppliername   : abap.char(50);
  suppliergstno  : abap.char(15);
  localcentre    : abap.char(7);
  supplierstate  : abap.char(30);
  purpostingcode : abap.numc(10);
  purpostinghead : abap.char(50);
  taxcode        : abap.char(50);
  gstrate        : abap.dec(7,2);
  qty            : abap.dec(15,3);
  uom            : abap.char(5);
  rate           : abap.dec(15,3);
  amount         : abap.dec(15,2);
  igstamount     : abap.dec(15,2);
  cgstamount     : abap.dec(15,2);
  sgstamount     : abap.dec(15,2);
  rigstamount    : abap.dec(15,2);
  rcgstamount    : abap.dec(15,2);
  rsgstamount    : abap.dec(15,2);
  gstcess        : abap.dec(15,2);


}
implemented by method
  zcl_purgstrcmfb60=>get_data;