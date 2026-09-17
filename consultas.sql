-- 1. Clientes con pedidos entre dos fechas (BETWEEN)
SELECT DISTINCT c.nombre, p.fecha_hora, p.total
FROM Clientes c
JOIN Pedidos p ON c.id_cliente = p.id_cliente
WHERE p.fecha_hora BETWEEN '2026-09-01 00:00:00' AND '2026-09-15 23:59:59';

-- 2. Pizzas más vendidas (GROUP BY y COUNT/SUM)
SELECT pz.nombre, SUM(dp.cantidad) AS cantidad_vendida
FROM Pizzas pz
JOIN Detalle_Pedidos dp ON pz.id_pizza = dp.id_pizza
GROUP BY pz.id_pizza, pz.nombre
ORDER BY cantidad_vendida DESC;

-- 3. Pedidos por repartidor 
SELECT r.nombre AS repartidor, p.id_pedido, p.estado, p.metodo_pago
FROM Repartidores r
JOIN Domicilios d ON r.id_repartidor = d.id_repartidor
JOIN Pedidos p ON d.id_pedido = p.id_pedido;

-- 4. Promedio de entrega por zona en minutos 
SELECT r.zona_asignada, AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)) AS tiempo_promedio_minutos
FROM Repartidores r
JOIN Domicilios d ON r.id_repartidor = d.id_repartidor
WHERE d.hora_entrega IS NOT NULL
GROUP BY r.zona_asignada;

-- 5. Clientes que gastaron más de un monto específico 
-- (Ejemplo: clientes que gastaron más de $50,000 en total)
SELECT c.nombre, SUM(p.total) AS total_gastado
FROM Clientes c
JOIN Pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nombre
HAVING total_gastado > 50000;

-- 6. Búsqueda por coincidencia parcial de nombre de pizza
SELECT * FROM Pizzas 
WHERE nombre LIKE '%Peppe%';

-- 7. Subconsulta para obtener los clientes frecuentes (más de 5 pedidos mensuales)
SELECT nombre, telefono, correo 
FROM Clientes 
WHERE id_cliente IN (
    SELECT id_cliente 
    FROM Pedidos 
    WHERE MONTH(fecha_hora) = 9 AND YEAR(fecha_hora) = 2026
    GROUP BY id_cliente 
    HAVING COUNT(id_pedido) > 5
);