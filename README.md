# SQL_BANK_CASE_STUDY

## Problem Statement:
You are the database developer of an international bank. You are responsible for managing the bank’s database. You want to use the data to answer a few questions about your customers regarding withdrawal, deposit and so on, especially about the transaction amount on a particular date across various regions of the world. Perform SQL queries to get the key insights of a customer.

## Dataset:
The 3 key datasets for this case study are:

### a. Continent: 
The Continent table has two attributes i.e., region_id and region_name, where region_name consists of different continents such as Asia, Europe, Africa etc., assigned with the unique region id.

### b. Customers: 
The Customers table has four attributes named customer_id, region_id, start_date and end_date which consists of 3500 records.

### c. Transaction: 
Finally, the Transaction table contains around 5850 records and has four attributes named customer_id, txn_date, txn_type and txn_amount.

## Tasks : 
1. Display the count of customers in each region who have done the
transaction in the year 2020. 

```sql
SELECT 
COUNT(CU.customer_id) AS COUNT_OF_CUSTOMERS,
CO.region_name
FROM CUSTOMERS CU
INNER JOIN CONTINENT CO ON CU.region_id = CO.region_id
INNER JOIN TRANSACTIONS T ON CU.customer_id = T.customer_id
WHERE YEAR(T.TXN_DATE) = '2020'
GROUP BY CO.region_NAME
ORDER BY COUNT(CU.CUSTOMER_ID) ASC
```

