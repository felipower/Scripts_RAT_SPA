/*
************************************************************************************************************
* Pasos para el SPA y DBREPLAY
************************************************************************************************************
*/


/*
-- Esto se hizo para solucionar y ver que problema con las celdas habia en la anterior configuracion del exa anterior
-- no es necesario ahora
-- Habilitar el trace de SO segun lo solicitado por soporte antes del replay
On each node as root, 

/u01/app/19.0.0.0/grid/bin/crsctl modify type ora.cssd.type -attr "ATTRIBUTE=REBOOT_OPTS, TYPE=string, DEFAULT_VALUE=,FLAGS=CONFIG" -init -unsupported 
/u01/app/19.0.0.0/grid/bin/crsctl modify type ora.cssdmonitor.type -attr "ATTRIBUTE=REBOOT_OPTS, TYPE=string, DEFAULT_VALUE=,FLAGS=CONFIG" -init -unsupported 
/u01/app/19.0.0.0/grid/bin/crsctl modify res ora.cssd -attr "REBOOT_OPTS=CRASHDUMP" -init -unsupported 
/u01/app/19.0.0.0/grid/bin/crsctl modify res ora.cssdmonitor -attr "REBOOT_OPTS=CRASHDUMP" -init -unsupported
*/




-- importante para aplicar rat desde enterprise manager en caso de que se quisiese hacer todo por la interfaz de  cloud control
--EM 13c: Real Application Testing (RAT) Setup and Execution From Enterprise Manager (Doc ID 2741126.1)
Viewer: 'Database Replay Viewer Role' - Users who have the Database Replay Viewer role can view any Database Replay entity. By default, no Enterprise Manager user is granted this role. However, the EM_ALL_VIEWER role includes this role by default.

Operator: 'Database Replay Operator Role' - The Database Replay Operator role includes the Database Replay Viewer role and thus its privileges. Users who have the Database Replay Operator role can also edit and delete any Database Replay entity. By default, no Enterprise Manager user is granted this role. However, the EM_ALL_OPERATOR role includes this role by default.



-- Importante Levantar los siguientes servicios creados anteriormente sobre exacc destino
srvctl start service -d ERTXPR -s ERTXPRSRV
srvctl start service -d EBSCSPR -s EBSCSPRSRV



-- configurar para que los snap permanezcan harto tiempo
-- 1440 minutos = 1 dia  
-- para 2 meses: 92160 y cada 30 min
execute dbms_workload_repository.modify_snapshot_settings (interval => 15, retention => 92160);
commit;



-- Revisar los grupos de Redolog de las nuevas instancias 3 y 4
-- que no exista ningun redo creado en el group disk DATAC sino en RECOC
select * from GV$log 


