CLASS zcl_summary_so DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SUMMARY_SO IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

  IF io_request->is_data_requested( ).
       DATA: lt_response    TYPE TABLE OF zdd_sumary_so,
               ls_response    LIKE LINE OF lt_response,
               lt_responseout LIKE lt_response,
               ls_responseout LIKE LINE OF lt_responseout,
               lt_response1 like lt_response.

        DATA : qty_diff type p decimals 3 LENGTH 15,
               inv_diff type p decimals 2 LENGTH 15.

        DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
        DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
        DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

        DATA(lt_parameters)  = io_request->get_parameters( ).
        DATA(lt_fileds)  = io_request->get_requested_elements( ).
        DATA(lt_sort)          = io_request->get_sort_elements( ).

        TRY.
            DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
            CLEAR lt_Filter_cond.
        ENDTRY.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
         IF ls_filter_cond-name = to_upper( 'so' ).
          DATA(lt_so) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'so_item' ).
          DATA(lt_soitem) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'plant' ).
          DATA(lt_plant) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'dc' ).
          DATA(lt_dc) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'status' ).
          DATA(lt_status) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'bp' ).
          DATA(lt_bp) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'bp_name' ).
          DATA(lt_bpname) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'mat' ).
          DATA(lt_mat) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'mat_desc' ).
          DATA(lt_matdesc) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = to_upper( 'o_date' ).
          DATA(lt_date) = ls_filter_cond-range[].
         ENDIF.
      ENDLOOP.

        IF lt_mat IS NOT INITIAL.
          LOOP AT lt_mat INTO DATA(wa_mat).

            DATA : var2 TYPE c length 18.

            IF wa_mat-low IS NOT INITIAL.
              var2 = wa_mat-low.
              wa_mat-low = |{ var2 ALPHA = IN }|.
            ENDIF.

            IF wa_mat-high IS NOT INITIAL.
              CLEAR var2.
              var2 = wa_mat-high .
              wa_mat-high  = |{ var2 ALPHA = IN }|.
            ENDIF.
            MODIFY lt_mat FROM wa_mat.
            clear : wa_mat.
          ENDLOOP.
     ENDIF.

     IF lt_bp IS NOT INITIAL.
          LOOP AT lt_bp INTO DATA(wa_cust).

            DATA : var3 TYPE c length 10.

            IF wa_cust-low IS NOT INITIAL.
              var3 = wa_cust-low.
              wa_cust-low = |{ var3 ALPHA = IN }|.
            ENDIF.

            IF wa_cust-high IS NOT INITIAL.
              CLEAR var3.
              var3 = wa_cust-high .
              wa_cust-high  = |{ var3 ALPHA = IN }|.
            ENDIF.
            MODIFY lt_bp FROM wa_cust.
            clear : wa_cust.
          ENDLOOP.
     ENDIF.


     IF lt_so IS NOT INITIAL.
          LOOP AT lt_so INTO DATA(wa_so).

            DATA : var1 TYPE c length 10.

            IF wa_so-low IS NOT INITIAL.
              var1 = wa_so-low.
              wa_so-low = |{ var1 ALPHA = IN }|.
            ENDIF.

            IF wa_so-high IS NOT INITIAL.
              CLEAR var1.
              var1 = wa_so-high .
              wa_so-high  = |{ var1 ALPHA = IN }|.
            ENDIF.
            MODIFY lt_so FROM wa_so.
            clear : wa_so.
          ENDLOOP.
     ENDIF.

      IF lt_soitem IS NOT INITIAL.
          LOOP AT lt_soitem INTO DATA(wa_soi).

            DATA : var4 TYPE c length 6.

            IF wa_soi-low IS NOT INITIAL.
              var4 = wa_soi-low.
              wa_soi-low = |{ var4 ALPHA = IN }|.
            ENDIF.

            IF wa_soi-high IS NOT INITIAL.
              CLEAR var4.
              var4 = wa_soi-high .
              wa_soi-high  = |{ var4 ALPHA = IN }|.
            ENDIF.
            MODIFY lt_soitem FROM wa_soi.
            clear : wa_soi.
          ENDLOOP.
     ENDIF.

    Select from I_SalesDocument as a
    left join I_SalesDocumentItem as b on a~SalesDocument = b~SalesDocument
    left join I_CreditBlockedSalesDocument as g on a~SalesDocument = g~SalesDocument
    left join I_customer as c on b~BillToParty = c~Customer
    left join I_RegionText as d on c~Region = d~Region and c~Country = d~Country  and d~Language = 'E'
    left join I_ProductText as e on b~Material = e~Product and e~Language = 'E'
    fields a~SalesDocument,a~DistributionChannel,b~SalesDocumentItem,b~plant,a~CreationDate,a~CreationTime,b~BillToParty,c~CustomerName,
    d~RegionName,b~Material,a~PurchaseOrderByCustomer,e~ProductName,b~OrderQuantity,b~NetAmount,
    g~SalesDocument as credit
    where a~SalesDocument in @lt_so and b~SalesDocumentItem in @lt_soitem and b~Plant in @lt_plant and a~DistributionChannel in @lt_dc and
    b~BillToParty in @lt_bp and c~CustomerName in @lt_bpname and b~Material in @lt_mat and e~ProductName in @lt_matdesc and a~CreationDate in @lt_date
    into table @data(it).

     select from I_SalesDocumentItem as a
     left join I_deliverydocumentitem as j on j~ReferenceSDDocument = a~SalesDocument and j~ReferenceSDDocumentItem = a~SalesDocumentItem
      and j~DeliveryDocumentItemCategory eq 'TAN'
     left join I_DeliveryDocument as i on j~DeliveryDocument = i~DeliveryDocument
     left join I_BillingDocumentItem as f on a~SalesDocument = f~SalesDocument and a~SalesDocumentItem = f~SalesDocumentItem
     and f~SalesDocumentItemCategory eq 'TAN'
     left join I_BillingDocument as h on f~BillingDocument = h~BillingDocument
     fields f~BillingQuantityInBaseUnit,f~NetAmount as inv_val,  f~BillingDocument,f~BillingDocumentItem,h~BillingDocumentType,a~SalesDocument,a~SalesDocumentItem,
     a~Material,h~BillingDocumentIsCancelled,j~ReferenceSDDocument,f~SalesDocument as bill_sd,a~OrderQuantity,h~BillingDocumentDate,i~DeliveryDate
      where a~SalesDocument in @lt_so and a~SalesDocumentItem in @lt_soitem and h~BillingDocumentIsCancelled ne 'X' and h~BillingDocumentType ne 'S1'
      and h~BillingDocumentType ne 'F8'
      into table @data(it2).

      sort it2 by SalesDocument SalesDocumentItem  BillingDocument BillingDocumentItem.
      DELETE ADJACENT DUPLICATES FROM it2 COMPARING SalesDocument SalesDocumentItem  BillingDocument BillingDocumentItem.

