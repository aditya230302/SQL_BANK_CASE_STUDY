use CASE_STUDY_3

SELECT * FROM CUSTOMERS

SELECT * FROM CONTINENT

SELECT * FROM TRANSACTIONS

-- 1. Display the count of customers in each region who have done the transaction in the year 2020.

SELECT 
COUNT(CU.customer_id) AS COUNT_OF_CUSTOMERS,
CO.region_name
FROM CUSTOMERS CU
INNER JOIN CONTINENT CO ON CU.region_id = CO.region_id
INNER JOIN TRANSACTIONS T ON CU.customer_id = T.customer_id
WHERE YEAR(T.TXN_DATE) = '2020'
GROUP BY CO.region_NAME
ORDER BY COUNT(CU.CUSTOMER_ID) ASC

-- 2. Display the maximum and minimum transaction amount of each transaction type.

SELECT TXN_TYPE, MAX(TXN_AMOUNT) AS MAX_TRANSACTION_AMOUNT,
MIN(TXN_AMOUNT) AS MIN_TRANSACTION_AMOUNT 
FROM TRANSACTIONS
GROUP BY txn_type

-- 3. Display the customer id, region name and transaction amount where transaction type is deposit and transaction amount > 2000.

SELECT 
CU.customer_id,
CO.region_name,
T.txn_amount,
txn_type
FROM CUSTOMERS CU
INNER JOIN CONTINENT CO ON CU.region_id = CO.region_id
INNER JOIN TRANSACTIONS T ON CU.customer_id = T.customer_id
WHERE T.txn_type = 'deposit' AND T.txn_amount>2000

-- 4. Find duplicate records in the Customer table.
SELECT * INTO #A1 FROM
(SELECT ROW_NUMBER() OVER(PARTITION BY CUSTOMER_ID ORDER BY CUSTOMER_ID) AS SLNO,* FROM CUSTOMERS) T1

DELETE FROM #A1 WHERE SLNO = 1

SELECT * FROM #A1

-- OR

SELECT CUSTOMER_ID, COUNT(*) as NO_OF_OCCURENCES
FROM CUSTOMERS
GROUP BY CUSTOMER_ID
HAVING COUNT(*) > 1;

-- 5. Display the customer id, region name, transaction type and transaction amount for the minimum transaction amount in deposit.

SELECT 
CU.customer_id,
CO.region_name,
T.txn_type,
T.txn_amount
FROM CUSTOMERS CU
INNER JOIN CONTINENT CO ON CU.region_id = CO.region_id
INNER JOIN TRANSACTIONS T ON CU.customer_id = T.customer_id
WHERE TXN_AMOUNT IN (SELECT MIN(TXN_AMOUNT) FROM TRANSACTIONS WHERE txn_type = 'DEPOSIT') 

-- 6. Create a stored procedure to display details of customers in the Transaction table where the transaction date is greater than Jun 2020.

CREATE PROCEDURE PR01
AS
BEGIN
	SELECT * FROM TRANSACTIONS WHERE TXN_DATE > '2020-06-01'
END

EXEC PR01

-- 7. Create a stored procedure to insert a record in the Continent table.
CREATE PROCEDURE PR02(@REGION_ID NVARCHAR(100), @REGION_NAME NVARCHAR(100))
AS
BEGIN
	INSERT INTO CONTINENT VALUES(@REGION_ID,@REGION_NAME)
	PRINT 'RECORD INSERTED'
END

EXEC PR02 10,INDIA

SELECT * FROM CONTINENT

-- 8. Create a stored procedure to display the details of transactions that happened on a specific day.

CREATE PROCEDURE PR03(@DATE DATE)
AS
BEGIN
	SELECT * FROM TRANSACTIONS WHERE txn_date = @DATE
END

EXEC PR03 '2020-01-21'

-- 9. Create a user defined function to add 10% of the transaction amount in a table.

CREATE FUNCTION FN01(@X INT)
RETURNS TABLE
AS
	RETURN (SELECT *,(CAST(TXN_AMOUNT AS NUMERIC(10,2)) + (CAST(TXN_AMOUNT AS NUMERIC(10,2)))*@X/100) AS AMOUNT 
	FROM TRANSACTIONS)
	
SELECT * FROM FN01(10)

-- 10. Create a user defined function to find the total transaction amount for a given transaction type.

CREATE FUNCTION FN02(@X NVARCHAR(100))
RETURNS TABLE
AS
	RETURN (SELECT SUM(TXN_AMOUNT) AS TOTAL_AMOUNT FROM TRANSACTIONS
			WHERE txn_type = @X)

SELECT * FROM DBO.FN02('DEPOSIT')

-- 11. Create a table value function which comprises the columns customer_id, region_id ,txn_date , txn_type , txn_amount which will retrieve data from the above table.

