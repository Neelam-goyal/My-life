CLASS zcl_savestockvalue DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .
    CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
    METHODS runJob.
    METHODS insertStartTime
      IMPORTING
        start_time  TYPE t
        start_date  TYPE d
        from_at_ist TYPE string
        to_at_ist   TYPE string.
    METHODS convertIST
      IMPORTING
        sdate          TYPE d
        stime          TYPE t
      RETURNING
        VALUE(ist_str) TYPE string.
    METHODS convertUTC
      IMPORTING
        sdate          TYPE d
        stime          TYPE t
      RETURNING
        VALUE(utc_str) TYPE string.
      METHODS convertTstmp
      IMPORTING
        sdate          TYPE d
        stime          TYPE t
      RETURNING
        VALUE(ist_str) TYPE string.
     METHODS convertISTSeparate
      IMPORTING
        sdate          TYPE d
        stime          TYPE t
      EXPORTING
        VALUE(idate) TYPE d
        VALUE(itime) TYPE t.

    METHODS updateEndTime
      IMPORTING
        start_time TYPE t
        start_date TYPE d.
PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SAVESTOCKVALUE IMPLEMENTATION.


  METHOD convertIST.

    DATA timestamp TYPE timestampl.
    timestamp = sdate && stime.

    CALL METHOD cl_abap_tstmp=>add
      EXPORTING
        tstmp   = timestamp
        secs    = 19800 " 5 hours 30 minutes in seconds
      RECEIVING
        r_tstmp = timestamp.

    CALL METHOD cl_abap_tstmp=>tstmp2utclong
      EXPORTING
        timestamp = timestamp
      RECEIVING
        utclong   = ist_str.

  ENDMETHOD.


  METHOD convertISTSeparate.

    DATA: timestamp   TYPE timestampl,
          timestp_str TYPE string.
    timestamp = sdate && stime.

    CALL METHOD cl_abap_tstmp=>add
      EXPORTING
        tstmp   = timestamp
        secs    = 19800 " 5 hours 30 minutes in seconds
      RECEIVING
        r_tstmp = timestamp.

    timestp_str = timestamp.

    idate = timestp_str+0(8). " Extracting date part
    itime = timestp_str+8(6). " Extracting time part
  ENDMETHOD.


  METHOD convertTstmp.

    DATA timestamp TYPE timestampl.
    timestamp = sdate && stime.

    CALL METHOD cl_abap_tstmp=>tstmp2utclong
      EXPORTING
        timestamp = timestamp
      RECEIVING
        utclong   = ist_str.
  ENDMETHOD.


  METHOD convertUTC.

    DATA timestamp TYPE timestampl.
    timestamp = sdate && stime.

    CALL METHOD cl_abap_tstmp=>subtractsecs
      EXPORTING
        tstmp   = timestamp
        secs    = 19800 " 5 hours 30 minutes in seconds
      RECEIVING
        r_tstmp = utc_str.
  ENDMETHOD.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'My ID'                                      changeable_ind = abap_true )
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'My Description'   lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     datatype = 'I' length = 10 param_text = 'My Count'                                   changeable_ind = abap_true )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length =  1 param_text = 'Full Processing' checkbox_ind = abap_true  changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '4711' )
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'My Default Description' )
      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = '200' )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = abap_false )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    runJob(  ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    runJob( ).
  ENDMETHOD.


  METHOD insertStartTime.

    MODIFY ENTITIES OF zr_batchlog
      ENTITY ZrBatchLog
      CREATE FIELDS (
          BatchJobName
          StartDate
          StartTime
          FromAtUtc
          ToAtUtc
      )
      WITH VALUE #(
        ( %cid = getCID( )
          BatchJobName = 'Save Stock Value'
          StartDate = start_date
          StartTime = start_time
          FromAtUtc = from_at_ist
          ToAtUtc = to_at_ist
         ) )
          MAPPED DATA(fs_mapped)
          FAILED DATA(fs_failed)
          REPORTED DATA(fs_report).
    COMMIT ENTITIES BEGIN
        RESPONSE OF zr_batchlog
        FAILED DATA(ls_save_failed)
        REPORTED DATA(ls_save_reported).
    ...
    COMMIT ENTITIES END.
  ENDMETHOD.


  METHOD runJob.

    DATA: from_time TYPE t,
          to_time   TYPE t,
          from_date TYPE d,
          to_date   TYPE d.

