/*
* Procedimento de Ejemplo Captura  RAT 
* author: Felipe Donoso, felipe.donoso@oracle.com
* creacion: 2016-09-23
*
* ejecutar comando por comando y enviarnos la evidencia por favor.
* en caso de algun error por favor no continuar con la ejecucion de comandos
* y darnos aviso
*/


spool sqlset.log

define sqlsettable ='RAT_TABLA_SQLSET'
define sqlset ='RAT_SQLSET'
define baseline ='RAT_BASELINE'


-- Si es primera vez que se ejecuta el presente script dara error 
-- en los siguientes 3 comandos,
-- lo cual es absolutamente normal
EXECUTE DBMS_SQLTUNE.DROP_SQLSET( sqlset_name => '&sqlset' );
DROP TABLE SYSTEM.&sqlsettable ;
EXECUTE DBMS_WORKLOAD_REPOSITORY.DROP_BASELINE (baseline_name => '&baseline');


-- Please create a new snapshot:
execute dbms_workload_repository.create_snapshot();


-- Execute this query and get capture id
-- (the last row it must to be the last capture finished)
column id new_value capture_id
select
max(id) id --,name
from dba_workload_captures ;


-- This will generate dmp into de DB directory capture
-- using the previous capture_id
-- Very important this command
BEGIN
DBMS_WORKLOAD_CAPTURE.EXPORT_AWR (capture_id => &capture_id);
END;
/

 
-- Create baseline using the snaps id beetwen the start and finish capture hours.
column AWR_BEGIN_SNAP new_value begin_snap
column AWR_END_SNAP new_value end_snap
select AWR_BEGIN_SNAP,AWR_END_SNAP
from dba_workload_captures
where id = &capture_id;
EXECUTE DBMS_WORKLOAD_REPOSITORY.CREATE_BASELINE (start_snap_id => &begin_snap, end_snap_id => &end_snap ,baseline_name =>'&baseline');

 
-- Create SQLSET TABLE
BEGIN
DBMS_SQLTUNE.create_stgtab_sqlset (table_name =>'&sqlsettable', schema_name =>'SYSTEM', tablespace_name =>'SYSTEM' );
END;
/


-- Create SQLSET
BEGIN
DBMS_SQLTUNE.CREATE_SQLSET (
sqlset_name => '&sqlset',
description => 'sqlsets de base de datos origen');
END;
/


-- LOAD_SQLSET with the baseline, using the begin and end snap of capture
declare
baseline_ref_cur
DBMS_SQLTUNE.SQLSET_CURSOR;
begin
open baseline_ref_cur
for
select VALUE(p) from
table(
DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(&begin_snap,&end_snap,'parsing_schema_name not in (''DBSNMP'',''SYS'')' ,NULL,NULL,NULL,NULL,NULL,NULL,'ALL'))
p;
DBMS_SQLTUNE.LOAD_SQLSET('&sqlset', baseline_ref_cur);
end;
/

 

-- pack the sqlset into the sqlset_table
BEGIN
DBMS_SQLTUNE.pack_stgtab_sqlset(sqlset_name =>'&sqlset',sqlset_owner => 'SYS',staging_table_name =>'&sqlsettable',staging_schema_owner =>'SYSTEM');
END;
/


spool off



-- por favor indicar en el dump el nombre de la base de datos
-- exportar la tabla y enviarnos el DMP via email o comentarnos en que ruta quedara
exp system/oracle tables=RAT_TABLA_SQLSET file=nombre_de_la_BD_____RAT_TABLA_SQLSET.dmp log=nombre_de_la_BD_____RAT_TABLA_SQLSET.log