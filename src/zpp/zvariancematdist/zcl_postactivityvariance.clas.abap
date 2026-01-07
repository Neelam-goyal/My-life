CLASS zcl_postactivityvariance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .

    CLASS-METHODS getDate
      IMPORTING datestr TYPE string
      RETURNING VALUE(result) TYPE d.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_POSTACTIVITYVARIANCE IMPLEMENTATION.


   METHOD getDate.
    DATA: lv_date_str   TYPE string,
      lv_date       TYPE d,
      lv_internal   TYPE c length 8.


        " Extract the date part (DD/MM/YYYY)
        DATA(lv_date_part) = datestr(10).  " '27/03/2025'

        " Convert DD/MM/YYYY to YYYYMMDD
        DATA: lv_day   TYPE c length 2,
              lv_month TYPE c length 2,
              lv_year  TYPE c length 4.

        lv_day   = lv_date_part(2).
        lv_month = lv_date_part+3(2).
        lv_year  = lv_date_part+6(4).

        CONCATENATE lv_year lv_month lv_day INTO result.

  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Post Activity Variance'   lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'P_DATE'  kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 10 param_text = 'Declaration Date'   lowercase_ind = abap_true changeable_ind = abap_true )
       ( selname = 'P_PLANT'  kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 4 param_text = 'Plant'   lowercase_ind = abap_true changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Post Activity Variance' )
      ( selname = 'P_DATE'  kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = cl_abap_context_info=>get_system_date( ) )

    ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    TYPES ty_id TYPE c LENGTH 10.

    DATA s_id    TYPE RANGE OF ty_id.
    DATA p_descr TYPE c LENGTH 80.
    DATA p_count TYPE i.
    DATA p_simul TYPE abap_boolean.
    DATA processfrom TYPE d.

    DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
    DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
    DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA: template  TYPE cl_apj_rt_api=>ty_template_name.
    DATA: p_date TYPE d.
    DATA: p_plant type c length 4.

    LOOP AT it_parameters INTO DATA(wa_parameter).
      CASE wa_parameter-selname.
        WHEN 'P_DATE'.
          p_date = getdate( CONV string( wa_parameter-low ) ).
        WHEN 'P_PLANT'  .
         p_plant =  wa_parameter-low.
      ENDCASE.
    ENDLOOP.

    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvariance' ##NO_TEXT.

    DATA prodorderdate TYPE datum.
    DATA plantno TYPE char05.
    DATA companycode TYPE char05.
    DATA productdesc TYPE char72.
    DATA productcode TYPE char72.

    DATA lt_confirmation TYPE TABLE FOR CREATE i_productionordconfirmationtp.
    DATA lt_matldocitm TYPE TABLE FOR CREATE i_productionordconfirmationtp\_prodnordconfmatldocitm.
    DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlines.


    FIELD-SYMBOLS <ls_matldocitm> LIKE LINE OF lt_matldocitm.
    DATA lt_target LIKE <ls_matldocitm>-%target.


    "Activity Variance Posting
    IF p_date IS INITIAL.
      SELECT FROM zactivitydist
          FIELDS bukrs, plantcode, declaredate
          WHERE variancecalculated = 1 AND varianceposted = 1 AND varianceclosed = 0
          INTO TABLE @DATA(activitydistline).
    ELSE.
      SELECT FROM zactivitydist
          FIELDS bukrs, plantcode, declaredate
          WHERE variancecalculated = 1 AND varianceposted = 1 AND varianceclosed = 0
                AND declaredate = @p_date and plantcode = @p_plant
          INTO TABLE @activitydistline.
    ENDIF.

    LOOP AT activitydistline INTO DATA(waactdistline).
      companycode = waactdistline-Bukrs.
      plantno = waactdistline-Plantcode.
      prodorderdate = waactdistline-declaredate.

*      "changes one at a time***************************************************************
          SELECT FROM zactdistlines AS actdlines
          FIELDS productionorder, orderconfirmationgroup, shiftnumber, shiftgroup, distlineno, vlabour, vpower, vfuel, vrepair, voverheads
          WHERE actdlines~Bukrs = @companycode AND actdlines~plantcode = @plantno AND actdlines~declaredate = @prodorderdate
              AND ( actdlines~vfuel <> 0 OR actdlines~vlabour <> 0 OR actdlines~voverheads <> 0 OR actdlines~vpower <> 0 OR actdlines~vrepair <> 0 )
              AND actdlines~varianceposted = 0
              ORDER BY distlineno ASCENDING
              INTO TABLE @DATA(ltactdlinegrp)
                UP TO 1 ROWS.
****************************************************************************************

*      "Post Activity variance Entries thru Confirmation
*      SELECT FROM zactdistlines AS actdlines
*          FIELDS productionorder, orderconfirmationgroup, shiftnumber, shiftgroup, distlineno, vlabour, vpower, vfuel, vrepair, voverheads
*          WHERE actdlines~Bukrs = @companycode AND actdlines~plantcode = @plantno AND actdlines~declaredate = @prodorderdate
*              AND ( actdlines~vfuel <> 0 OR actdlines~vlabour <> 0 OR actdlines~voverheads <> 0 OR actdlines~vpower <> 0 OR actdlines~vrepair <> 0 )
*              AND actdlines~varianceposted = 0
*          INTO TABLE @DATA(ltactdlinegrp).

          sort ltactdlinegrp by distlineno.
      IF ltactdlinegrp IS NOT INITIAL.
        LOOP AT ltactdlinegrp INTO DATA(waactdlinegrp).

          "read proposals and corresponding times for given quantity
          READ ENTITIES OF i_productionordconfirmationtp
              ENTITY productionorderconfirmation
              EXECUTE getconfproposal
              FROM VALUE #( ( confirmationgroup = waactdlinegrp-orderconfirmationgroup
                  %param-confirmationyieldquantity = 1 ) )
          RESULT DATA(lt_confproposalact)
          FAILED DATA(lt_conf_failed)
          REPORTED DATA(lt_reported_confact).

          LOOP AT lt_confproposalact ASSIGNING FIELD-SYMBOL(<ls_confproposalact>).
            " convert proposals to confirmations with goodsmovement
            APPEND INITIAL LINE TO lt_confirmation ASSIGNING FIELD-SYMBOL(<ls_confirmationact>).
            <ls_confirmationact>-%cid = 'Conf' && sy-tabix.
            <ls_confirmationact>-%data = CORRESPONDING #( <ls_confproposalact>-%param ).
            <ls_confirmationact>-ConfirmationYieldQuantity = 0.
            <ls_confirmationact>-PostingDate = prodorderdate.
            <ls_confirmationact>-OpConfirmedWorkQuantity1 = waactdlinegrp-vlabour.
            <ls_confirmationact>-OpConfirmedWorkQuantity2 = waactdlinegrp-vpower.
            <ls_confirmationact>-OpConfirmedWorkQuantity3 = waactdlinegrp-vfuel.
            <ls_confirmationact>-OpConfirmedWorkQuantity4 = waactdlinegrp-vrepair.
            <ls_confirmationact>-OpConfirmedWorkQuantity5 = waactdlinegrp-voverheads.
            <ls_confirmationact>-OpConfirmedWorkQuantity6 = 0.
            <ls_confirmationact>-ShiftDefinition = waactdlinegrp-shiftnumber.
            <ls_confirmationact>-ShiftGrouping = waactdlinegrp-shiftgroup.

          ENDLOOP.

          MODIFY ENTITIES OF i_productionordconfirmationtp
              ENTITY productionorderconfirmation
              CREATE FROM lt_confirmation
          MAPPED DATA(lt_mappedact)
          FAILED DATA(lt_failedact)
          REPORTED DATA(lt_reportedact).

          COMMIT ENTITIES.

           IF lt_failedact is INITIAL.
          UPDATE zactdistlines
              SET varianceposted = 1
              WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| )
                    AND distlineno = @waactdlinegrp-distlineno.

          UPDATE zactdistlines
              SET varianceposted = 1
              WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| )
                    AND varianceposted = 0 AND vlabour = 0 AND vpower = 0 AND vfuel = 0 AND vrepair = 0 AND voverheads = 0.

          "Check for Day Close
          SELECT FROM zactdistlines AS actlines
              FIELDS productionorder
              WHERE Bukrs = @companycode AND plantcode = @plantno AND declaredate = @prodorderdate
                  AND varianceposted = 0
              INTO TABLE @DATA(ltactdlinecheck).
          IF ltactdlinecheck IS INITIAL.
            UPDATE zactivitydist
                SET varianceclosed = 1
                WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| ).
          ENDIF.
          ENDIF.

          CLEAR : lt_confproposalact, lt_confirmation, lt_matldocitm.
          CLEAR : lt_mappedact, lt_failedact, lt_reportedact.
          clear : ltactdlinecheck,lt_reported_confact,waactdlinegrp,lt_confproposalact.
        ENDLOOP.
      ENDIF.
        clear : ltactdlinegrp.
      clear : waactdistline.
    ENDLOOP.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    TYPES ty_id TYPE c LENGTH 10.

    DATA s_id    TYPE RANGE OF ty_id.
    DATA p_descr TYPE c LENGTH 80.
    DATA p_count TYPE i.
    DATA p_simul TYPE abap_boolean.
    DATA processfrom TYPE d.

    DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
    DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
    DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA: template  TYPE cl_apj_rt_api=>ty_template_name.
    DATA p_date TYPE d.
    DATA: p_plant type c length 4.

    data : dates type d,
           plants type c length 4.
    dates = cl_abap_context_info=>get_system_date( ).
    plants = 'BB02'.

    p_date = '20250312'.
    p_plant = plants.


    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_matvariance' ##NO_TEXT.

    DATA prodorderdate TYPE datum.
    DATA plantno TYPE char05.
    DATA companycode TYPE char05.
    DATA productdesc TYPE char72.
    DATA productcode TYPE char72.

    DATA lt_confirmation TYPE TABLE FOR CREATE i_productionordconfirmationtp.
    DATA lt_matldocitm TYPE TABLE FOR CREATE i_productionordconfirmationtp\_prodnordconfmatldocitm.
    DATA upd_matdistlinetab TYPE TABLE FOR UPDATE ZR_matdistlines.


    FIELD-SYMBOLS <ls_matldocitm> LIKE LINE OF lt_matldocitm.
    DATA lt_target LIKE <ls_matldocitm>-%target.

    "Activity Variance Posting
    IF p_date IS INITIAL.
      SELECT FROM zactivitydist
          FIELDS bukrs, plantcode, declaredate
          WHERE variancecalculated = 1 AND varianceposted = 1 AND varianceclosed = 0
          INTO TABLE @DATA(activitydistline).
    ELSE.
      SELECT FROM zactivitydist
          FIELDS bukrs, plantcode, declaredate
          WHERE variancecalculated = 1 AND varianceposted = 1 AND varianceclosed = 0
                AND declaredate = @p_date and plantcode = @p_plant
          INTO TABLE @activitydistline.
    ENDIF.

    LOOP AT activitydistline INTO DATA(waactdistline).
      companycode = waactdistline-Bukrs.
      plantno = waactdistline-Plantcode.
      prodorderdate = waactdistline-declaredate.

