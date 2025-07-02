# Question 1 #
SELECT 				customer_name,
					CONCAT(house_number, ' ', street, ' ', city, ' ', postcode) AS full_address
FROM 				customers
WHERE 				city = 'London'						-- address in London
AND 				postcode LIKE 'N%'					-- postcode in North London		
AND 				postcode NOT LIKE 'NW%' 			-- postcode not NW
ORDER BY 			customer_name ASC
;

# Question 2 #
SELECT 				account_id,
					date_opened
FROM 				accounts
WHERE 				DATE(date_opened) >= DATE_ADD(CURDATE(), INTERVAL -10 YEAR)			-- date opened is in the last 10 years
AND 				date_closed IS NULL													-- account is not closed
ORDER BY 			date_opened DESC
;

# Question 3 #
SELECT 		*
FROM 		accounts
WHERE 		DATE_FORMAT(date_opened, "%Y%m") > DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL -12 MONTH), "%Y%m") 
OR 			DATE_FORMAT(date_closed, "%Y%m") > DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL -12 MONTH),"%Y%m");
-- this query returns all information of every account that was either opened or closed in the last 12 months
-- excluding the accounts that were opened or closed in the exact month 12 months ago 

# Question 4 #
SELECT 				c.customer_id,
					c.customer_name,
                    IFNULL(a.account_id, '') AS account_id,				-- replace NULL with empty string
                    IFNULL(t.transaction_time, '') AS transaction_time	-- replace NULL with empty string
FROM 				customers c												-- all customers
	LEFT OUTER JOIN 
		accounts a
	ON a.customer_id = c.customer_id
    LEFT OUTER JOIN
		transactions t
	ON a.account_id = t.account_id 				
ORDER BY 			c.customer_id ASC,
					a.account_id ASC,
                    t.transaction_time DESC
;

# Question 5 #
SELECT 			c.customer_id,
				c.customer_name,
                t.account_id,
                t.transaction_time
FROM 			customers c															-- all customers
	INNER JOIN
		accounts a																	-- all accounts
	ON c.customer_id = a.customer_id
    INNER JOIN
		transactions t
	ON a.account_id = t.account_id
WHERE 			t.transaction_time = (SELECT MIN(transaction_time)					-- earliest transaction
										FROM transactions)
;

# Question 6 #
SELECT 			DATE_FORMAT(MIN(date_opened), '%Y-%m-%d') AS `Earliest & Latest Account Opening Dates & Transaction Times`
FROM 			accounts						-- earliest date opened
UNION ALL
SELECT 			DATE_FORMAT(MAX(date_opened), '%Y-%m-%d')
FROM 			accounts						-- latest date opened
UNION ALL				
SELECT 			MIN(transaction_time)
FROM 			transactions					-- earliest transaction
UNION ALL	
SELECT 			MAX(transaction_time)
FROM 			transactions					-- latest transaction
;

# Question 7 #
SELECT 			account_id,
				SUM(amount) AS current_balance				-- total transaction amount = current balance
FROM 			transactions
GROUP BY 		account_id
ORDER BY 		SUM(amount) ASC
;

# Question 8 #
SELECT 			customer_id,
				COUNT(account_id) AS num_accounts,					-- num of accounts
                account_type										-- type of account
FROM 			accounts
GROUP BY 		customer_id, 
				account_type
ORDER BY 		customer_id ASC,
				account_type DESC
;

# Question 9 #
SELECT 			c.customer_name,
				COUNT(a1.account_id) AS num_accounts,							-- num of account
                IFNULL(a2.account_description, 'No Account') AS account_type	-- account type or 'no account'
FROM 			customers c														-- all customers
	LEFT OUTER JOIN
		accounts a1
	ON c.customer_id = a1.customer_id											-- tables joined on unique customer ids 
	LEFT OUTER JOIN
		account_types a2
	ON a1.account_type = a2.account_type
GROUP BY 		c.customer_id, 
				c.customer_name, 
                a2.account_description
ORDER BY 		c.customer_name ASC,
				a2.account_description DESC
;

# Question 10 #
SELECT 			COUNT(t.transaction_time) AS num_transactions,			-- number of transactions per account
				a.account_type,
                t.transaction_type
FROM 			transactions t
	RIGHT OUTER JOIN
		accounts a						-- include every account even if no transactions made
	ON t.account_id = a.account_id		-- join on account id from both tables
GROUP BY 		a.account_type,
				t.transaction_type
ORDER BY 		a.account_type ASC,
				t.transaction_type ASC
;

# Question 11 #
SELECT 			customer_id,
				COUNT(DISTINCT account_type)
FROM 			accounts
GROUP BY 		customer_id
ORDER BY 		COUNT(DISTINCT account_type) DESC;
-- this query displays the number of distinct account types for each customer,
-- with the results ordered from customers with the most accounts to those with the fewest

# Question 12 #
SELECT 			account_id,
				SUM(amount) AS total_cash_deposits
FROM 			transactions
WHERE 			transaction_type = 5			-- cash deposits = transaction type 5
GROUP BY 		account_id
HAVING 			SUM(amount) > 3000				-- sum of cash deposits > 3000
ORDER BY 		SUM(amount) DESC				-- descending order
;

