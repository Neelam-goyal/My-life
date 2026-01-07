@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Customers'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #DIMENSION
@ObjectModel.representativeKey: 'Customer'

define view entity ZDIM_Customer
  as select from    I_Customer                as A
    left outer join I_RegionText              as _RegionText      on  A.Region             = _RegionText.Region
                                                                  and A.Country            = _RegionText.Country
                                                                  and _RegionText.Language = $session.system_language
    left outer join I_BusinessPartner         as _businessPartner on A.Customer = _businessPartner.BusinessPartner
    left outer join I_BusinessPartnerTypeText as _bpt             on  _businessPartner.BusinessPartnerType = _bpt.BusinessPartnerType
                                                                  and _bpt.Language                        = $session.system_language

{
      @ObjectModel.text.element: ['CustomerName']
  key A.Customer,

      @Semantics.text:true
      A.CustomerName,

      @Semantics.text:true
      @EndUserText.label: 'GSTIN'
      A.TaxNumber3           as GSTIN,

      @EndUserText.label: 'City'
      A.CityName             as City,

      @EndUserText.label: 'State'
      _RegionText.RegionName as Region,

      @EndUserText.label: 'Country'
      A.Country,

      @ObjectModel.text.element: ['BusinessPartnerTypeDesc']
      _businessPartner.BusinessPartnerType,

      @Semantics.text:true
      _bpt.BusinessPartnerTypeDesc,
      
      _businessPartner.InternationalLocationNumber1 as SSCode

      //    CustomerFullName,
      //    BPCustomerName,
      //    BPCustomerFullName,
      //    CreatedByUser,
      //    CreationDate,
      //    AddressID,
      //    CustomerClassification,
      //    VATRegistration,
      //    CustomerAccountGroup,
      //    AuthorizationGroup,
      //    DeliveryIsBlocked,
      //    PostingIsBlocked,
      //    BillingIsBlockedForCustomer,
      //    OrderIsBlockedForCustomer,
      //    InternationalLocationNumber1,
      //    IsOneTimeAccount,
      //    TaxJurisdiction,
      //    Industry,
      //    TaxNumberType,
      //    TaxNumber1,
      //    TaxNumber2,
      //    TaxNumber3,
      //    TaxNumber4,
      //    TaxNumber5,
      //    TaxNumber6,
      //    CustomerCorporateGroup,
      //    Supplier,
      //    NielsenRegion,
      //    IndustryCode1,
      //    IndustryCode2,
      //    IndustryCode3,
      //    IndustryCode4,
      //    IndustryCode5,
      //    Country,
      //    OrganizationBPName1,
      //    OrganizationBPName2,
      //    CityName,
      //    PostalCode,
      //    StreetName,
      //    SortField,
      //    FaxNumber,
      //    BR_SUFRAMACode,
      //    Region,
      //    TelephoneNumber1,
      //    TelephoneNumber2,
      //    AlternativePayerAccount,
      //    DataMediumExchangeIndicator,
      //    VATLiability,
      //    IsBusinessPurposeCompleted,
      //    ResponsibleType,
      //    FiscalAddress,
      //    NFPartnerIsNaturalPerson,
      //    DeletionIndicator,
      //    Language,
      //    TradingPartner,
      //    DeliveryDateTypeRule,
      //    ExpressTrainStationName,
      //    TrainStationName,
      //    InternationalLocationNumber2,
      //    InternationalLocationNumber3,
      //    CityCode,
      //    County,
      //    CustomerHasUnloadingPoint,
      //    CustomerWorkingTimeCalendar,
      //    IsCompetitor,
      //    TaxInvoiceRepresentativeName,
      //    BusinessType,
      //    IndustryType,
      //    TW_CollvBillingIsSupported,
      //    AlternativePayeeIsAllowed,
      //    FreeDefinedAttribute01,
      //    FreeDefinedAttribute02,
      //    FreeDefinedAttribute03,
      //    FreeDefinedAttribute04,
      //    FreeDefinedAttribute05,
      //    FreeDefinedAttribute06,
      //    FreeDefinedAttribute07,
      //    FreeDefinedAttribute08,
      //    FreeDefinedAttribute09,
      //    FreeDefinedAttribute10,
      //    PaymentReason,
      //    CustomerConditionGroup1,
      //    CustomerConditionGroup2,
      //    CustomerConditionGroup3,
      //    CustomerConditionGroup4,
      //    CustomerConditionGroup5,
      //    IsSalesProspect,
      //    PaymentIsBlockedForCustomer,
      //    IsConsumer,
      //    DataControllerSet,
      //    DataController1,
      //    DataController2,
      //    DataController3,
      //    DataController4,
      //    DataController5,
      //    DataController6,
      //    DataController7,
      //    DataController8,
      //    DataController9,
      //    DataController10,
      //    BusinessPartnerName1,
      //    BusinessPartnerName2,
      //    BusinessPartnerName3,
      //    BusinessPartnerName4,
      //    BPAddrCityName,
      //    BPAddrStreetName,
      //    AddressSearchTerm1,
      //    AddressSearchTerm2,
      //    DistrictName,
      //    POBoxDeviatingCityName,
      //    BusinessPartnerFormOfAddress,
      //    BR_ICMSTaxPayerType,
      //    /* Associations */
      //    _AddressDefaultRepresentation,
      //    _AddressRepresentation,
      //    _ContactPerson,
      //    _CorrespondingSupplier,
      //    _CreatedByUser,
      //    _CustomerAccountGroupText,
      //    _CustomerAddr,
      //    _CustomerAddrSalesAreaTax,
      //    _CustomerClassification,
      //    _CustomerClassificationText,
      //    _CustomerCompany,
      //    _CustomerHierarchyNode,
      //    _CustomerSalesArea,
      //    _CustomerSalesAreaTax,
      //    _CustomerToBusinessPartner,
      //    _GlobalCompany,
      //    _StandardAddress
}