*     query to select
    SELECT FROM I_StockQuantityCurrentValue_2( P_DisplayCurrency = 'INR' ) AS Stock
        INNER JOIN I_ProductText AS _Text ON _Text~Product = Stock~Product AND _Text~Language = 'E'
        INNER JOIN I_product AS Product ON Product~Product = Stock~Product
        INNER JOIN ztable_plant AS Plant ON Plant~plant_code = Stock~Plant
        LEFT JOIN I_ProductValuationBasic AS ProductValuation
          ON ProductValuation~Product = Stock~Product AND ProductValuation~ValuationArea = Stock~Plant
        FIELDS Stock~Plant, Stock~Product, Stock~Batch, Stock~StorageLocation, Stock~ProductType, _Text~ProductName, Stock~MaterialBaseUnit, Plant~plant_name1,
                SUM( Stock~MatlWrhsStkQtyInMatlBaseUnit ) AS StockQty
        WHERE Stock~ValuationAreaType = '1'
              AND (
                    ( product~ProductType = 'ZFRT' AND ProductValuation~ValuationClass = '7920' )
                    OR  product~ProductType IN ('ZNVM', 'ZWST')
                   )
              AND plant~integrationenabled = 'X'
        GROUP BY Stock~Plant, Stock~Product, Stock~Batch, Stock~StorageLocation, Stock~ProductType, _Text~ProductName, Stock~MaterialBaseUnit, Plant~plant_name1
        INTO TABLE @DATA(result).

*   from time and to time selection
    SELECT SINGLE FROM zr_batchlog
       FIELDS MAX( startdate ) AS StartDate
       WHERE batchjobname = 'Save Stock Value'
       INTO @DATA(fs_batchlog_date).

    IF fs_batchlog_date IS INITIAL.
      from_date = '20010101'. " Default start date
      from_time = '000000'.   " Default start time
    ELSE.
      from_date = fs_batchlog_date.

      SELECT SINGLE FROM zr_batchlog
        FIELDS MAX( StartTime ) AS StartTime
        WHERE BatchJobName = 'Save Stock Value'
          AND StartDate = @from_date
        INTO @DATA(fs_batchlog_time).

      from_time = fs_batchlog_time.
    ENDIF.

    to_date = cl_abap_context_info=>get_system_date( ).
    to_time = cl_abap_context_info=>get_system_time( ).


*    get IST date and time for insertion
    CALL METHOD convertISTSeparate
      EXPORTING
        sdate = to_date
        stime = to_time
      IMPORTING
        idate = DATA(to_date_ist)
        itime = DATA(to_time_ist).


*   get from date & time and to date & time in IST format
    DATA(from_at) = converttstmp( sdate = from_date stime = from_time ). " as from date & time in IST
    DATA(to_at) = convertist( sdate = to_date stime = to_time ).

*    get time time in utc
    DATA(from_at_utc) = convertUTC( sdate = from_date stime = from_time ). " as from date & time in UTC
    DATA(to_at_utc) = to_date && to_time.

*   Inserting start date &time in batch log
    insertstarttime( start_time = to_time_ist start_date = to_date_ist from_at_ist = from_at to_at_ist = to_at ).

*   Inserting into Log Table
    LOOP AT result INTO DATA(fs_result).

      MODIFY ENTITIES OF zr_currentstocklog
      ENTITY zrcurrentstocklog
      CREATE FIELDS (
        Plant
        PlantName
        Product
        ProductName
        ProductType
        Batch
        StorageLocation
        InsertedDate
        InsertedTime
        MaterialBaseUnit
        MatlWrhsStkQtyInMatlBaseUnit
      )
      WITH VALUE #(
        (
          %cid = getCID( )
          Plant = fs_result-Plant
          PlantName = fs_result-plant_name1
          Product = fs_result-Product
          ProductName = fs_result-ProductName
          ProductType = fs_result-ProductType
          Batch = fs_result-Batch
          StorageLocation = fs_result-StorageLocation
          InsertedDate = to_date_ist
          InsertedTime = to_time_ist
          MaterialBaseUnit = fs_result-MaterialBaseUnit
          MatlWrhsStkQtyInMatlBaseUnit = fs_result-StockQty
        ) )
      MAPPED DATA(fs_mapped)
      FAILED DATA(fs_failed)
      REPORTED DATA(fs_report).

      COMMIT ENTITIES BEGIN
         RESPONSE OF zr_currentstock
         FAILED DATA(ls_save_failed)
         REPORTED DATA(ls_save_reported).
      ...
      COMMIT ENTITIES END.
    ENDLOOP.