*      "changes one at a time***************************************************************
          SELECT FROM zactdistlines AS actdlines
          FIELDS productionorder, orderconfirmationgroup, shiftnumber, shiftgroup, distlineno, vlabour, vpower, vfuel, vrepair, voverheads
          WHERE actdlines~Bukrs = @companycode AND actdlines~plantcode = @plantno AND actdlines~declaredate = @prodorderdate
              AND ( actdlines~vfuel <> 0 OR actdlines~vlabour <> 0 OR actdlines~voverheads <> 0 OR actdlines~vpower <> 0 OR actdlines~vrepair <> 0 )
              AND actdlines~varianceposted = 0
              ORDER BY distlineno ASCENDING
              INTO TABLE @DATA(ltactdlinegrp)
                UP TO 1 ROWS.

****************************************************************************************

*      "Post Activity variance Entries thru Confirmation
*      SELECT FROM zactdistlines AS actdlines
*          FIELDS productionorder, orderconfirmationgroup, shiftnumber, shiftgroup, distlineno, vlabour, vpower, vfuel, vrepair, voverheads
*          WHERE actdlines~Bukrs = @companycode AND actdlines~plantcode = @plantno AND actdlines~declaredate = @prodorderdate
*              AND ( actdlines~vfuel <> 0 OR actdlines~vlabour <> 0 OR actdlines~voverheads <> 0 OR actdlines~vpower <> 0 OR actdlines~vrepair <> 0 )
*              AND actdlines~varianceposted = 0
*          INTO TABLE @DATA(ltactdlinegrp).

          sort ltactdlinegrp by distlineno.
      IF ltactdlinegrp IS NOT INITIAL.
        LOOP AT ltactdlinegrp INTO DATA(waactdlinegrp).

          "read proposals and corresponding times for given quantity
          READ ENTITIES OF i_productionordconfirmationtp
              ENTITY productionorderconfirmation
              EXECUTE getconfproposal
              FROM VALUE #( ( confirmationgroup = waactdlinegrp-orderconfirmationgroup
                  %param-confirmationyieldquantity = 1 ) )
          RESULT DATA(lt_confproposalact)
          FAILED DATA(lt_conf_failed)
          REPORTED DATA(lt_reported_confact).

          LOOP AT lt_confproposalact ASSIGNING FIELD-SYMBOL(<ls_confproposalact>).
            " convert proposals to confirmations with goodsmovement
            APPEND INITIAL LINE TO lt_confirmation ASSIGNING FIELD-SYMBOL(<ls_confirmationact>).
            <ls_confirmationact>-%cid = 'Conf' && sy-tabix.
            <ls_confirmationact>-%data = CORRESPONDING #( <ls_confproposalact>-%param ).
            <ls_confirmationact>-ConfirmationYieldQuantity = 0.
            <ls_confirmationact>-PostingDate = prodorderdate.
            <ls_confirmationact>-OpConfirmedWorkQuantity1 = waactdlinegrp-vlabour.
            <ls_confirmationact>-OpConfirmedWorkQuantity2 = waactdlinegrp-vpower.
            <ls_confirmationact>-OpConfirmedWorkQuantity3 = waactdlinegrp-vfuel.
            <ls_confirmationact>-OpConfirmedWorkQuantity4 = waactdlinegrp-vrepair.
            <ls_confirmationact>-OpConfirmedWorkQuantity5 = waactdlinegrp-voverheads.
            <ls_confirmationact>-OpConfirmedWorkQuantity6 = 0.
            <ls_confirmationact>-ShiftDefinition = waactdlinegrp-shiftnumber.
            <ls_confirmationact>-ShiftGrouping = waactdlinegrp-shiftgroup.

          ENDLOOP.

          MODIFY ENTITIES OF i_productionordconfirmationtp
              ENTITY productionorderconfirmation
              CREATE FROM lt_confirmation
          MAPPED DATA(lt_mappedact)
          FAILED DATA(lt_failedact)
          REPORTED DATA(lt_reportedact).

          COMMIT ENTITIES.

           IF lt_failedact is INITIAL.
          UPDATE zactdistlines
              SET varianceposted = 1
              WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| )
                    AND distlineno = @waactdlinegrp-distlineno.

          UPDATE zactdistlines
              SET varianceposted = 1
              WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| )
                    AND varianceposted = 0 AND vlabour = 0 AND vpower = 0 AND vfuel = 0 AND vrepair = 0 AND voverheads = 0.

          "Check for Day Close
          SELECT FROM zactdistlines AS actlines
              FIELDS productionorder
              WHERE Bukrs = @companycode AND plantcode = @plantno AND declaredate = @prodorderdate
                  AND varianceposted = 0
              INTO TABLE @DATA(ltactdlinecheck).
          IF ltactdlinecheck IS INITIAL.
            UPDATE zactivitydist
                SET varianceclosed = 1
                WHERE bukrs = @companycode AND plantcode = @plantno  AND declarecdate = @( |{ prodorderdate }| ).
          ENDIF.
          ENDIF.

          CLEAR : lt_confproposalact, lt_confirmation, lt_matldocitm.
          CLEAR : lt_mappedact, lt_failedact, lt_reportedact.
          clear : ltactdlinecheck,lt_reported_confact,waactdlinegrp,lt_confproposalact.
        ENDLOOP.
      ENDIF.
        clear : ltactdlinegrp.
      clear : waactdistline.
    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
