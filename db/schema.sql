--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO postgres;

--
-- Name: logs; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA logs;


ALTER SCHEMA logs OWNER TO postgres;

--
-- Name: master; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA master;


ALTER SCHEMA master OWNER TO postgres;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: vehiclecondemnations; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA vehiclecondemnations;


ALTER SCHEMA vehiclecondemnations OWNER TO postgres;

--
-- Name: vehiclecondemnationsBackup; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "vehiclecondemnationsBackup";


ALTER SCHEMA "vehiclecondemnationsBackup" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: invalidate; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.invalidate (
    id bigint NOT NULL,
    username character varying(255) NOT NULL,
    invalidated_at timestamp without time zone NOT NULL,
    ip_address character varying(255)
);


ALTER TABLE auth.invalidate OWNER TO postgres;

--
-- Name: login; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.login (
    usercode integer NOT NULL,
    userid character varying(25) NOT NULL,
    userpassword character varying(512) NOT NULL,
    userpasswordsalt character varying(12) NOT NULL,
    nameofuser character varying(100) NOT NULL,
    departmentcode integer,
    officecode integer,
    userrole character varying(1),
    useraccess boolean
);


ALTER TABLE auth.login OWNER TO postgres;

--
-- Name: password_reset_token; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.password_reset_token (
    id bigint NOT NULL,
    user_code integer,
    token character varying(255),
    expiry timestamp without time zone
);


ALTER TABLE auth.password_reset_token OWNER TO postgres;

--
-- Name: roles_rolecode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_rolecode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_rolecode_seq OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.roles (
    rolecode integer DEFAULT nextval('public.roles_rolecode_seq'::regclass) NOT NULL,
    rolename character varying(255) NOT NULL,
    description character varying(255)
);


ALTER TABLE auth.roles OWNER TO postgres;

--
-- Name: userlogin; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.userlogin (
    usercode integer NOT NULL,
    username character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    departmentcode integer NOT NULL,
    useraccess boolean NOT NULL,
    role character varying(255) NOT NULL,
    CONSTRAINT userlogin_check CHECK (((role)::text = ANY (ARRAY[('TD'::character varying)::text, ('ADMIN'::character varying)::text, ('DA'::character varying)::text, ('ADMINISTRATOR'::character varying)::text, ('SAD1'::character varying)::text, ('SAD2'::character varying)::text])))
);


ALTER TABLE auth.userlogin OWNER TO postgres;

--
-- Name: audit_logs; Type: TABLE; Schema: logs; Owner: postgres
--

CREATE TABLE logs.audit_logs (
    id bigint NOT NULL,
    username character varying(255) NOT NULL,
    uri character varying(255),
    description text,
    action character varying(255),
    status character varying(255),
    ip_address character varying,
    timetsamp timestamp without time zone,
    http_status integer,
    ip_addr character varying(255),
    "timestamp" timestamp(6) without time zone NOT NULL
);


ALTER TABLE logs.audit_logs OWNER TO postgres;

--
-- Name: login; Type: TABLE; Schema: logs; Owner: postgres
--

CREATE TABLE logs.login (
    id bigint NOT NULL,
    http_method character varying(255),
    http_response_status integer,
    "timestamp" timestamp(6) without time zone,
    endpoint character varying(255),
    username character varying(255)
);


ALTER TABLE logs.login OWNER TO postgres;

--
-- Name: logs; Type: TABLE; Schema: logs; Owner: postgres
--

CREATE TABLE logs.logs (
    username character varying,
    event_date timestamp without time zone,
    logger character varying,
    level character varying,
    message character varying,
    stacktrace character varying
);


ALTER TABLE logs.logs OWNER TO postgres;

--
-- Name: departments; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.departments (
    departmentcode integer NOT NULL,
    departmentname character varying(255),
    departmentcode_iobs integer
);


ALTER TABLE master.departments OWNER TO postgres;

--
-- Name: districtrtos; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.districtrtos (
    districtrtocode integer NOT NULL,
    rtocode character varying(255) NOT NULL,
    districtcode integer NOT NULL
);


ALTER TABLE master.districtrtos OWNER TO postgres;

--
-- Name: districts; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.districts (
    districtcode integer NOT NULL,
    districtname character varying(255) NOT NULL,
    lgdcode integer
);


ALTER TABLE master.districts OWNER TO postgres;

--
-- Name: drivers; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.drivers (
    id bigint NOT NULL,
    contact_number character varying(255),
    license_number character varying(255),
    name character varying(255)
);


ALTER TABLE master.drivers OWNER TO postgres;

--
-- Name: drivers_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

ALTER TABLE master.drivers ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME master.drivers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: financialyear; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.financialyear (
    financialyearcode integer NOT NULL,
    financialyearfrom integer,
    financialyearto integer
);


ALTER TABLE master.financialyear OWNER TO postgres;

--
-- Name: offices; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.offices (
    departmentcode integer NOT NULL,
    officecode integer NOT NULL,
    officename character varying(255) NOT NULL
);


ALTER TABLE master.offices OWNER TO postgres;

--
-- Name: pageurls; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.pageurls (
    urlcode integer NOT NULL,
    pageurl character varying(100) NOT NULL,
    subprocessname character varying(100),
    subprocessicon character varying(50),
    processname character varying(100) NOT NULL,
    processicon character varying(50),
    showinmenu boolean NOT NULL
);


ALTER TABLE master.pageurls OWNER TO postgres;

--
-- Name: processes; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.processes (
    processcode integer NOT NULL,
    processname character varying(100) NOT NULL,
    processdescription character varying(255),
    pageurl character varying(50)
);


ALTER TABLE master.processes OWNER TO postgres;

--
-- Name: processflow; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.processflow (
    slno integer NOT NULL,
    fromprocess integer,
    toprocess integer
);


ALTER TABLE master.processflow OWNER TO postgres;

--
-- Name: userpages; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.userpages (
    userpagecode character varying(255) NOT NULL,
    rolecode integer NOT NULL,
    urlcode integer NOT NULL
);


ALTER TABLE master.userpages OWNER TO postgres;

--
-- Name: usersprocesses; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.usersprocesses (
    processcode smallint NOT NULL,
    usercode integer NOT NULL,
    slno integer
);


ALTER TABLE master.usersprocesses OWNER TO postgres;

--
-- Name: vehiclemanufacturers; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.vehiclemanufacturers (
    vehiclemanufacturercode integer NOT NULL,
    vehiclemanufacturername character varying(255) NOT NULL
);


ALTER TABLE master.vehiclemanufacturers OWNER TO postgres;

--
-- Name: vehicleparts; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.vehicleparts (
    vehiclepartcode integer NOT NULL,
    vehiclepartdescription character varying(255) NOT NULL
);


ALTER TABLE master.vehicleparts OWNER TO postgres;

--
-- Name: vehicletypes; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.vehicletypes (
    vehicletypecode integer NOT NULL,
    vehicletypedescription character varying(1000) NOT NULL
);


ALTER TABLE master.vehicletypes OWNER TO postgres;

--
-- Name: audit_logs_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_logs_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_seq OWNER TO postgres;

--
-- Name: invalidate_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invalidate_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invalidate_seq OWNER TO postgres;

--
-- Name: login_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.login_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.login_seq OWNER TO postgres;

