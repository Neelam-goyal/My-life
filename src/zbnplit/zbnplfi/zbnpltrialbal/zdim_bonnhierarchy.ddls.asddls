@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Bonn Hierarchy'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDIM_BonnHierarchy
  as


  select

  from         ZR_BonnHierarchy as L5
    inner join ZR_BonnHierarchy as L4 on  L5.ParentNode         = L4.HierarchyNode
                                      and L5.GLAccountHierarchy = L4.GLAccountHierarchy
    inner join ZR_BonnHierarchy as L3 on  L4.ParentNode         = L3.HierarchyNode
                                      and L3.GLAccountHierarchy = L4.GLAccountHierarchy
    inner join ZR_BonnHierarchy as L2 on  L3.ParentNode         = L2.HierarchyNode
                                      and L2.GLAccountHierarchy = L3.GLAccountHierarchy
    inner join ZR_BonnHierarchy as L1 on  L2.ParentNode         = L1.HierarchyNode
                                      and L2.GLAccountHierarchy = L1.GLAccountHierarchy
    inner join ZR_BonnHierarchy as L0 on  L1.ParentNode         = L0.HierarchyNode
                                      and L1.GLAccountHierarchy = L0.GLAccountHierarchy
{
  @EndUserText.label: 'L5'
  L5.GLAccount                                                        as N5,
  @EndUserText.label: 'L4'
  L4.HierarchyNodeText                                                as N4,
  @EndUserText.label: 'L3'
  L3.HierarchyNodeText                                                as N3,
  @EndUserText.label: 'L2'
  L2.HierarchyNodeText                                                as N2,
  @EndUserText.label: 'L1'
  concat_with_space(L1.HierarchyNodeSequence, L1.HierarchyNodeText,1) as N1,
  @EndUserText.label: 'L0'
  L0.HierarchyNodeText                                                as N0
}
where
      L5.GLAccountHierarchy =  'BONN'
  and L5.GLAccount          <> ''
  and L5.GLAccount          is not null
  and L5.GLAccount          is not initial
  and L5.HierarchyNodeLevel =  '000006'

union

select

from         ZR_BonnHierarchy as L5
  inner join ZR_BonnHierarchy as L4 on  L5.ParentNode         = L4.HierarchyNode
                                    and L5.GLAccountHierarchy = L4.GLAccountHierarchy
  inner join ZR_BonnHierarchy as L3 on  L4.ParentNode         = L3.HierarchyNode
                                    and L3.GLAccountHierarchy = L4.GLAccountHierarchy

  inner join ZR_BonnHierarchy as L2 on  L3.ParentNode         = L2.HierarchyNode
                                    and L2.GLAccountHierarchy = L3.GLAccountHierarchy
  inner join ZR_BonnHierarchy as L1 on  L2.ParentNode         = L1.HierarchyNode
                                    and L2.GLAccountHierarchy = L1.GLAccountHierarchy
{

  L5.GLAccount                                                        as N5,
  L4.HierarchyNodeText                                                as N4,
  L4.HierarchyNodeText                                                as N3,
  L3.HierarchyNodeText                                                as N2,
  concat_with_space(L2.HierarchyNodeSequence, L2.HierarchyNodeText,1) as N1,
  L1.HierarchyNodeText                                                as N0
}
where
      L5.GLAccountHierarchy =  'BONN'
  and L5.GLAccount          <> ''
  and L5.GLAccount          is not null
  and L5.GLAccount          is not initial
  and L5.HierarchyNodeLevel =  '000005'

union

select

from         ZR_BonnHierarchy as L5
  inner join ZR_BonnHierarchy as L4 on  L5.ParentNode         = L4.HierarchyNode
                                    and L5.GLAccountHierarchy = L4.GLAccountHierarchy
  inner join ZR_BonnHierarchy as L3 on  L4.ParentNode         = L3.HierarchyNode
                                    and L3.GLAccountHierarchy = L4.GLAccountHierarchy

  inner join ZR_BonnHierarchy as L2 on  L3.ParentNode         = L2.HierarchyNode
                                    and L2.GLAccountHierarchy = L3.GLAccountHierarchy
{
  L5.GLAccount                                                        as N5,
  L4.HierarchyNodeText                                                as N4,
  L4.HierarchyNodeText                                                as N3,
  L4.HierarchyNodeText                                                as N2,
  concat_with_space(L3.HierarchyNodeSequence, L3.HierarchyNodeText,1) as N1,
  L2.HierarchyNodeText                                                as N0
}
where
      L5.GLAccountHierarchy =  'BONN'
  and L5.GLAccount          <> ''
  and L5.GLAccount          is not null
  and L5.GLAccount          is not initial
  and L5.HierarchyNodeLevel =  '000004'


union

select

from         ZR_BonnHierarchy as L5
  inner join ZR_BonnHierarchy as L4 on  L5.ParentNode         = L4.HierarchyNode
                                    and L5.GLAccountHierarchy = L4.GLAccountHierarchy
  inner join ZR_BonnHierarchy as L3 on  L4.ParentNode         = L3.HierarchyNode
                                    and L3.GLAccountHierarchy = L4.GLAccountHierarchy
{
  L5.GLAccount                                                        as N5,
  L4.HierarchyNodeText                                                as N4,
  L4.HierarchyNodeText                                                as N3,
  L4.HierarchyNodeText                                                as N2,
  concat_with_space(L4.HierarchyNodeSequence, L4.HierarchyNodeText,1) as N1,
  L3.HierarchyNodeText                                                as N0
}
where
      L5.GLAccountHierarchy =  'BONN'
  and L5.GLAccount          <> ''
  and L5.GLAccount          is not null
  and L5.GLAccount          is not initial
  and L5.HierarchyNodeLevel =  '000003'


union

select

from         ZR_BonnHierarchy as L5
  inner join ZR_BonnHierarchy as L4 on  L5.ParentNode         = L4.HierarchyNode
                                    and L5.GLAccountHierarchy = L4.GLAccountHierarchy
{
  L5.GLAccount                                                        as N5,
  L4.HierarchyNodeText                                                as N4,
  L4.HierarchyNodeText                                                as N3,
  L4.HierarchyNodeText                                                as N2,
  concat_with_space(L4.HierarchyNodeSequence, L4.HierarchyNodeText,1) as N1,
  L4.HierarchyNodeText                                                as N0
}
where
      L5.GLAccountHierarchy =  'BONN'
  and L5.GLAccount          <> ''
  and L5.GLAccount          is not null
  and L5.GLAccount          is not initial
  and L5.HierarchyNodeLevel =  '000002'
