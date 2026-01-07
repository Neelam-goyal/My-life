CLASS zbanktestclass DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .


  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZBANKTESTCLASS IMPLEMENTATION.


    METHOD if_oo_adt_classrun~main.

       delete from zbrstable where accountcode = ''.
       UPDATE zbankpayable set Vutacode = '23100020' where uniqtraccode = 'N100076DT45919A21120011A210001'.
       UPDATE zbankpayable set Vutacode = '23100020' where uniqtraccode = 'I100074DT45919A21120013ACVPP02'.
       UPDATE zbankpayable set Vutacode = '23100020' where uniqtraccode = 'I100075DT45919A21120013ACVPP02'.

*      DATA(filename) = ''.
*      IF filename IS NOT INITIAL.
*        DELETE FROM zbankpayable WHERE uploadfilename = @filename.
*      ENDIF.
*
*      SELECT FROM zbankpayable
*      FIELDS vutdate, unit, vutacode, createdtime, instructionrefnum
*      WHERE uploadfilename = @filename
*      INTO TABLE @DATA(lt_bankpayable).
*
*      LOOP AT lt_bankpayable INTO DATA(ls_bankpayable).
*        DATA(updateddate) = zcl_http_bankpayable=>convertdate( CONV i( ls_bankpayable-vutdate ) ).
*
*        UPDATE zbankpayable SET vutdate = @updateddate
*        WHERE vutdate = @ls_bankpayable-vutdate
*             AND unit = @ls_bankpayable-unit
*             AND vutacode = @ls_bankpayable-vutacode
*             AND createdtime = @ls_bankpayable-createdtime
*             AND instructionrefnum = @ls_bankpayable-instructionrefnum.
*      ENDLOOP.



    ENDMETHOD.
ENDCLASS.
