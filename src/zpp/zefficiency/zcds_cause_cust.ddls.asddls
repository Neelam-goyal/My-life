    @AbapCatalog.viewEnhancementCategory: [#NONE]
    @AccessControl.authorizationCheck: #NOT_REQUIRED
    @EndUserText.label: 'Cds for Cause'
    @Metadata.ignorePropagatedAnnotations: true
    @ObjectModel.usageType:{
        serviceQuality: #X,
        sizeCategory: #S,
        dataClass: #MIXED
    }
    define view entity ZCDS_CAUSE_CUST as select from zproduct_details as a
   left outer join zproductionbreakdown as b on  a.ManufacturingOrder = b.prodordcode 
                                   and a.ShiftDescription = b.shift 
                                   and a.PostingDate = b.brkdndate
    
    {
        key a.WorkCenter as WorkCenter,
        key a.Plant as Plant,
        key b.shift as Shift,
        key b.brkdndate as BreakdownDate,
        key a.ManufacturingOrder as ManufacturingOrder,
        b.subreasoncode as Causecode,
        b.reasoncode as Reasoncode,
        b.subreasondesc as Causedescription,
        b.remarks as Remarks,
        b.brkdnstarttime as BreakdownStartTime,
        b.brkdnendtime as BreakdownEndTime,
        
   /** Duration in minutes with midnight-crossing support **/
    case
        when (
            ( cast( substring(b.brkdnendtime, 1, 2) as abap.int4 ) * 60 +
              cast( substring(b.brkdnendtime, 3, 2) as abap.int4 ) )
          -
            ( cast( substring(b.brkdnstarttime, 1, 2) as abap.int4 ) * 60 +
              cast( substring(b.brkdnstarttime, 3, 2) as abap.int4 ) )
        ) < 0
        then
            1440 +
            (
                ( cast( substring(b.brkdnendtime, 1, 2) as abap.int4 ) * 60 +
                  cast( substring(b.brkdnendtime, 3, 2) as abap.int4 ) )
              -
                ( cast( substring(b.brkdnstarttime, 1, 2) as abap.int4 ) * 60 +
                  cast( substring(b.brkdnstarttime, 3, 2) as abap.int4 ) )
            )
        else
            (
                ( cast( substring(b.brkdnendtime, 1, 2) as abap.int4 ) * 60 +
                  cast( substring(b.brkdnendtime, 3, 2) as abap.int4 ) )
              -
                ( cast( substring(b.brkdnstarttime, 1, 2) as abap.int4 ) * 60 +
                  cast( substring(b.brkdnstarttime, 3, 2) as abap.int4 ) )
            )
    end as BrkDwnInMin,
    
    cast( 1 as abap.int4 ) as NoOfOccurrence
    
    
}
