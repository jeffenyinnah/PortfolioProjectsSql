------------------------------- PROBLEM STATEMENT------------------------------
------ Danny wants to use data to answer the following questions
-------ABout customers visiting patterns, how much money they've spent, favorite menu items
------ Answering these questions will help him deliver a better and more personalized experience for the customers
------- Danny plans to use this insight to help him decide if he should expand the existing customer loyalty program
------ He needs help to generate some basic datasets so that his team can inspect the dataset without using sql

----- We have been provided with 3 datasets -> sales, menu, members

------------------------------- CREATING TABLES --------------------------
CREATE TABLE Sales 
(	
	customerId varchar(25),
	OrderDate Date,
	ProductID varchar (25)
);

CREATE TABLE Menu
(
	ProductID varchar(25),
	ProductName varchar(255),
	Price numeric
)

CREATE TABLE Members 
(
	CustomerID varchar(25),
	JoinDate Date
);

------------------------INSERTING INTO TABLES

INSERT INTO Sales 
	("customerId", "OrderDate","ProductID") 
VALUES 
	('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

INSERT INTO Menu 
	(ProductID, ProductName,Price) 
VALUES 
	('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');


INSERT INTO Members 
	(CustomerID, JoinDate) 
VALUES 
	('A', '2021-01-07'),
  ('B', '2021-01-09');


  ----------------------------------------------------------Case Study Questions-----------------------------------------------
----------------------------------------What is the total amount each customer spent at the restaurant?
--SELECT DISTINCT customerID FROM Sales -> We have 3 customers in our dataset
SELECT S.customerId, SUM(M.Price) as TotalAmountSpent
FROM Sales S
JOIN Menu M
	ON S.ProductID = M.ProductID
GROUP BY S.customerId
ORDER BY 2

----------------------------------------How many days has each customer visited the restaurant?

SELECT customerId, COUNT(DISTINCT OrderDate)
FROM Sales
GROUP BY customerId
ORDER BY 2


-------------------------------------What was the first item from the menu purchased by each customer?
SELECT S.customerId, S.OrderDate as FirstPurchaseItem, M.ProductName
FROM Sales S
JOIN Menu M
	ON M.ProductID = S.ProductID
WHERE S.OrderDate = (
	SELECT MIN(OrderDate)
	FROM Sales
	WHERE customerId = S.customerId
)

-------------------------------------What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT M.ProductName, COUNT(*) as TimesPurchased
FROM Sales S
JOIN Menu M
	ON M.ProductID = S.ProductID
GROUP BY  M.ProductName
ORDER BY 2 DESC


-----------------------------------Which item was the most popular for each customer?
SELECT S.customerId, M.ProductName, COUNT(S.ProductID) as MostPopularItemByCustomer
FROM Sales S
	JOIN Menu M
		ON M.ProductID = S.ProductID
GROUP BY  S.customerId, M.ProductName
ORDER BY 1,3 DESC

------------------------------------Which item was purchased first by the customer after they became a member?
SELECT S.customerId 
FROM Sales S
JOIN Members Mb ON Mb.CustomerID = S.customerId  --- This shows that only customers with CustomerId A and B are members.

SELECT S.customerId, S.OrderDate as ItemPurchasedAfter, M.ProductName, B.JoinDate
FROM Sales S
JOIN Menu M ON M.ProductID = S.ProductID 
JOIN Members B ON B.CustomerID = S.customerId
WHERE S.OrderDate = (
	SELECT MIN(OrderDate)
	FROM Sales
	WHERE customerId = S.customerId AND OrderDate >= B.JoinDate
)

---------------------------------------Which item was purchased just before the customer became a member?
SELECT S.customerId, S.OrderDate as ItemPurchasedBefore, M.ProductName, B.JoinDate
FROM Sales S
JOIN Menu M ON M.ProductID = S.ProductID 
JOIN Members B ON B.CustomerID = S.customerId
WHERE S.OrderDate = (
	SELECT MIN(OrderDate)
	FROM Sales
	WHERE customerId = S.customerId AND OrderDate <= B.JoinDate
)

-----------------------------What is the total items and amount spent for each member before they became a member?
SELECT S.customerId, SUM(M.Price) as AmountSpent, COUNT(M.ProductID) as TotalItems
FROM Sales S
	JOIN Menu M ON M.ProductID = S.ProductID 
	JOIN Members B ON B.CustomerID = S.customerId
WHERE S.OrderDate = (
	SELECT MAX(OrderDate)
	FROM Sales WHERE OrderDate >= B.JoinDate)
GROUP BY S.customerId


--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- $1 spent = 10 Points => sushi = 20 points
SELECT S.customerId, SUM(
	CASE 
		WHEN M.ProductName = 'sushi' THEN M.Price*20
		ELSE M.Price*10
	END
) as TotalPoints
FROM Sales S
JOIN Menu M ON M.ProductID = S.ProductID
GROUP BY S.customerId
-- 
--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT S.customerId, SUM(
	CASE 
		WHEN S.OrderDate BETWEEN Mb.JoinDate AND DATEADD(day, 7, mb.JoinDate) THEN M.Price*20
		WHEN M.ProductName = 'sushi' THEN M.Price*20
		ELSE M.Price END
	) as TotalPoints
FROM Sales S
JOIN Menu M ON S.ProductID = M.ProductID
LEFT JOIN Members Mb ON S.customerId = Mb.CustomerID
WHERE S.customerId IN ('A', 'B') AND S.OrderDate <= '2021-01-31'
GROUP BY S.customerId

------------------ ----------------RECREATE THE TABLE output using availale data
SELECT S.customerId, S.OrderDate, M.ProductName, M.Price,
CASE WHEN S.OrderDate >= Mb.JoinDate THEN 'Y'
ELSE 'N' END as Member
FROM Sales S
JOIN Menu M ON M.ProductID = S.ProductID
LEFT JOIN Members Mb ON Mb.CustomerID = S.customerId
ORDER BY S.customerId, S.OrderDate

----------------------------------- RANK ALL THE THINGS
WITH customers_data AS (SELECT s.customerId, S.OrderDate, M.ProductName, M.Price,
CASE WHEN s.OrderDate < mb.JoinDate THEN 'N'
	WHEN s.orderDate >= mb.JoinDate THEN 'Y'
	ELSE 'N' End as Member
FROM Sales s
JOIN Menu m ON m.ProductID = s.ProductID
LEFT JOIN Members Mb ON Mb.CustomerID  = s.CustomerID
)
SELECT *, 
CASE WHEN Member = 'N' Then NULL
ELse RANK() OVER (PARTITION BY customerId, Member Order by orderDate) END as ranking
FROM customers_data
ORDER BY customerId, OrderDate