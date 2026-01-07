CLASS zcl_test1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEST1 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main..

    DATA: it_final TYPE TABLE OF zbillinglines.
    DATA: wa_final TYPE zbillinglines.
    DATA: lv_bill1 TYPE zbillinglines-BILLNO.
    DATA: lv_bill2 TYPE zbillinglines-billno.
    DATA: lv_comp TYPE zbillinglines-companycode.
    DATA: lv_fiscal TYPE zbillinglines-fiscalyearvalue.
    DATA: lv_line TYPE zbillinglines-lineitemno.
*  data: lv_typebill type zbillinglines-billingtype.
*  lv_typebill = '0000'.
    lv_bill1 = '0000000000'.
    lv_bill2 = '0000000000'.
    lv_fiscal = '0000'.
    lv_comp = '0000'.
    lv_line = '0000'.

*    DELETE FROM zbillingLINES WHERE companycode EQ 'HOVL'.
*    DELETE FROM zbillingproc WHERE BUKRS EQ 'HOVL'.
delete from zbillinglines where invoice eq @lv_bill1.
delete from zbillingproc where billingdocument eq @lv_bill1.

*    DELETE FROM zbillinglines WHERE invoice IS NOT INITIAL.
*     delete from zbillingproc where billingdocument = @lv_bill1.
*     delete from zbillinglines where invoice = @lv_bill1.

*    IF  lv_bill1 IS NOT INITIAL AND lv_bill2 IS NOT INITIAL.
*      SELECT * FROM zbillinglines
**      FIELDS companycode, invoice, lineitemno, fiscalyearvalue, customerponumber, billno
*      WHERE companycode = @lv_comp AND billno BETWEEN @lv_bill1 AND @lv_bill2 AND fiscalyearvalue = @lv_fiscal
*      INTO CORRESPONDING FIELDS OF TABLE @it_final.
*    ELSE.
*      SELECT * FROM zbillinglines
**      FIELDS companycode, invoice, lineitemno, fiscalyearvalue, customerponumber
*      WHERE companycode = @lv_comp AND billno = @lv_bill1 AND fiscalyearvalue = @lv_fiscal
*      INTO CORRESPONDING FIELDS OF TABLE @it_final.
*    ENDIF.
*
*    LOOP AT it_final INTO wa_final.
*
*      DATA(lv_len) = strlen( wa_final-customerponumber ).
*
*      IF wa_final-billingtype = 'F2'.
*        IF lv_len GE 8.
*          lv_len = lv_len - 8.
*          wa_final-billno = wa_final-customerponumber+lv_len(8).
*        ELSE.
*          wa_final-billno = wa_final-customerponumber.
*        ENDIF.
*
*      ELSEIF wa_final-billingtype = 'CBRE'.
*        IF lv_len GE 9.
*          lv_len = lv_len - 9.
*          wa_final-billno = wa_final-customerponumber+lv_len(9).
*        ELSE.
*          wa_final-billno = wa_final-customerponumber.
*        ENDIF.
*
*      ENDIF.
*
*
*      MODIFY zbillinglines FROM @wa_final.
*      CLEAR: wa_final.
*    ENDLOOP..




  ENDMETHOD.
ENDCLASS.