--
-- Name: password_reset_token_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.password_reset_token_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.password_reset_token_seq OWNER TO postgres;

--
-- Name: roles_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_seq OWNER TO postgres;

--
-- Name: userlogin_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.userlogin_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.userlogin_seq OWNER TO postgres;

--
-- Name: users_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_seq OWNER TO postgres;

--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicles (
    id integer NOT NULL,
    department_id integer NOT NULL,
    registration_number character varying(50) NOT NULL,
    model character varying(100) NOT NULL,
    purchase_date date NOT NULL,
    purchase_cost numeric(12,2),
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.vehicles OWNER TO postgres;

--
-- Name: vehicles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vehicles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicles_id_seq OWNER TO postgres;

--
-- Name: vehicles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vehicles_id_seq OWNED BY public.vehicles.id;


--
-- Name: allottedvehicles; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.allottedvehicles (
    applicationcode character varying(255) NOT NULL,
    letternodate character varying(100),
    allotteddate date NOT NULL,
    allotteesname character varying(100),
    allotteesaddress character varying(255),
    entrydate date DEFAULT ('now'::text)::date NOT NULL
);


ALTER TABLE vehiclecondemnations.allottedvehicles OWNER TO postgres;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE SEQUENCE vehiclecondemnations.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE vehiclecondemnations.hibernate_sequence OWNER TO postgres;

--
-- Name: liftedvehicles; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.liftedvehicles (
    applicationcode character varying(255) NOT NULL,
    letternodate character varying(100),
    lifteddate date,
    liftersname character varying(100),
    liftersaddress character varying(255),
    liftedmode character varying(1),
    entrydate date DEFAULT ('now'::text)::date NOT NULL
);


ALTER TABLE vehiclecondemnations.liftedvehicles OWNER TO postgres;

--
-- Name: offervehicles; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.offervehicles (
    applicationcode character varying(10) NOT NULL,
    letterno character varying(100),
    entrydate date DEFAULT ('now'::text)::date NOT NULL
);


ALTER TABLE vehiclecondemnations.offervehicles OWNER TO postgres;

--
-- Name: pool_parked; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.pool_parked (
    id bigint NOT NULL,
    department_id bigint,
    vehicle_type_id bigint NOT NULL,
    manufacturer_id bigint NOT NULL,
    model character varying(255) NOT NULL,
    registration_no character varying(255) NOT NULL,
    chassis_no character varying(255) NOT NULL,
    engine_no character varying(255) NOT NULL,
    purchase_date date NOT NULL,
    purchase_cost double precision,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    vehicle_description character varying(255),
    date_of_manufacturing date,
    process_code bigint,
    allotted_date date,
    status character varying(255)
);


ALTER TABLE vehiclecondemnations.pool_parked OWNER TO postgres;

--
-- Name: prints; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.prints (
    departmentname character varying(100),
    userid character varying(25)
);


ALTER TABLE vehiclecondemnations.prints OWNER TO postgres;

--
-- Name: query; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.query (
    applicationcode character varying(10) NOT NULL,
    transportletterno character varying(100),
    transportremarks character varying(255),
    transportentrydate timestamp without time zone DEFAULT ('now'::text)::date,
    officeletterno character varying(100),
    officeremarks character varying(255),
    officeentrydate timestamp without time zone
);


ALTER TABLE vehiclecondemnations.query OWNER TO postgres;

--
-- Name: rejectedvehicles; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.rejectedvehicles (
    slno integer,
    entrydate date,
    letterno character varying,
    remarks character varying,
    applicationcode character varying NOT NULL
);


ALTER TABLE vehiclecondemnations.rejectedvehicles OWNER TO postgres;

--
-- Name: repair_request_problems; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.repair_request_problems (
    id bigint NOT NULL,
    repair_request_id bigint NOT NULL,
    problem_text character varying(255) NOT NULL,
    estimate_amount double precision,
    remark character varying(255)
);


ALTER TABLE vehiclecondemnations.repair_request_problems OWNER TO postgres;

--
-- Name: repair_request_problems_id_seq; Type: SEQUENCE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE SEQUENCE vehiclecondemnations.repair_request_problems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE vehiclecondemnations.repair_request_problems_id_seq OWNER TO postgres;

--
-- Name: repair_request_problems_id_seq; Type: SEQUENCE OWNED BY; Schema: vehiclecondemnations; Owner: postgres
--

ALTER SEQUENCE vehiclecondemnations.repair_request_problems_id_seq OWNED BY vehiclecondemnations.repair_request_problems.id;


--
-- Name: repair_requests; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.repair_requests (
    id bigint NOT NULL,
    vehicle_id bigint,
    department_id integer,
    kilometer_reading integer,
    last_service_date date,
    location character varying(255),
    urgency character varying(255),
    status character varying(255) DEFAULT 'Pending with Transport Department'::character varying,
    process_code bigint,
    approval_order_file character varying(255),
    work_order_file character varying(255),
    sanction_order_file character varying(255),
    estimate_amount double precision,
    td_approved boolean DEFAULT false,
    td_approved_date date
);


ALTER TABLE vehiclecondemnations.repair_requests OWNER TO postgres;

--
-- Name: repair_requests_id_seq; Type: SEQUENCE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE SEQUENCE vehiclecondemnations.repair_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE vehiclecondemnations.repair_requests_id_seq OWNER TO postgres;

--
-- Name: repair_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: vehiclecondemnations; Owner: postgres
--

ALTER SEQUENCE vehiclecondemnations.repair_requests_id_seq OWNED BY vehiclecondemnations.repair_requests.id;


--
-- Name: scrap; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.scrap (
    applicationcode character varying(255) NOT NULL,
    remarks character varying(255),
    letternodate character varying(100),
    amount integer,
    entrydate date DEFAULT ('now'::text)::date NOT NULL,
    slno integer,
    remakrs character varying(255)
);


ALTER TABLE vehiclecondemnations.scrap OWNER TO postgres;

--
-- Name: tendervehicles; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.tendervehicles (
    applicationcode character varying(255) NOT NULL,
    letternodate character varying(100),
    entrydate date DEFAULT ('now'::text)::date NOT NULL,
    slno integer
);


ALTER TABLE vehiclecondemnations.tendervehicles OWNER TO postgres;

--
-- Name: vcctc; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.vcctc (
    applicationcode character varying(255) NOT NULL,
    vcctc character varying(1) DEFAULT 'V'::character varying NOT NULL,
    priceapproved character varying(1) NOT NULL,
    vehicleprice integer,
    letternodate character varying(100),
    entrydate date DEFAULT ('now'::text)::date NOT NULL,
    entry_date date
);


ALTER TABLE vehiclecondemnations.vcctc OWNER TO postgres;

--
-- Name: vcctc_temp; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.vcctc_temp (
    applicationcode character varying(255) NOT NULL,
    vcctc character varying(1) DEFAULT 'V'::character varying,
    priceapproved character varying(1) DEFAULT 'N'::character varying,
    vehicleprice integer,
    letternodate character varying(100),
    entrydate date DEFAULT ('now'::text)::date
);


ALTER TABLE vehiclecondemnations.vcctc_temp OWNER TO postgres;

--
-- Name: vehicle_fleet_id_seq; Type: SEQUENCE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE SEQUENCE vehiclecondemnations.vehicle_fleet_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE vehiclecondemnations.vehicle_fleet_id_seq OWNER TO postgres;

--
-- Name: vehicle_fleet_id_seq; Type: SEQUENCE OWNED BY; Schema: vehiclecondemnations; Owner: postgres
--

ALTER SEQUENCE vehiclecondemnations.vehicle_fleet_id_seq OWNED BY vehiclecondemnations.pool_parked.id;


--
-- Name: vehiclepartsconditions; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.vehiclepartsconditions (
    applicationcode character varying(255) NOT NULL,
    vehiclepartcode integer NOT NULL,
    condition character varying(1000) NOT NULL,
    slno integer
);


ALTER TABLE vehiclecondemnations.vehiclepartsconditions OWNER TO postgres;

--
-- Name: vehiclepartsconditions_draft; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.vehiclepartsconditions_draft (
    applicationcode character varying(255) NOT NULL,
    vehiclepartcode integer NOT NULL,
    condition character varying(1000),
    slno integer
);


ALTER TABLE vehiclecondemnations.vehiclepartsconditions_draft OWNER TO postgres;

--
-- Name: vehicles; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.vehicles (
    applicationmode character varying(255) NOT NULL,
    applicationslno character varying(255) NOT NULL,
    applicationcode character varying(255) NOT NULL,
    departmentcode integer NOT NULL,
    officename character varying(255) NOT NULL,
    directorateletternodate character varying(100),
    officerdesignation character varying(255),
    vehicletypecode integer NOT NULL,
    vehicledescription character varying(1000) NOT NULL,
    vehiclemanufacturercode integer NOT NULL,
    registereddistrict integer NOT NULL,
    registrationno character varying(20) NOT NULL,
    engineno character varying(20) NOT NULL,
    chassisno character varying(20) NOT NULL,
    manufactureyear integer NOT NULL,
    purchasedate date NOT NULL,
    vehicleprice integer NOT NULL,
    improvements character varying(1000),
    totalkms integer NOT NULL,
    expenses integer,
    repairexpenses integer,
    battery character varying(255),
    tyres character varying(255),
    repairslastsixmonths integer,
    accidentdamage character varying(1000),
    accidentcaseresolved character varying(1),
    comments character varying(1000),
    mviprice integer,
    mviremarks character varying(1000),
    processcode integer DEFAULT 1,
    locations character varying(255) NOT NULL,
    govtletternodate character varying(100),
    entrydate date DEFAULT ('now'::text)::date,
    depreciatedamount integer,
    mvireportavailable character varying(1),
    whetheraccident character varying(1),
    financialyearcode integer,
    premises character varying(10000),
    remarks character varying(1000),
    versionflagcode character varying(255) DEFAULT 2 NOT NULL
);


ALTER TABLE vehiclecondemnations.vehicles OWNER TO postgres;

--
-- Name: vehicles_draft; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.vehicles_draft (
    applicationmode character varying(255),
    applicationslno character varying(255),
    applicationcode character varying(255) NOT NULL,
    departmentcode integer,
    officename character varying(255),
    officerdesignation character varying(255),
    premises character varying(255),
    locations character varying(255),
    directorateletternodate character varying(255),
    govtletternodate character varying(255),
    vehicletypecode integer,
    vehicledescription character varying(255),
    vehiclemanufacturercode integer,
    registereddistrict integer,
    registrationno character varying(255),
    engineno character varying(255),
    chassisno character varying(255),
    manufactureyear integer,
    purchasedate date,
    vehicleprice integer,
    totalkms integer,
    depreciatedamount integer,
    improvements character varying(255),
    expenses integer,
    repairexpenses integer,
    repairslastsixmonths integer,
    whetheraccident character varying(255),
    accidentcaseresolved character varying(255),
    comments character varying(255),
    mvireportavailable character varying(255),
    battery character varying(255),
    tyres character varying(255),
    accidentdamage character varying(255),
    mviprice integer,
    mviremarks character varying(255),
    processcode integer,
    entrydate date DEFAULT ('now'::text)::date,
    financialyearcode integer,
    remarks character varying(255),
    versionflagcode character varying(255) DEFAULT 2 NOT NULL
);


ALTER TABLE vehiclecondemnations.vehicles_draft OWNER TO postgres;

--
-- Name: verifications; Type: TABLE; Schema: vehiclecondemnations; Owner: postgres
--

CREATE TABLE vehiclecondemnations.verifications (
    applicationcode character varying(255) NOT NULL,
    letternodate character varying(100),
    entrydate date DEFAULT ('now'::text)::date NOT NULL,
    slno integer,
    remarks character varying(255)
);


ALTER TABLE vehiclecondemnations.verifications OWNER TO postgres;

--
-- Name: allottedvehicles; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".allottedvehicles (
    applicationcode character varying(10) NOT NULL,
    letterno character varying(100),
    allotteddate date NOT NULL,
    allotteesname character varying(100),
    allotteesaddress character varying(255),
    entrydate date DEFAULT ('now'::text)::date NOT NULL
);


