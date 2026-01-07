CLASS zdel_act_variance_posting DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.

  DATA: item_comp TYPE zactdistlines-bukrs VALUE ''.
  DATA: item_plant TYPE zactdistlines-plantcode VALUE ''.
  DATA: item_date TYPE zactdistlines-declaredate VALUE '00000000'.
  DATA: item_dist_line TYPE zactdistlines-distlineno VALUE 0.
  DATA: header_comp TYPE zactivitydist-bukrs VALUE ''.
  DATA: header_plant TYPE zactivitydist-plantcode VALUE ''.
  DATA: header_date TYPE zactivitydist-declaredate VALUE '00000000'.
  DATA: check type i value 0.
ENDCLASS.



CLASS ZDEL_ACT_VARIANCE_POSTING IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*  delete from zrepmatbread.
*  delete from zmatvarbread.
   update zmaterialdistbrd set varianceclosed = 0 where declarecdate = '20250820'.
   update zmatdistlinesbrd set varianceposted = 0 where declarecdate = '20250820'.

    IF check = 1.
        UPDATE zactdistlines
        set varianceposted = 0
        where bukrs = @item_comp and plantcode = @item_plant and declaredate = @item_date and distlineno = @item_dist_line.
    ENDIF.

    IF check = 2.
        UPDATE zactdistlines
        set varianceposted = 1
        where bukrs = @item_comp and plantcode = @item_plant and declaredate = @item_date and distlineno = @item_dist_line.
    ENDIF.

    IF check = 3.
        UPDATE zactivitydist
        set varianceclosed = 0
        where bukrs = @header_comp and plantcode = @header_plant and declaredate = @header_date.
    ENDIF.

     IF check = 4.
        UPDATE zactivitydist
        set varianceclosed = 1
        where bukrs = @header_comp and plantcode = @header_plant and declaredate = @header_date.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
