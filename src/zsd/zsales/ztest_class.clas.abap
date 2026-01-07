CLASS ztest_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    CLASS-METHODS updatebulk.
    class-METHODS deletebulk.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_CLASS IMPLEMENTATION.


  METHOD deletebulk.
  delete from zdt_rplcrnote
  WHERE  imno in ( 'LDB000020', 'LDB000015' ) and implant eq 'BN02'.

  ENDMETHOD.


  METHOD updatebulk.


      UPDATE zinvoicedatatab1 SET scrap_prd = 'S1' WHERE idno IN ( 'S-015953',
'JK022376',
'JK022457',
'JK022533',
'JK022602',
'JK022672',
'JK022757',
'JK022895',
'JK022900',
'KT000874',
'KT000889',
'KT000909',
'KT000945',
'KT000960',
'KT000999',
'KT001000',
'KT001019',
'KT001033',
'PK900119',
'PK900120',
'PK900121',
'PK900122',
'PK900123',
'PK900124',
'PK900125',
'PK900126',
'PK900127',
'PK900128'  )
  AND idprdcode IN ( '000000001400000051',
  '000000001600000023',
  '000000001600000022' ).


  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    deletebulk(  ).


    DATA bulkupdate TYPE c LENGTH 1 VALUE ''.

    IF bulkupdate = 'X'.
      updatebulk(  ).
      RETURN.
    ENDIF.

*    DELETE FROM zrplcrnotev2.

    DATA: ls_rplcrnote TYPE zdt_rplcrnote,
          lt_rplcrnote TYPE STANDARD TABLE OF zdt_rplcrnote,
          gateentry    TYPE string,
          year         TYPE string,
          cgpnooo      TYPE string.



    DATA(migo) = '5000006958'.
    DATA imno TYPE string.
    DATA(purchaseorder) = '3000000084'.
    DATA(update_line) = ''.
    DATA cgpno TYPE string.
    DATA gateEntryy TYPE string.
    DATA scrapbill TYPE string.
    IF update_line = 'X'.
      UPDATE zinv_mst SET migo_processed = 1, migo_no = @migo, error_log = ''
                WHERE po_no = @purchaseorder.
    ENDIF.



    DATA(plant) = '1000'.
    DATA(from_date) = '20231001'.
    DATA(to_date) = '20231031'.



