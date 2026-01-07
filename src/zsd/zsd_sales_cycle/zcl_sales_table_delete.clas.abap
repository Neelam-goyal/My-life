CLASS zcl_sales_table_delete DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: lv_imno TYPE zinv_mst-imno VALUE ''.
    DATA: lv_imno1 TYPE zinv_mst-imno VALUE ''.
    DATA: lv_idno TYPE zdt_usdatamst1-imno VALUE ''.
    DATA: lv_idno1 TYPE zdt_usdatamst1-imno VALUE ''.
    DATA: lv_date1 TYPE zinv_mst-imdate VALUE '00000000'.
    DATA: lv_date2 TYPE zinv_mst-imdate VALUE '00000000'.
    DATA: check TYPE i VALUE '0'.

ENDCLASS.



CLASS ZCL_SALES_TABLE_DELETE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.



    IF check = 1.
      UPDATE zinv_mst
      SET processed = '',
      reference_doc = '',
      reference_doc_del = '',
      status = '',
      datavalidated = 0,
      error_log = ''
      WHERE imno GE @lv_imno AND imno LE @lv_imno1.

    ELSEIF check = 2 .
      UPDATE zdt_usdatamst1
      SET processed = '',
      reference_doc = '',
      reference_doc_del = '',
      status = '',
      datavalidated = 0,
      error_log = ''
      WHERE imno GE @lv_idno AND imno LE @lv_idno1 .

    ELSEIF check = 3.

      UPDATE zinvoicedatatab1
      SET processed = '',
      error_log = ''
      WHERE idno GE @lv_imno AND idno LE @lv_imno1.

    ELSEIF check = 4.

      UPDATE zdt_usdatadata1
      SET processed = '',
      error_log = ''
      WHERE idno GE @lv_idno AND idno LE @lv_idno1.

    ELSEIF check = 5.
      DELETE FROM zinvoicedatatab1 WHERE idno GE @lv_imno AND idno LE @lv_imno1 AND idprdcode = '000000001400000030'.


    ELSEIF check = 6.
      DELETE FROM zdt_usdatadata1 WHERE idno GE @lv_idno AND idno LE @lv_idno1  AND idprdcode = '000000001400000030'.


    ELSEIF check = 7.
      DELETE FROM zinv_mst WHERE imno GE @lv_idno AND imno LE @lv_idno1.

    ELSEIF check = 8.
      DELETE FROM  zinvoicedatatab1 WHERE idno GE @lv_idno AND idno LE @lv_idno1.

    ELSEIF check = 9.
      DELETE FROM zinv_mst WHERE imno EQ @lv_idno.


    ELSEIF check = 10.
      DELETE FROM  zinvoicedatatab1 WHERE idno EQ @lv_imno.

    ELSEIF check = 11.
      UPDATE zinv_mst
       SET
       reference_doc_invoice = '',
       invoiceamount = ''
       WHERE imno EQ @lv_imno.

    ELSEIF check = 12.
      DELETE FROM zinvoicedatatab1 WHERE idno EQ @lv_imno AND idprdcode = '000000001400000023'.

    ELSEIF check = 13.
      DELETE FROM zinvoicedatatab1 WHERE idno EQ @lv_imno AND idprdcode = '000000001400000030'.

    ELSEIF check = 14.
      DELETE FROM zinvoicedatatab1 WHERE idno EQ @lv_imno AND idprdcode = '000000001400000031'.

    ELSEIF check = 15.
      UPDATE zinv_mst
       SET
       reference_doc_del  = ''
       WHERE imno EQ @lv_imno.

    ELSEIF check = 16.
      DELETE FROM zinv_mst WHERE datavalidated = '2'.

    ELSEIF check = 17.
      DELETE FROM zinv_mst WHERE datavalidated = '1' AND reference_doc IS INITIAL AND imdate GE @lv_date1 AND imdate LE @lv_date2.

    ELSEIF check = 18.
      UPDATE zinv_mst
       SET
       po_no = '',
       po_processed = 0,
       error_log = ''
       WHERE imno EQ @lv_imno.

    ELSEIF check = 19.
      UPDATE zinv_mst
       SET
       migo_processed = 0,
       migo_no = '',
       error_log = ''
       WHERE imno EQ @lv_imno.

     elseif check = 20.
       DELETE FROM zinv_mst WHERE comp_code is initial.
       Delete from zinvoicedatatab1 where comp_code is INITIAL.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