# Question 13 #
SELECT 			t1.account_id,
				t1.amount,
                t1.transaction_time
FROM 			transactions t1
WHERE 			t1.amount = (SELECT 	MAX(t2.amount)						-- largest transaction amount 
							FROM 		transactions t2
                            WHERE 		t1.account_id = t2.account_id)		-- each account id in transactions table
;

# Question 14 #
SELECT 		account_id
FROM 		transactions
WHERE 		transaction_time >= DATE_ADD(NOW(), INTERVAL -365 DAY)
GROUP BY 	account_id
HAVING 		AVG(amount) > 1000;
-- this query displays the account ids that made a transaction in the last 365 days including the 356th day, where the average transaction amount was greater than 1,000

# Question 15 #
SELECT 	a1.branch_id,
		a1.customer_id,
		a1.date_opened
FROM 	accounts a1
WHERE 	a1.date_opened = (SELECT MAX(a2.date_opened)
							FROM accounts a2
							WHERE a2.branch_id = a1.branch_id);
-- this query displays the customer id of the account that was most recently opened for each branch

# Question 16 # 
# Display the highest number of transactions made by any account
-- step 1 get the count of transactions made by all accounts
SELECT 	COUNT(transaction_time) AS num_transactions
FROM 		transactions
GROUP BY 	account_id
;

-- step 2 get the max of the count of transations
SELECT 		MAX(num_transactions) AS max_num_transactions
FROM 		(SELECT 	COUNT(transaction_time) AS num_transactions
			FROM 		transactions
			GROUP BY 	account_id) tt
;



# Question 17
# (a) what will the following query return?
SELECT 	MAX(average)
FROM	(SELECT 	AVG(amount) AS average
		FROM 	transactions
		WHERE 	QUARTER(transaction_time) = QUARTER(DATE_ADD(CURDATE(), INTERVAL -1 QUARTER))
		GROUP BY account_id) iv
;

-- this displays the highest average transaction amount for all transactions done 
-- in quarter 1 (the previous quarter) of every year



# Question 17
# (b) Change the query from question 17 a), so that the time constraint is limited solely to the previous quarter.

SELECT 	MAX(average)
FROM	(SELECT 	AVG(amount) AS average
		FROM 	transactions
		WHERE 	QUARTER(transaction_time) = QUARTER(DATE_ADD(CURDATE(), INTERVAL -1 QUARTER))
        AND 	YEAR(transaction_time) = YEAR(DATE_ADD(CURDATE(), INTERVAL -1 QUARTER))
		GROUP BY account_id) iv
;

# Question 18 #
# (a)
INSERT INTO transaction_types (transaction_type, transaction_description)			-- add new transaction type to table
VALUES (6, 'Interest Payment');

# (b) 
CREATE TABLE transactions_history LIKE transactions;			-- new table with same format as transactions table
INSERT INTO transactions_history
	SELECT		*
	FROM 		transactions
    WHERE 		DATE_FORMAT(transaction_time, '%Y%m%d') < DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL -5 YEAR), '%Y0101')			-- transactions made before 01/01 5 years ago
;

# Question 19 #
# (a)
UPDATE 			customers
SET 			house_number = '153',
				street = 'North Street',
                city = 'Glasgow',
                postcode = 'G3 7DA'
WHERE			customer_id = 16
;

# (b) 
SET autocommit = 0;						-- disable autocommit
SET SQL_SAFE_UPDATES = 0;				-- disable safe update mode
UPDATE 			accounts
SET 			date_closed = CURDATE()							-- close account using todays date
WHERE 			account_type = 1								-- 1 = current account
AND 			date_closed IS NULL								-- look at only open accounts
AND 			account_id IN (SELECT 		account_id
								FROM 		transactions
                                GROUP BY 	account_id
                                HAVING 		SUM(amount) = 0																		-- account balance is 0
                                AND 		YEAR(MAX(transaction_time)) < YEAR(DATE_ADD(CURDATE(), INTERVAL - 4 YEAR)))			-- last transaction made more than 4 years ago
;
SET SQL_SAFE_UPDATES = 1;				-- enable safe update mode
SET autocommit = 1;						-- enable autocommit

# Question 20 #
# (a) 
SET autocommit = 0;						-- disable autocommit
SET SQL_SAFE_UPDATES = 0;				-- disable safe update mode

DELETE FROM 			branches
WHERE 					house_number = '38'
AND						street = 'Stoke Newington High Street'
AND						city = 'London'
;
SET SQL_SAFE_UPDATES = 1;				-- enable safe update mode
SET autocommit = 1;						-- enable autocommit

# (b)
SET autocommit = 0;						-- disable autocommit
SET SQL_SAFE_UPDATES = 0;				-- disable safe update mode

DELETE FROM			customers
WHERE 				customer_id NOT IN(SELECT customer_id					-- customers that have never had an account
										FROM accounts
                                        WHERE customer_id IS NOT NULL)		-- removes unknown customer_id values
;
SET SQL_SAFE_UPDATES = 1;				-- enable safe update mode
SET autocommit = 1;						-- enable autocommit