***********************************del pgi inv status changes***********


     select from I_SalesDocumentItem as a
     left join I_deliverydocumentitem as j on j~ReferenceSDDocument = a~SalesDocument and j~ReferenceSDDocumentItem = a~SalesDocumentItem
      and j~DeliveryDocumentItemCategory eq 'TAN'
     left join I_DeliveryDocument as i on j~DeliveryDocument = i~DeliveryDocument
     fields a~SalesDocument,a~SalesDocumentItem,
     a~Material,j~ReferenceSDDocument,a~OrderQuantity,j~CreationDate,j~CreationTime,
     j~DeliveryDocument,j~DeliveryDocumentItem,j~ActualDeliveryQuantity,i~OverallGoodsMovementStatus,i~ActualGoodsMovementDate,i~ActualGoodsMovementTime
      where a~SalesDocument in @lt_so and a~SalesDocumentItem in @lt_soitem
      into table @data(it3).

     sort it3 by SalesDocument SalesDocumentItem CreationDate CreationTime ActualGoodsMovementDate ActualGoodsMovementTime .

************************************************************************

         TYPES: BEGIN OF ty_collect,
             so        TYPE zdd_sumary_so-so,
             so_item   TYPE zdd_sumary_so-so_item,
             mat       TYPE zdd_sumary_so-mat,
             inv_qty   TYPE zdd_sumary_so-inv_qty,
             inv_val   TYPE zdd_sumary_so-inv_val,
           END OF ty_collect.

    DATA: lt_collect TYPE STANDARD TABLE OF ty_collect  WITH NON-UNIQUE KEY so so_item mat ,
          ls_collect TYPE ty_collect.

    LOOP AT it2 INTO DATA(wa1).
      ls_collect-so        = wa1-SalesDocument.
      ls_collect-so_item   = wa1-SalesDocumentItem.
      ls_collect-mat       = wa1-Material.
      ls_collect-inv_qty   = wa1-BillingQuantityInBaseUnit.
      ls_collect-inv_val   = wa1-inv_val.
      COLLECT ls_collect INTO lt_collect.
    ENDLOOP.


    TYPES: BEGIN OF ty_collect1,
             so        TYPE zdd_sumary_so-so,
             inv_qty   TYPE zdd_sumary_so-inv_qty,
             inv_val   TYPE zdd_sumary_so-inv_val,
             order_qty TYPE zdd_sumary_so-o_qty,
           END OF ty_collect1.


      DATA: lt_collect_stat TYPE SORTED TABLE OF ty_collect1  WITH UNIQUE KEY so,
          ls_collect_stat TYPE ty_collect1.

