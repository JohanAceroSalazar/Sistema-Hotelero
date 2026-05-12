DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'instructor_role'
    ) THEN

        CREATE ROLE instructor_role
        WITH
            LOGIN
            PASSWORD 'jesusariel'
            NOSUPERUSER
            NOCREATEDB
            NOCREATEROLE
            NOREPLICATION;

    END IF;
END
$$;