*   Inserting Data into main Stock table
    SELECT FROM zr_currentstocklog
      FIELDS Plant, PlantName, Product, ProductName, ProductType, MaterialBaseUnit,
             SUM( MatlWrhsStkQtyInMatlBaseUnit ) AS MatlWrhsStkQtyInMatlBaseUnit
      WHERE InsertedDate = @to_date_ist AND InsertedTime = @to_time_ist
      GROUP BY Plant, PlantName, Product, ProductName, ProductType, MaterialBaseUnit
      INTO TABLE @DATA(lt_currentstocklog).



    LOOP AT lt_currentstocklog INTO DATA(fs_currentstocklog).

       SELECT SINGLE FROM zr_matdocitems AS a
        INNER JOIN zr_mvtmapper AS b ON a~GoodsMovementType = b~Movementtype
           FIELDS SUM( a~Quantity * b~Multiplier ) AS StockQty
            WHERE a~Plant = @fs_currentstocklog-Plant
            AND a~ProductCode = @fs_currentstocklog-Product
            AND a~orderid IS INITIAL
            AND a~GoodsMovementType IN ('101', '102' )
            AND a~CreatedAt BETWEEN @from_at AND @to_at
            INTO @DATA(purchase_stock_qty).

      SELECT SINGLE FROM zr_matdocitems AS a
         INNER JOIN zr_mvtmapper AS b ON a~GoodsMovementType = b~Movementtype
           FIELDS SUM( a~Quantity * b~Multiplier ) AS StockQty
           WHERE a~Plant = @fs_currentstocklog-Plant
            AND a~ProductCode = @fs_currentstocklog-Product
            AND a~orderid IS NOT INITIAL
            AND a~GoodsMovementType IN ('101', '102', '531', '532')
            AND a~CreatedAt BETWEEN @from_at AND @to_at
            INTO @DATA(prod_stock_qty).

      SELECT SINGLE FROM zr_matdocitems AS a
           INNER JOIN zr_mvtmapper AS b ON a~GoodsMovementType = b~Movementtype
           FIELDS SUM(
                        CASE
                            WHEN b~DebitCreditIndicator = 'X' AND a~DebitCreditCode = 'H' THEN a~Quantity * b~Multiplier
                            WHEN b~DebitCreditIndicator = 'X' AND a~DebitCreditCode = 'S' THEN a~Quantity * b~Multiplier * -1
                            ELSE a~Quantity * b~Multiplier
                        END
                     ) AS StockQty
            WHERE a~Plant = @fs_currentstocklog-Plant
            AND a~ProductCode = @fs_currentstocklog-Product
            AND a~GoodsMovementType NOT IN ('101', '102', '531', '532' )
            AND a~CreatedAt BETWEEN @from_at AND @to_at
            INTO @DATA(adjusted_stock_qty).


   SELECT SINGLE FROM zr_matdocitems AS a
           LEFT JOIN zr_mvtmapper AS b ON a~GoodsMovementType = b~Movementtype
           FIELDS SUM( a~Quantity ) AS StockQty
            WHERE a~Plant = @fs_currentstocklog-Plant
            AND a~ProductCode = @fs_currentstocklog-Product
            AND a~GoodsMovementType NOT IN ('101', '102', '531', '532' )
            AND b~Movementtype IS NULL
            AND a~CreatedAt BETWEEN @from_at AND @to_at
            INTO @DATA(new_adjusted_stock_qty).

      SELECT SINGLE FROM zr_salesmatdocitems
          FIELDS SUM( Quantity ) AS StockQty
           WHERE Plant = @fs_currentstocklog-Plant
           AND ProductCode = @fs_currentstocklog-Product
           AND CreatedAt BETWEEN @from_at AND @to_at
           AND GoodsMovementType IN ( '601', '641', '647','654' )
           INTO @DATA(sales_stock_qty).


      SELECT SINGLE FROM zr_salesmatdocitems
           FIELDS SUM( Quantity ) AS StockQty
            WHERE Plant = @fs_currentstocklog-Plant
            AND ProductCode = @fs_currentstocklog-Product
            AND CreatedAt BETWEEN @from_at AND @to_at
            AND GoodsMovementType IN ( '602', '642', '648','653' )
            INTO @DATA(sales_return_stock_qty).