ALTER TABLE "vehiclecondemnationsBackup".allottedvehicles OWNER TO postgres;

--
-- Name: departments; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".departments (
    departmentcode integer NOT NULL,
    departmentname character varying(100)
);


ALTER TABLE "vehiclecondemnationsBackup".departments OWNER TO postgres;

--
-- Name: districts; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".districts (
    districtcode smallint NOT NULL,
    districtname character varying(25) NOT NULL,
    dcode character varying
);


ALTER TABLE "vehiclecondemnationsBackup".districts OWNER TO postgres;

--
-- Name: financialyear; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".financialyear (
    slno integer NOT NULL,
    fromyear integer,
    toyear integer
);


ALTER TABLE "vehiclecondemnationsBackup".financialyear OWNER TO postgres;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE SEQUENCE "vehiclecondemnationsBackup".hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "vehiclecondemnationsBackup".hibernate_sequence OWNER TO postgres;

--
-- Name: liftedvehicles; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".liftedvehicles (
    applicationcode character varying(10) NOT NULL,
    letterno character varying(100),
    lifteddate date NOT NULL,
    liftersname character varying(100),
    liftersaddress character varying(255),
    liftedmode character varying(1),
    entrydate date DEFAULT ('now'::text)::date NOT NULL
);


ALTER TABLE "vehiclecondemnationsBackup".liftedvehicles OWNER TO postgres;

--
-- Name: login; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".login (
    usercode integer NOT NULL,
    userid character varying(25) NOT NULL,
    userpassword character varying(512) NOT NULL,
    userpasswordsalt character varying(12) NOT NULL,
    nameofuser character varying(100) NOT NULL,
    departmentcode integer,
    officecode integer,
    userrole character varying(1),
    useraccess boolean
);


ALTER TABLE "vehiclecondemnationsBackup".login OWNER TO postgres;

--
-- Name: offervehicles; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".offervehicles (
    applicationcode character varying(10) NOT NULL,
    letterno character varying(100),
    entrydate date DEFAULT ('now'::text)::date NOT NULL
);


ALTER TABLE "vehiclecondemnationsBackup".offervehicles OWNER TO postgres;

--
-- Name: offices; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".offices (
    departmentcode integer NOT NULL,
    officecode integer NOT NULL,
    officename character varying(255) NOT NULL
);


ALTER TABLE "vehiclecondemnationsBackup".offices OWNER TO postgres;

