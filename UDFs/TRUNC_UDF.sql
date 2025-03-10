-- <copyright file="TRUNC_UDF.sql" company="Mobilize.Net">
--        Copyright (C) Mobilize.Net info@mobilize.net - All Rights Reserved
-- 
--        This file is part of the Mobilize Frameworks, which is
--        proprietary and confidential.
-- 
--        NOTICE:  All information contained herein is, and remains
--        the property of Mobilize.Net Corporation.
--        The intellectual and technical concepts contained herein are
--        proprietary to Mobilize.Net Corporation and may be covered
--        by U.S. Patents, and are protected by trade secret or copyright law.
--        Dissemination of this information or reproduction of this material
--        is strictly forbidden unless prior written permission is obtained
--        from Mobilize.Net Corporation.
-- </copyright>

-- =============================================
-- These UDFs help to achieve functional equivalence when migrating the TRUNC function from Teradata, for both TRUNC(Date) and TRUNC(Numeric) cases
-- =============================================

-- =============================================
-- DESCRIPTION: UDF THAT REPRODUCES TERADATA'S TRUNC(Date) FUNCTIONALITY WHEN THE FORMAT PARAMETER IS SPECIFIED
-- PARAMETERS:
-- DATE_TO_TRUNC: TIMESTAMP_LTZ. DATETIME VALUE TO TRUNCATE WHICH MUST BE A DATE, TIMESTAMP OR TIMESTAMP WITH TIMEZONE
-- DATE_FMT: VARCHAR. SHOULD BE ONE OF THE DATE FORMATS SUPPORTED BY THE TRUNC FUNCTION
-- RETURNS: A DATE TRUNCATED USING THE FORMAT SPECIFIED
-- EXAMPLE:
--  INPUT:
--      SELECT TRUNC_UDF(TIMESTAMP '2015-08-18 12:30:00', 'Q')
--  OUTPUT:
--      DATE WITH VALUE 2015-07-01
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.TRUNC_UDF(DATE_TO_TRUNC TIMESTAMP_LTZ, DATE_FMT VARCHAR(5))
RETURNS DATE
AS
$$
CAST(CASE 
WHEN UPPER(DATE_FMT) IN ('CC','SCC') THEN DATE_FROM_PARTS(CAST(LEFT(CAST(YEAR(DATE_TO_TRUNC) as CHAR(4)),2) || '01' as INTEGER),1,1)
WHEN UPPER(DATE_FMT) IN ('SYYYY','YYYY','YEAR','SYEAR','YYY','YY','Y') THEN DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1)
WHEN UPPER(DATE_FMT) IN ('IYYY','IYY','IY','I') THEN 
    CASE DAYOFWEEK(DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
         WHEN 0 THEN DATEADD(DAY, 1, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
         WHEN 1 THEN DATEADD(DAY, 0, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
         WHEN 2 THEN DATEADD(DAY, -1, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
         WHEN 3 THEN DATEADD(DAY, -2, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
         WHEN 4 THEN DATEADD(DAY, -3, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
         WHEN 5 THEN DATEADD(DAY, 3, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
         WHEN 6 THEN DATEADD(DAY, 2, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
    END        
WHEN UPPER(DATE_FMT) IN ('MONTH','MON','MM','RM') THEN DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),MONTH(DATE_TO_TRUNC),1)
WHEN UPPER(DATE_FMT)IN ('Q') THEN DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),(QUARTER(DATE_TO_TRUNC)-1)*3+1,1)
WHEN UPPER(DATE_FMT) IN ('WW') THEN DATEADD(DAY, 0-MOD(TIMESTAMPDIFF(DAY,DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1),DATE_TO_TRUNC),7), DATE_TO_TRUNC)
WHEN UPPER(DATE_FMT) IN ('IW') THEN DATEADD(DAY, 0-MOD(TIMESTAMPDIFF(DAY,(CASE DAYOFWEEK(DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
                                                                 WHEN 0 THEN DATEADD(DAY, 1, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
                                                                 WHEN 1 THEN DATEADD(DAY, 0, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
                                                                 WHEN 2 THEN DATEADD(DAY, -1, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
                                                                 WHEN 3 THEN DATEADD(DAY, -2, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
                                                                 WHEN 4 THEN DATEADD(DAY, -3, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
                                                                 WHEN 5 THEN DATEADD(DAY, 3, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
                                                                 WHEN 6 THEN DATEADD(DAY, 2, DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),1,1))
                                                               END),      DATE_TO_TRUNC),7), DATE_TO_TRUNC)
WHEN UPPER(DATE_FMT) IN ('W') THEN DATEADD(DAY, 0-MOD(TIMESTAMPDIFF(DAY,DATE_FROM_PARTS(YEAR(DATE_TO_TRUNC),MONTH(DATE_TO_TRUNC),1),DATE_TO_TRUNC),7), DATE_TO_TRUNC)                                                             
WHEN UPPER(DATE_FMT) IN ('DDD', 'DD','J') THEN DATE_TO_TRUNC
WHEN UPPER(DATE_FMT) IN ('DAY', 'DY','D') THEN DATEADD(DAY, 0-DAYOFWEEK(DATE_TO_TRUNC), DATE_TO_TRUNC)
WHEN UPPER(DATE_FMT) IN ('HH', 'HH12','HH24') THEN DATE_TO_TRUNC
WHEN UPPER(DATE_FMT) IN ('MI') THEN DATE_TO_TRUNC
END AS DATE)
$$
;

-- =============================================
-- DESCRIPTION: UDF THAT REPRODUCES TERADATA'S TRUNC(Date) FUNCTIONALITY WHEN THE FORMAT PARAMETER IS NOT SPECIFIED
-- PARAMETERS:
-- DATE_TO_TRUNC: TIMESTAMP_LTZ. DATETIME VALUE TO TRUNCATE WHICH MUST BE A DATE, TIMESTAMP OR TIMESTAMP WITH TIMEZONE
-- RETURNS: THE DATE PART OF DATE_TO_TRUNC
-- EXAMPLE:
--  INPUT:
--      SELECT TRUNC_UDF(TIMESTAMP '2015-08-18 12:30:00')
--  OUTPUT:
--      DATE WITH VALUE 2015-08-18
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.TRUNC_UDF(INPUT TIMESTAMP_LTZ)
RETURNS DATE
AS
$$
    INPUT::DATE
$$;

-- =============================================
-- DESCRIPTION: UDF THAT REPRODUCES TERADATA'S TRUNC(Numeric) FUNCTIONALITY WHEN A SCALE IS SPECIFIED
-- PARAMETERS:
-- INPUT: NUMBER. THE NUMBER TO TRUNCATE
-- SCALE: NUMBER. THE AMOUNT OF PLACES TO TRUNCATE (BETWEEN -38 AND 38)
-- RETURNS: INPUT TRUNCATED TO SCALE PLACES
-- EXAMPLE:
--  INPUT:
--      SELECT TRUNC_UDF(25122.3368, 2);
--      SELECT TRUNC_UDF(25122.3368, -2);
--  OUTPUT:
--      25122.33
--      25100
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.TRUNC_UDF(INPUT NUMBER, SCALE NUMBER)
RETURNS INT
AS
$$
    TRUNC(INPUT, SCALE)
$$;

-- =============================================
-- DESCRIPTION: UDF THAT REPRODUCES TERADATA'S TRUNC(Numeric) FUNCTIONALITY WHEN NO SCALE IS SPECIFIED
-- PARAMETERS:
-- INPUT: NUMBER. THE NUMBER TO TRUNCATE
-- RETURNS: INPUT TRUNCATED TO ZERO DECIMAL PLACES
-- EXAMPLE:
--  INPUT:
--      SELECT TRUNC_UDF(25122.3368)
--  OUTPUT:
--      25122
-- =============================================
CREATE OR REPLACE FUNCTION PUBLIC.TRUNC_UDF(INPUT NUMBER)
RETURNS INT
AS
$$
    TRUNC(INPUT)
$$;