-- Important please review that you have enough space on SYSTEM, SYSAUX and UNDO tablespace.
set lines 500 pages 0
col cmd format a120
select 'alter database datafile '''||file_name ||''' autoextend on next 100M ;'  cmd
from dba_data_files
where tablespace_name in ('SYSTEM','SYSAUX') or tablespace_name like '%UNDO%'


-- ejecutar esto en cada BD para evitar errores de snapshot to old
-- en las nuevas instancias 3 y 4 agregadas
-- 
alter tablespace UNDOTBS_03 add datafile size 1G autoextend on next 512M ;
alter tablespace UNDOTBS_03 add datafile size 1G autoextend on next 512M ;
alter tablespace UNDOTBS_03 add datafile size 1G autoextend on next 512M ;
alter tablespace UNDOTBS_04 add datafile size 1G autoextend on next 512M ;
alter tablespace UNDOTBS_04 add datafile size 1G autoextend on next 512M ;
alter tablespace UNDOTBS_04 add datafile size 1G autoextend on next 512M ;

-- esto es para evitar los errores de dbreplay es muy importante ya que 
-- en la preparacion y ejecucion de dbreplay se consume
-- mucho espacio en estas tablas internas de dbreplay que estan en sysaux
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;
alter tablespace sysaux add datafile size 1G autoextend on next 100M ;


-- Create user for test and review performance 
-- es solo por si no se puede usar el usuario SYS pero la password
-- esta en el archivo de usuarios/pass e ips de la carpeta de content
create user ocs_m2c identified by "OCS.ora1234" ;
grant create session, select any dictionary, dba to ocs_m2c ;
-- for change temporary pass of system:
-- guardar el valor de sparse4
/* SELECT password, spare4 FROM SYS.USER$ WHERE name ='SYSTEM' ; 

PASSWORD
--------------------------------------------------------------------------------
SPARE4
--------------------------------------------------------------------------------
B9D03F857F908380

S:6AA5A404596789B248ECD71A72FBD3BC8E5C3CE5C41BF80EEBA82CBFCD9A;H:8D278AFD51EE10B
3C7AC5659283320FD;T:822CD39393006B95BD0A249DC3CE4E1FFF058D885F89CE2C1A9060819685
B25784E280C4E24405F70723166D802D3E0E501119B2613E5F32DC3A82B1F744B55BC2B17132D91F
6B7E64A8F6E34CF78E8F
*/
-- EN caso de que se quisiera editar
--alter user system identified by "OCS.ora1234" ;



--
-- PREPARACION DE LOS STRING DE CONEXION



-- primero la base EBSCS
-- para el tnsnames de EBSCSPR PARA TODOS LOS NODOS
--/u02/app/oracle/product/12.1.0/dbhome_1/network/admin/EBSCSPR/tnsnames.ora
##### RAT 2022-08 #####
EBSCSPRSRV=
    (DESCRIPTION=(ADDRESS=
        (PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521))
      (CONNECT_DATA=(SERVER=DEDICATED)
        (SERVICE_NAME=EBSCSPRSRV.tdeprdcl.internal)
        (UR=A)(FAILOVER_MODE=(TYPE=select)(METHOD=basic))))
EBSCSPR1=
    (DESCRIPTION=(ADDRESS=
        (PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521))
      (CONNECT_DATA=(SERVER=DEDICATED)
        (SID=EBSCSPR1)(UR=A)(FAILOVER_MODE=(TYPE=select)(METHOD=basic))))
EBSCSPR2=
    (DESCRIPTION=(ADDRESS=
        (PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521))
      (CONNECT_DATA=(SERVER=DEDICATED)
        (SID=EBSCSPR2)(UR=A)(FAILOVER_MODE=(TYPE=select)(METHOD=basic))))
EBSCSPR3=
    (DESCRIPTION=(ADDRESS=
        (PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521))
      (CONNECT_DATA=(SERVER=DEDICATED)
        (SID=EBSCSPR3)(UR=A)(FAILOVER_MODE=(TYPE=select)(METHOD=basic))))
EBSCSPR4=
    (DESCRIPTION=(ADDRESS=
        (PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521))
      (CONNECT_DATA=(SERVER=DEDICATED)
        (SID=EBSCSPR4)(UR=A)(FAILOVER_MODE=(TYPE=select)(METHOD=basic))))
# Dblink que usa el cliente dblink
# Comentar cualquier entrada anterior relacionada a este alias
ERTXPD1=
    (DESCRIPTION=(ADDRESS=
        (PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521))
      (CONNECT_DATA=(SERVER=DEDICATED)
        (SERVICE_NAME=ERTXPRSRV.tdeprdcl.internal)
        (UR=A)(FAILOVER_MODE=(TYPE=select)(METHOD=basic))))


-- TESTEAR LAS CONEXIONES
-- Probar los tnsnames incluyendo los dblink
-- una vez copiados todos los alias anterioresa los nodos
sqlplus -s "ocs_m2c/OCS.ora1234@EBSCSPRSRV" <<EOF
select instance_name from V\$instance ;
exit;
EOF
sqlplus  -s "ocs_m2c/OCS.ora1234@EBSCSPR1" <<EOF 
select instance_name from V\$instance ;
exit;
EOF
sqlplus -s "ocs_m2c/OCS.ora1234@EBSCSPR2" <<EOF
select instance_name from V\$instance ;
exit;
EOF
sqlplus -s "ocs_m2c/OCS.ora1234@EBSCSPR3" <<EOF
select instance_name from V\$instance ;
exit;
EOF
sqlplus -s "ocs_m2c/OCS.ora1234@EBSCSPR4" <<EOF
select instance_name from V\$instance ;
exit;
EOF


-- probar dblink
-- debe mostrar la info de la otra base de datos a la cual referenciamos
sqlplus "ocs_m2c/OCS.ora1234@EBSCSPRSRV" <<EOF
prompt instancia local a la cual me conecte 
select instance_name from V\$instance ;
prompt esto msotrara ahora info del dblink
select sysdate, db_unique_name from V\$database@BSCS_TO_RTX_LINK.TDEPRDCL.INTERNAL ;
select instance_name, host_name from V\$instance@BSCS_TO_RTX_LINK.TDEPRDCL.INTERNAL ;
exit;
EOF



-- Ahora lo mismo pero para  la base ERTX
-- para el tnsnames de ERTXPR PARA TODOS LOS NODOS
--/u02/app/oracle/product/12.1.0/dbhome_1/network/admin/ERTXPR/tnsnames.ora
##### RAT 2022-08 #####
ERTXPRSRV=
    (DESCRIPTION=(ADDRESS=
        (PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521))
      (CONNECT_DATA=(SERVER=DEDICATED)
        (SERVICE_NAME=ERTXPRSRV.tdeprdcl.internal)
        (UR=A)(FAILOVER_MODE=(TYPE=select)(METHOD=basic))))
ERTXPR1=
    (DESCRIPTION=(ADDRESS=
        (PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521))
      (CONNECT_DATA=(SERVER=DEDICATED)
        (SID=ERTXPR1)(UR=A)(FAILOVER_MODE=(TYPE=select)(METHOD=basic))))
ERTXPR2=
    (DESCRIPTION=(ADDRESS=
        (PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521))
      (CONNECT_DATA=(SERVER=DEDICATED)
        (SID=ERTXPR2)(UR=A)(FAILOVER_MODE=(TYPE=select)(METHOD=basic))))
ERTXPR3=
    (DESCRIPTION=(ADDRESS=
        (PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521))
      (CONNECT_DATA=(SERVER=DEDICATED)
        (SID=ERTXPR3)(UR=A)(FAILOVER_MODE=(TYPE=select)(METHOD=basic))))
ERTXPR4=
    (DESCRIPTION=(ADDRESS=
        (PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521))
      (CONNECT_DATA=(SERVER=DEDICATED)
        (SID=ERTXPR4)(UR=A)(FAILOVER_MODE=(TYPE=select)(METHOD=basic))))
# Dblink que usa el cliente dblink
# Comentar cualquier entrada anterior relacionada a este alias
EBSCSPD1=
    (DESCRIPTION=(ADDRESS=
        (PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521))
      (CONNECT_DATA=(SERVER=DEDICATED)
        (SERVICE_NAME=EBSCSPRSRV.tdeprdcl.internal)
        (UR=A)(FAILOVER_MODE=(TYPE=select)(METHOD=basic))))


-- TESTEAR LAS CONEXIONES
-- Probar los tnsnames incluyendo los dblink
-- una vez copiados todos los alias anterioresa los nodos
sqlplus -s "ocs_m2c/OCS.ora1234@ERTXPRSRV" <<EOF
select instance_name from V\$instance ;
exit;
EOF
sqlplus  -s "ocs_m2c/OCS.ora1234@ERTXPR1" <<EOF 
select instance_name from V\$instance ;
exit;
EOF
sqlplus -s "ocs_m2c/OCS.ora1234@ERTXPR2" <<EOF
select instance_name from V\$instance ;
exit;
EOF
sqlplus -s "ocs_m2c/OCS.ora1234@ERTXPR3" <<EOF
select instance_name from V\$instance ;
exit;
EOF
sqlplus -s "ocs_m2c/OCS.ora1234@ERTXPR4" <<EOF
select instance_name from V\$instance ;
exit;
EOF


-- probar dblink
-- debe mostrar la info de la otra base de datos a la cual referenciamos
sqlplus "ocs_m2c/OCS.ora1234@ERTXPRSRV" <<EOF
prompt instancia local a la cual me conecte 
select instance_name from V\$instance ;
prompt esto msotrara ahora info del dblink
select sysdate, db_unique_name from V\$database@RTX_TO_BSCS_LINK.TDEPRDCL.INTERNAL ;
select instance_name, host_name from V\$instance@RTX_TO_BSCS_LINK.TDEPRDCL.INTERNAL ;
exit;
EOF




-- cambiar los privilegios sobre los archivos de captura 
-- sino podra haber problemas al momento de ejecutar el dbreplay o sqlset
-- si es el que motor de BD no tiene acceso por temas de privilegio
-- a alguno de los archivos de captura o dumps.
-- por ahora no hay problemas con que queden con este espacio
-- ya que son copiados con el usuario opc
[opc@cdv1prbscsdbvm01 Rat]$ chmod -R 777 /u02/Rat/ERTXPD1_20220822
[opc@cdv1prbscsdbvm01 Rat]$ chmod -R 777 /u02/Rat/EBSCSPD1_20220822




/****************************************************************
 Ahora se procede con SPA sobre las bases de datos
 Import table with sql sets to the target or testing database  
*****************************************************************/

-- ejecutar en las respectivas BDs la creacion de estos directorios
--

-- ahora para la BD ERTX
sqlplus "ocs_m2c/OCS.ora1234@ERTXPRSRV"
create directory  REPLAY_DATABASE as '/u02/Rat/ERTXPD1_20220822/ERTXPD1_20220822' ;
create directory  SQLSET_DMP as '/u02/Rat/ERTXPD1_20220822/ERTXPD1_20220822/dump' ;
grant all  on  directory     CAPTURE_DATABASE to  public;  
grant all  on  directory     SQLSET_DMP to  public;  

-- importamos las tablas de sqlset
impdp ocs_m2c/OCS.ora1234@ERTXPRSRV  directory=SQLSET_DMP dumpfile=ERTXPD1_RAT_TABLA_SQLSET_.dmp


-- ahora para la BD EBSC
sqlplus "ocs_m2c/OCS.ora1234@EBSCSPRSRV"
create directory  REPLAY_DATABASE as '/u02/Rat/EBSCSPD1_20220822/EBSCSPD1_20220822' ;
create directory  SQLSET_DMP as '/u02/Rat/EBSCSPD1_20220822/EBSCSPD1_20220822/dump' ;
grant all  on  directory     CAPTURE_DATABASE to  public;  
grant all  on  directory     SQLSET_DMP to  public;  


-- importamos las tablas de sqlset
impdp ocs_m2c/OCS.ora1234@EBSCSPRSRV  directory=SQLSET_DMP dumpfile=EBSCSPD1_RAT_TABLA_SQLSET_.dmp




-- ejecutar esto en cada BD
-- desempaquetar los sqlset en una tabla de desempaquetameiento
-- No olvidar commit
-- unpack the sqlsets
-- noteid: How to Move a SQL Tuning Set from One Database to Another (Doc ID 751068.1)
BEGIN
  DBMS_SQLTUNE.unpack_stgtab_sqlset(sqlset_name          => 'RAT_SQLSET',
                                    sqlset_owner         => 'SYS',
                                    replace              =>  TRUE,
                                    staging_table_name   => 'RAT_TABLA_SQLSET',
                                    staging_schema_owner => 'SYSTEM');
END;
/
commit;




-- cargar los planes de la tabla de stage
-- esto demorara unos 5 minutos o menos dependiendo del numero de sentencias
-- Then load the plans:
set serveroutput on
declare
my_int pls_integer;
begin
my_int := dbms_spm.load_plans_from_sqlset (sqlset_name => 'RAT_SQLSET',
sqlset_owner => 'SYS',
fixed => 'YES',
enabled => 'YES');
DBMS_OUTPUT.PUT_line(my_int);
end;
/
commit;



-- ahora si queremos podemos validara las sentencias desempaquetadas
SELECT SQL_ID, SQL_TEXT FROM  TABLE(DBMS_SQLTUNE.SELECT_SQLSET('RAT_SQLSET'));
select  sqlset_name, sql_id,executions   from  dba_sqlset_statements where  sqlset_name = 'RAT_SQLSET'  order by 3 desc ; 
 


-- Ahora empezaremos con las tareas de SPA usando el sqlset que tenemos
-- para dudas o consultas ir viendo la siguiente nota que habla de RAT Y SPA
-- FAQ: Database Upgrade Using Real Application Testing (Doc ID 1600574.1)
--
-- La siguiente solo habla de SPA mas en detalle:
-- SQL Performance Analyzer Summary (Doc ID 1577290.1)
--
-- AJUSTANDO LOS NOMBRES DE SQLSET Y NOMBRE DE TAREA
-- desde este link se puede revisar mas en detalle los pasos muy simplificados
--  https://aws.amazon.com/blogs/database/use-oracle-real-application-testing-features-with-amazon-rds-for-oracle/
--
-- Create SQL analysis task which will be used to execute the workload on the test database server. 
set serveroutput on size unlimited
DECLARE
v_task VARCHAR2(64) := '';
BEGIN
v_task := DBMS_SQLPA.create_analysis_task(
sqlset_name => 'RAT_SQLSET', task_name=>'SPA_TASK_RAT_01',sqlset_owner=>'SYS');
END;
/
commit;



-- ahora generaremos el convert, fijarse que luego de ejecutar lo siguiente sera posible desde la url de la consola
-- de cloud control poder ver la tarea de SPA creada
-- en el apartado de PERFORMANCE --> SQL ---> SQL PEFFORMANCE ANALYZER HOME (ingresar con las credenciales de sys que nos entregaron)
-- (ojo al entrar a la consola de cloud control fijarse que estamos conectados a las instancias nuevas del exacc destino y no los del origen
-- esto se puede validar fijandonos en que el nombre de instancia a los que nos conectamos sean ERTXPR1 o EBSCSPR1
-- Create SQL plan baselines to enable the optimizer to avoid performance regressions by using execution plans with known performance characteristics. If a performance regression occurs due to plan changes, a SQL plan baseline can be created and used to prevent the optimizer from picking a new, regressed execution plan.
set serveroutput on size unlimited
begin
dbms_sqlpa.execute_analysis_task(
task_name => 'SPA_TASK_RAT_01',
execution_type => 'CONVERT SQLSET',
execution_name => 'BASELINE_RAT_CAPTURE',
execution_desc => 'Creating Baseline Trial',
execution_params => dbms_advisor.arglist('sqlset_name', 'RAT_SQLSET','sqlset_owner','SYS')
);
end;
/
commit;



-- el siguiente script dejarlo en modo background y con nohup corriendo porque demorara una buena cantidad de horas
-- ejemplo: nohup sh script.sh > script.log 2>&1 &
-- ejecutando cada sentencia
-- fijarse que desde cloud control se puede ver que la tarea de spa SPA_TASK_RAT cambio de status 
-- y ahora muestra en ejecucion (Processing) y muestra el numero de sentencias que van avanzando que va ejecutando
-- apartado de PERFORMANCE --> SQL ---> SQL PEFFORMANCE ANALYZER HOME (ingresar con las credenciales de sys que nos entregaron)
--
-- Using test execute method, SQL tuning set is executed on the test Amazon RDS for Oracle instance. The test runs each of the SQL statements contained in the workload to completion. During execution, SQL Performance Analyzer generates execution plans and computes execution statistics for each SQL statement in the workload. Each SQL statement in the SQL tuning set is executed separately from other SQL statements, without preserving their initial order of execution or concurrency. This is done at least twice for each SQL statement, for as many times as possible until the execution times out (up to a maximum of 10 times).  To execute the first trail of the SQL statements run the command as shown below.
set serveroutput on size unlimited
BEGIN
DBMS_SQLPA.EXECUTE_ANALYSIS_TASK(task_name => 'SPA_TASK_RAT_01',
execution_type => 'TEST EXECUTE',
execution_name => 'FIRST_TRIAL_RAT',
execution_desc => 'First trial on new environment',
execution_params => dbms_advisor.arglist('sqlset_name', 'RAT_SQLSET','sqlset_owner','SYS','local_time_limit','300','time_limit','28800') -- 300 segundos (5min) maximo por consulta y un tiempo total de ejecucion de 8 horas (28800 minutos), es bueno dejar seteado ese limite puesto que las sentencias cada una de ellas puede ejecutare muchisimas cantidad de veces por part de SPA (hasta 10 veces en algunos casos).
-- execution_params => dbms_advisor.arglist('sqlset_name', 'RAT_SQLSET','sqlset_owner','SYS','local_time_limit','1200','time_limit','86400') --este ejemplo lo comentamos pero es a modo de ejemplo. la duracion tendra 20 (1200 seg) minutos por consulta con un tiempo total de 24 horas (86400 segundos)
);
END;
/
commit;


-- para ir visualizando el progreso de la ejecucion:
select * from DBA_ADVISOR_EXECUTIONS where task_name='SPA_TASK_RAT_01'
-- si se requiere revisar en detalle las consultas del sqlset y ver sus estadisticas y tiempos de ejecucion consultar lo siguiente
select  *  from  dba_sqlset_statements where  sqlset_name = 'SPA_TASK_RAT_01'



 -- en caso de querer necesitar detener momentaneamenet el analisis se ejecuta lo siguiente indicando el nombre de la tarea
 -- ejemplo SPA_TASK_RAT
 EXEC DBMS_SQLPA.INTERRUPT_ANALYSIS_TASK(task_name => 'SPA_TASK_RAT_01');
 -- para resumirlo:
 exec dbms_sqlpa.resume_analysis_task(task_name => 'SPA_TASK_RAT_01');
 -- para detener completamente 
exec dbms_sqlpa.cancel_analysis_task(task_name => 'SPA_TASK_RAT_01');


/*
Ahora ejecutar la tarea de comparacion
para revisar el reporte de comparacion revisar la siguiente nota:
SQL Performance Analyzer Example (Doc ID 455889.1)
--
EXISTE VARIAS METRICAS A USAR UNA DE ELLAS ES ELAPSED TIME HAY OTRA LLAMADA CPU TIME:
 (SELECT metric_name FROM v$sqlpa_metric )
- PARSE_TIME               
- ELAPSED_TIME             
- CPU_TIME                 
- USER_IO_TIME             
- BUFFER_GETS  ----> ojo que durante la primera ejecucion casi todas las lecturas van al disco, y en las posteriores iran a la SGA             
- DISK_READS               
- DIRECT_WRITES            
- OPTIMIZER_COST           
- IO_INTERCONNECT_BYTES  
-- aquello se modifica en  comparison_metric
*/
-- Now that the baseline is created and the SQL tuning set has been executed, performance data can be collected for comparison between the two using SQL Performance Analyzer. To run the comparison execute the below command on the Amazon RDS for Oracle instance
Begin
DBMS_SQLPA.EXECUTE_ANALYSIS_TASK(task_name => 'SPA_TASK_RAT_01',
execution_type => 'compare performance',
execution_name => 'SPA_Comparison_Capture',
execution_params => dbms_advisor.arglist('comparison_metric', 'ELAPSED_TIME', -- existen estas otras comparaciones: ELAPSED_TIME, CPU_TIME, USER_IO_TIME, OPTIMIZER_COST, BUFFER_GETS, DISK_READS ,IO_INTERCONNECT_BYTES
'execution_name1', 'BASELINE_RAT_CAPTURE',
'execution_name2', 'FIRST_TRIAL_RAT',
'TIME_LIMIT', 'UNLIMITED')
);
end;
/




-- After the comparison analysis is completed, you can generate a report to identify the SQL statements that have improved, remained unchanged, or regressed due to the system change. The following command generates the performance report.
-- SI NO SE PUEDE OCUPAR LA GENERACION DEL REPORTE HTML USANDO UTLFILE HACERLO VIA LA INTERFAZGRAFICA DE CLOUD CONTROL
-- ingresando a SPA via cloud control:
-- apartado de PERFORMANCE --> SQL ---> SQL PEFFORMANCE ANALYZER HOME (ingresar con las credenciales de sys que nos entregaron)
-- seleccionando el nombre de la tarea de SPA (SPA_TASK_RAT_01) y luego seleccionado la opcion "View Trial Comparison Report"
declare
l_replay_dir varchar2(30) := 'REPLAY_DIR';
l_report clob;
l_output_file utl_file.file_type;
l_output_offset number := 1;
l_output_length number;
begin
l_report := DBMS_SQLPA.REPORT_ANALYSIS_TASK('SPA_TASK_RAT_01', 'HTML','ALL', 'ALL');
-- write the file to disk (may be too large to output in sqlplus)
l_output_length := dbms_lob.getlength(l_report);
l_output_file := utl_file.fopen(l_replay_dir, 'rat_spa.html', 'w');
begin
while (l_output_offset < l_output_length) loop
utl_file.put(l_output_file, dbms_lob.substr(l_report, 32767, l_output_offset));
utl_file.fflush(l_output_file);
l_output_offset := l_output_offset + 32767;
end loop;
utl_file.new_line(l_output_file);
utl_file.fclose(l_output_file);
dbms_output.put_line('output in file ' || l_replay_dir || ':rat_spa.html');
exception
when others then
utl_file.fclose(l_output_file);
raise;
end;
end;
/



Revisar el reporte de SPA de html y ese es el primer paso para ver las diferencias encontradas
si se hacen cambios en la BD como agregar memoria por ejemplo se puede hacer otro trial nuevamente de test execute solo cambiar el nombre
del execution_name (SECOND_TRIAL_RAT por ejemplo) manteniendo el mismo nombre de task_name usado anteriormente
--se hicieron estos cambios sobre ERTX
-- probar con este cambio primero
alter system set sga_target=102400M scope=spfile sid='*';
alter system set sga_max_size=102400M scope=spfile sid='*' ;
alter system set pga_aggregate_target=40960M scope=spfile sid='*';
alter system set PGA_AGGREGATE_LIMIT=81920M scope=spfile sid='*';
srvctl stop service -d ERTXPR -s ERTXPRSRV
srvctl stop database -d ERTXPR
srvctl start database -d ERTXPR
srvctl start service -d ERTXPR -s ERTXPRSRV
srvctl status database -d ERTXPR
srvctl status service -d ERTXPR
-- despues agregar mas sga si se desea seria buena idea dejarla en 120 GB para aprovechar mas la memoria
-- por ahora solo quedo en 100GB la sga, evaluar mas adelante incrementarla a 120 o mas por ejemplo
alter system set sga_target=122880M scope=spfile sid='*';
alter system set sga_max_size=122880M scope=spfile sid='*';
alter system set pga_aggregate_target=40960M scope=spfile sid='*';
alter system set PGA_AGGREGATE_LIMIT=81920M scope=spfile sid='*';
-- dejarlo en background sl siguiente trial nuevo , luego de hacer los cambios
set serveroutput on size unlimited
BEGIN
DBMS_SQLPA.EXECUTE_ANALYSIS_TASK(task_name => 'SPA_TASK_RAT_01',
execution_type => 'TEST EXECUTE',
execution_name => 'SECOND_TRIAL_RAT',
execution_desc => 'second trial on new environment (mas SGA Y PGA)',
execution_params => dbms_advisor.arglist('sqlset_name', 'RAT_SQLSET','sqlset_owner','SYS','local_time_limit','1200','time_limit','86400') 
);
END;
/
commit;
-- y despues comparando la linea base del origen BASELINE_RAT_CAPTURE VS este segundo trial (la comparacion tambien se puede hacer via cloud control)
Begin
DBMS_SQLPA.EXECUTE_ANALYSIS_TASK(task_name => 'SPA_TASK_RAT_01',
execution_type => 'compare performance',
execution_name => 'SPA_Comparison_Capture',
execution_params => dbms_advisor.arglist('comparison_metric', 'ELAPSED_TIME', -- existen estas otras comparaciones: ELAPSED_TIME, CPU_TIME, USER_IO_TIME, OPTIMIZER_COST, BUFFER_GETS, DISK_READS ,IO_INTERCONNECT_BYTES
'execution_name1', 'BASELINE_RAT_CAPTURE',
'execution_name2', 'SECOND_TRIAL_RAT',
'TIME_LIMIT', 'UNLIMITED')
);
end;
/
-- y despues sacando el reporte nuevamente via sqlplus o via la consola de cloud control






/***************************************************************************
/*********************** EJECUCION DE DBREPLAY ****************************/



-- Este paso es fundamental hacerlo en las BDs de destino
-- DISABLE TUNING ADVISOR IF THE REPLAY IS SLOW!!
--
-- Very important disable tuning advisor 
-- https://www.aemcorp.com/managedservices/blog/oracle-real-application-testing-rat-what-is-it-and-how-do-you-use-it
-- la tarea de replay podria durar bastante horas mas al respecto
--
BEGIN DBMS_AUTO_TASK_ADMIN.DISABLE( 
client_name => 'sql tuning advisor', 
operation => NULL, 
window_name => NULL); 
END; 
/



-- importante estoo por favor.
-- Before to apply RAT Replay, Oracle recommends bounce database instances, or instead of that
-- you can flush buffer cash or shared pool. It's for avoid error like for example:
-- Error ORA-32701 'On Current SQL: insert into wrh$_sql_bind_metadata' (Doc ID 2226216.1)
srvctl stop database -d EBSCSPR ; srvctl start database -d EBSCSPR
srvctl stop database -d ERTXPR ; srvctl start database -d ERTXPR
srvctl status database -d EBSCSPR
srvctl status database -d ERTXPR
srvctl start service -d EBSCSPR -s EBSCSPRSRV
srvctl start service -d ERTXPR -s ERTXPRSRV
-- verfificar los servicios ERTXPRSRV y EBSCSPRSRV y que son importantes para el dbreplay
-- deben estar corriendo en TODOS los nodos
srvctl status service -d ERTXPR
srvctl status service -d EBSCSPR



-- despues de estos reinicios importante no volver a reiniciar mientras se comience con los procesos
-- de captura puesto que si se hace entre medio, habra que volver a ejecutar todo los pasos
-- de dbreplay desde el comienzo



/**********************************************************************************
 *	NOTE:
 * Execute every of these scripts en background, maybe it take so longer execution
 * Asi que dejar todos los script con nohup corriendo
 */



-- Primer paso inicial
-- Process capture replay
-- Maybe it could take a long time
-- 01_DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE.sh
sqlplus "/as sysdba" <<EOF
set timin on
-- SI se omite el parallel, oracle lo determina automatico y en ocasiones puede causar muchas hebras en ejecucion
-- causando bloqueos: ORA-32701: Possible hangs up to hang ID=2 detected sobre la tabla: wrr$_captures
-- Indicar un numero bajo o en su defecto indicar paralelismo de 1 para forzar que sea Serial
exec DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE (capture_dir=>'REPLAY_DATABASE',PARALLEL_LEVEL=>6);
exit;
EOF


-- Atencion lo siguiente es solo por si aparecen errores
-- SI por algun motivo el proceso anterior diera errores aplicar el siguiente workaround:
/* Maybe we have this error: DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE Returns an ORA-15516 and ORA-942 Error After Applying a Real Application Testing (RAT) Bundle Patch (Doc ID 2226397.1). Execute this workaround FROM THE NODE 01 PLEASE!!!
*/
workaround: 
@$ORACLE_HOME/rdbms/admin/catnowrr.sql
@$ORACLE_HOME/rdbms/admin/catwrr.sql
EXEC UTL_RECOMP.recomp_parallel(4);
alter system flush shared_pool -- en las 4 instancias
alter system flush buffer_cache -- en las 4 instancias
-- Los anteriores flush son para evitar problemas conocidos que se pueden
-- presentar sobre la tabla wrr$_captures con bloqueos o hangs asociados a la ejecucion de 
-- DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE  cuando se deja a oracle que decida el paralelismo
/*
SQL> BEGIN DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE (capture_dir=>'DBREPLAY_DATABASE_20210818',PARALLEL_LEVEL=>10); END;
*
ERROR at line 1:
ORA-15516: parallel preprocessing worker hit error ORA-942
ORA-06512: at "SYS.DBMS_WORKLOAD_REPLAY", line 2587
ORA-06512: at line 1
Also we have the next error:
ORA-15516: parallel preprocessing worker hit error ORA-1653
(try without parallel)
If you get error: ORA-15516: parallel preprocessing worker hit error ORA-1653
Please review that you have enough space in SYSTEM and SYSAUX tablespace.
*/




-- Siguiente paso el calibrate, esto nos dira el numero de clientes que deberiamos dejar corriendo,
-- nos dará un consejo
-- calibrate 
--
--BD ERTX
nohup wrc system/oracle@ERTXPRSRV  mode=calibrate replaydir=/u02/Rat/ERTXPD1_20220822/ERTXPD1_20220822
-- BD EBSC
nohup wrc system/oracle@EBSCSPRSRV mode=calibrate replaydir=/u02/Rat/EBSCSPD1_20220822/EBSCSPD1_20220822




-- siguiente paso inicializar, se le puede poner nombre al proceso de replay
-- se sugiere dejar el mismo
-- Initialize
-- 03_DBMS_WORKLOAD_REPLAY.INITIALIZE_REPLAY.sh
sqlplus "/as sysdba" <<EOF
set timin on
BEGIN
DBMS_WORKLOAD_REPLAY.INITIALIZE_REPLAY  (
   replay_name     => 'REPLAY_DATABASE' ,
   replay_dir      => 'REPLAY_DATABASE' );
END;
/
exit;
EOF



-- in case of cancelation:
-- exec DBMS_WORKLOAD_REPLAY.CANCEL_REPLAY ();




-- ahora lo importante hay que hacer el remapeo
--During capture, connection strings used to connect to production system are captured
--Connection strings must be remapped to replay system 
-- NOTE: If connections are not remapped, workload may be replayed against production database
select conn_id,capture_conn,replay_conn from dba_workload_connection_map;


-- THIS IS MOST IMPORTANTE, you have two alternatives:
-- 1.-
-- NOTE Review very good the service_name to use !!!!!
-- Este es el script para la BD ERTX
set lines 600 pages 0
col cmd format a300
spool remap.sql
SELECT 'EXEC dbms_workload_replay.remap_connection(connection_id =>'||a.conn_id||',replay_connection =>''(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521)(CONNECT_DATA=(SERVICE_NAME=ERTXPRSRV.tdeprdcl.internal)))'');'
FROM dba_workload_connection_map a, dba_workload_replays b
WHERE a.replay_id = b.id AND b.status = 'INITIALIZED'
ORDER BY a.conn_id;
spool off
-- Este el mismo script pero para la BD EBSC
set lines 600 pages 0
col cmd format a300
spool remap.sql
SELECT 'EXEC dbms_workload_replay.remap_connection(connection_id =>'||a.conn_id||',replay_connection =>''(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=cdv1prbscsdb-scan.tdeprdcl.internal)(PORT=1521)(CONNECT_DATA=(SERVICE_NAME=EBSCSPRSRV.tdeprdcl.internal)))'');'
FROM dba_workload_connection_map a, dba_workload_replays b
WHERE a.replay_id = b.id AND b.status = 'INITIALIZED'
ORDER BY a.conn_id;
spool off


-- De hecho para validar que los string estan bien armados, hacer una prueba conectandonos usando esos mismos string de conexion, deberiamos poder conectarnos exitosamente usando los DESCRIPTION=(....


-- guardar lo anterior en un script y ejecutarlo en las respectivas BDs
-- poner atencion de ejecitarlo en las BDs que corresponden
@remap.sql

-- luego en cada BD hay que revisar como quedo el remapeo, y fijarse
-- que cada mapeo apunte a la scan y nombre de servicio respectivo de estas nuevas BDs
select conn_id,replay_conn from dba_workload_connection_map;

/*
-- este es solo otro ejemplo que se puede usar obviamente usando 
EXEC dbms_workload_replay.remap_connection(connection_id =>1,replay_connection =>'(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=lab-db12-2-ol7)(PORT=1521)(CONNECT_DATA=(SERVICE_NAME=test02)))');
EXEC dbms_workload_replay.remap_connection(connection_id =>2,replay_connection =>'(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=lab-db12-2-ol7)(PORT=1521)(CONNECT_DATA=(SERVICE_NAME=test02)))');
*/





-- Ahora viene la creacion de filtros por cada replay
-- How to Create Filters for Either a Capture or Replay with Real Application Testing (RAT) (Doc ID 2285287.1)
-- agregar estos filtros (si ya fueron agregados en otra prueba de replay sobre los mismos archivos rec no aplicarlos)
-- ejemplo de filtros
--exec dbms_workload_replay.add_filter(fname=>'nombre_filtro', fattribute => 'USER', fvalue=>'NOMBRE_USUARIO') ;
-- in case of error with the filters:
/*
exec DBMS_WORKLOAD_REPLAY.DELETE_FILTER('NO_DBSNMP');
exec DBMS_WORKLOAD_REPLAY.DELETE_FILTER('NO_SYSTEM');
exec DBMS_WORKLOAD_REPLAY.DELETE_FILTER('NO_SYS');
commit;
*/
-- in order to use these filters, we need to create a filter set. 
-- All filters created after the last filter set will be included in this new filter set automatically.
-- the filter/filter set will be created in the replay folder, not in database.
-- slow, 5 minutes roughly.

--How to Create Filters for Either a Capture or Replay with Real Application Testing (RAT) (Doc ID 2285287.1)
-- 04_DBMS_WORKLOAD_REPLAY.CREATE_FILTER_SET.sh
sqlplus "/as sysdba" <<EOF
set timin on
-- Si la siguiente linea (DBMS_WORKLOAD_REPLAY.CREATE_FILTER_SET y use_filter_set)
-- ya fueron  anteriormente ejecutada sobre los archivos rec en otra prueba de replay
-- no ejecutarla de nuevo si no se obtendra el error:
-- unique constraint (SYS.WRR$_FILTERS_PK) violated
-- al momento de ejecutar el paso siguiente: DBMS_WORKLOAD_REPLAY.PREPARE_REPLAY
-- en caso del error cancelar el replay y volverlo a ejecutar:
-- /* exec DBMS_WORKLOAD_REPLAY.CANCEL_REPLAY (); */
exec dbms_workload_replay.add_filter(fname=>'NO_DBSNMP', fattribute => 'USER', fvalue=>'DBSNMP') ;
exec dbms_workload_replay.add_filter(fname=>'NO_SYSTEM', fattribute => 'USER', fvalue=>'SYSTEM') ;
exec dbms_workload_replay.add_filter(fname=>'NO_SYS', fattribute => 'USER', fvalue=>'SYS') ;
-- VERYY SLOW THE NEXT!!!!
exec DBMS_WORKLOAD_REPLAY.CREATE_FILTER_SET(replay_dir=>'REPLAY_DATABASE', filter_set=> 'FILTERSET_USUARIOS', default_action=>'INCLUDE');
-- use the filter we created.
exec dbms_workload_replay.use_filter_set(filter_set=>'FILTERSET_USUARIOS');
exit;
EOF



-- siguiente paso preparacion del replay
-- Prepare replay
-- 05_DBMS_WORKLOAD_REPLAY.PREPARE_REPLAY.sh
-- Is probably that we have a error here if we have not enough space on sysaux tablespace:
-- RAT Replay: DBMS_WORKLOAD_REPLAY Fails with 'ORA-20223 Does Not Contain A Processed Workload Capture' (Doc ID 2759140.1)
-- agregar espacio en el sysaux por si se nos olvido hacerlo anteriormente
-- recordar que este paso consume muchisimo en las tablas internas de rat
-- sobre los sysaux
alter tablespace sysaux add datafile size 1g autoextend on next 20m ;
alter tablespace sysaux add datafile size 1g autoextend on next 20m ;
alter tablespace sysaux add datafile size 1g autoextend on next 20m ;
alter tablespace sysaux add datafile size 1g autoextend on next 20m ;
alter tablespace sysaux add datafile size 1g autoextend on next 20m ;
-- OJO QUE ESTA PARTE DEMORA
-- aqui se demorara unas 03 horas aprox o menos 
sqlplus "/as sysdba" <<EOF
set timin on
BEGIN
   DBMS_WORKLOAD_REPLAY.PREPARE_REPLAY (
   synchronization         => false,
   CONNECT_TIME_SCALE      => 100  ,
   THINK_TIME_SCALE        => 100
   );
END;
/
exit;
EOF



-- ahora que nuestra replay quedo preparada vamos a dejar en background los clientes
-- USAR UN NUMERO DE CLIENTES SIMILARES A LOS QUE USO EN EL AMBIENTE ORIGEN CONSIDERANDO LAS INSTANCIAS
-- SI EL ORIGEN TIENE 2 INSTANCIAS, ENTONCES QUE LOS CLIENTES CORRAN SOBRE DOS INSTANCIAS Y NO LAS 4. 
-- cuando pasa eso RAT ACTUA UN TANTO RARO. Eso mismo nos comentaron algunos especialistas de RAT
-- In this example the calibrate show us that is recommendable to use 8 clients
-- on differents rac nodes (we have 4 nodes)
-- NOTE: The option CONNECTION_OVERRIDE – If TRUE the ignore replay connections 
-- specified in DBA_WORKLOAD_CONNECTION_MAP. If FALSE (default) use replay connections in DBA_WORKLOAD_CONNECTION_MAP
-- Leave these scripts on ACFS or shared disk between all cluster nodes 
-- quizas la opcion de DEBUG=ON quitarla para no llenar tanto los discos.

-- **** BD ERTX ****
-- Esto es solo una sugerencia, que los clientes de dbreplay de la base ERTX queden corriendo en los nodos 01 y 02 del vmcluster, asi se distruibuira mejor la carga
-- fijarse que en los server ponemos los alias de tns de las respectivas instancias donde queremos que corra esa carga.
-- este cliente es desde el nodo 01
nohup wrc userid=system password=OCS.ora1234 server=ERTXPR1 mode=replay replaydir=/u02/Rat/ERTXPD1_20220822/ERTXPD1_20220822 DSCN_OFF=true debug=off connection_override=TRUE > log_wrc_ERTXPR1.log 2>&1 &
-- este cliente es desde el nodo 02
nohup wrc userid=system password=OCS.ora1234 server=ERTXPR2 mode=replay replaydir=/u02/Rat/ERTXPD1_20220822/ERTXPD1_20220822 DSCN_OFF=true debug=off connection_override=TRUE > log_wrc_ERTXPR2.log 2>&1 &


-- **** BD EBSC ****
-- Esto es solo una sugerencia, que los clientes de dbreplay de la base EBSCS queden corriendo en los nodos 03 y 04 del vmcluster, asi se distruibuira mejor la carga
-- fijarse que en los server ponemos los alias de tns de las respectivas instancias donde queremos que corra esa carga.
-- este cliente es desde el nodo 03
nohup wrc userid=system password=OCS.ora1234 server=EBSCSPR3 mode=replay replaydir=/u02/Rat/EBSCSPD1_20220822/EBSCSPD1_20220822 DSCN_OFF=true debug=off connection_override=TRUE > log_wrc_EBSCSPR3.log 2>&1 &
-- este cliente es desde el nodo 04
nohup wrc userid=system password=OCS.ora1234 server=EBSCSPR4 mode=replay replaydir=/u02/Rat/EBSCSPD1_20220822/EBSCSPD1_20220822 DSCN_OFF=true debug=off connection_override=TRUE > log_wrc_EBSCSPR4.log 2>&1 &

-- el numero de clientes podria aumentar de acuerdo a lo que calibrate sugiera, puede que calibrate sugiera ejecutar con 4 clientes el replay, en ese caso se dejan dos comandos corriendo de wrc en el nodo 01 y otros dos comandos de wrc corriendo en el nodo 02 para la base ERTX, y lo mismo se haria para la base EBSC, dos comandos de wrc corriendo en el nodo 03 y otros dos comandos de wrc corriendo en el nodo 04. Por ejemplo.


-- si los clientes de wrc dan este error:
Executing Database Replay Fails With: "ORA-15568: login of user ORA_RECO_070361 during workload replay failed with ORA-1435" Error (Doc ID 1949927.1)
es por la presencia de transacciones distribuidas que no estan soportadas
-- asi que no se puede hacer nada con ese warning, rat no soporta esas trnsacciones ni las puede replicar
-- asi que no tomar en cuenta



-- Hacemos un ultimo chequeo 
-- para bd ERTX
wrc mode=list_hosts replaydir=/u02/Rat/ERTXPD1_20220822/ERTXPD1_20220822
-- para bd EBSC
wrc mode=list_hosts replaydir=/u02/Rat/EBSCSPD1_20220822/EBSCSPD1_20220822


-- IF you have the error:
-- ORA-15567: replay user system encountered an error during a sanity check
-- Check this note: WRC fails with "ORA-15567: Replay User System Encountered An Error During A Sanity Check" (Doc ID 2110258.1)
-- for example some solution is: grant become user to <user>;
-- revisar tambien que no haya algun string de conexion mal puesto en el remap



-- este es un script para ir limpiando traces en caso de que se haya usado debug=on
# limpieza de traces
-- habria que ir mirando estos directorios en los nodos
mkdir /u02/Rat/replay_traceshost_2557851861_82/trace
-- o dejar un crotab que vaya borrando archivos usando un script similar a este para ir movindo archivos hacia un disco con mas espacio por ejemplo, o simplemente eliminarlos
/bin/find /u02/app/oracle/diag/clients/user_oracle/host_2557851861_82/trace -type f -mmin +5 -exec mv '{}' /u02/Rat/replay_traceshost_2557851861_82/trace \;
-- ejemplo crontab
# Script temporal
# Limpieza traces de pruebas de RAT
00,10,20,30,40,50 * * * * sh /u02/Rat/limpieza_traces_nodo01.sh >> /u02/Rat/limpieza_traces_nodo01.log 2>&1




-- continuamos
-- crear un snapshot
execute  dbms_workload_repository.create_snapshot(); 

--verificar que los tablespaces temporales existan y esten ok
select name from V$tempfile ;


-- ahora viene el paso que realmente parte el replay se deberia ejecutar
-- al mismo tiempo en cada BD
-- comenzar la replica
-- 07_DBMS_WORKLOAD_REPLAY.START_REPLAY.sh
sqlplus "/as sysdba" <<EOF
set timin on
BEGIN
   DBMS_WORKLOAD_REPLAY.START_REPLAY;
END;
/
exit;
EOF
-- Este proceso aprox durara la cantidad de horas de la captura asi que paciencia
-- Una 




/*
 *****************************************
 * Querys para ver el reporte de RAT, se pueden ocupar estos como alternativap pero
 * se puede continuar con el paso a a paso donde mostramos los avances
 * https://westzq1.github.io/oracle/2019/02/22/Oracle-Database-Workload-Replay.html
 *
 */


-- esto por ahora no es necesario fue solicitado por soporte para otro cliente
/* STOP TRACE CRS SO on every node*/
--To disable the crash dump, as root user after issue reproduces. 
--/u01/app/19.0.0.0/grid/bin/crsctl modify res ora.cssd -attr "REBOOT_OPTS=" -init -unsupported 
/--u01/app/19.0.0.0/grid/bin/crsctl modify res ora.cssdmonitor -attr "REBOOT_OPTS=" -init -unsupported 

-- una vez terminado el proceso de rat sacar un snap si es necesario
execute  dbms_workload_repository.create_snapshot(); 



-- esperar unos 5 minutos a que termine la foto de los snap de awr


-- Important is export AWR of this REPLAY for
-- post-analysys or compare with other awr 
VARIABLE rep_id number;
BEGIN
   SELECT max(id) INTO :rep_id FROM dba_workload_replays;
END;
/

BEGIN
  DBMS_WORKLOAD_REPLAY.EXPORT_AWR (replay_id => :rep_id);
END;
/



/*
 * REPORT REPLAY PROCESS
 *
 * Now we can examine a replay report using the next query :)
 * Esto nos mostrara el reporte del dbreplay con lo que se encontro en el replay
 * es util mirarlo pero es mas util aun comprar los awr de la captura con el awr del replay eso lo haremos mas adelante en otro paso
 */
set serveroutput on size unlimited
set echo off head off feedback off linesize 200 pagesize 1000
set long 1000000 longchunksize 10000000
VARIABLE rep_id number;
BEGIN
   SELECT max(id) INTO :rep_id FROM dba_workload_replays;
END;
/
spool DBMS_WORKLOAD_REPLAY.REPORT.html
select DBMS_WORKLOAD_REPLAY.REPORT( :rep_id, 'HTML') from dual;
spool off


-- or also using this:
DECLARE
  cap_id         NUMBER;
  rep_id         NUMBER;
  rep_rpt        CLOB;
BEGIN
  cap_id := DBMS_WORKLOAD_REPLAY.GET_REPLAY_INFO(dir => 'dec06');
  /* Get the latest replay for that capture */
  SELECT max(id)
  INTO   rep_id
  FROM   dba_workload_replays
  WHERE  capture_id = cap_id;
 
  rep_rpt := DBMS_WORKLOAD_REPLAY.REPORT(replay_id => rep_id,
                           format => DBMS_WORKLOAD_REPLAY.TYPE_TEXT);
END;
/


# Por si se quisiera revisar reportes y graficos exawatcher indicando el horario de inicio y de fin, es solo como observacion no es necesario
# EXWATCHER 
¢ For every NODE
# Para reportar resultados y empaquetarlos (dd/mm/yyyy_hh24:mi:ss)
/opt/oracle.ExaWatcher/GetExaWatcherResults.sh --from 09/13/2021_09:00:00 --to 09/14/2021_16:00:00




-- IMPORTAR SNAPS AWR DE LA CAPTURA
-- Para producir el reporte que compare la performance de captura vs replay:
-- captura vs replay
-- o replay vs otro replay se debe usar lo siguiente:
-- Si se va a comprar captura vs reply
-- el parámetro replay_id2 no se debe especificar:
-- # https://docs.oracle.com/cd/E11882_01/server.112/e41481/dbr_analyze.htm#RATUG289
--The replay_id2 parameter specifies the numerical identifier of the workload replay before change for which the reported will be generated. If unspecified, the comparison will be performed with the workload capture.
create user RAT_AWR_CAPTURE identified by "OCS.ora1234" default tablespace users;
grant create session, resource, dba to RAT_AWR_CAPTURE_20210818 ;
alter user RAT_AWR_CAPTURE_20210818 quota unlimited on users ;
-- this is for avoid error when execute DBMS_WORKLOAD_REPLAY.COMPARE_PERIOD_REPORT 
-- Error "AWR snapshots not found for Capture" returned when Executing DBMS_WORKLOAD_REPLAY.COMPARE_PERIOD_REPORT After Replay (Doc ID 1575980.1)
VARIABLE cap_id number;
BEGIN
   SELECT max(id) INTO :cap_id FROM DBA_WORKLOAD_CAPTURES;
END;
/
select :cap_id from dual ;
SELECT DBMS_WORKLOAD_CAPTURE.IMPORT_AWR (capture_id => :cap_id ,  staging_schema => 'RAT_AWR_CAPTURE' )  FROM DUAL;
commit ;
/*
DBMS_WORKLOAD_CAPTURE.IMPORT_AWR(CAPTURE_ID=>:CAP_ID,STAGING_SCHEMA=>'RAT_AWR_CA
--------------------------------------------------------------------------------
								       191546401
*/





-- PRODUCIR EL REPORTE GENERAL DE COMPARACION CAPTURA VS REPLAY
VARIABLE rep_id number;
BEGIN
   SELECT max(id) INTO :rep_id FROM dba_workload_replays;
END;
/
select :rep_id from dual ;
var report_bind clob;
begin
DBMS_WORKLOAD_REPLAY.COMPARE_PERIOD_REPORT (replay_id1 => :rep_id, replay_id2=> null, format => 'HTML', result => :report_bind);
end;
/


-- This section describes how to generate replay compare period reports using the DBMS_WORKLOAD_REPLAY package. This report only compares workload replays that contain at least 5 minutes of database time.
--
set serveroutput on size unlimited
set echo off head off feedback off linesize 200 pagesize 1000
set long 1000000 longchunksize 10000000
spool DBMS_WORKLOAD_REPLAY.COMPARE_PERIOD_REPORT.html
exec dbms_output.put_line(DBMS_LOB.SUBSTR(:report_bind,32767,1));
spool off


/*
-- COMPRAR SQLSETS
-- esto es opcional
Este comando esta muy bueno para analizar los SQL tambien:
Generating SQL Performance Analyzer Reports Using APIs
This section describes how to generate a SQL Performance Analyzer report using the DBMS_WORKLOAD_REPLAY package.
The SQL Performance Analyzer report can be used to compare a SQL tuning set from a workload capture to another SQL tuning set from a workload replay, or two SQL tuning sets from two workload replays. Comparing SQL tuning sets with Database Replay provides more information than SQL Performance Analyzer test-execute because it considers and shows all execution plans for each SQL statement, while SQL Performance Analyzer test-execute generates only one execution plan per SQL statement for each SQL trial.
To generate a replay compare period report, use the DBMS_WORKLOAD_REPLAY.COMPARE_SQLSET_REPORT procedure:
*/
--
--leave replay_id2 null if you need to compare that with capture
VARIABLE rep_id number;
BEGIN
   SELECT max(id) INTO :rep_id FROM dba_workload_replays;
END;
/
select :rep_id from dual ;
var report_bind clob;
BEGIN
DBMS_WORKLOAD_REPLAY.COMPARE_SQLSET_REPORT(
                           replay_id1 => :rep_id,
                           replay_id2 => null,
                           format => 'DBMS_WORKLOAD_CAPTURE.TYPE_HTML',
                           result => :report_bind);
END;
/
set serveroutput on size unlimited
set echo off head off feedback off linesize 200 pagesize 1000
set long 1000000 longchunksize 10000000
spool DBMS_WORKLOAD_REPLAY.COMPARE_SQLSET_REPORT.html
exec dbms_output.put_line(DBMS_LOB.SUBSTR(:report_bind,32767,1));
spool off



 


--
--importar los script de captura de AWR para comparar: 
-- LOS VALORES DE SNAP Y DBID DE LA CAPTURA Y REPPLAY SE PUEDEN SACAR DEL REPORTE
-- DE COMPARACION para que se puedan ocupar por la funcion
-- DBMS_WORKLOAD_REPOSITORY.AWR_GLOBAL_DIFF_REPORT_HTML
-- en el apartado (Information About AWR and Time Periods)
--
CREATE USER capture_awr  identified by capture_awr default tablespace users ;
alter user  capture_awr quota unlimited on users ; 

-- el replay id puede ser encontrado en es el numero maximo que deberiamos observar aqui:
-- SELECT ID,STATUS,TO_CHAR(END_TIME,'DD-MM-YYYY hh24:mi') FROM  DBA_WORKLOAD_REPLAYS order by end_time;
-- esto tambien se puede hacer automaticamente desde la pagina de enterprise manager desde el reporte
-- para comparar los periodos antes y despues:
Replay Workload on Test Database -> Analyze Results -> seleccionar directorio y la captura -> Reports -> Compare period report AWR 
-- el numero del id de replay se obtiene desde la query:
-- SELECT max(id) INTO :rep_id FROM dba_workload_replays;
SELECT DBMS_WORKLOAD_REPLAY.IMPORT_AWR (replay_id => 62, staging_schema => 'CAPTURE_AWR') FROM DUAL;
-- revisar el archivo /u01/capture_database/cap/wcr_ca.log para ver si hay algun problema con la importacion del awr

-- Con el siguiente script se puede sacar un reporte de diferencia :
@?/rdbms/admin/awrgdrpi.sql you can view the snapid and dbid

-- lo anterior es lo mismo que ejecutar pero usando los parametros, del dbid de la BD de origen y el otro dbid de la base actual donde reproducimos el replay, usando los begin snap y end snap correspondientes abarcando los horarios
set serveroutput on size unlimited
spool Capture_vs_Replay_AWR_GLOBAL_DIFF_REPORT.html
select *
from table(
DBMS_WORKLOAD_REPOSITORY.AWR_GLOBAL_DIFF_REPORT_HTML(dbid1 => 191546401, inst_num1=>NULL, bid1 => 62407, eid1 => 62424, dbid2 => 504595950, inst_num2=>NULL, bid2 => 62616, eid2 => 62738)
);
spool off


-- otra opcion es hacerlo usando lo siguiente pero mejor desde el enterprise manager 




/*
* este paso tambien es opcional y es para usar dblinks para hacer anlisis de SPA
 * SPA ANALYSYS 
 * Testing Performance Impact of Upgrade from 10g to 11g Using SQL Performance Analyzer (Doc ID 1363104.1)
 */

4. Create a public database link from target to source 
create public database link DBLINK_SOURCE connect to SYSTEM identified by oracle using '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=lab-db12-2-ol7)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=test01)))';


5. Create a SPA Task 

exec DBMS_SQLPA.DROP_ANALYSIS_TASK('SPA_TEST__20210817');
  DECLARE
   V_TASK VARCHAR2(100);
  BEGIN
    V_TASK := DBMS_SQLPA.CREATE_ANALYSIS_TASK(SQLSET_NAME => 'STS_database_RAT_PROD_20210817', TASK_NAME => 'SPA_TEST__20210817');
 END;
/

6. Test Execution in 10g
NOTE : You may want to flush shared pool and buffer cache of 10g before this execution.


begin 
DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( 
task_name => 'SPA_TEST__20210817', 
execution_type => 'TEST EXECUTE', 
execution_name => 'EXEC_SOURCE',
execution_params => dbms_advisor.arglist('DATABASE_LINK', 'DBLINK_SOURCE')); 
end; 
/

7. Test Execution in 11g
NOTE : You may want to flush shared pool and buffer cache of 11g before this execution.

begin 
DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( 
task_name => 'SPA_TEST__20210817', 
execution_type => 'TEST EXECUTE', 
execution_name => 'EXEC_TARGET');
end; 
/

8. Execute the Comparison report

begin 
DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( 
task_name => 'SPA_TEST__20210817', 
execution_type => 'COMPARE PERFORMANCE', 
execution_name => 'Compare_elapsed_time', 
execution_params => dbms_advisor.arglist('execution_name1', 'EXEC_SOURCE', 'execution_name2', 'EXEC_TARGET', 'comparison_metric', 'elapsed_time') ); 
end; 
/

9. Generate the SPA Report


set long 100000 longchunksize 100000 linesize 200 head off feedback off echo off 
spool spa_report_elapsed_time.html 
SELECT dbms_sqlpa.report_analysis_task('SPA_TEST__20210817', 'HTML', 'ALL','ALL', execution_name=>'Compare_elapsed_time') FROM dual; 
spool off




-- This is other alternative for SPA analysys
-- https://mogukiller.wordpress.com/2016/08/25/rat-sql-performance-analyzer/
-- en el anterior link hay informacion de como capturar la info de un determinado sqlid o de los cursores mismos en vez de solo 
-- recolectar la info de las lineas bases de awr
-- analisis de resultados:
exec DBMS_SQLPA.DROP_ANALYSIS_TASK('TASK_TPCC');
  DECLARE
   V_TASK VARCHAR2(100);
  BEGIN
    V_TASK := DBMS_SQLPA.CREATE_ANALYSIS_TASK(SQLSET_NAME => 'STS_database_RAT_PROD_20210817', TASK_NAME => 'TASK_TPCC');
 END;
/


2.7.- Ejecutamos el STS
------------------------------------------
/* nota: el parametro execution_type puede ser =>
            test execute:           Ejecuta la parte DML de las sentencias del STS
            compare performance     Compara performance entre dos ejecuciones.
            explain plan:           Obtenemos los explain plan sin ejecutar las queries.
*/
 
BEGIN
  DBMS_SQLPA.execute_analysis_task(
    task_name       => 'TASK_TPCC',
    execution_type  => 'test execute',
    execution_name  => 'after_change');
END;
/

-- nota: Para ejecutar 'compare performance' seria necesario dos ejecuciones con 'test execute' antes y despues del cambio
 
BEGIN
  DBMS_SQLPA.execute_analysis_task(
    task_name        => 'TASK_TPCC',
    execution_type   => 'compare performance', 
dbms_advisor.arglist('execution_name1','before_change',
                    'execution_name2','after_change',
                    'comparision_metric','disk_reads'); -- compresion_metric puede recibir estos parametros: DISK_READ|OPTIMIZER_COST|BUFFER_GETS
    );
END;
/


 -- Luego se podra ver la performance desde el enterprise manager -> performance -> sql -> sql performance analyzer home