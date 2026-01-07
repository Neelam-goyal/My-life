@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SALES Data PBI'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
    serviceQuality: #X,
    sizeCategory  : #S,
    dataClass     : #MIXED
}
define view entity ZPBI_SALESDATA
  as select from    ZR_BillingDocumentItem     as item

    left outer join ZDIM_BillingDocumentType   as M_BillingDocumentType on item.BillingDocumentType = M_BillingDocumentType.BillingDocumentType

    left outer join ZDIM_Customer              as M_SoldToParty         on item.SoldToParty = M_SoldToParty.Customer

    left outer join ZDIM_CustomerWithSalesArea as M_BillToParty         on  item.BillToParty       = M_BillToParty.Customer
                                                                        and item.SalesOrganization = M_BillToParty.SalesOrg

    left outer join ZDIM_Customer              as M_ShipToParty         on item.ShipToParty = M_ShipToParty.Customer

    left outer join I_FiscalCalendarDate       as M_TimeDim             on  M_TimeDim.CalendarDate      = item.BillingDocumentDate
                                                                        and M_TimeDim.FiscalYearVariant = 'V3'

    left outer join ZDIM_DistributionChannel   as M_DistributionChannel on item.DistributionChannel = M_DistributionChannel.DistributionChannel

    left outer join ZDIM_Division              as M_Division            on item.Division = M_Division.Division

    left outer join ZDIM_Country               as M_Country             on item.Country = M_Country.Country

    left outer join ZDIM_Company               as M_CompanyCode         on item.CompanyCode = M_CompanyCode.CompanyCode

    left outer join ZDIM_Plant                 as M_Plant               on item.Plant = M_Plant.Plant

    left outer join ZDIM_Product               as M_Product             on item.Product = M_Product.Product

    left outer join ZDIM_ProductType           as M_ProductType         on M_Product.ProductType = M_ProductType.ProductType

    left outer join ZDIM_Brand                 as M_ProductBrand        on M_Product.Brand = M_ProductBrand.Brandcode

  //    left outer join I_ProductUnitsOfMeasure    as M_AltCtn              on  M_AltCtn.BaseUnit        = 'CTN'
  //                                                                        and M_AltCtn.Product         = item.Product
  //                                                                        and item.BillingQuantityUnit = M_AltCtn.AlternativeUnit

