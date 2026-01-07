@EndUserText.label: 'Copy TMG for With Holding tax'
define abstract entity ZD_CopyTmgForWithHoldingTaP
{
  @EndUserText.label: 'New WITHHOLDINGTAXCODE'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Officialwhldgtaxcode' )
  Officialwhldgtaxcode : zdewithholdingtax;
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Withholdingtaxcode' )
  withholdingtaxcode   : abap.char(4);
  
}
