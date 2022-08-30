-- Transformacion de las BDs en modo snapshot en exacc destino
-- Antes de comenzar la captura en origen

-- CONVERTIR BDS EN MODO SNAPSHOT
-- BD ERTXPR
-- levantarla en caso de que se encontrara abajo
srvctl start database -d ERTXPR -o mount
alter database recover managed standby database cancel ;
ALTER DATABASE CONVERT TO SNAPSHOT STANDBY;
srvctl stop database -d ERTXPR
srvctl start instance -d ERTXPR -i ERTXPR1 -o open 
srvctl start instance -d ERTXPR -i ERTXPR2 -o open 
srvctl start instance -d ERTXPR -i ERTXPR3 -o open 
srvctl start instance -d ERTXPR -i ERTXPR4 -o open 
-- Revisar el status de la snapshot standby
SELECT flashback_on FROM v$database;
--revisar los grupos existentes de redos
-- ya que al levantar las instancias 3 y 4 puede que no existan y se deben crear
--select THREAD#, GROUP#, MEMBERS, round(bytes/1024/1024,2) MB from V$log order by 1,2;
ALTER DATABASE ADD LOGFILE THREAD 3 GROUP 300 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 3 GROUP 320 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 3 GROUP 321 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 3 GROUP 322 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 3 GROUP 323 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 4 GROUP 419 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 4 GROUP 420 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 4 GROUP 421 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 4 GROUP 422 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 4 GROUP 423 '+DATAC1' SIZE 4096m;
-- borrar estos redologs antiguos que no se usaran de THREAD3 y THREAD4 (ademas son de 100MB y no sirven)
ALTER DATABASE DROP LOGFILE GROUP 1;
ALTER DATABASE DROP LOGFILE GROUP 2;
ALTER DATABASE DROP LOGFILE GROUP 3;
ALTER DATABASE DROP LOGFILE GROUP 4;
-- select THREAD#, GROUP#, MEMBERS, round(bytes/1024/1024,2) MB from V$log order by 1,2;
--
-- rollback para volver a dejarla en modo standby
-- para rollback o devolver la BD a modo standby como estaba al comienzo en caso de ser necesario
srvctl stop database -d ERTXPR
srvctl start instance -d ERTXPR -i ERTXPR1 -o mount
ALTER DATABASE CONVERT TO PHYSICAL STANDBY;





-- CONVERTIR BDS EN MODO SNAPSHOT
-- BD EBSCSPR
-- levantarla en caso de que se encontrara abajo
srvctl start database -d EBSCSPR -o mount
alter database recover managed standby database cancel ;
ALTER DATABASE CONVERT TO SNAPSHOT STANDBY;
srvctl stop database -d EBSCSPR
srvctl start instance -d EBSCSPR -i EBSCSPR1 -o open 
srvctl start instance -d EBSCSPR -i EBSCSPR2 -o open 
srvctl start instance -d EBSCSPR -i EBSCSPR3 -o open 
srvctl start instance -d EBSCSPR -i EBSCSPR4 -o open 
-- Revisar el status de la snapshot standby
SELECT flashback_on FROM v$database;
--revisar los grupos existentes de redos
-- ya que al levantar las instancias 3 y 4 puede que no existan y se deben crear
--select THREAD#, GROUP#, MEMBERS, round(bytes/1024/1024,2) MB from V$log order by 1,2;
ALTER DATABASE ADD LOGFILE THREAD 3 GROUP 300 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 3 GROUP 320 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 3 GROUP 321 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 3 GROUP 322 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 3 GROUP 323 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 3 GROUP 324 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 4 GROUP 419 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 4 GROUP 420 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 4 GROUP 421 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 4 GROUP 422 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 4 GROUP 423 '+DATAC1' SIZE 4096m;
ALTER DATABASE ADD LOGFILE THREAD 4 GROUP 424 '+DATAC1' SIZE 4096m;
-- borrar estos redologs antiguos que no se usaran de THREAD3 y THREAD4 (ademas son de 100MB y no sirven)
ALTER DATABASE DROP LOGFILE GROUP 11;
ALTER DATABASE DROP LOGFILE GROUP 12;
ALTER DATABASE DROP LOGFILE GROUP 13;
ALTER DATABASE DROP LOGFILE GROUP 14;
-- select THREAD#, GROUP#, MEMBERS, round(bytes/1024/1024,2) MB from V$log order by 1,2;
--
-- rollback para volver a dejarla en modo standby
-- para rollback o devolver la BD a modo standby como estaba al comienzo en caso de ser necesario
srvctl stop database -d EBSCSPR
srvctl start instance -d EBSCSPR -i EBSCSPR1 -o mount
ALTER DATABASE CONVERT TO PHYSICAL STANDBY;

