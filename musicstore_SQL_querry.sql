use Music_Store
-- Q1. Who is the senior most employee based on job title 
 
 select top 1 first_name, last_name, employee_id from employee
 order by levels desc 

-- Q2. Which country have the most invoices

 select top 1 billing_country, count(invoice_id) as #_of_invoices from invoice
 group by billing_country 
 order by #_of_invoices desc

-- Q3. What are top 3 values of total invoices

 select top 3 invoice_id, cast(total as decimal(10,2)) as invoice_value from invoice
 order by total desc

--Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name & sum of all invoice totals

select top 1 billing_city, cast(sum(total) as decimal (10,2)) as invoice_total from invoice
group by billing_city
order by invoice_total desc

--Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money.

select top 1 a.customer_id, a.first_name, a.last_name,sum(b.total) as total_money_spent 
from customer as a
 join invoice as b
 on a.customer_id = b.customer_id
 group by a.customer_id, a.first_name, a.last_name
 order by total_money_spent   desc

-- Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A

select a.first_name, a.last_name, a.email from customer as a
join invoice as b
on b.customer_id = a.customer_id
where b.invoice_id in (select invoice_id from invoice_line where track_id in 
					  (select track_id from track
					   where genre_id =( select genre_id from genre where name like 'Rock')))
order by a.email

-- Q7. Lets invite thge artist who have written the most number of rock music our datasheet.
-- Write a querry that returns the name of artist and total track counts of top 10 rock bands.

select top 10 c.name, a.artist_id, count(t.track_id) as no_of_tracks from track as t
join album as a on a.album_id = t.album_id
join artist as c on c.artist_id = a.artist_id
where t.genre_id = (select genre_id from genre where name like 'Rock')
group by c.name, a.artist_id
order by no_of_tracks desc

--Q8. Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

select name, milliseconds as track_lenght from track
where milliseconds > (select avg(milliseconds) from track)
order by track_lenght desc

--Q1: Find how much amount spent by each customer on artists? 
--Write a query to return customer name, artist name and total spent.

with bsa as(
select b.artist_id, b.name, sum(a.unit_price*a.quantity) as total
from invoice_line as a
join track as c
on a.track_id = c.track_id
join album as d
on c.album_id = d.album_id
join artist as b
on b.artist_id = d.artist_id
group by b.artist_id, b.name
)

select p.customer_id,p.first_name, p.last_name, bsa.name, sum(r.unit_price*r.quantity)as amount_spent from customer as p
join invoice as q
on p.customer_id = q.customer_id
join invoice_line as r
on q.invoice_id = r.invoice_id
join track as s
on r.track_id = s.track_id
join album as t
on s.album_id = t.album_id
join  bsa
on t.artist_id = bsa.artist_id
group by p.customer_id,p.first_name, p.last_name, bsa.name
order by amount_spent desc

--Q9: We want to find out the most popular music Genre for each country.
    --We determine the most popular genre as the genre with the highest amount of purchases. 
    --Write a query that returns each country along withthe top Genre. 
    --For countries where the maximum number of purchases is shared return all Genres.


WITH popular_genre AS 
(
    SELECT COUNT(il.quantity) AS purchases, 
           c.country, 
           g.name, 
           g.genre_id, 
           ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo 
    FROM invoice_line AS il
    JOIN invoice AS i ON i.invoice_id = il.invoice_id
    JOIN customer AS c ON c.customer_id = i.customer_id
    JOIN track AS t ON t.track_id = il.track_id
    JOIN genre AS g ON g.genre_id = t.genre_id
    GROUP BY c.country, g.name, g.genre_id
)
SELECT * FROM popular_genre WHERE RowNo = 1
ORDER BY country ASC, purchases DESC;

--Q10: Q3: Write a query that determines the customer that has spent the moston music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount

WITH Customer_with_country AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country,
        SUM(i.total) AS total_spending,
        ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS RowNo 
    FROM invoice AS i
    JOIN customer AS c ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
)
SELECT * FROM Customer_with_country 
WHERE RowNo = 1
ORDER BY billing_country ASC, total_spending DESC;



