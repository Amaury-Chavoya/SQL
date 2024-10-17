SELECT * FROM menu_items
--B)
--ENCONTRAR EL NÚMERO DE ARTÍCULOS EN EL MENÚ
SELECT count(menu_item_id) 
FROM menu_items

--¿CUÁL ES EL ARTÍCULO MÁS Y MENOS CARO DEL MENÚ?
SELECT item_name AS "Item Name", price AS "Price"
FROM menu_items
WHERE price = (SELECT MIN (price) FROM menu_items) OR price = (SELECT MAX (price) FROM menu_items)

-- ¿CUÁNTOS PLATOS AMERICANOS HAY EN EL MENÚ?
SELECT COUNT(category)
FROM menu_items 
WHERE category = 'American'

-- ¿CUÁL ES EL PRECIO PROMEDIO DE LOS PLATOS?
SELECT AVG(price) 
FROM menu_items

--C) 
	SELECT * FROM order_details 
--¿CUÁNTOS PEDIDOS ÚNICOS SE REALIZARON EN TOTAL?
SELECT COUNT(order_details_id)
FROM order_details

--¿CUÁLES SON LOS 7 PEDIDOS QUE TUVIERON MAYOR NÚMERO DE ARTÍCULOS?
SELECT order_id, COUNT(order_id) AS "Número de artículos"
FROM order_details
GROUP BY order_id
ORDER BY 2 DESC
LIMIT 7

--¿CÚANDO SE REALIZÓ EL PRIMER Y ÚLTIMO PEDIDO?
SELECT MIN (order_date) AS "Primer pedido", MAX(order_date) AS "Último pedido"
FROM order_details

--¿CÚANTOS PEDIDOS SE HICIERON ENTRE '2023-01-01' Y EL '2023-01-05'?
SELECT COUNT(order_date) AS "Cantidad de pedidos"
FROM order_details
WHERE order_date BETWEEN '2023-01-01' AND '2023-01-05'

--D)USAR AMBAS TABLAS PARA CONOCER LA REACCIÓN DE LA GENTE SOBRE EL MENÚ
SELECT * FROM menu_items
SELECT * FROM order_details
	
--1. REALIZAR UN LEFT JOIN ENTRE order_details y menu_items CON EL IDENTIFICADOR item_id(order_details)
--   Y menu_item_id(menu_items) Y REALIZAR CONSULTAS PARA OBTENER LO SIGUIENTE
SELECT item_id, menu_item_id, order_details, menu_items
FROM order_details
LEFT JOIN menu_items ON item_id = menu_item_id

	--ANÁLISIS DE DATOS - 5 PUNTOS CLAVES

--1.-¿CUÁNTOS PEDIDOS HUBO POR CATEGORÍA?
/*Esto para saber qué categoría es mi más vendida y cuál 
es a la que le tengo que poner más empeño*/
	
SELECT category, COUNT(order_id) AS "Total"
FROM menu_items
LEFT JOIN order_details ON item_id = menu_item_id
GROUP BY category 
ORDER BY "Total" DESC

/*Teniendo la categoría con más ventas ahora veremos qué
productos nos Siguen funcionando como top 3, así podemos meter
alguna variación en el mísmo o acompañar con algún producto bottom 3
para que estos se vendan más*/
	
--2.-¿TOP 3 PLATILLOS ASIÁTICOS?
	
SELECT item_name, COUNT(order_id) AS Total_Orders
FROM menu_items
LEFT JOIN order_details ON item_id = menu_item_id
WHERE category = 'Asian'
GROUP BY item_name
ORDER BY Total_Orders DESC
LIMIT 3;

--¿BOTTOM 3 PLATILLOS ASIÁTICOS?

SELECT item_name, COUNT(order_id) AS Total_Orders
FROM menu_items
LEFT JOIN order_details ON item_id = menu_item_id
WHERE category = 'Asian'
GROUP BY item_name
ORDER BY Total_Orders ASC
LIMIT 3;

/*El análisis que haría aquí sería en que la comida Asiática se mantenga igual 
en ventas o mejor, para lo último podemos generar paquetes a un precio que haga
que los bottom 3 se vendan para obtener más ganancia*/

--3.-¿ANÁLISIS DE LA DEMANDA EN DIFERENTES HORARIOS?

SELECT category,COUNT(order_id) AS Total_Orders,
CASE
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 11 THEN 'Morning'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 17 THEN 'Afternoon'
	WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 23 THEN 'Evening'
	ELSE 'Night'
END AS Time_Period
FROM menu_items
LEFT JOIN order_details ON item_id = menu_item_id
GROUP BY category, Time_Period
ORDER BY Total_Orders DESC

/*Al analizar los datos vemos que en la tarde es donde mayor número de órdenes 
se tienen, teniando a la asiática, italiana y mexicana como top 3. Por la mañana
es cuando hay menor número de órdenes, siendo irónicamente la mexicana, italaian y americana.
La propuesta sería tener menos personal en la mañana y más por la tarde, podemos reducir costos
si es que se tienen mayor números de empleados de lo necesario por la mañana y/o poner mejores
promociones en la mañana para aumentar las ganancias en ese periodo de tiempo*/

--4.-¿QUÉ PLATILLOS NOS DEJAN MEJOR GANANCIA?
	
SELECT category, item_name,
	COUNT(menu_item_id) AS Number_of_orders,
	COUNT(menu_item_id) * price AS Total_revenue
FROM menu_items
LEFT JOIN order_details ON item_id = menu_item_id
GROUP BY category, item_name, price
ORDER BY Total_revenue DESC

/*Esta parte es importante, porque nos ayuda a maximizar ganancias dependiendo
del producto que más venda, hacer recorde de presupuestos en las que no y seguir 
invirtiendo en las que sí*/

--5.-¿CÓMO FUERON LAS VENTAS POR MES?

SELECT 
	DATE_TRUNC('month', order_date) AS Month_starting,
	COUNT(order_id) AS Total_orders,
	SUM(price) AS Total_revenue
FROM order_details
LEFT JOIN menu_items ON item_id = menu_item_id
GROUP BY Month_starting
ORDER BY Month_starting DESC;

/*Para corroborar podemos contar el número de pedidos realizados para saber
si la sumatoria del total de ordenes es correcto*/

SELECT COUNT(order_details_id)
FROM order_details --Vemos que son 12,234 igual que en la tabla pasada si sumamos por mes.

