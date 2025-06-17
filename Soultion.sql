--DISPLAY ALL DATA
SELECT * FROM production.brands
SELECT * FROM production.categories
SELECT * FROM production.products
SELECT * FROM production.stocks

SELECT * FROM sales.customers
SELECT * FROM sales.order_items
SELECT * FROM sales.orders
SELECT * FROM sales.staffs
SELECT * FROM sales.stores


--         EDA     -----
--there is too much missing phone values in sales.customers ,so we will delete it
ALTER TABLE sales.customers
DROP COLUMN phone

-- there is null in shipped_date col in sales orders
UPDATE sales.orders
SET shipped_date = required_date
WHERE shipped_date IS NULL


--1- Which bike is most expensive
SELECT TOP(1) product_name,list_price
FROM production.products
ORDER BY list_price DESC 

--2- How many total customers does BikeStore have
SELECT COUNT(customer_id) AS ' Total Customers'
FROM sales.customers


--3- How many stores does BikeStore have?
SELECT COUNT(store_id) #stores
FROM sales.stores


--4- What is the total price spent per order? Hint: total price = [list_price] *[quantity]*(1-[discount])
SELECT SUM( (list_price* quantity * (1-discount) )) AS 'Total price per orders' ,order_id
FROM sales.order_items 
GROUP BY order_id
ORDER BY 1 DESC



--5- What’s the sales/revenue per store?
SELECT SUM( (list_price* quantity * (1-discount) )) AS 'Total Sales' ,C.store_name
FROM sales.order_items a
JOIN sales.orders b
ON (a.order_id=b.order_id)
JOIN sales.stores c
ON(b.store_id=c.store_id)
GROUP BY C.store_name
ORDER BY 2 


--6- Which category is most sold?
SELECT c.category_name,SUM(a.quantity) 'most category sold',c.category_id
FROM sales.order_items a
JOIN production.products b
ON (a.product_id=b.product_id)
JOIN production.categories c 
ON (b.category_id=c.category_id)
GROUP BY c.category_name,c.category_id
ORDER BY 3


--7- Which category rejected more orders?
SELECT TOP(1) COUNT(a.order_status) 'Most rejected',d.category_name
FROM sales.orders a
JOIN sales.order_items b
ON(a.order_id=b.product_id)
JOIN production.products c
ON(b.product_id=c.product_id)
JOIN production.categories d
ON (c.category_id=d.category_id)
WHERE a.order_status=3
GROUP BY d.category_name
ORDER BY 1 DESC


--8 Which bike is the least sold?
SELECT TOP(1) SUM(a.quantity) #QUANTITY
,SUM(a.list_price) PRICE,b.product_name
FROM sales.order_items a
JOIN production.products b
ON(a.product_id=b.product_id)
GROUP BY b.product_name
ORDER BY 1 


--9 What’s the full name of a customer with ID 259?
SELECT first_name+' '+last_name AS 'FULL NAME'
FROM sales.customers
WHERE customer_id=259




--10- What did the customer on question 9 buy and when? 
--What’s the status of this order?

SELECT d.product_name,b.order_date,b.order_status
FROM sales.customers a
JOIN sales.orders b
ON(a.customer_id=b.customer_id)
JOIN sales.order_items c
ON(b.order_id=c.order_id)
JOIN production.products d
ON(c.product_id=d.product_id)
WHERE a.customer_id=259




--11- Which staff processed the order of customer 259? 
--And from which store?
SELECT first_name+ ' '+ last_name AS NAME,b.customer_id,c.store_name
FROM sales.staffs a
LEFT JOIN sales.orders b
ON(a.staff_id=b.staff_id)
JOIN sales.stores c
On (b.store_id=c.store_id)
WHERE b.customer_id=259


--12-How many staff does BikeStore have?

SELECT COUNT(a.staff_id)
FROM sales.staffs a

--Who seems to be the lead Staff at BikeStore?