--
-- Name: prints; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".prints (
    departmentname character varying(100),
    userid character varying(25)
);


ALTER TABLE "vehiclecondemnationsBackup".prints OWNER TO postgres;

--
-- Name: processes; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".processes (
    processcode integer NOT NULL,
    processid integer,
    processname character varying(100) NOT NULL,
    description character varying(255),
    pageurl character varying(50),
    additionalprocessingurl character varying(255),
    status character varying(1),
    btn character varying(255)
);


ALTER TABLE "vehiclecondemnationsBackup".processes OWNER TO postgres;

--
-- Name: processflow; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".processflow (
    slno integer NOT NULL,
    fromprocess integer,
    toprocess integer
);


ALTER TABLE "vehiclecondemnationsBackup".processflow OWNER TO postgres;

--
-- Name: query; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".query (
    applicationcode character varying(10) NOT NULL,
    transportletterno character varying(100),
    transportremarks character varying(255),
    transportentrydate timestamp without time zone DEFAULT ('now'::text)::date,
    officeletterno character varying(100),
    officeremarks character varying(255),
    officeentrydate timestamp without time zone
);


ALTER TABLE "vehiclecondemnationsBackup".query OWNER TO postgres;

--
-- Name: rejectedvehicles; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".rejectedvehicles (
    slno integer,
    entrydate date,
    letterno character varying,
    remarks character varying,
    applicationcode character varying NOT NULL
);


ALTER TABLE "vehiclecondemnationsBackup".rejectedvehicles OWNER TO postgres;

--
-- Name: scrap; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".scrap (
    applicationcode character varying(10) NOT NULL,
    remarks character varying(255),
    letterno character varying(100),
    amount integer,
    entrydate date DEFAULT ('now'::text)::date NOT NULL,
    slno integer
);


ALTER TABLE "vehiclecondemnationsBackup".scrap OWNER TO postgres;

--
-- Name: tendervehicles; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".tendervehicles (
    applicationcode character varying(10) NOT NULL,
    letterno character varying(100),
    entrydate date DEFAULT ('now'::text)::date NOT NULL,
    slno integer
);


ALTER TABLE "vehiclecondemnationsBackup".tendervehicles OWNER TO postgres;

--
-- Name: usersprocesses; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".usersprocesses (
    processcode smallint NOT NULL,
    usercode integer NOT NULL,
    slno integer
);


ALTER TABLE "vehiclecondemnationsBackup".usersprocesses OWNER TO postgres;

--
-- Name: vcctc; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".vcctc (
    applicationcode character varying(10) NOT NULL,
    vcctc character varying(1) NOT NULL,
    priceapproved character varying(1) NOT NULL,
    vehicleprice integer,
    letterno character varying(100),
    entrydate date DEFAULT ('now'::text)::date NOT NULL
);


ALTER TABLE "vehiclecondemnationsBackup".vcctc OWNER TO postgres;

--
-- Name: vcctc_temp; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".vcctc_temp (
    applicationcode character varying(10),
    vcctc character varying(1),
    priceapproved character varying(1),
    vehicleprice integer,
    letterno character varying(100),
    entrydate date
);


ALTER TABLE "vehiclecondemnationsBackup".vcctc_temp OWNER TO postgres;

--
-- Name: vehiclemanufacturers; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".vehiclemanufacturers (
    manufacturercode smallint NOT NULL,
    manufacturername character varying(100) NOT NULL
);


ALTER TABLE "vehiclecondemnationsBackup".vehiclemanufacturers OWNER TO postgres;

--
-- Name: vehicleparts; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".vehicleparts (
    vehiclepartcode smallint NOT NULL,
    vehiclepartdescriptions character varying(100) NOT NULL
);


ALTER TABLE "vehiclecondemnationsBackup".vehicleparts OWNER TO postgres;

--
-- Name: vehiclepartsconditions; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".vehiclepartsconditions (
    applicationcode character varying(10) NOT NULL,
    vehiclepartcode smallint NOT NULL,
    condition character varying(1000) NOT NULL,
    slno integer
);


ALTER TABLE "vehiclecondemnationsBackup".vehiclepartsconditions OWNER TO postgres;

--
-- Name: vehicles; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".vehicles (
    applicationmode character varying(1) NOT NULL,
    applicationslno integer NOT NULL,
    applicationcode character varying(10) NOT NULL,
    officecodeb integer NOT NULL,
    officecodea character varying(255) NOT NULL,
    letternodate character varying(100),
    designation character varying(255),
    vehiclecategorycode smallint NOT NULL,
    description character varying(1000) NOT NULL,
    manufacturercode smallint NOT NULL,
    registereddistrict smallint NOT NULL,
    registrationo character varying(20) NOT NULL,
    engineno character varying(20) NOT NULL,
    chassisno character varying(20) NOT NULL,
    manufactureyear integer NOT NULL,
    purchasedate date NOT NULL,
    vehicleprice integer NOT NULL,
    improvements character varying(1000),
    totalkms integer NOT NULL,
    expenses integer,
    repairexpenses integer,
    battery character varying(255),
    tyres character varying(255),
    repairslastsixmonths integer,
    accidentdamage character varying(1000),
    accidentcaseresolved character varying(1),
    comments character varying(1000),
    mviprice integer,
    mviremarks character varying(1000),
    processcode integer DEFAULT 1,
    locations character varying(255) NOT NULL,
    govtletternodate character varying(100),
    entrydate date DEFAULT ('now'::text)::date,
    depreciatedamount integer,
    mvireportavailable character varying(1),
    whetheraccident character varying(1),
    financialyearcode integer
);


ALTER TABLE "vehiclecondemnationsBackup".vehicles OWNER TO postgres;

--
-- Name: vehicles_draft; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".vehicles_draft (
    applicationcode character varying(255) NOT NULL,
    accidentcaseresolved character varying(1),
    accidentdamage character varying(1000),
    applicationmode character varying(1),
    applicationslno integer,
    battery character varying(255),
    chassisno character varying(20),
    comments character varying(1000),
    depreciatedamount integer,
    description character varying(1000),
    designation character varying(255),
    engineno character varying(20),
    entrydate date,
    expenses integer,
    govtletternodate character varying(100),
    improvements character varying(1000),
    letternodate character varying(100),
    locations character varying(255),
    manufactureyear integer,
    mviprice integer,
    mviremarks character varying(1000),
    mvireportavailable character varying(1),
    officecodea character varying(255),
    purchasedate date,
    registrationo character varying(20),
    repairexpenses integer,
    repairslastsixmonths integer,
    totalkms integer,
    tyres character varying(255),
    vehicleprice integer,
    whetheraccident character varying(1),
    registereddistrict integer,
    financialyearcode integer,
    manufacturercode integer,
    officecodeb integer,
    processcode integer,
    vehiclecategorycode integer
);


ALTER TABLE "vehiclecondemnationsBackup".vehicles_draft OWNER TO postgres;

--
-- Name: vehicletypes; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".vehicletypes (
    vehicletypecode smallint NOT NULL,
    vehicletypedescription character varying(1000) NOT NULL
);


ALTER TABLE "vehiclecondemnationsBackup".vehicletypes OWNER TO postgres;