*     unposted qty
      SELECT SINGLE FROM zc_usdatadata1 AS a
          INNER JOIN zc_usdatamst AS b ON a~CompCode = b~CompCode AND a~Plant = b~Plant
                                            AND a~Idfyear = b~Imfyear AND a~Idtype = b~Imtype AND a~Idno = b~Imno
          FIELDS SUM( a~Idprdqty  ) AS UnPostedQty
          WHERE a~plant = @fs_currentstocklog-Plant
            AND a~idprdcode = @fs_currentstocklog-Product
            AND b~CreatedAt BETWEEN @from_at_utc AND @to_at_utc
            AND (
                b~ReferenceDocDel IS INITIAL
                OR NOT EXISTS (
                    SELECT DeliveryDocument AS ReferenceDocDel FROM i_materialdocumentitem_2 AS c
                    WHERE c~deliverydocument = b~ReferenceDocDel
                      AND c~material = a~Idprdcode
                 )
              )
          INTO @DATA(unsold_unposted_qty).

      SELECT SINGLE FROM zc_invoicedatatab1000 AS a
      INNER JOIN zc_inv_mst000 AS b ON b~CompCode = a~CompCode AND b~Plant = a~Plant
                                       AND a~Idfyear = b~Imfyear AND a~Idtype = b~Imtype AND a~Idno = b~Imno
      FIELDS SUM( a~Idprdqty ) AS UnPostedQty
      WHERE a~plant = @fs_currentstocklog-Plant
          AND a~idprdcode = @fs_currentstocklog-Product
          AND b~CreatedAt BETWEEN @from_at_utc AND @to_at_utc
          AND (
                b~ReferenceDocDel IS INITIAL
                OR NOT EXISTS (
                    SELECT DeliveryDocument AS ReferenceDocDel FROM i_materialdocumentitem_2 AS c
                    WHERE c~deliverydocument = b~ReferenceDocDel
                      AND c~material = a~Idprdcode
                 )
              )
      INTO @DATA(unposted_sales_qty).


      "    for last closing stock
      SELECT SINGLE FROM zc_usdatadata1 AS a
         INNER JOIN zc_usdatamst AS b ON a~CompCode = b~CompCode AND a~Plant = b~Plant
                                        AND a~Idfyear = b~Imfyear AND a~Idtype = b~Imtype AND a~Idno = b~Imno
         FIELDS SUM( a~Idprdqty  ) AS UnPostedQty
         WHERE a~plant = @fs_currentstocklog-Plant
           AND a~idprdcode = @fs_currentstocklog-Product
           AND (
                b~ReferenceDocDel IS INITIAL
                OR NOT EXISTS (
                    SELECT DeliveryDocument AS ReferenceDocDel FROM i_materialdocumentitem_2 AS c
                    WHERE c~deliverydocument = b~ReferenceDocDel
                      AND c~material = a~Idprdcode
                 )
              )
         INTO @DATA(unsold_upto_qty).

      SELECT SINGLE FROM zc_invoicedatatab1000 AS a
          INNER JOIN zc_inv_mst000 AS b ON b~CompCode = a~CompCode AND b~Plant = a~Plant
                                            AND a~Idfyear = b~Imfyear AND a~Idtype = b~Imtype AND a~Idno = b~Imno
          FIELDS SUM( a~Idprdqty ) AS UnPostedQty
          WHERE a~plant = @fs_currentstocklog-Plant
              AND a~idprdcode = @fs_currentstocklog-Product
              AND (
                b~ReferenceDocDel IS INITIAL
                OR NOT EXISTS (
                    SELECT DeliveryDocument AS ReferenceDocDel FROM i_materialdocumentitem_2 AS c
                    WHERE c~deliverydocument = b~ReferenceDocDel
                      AND c~material = a~Idprdcode
                 )
              )
          INTO @DATA(upto_sales_qty).