*****MIRO UPDATE *****
    DATA: updatemiro TYPE c LENGTH 1 VALUE ''.
    CASE updatemiro.
      WHEN 'X'.

        UPDATE zinv_mst
          SET miro_processed = 1
          WHERE imdate BETWEEN @from_date AND @to_date
            AND po_no IS NOT INITIAL.

      WHEN 'Y'.
        UPDATE zinv_mst
          SET miro_processed = 1
          WHERE plant = @plant
            AND po_no IS NOT INITIAL.

      WHEN 'W'.
        UPDATE zinv_mst
          SET miro_processed = 1
          WHERE plant  = @plant
            AND imdate BETWEEN @from_date AND @to_date
            AND po_no  IS NOT INITIAL.

    ENDCASE.
    IF sy-subrc <> 0.
      " Handle error (e.g., no records found to update)
    ENDIF.





    DATA(update_po) = ''.
    IF update_po = 'X'.
      UPDATE zinv_mst SET po_tobe_created = 2
      WHERE plant = @plant AND imdate BETWEEN @from_date AND @to_date AND po_tobe_created = 1 AND po_no = ''.

    ELSEIF update_po = 'E'.
      UPDATE zinv_mst SET po_tobe_created = 2
  WHERE plant = @plant AND imno = @imno ."AND po_tobe_created = 1.

    ELSEIF update_po = 'V'.
      UPDATE zinv_mst SET gate_entry_no = '' , error_log = ''
  WHERE plant = @plant AND imno = @imno ."AND po_tobe_created = 1.

    ELSEIF update_po = 'L'.
      UPDATE zinv_mst SET gate_entry_no = @gateentry , error_log = ''
  WHERE plant = @plant AND imno = @imno ."AND po_tobe_created = 1.

    ELSEIF update_po = 'P'.
      DELETE FROM zcashroomcrtable WHERE  plant = @plant AND cfyear = @year AND cgpno = @cgpnooo .

    ELSEIF update_po = 'J'.
      DELETE FROM zcustcontrolsht WHERE  plant = @plant AND imfyear = @year AND gate_entry_no = @cgpnooo .

    ELSEIF update_po = 'M'.
      UPDATE zinv_mst SET scrapbill = @scrapbill
  WHERE plant = @plant AND imno = @imno .
    ENDIF.

    DATA(reverse_po) = ''.
    DATA(Chashroom) = ''.
    DATA(cust) = ''.
    IF reverse_po = 'X'.
      UPDATE zinv_mst SET po_tobe_created = 1
      WHERE plant = @plant AND imdate BETWEEN @from_date AND @to_date.
    ENDIF.

    DATA(salesCycle) = ''.

    IF salesCycle = 'X'.

      IF update_po = 'Z'.

        DATA clear_option TYPE i VALUE 0.

        CASE clear_option.

          WHEN 1.
            UPDATE zinv_mst
              SET reference_doc_invoice = ''
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 2.
            UPDATE zinv_mst
              SET invoiceamount = 0
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 3.
            UPDATE zinv_mst
              SET reference_doc_del = ''
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 4.
            UPDATE zinv_mst
              SET orderamount = 0
              WHERE imno  = @imno
                AND plant = @plant.


          WHEN 5.
            UPDATE zinv_mst
              SET reference_doc = ''
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 6.
            UPDATE zinv_mst
              SET processed = ''
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 7.
            UPDATE zinv_mst
              SET po_processed = ''
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 8.
            UPDATE zinv_mst
              SET po_no = ''
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 9.
            UPDATE zinv_mst
              SET migo_no = '', migo_processed = ''
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 10.
            UPDATE zinv_mst
              SET gate_entry_no = ''
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 11.
            UPDATE zcontrolsheet
              SET reference_doc = ''
              , glposted = ''
              ,cdate = '20251111'
              WHERE gate_entry_no  = @gateEntryy.

          WHEN 12.
            UPDATE zcashroomcrtable
              SET reference_doc = '', glposted = '', camt = '18000'
              WHERE cgpno  = @cgpno AND plant = @plant.


        ENDCASE.

      ENDIF.


    ELSE.

      IF update_po = 'P'.

        DATA Returnclear TYPE i VALUE 0.

        CASE Returnclear.

          WHEN 1.
            UPDATE zdt_usdatamst1
              SET reference_doc_invoice = ''
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 2.
            UPDATE zdt_usdatamst1
              SET invoiceamount = 0
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 3.
            UPDATE zdt_usdatamst1
              SET reference_doc_del = ''
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 4.
            UPDATE zdt_usdatamst1
              SET orderamount = 0
              WHERE imno  = @imno
                AND plant = @plant.


          WHEN 5.
            UPDATE zdt_usdatamst1
              SET reference_doc = ''
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 6.
            UPDATE zdt_usdatamst1
              SET processed = ''
              WHERE imno  = @imno
                AND plant = @plant.

          WHEN 7.

            UPDATE  zdt_usdatamst1
            SET
             reference_doc = '', processed = ''
                , reference_doc_del = ''
                WHERE imno  = @imno
                  AND plant = @plant.

            UPDATE zdt_usdatadata1
        SET
         idprdrate = '', idtotaldiscamount = ''
            , idtcsamt = '' , idtxbamt = '', idprdamt = ''
            WHERE idno  = @imno
              AND plant = @plant.

          WHEN 8.
            UPDATE zcashroomcrtable
            SET  glposted = '', reference_doc = ''
             WHERE ccmpcode = 'BNPL'.


          WHEN 9.
            UPDATE zinv_mst
            SET migo_no = '5000000800'
            WHERE imno = 'LD901713'.

          WHEN 10.
            UPDATE zinv_mst
            SET comp_code = ''
            WHERE imno = '009840'.

            UPDATE zinvoicedatatab1
            SET comp_code = ''
            WHERE idno = '009840'.





        ENDCASE.

      ENDIF.



    ENDIF.

    DATA :chashroom_po TYPE string.
    IF chashroom_po = 'biut'.

*        data plantchasroom type string.
      DATA cashroom TYPE i VALUE 0.

      CASE cashroom.

        WHEN 4.
          UPDATE zcashroomcrtable
       SET reference_doc = '',
           glposted      = ''
       WHERE plant = 'BN06'
         AND cgpno IN (
    '07516',
    '07514' ).


      ENDCASE.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