--
-- Name: verifications; Type: TABLE; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE TABLE "vehiclecondemnationsBackup".verifications (
    applicationcode character varying(10) NOT NULL,
    letterno character varying(100),
    entrydate date DEFAULT ('now'::text)::date NOT NULL,
    slno integer,
    remarks character varying
);


ALTER TABLE "vehiclecondemnationsBackup".verifications OWNER TO postgres;

--
-- Name: vehicles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles ALTER COLUMN id SET DEFAULT nextval('public.vehicles_id_seq'::regclass);


--
-- Name: pool_parked id; Type: DEFAULT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.pool_parked ALTER COLUMN id SET DEFAULT nextval('vehiclecondemnations.vehicle_fleet_id_seq'::regclass);


--
-- Name: repair_request_problems id; Type: DEFAULT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.repair_request_problems ALTER COLUMN id SET DEFAULT nextval('vehiclecondemnations.repair_request_problems_id_seq'::regclass);


--
-- Name: repair_requests id; Type: DEFAULT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.repair_requests ALTER COLUMN id SET DEFAULT nextval('vehiclecondemnations.repair_requests_id_seq'::regclass);


--
-- Name: invalidate invalidate_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.invalidate
    ADD CONSTRAINT invalidate_pkey PRIMARY KEY (id);


--
-- Name: login login_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.login
    ADD CONSTRAINT login_pkey PRIMARY KEY (usercode);


--
-- Name: password_reset_token password_reset_token_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.password_reset_token
    ADD CONSTRAINT password_reset_token_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (rolecode);


--
-- Name: login uk_login; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.login
    ADD CONSTRAINT uk_login UNIQUE (userid);


--
-- Name: userlogin ukey_username; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.userlogin
    ADD CONSTRAINT ukey_username UNIQUE (username);


--
-- Name: userlogin userlogin_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.userlogin
    ADD CONSTRAINT userlogin_pkey PRIMARY KEY (usercode);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: logs; Owner: postgres
--

ALTER TABLE ONLY logs.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: login login_pkey; Type: CONSTRAINT; Schema: logs; Owner: postgres
--

ALTER TABLE ONLY logs.login
    ADD CONSTRAINT login_pkey PRIMARY KEY (id);


--
-- Name: districtrtos districtrto_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.districtrtos
    ADD CONSTRAINT districtrto_pkey PRIMARY KEY (districtrtocode);


--
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (districtcode);


--
-- Name: drivers drivers_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (id);


--
-- Name: offices offices_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (officecode);


--
-- Name: pageurls pageurls_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.pageurls
    ADD CONSTRAINT pageurls_pkey PRIMARY KEY (urlcode);


--
-- Name: processes pk_processes; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.processes
    ADD CONSTRAINT pk_processes PRIMARY KEY (processcode);


--
-- Name: financialyear pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.financialyear
    ADD CONSTRAINT pkey PRIMARY KEY (financialyearcode);


--
-- Name: usersprocesses pkuserprocesses; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.usersprocesses
    ADD CONSTRAINT pkuserprocesses PRIMARY KEY (processcode, usercode);


--
-- Name: processflow prkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.processflow
    ADD CONSTRAINT prkey PRIMARY KEY (slno);


--
-- Name: departments sm_departments_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.departments
    ADD CONSTRAINT sm_departments_pkey PRIMARY KEY (departmentcode);


--
-- Name: userpages userpages_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.userpages
    ADD CONSTRAINT userpages_pkey PRIMARY KEY (rolecode, urlcode);


--
-- Name: vehiclemanufacturers vehiclemanufacturers_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.vehiclemanufacturers
    ADD CONSTRAINT vehiclemanufacturers_pkey PRIMARY KEY (vehiclemanufacturercode);


--
-- Name: vehicleparts vehicleparts_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.vehicleparts
    ADD CONSTRAINT vehicleparts_pkey PRIMARY KEY (vehiclepartcode);


--
-- Name: vehicletypes vehicletypes_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.vehicletypes
    ADD CONSTRAINT vehicletypes_pkey PRIMARY KEY (vehicletypecode);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


--
-- Name: vehicles vehicles_registration_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_registration_number_key UNIQUE (registration_number);


--
-- Name: allottedvehicles allottedvehicles_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.allottedvehicles
    ADD CONSTRAINT allottedvehicles_pkey PRIMARY KEY (applicationcode);


--
-- Name: rejectedvehicles key; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.rejectedvehicles
    ADD CONSTRAINT key PRIMARY KEY (applicationcode);


--
-- Name: liftedvehicles liftedvehicles_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.liftedvehicles
    ADD CONSTRAINT liftedvehicles_pkey PRIMARY KEY (applicationcode);


--
-- Name: offervehicles offervehicles_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.offervehicles
    ADD CONSTRAINT offervehicles_pkey PRIMARY KEY (applicationcode);


--
-- Name: repair_request_problems repair_request_problems_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.repair_request_problems
    ADD CONSTRAINT repair_request_problems_pkey PRIMARY KEY (id);


--
-- Name: repair_requests repair_requests_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.repair_requests
    ADD CONSTRAINT repair_requests_pkey PRIMARY KEY (id);


--
-- Name: scrap scrap_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.scrap
    ADD CONSTRAINT scrap_pkey PRIMARY KEY (applicationcode, entrydate);


--
-- Name: tendervehicles tendervehicles_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.tendervehicles
    ADD CONSTRAINT tendervehicles_pkey PRIMARY KEY (applicationcode);


--
-- Name: vcctc vcctc_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vcctc
    ADD CONSTRAINT vcctc_pkey PRIMARY KEY (applicationcode, vcctc);


--
-- Name: vcctc_temp vcctc_temp_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vcctc_temp
    ADD CONSTRAINT vcctc_temp_pkey PRIMARY KEY (applicationcode);


--
-- Name: pool_parked vehicle_fleet_chassis_no_key; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.pool_parked
    ADD CONSTRAINT vehicle_fleet_chassis_no_key UNIQUE (chassis_no);


--
-- Name: pool_parked vehicle_fleet_engine_no_key; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.pool_parked
    ADD CONSTRAINT vehicle_fleet_engine_no_key UNIQUE (engine_no);


--
-- Name: pool_parked vehicle_fleet_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.pool_parked
    ADD CONSTRAINT vehicle_fleet_pkey PRIMARY KEY (id);


--
-- Name: pool_parked vehicle_fleet_registration_no_key; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.pool_parked
    ADD CONSTRAINT vehicle_fleet_registration_no_key UNIQUE (registration_no);


--
-- Name: vehiclepartsconditions_draft vehiclepartsconditions_draft_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehiclepartsconditions_draft
    ADD CONSTRAINT vehiclepartsconditions_draft_pkey PRIMARY KEY (applicationcode, vehiclepartcode);


--
-- Name: vehiclepartsconditions vehiclepartsconditions_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehiclepartsconditions
    ADD CONSTRAINT vehiclepartsconditions_pkey PRIMARY KEY (applicationcode, vehiclepartcode);


--
-- Name: vehicles vehicles_applicationslno_key; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles
    ADD CONSTRAINT vehicles_applicationslno_key UNIQUE (applicationslno);


--
-- Name: vehicles_draft vehicles_draft_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles_draft
    ADD CONSTRAINT vehicles_draft_pkey PRIMARY KEY (applicationcode);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (applicationcode);


