CLASS LHC_ZR_repmatbread DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Zrrepmatbread
        RESULT result.

     METHODS recalculate FOR MODIFY
      IMPORTING keys FOR ACTION zrrepmatbread~recalculate.


ENDCLASS.

CLASS LHC_ZR_repmatbread IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD recalculate.

    READ ENTITIES OF zr_repmatbread IN LOCAL MODE
    ENTITY zrrepmatbread
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(entities).


    LOOP AT entities INTO DATA(ety).

        SELECT SINGLE FROM ZR_matdistlinesbrd
          FIELDS SUM( Varianceqty ) AS Varianceqty
          WHERE Varianceposted = 1
            AND Productcode = @ety-Material
            AND Plantcode = @ety-Plant
            AND Declarecdate BETWEEN @ety-Rangedate AND @ety-Todate
          INTO @DATA(var_qty).

*      DATA prdcode TYPE c LENGTH 18.
*      prdcode = |{ ety-Material ALPHA = IN }|.
*
*
*      SELECT SINGLE FROM i_mfgorderconfmatldocitem AS e
*      INNER JOIN ZR_matdistlinesbrd AS a ON a~Plantcode = e~Plant
*                                           AND a~Productionorder = e~ManufacturingOrder
*                                           AND a~varianceqty = (  CASE
*                                                                   WHEN e~GoodsMovementType = '261' THEN e~QuantityInEntryUnit
*                                                                   WHEN e~GoodsMovementType = '262' THEN e~QuantityInEntryUnit * -1
*                                                                   ELSE 0
*                                                                   END )
*      FIELDS SUM( CASE
*                   WHEN e~GoodsMovementType = '261' THEN e~QuantityInEntryUnit
*                   WHEN e~GoodsMovementType = '262' THEN e~QuantityInEntryUnit * -1
*                   ELSE 0
*                   END ) AS QuantityInEntryUnit WHERE e~GoodsMovementType IN ( '261', '262' )
*      AND e~Plant = @ety-Plant AND a~Productcode = @ety-material AND e~Material = @prdcode
*      AND a~Declarecdate BETWEEN @ety-Rangedate AND @ety-Todate
*      AND e~IsReversed = ''
*      INTO @DATA(var_qty) PRIVILEGED ACCESS.

      MODIFY ENTITIES OF zr_repmatbread IN LOCAL MODE
      ENTITY zrrepmatbread
      UPDATE FIELDS ( VarPosted )
      WITH VALUE #( (
                VarPosted = var_qty
                %pky = ety-%pky
      ) ).

    ENDLOOP.

  ENDMETHOD.


ENDCLASS.
