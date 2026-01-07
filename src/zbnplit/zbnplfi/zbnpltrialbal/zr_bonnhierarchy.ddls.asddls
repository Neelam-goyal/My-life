@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Flattern Bonn Hierarchy'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_BonnHierarchy

  as select from I_GLAccountHierarchyNode  as Node
    left outer join   I_GLAccountHierarchyNodeT as NodeT on  Node.GLAccountHierarchy = NodeT.GLAccountHierarchy
                                                    and Node.HierarchyNode      = NodeT.HierarchyNode
                                                    and NodeT.Language          = 'E'
{
  key Node.GLAccountHierarchy,
  key Node.HierarchyNode,
  
      NodeT.HierarchyNodeText,
      NodeT.HierarchyNodeShortText,
      Node.ParentNode,

      Node.ChartOfAccounts,
      Node.GLAccount,
      Node.SequenceNumber,
      Node.HierarchyNodeSequence,
      Node.HierarchyNodeLevel,
      Node.NodeType,
      Node.SignIsInverted,
      Node.HierarchyNodeVal,
      /* Associations */
      Node._ChartOfAccounts,
      Node._GLAccountInChartOfAccounts

}