--
-- Name: verifications verifications_pkey; Type: CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.verifications
    ADD CONSTRAINT verifications_pkey PRIMARY KEY (applicationcode);


--
-- Name: allottedvehicles allottedvehicles_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".allottedvehicles
    ADD CONSTRAINT allottedvehicles_pkey PRIMARY KEY (applicationcode);


--
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (districtcode);


--
-- Name: rejectedvehicles key; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".rejectedvehicles
    ADD CONSTRAINT key PRIMARY KEY (applicationcode);


--
-- Name: liftedvehicles liftedvehicles_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".liftedvehicles
    ADD CONSTRAINT liftedvehicles_pkey PRIMARY KEY (applicationcode);


--
-- Name: login login_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".login
    ADD CONSTRAINT login_pkey PRIMARY KEY (usercode);


--
-- Name: offervehicles offervehicles_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".offervehicles
    ADD CONSTRAINT offervehicles_pkey PRIMARY KEY (applicationcode);


--
-- Name: offices offices_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (officecode);


--
-- Name: processes pk_processes; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".processes
    ADD CONSTRAINT pk_processes PRIMARY KEY (processcode);


--
-- Name: financialyear pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".financialyear
    ADD CONSTRAINT pkey PRIMARY KEY (slno);


--
-- Name: usersprocesses pkuserprocesses; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".usersprocesses
    ADD CONSTRAINT pkuserprocesses PRIMARY KEY (processcode, usercode);


--
-- Name: processflow prkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".processflow
    ADD CONSTRAINT prkey PRIMARY KEY (slno);


--
-- Name: scrap scrap_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".scrap
    ADD CONSTRAINT scrap_pkey PRIMARY KEY (applicationcode, entrydate);


--
-- Name: departments sm_departments_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".departments
    ADD CONSTRAINT sm_departments_pkey PRIMARY KEY (departmentcode);


--
-- Name: tendervehicles tendervehicles_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".tendervehicles
    ADD CONSTRAINT tendervehicles_pkey PRIMARY KEY (applicationcode);


--
-- Name: login uk_login; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".login
    ADD CONSTRAINT uk_login UNIQUE (userid);


--
-- Name: vcctc vcctc_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vcctc
    ADD CONSTRAINT vcctc_pkey PRIMARY KEY (applicationcode, vcctc);


--
-- Name: vehiclemanufacturers vehiclemanufacturers_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehiclemanufacturers
    ADD CONSTRAINT vehiclemanufacturers_pkey PRIMARY KEY (manufacturercode);


--
-- Name: vehicleparts vehicleparts_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicleparts
    ADD CONSTRAINT vehicleparts_pkey PRIMARY KEY (vehiclepartcode);


--
-- Name: vehiclepartsconditions vehiclepartsconditions_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehiclepartsconditions
    ADD CONSTRAINT vehiclepartsconditions_pkey PRIMARY KEY (applicationcode, vehiclepartcode);


--
-- Name: vehicles vehicles_applicationslno_key; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles
    ADD CONSTRAINT vehicles_applicationslno_key UNIQUE (applicationslno);


--
-- Name: vehicles_draft vehicles_draft_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles_draft
    ADD CONSTRAINT vehicles_draft_pkey PRIMARY KEY (applicationcode);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (applicationcode);


--
-- Name: vehicletypes vehicletypes_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicletypes
    ADD CONSTRAINT vehicletypes_pkey PRIMARY KEY (vehicletypecode);


--
-- Name: verifications verifications_pkey; Type: CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".verifications
    ADD CONSTRAINT verifications_pkey PRIMARY KEY (applicationcode);


--
-- Name: fki_financialyearkey; Type: INDEX; Schema: vehiclecondemnations; Owner: postgres
--

CREATE INDEX fki_financialyearkey ON vehiclecondemnations.vehicles USING btree (financialyearcode);


--
-- Name: fki_financialyearkey; Type: INDEX; Schema: vehiclecondemnationsBackup; Owner: postgres
--

CREATE INDEX fki_financialyearkey ON "vehiclecondemnationsBackup".vehicles USING btree (financialyearcode);


--
-- Name: login fk625ef696d9c5c5b; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.login
    ADD CONSTRAINT fk625ef696d9c5c5b FOREIGN KEY (departmentcode) REFERENCES master.departments(departmentcode);


--
-- Name: userlogin fkey_dept_code; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.userlogin
    ADD CONSTRAINT fkey_dept_code FOREIGN KEY (departmentcode) REFERENCES master.departments(departmentcode) NOT VALID;


--
-- Name: invalidate fkey_username; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.invalidate
    ADD CONSTRAINT fkey_username FOREIGN KEY (username) REFERENCES auth.userlogin(username) NOT VALID;


