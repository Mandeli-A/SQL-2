SELECT c.nombre AS nombre_cliente, p.id_pedido, p.total, p.estado 
FROM clientes c 
JOIN pedidos p ON c.id_cliente = p.id_cliente;

SELECT * 
FROM pedidos 
WHERE estado = 'entregado' 
  AND fecha_pedido BETWEEN '2026-01-01' AND '2026-12-31';

SELECT metodo_pago, COUNT(*) AS cantidad_pedidos, SUM(total) AS total_acumulado 
FROM pedidos 
GROUP BY metodo_pago;

SELECT c.id_cliente, c.nombre, COUNT(p.id_pedido) AS total_pedidos 
FROM clientes c 
JOIN pedidos p ON c.id_cliente = p.id_cliente 
GROUP BY c.id_cliente, c.nombre 
HAVING COUNT(p.id_pedido) > 5;