*    LOOP AT it2 INTO DATA(wa_status).
*      ls_collect_stat-so        = wa_status-SalesDocument.
*      ls_collect_stat-inv_qty   = wa_status-BillingQuantityInBaseUnit.
*      ls_collect_stat-inv_val   = wa_status-inv_val.
*      ls_collect_stat-order_qty = wa_status-OrderQuantity.
**      ls_collect_stat-order_qty = wa_soqty-OrderQuantity.
*      COLLECT ls_collect_stat INTO lt_collect_stat.
*    ENDLOOP.


    LOOP AT it INTO DATA(wa_soqty).
      read table it2 into data(wa_status) with key SalesDocument = wa_soqty-SalesDocument SalesDocumentItem = wa_soqty-SalesDocumentItem Material = wa_soqty-Material.
      ls_collect_stat-so        = wa_soqty-SalesDocument.
      ls_collect_stat-inv_qty   = wa_status-BillingQuantityInBaseUnit.
      ls_collect_stat-inv_val   = wa_status-inv_val.
      ls_collect_stat-order_qty = wa_soqty-OrderQuantity.
      COLLECT ls_collect_stat INTO lt_collect_stat.
      clear : wa_status,wa_soqty.
    ENDLOOP.

    Loop at it into data(wa).
*      select single from I_DeliveryDocumentItem as a
*      left join I_DeliveryDocument as b on a~DeliveryDocument = b~DeliveryDocument
*       fields b~OverallGoodsMovementStatus,a~DeliveryDocument,a~ReferenceSDDocument
*       where a~ReferenceSDDocument = @wa-SalesDocument and a~ReferenceSDDocumentItem = @wa-SalesDocumentItem
*       into @data(pgi_check).

     ls_response-plant = wa-Plant.
     ls_response-dc = wa-DistributionChannel.
     ls_response-so = wa-SalesDocument.
     ls_response-o_date = wa-CreationDate.
     ls_response-o_time = wa-CreationTime.
     ls_response-so_item = wa-SalesDocumentItem.
     ls_response-bp = wa-BillToParty.
     ls_response-bp_name = wa-CustomerName.
     ls_response-state = wa-RegionName.
     ls_response-cust_ref = wa-PurchaseOrderByCustomer.
     ls_response-mat = wa-Material.
     ls_response-mat_desc = wa-ProductName.
     ls_response-o_qty = wa-OrderQuantity.
     ls_response-o_value = wa-NetAmount.
     READ TABLE lt_collect INTO DATA(wa2) WITH KEY so = wa-SalesDocument
           so_item = wa-SalesDocumentItem
           mat = wa-Material.

       IF sy-subrc = 0.
        ls_response-inv_qty = wa2-inv_qty.
        ls_response-inv_val = wa2-inv_val.
      ENDIF.

      qty_diff = wa-OrderQuantity - ls_response-inv_qty.
      inv_diff = wa-NetAmount - ls_response-inv_val.

      ls_response-qty_diff = qty_diff.
      ls_response-val_diff = inv_diff.

*     read table it2 into data(wa_stat) with key SalesDocument = wa-SalesDocument SalesDocumentItem = wa-SalesDocumentItem.

*          IF wa_stat-bill_sd is not initial.
*           ls_response-inv = 'YES'.
*          Else.
*           ls_response-inv = 'NO'.
*          ENDIF.
*    If pgi_check-OverallGoodsMovementStatus = 'C'.
*          ls_response-pgi = 'YES'.
*          ELSE.
*          ls_response-pgi = 'NO'.
*          ENDIF.
*
*          If pgi_check-ReferenceSDDocument is initial.
*           ls_response-del = 'NO'.
*          ELSE.
*           ls_response-del = 'YES'.
*          ENDIF.