CREATE FUNCTION FN03()
RETURNS TABLE
AS
RETURN (
SELECT 
CU.CUSTOMER_ID, CU.REGION_ID, T.TXN_DATE, T.TXN_TYPE, T.TXN_AMOUNT
FROM Customers CU INNER JOIN TRANSACTIONS T ON T.customer_id = CU.customer_id 
)

SELECT * FROM DBO.FN03()

-- 12. Create a TRY...CATCH block to print a region id and region name in a single column.

BEGIN TRY
SELECT REGION_ID+' '+ REGION_NAME AS COMBINED_COLUMN 
FROM Continent
END TRY
BEGIN CATCH
SELECT ERROR_MESSAGE() AS ERROR
END CATCH

-- 13. Create a TRY...CATCH block to insert a value in the Continent table.

BEGIN TRY
INSERT INTO CONTINENT VALUES (6, 'RUSSIA')
END TRY
BEGIN CATCH
PRINT ERROR_MESSAGE()
END CATCH

SELECT * FROM CONTINENT

-- 14. Create a trigger to prevent deleting a table in a database.

CREATE TRIGGER TRG_DELETE
ON CONTINENT
FOR DELETE
AS
BEGIN
	ROLLBACK
	PRINT '********************************************'
	PRINT 'YOU CANNOT DELETE FROM THIS TABLE'
	PRINT '********************************************'
END

SELECT * FROM CONTINENT

delete CONTINENT
-- 15. Create a trigger to audit the data in a table.

SELECT * FROM Continent

-- Step 1: Create audit table with action logging
CREATE TABLE CONTINENT_AUDIT (
    REGION_ID INT,
    REGION_NAME VARCHAR(20),
    ACTION_TYPE VARCHAR(10),
    INSERTED_BY VARCHAR(50),
    ACTION_TIMESTAMP DATETIME
);
GO

-- Step 2: Create trigger that handles INSERT, UPDATE, DELETE
CREATE TRIGGER TRG_CONTINENT_AUDIT
ON CONTINENT
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- INSERTED rows (new data) - for INSERT or UPDATE
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO CONTINENT_AUDIT (REGION_ID, REGION_NAME, ACTION_TYPE, INSERTED_BY, ACTION_TIMESTAMP)
        SELECT REGION_ID, REGION_NAME, 
               CASE 
                   WHEN EXISTS (SELECT * FROM deleted WHERE REGION_ID = inserted.REGION_ID) 
                   THEN 'UPDATE' 
                   ELSE 'INSERT' 
               END,
               ORIGINAL_LOGIN(), GETDATE()
        FROM inserted;
    END

    -- DELETED rows - for DELETE
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO CONTINENT_AUDIT (REGION_ID, REGION_NAME, ACTION_TYPE, INSERTED_BY, ACTION_TIMESTAMP)
        SELECT REGION_ID, REGION_NAME, 'DELETE', ORIGINAL_LOGIN(), GETDATE()
        FROM deleted;
    END
END;
GO

INSERT INTO CONTINENT VALUES(6, 'RUSSIA')

DISABLE TRIGGER TRG_DELETE ON CONTINENT

DELETE FROM Continent
WHERE REGION_ID = 6

UPDATE CONTINENT
SET REGION_NAME = 'INDIA'
WHERE region_id = 6

ENABLE TRIGGER TRG_DELETE ON CONTINENT

SELECT * FROM CONTINENT_AUDIT

-- 16. Create a trigger to prevent login of the same user id in multiple pages.

CREATE TRIGGER PREVENT_MULTIPLE_LOGINS
ON ALL SERVER
FOR LOGON
AS
BEGIN
	DECLARE @SESSION_COUNT INT
	SELECT @SESSION_COUNT = COUNT(*) FROM SYS.DM_EXEC_SESSIONS
	WHERE is_user_process = 1
	AND LOGIN_NAME = ORIGINAL_LOGIN()
	IF @SESSION_COUNT > 1
		BEGIN
			PRINT 'MULTIPLE LOGINS NOT ALLOWED'
			ROLLBACK
		END
END

DISABLE TRIGGER PREVENT_MULTIPLE_LOGINS ON ALL SERVER

-- 17. Display top n customers on the basis of transaction type.

CREATE PROCEDURE PR04(@N INT, @TYPE NVARCHAR(100))
AS
BEGIN
	SELECT TOP(@N) * FROM TRANSACTIONS WHERE txn_type = @TYPE
	ORDER BY txn_amount DESC
END

EXEC PR04 10,'DEPOSIT'

-- 18. Create a pivot table to display the total purchase, withdrawal and deposit for all the customers.

SELECT * FROM
(SELECT CUSTOMER_ID, TXN_TYPE, TXN_AMOUNT FROM TRANSACTIONS) AS T
PIVOT
(SUM(TXN_AMOUNT)FOR TXN_TYPE IN (PURCHASE, DEPOSIT, WITHDRAWAL)) AS P

