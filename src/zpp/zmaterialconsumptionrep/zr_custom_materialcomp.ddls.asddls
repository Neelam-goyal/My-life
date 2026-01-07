@AbapCatalog.sqlViewName: 'ZRMTLCOMP'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CUSTOM MATERIAL CONSUMPTION'
@Metadata.ignorePropagatedAnnotations: true


define view  ZR_CUSTOM_MATERIALCOMP as select from I_MaterialDocumentItem_2 as a
{
    key a.Plant ,
    key a.Material , 
    a.PostingDate ,
    sum ( a.QuantityInEntryUnit ) as totalqty

}
where a.Material = '' and a.Plant = 'BN02' 
group by a.Plant , a.Material , a.PostingDate

