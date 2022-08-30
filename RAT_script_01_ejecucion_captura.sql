-- Procedimento de Ejemplo Captura  RAT 
-- author: Felipe Donoso, felipe.donoso@oracle.com
-- creacion: 2016-09-22

-- creacion de directorio y privilegios
!mkdir 	/u01/capture_database
DROP DIRECTORY capture_database;
-- es buena idea generar un directorio con el nombre de la BD y fecha yyyymmdd
CREATE OR REPLACE DIRECTORY CAPTURE_DATABASE  as '/u02/Rat/nombre_de_BD_con_fecha____yyyymmdd';
grant all on directory  capture_database  to  public; 


-- Creacion de filtros
-- How to Create Filters for Either a Capture or Replay with Real Application Testing (RAT) (Doc ID 2285287.1)
-- Ejemplo:
-- BEGIN
--   DBMS_WORKLOAD_CAPTURE.ADD_FILTER  (
--   fname            => 'USER_XXXXXXX'      ,
--   fattribute       => 'USER'            ,
--   fvalue           => 'XXXXXXX'           );
--END;
--/
exec DBMS_WORKLOAD_CAPTURE.add_filter(fname=>'NO_DBSNMP', fattribute => 'USER', fvalue=>'DBSNMP') ;
exec DBMS_WORKLOAD_CAPTURE.add_filter(fname=>'NO_SYSTEM', fattribute => 'USER', fvalue=>'SYSTEM') ;
exec DBMS_WORKLOAD_CAPTURE.add_filter(fname=>'NO_SYS', fattribute => 'USER', fvalue=>'SYS') ;


-- generar un snapshot awr para La Base de datos
execute  dbms_workload_repository.create_snapshot();  


-- iniciar la captura de la BD con los filtros de usuarios a no capturar (INCLUDE).
-- aqui la captura quedara corriendo indefinidamente a no ser que se usa la opcion subsiguiente:
BEGIN
	   DBMS_WORKLOAD_CAPTURE.START_CAPTURE
	   (name=>'CAPTURE_RAT_DATABASE'
	   ,dir=> 'CAPTURE_DATABASE'
	   ,default_action=>'INCLUDE'
      );
END;
/

-- https://docs.oracle.com/database/121/ARPLS/d_workload_capture.htm#ARPLS69065
-- Optional input to specify the duration (in seconds) for which the workload needs to be captured. DEFAULT is NULL which means that workload capture continues until the user executes DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE.
BEGIN
	   DBMS_WORKLOAD_CAPTURE.START_CAPTURE
	   (name=>'CAPTURE_RAT_DATABASE'
	   ,dir=> 'CAPTURE_DATABASE'
	   ,default_action=>'INCLUDE'
     ,duration=>21600 -- se expresa en segundos, por ejemplo 6 horas serian 21600 segundos
      );
END;
/



-- scripts de ejemplo para simular carga en caso de ser necesario
-- para verificar la creacion de los archivos de captura
/* 
sqlplus "rat_test/rat_test" <<EOF
CREATE TABLE rat_test.rat_test_table01 (
  num           NUMBER,
  text  VARCHAR2(100)
) tablespace users ;
BEGIN
  FOR x IN 1 .. 200000 LOOP
    INSERT INTO rat_test.rat_test_table01 (num, text)
    VALUES (x, 'rat test number: ' || x);
  END LOOP;
  COMMIT;
END;
/
select * from rat_test.rat_test_table01  where num in (11,100,10000,30000,150000,190000) ;
exit;
EOF
--sleep 5 min para dejar pasar tiempo del otro snapshot
execute  dbms_workload_repository.create_snapshot();  
*/



-- Monitoreo de Captura
set linesize 300
COL NAME FOR A22 
COL DIRECTORY FOR A15
SELECT name,id,directory,status,start_time,duration_secs/3600,capture_size,filters_used,user_calls  FROM DBA_WORKLOAD_CAPTURES;
	


-- Finalizacion de captura luego de capturar por una 2 o 3 horas
BEGIN
	DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE     ;
END;
/


-- Generacion de snapshot final awr
execute  dbms_workload_repository.create_snapshot();  

-- continuar con el script siguiente de post captura.

	

