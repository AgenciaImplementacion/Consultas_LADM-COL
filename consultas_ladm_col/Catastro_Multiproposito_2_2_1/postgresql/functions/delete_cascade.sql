-- adjusted function
-- From: https://stackoverflow.com/a/19103574/9802768
CREATE OR REPLACE FUNCTION delete_cascade(p_schema varchar, p_table varchar, p_key varchar, p_recursion varchar[] DEFAULT null)
 RETURNS integer AS $$
DECLARE
    rx record;
    rd record;
    v_sql varchar;
    v_recursion_key varchar;
    recnum integer;
    v_primary_key varchar;
    v_rows integer;
BEGIN
    recnum := 0;
	--selects the primary key of the interest table
    SELECT ccu.column_name INTO v_primary_key
        FROM
        information_schema.table_constraints  tc
        JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name AND ccu.constraint_schema=tc.constraint_schema
        AND tc.constraint_type='PRIMARY KEY'
        AND tc.table_name=p_table
        AND tc.table_schema=p_schema;

    FOR rx IN (
        SELECT DISTINCT kcu.table_name AS foreign_table_name,
        kcu.column_name AS foreign_column_name,
        kcu.table_schema AS foreign_table_schema,
        kcu2.column_name AS foreign_table_primary_key
        FROM information_schema.constraint_column_usage ccu
        JOIN information_schema.table_constraints tc ON tc.constraint_name=ccu.constraint_name AND tc.constraint_catalog=ccu.constraint_catalog AND ccu.constraint_schema=ccu.constraint_schema
        JOIN information_schema.key_column_usage kcu ON kcu.constraint_name=ccu.constraint_name AND kcu.constraint_catalog=ccu.constraint_catalog AND kcu.constraint_schema=ccu.constraint_schema
        JOIN information_schema.table_constraints tc2 ON tc2.table_name=kcu.table_name AND tc2.table_schema=kcu.table_schema
        JOIN information_schema.key_column_usage kcu2 ON kcu2.constraint_name=tc2.constraint_name AND kcu2.constraint_catalog=tc2.constraint_catalog AND kcu2.constraint_schema=tc2.constraint_schema
        WHERE ccu.table_name=p_table  AND ccu.table_schema=p_schema
        AND TC.CONSTRAINT_TYPE='FOREIGN KEY'
        and tc2.constraint_type='PRIMARY KEY'
)
    LOOP
        v_sql := 'select '||rx.foreign_table_primary_key||' as key from '||rx.foreign_table_schema||'.'||rx.foreign_table_name||'
            where '||rx.foreign_column_name||'='||quote_literal(p_key)||' for update';
        --raise notice '%',v_sql;
        --found a foreign key, now find the primary keys for any data that exists in any of those tables.
        FOR rd IN EXECUTE v_sql
        LOOP
            v_recursion_key=rx.foreign_table_schema||'.'||rx.foreign_table_name||'.'||rx.foreign_column_name||'='||rd.key;
            IF (v_recursion_key = ANY (p_recursion)) THEN
                --raise notice 'Avoiding infinite loop';
            ELSE
                --raise notice 'Recursing to %,%',rx.foreign_table_name, rd.key;
                recnum:= recnum +delete_cascade(rx.foreign_table_schema::varchar, rx.foreign_table_name::varchar, rd.key::varchar, p_recursion||v_recursion_key);
            END IF;
        END LOOP;
    END LOOP;
    BEGIN
    --actually delete original record.
    v_sql := 'delete from '||p_schema||'.'||p_table||' where '||v_primary_key||'='||quote_literal(p_key);
    EXECUTE v_sql;
    GET DIAGNOSTICS v_rows= ROW_COUNT;
    --raise notice 'Deleting %.% %=%',p_schema,p_table,v_primary_key,p_key;
    recnum:= recnum +v_rows;
    EXCEPTION WHEN OTHERS THEN recnum=0;
    END;

    RETURN recnum;
END;
$$
LANGUAGE PLPGSQL;