SELECT a.first_name+ ' ' + a.last_name AS LEADER
FROM sales.staffs a
WHERE a.manager_id IS NULL


--13- Which brand is the most liked?
SELECT TOP(1) SUM(a.quantity) #QUANTITY ,b.brand_id,c.brand_name
FROM sales.order_items a
JOIN production.products b 
ON(a.product_id=b.product_id)
JOIN production.brands c
ON(b.brand_id=c.brand_id)
GROUP BY b.brand_id , c.brand_name 
ORDER BY 1 DESC


--14- How many categories does BikeStore have,
SELECT COUNT(category_id) #categories
FROM production.categories a

--and which one is the least liked?
SELECT TOP(1) SUM(a.quantity) #QUANTITY ,c.category_name
FROM sales.order_items a
JOIN production.products b 
ON(a.product_id=b.product_id)
JOIN production.categories c
ON(b.category_id=c.category_id)
GROUP BY  c.category_name 
ORDER BY 1 


--15- Which store still have more products of the most liked brand?
SELECT a.brand_name,d.store_name,SUM(c.quantity) #Quantity
FROM production.brands a
JOIN  production.products b
ON(a.brand_id=b.brand_id)
JOIN production.stocks c
ON(b.product_id=c.product_id)
JOIN sales.stores d
ON(c.store_id=d.store_id)
WHERE a.brand_name='Electra'
GROUP BY a.brand_name,d.store_name


--16-- Which state is doing better in terms of sales?
SELECT TOP(1) SUM( (a.list_price* a.quantity * (1-a.discount) )) AS 'Total Sales' ,C.store_name,c.state
FROM sales.order_items a
JOIN sales.orders b
ON (a.order_id=b.order_id)
JOIN sales.stores c
ON(b.store_id=c.store_id)
GROUP BY C.store_name,c.state
ORDER BY 1 DESC


--17- What’s the discounted price of product id 259?
SELECT discount,product_id,quantity
FROM sales.order_items
WHERE product_id=259


--18- What’s the product name, quantity, price, category, model year and brand 
--name of product number 44?	
SELECT b.product_name,SUM(a.quantity) #Quantity,a.list_price,
d.category_name,b.model_year,c.brand_name
FROM sales.order_items	 a
JOIN production.products b
ON(a.product_id=b.product_id)
JOIN production.categories d
ON(b.category_id=d.category_id)
JOIN production.brands c
ON(b.brand_id=c.brand_id)
WHERE b.product_id=44
GROUP BY b.product_name,a.list_price,d.category_name,b.model_year,c.brand_name



--19- What’s the zip code of CA?
SELECT zip_code
FROM sales.stores
WHERE state='CA'


--20- How many states does BikeStore operate in?
SELECT COUNT(DISTINCT state) #States
FROM sales.stores


--21- How many bikes under the children category were sold in the last 8 
--months?
SELECT COUNT(d.category_name) 
FROM sales.orders a
JOIN sales.order_items b 
ON(a.order_id=b.order_id)
JOIN production.products c
ON(b.product_id=c.product_id)
JOIN production.categories d
ON(c.category_id=d.category_id) 
WHERE d.category_name='Children Bicycles'
AND order_date BETWEEN '2018-04-28' AND '2018-11-18'





--22- What’s the shipped date for the order from customer 523
SELECT shipped_date
FROM sales.orders
WHERE customer_id=523



--23- How many orders are still pending?
SELECT COUNT(order_status) #ORDERS,order_status 
FROM sales.orders
GROUP BY order_status
ORDER BY 2



--24) What’s the names of category and brand does "Electra white water 3i -
--2018" fall under?

SELECT a.product_name,c.brand_name,b.category_name
FROM production.products a
LEFT JOIN production.categories b
ON(a.category_id=b.category_id)
LEFT JOIN production.brands c
ON(c.brand_id=a.brand_id)
WHERE product_name LIKE 'Electra white%'



 







