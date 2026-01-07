CLASS LHC_ZR_INVGROUPED000 DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrInvgrouped000
        RESULT result.

    METHODS calculate FOR MODIFY
      IMPORTING keys FOR ACTION ZrInvgrouped000~calculate .

    METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

    METHODS generateForSales IMPORTING VALUE(curDate) TYPE D.
    METHODS generateForUnSold IMPORTING VALUE(curDate) TYPE D.
    METHODS generateForExpense IMPORTING VALUE(curDate) TYPE D.
    METHODS generateForCrates IMPORTING VALUE(curDate) TYPE D.
    METHODS generateForScrap IMPORTING VALUE(curDate) TYPE D.
    METHODS generateForCRN IMPORTING VALUE(curDate) TYPE D.
    METHODS generateForReciept IMPORTING VALUE(curDate) TYPE D.

    CLASS-DATA wa_irn TYPE zr_invgrouped000.
    CLASS-DATA lt_irn TYPE TABLE OF zr_invgrouped000.


    METHODS UpdatedDoc
      IMPORTING delivery TYPE string
      doctype TYPE STRING.
  ENDCLASS.

CLASS LHC_ZR_INVGROUPED000 IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

   METHOD calculate.



     READ TABLE keys INTO DATA(ls_key) INDEX 1.
     DATA(curDate) = ls_key-%param-OrderDate.
     DELETE FROM zinv_grouped WHERE orderdate EQ @curDate.

     generateForSales( curDate = curDate ).
     generateForUnSold( curDate = curDate ).
     generateForExpense( curDate = curDate ).
     generateForCrates( curDate = curDate ).
     generateForScrap( curDate = curDate ).
     generateForCRN( curDate = curDate ).
     generateForReciept( curDate = curDate ).

     APPEND VALUE #(  %cid = ls_key-%cid
             %msg = new_message_with_text(
               severity = if_abap_behv_message=>severity-success
               text = 'Data Generated.' )
               ) TO reported-zrinvgrouped000.
     RETURN.
   ENDMETHOD.

    METHOD UpdatedDoc.


      SELECT SINGLE FROM I_BillingDocument AS a
      JOIN I_BILlingDocumentITEM AS b ON b~BillingDocument = a~BillingDocument
      FIELDS a~BillingDocument, ( a~TotalNetAmount + a~TotalTaxAmount ) AS TotAmt
        WHERE b~ReferenceSDDocument = @delivery AND a~BillingDocumentType NE 'S1' AND a~BillingDocumentIsCancelled = ''
      INTO @DATA(ls_billing).

      IF ls_billing IS NOT INITIAL.
        IF doctype EQ 'Sales'.
          UPDATE zinv_mst
          SET
              reference_doc_invoice = @ls_billing-BillingDocument ,
              invoiceamount =  @ls_billing-totamt
          WHERE reference_doc_del = @delivery.
        ELSEIF doctype EQ 'Unsold'.
          UPDATE zdt_usdatamst1
          SET
              reference_doc_invoice = @ls_billing-BillingDocument ,
              invoiceamount =  @ls_billing-totamt
          WHERE reference_doc_del = @delivery.
        ENDIF.
        ENDIF.


      ENDMETHOD.

         METHOD generateForUnSold.

           SELECT FROM zdt_usdatamst1
                   FIELDS reference_doc_del, comp_code, plant, imfyear, imno, imtype
                     WHERE reference_doc_del NE ''
                     AND reference_doc_invoice EQ ''
                     INTO TABLE @DATA(lt_result1).

           LOOP AT lt_result1 INTO DATA(wa_irn1).
             DATA(del) = CONV string( wa_irn1-reference_doc_del ).
             UpdatedDoc( delivery = del doctype = 'Unsold' ).
           ENDLOOP.


           SELECT SINGLE FROM zdt_usdatamst1
                   FIELDS
                    SUM( imnetamtro ) AS actualamount,
                    SUM( invoiceamount ) AS billedamount,
                    SUM( orderamount ) AS orderamount,
                    COUNT( imno ) AS nooforder
                     WHERE imdate = @curDate
                     INTO @DATA(ls_actual).

         SELECT SINGLE FROM zdt_usdatamst1
         FIELDS
              COUNT( imno ) AS Datavalidated
                   WHERE imdate = @curDate AND datavalidated = '1'
                    INTO @DATA(ls_datavalidated).


           SELECT SINGLE FROM zdt_usdatamst1
           FIELDS COUNT( reference_doc_del ) AS delCount
           WHERE imdate = @curDate AND reference_doc_del NE ''
           INTO @DATA(ls_delcount).

           SELECT SINGLE FROM zdt_usdatamst1
           FIELDS COUNT( reference_doc ) AS orderCount
           WHERE imdate = @curDate AND reference_doc NE ''
           INTO @DATA(ls_ordercount).

           SELECT SINGLE FROM zdt_usdatamst1
           FIELDS COUNT( reference_doc_invoice ) AS invCount
           WHERE imdate = @curDate AND reference_doc_invoice NE ''
           INTO @DATA(ls_invcount).


           wa_irn-BilledAmount = ls_actual-billedamount.
           wa_irn-Processed = ls_invcount.
           wa_irn-OrderBilled = ls_invcount.
           wa_irn-OrderAmount = ls_actual-actualamount.
           wa_irn-NoOfOrder = ls_actual-nooforder.
           wa_irn-datavalidated = ls_datavalidated.
           wa_irn-OutboundCreated = ls_delcount.
           wa_irn-SOAmount = ls_actual-orderamount.
           wa_irn-SOCreated = ls_ordercount.
           wa_irn-OrderDate = curDate.



           MODIFY ENTITIES OF zr_invgrouped000 IN LOCAL MODE
             ENTITY ZrInvgrouped000
             CREATE FIELDS ( BilledAmount Processed OrderBilled OrderAmount NoOfOrder Datavalidated OutboundCreated SOAmount SOCreated
                              OrderDate Type )
             WITH VALUE #( (
                    %cid = getCID( )
                    Billedamount    = wa_irn-BilledAmount
                    Processed       = wa_irn-Processed
                    OrderBilled     = wa_irn-OrderBilled
                    OrderAmount     = wa_irn-OrderAmount
                    NoOfOrder       = wa_irn-NoOfOrder
                    Datavalidated   = wa_irn-Datavalidated
                    OutboundCreated = wa_irn-OutboundCreated
                    SOAmount        = wa_irn-SOAmount
                    SOCreated       = wa_irn-SOCreated
                    OrderDate       = wa_irn-OrderDate
                    Type            = 'Unsold'
                ) )
             MAPPED   DATA(mapped)
             FAILED   DATA(failed)
             REPORTED DATA(reported).


         ENDMETHOD.



   METHOD generateForExpense.



     SELECT SINGLE FROM zcontrolsheet
             FIELDS
              SUM( toll + routeexp + cngexp + other + repair + dieselexp ) AS actualamount,
              CAST( SUM( glposted ) AS INT4 ) AS processed,
              COUNT( gate_entry_no ) AS nooforder
               WHERE gpdate = @curDate
               INTO @DATA(ls_actual).


     wa_irn-Processed = ls_actual-processed.
     wa_irn-OrderAmount = ls_actual-actualamount.
     wa_irn-NoOfOrder = ls_actual-nooforder.
     wa_irn-datavalidated = ls_actual-processed.
     wa_irn-OrderDate = curDate.

     MODIFY ENTITIES OF zr_invgrouped000 IN LOCAL MODE
       ENTITY ZrInvgrouped000
       CREATE FIELDS ( Processed OrderAmount NoOfOrder OrderDate Datavalidated Type )
       WITH VALUE #( (
              %cid = getCID( )
              Processed       = wa_irn-Processed
              OrderAmount     = wa_irn-OrderAmount
              NoOfOrder       = wa_irn-NoOfOrder
              OrderDate       = wa_irn-OrderDate
              Datavalidated   = wa_irn-Datavalidated
              Type            = 'Expenses'
          ) )
       MAPPED DATA(mapped)
       FAILED   DATA(failed)
       REPORTED DATA(reported).

   ENDMETHOD.

   METHOD generateForCrates.



     SELECT SINGLE FROM zcratesdata
             FIELDS
              CAST( SUM( movementposted ) AS INT4 ) AS processed,
              COUNT( cmno ) AS nooforder
               WHERE cmdate = @curDate
               INTO @DATA(ls_actual).


     wa_irn-Processed = ls_actual-processed.
     wa_irn-NoOfOrder = ls_actual-nooforder.
     wa_irn-datavalidated = ls_actual-processed.
     wa_irn-OrderDate = curDate.



     MODIFY ENTITIES OF zr_invgrouped000 IN LOCAL MODE
       ENTITY ZrInvgrouped000
       CREATE FIELDS ( Processed NoOfOrder OrderDate Datavalidated Type )
       WITH VALUE #( (
              %cid = getCID( )
              Processed       = wa_irn-Processed
              NoOfOrder       = wa_irn-NoOfOrder
              OrderDate       = wa_irn-OrderDate
              Datavalidated   = wa_irn-Datavalidated
              Type            = 'Crates'
          ) )
       MAPPED DATA(mapped)
       FAILED   DATA(failed)
       REPORTED DATA(reported).

   ENDMETHOD.

    METHOD generateForScrap.



     SELECT SINGLE FROM zdt_rplcrnote
             FIELDS
              COUNT( imno ) AS nooforder
               WHERE imdate = @curDate
               INTO @DATA(nooforder).

      SELECT SINGLE FROM zdt_rplcrnote
         FIELDS
          COUNT( imno ) AS nooforder
           WHERE imdate = @curDate and processed = '1'
        INTO @DATA(processed).


     wa_irn-Processed = processed.
     wa_irn-NoOfOrder = nooforder.
     wa_irn-datavalidated = processed.
     wa_irn-OrderDate = curDate.



     MODIFY ENTITIES OF zr_invgrouped000 IN LOCAL MODE
       ENTITY ZrInvgrouped000
       CREATE FIELDS ( Processed NoOfOrder OrderDate Datavalidated Type )
       WITH VALUE #( (
              %cid = getCID( )
              Processed       = wa_irn-Processed
              NoOfOrder       = wa_irn-NoOfOrder
              OrderDate       = wa_irn-OrderDate
              Datavalidated   = wa_irn-Datavalidated
              Type            = 'Scraps'
          ) )
       MAPPED DATA(mapped)
       FAILED   DATA(failed)
       REPORTED DATA(reported).


   ENDMETHOD.

    METHOD generateForReciept.

     SELECT SINGLE FROM zcashroomcrtable
             FIELDS
             sum( glposted ) AS processed,
              COUNT( cno ) AS nooforder
               WHERE cdate = @curDate
               INTO @DATA(lv_actual).

     wa_irn-Processed = lv_actual-processed.
     wa_irn-NoOfOrder = lv_actual-nooforder.
     wa_irn-datavalidated = lv_actual-processed.
     wa_irn-OrderDate = curDate.

     MODIFY ENTITIES OF zr_invgrouped000 IN LOCAL MODE
       ENTITY ZrInvgrouped000
       CREATE FIELDS ( Processed NoOfOrder OrderDate Datavalidated Type )
       WITH VALUE #( (
              %cid = getCID( )
              Processed       = wa_irn-Processed
              NoOfOrder       = wa_irn-NoOfOrder
              OrderDate       = wa_irn-OrderDate
              Datavalidated   = wa_irn-Datavalidated
              Type            = 'Receipts'
          ) )
       MAPPED DATA(mapped)
       FAILED   DATA(failed)
       REPORTED DATA(reported).


   ENDMETHOD.


    METHOD generateForCRN.



     SELECT SINGLE FROM zdt_rplcrnote
             FIELDS
              COUNT( imno ) AS nooforder
               WHERE imdate = @curDate
               INTO @DATA(nooforder).

      SELECT SINGLE FROM zdt_rplcrnote
         FIELDS
          COUNT( imno ) AS nooforder
           WHERE imdate = @curDate and glposted = '1'
        INTO @DATA(processed).


     wa_irn-Processed = processed.
     wa_irn-NoOfOrder = nooforder.
     wa_irn-datavalidated = processed.
     wa_irn-OrderDate = curDate.



     MODIFY ENTITIES OF zr_invgrouped000 IN LOCAL MODE
       ENTITY ZrInvgrouped000
       CREATE FIELDS ( Processed NoOfOrder OrderDate Datavalidated Type )
       WITH VALUE #( (
              %cid = getCID( )
              Processed       = wa_irn-Processed
              NoOfOrder       = wa_irn-NoOfOrder
              OrderDate       = wa_irn-OrderDate
              Datavalidated   = wa_irn-Datavalidated
              Type            = 'Credit Notes'
          ) )
       MAPPED DATA(mapped)
       FAILED   DATA(failed)
       REPORTED DATA(reported).


   ENDMETHOD.

    METHOD generateForSales.

      SELECT FROM zinv_mst
              FIELDS reference_doc_del, comp_code, plant, imfyear, imno, imtype
                WHERE reference_doc_del NE ''
                AND reference_doc_invoice EQ ''
                INTO TABLE @DATA(lt_result1).

      LOOP AT lt_result1 INTO DATA(wa_irn1).
        DATA(del) = CONV string( wa_irn1-reference_doc_del ).
        UpdatedDoc( delivery = del doctype = 'Sales' ).
      ENDLOOP.



      SELECT SINGLE FROM zinv_mst
              FIELDS
               SUM( imnetamtro ) AS actualamount,
               SUM( invoiceamount ) AS billedamount,
               SUM( orderamount ) AS orderamount,
               CAST( SUM( po_processed  ) AS INT4 ) AS poCount,
               CAST( SUM( migo_processed ) AS INT4 ) AS migoCount,
               CAST( SUM( po_tobe_created ) AS INT4 ) AS po_tobe_created,
               COUNT( imno ) AS nooforder
                WHERE imdate = @curDate
                INTO @DATA(ls_actual).

      SELECT SINGLE FROM zinv_mst
         FIELDS
              COUNT( imno ) AS Datavalidated
                   WHERE imdate = @curDate AND datavalidated = '1'
                    INTO @DATA(ls_datavalidated).

      SELECT SINGLE FROM zinv_mst
      FIELDS COUNT( reference_doc_del ) AS delCount
      WHERE imdate = @curDate AND reference_doc_del NE ''
      INTO @DATA(ls_delcount).

      SELECT SINGLE FROM zinv_mst
      FIELDS COUNT( reference_doc ) AS orderCount
      WHERE imdate = @curDate AND reference_doc NE ''
      INTO @DATA(ls_ordercount).

      SELECT SINGLE FROM zinv_mst
      FIELDS COUNT( reference_doc_invoice ) AS invCount
      WHERE imdate = @curDate AND reference_doc_invoice NE ''
      INTO @DATA(ls_invcount).


      wa_irn-BilledAmount = ls_actual-billedamount.
      wa_irn-OrderBilled = ls_invcount.
      wa_irn-Processed = ls_invcount.
      wa_irn-OrderAmount = ls_actual-actualamount.
      wa_irn-NoOfOrder = ls_actual-nooforder.
      wa_irn-datavalidated = ls_datavalidated.
      wa_irn-OutboundCreated = ls_delcount.
      wa_irn-SOAmount = ls_actual-orderamount.
      wa_irn-SOCreated = ls_ordercount.
      wa_irn-POCreated = ls_actual-poCount.
      wa_irn-MiGoCreated = ls_actual-migoCount.
      wa_irn-potobecreated = ls_actual-po_tobe_created.
      wa_irn-OrderDate = curDate.



      MODIFY ENTITIES OF zr_invgrouped000 IN LOCAL MODE
        ENTITY ZrInvgrouped000
        CREATE FIELDS ( BilledAmount OrderBilled OrderAmount NoOfOrder OutboundCreated SOCreated SOAmount
                         OrderDate POCreated MiGoCreated Datavalidated Potobecreated Processed Type )
        WITH VALUE #( (
               %cid = getCID( )
               Billedamount    = wa_irn-BilledAmount
               OrderBilled     = wa_irn-OrderBilled
               OrderAmount     = wa_irn-OrderAmount
               NoOfOrder       = wa_irn-NoOfOrder
               OutboundCreated = wa_irn-OutboundCreated
               SOCreated       = wa_irn-SOCreated
               SOAmount        = wa_irn-SOAmount
               OrderDate       = wa_irn-OrderDate
               POCreated       = wa_irn-POCreated
               MiGoCreated     = wa_irn-MiGoCreated
               Datavalidated   = wa_irn-Datavalidated
               Potobecreated   = wa_irn-Potobecreated
               Processed       = wa_irn-Processed
               Type            = 'Sales'
           ) )
        MAPPED DATA(mapped)
        FAILED   DATA(failed)
        REPORTED DATA(reported).


    ENDMETHOD.

  METHOD getCID.
            TRY.
                cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
            CATCH cx_uuid_error.
                ASSERT 1 = 0.
            ENDTRY.
  ENDMETHOD.

ENDCLASS.
