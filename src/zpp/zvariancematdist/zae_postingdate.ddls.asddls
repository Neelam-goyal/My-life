@EndUserText.label: 'Post Variance Date Parameter'
define abstract entity zae_postingdate
{
  @EndUserText.label: 'Company Code'
  bukrs        : abap.char(4);
  @EndUserText.label: 'Plant'
  werks        : abap.char(4);
  @EndUserText.label: 'Posting Date'
  declarecdate : abap.datn;
//  @EndUserText.label: 'Posting To Date'
//  declarectodate : abap.datn;

}