*     Get Last Closing Stock will become this day opening stock
      SELECT SINGLE FROM zr_currentstocklog
          FIELDS SUM( MatlWrhsStkQtyInMatlBaseUnit ) AS MatlWrhsStkQtyInMatlBaseUnit
            WHERE Plant = @fs_currentstocklog-Plant
            AND Product = @fs_currentstocklog-Product
            AND InsertedDate = @from_date
            AND InsertedTime = @from_time
            INTO @DATA(last_clos_new_open_stock).

      MODIFY ENTITIES OF zr_currentstock
      ENTITY ZrCurrentstock
      CREATE FIELDS (
        Plant
        PlantName
        Product
        ProductName
        ProductType
        InsertedDate
        InsertedTime
        MaterialBaseUnit
        OpeningStock
        ProductionStock
        PostedStock
        PostedReturnStock
        PurchaseStock
        UnpostedInvStock
        UnpostedUnsoldStock
        AdjustmentStock
        CalculateStock
        MatlWrhsStkQtyInMatlBaseUnit
        UnpostedUpto
        AdjustedMvtStock
      )
      WITH VALUE #(
        (
          %cid = getCID( )
          Plant = fs_currentstocklog-Plant
          PlantName = fs_currentstocklog-PlantName
          Product = fs_currentstocklog-Product
          ProductName = fs_currentstocklog-ProductName
          ProductType = fs_currentstocklog-ProductType
          InsertedDate = to_date_ist
          InsertedTime = to_time_ist
          MaterialBaseUnit = fs_currentstocklog-MaterialBaseUnit
*         last closing stock will become this day opening stock
          OpeningStock = last_clos_new_open_stock
          ProductionStock = prod_stock_qty
          PostedStock = sales_stock_qty
          PostedReturnStock = sales_return_stock_qty
          PurchaseStock = purchase_stock_qty
          UnpostedInvStock = unposted_sales_qty
          UnpostedUnsoldStock = unsold_unposted_qty
          AdjustmentStock = adjusted_stock_qty + new_adjusted_stock_qty
          CalculateStock = ( last_clos_new_open_stock
                                + prod_stock_qty
                                + purchase_stock_qty
                                + sales_return_stock_qty
                                + unsold_unposted_qty )
                                - (
                                    sales_stock_qty
                                    + unposted_sales_qty
                                    + adjusted_stock_qty + new_adjusted_stock_qty
                                  )
          MatlWrhsStkQtyInMatlBaseUnit = fs_currentstocklog-MatlWrhsStkQtyInMatlBaseUnit
          UnpostedUpto = ( unsold_upto_qty - upto_sales_qty )
          AdjustedMvtStock = new_adjusted_stock_qty
        ) )
      MAPPED DATA(fs_mapped1)
      FAILED DATA(fs_failed1)
      REPORTED DATA(fs_report1).

      COMMIT ENTITIES BEGIN
         RESPONSE OF zr_currentstock
         FAILED DATA(ls_save_failed1)
         REPORTED DATA(ls_save_reported1).
      ...
      COMMIT ENTITIES END.
    ENDLOOP.



*   updating end time in batch log
    updateEndTime( start_time = to_time_ist start_date = to_date_ist ).

  ENDMETHOD.


  METHOD updateEndTime.

    DATA(end_time) = cl_abap_context_info=>get_system_time( ).
    end_time = end_time + 19800. " Adding 5 hours 30 minutes in seconds

    SELECT FROM zr_batchlog
     FIELDS BatchJobName, StartDate, StartTime
    WHERE BatchJobName = 'Save Stock Value'
      AND StartDate = @start_date and StartTime = @start_time
      INTO TABLE @DATA(lt_batchlog).

    MODIFY ENTITIES OF zr_batchlog
    ENTITY ZrBatchLog
    UPDATE FIELDS ( EndTime )
    WITH VALUE #(
    FOR wa IN lt_batchlog (
        BatchJobName = wa-BatchJobName
        StartDate = wa-StartDate
        StartTime = wa-StartTime
        EndTime = end_time ) )
    MAPPED DATA(fs_mapped)
    FAILED DATA(fs_failed)
    REPORTED DATA(fs_report).

    COMMIT ENTITIES BEGIN
        RESPONSE OF zr_batchlog
        FAILED DATA(ls_save_failed)
        REPORTED DATA(ls_save_reported).
    ...
    COMMIT ENTITIES END.


  ENDMETHOD.
ENDCLASS.
