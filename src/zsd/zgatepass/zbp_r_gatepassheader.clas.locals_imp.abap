CLASS LHC_ZR_GATEPASSHEADER DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrGatepassheader
        RESULT result,
    earlynumbering_gph FOR NUMBERING
      IMPORTING entities FOR CREATE ZrGatepassheader,
    earlynumbering_gpl FOR NUMBERING
      IMPORTING entities FOR CREATE ZrGatepassheader\_GatePassLine.





ENDCLASS.

CLASS LHC_ZR_GATEPASSHEADER IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

    METHOD earlynumbering_gpl.
    READ ENTITIES OF zr_gatepassheader IN LOCAL MODE
      ENTITY ZrGatepassheader BY \_GatePassLine
        FIELDS ( PassLineNo )
          WITH CORRESPONDING #( entities )
          RESULT DATA(gate_entry_lines)
        FAILED failed.


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<gate_entry_header>).
      " get highest item from lines
      DATA(max_item_id) = REDUCE #( INIT max = CONV posnr( '000000' )
                                    FOR gate_entry_line IN gate_entry_lines USING KEY entity WHERE ( GatePass = <gate_entry_header>-GatePass )
                                    NEXT max = COND posnr( WHEN gate_entry_line-PassLineNo > max
                                                           THEN gate_entry_line-PassLineNo
                                                           ELSE max )
                                  ).
    ENDLOOP.

    "assign Gate Entry Item id
    LOOP AT <gate_entry_header>-%target ASSIGNING FIELD-SYMBOL(<gate_entry_line>).
      APPEND CORRESPONDING #( <gate_entry_line> ) TO mapped-zrgatepassline ASSIGNING FIELD-SYMBOL(<mapped_gate_entry_line>).
      IF <gate_entry_line>-PassLineNo IS INITIAL.
        max_item_id += 10.
        <mapped_gate_entry_line>-PassLineNo = max_item_id.
      ENDIF.


    ENDLOOP.
  ENDMETHOD.


  METHOD earlynumbering_gph.


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<gate_entry_header>).


    DATA: currentYear  TYPE string,
          currentMonth TYPE string,
          numYear      TYPE N LENGTH 4.


      currentYear  = <gate_entry_header>-EntryDate+0(4).
      currentMonth = <gate_entry_header>-EntryDate+4(2).
      numYear = currentYear.
      IF currentMonth >= '04'.  " April (04) to December (12)
        numYear = numYear.
      ELSE.
        numYear = numYear - 1.
      ENDIF.

      DATA: nr_number     TYPE cl_numberrange_runtime=>nr_number.
      TRY.

        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr = '10'
            toyear      = numyear
            object      = 'ZGATEPASS'
          IMPORTING
            number      = DATA(nextnumber)
        ).
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        numYear = numYear.
      ENDTRY.
      SHIFT nextnumber LEFT DELETING LEADING '0'.
    ENDLOOP.

    "assign Gate Entry no.
    APPEND CORRESPONDING #( <gate_entry_header> ) TO mapped-zrgatepassheader ASSIGNING FIELD-SYMBOL(<mapped_gate_entry_header>).
    IF <gate_entry_header>-GatePass IS INITIAL.
      <mapped_gate_entry_header>-GatePass = |{ <gate_entry_header>-plant }-{ nextnumber }|.
    ENDIF.


  ENDMETHOD.


ENDCLASS.