{
  key item.BillingDocument,
  key item.BillingDocumentItem,

      @EndUserText.label: 'Bill No.'
      item._BillingDocument.DocumentReferenceID,

      item.BillingDocumentDate,

      @Semantics.fiscal.yearVariant: true
      M_TimeDim.FiscalYearVariant,

      @EndUserText.label: 'Year'
      M_TimeDim.FiscalYear                                       as BillingYear,

      @EndUserText.label: 'Quarter'
      M_TimeDim.FiscalQuarter                                    as BillingQuarter,

      @Semantics.calendar.yearMonth
      @EndUserText.label: 'YearMonth'
      M_TimeDim._CalendarDate.YearMonth                          as BillingYearMonth,

      item.CompanyCode,
      M_CompanyCode.CompanyCodeName,

      item.SalesOrganization,

      item.DistributionChannel,
      M_DistributionChannel.DistributionChannelName,

      M_BillToParty._DistributionChannel.DistributionChannelName as BillToPartyMstDistChannel,

      item.Division,
      M_Division.DivisionName,

      item.Plant,
      M_Plant.PlantName,

      item.SDDocumentCategory,
      item._SDDocumentCategory._Text[1:Language='E'].SDDocumentCategoryName,

      item.BillingDocumentType,
      M_BillingDocumentType.BillingDocumentTypeName,

      item.Country,
      M_Country.CountryName,

      @EndUserText.label: 'State'
      item._Region._RegionText[1:Language='E'].RegionName,

      @EndUserText.label: 'Region'
      item.Region,

      @EndUserText.label: 'BillToPartyMstState'
      M_BillToParty.State                                        as BillToPartyMstState,

      @EndUserText.label: 'BillToPartyMstSSCode'
      M_BillToParty.SSCode,

      @EndUserText.label: 'GSTIN'
      M_SoldToParty.GSTIN                                        as SoldToPartyGSTIN,

      @EndUserText.label: 'City'
      M_SoldToParty.City,

      item.SalesDistrict,
      item._SalesDistrict._Text[1:Language='E'].SalesDistrictName,

      item.SoldToParty,
      M_SoldToParty.CustomerName                                 as SoldToPartyName,

      item.BillToParty,
      M_BillToParty.CustomerName                                 as BillToPartyName,

      item.ShipToParty,
      M_ShipToParty.CustomerName                                 as ShipToPartyName,

      item.Product,
      M_Product.ProductName,

      M_Product.ProductType,
      M_ProductType.MaterialTypeName                             as ProductTypeName,

      @EndUserText.label: 'ProductGroup'
      M_Product.ProductGroupName,

      @EndUserText.label: 'ProductSubGroup'
      M_Product.ProductSubGroupName,

      M_Product.ProductCategory,
      M_Product.Brand,

      item.BillingQuantityUnit,

      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      @EndUserText.label: 'BillingQuantity'
      item.BillingQuantity,

      @EndUserText.label: 'Item Weight(KG)'
      cast('KG' as abap.unit(3))                                 as ItemWeightUnit,

      @EndUserText.label: 'Item Gross Weight'
      coalesce(
        cast(
          unit_conversion(
            quantity       => item.ItemGrossWeight,
            source_unit    => item.ItemWeightUnit,
            target_unit    => cast('KG' as abap.unit(3)),
            error_handling => 'SET_TO_NULL'
          ) as abap.dec(13,3)
        ),
        cast(0 as abap.dec(13,3))
      )                                                          as ItemGrossWeight,

      @EndUserText.label: 'Item Net Weight'
      coalesce(
        cast(
          unit_conversion(
            quantity       => item.ItemNetWeight,
            source_unit    => item.ItemWeightUnit,
            target_unit    => cast('KG' as abap.unit(3)),
            error_handling => 'SET_TO_NULL'
          ) as abap.dec(13,3)
        ),
        cast(0 as abap.dec(13,3))
      )                                                          as ItemNetWeight,

      @EndUserText.label: 'Item CTNS'
      coalesce(
        case
         when item.BillingQuantityUnit = 'CTN' then cast( item.BillingQuantity as abap.dec(13,3))
         when item.BaseUnit = 'CTN' then cast(item.BillingQuantityInBaseUnit as abap.dec(13,3))
        end,
        cast(0 as abap.dec(13,3))
      )                                                          as ItemCTNS,

      coalesce(
        cast(
          currency_conversion(
            amount              => item.NetAmount,
            source_currency     => item.TransactionCurrency,
            target_currency     => cast('INR' as vdm_v_display_currency),
            exchange_rate_date  => item.BillingDocumentDate,
            exchange_rate_type  => 'M',
            error_handling      => 'SET_TO_NULL',
            round               => 'true',
            decimal_shift       => 'true',
            decimal_shift_back  => 'true'
          ) as abap.dec(19,2)
        ),
        cast(0 as abap.dec(19,2))
      ) -
      coalesce(
        cast(
          currency_conversion(
            amount              => item.FreightAmount,
            source_currency     => item.TransactionCurrency,
            target_currency     => cast('INR' as vdm_v_display_currency),
            exchange_rate_date  => item.BillingDocumentDate,
            exchange_rate_type  => 'M',
            error_handling      => 'SET_TO_NULL',
            round               => 'true',
            decimal_shift       => 'true',
            decimal_shift_back  => 'true'
          ) as abap.dec(19,2)
        ),
        cast(0 as abap.dec(19,2))
      )                                                          as SaleAmount,

      @EndUserText.label: 'Freight Amount'
      coalesce(
        cast(
          currency_conversion(
            amount              => item.FreightAmount,
            source_currency     => item.TransactionCurrency,
            target_currency     => cast('INR' as vdm_v_display_currency),
            exchange_rate_date  => item.BillingDocumentDate,
            exchange_rate_type  => 'M',
            error_handling      => 'SET_TO_NULL',
            round               => 'true',
            decimal_shift       => 'true',
            decimal_shift_back  => 'true'
          ) as abap.dec(19,2)
        ),
        cast(0 as abap.dec(19,2))
      )                                                          as FreightAmountInINR,

      @EndUserText.label: 'Txbl Amount'
      coalesce(
        cast(
          currency_conversion(
            amount              => item.NetAmount,
            source_currency     => item.TransactionCurrency,
            target_currency     => cast('INR' as vdm_v_display_currency),
            exchange_rate_date  => item.BillingDocumentDate,
            exchange_rate_type  => 'M',
            error_handling      => 'SET_TO_NULL',
            round               => 'true',
            decimal_shift       => 'true',
            decimal_shift_back  => 'true'
          ) as abap.dec(19,2)
        ),
        cast(0 as abap.dec(19,2))
      )                                                          as TxblAmountInInr,

      @EndUserText.label: 'Tax Amount'
      coalesce(
        cast(
          currency_conversion(
            amount              => item.TaxAmount,
            source_currency     => item.TransactionCurrency,
            target_currency     => cast('INR' as vdm_v_display_currency),
            exchange_rate_date  => item.BillingDocumentDate,
            exchange_rate_type  => 'M',
            error_handling      => 'SET_TO_NULL',
            round               => 'true',
            decimal_shift       => 'true',
            decimal_shift_back  => 'true'
          ) as abap.dec(19,2)
        ),
        cast(0 as abap.dec(19,2))
      )                                                          as TaxAmountInINR,

      coalesce(
        cast(
          currency_conversion(
            amount              => item.NetAmount,
            source_currency     => item.TransactionCurrency,
            target_currency     => cast('INR' as vdm_v_display_currency),
            exchange_rate_date  => item.BillingDocumentDate,
            exchange_rate_type  => 'M',
            error_handling      => 'SET_TO_NULL',
            round               => 'true',
            decimal_shift       => 'true',
            decimal_shift_back  => 'true'
          ) as abap.dec(19,2)
        ),
        cast(0 as abap.dec(19,2))
      ) +
      coalesce(
        cast(
          currency_conversion(
            amount              => item.TaxAmount,
            source_currency     => item.TransactionCurrency,
            target_currency     => cast('INR' as vdm_v_display_currency),
            exchange_rate_date  => item.BillingDocumentDate,
            exchange_rate_type  => 'M',
            error_handling      => 'SET_TO_NULL',
            round               => 'true',
            decimal_shift       => 'true',
            decimal_shift_back  => 'true'
          ) as abap.dec(19,2)
        ),
        cast(0 as abap.dec(19,2))
      )                                                          as NetAmountInINR
}
