/* To isolate the transactions of each cardholder and
count the transactions that are less than $2.00 per
cardholder, we can use the following query: */
SELECT ch.name as cardholder_name, COUNT(t.id) as total_transactions, COUNT(CASE WHEN t.amount < 2 THEN 1 END) as small_transactions
FROM card_holder ch
INNER JOIN credit_card cc ON ch.id = cc.cardholder_id
INNER JOIN transaction t ON cc.card = t.card
GROUP BY ch.name;
-------------------------------------------------------

/* Count the transactions that are less than $2.00 per
cardholder. */
SELECT ch.name as cardholder_name, COUNT(t.id) as small_transactions_count
FROM card_holder ch
INNER JOIN credit_card cc ON ch.id = cc.cardholder_id
INNER JOIN transaction t ON cc.card = t.card
WHERE t.amount < 2
GROUP BY ch.name;
------------------------------------------------------

/* To find the top 100 highest transactions made between
7:00 am and 9:00 am, we can use the following query: */
SELECT t.id, t.date, t.amount, ch.name as cardholder_name, m.name as merchant_name
FROM transaction t
INNER JOIN credit_card cc ON t.card = cc.card
INNER JOIN card_holder ch ON cc.cardholder_id = ch.id
INNER JOIN merchant m ON t.id_merchant = m.id
WHERE EXTRACT(HOUR FROM t.date) >= 7 AND EXTRACT(HOUR FROM t.date) < 9
ORDER BY t.amount DESC
LIMIT 100;
------------------------------------------------------

/* To identify anomalous transactions that could be
fraudulent, we can look for transactions that are much
larger than the typical transaction amount for the
given cardholder. For example, if a cardholder
typically spends less than $50 per transaction, a
$500 transaction could be a red flag. To determine the
typical transaction amount for each cardholder, we
can use the following query: */
SELECT ch.name as cardholder_name, AVG(t.amount) as avg_transaction_amount
FROM card_holder ch
INNER JOIN credit_card cc ON ch.id = cc.cardholder_id
INNER JOIN transaction t ON cc.card = t.card
GROUP BY ch.name;
/* We can then use this information to identify
transactions that are significantly higher than the
average transaction amount for the given cardholder. */
-------------------------------------------------------

/* To check if there is a higher number of fraudulent
transactions made during the 7:00 am to 9:00 am time
frame versus the rest of the day, we can compare the
proportion of small transactions made during this time
frame to the rest of the day. If the proportion of
small transactions is much higher during this time
frame, it could indicate fraudulent activity.
We can use the following query to calculate the small
transaction ratio for each time frame: */
SELECT EXTRACT(HOUR FROM t.date) as hour, COUNT(CASE WHEN t.amount < 2 THEN 1 END) as small_transactions, COUNT(t.id) as total_transactions,
       CAST(COUNT(CASE WHEN t.amount < 2 THEN 1 END) AS FLOAT) / COUNT(t.id) as small_transaction_ratio
FROM transaction t
WHERE EXTRACT(HOUR FROM t.date) >= 7 AND EXTRACT(HOUR FROM t.date) < 9
   OR EXTRACT(HOUR FROM t.date) >= 21 OR EXTRACT(HOUR FROM t.date) < 7
GROUP BY EXTRACT(HOUR FROM t.date);
/* We can then compare the small transaction ratio for
the 7:00 am to 9:00 am time frame to the rest of the
day to see if there is a significant difference. */
-------------------------------------------------------

/* To find the top 5 merchants prone to being hacked
using small transactions, we can use the following
query: */
SELECT m.name as merchant_name, COUNT(CASE WHEN t.amount < 2 THEN 1 END) as small_transactions
FROM merchant m
INNER JOIN transaction t ON m.id = t.id_merchant
GROUP BY m.name
ORDER BY small_transactions DESC
LIMIT 5;
-------------------------------------------------------

-- Create Views for each of the above queries:

/* View to isolate the transactions of each cardholder
and count the transactions that are less than $2.00
per cardholder: */
CREATE VIEW cardholder_transaction_counts AS
SELECT ch.name as cardholder_name, COUNT(t.id) as total_transactions, COUNT(CASE WHEN t.amount < 2 THEN 1 END) as small_transactions
FROM card_holder ch
INNER JOIN credit_card cc ON ch.id = cc.cardholder_id
INNER JOIN transaction t ON cc.card = t.card
GROUP BY ch.name;

/* View to count the transactions that are less than
$2.00 per cardholder: */
CREATE VIEW small_transactions_per_cardholder AS
SELECT ch.name as cardholder_name, COUNT(t.id) as small_transactions_count
FROM card_holder ch
INNER JOIN credit_card cc ON ch.id = cc.cardholder_id
INNER JOIN transaction t ON cc.card = t.card
WHERE t.amount < 2
GROUP BY ch.name;

/* View to find the top 100 highest transactions made
between 7:00 am and 9:00 am: */
CREATE VIEW top_100_morning_transactions AS
SELECT t.id, t.date, t.amount, ch.name as cardholder_name, m.name as merchant_name
FROM transaction t
INNER JOIN credit_card cc ON t.card = cc.card
INNER JOIN card_holder ch ON cc.cardholder_id = ch.id
INNER JOIN merchant m ON t.id_merchant = m.id
WHERE EXTRACT(HOUR FROM t.date) >= 7 AND EXTRACT(HOUR FROM t.date) < 9
ORDER BY t.amount DESC
LIMIT 100;

/* View to identify anomalous transactions that could
be fraudulent: */
CREATE VIEW avg_transaction_amount_per_cardholder AS
SELECT ch.name as cardholder_name, AVG(t.amount) as avg_transaction_amount
FROM card_holder ch
INNER JOIN credit_card cc ON ch.id = cc.cardholder_id
INNER JOIN transaction t ON cc.card = t.card
GROUP BY ch.name;

/* View to check if there is a higher number of
fraudulent transactions made during the 7:00 am to
9:00 am time frame versus the rest of the day: */
CREATE VIEW small_transaction_ratio_by_timeframe AS
SELECT EXTRACT(HOUR FROM t.date) as hour, COUNT(CASE WHEN t.amount < 2 THEN 1 END) as small_transactions, COUNT(t.id) as total_transactions,
       CAST(COUNT(CASE WHEN t.amount < 2 THEN 1 END) AS FLOAT) / COUNT(t.id) as small_transaction_ratio
FROM transaction t
WHERE EXTRACT(HOUR FROM t.date) >= 7 AND EXTRACT(HOUR FROM t.date) < 9
   OR EXTRACT(HOUR FROM t.date) >= 21 OR EXTRACT(HOUR FROM t.date) < 7
GROUP BY EXTRACT(HOUR FROM t.date);

/* View to find the top 5 merchants prone to being
hacked using small transactions: */
CREATE VIEW top_5_small_transaction_merchants AS
SELECT m.name as merchant_name, COUNT(CASE WHEN t.amount < 2 THEN 1 END) as small_transactions
FROM merchant m
INNER JOIN transaction t ON m.id = t.id_merchant
GROUP BY m.name
ORDER BY small_transactions DESC
LIMIT 5;
------------------------------------------------------












