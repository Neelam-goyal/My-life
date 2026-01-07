@EndUserText.label: 'Copy TABLE FOR TAX CODE'
define abstract entity ZD_CopyTableForTaxCodeP
{
  @EndUserText.label: 'New Country'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Country' )
  Country : zde_country;
  @EndUserText.label: 'New WITHHOLDINGTAXCODE'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Officialwhldgtaxcode' )
  Officialwhldgtaxcode : zdewithholdingtax;
  @EndUserText.label: 'New WithHolding Tax Code'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Withholdingtaxcode' )
  Withholdingtaxcode : zde_withholdingtaxcode;
  @EndUserText.label: 'New WithHolding Tax Code'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: withholdingtaxtype' )
  withholdingtaxtype : zde_withholdingtaxtype;
  @EndUserText.label: 'New WithHolding Tax Code'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: glaccount' )
  glaccount : zde_glaccount;
  
}