--
-- Name: login login_departmentcode_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.login
    ADD CONSTRAINT login_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES master.departments(departmentcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: login login_officecode_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.login
    ADD CONSTRAINT login_officecode_fkey FOREIGN KEY (officecode) REFERENCES master.offices(officecode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: userlogin userlogin_departmentcode_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.userlogin
    ADD CONSTRAINT userlogin_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES master.departments(departmentcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: audit_logs fkey_username; Type: FK CONSTRAINT; Schema: logs; Owner: postgres
--

ALTER TABLE ONLY logs.audit_logs
    ADD CONSTRAINT fkey_username FOREIGN KEY (username) REFERENCES auth.userlogin(username) NOT VALID;


--
-- Name: districtrtos districtrto_districtcode_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.districtrtos
    ADD CONSTRAINT districtrto_districtcode_fkey FOREIGN KEY (districtcode) REFERENCES master.districts(districtcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: usersprocesses fk31e40655e66177b4; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.usersprocesses
    ADD CONSTRAINT fk31e40655e66177b4 FOREIGN KEY (processcode) REFERENCES master.processes(processcode);


--
-- Name: offices fka3b099376d9c5c5b; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.offices
    ADD CONSTRAINT fka3b099376d9c5c5b FOREIGN KEY (departmentcode) REFERENCES master.departments(departmentcode);


--
-- Name: processflow fkc1a501d17a5a6c; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.processflow
    ADD CONSTRAINT fkc1a501d17a5a6c FOREIGN KEY (toprocess) REFERENCES master.processes(processcode);


--
-- Name: processflow fkc1a501d68356e5d; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.processflow
    ADD CONSTRAINT fkc1a501d68356e5d FOREIGN KEY (fromprocess) REFERENCES master.processes(processcode);


--
-- Name: usersprocesses fkprocessup; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.usersprocesses
    ADD CONSTRAINT fkprocessup FOREIGN KEY (processcode) REFERENCES master.processes(processcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: usersprocesses fpusersup; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.usersprocesses
    ADD CONSTRAINT fpusersup FOREIGN KEY (usercode) REFERENCES auth.login(usercode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: offices offices_departmentcode_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.offices
    ADD CONSTRAINT offices_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES master.departments(departmentcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: userpages userpages_rolecode_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.userpages
    ADD CONSTRAINT userpages_rolecode_fkey FOREIGN KEY (rolecode) REFERENCES auth.roles(rolecode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: userpages userpages_urlcode_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.userpages
    ADD CONSTRAINT userpages_urlcode_fkey FOREIGN KEY (urlcode) REFERENCES master.pageurls(urlcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: allottedvehicles allottedvehicles_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.allottedvehicles
    ADD CONSTRAINT allottedvehicles_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES vehiclecondemnations.vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pool_parked fk_department; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.pool_parked
    ADD CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES master.departments(departmentcode);


--
-- Name: pool_parked fk_manufacturer; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.pool_parked
    ADD CONSTRAINT fk_manufacturer FOREIGN KEY (manufacturer_id) REFERENCES master.vehiclemanufacturers(vehiclemanufacturercode);


--
-- Name: repair_requests fk_repair_requests_department; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.repair_requests
    ADD CONSTRAINT fk_repair_requests_department FOREIGN KEY (department_id) REFERENCES master.departments(departmentcode);


--
-- Name: pool_parked fk_vehicle_type; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.pool_parked
    ADD CONSTRAINT fk_vehicle_type FOREIGN KEY (vehicle_type_id) REFERENCES master.vehicletypes(vehicletypecode);


--
-- Name: rejectedvehicles fkbb240d4536e35729; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.rejectedvehicles
    ADD CONSTRAINT fkbb240d4536e35729 FOREIGN KEY (applicationcode) REFERENCES vehiclecondemnations.vehicles(applicationcode);


--
-- Name: liftedvehicles liftedvehicles_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.liftedvehicles
    ADD CONSTRAINT liftedvehicles_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES vehiclecondemnations.vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: offervehicles offervehicles_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.offervehicles
    ADD CONSTRAINT offervehicles_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES vehiclecondemnations.vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: repair_request_problems repair_request_problems_repair_request_id_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.repair_request_problems
    ADD CONSTRAINT repair_request_problems_repair_request_id_fkey FOREIGN KEY (repair_request_id) REFERENCES vehiclecondemnations.repair_requests(id) ON DELETE CASCADE;


--
-- Name: repair_requests repair_requests_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.repair_requests
    ADD CONSTRAINT repair_requests_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES vehiclecondemnations.pool_parked(id);


--
-- Name: scrap scrap_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.scrap
    ADD CONSTRAINT scrap_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES vehiclecondemnations.vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: tendervehicles tendervehicles_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.tendervehicles
    ADD CONSTRAINT tendervehicles_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES vehiclecondemnations.vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: vcctc vcctc_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vcctc
    ADD CONSTRAINT vcctc_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES vehiclecondemnations.vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: vcctc_temp vcctc_temp_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vcctc_temp
    ADD CONSTRAINT vcctc_temp_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES vehiclecondemnations.vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehiclepartsconditions vehiclepartsconditions_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehiclepartsconditions
    ADD CONSTRAINT vehiclepartsconditions_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES vehiclecondemnations.vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehiclepartsconditions_draft vehiclepartsconditions_draft_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehiclepartsconditions_draft
    ADD CONSTRAINT vehiclepartsconditions_draft_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES vehiclecondemnations.vehicles_draft(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehiclepartsconditions_draft vehiclepartsconditions_draft_vehiclepartcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehiclepartsconditions_draft
    ADD CONSTRAINT vehiclepartsconditions_draft_vehiclepartcode_fkey FOREIGN KEY (vehiclepartcode) REFERENCES master.vehicleparts(vehiclepartcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehiclepartsconditions vehiclepartsconditions_vehiclepartcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehiclepartsconditions
    ADD CONSTRAINT vehiclepartsconditions_vehiclepartcode_fkey FOREIGN KEY (vehiclepartcode) REFERENCES master.vehicleparts(vehiclepartcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehicles vehicles_departmentcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles
    ADD CONSTRAINT vehicles_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES master.departments(departmentcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehicles_draft vehicles_draft_departmentcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles_draft
    ADD CONSTRAINT vehicles_draft_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES master.departments(departmentcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehicles_draft vehicles_draft_financialyearcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles_draft
    ADD CONSTRAINT vehicles_draft_financialyearcode_fkey FOREIGN KEY (financialyearcode) REFERENCES master.financialyear(financialyearcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehicles_draft vehicles_draft_processcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles_draft
    ADD CONSTRAINT vehicles_draft_processcode_fkey FOREIGN KEY (processcode) REFERENCES master.processes(processcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehicles_draft vehicles_draft_registereddistrict_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles_draft
    ADD CONSTRAINT vehicles_draft_registereddistrict_fkey FOREIGN KEY (registereddistrict) REFERENCES master.districts(districtcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehicles_draft vehicles_draft_vehiclemanufacturercode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles_draft
    ADD CONSTRAINT vehicles_draft_vehiclemanufacturercode_fkey FOREIGN KEY (vehiclemanufacturercode) REFERENCES master.vehiclemanufacturers(vehiclemanufacturercode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehicles_draft vehicles_draft_vehicletypecode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles_draft
    ADD CONSTRAINT vehicles_draft_vehicletypecode_fkey FOREIGN KEY (vehicletypecode) REFERENCES master.vehicletypes(vehicletypecode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehicles vehicles_financialyearcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles
    ADD CONSTRAINT vehicles_financialyearcode_fkey FOREIGN KEY (financialyearcode) REFERENCES master.financialyear(financialyearcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehicles vehicles_processcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles
    ADD CONSTRAINT vehicles_processcode_fkey FOREIGN KEY (processcode) REFERENCES master.processes(processcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehicles vehicles_registereddistrict_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles
    ADD CONSTRAINT vehicles_registereddistrict_fkey FOREIGN KEY (registereddistrict) REFERENCES master.districts(districtcode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehicles vehicles_vehiclemanufacturercode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles
    ADD CONSTRAINT vehicles_vehiclemanufacturercode_fkey FOREIGN KEY (vehiclemanufacturercode) REFERENCES master.vehiclemanufacturers(vehiclemanufacturercode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: vehicles vehicles_vehicletypecode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.vehicles
    ADD CONSTRAINT vehicles_vehicletypecode_fkey FOREIGN KEY (vehicletypecode) REFERENCES master.vehicletypes(vehicletypecode) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- Name: verifications verifications_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnations; Owner: postgres
--

ALTER TABLE ONLY vehiclecondemnations.verifications
    ADD CONSTRAINT verifications_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES vehiclecondemnations.vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: allottedvehicles allottedvehicles_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".allottedvehicles
    ADD CONSTRAINT allottedvehicles_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: vehicles financialyearkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles
    ADD CONSTRAINT financialyearkey FOREIGN KEY (financialyearcode) REFERENCES "vehiclecondemnationsBackup".financialyear(slno);


--
-- Name: usersprocesses fk31e40655e66177b4; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".usersprocesses
    ADD CONSTRAINT fk31e40655e66177b4 FOREIGN KEY (processcode) REFERENCES "vehiclecondemnationsBackup".processes(processcode);


--
-- Name: verifications fk4934edb836e35729; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".verifications
    ADD CONSTRAINT fk4934edb836e35729 FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode);


--
-- Name: login fk625ef696d9c5c5b; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".login
    ADD CONSTRAINT fk625ef696d9c5c5b FOREIGN KEY (departmentcode) REFERENCES "vehiclecondemnationsBackup".departments(departmentcode);


--
-- Name: scrap fk68347d136e35729; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".scrap
    ADD CONSTRAINT fk68347d136e35729 FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode);


--
-- Name: vehicles fk780e56c733b124b; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles
    ADD CONSTRAINT fk780e56c733b124b FOREIGN KEY (officecodeb) REFERENCES "vehiclecondemnationsBackup".offices(officecode);


--
-- Name: vehicles fk780e56c767fd1e30; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles
    ADD CONSTRAINT fk780e56c767fd1e30 FOREIGN KEY (registereddistrict) REFERENCES "vehiclecondemnationsBackup".districts(districtcode);


--
-- Name: vehicles fk780e56c7bc7435f9; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles
    ADD CONSTRAINT fk780e56c7bc7435f9 FOREIGN KEY (manufacturercode) REFERENCES "vehiclecondemnationsBackup".vehiclemanufacturers(manufacturercode);


--
-- Name: vehicles fk780e56c7ca13a889; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles
    ADD CONSTRAINT fk780e56c7ca13a889 FOREIGN KEY (vehiclecategorycode) REFERENCES "vehiclecondemnationsBackup".vehicletypes(vehicletypecode);


--
-- Name: vehicles fk780e56c7e66177b4; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles
    ADD CONSTRAINT fk780e56c7e66177b4 FOREIGN KEY (processcode) REFERENCES "vehiclecondemnationsBackup".processes(processcode);


--
-- Name: vehicles fk780e56c7e8760574; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles
    ADD CONSTRAINT fk780e56c7e8760574 FOREIGN KEY (financialyearcode) REFERENCES "vehiclecondemnationsBackup".financialyear(slno);


--
-- Name: offices fka3b099376d9c5c5b; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".offices
    ADD CONSTRAINT fka3b099376d9c5c5b FOREIGN KEY (departmentcode) REFERENCES "vehiclecondemnationsBackup".departments(departmentcode);


--
-- Name: rejectedvehicles fkbb240d4536e35729; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".rejectedvehicles
    ADD CONSTRAINT fkbb240d4536e35729 FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode);


--
-- Name: vehiclepartsconditions fkbc5eecec36e35729; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehiclepartsconditions
    ADD CONSTRAINT fkbc5eecec36e35729 FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode);


--
-- Name: vehiclepartsconditions fkbc5eecece7590565; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehiclepartsconditions
    ADD CONSTRAINT fkbc5eecece7590565 FOREIGN KEY (vehiclepartcode) REFERENCES "vehiclecondemnationsBackup".vehicleparts(vehiclepartcode);


--
-- Name: processflow fkc1a501d17a5a6c; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".processflow
    ADD CONSTRAINT fkc1a501d17a5a6c FOREIGN KEY (toprocess) REFERENCES "vehiclecondemnationsBackup".processes(processcode);


--
-- Name: processflow fkc1a501d68356e5d; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".processflow
    ADD CONSTRAINT fkc1a501d68356e5d FOREIGN KEY (fromprocess) REFERENCES "vehiclecondemnationsBackup".processes(processcode);


--
-- Name: tendervehicles fkc95d359b36e35729; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".tendervehicles
    ADD CONSTRAINT fkc95d359b36e35729 FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode);


--
-- Name: vehicles_draft fkd440c22933b124b; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles_draft
    ADD CONSTRAINT fkd440c22933b124b FOREIGN KEY (officecodeb) REFERENCES "vehiclecondemnationsBackup".offices(officecode);


--
-- Name: vehicles_draft fkd440c22967fd1e30; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles_draft
    ADD CONSTRAINT fkd440c22967fd1e30 FOREIGN KEY (registereddistrict) REFERENCES "vehiclecondemnationsBackup".districts(districtcode);


--
-- Name: vehicles_draft fkd440c229bc7435f9; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles_draft
    ADD CONSTRAINT fkd440c229bc7435f9 FOREIGN KEY (manufacturercode) REFERENCES "vehiclecondemnationsBackup".vehiclemanufacturers(manufacturercode);


--
-- Name: vehicles_draft fkd440c229ca13a889; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles_draft
    ADD CONSTRAINT fkd440c229ca13a889 FOREIGN KEY (vehiclecategorycode) REFERENCES "vehiclecondemnationsBackup".vehicletypes(vehicletypecode);


--
-- Name: vehicles_draft fkd440c229e66177b4; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles_draft
    ADD CONSTRAINT fkd440c229e66177b4 FOREIGN KEY (processcode) REFERENCES "vehiclecondemnationsBackup".processes(processcode);


--
-- Name: vehicles_draft fkd440c229e8760574; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles_draft
    ADD CONSTRAINT fkd440c229e8760574 FOREIGN KEY (financialyearcode) REFERENCES "vehiclecondemnationsBackup".financialyear(slno);


--
-- Name: usersprocesses fkprocessup; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".usersprocesses
    ADD CONSTRAINT fkprocessup FOREIGN KEY (processcode) REFERENCES "vehiclecondemnationsBackup".processes(processcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: usersprocesses fpusersup; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".usersprocesses
    ADD CONSTRAINT fpusersup FOREIGN KEY (usercode) REFERENCES "vehiclecondemnationsBackup".login(usercode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: liftedvehicles liftedvehicles_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".liftedvehicles
    ADD CONSTRAINT liftedvehicles_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: login login_departmentcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".login
    ADD CONSTRAINT login_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES "vehiclecondemnationsBackup".departments(departmentcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: login login_officecode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".login
    ADD CONSTRAINT login_officecode_fkey FOREIGN KEY (officecode) REFERENCES "vehiclecondemnationsBackup".offices(officecode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: offervehicles offervehicles_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".offervehicles
    ADD CONSTRAINT offervehicles_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: offices offices_departmentcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".offices
    ADD CONSTRAINT offices_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES "vehiclecondemnationsBackup".departments(departmentcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: scrap scrap_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".scrap
    ADD CONSTRAINT scrap_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: tendervehicles tendervehicles_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".tendervehicles
    ADD CONSTRAINT tendervehicles_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: vcctc vcctc_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vcctc
    ADD CONSTRAINT vcctc_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: vehiclepartsconditions vehiclepartsconditions_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehiclepartsconditions
    ADD CONSTRAINT vehiclepartsconditions_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: vehicles vehicles_officecodeb_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles
    ADD CONSTRAINT vehicles_officecodeb_fkey FOREIGN KEY (officecodeb) REFERENCES "vehiclecondemnationsBackup".offices(officecode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: vehicles vehicles_registereddistrict_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles
    ADD CONSTRAINT vehicles_registereddistrict_fkey FOREIGN KEY (registereddistrict) REFERENCES "vehiclecondemnationsBackup".districts(districtcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: vehicles vehicles_vehiclecategorycode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".vehicles
    ADD CONSTRAINT vehicles_vehiclecategorycode_fkey FOREIGN KEY (vehiclecategorycode) REFERENCES "vehiclecondemnationsBackup".vehicletypes(vehicletypecode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: verifications verifications_applicationcode_fkey; Type: FK CONSTRAINT; Schema: vehiclecondemnationsBackup; Owner: postgres
--

ALTER TABLE ONLY "vehiclecondemnationsBackup".verifications
    ADD CONSTRAINT verifications_applicationcode_fkey FOREIGN KEY (applicationcode) REFERENCES "vehiclecondemnationsBackup".vehicles(applicationcode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