![{3D01A62B-EFAC-42E0-9A18-7D8D7574A055}](https://github.com/user-attachments/assets/27764999-7c80-490f-8d0c-4c374a73ee5a)

2. Display the maximum and minimum transaction amount of each
transaction type.

```sql
SELECT TXN_TYPE, MAX(TXN_AMOUNT) AS MAX_TRANSACTION_AMOUNT,
MIN(TXN_AMOUNT) AS MIN_TRANSACTION_AMOUNT 
FROM TRANSACTIONS
GROUP BY txn_type
```

![{58D1BE9D-8CF0-49B0-9CB4-D628DBEE4678}](https://github.com/user-attachments/assets/d1e62416-0f31-4e14-ad3d-8efd320909de)

3. Display the customer id, region name and transaction amount where
transaction type is deposit and transaction amount > 2000.

```sql
SELECT 
CU.customer_id,
CO.region_name,
T.txn_amount,
txn_type
FROM CUSTOMERS CU
INNER JOIN CONTINENT CO ON CU.region_id = CO.region_id
INNER JOIN TRANSACTIONS T ON CU.customer_id = T.customer_id
WHERE T.txn_type = 'DEPOSIT' AND T.txn_amount>2000
```

![{6B6309B7-93F9-4705-B0D3-5B2BC3DC4DB4}](https://github.com/user-attachments/assets/e58316a5-ea2c-4bfa-97b2-0a16b63d6000)

4. Find duplicate records in the Customer table.

```sql
SELECT * INTO #A1 FROM
(SELECT ROW_NUMBER() OVER(PARTITION BY CUSTOMER_ID ORDER BY CUSTOMER_ID) AS SLNO,* FROM CUSTOMERS) T1

DELETE FROM #A1 WHERE SLNO>=3 OR SLNO = 1

SELECT * FROM #A1

-- OR

SELECT CUSTOMER_ID, COUNT(*) as NO_OF_OCCURENCES
FROM CUSTOMERS
GROUP BY CUSTOMER_ID
HAVING COUNT(*) > 1;
```

![{3E6FBF4A-8102-4A89-A0B3-9C3243A62878}](https://github.com/user-attachments/assets/c0b53c72-5b18-428a-bcec-acb04547e984)

5. Display the customer id, region name, transaction type and transaction
amount for the minimum transaction amount in deposit.

```sql
SELECT 
CU.customer_id,
CO.region_name,
T.txn_type,
T.txn_amount
FROM CUSTOMERS CU
INNER JOIN CONTINENT CO ON CU.region_id = CO.region_id
INNER JOIN TRANSACTIONS T ON CU.customer_id = T.customer_id
WHERE TXN_AMOUNT IN (SELECT MIN(TXN_AMOUNT) FROM TRANSACTIONS WHERE txn_type = 'DEPOSIT') 
```

![image](https://github.com/user-attachments/assets/728d8273-cf1c-4d78-a61c-faf270962fb6)

6. Create a stored procedure to display details of customers in the
Transaction table where the transaction date is greater than Jun 2020.

```sql
CREATE PROCEDURE PR01
AS
BEGIN
	SELECT * FROM TRANSACTIONS WHERE TXN_DATE > '2020-06-01'
END

EXEC PR01
```

![{67AE1D27-B1CC-4598-B756-3C457FC7D1EE}](https://github.com/user-attachments/assets/813c4b51-4c79-450e-a73d-164ac8aede50)

7. Create a stored procedure to insert a record in the Continent table.

```sql
CREATE PROCEDURE PR02(@REGION_ID NVARCHAR(100), @REGION_NAME NVARCHAR(100))
AS
BEGIN
	INSERT INTO CONTINENT VALUES(@REGION_ID,@REGION_NAME)
	PRINT 'RECORD INSERTED'
END

EXEC PR02 10,INDIA

SELECT * FROM CONTINENT
```

![image](https://github.com/user-attachments/assets/68de5c35-8ca9-4e9f-9484-473b5bb9e8c5)

8. Create a stored procedure to display the details of transactions that
happened on a specific day.

```sql
CREATE PROCEDURE PR03(@DATE DATE)
AS
BEGIN
	SELECT * FROM TRANSACTIONS WHERE txn_date = @DATE
END

EXEC PR03 '2020-01-21'
```

![{1966177E-4A9E-43C3-AAC7-BE133D087912}](https://github.com/user-attachments/assets/bc238382-7407-4f7c-a53c-4680f1e7a9a5)

9. Create a user defined function to add 10% of the transaction amount in a
table.

```sql
CREATE FUNCTION FN01(@X INT)
RETURNS TABLE
AS
	RETURN (SELECT *,(CAST(TXN_AMOUNT AS NUMERIC(10,2)) + (CAST(TXN_AMOUNT AS NUMERIC(10,2)))*@X/100) AS AMOUNT 
	FROM TRANSACTIONS)
	
SELECT * FROM FN01(10)
```

![{4FE7C62C-5B55-4513-B6FD-9E9E192B0CE4}](https://github.com/user-attachments/assets/c2e78418-d451-449d-a31b-435d5e83ad9d)

10. Create a user defined function to find the total transaction amount for a
given transaction type.

```sql
CREATE FUNCTION FN02(@X NVARCHAR(100))
RETURNS TABLE
AS
	RETURN (SELECT SUM(TXN_AMOUNT) AS TOTAL_AMOUNT FROM TRANSACTIONS
			WHERE txn_type = @X)

SELECT * FROM DBO.FN02('DEPOSIT')
```

![image](https://github.com/user-attachments/assets/940120bb-fb82-440b-9d00-ae89f033d8d5)

11. Create a table value function which comprises the columns customer_id,
region_id ,txn_date , txn_type , txn_amount which will retrieve data from
the above table.

```sql
CREATE FUNCTION FN03()
RETURNS TABLE
AS
RETURN (
SELECT 
CU.CUSTOMER_ID, CU.REGION_ID, T.TXN_DATE, T.TXN_TYPE, T.TXN_AMOUNT
FROM Customers CU INNER JOIN TRANSACTIONS T ON T.customer_id = CU.customer_id 
)

SELECT * FROM DBO.FN03()
```

![{269A4943-065E-4AC1-9DB1-33190DD4D116}](https://github.com/user-attachments/assets/f53160c4-b1c8-4b9b-9bbf-d66357432923)

12. Create a TRY...CATCH block to print a region id and region name in a
single column.

```sql
BEGIN TRY
SELECT REGION_ID+' '+ REGION_NAME AS COMBINED_COLUMN 
FROM Continent
END TRY
BEGIN CATCH
SELECT ERROR_MESSAGE() AS ERROR
END CATCH
```

![{EB0BAC51-FA6D-4FFC-A9E2-A5F317F6DF1C}](https://github.com/user-attachments/assets/770c8844-6f6d-445e-afbf-6e1283d2b9f8)

13. Create a TRY...CATCH block to insert a value in the Continent table.

```sql
BEGIN TRY
INSERT INTO CONTINENT VALUES (6, 'RUSSIA')
END TRY
BEGIN CATCH
PRINT ERROR_MESSAGE()
END CATCH

SELECT * FROM CONTINENT

```

![{93375664-1570-480A-8233-86629B4FE36E}](https://github.com/user-attachments/assets/cd8dabe9-0f0f-423f-9228-19bcdfa784ef)

14. Create a trigger to prevent deleting a table in a database.

```sql
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
```

![{D6F753B6-E8B1-41CD-BE53-8DF0E10A2561}](https://github.com/user-attachments/assets/0c70abf0-2287-4e32-9559-258591fac612)

15. Create a trigger to audit the data in a table.

```sql
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
```

![image](https://github.com/user-attachments/assets/b89b6153-f92b-4772-abae-104c64bbf0a6)

16. Create a trigger to prevent login of the same user id in multiple pages.

```sql
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
```

17. Display top n customers on the basis of transaction type.

```sql
CREATE PROCEDURE PR04(@N INT, @TYPE NVARCHAR(100))
AS
BEGIN
	SELECT TOP(@N) * FROM TRANSACTIONS WHERE txn_type = @TYPE
	ORDER BY txn_amount DESC
END

EXEC PR04 10,'DEPOSIT'
```

![{A1E8FE11-52FB-4682-8D7F-A24BA03CFFEE}](https://github.com/user-attachments/assets/a21c0430-09d6-4557-8e55-9082157d3ea7)

18. Create a pivot table to display the total purchase, withdrawal and
deposit for all the customers.

```sql
SELECT * FROM
(SELECT CUSTOMER_ID, TXN_TYPE, TXN_AMOUNT FROM TRANSACTIONS) AS T
PIVOT
(SUM(TXN_AMOUNT)FOR TXN_TYPE IN (PURCHASE, DEPOSIT, WITHDRAWAL)) AS P
```

![{FB402995-1BA0-40F5-8076-A655DE1A93F7}](https://github.com/user-attachments/assets/8734315c-47a0-4a5b-980f-96e39b321f7f)
