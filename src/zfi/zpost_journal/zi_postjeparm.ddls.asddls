@EndUserText.label: 'CDS for POST JE Params'
define abstract entity ZI_POSTJEPARM
{
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeSTDVH', element: 'CompanyCode' } }]
    @EndUserText.label: 'Company Code'
    comp_code : bukrs;
    
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH', element: 'Plant' } }]  
    @EndUserText.label: 'Plant'
    plant : werks_d;
    
    @EndUserText.label: 'From Date'
    from_date : abap.dats;
    
    @EndUserText.label: 'To Date'
    to_date : abap.dats;
    
    @EndUserText.label: 'Percent'
    percent : abap.dec(5,2);
    
}
