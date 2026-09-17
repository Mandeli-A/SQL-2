USE DonPiccolo;

-- VISTA 1: Resumen de pedidos por cliente
CREATE VIEW vista_resumen_clientes AS
SELECT 
    c.nombre AS cliente, 
    COUNT(p.id_pedido) AS cantidad_pedidos, 
    IFNULL(SUM(p.total), 0) AS total_gastado
FROM Clientes c
LEFT JOIN Pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nombre;

-- VISTA 2: Desempeño de repartidores
CREATE VIEW vista_desempeno_repartidores AS
SELECT 
    r.nombre AS repartidor, 
    r.zona_asignada, 
    COUNT(d.id_domicilio) AS numero_entregas,
    IFNULL(AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)), 0) AS tiempo_promedio_minutos
FROM Repartidores r
LEFT JOIN Domicilios d ON r.id_repartidor = d.id_repartidor AND d.hora_entrega IS NOT NULL
GROUP BY r.id_repartidor, r.nombre, r.zona_asignada;

-- VISTA 3: Stock de ingredientes crítico
CREATE VIEW vista_stock_critico AS
SELECT 
    nombre AS ingrediente, 
    stock_actual, 
    stock_minimo
FROM Ingredientes
WHERE stock_actual < stock_minimo;