*      loop at it3 into data(wa3) where SalesDocument = wa-SalesDocument and SalesDocumentItem = wa-SalesDocumentItem and OverallGoodsMovementStatus = 'A'.
*         if wa3-OverallGoodsMovementStatus = 'C'.
*            ls_response-pgi = 'YES'.
*          ELSEif wa3-OverallGoodsMovementStatus = 'A'.
*           ls_response-pgi = 'NO'.
*         endif.
*         if wa3-DeliveryDocument is initial.
*           ls_response-del = 'NO'.
*         else .
*         ls_response-del = 'YES'.
*         ENDIF.
*       clear : wa3.
*      ENDLOOP.
   read table it3 into data(wa3) with key  SalesDocument = wa-SalesDocument  SalesDocumentItem = wa-SalesDocumentItem  OverallGoodsMovementStatus = 'A'.

      if wa3 is INITIAL.
        ls_response-pgi = 'YES'.
      ELSE.
        ls_response-pgi = 'NO'.
      ENDIF.

     read table it3 into data(wa4) with key  SalesDocument = wa-SalesDocument  SalesDocumentItem = wa-SalesDocumentItem.

      if wa4-DeliveryDocument is INITIAL.
        ls_response-del = 'NO'.
      ELSE.
        ls_response-del = 'YES'.
      ENDIF.

      IF ls_response-qty_diff = 0.
           ls_response-inv = 'YES'.
      Else.
           ls_response-inv = 'NO'.
       ENDIF.

       read table lt_collect_stat into data(del_status) with key so = wa-SalesDocument.

       IF del_status-inv_qty IS INITIAL OR del_status-inv_qty = 0.
          ls_response-status = 'Open Order'.
        ELSEIF del_status-inv_qty - del_status-order_qty = 0.
          ls_response-status = 'Fully Delivered'.
        ELSE.
          ls_response-status = 'Short Supply'.
       ENDIF.

*      IF ls_response-inv_qty IS INITIAL.
*        ls_response-status = 'Open Order'.
*      ELSEIF wa2-inv_qty is not INITIAL and qty_diff = 0.
*        ls_response-status = 'Fully Delivered'.
*      ELSE.
*        ls_response-status = 'Short Supply'.
*      ENDIF.

      IF wa-credit IS INITIAL.
        ls_response-fin = 'YES'.
      ELSE.
        ls_response-fin = 'NO'.
      ENDIF.

     append ls_response TO lt_response.
     clear : wa,ls_response,qty_diff,inv_diff,wa2,wa3,wa4.
    ENDLOOP.

    IF lt_status IS NOT INITIAL.
      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<ls_response1>).
        IF <ls_response1>-status IN lt_status.
          APPEND <ls_response1> TO lt_response1.
        ENDIF.
      ENDLOOP.
    ELSE.
      lt_response1 = lt_response.
    ENDIF.

     lv_max_rows = lv_skip + lv_top.
     IF lv_skip > 0.
       lv_skip = lv_skip + 1.
     ENDIF.

     CLEAR lt_responseout.

     sort lt_response1 by so so_item.

      LOOP AT lt_sort INTO DATA(ls_sort).
            CASE ls_sort-element_name.
              WHEN 'SO'.
                SORT lt_response1 BY  so ASCENDING.
                IF ls_sort-descending = abap_true.
                  SORT lt_response1 BY so DESCENDING.
                ENDIF.
              WHEN 'SO_ITEM'.
                SORT lt_response1 BY  so_item ASCENDING.
                IF ls_sort-descending = abap_true.
                  SORT lt_response1 BY  so_item DESCENDING.
                ENDIF.
              WHEN 'O_DATE'.
                SORT lt_response1 BY o_date ASCENDING.
                IF ls_sort-descending = abap_true.
                  SORT lt_response1 BY o_date DESCENDING.
                ENDIF.
               WHEN 'BP'.
                SORT lt_response1 BY bp ASCENDING.
                IF ls_sort-descending = abap_true.
                  SORT lt_response1 BY bp DESCENDING.
                ENDIF.
               WHEN 'O_TIME'.
                SORT lt_response1 BY o_time ASCENDING.
                IF ls_sort-descending = abap_true.
                  SORT lt_response1 BY o_time DESCENDING.
                ENDIF.
             ENDCASE.
        ENDLOOP.


     Loop at lt_response1 ASSIGNING FIELD-SYMBOL(<wa_res>).
       shift <wa_res>-bp LEFT DELETING LEADING '0'.
       shift <wa_res>-mat LEFT DELETING LEADING '0'.
       shift <wa_res>-so LEFT DELETING LEADING '0'.
       shift <wa_res>-so_item LEFT DELETING LEADING '0'.
     ENDLOOP.
*     sort lt_response1 by so so_item BillingDocument BillingDocumentItem.
*     DELETE ADJACENT DUPLICATES FROM lt_response1 COMPARING so so_item BillingDocument BillingDocumentItem.

     LOOP AT lt_response1 ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
       ls_responseout = <lfs_out_line_item>.
       append ls_responseout TO lt_responseout.
     ENDLOOP.

     io_response->set_total_number_of_records( lines( lt_response1 ) ).
     io_response->set_data( lt_responseout ).
   ENDIF.
  ENDMETHOD.
ENDCLASS.
