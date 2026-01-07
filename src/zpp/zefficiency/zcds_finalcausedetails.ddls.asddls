@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CAUSE DETAILS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDS_FINALCAUSEDETAILS
 as select from zproductionbreakdown   as a  
{
  /*--------------------  Key & source fields  --------------------*/
  key a.comp_code          as CompanyCode,
//  key a.shift             as Shift,
  KEY CASE 
    WHEN SHIFT = 'DAY' THEN 'DAY'
    WHEN SHIFT = 'NIGHT' THEN 'NIGHT'
    WHEN SHIFT = ' ' THEN 'DAY'
    ELSE NULL
END AS SHIFT,
  key a.brkdndate          as BreakdownDate,
  key a.prodordcode        as ManufacturingOrder,
  a.reasoncode             as Reasoncode,
  a.reasondesc             as ReasonDescription,
  a.remarks                as Remarks,
  a.brkdnstarttime         as BreakdownStartTime,
  a.brkdnendtime           as BreakdownEndTime,
  a.breakdownpercentage    as BreakdownPercentage,

  /*--------------------  1. Raw time difference in minutes  --------------------*/
  cast(
        case
           when ( cast( substring( a.brkdnendtime  , 1, 2 ) as abap.int4 ) * 60
                + cast( substring( a.brkdnendtime  , 3, 2 ) as abap.int4 ) )
              - ( cast( substring( a.brkdnstarttime, 1, 2 ) as abap.int4 ) * 60
                + cast( substring( a.brkdnstarttime, 3, 2 ) as abap.int4 ) )
                < 0
           then 1440
                + ( cast( substring( a.brkdnendtime  , 1, 2 ) as abap.int4 ) * 60
                  + cast( substring( a.brkdnendtime  , 3, 2 ) as abap.int4 ) )
                - ( cast( substring( a.brkdnstarttime, 1, 2 ) as abap.int4 ) * 60
                  + cast( substring( a.brkdnstarttime, 3, 2 ) as abap.int4 ) )
           else ( cast( substring( a.brkdnendtime  , 1, 2 ) as abap.int4 ) * 60
                + cast( substring( a.brkdnendtime  , 3, 2 ) as abap.int4 ) )
                - ( cast( substring( a.brkdnstarttime, 1, 2 ) as abap.int4 ) * 60
                + cast( substring( a.brkdnstarttime, 3, 2 ) as abap.int4 ) )
        end
       as abap.dec(15,2)
      )                                        as BrkDownTimeInMINS,

  /*-------------------- 2. Breakdown time adjusted by percentage  --------------*/
  cast(
        case
          /* — with percentage — */
          when a.breakdownpercentage is not null
           and a.breakdownpercentage > 0
          then
            ( case
                when ( cast( substring( a.brkdnendtime  , 1, 2 ) as abap.int4 ) * 60
                     + cast( substring( a.brkdnendtime  , 3, 2 ) as abap.int4 ) )
                   - ( cast( substring( a.brkdnstarttime, 1, 2 ) as abap.int4 ) * 60
                     + cast( substring( a.brkdnstarttime, 3, 2 ) as abap.int4 ) )
                     < 0
                then 1440
                     + ( cast( substring( a.brkdnendtime  , 1, 2 ) as abap.int4 ) * 60
                       + cast( substring( a.brkdnendtime  , 3, 2 ) as abap.int4 ) )
                     - ( cast( substring( a.brkdnstarttime, 1, 2 ) as abap.int4 ) * 60
                       + cast( substring( a.brkdnstarttime, 3, 2 ) as abap.int4 ) )
                else ( cast( substring( a.brkdnendtime  , 1, 2 ) as abap.int4 ) * 60
                     + cast( substring( a.brkdnendtime  , 3, 2 ) as abap.int4 ) )
                     - ( cast( substring( a.brkdnstarttime, 1, 2 ) as abap.int4 ) * 60
                     + cast( substring( a.brkdnstarttime, 3, 2 ) as abap.int4 ) )
              end
              * a.breakdownpercentage / 100 )

          /* — without percentage — */
          else
            ( case
                when ( cast( substring( a.brkdnendtime  , 1, 2 ) as abap.int4 ) * 60
                     + cast( substring( a.brkdnendtime  , 3, 2 ) as abap.int4 ) )
                   - ( cast( substring( a.brkdnstarttime, 1, 2 ) as abap.int4 ) * 60
                     + cast( substring( a.brkdnstarttime, 3, 2 ) as abap.int4 ) )
                     < 0
                then 1440
                     + ( cast( substring( a.brkdnendtime  , 1, 2 ) as abap.int4 ) * 60
                       + cast( substring( a.brkdnendtime  , 3, 2 ) as abap.int4 ) )
                     - ( cast( substring( a.brkdnstarttime, 1, 2 ) as abap.int4 ) * 60
                       + cast( substring( a.brkdnstarttime, 3, 2 ) as abap.int4 ) )
                else ( cast( substring( a.brkdnendtime  , 1, 2 ) as abap.int4 ) * 60
                     + cast( substring( a.brkdnendtime  , 3, 2 ) as abap.int4 ) )
                     - ( cast( substring( a.brkdnstarttime, 1, 2 ) as abap.int4 ) * 60
                     + cast( substring( a.brkdnstarttime, 3, 2 ) as abap.int4 ) )
              end )
        end
       as abap.dec(15,2)
      )                                        as BrkDwnInMinPercentage,

  /*-------------------- 3. Constant -----------------------------*/
  cast( 1 as abap.int4 )                       as NoOfOccurrence
}


