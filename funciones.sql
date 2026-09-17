USE DonPiccolo;

DELIMITER //
-- 1. FUNCIÓN: Calcular el total de un pedido
CREATE FUNCTION calcular_total_pedido(p_id_pedido INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_subtotal_pizzas DECIMAL(10,2) DEFAULT 0;
    DECLARE v_costo_envio DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;
    DECLARE v_iva DECIMAL(10,2) DEFAULT 0.19;

    SELECT IFNULL(SUM(precio_unitario * cantidad), 0) INTO v_subtotal_pizzas
    FROM Detalle_Pedidos
    WHERE id_pedido = p_id_pedido;

    SELECT IFNULL(costo_envio, 0) INTO v_costo_envio
    FROM Domicilios
    WHERE id_pedido = p_id_pedido;

    SET v_total = (v_subtotal_pizzas * (1 + v_iva)) + v_costo_envio;

    RETURN v_total;
END //
DELIMITER ;

SELECT calcular_total_pedido(1) AS total_calculado_pedido_1;

DELIMITER //
-- 2. FUNCIÓN: Calcular la ganancia neta diaria
CREATE FUNCTION calcular_ganancia_diaria(p_fecha DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total_ventas DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total_costos DECIMAL(10,2) DEFAULT 0;

    SELECT IFNULL(SUM(total), 0) INTO v_total_ventas
    FROM Pedidos
    WHERE DATE(fecha_hora) = p_fecha AND estado = 'entregado';

    SELECT IFNULL(SUM(dp.cantidad * p_i.cantidad_requerida * i.costo_unidad), 0) INTO v_total_costos
    FROM Pedidos ped
    JOIN Detalle_Pedidos dp ON ped.id_pedido = dp.id_pedido
    JOIN Pizza_Ingredientes p_i ON dp.id_pizza = p_i.id_pizza
    JOIN Ingredientes i ON p_i.id_ingrediente = i.id_ingrediente
    WHERE DATE(ped.fecha_hora) = p_fecha AND ped.estado = 'entregado';
    
    RETURN v_total_ventas - v_total_costos;
END //
DELIMITER ;

DELIMITER //
SELECT calcular_ganancia_diaria('2026-09-01') AS ganancia_neta_2026_09_01;

-- 3. PROCEDIMIENTO ALMACENADO: Registrar entrega de pedido
CREATE PROCEDURE registrar_entrega(IN p_id_pedido INT, IN p_hora_entrega DATETIME)
BEGIN
    UPDATE Domicilios
    SET hora_entrega = p_hora_entrega
    WHERE id_pedido = p_id_pedido;

    UPDATE Pedidos
    SET estado = 'entregado'
    WHERE id_pedido = p_id_pedido;
END //

SELECT p.id_pedido, p.estado, d.hora_entrega 
FROM Pedidos p 
LEFT JOIN Domicilios d ON p.id_pedido = d.id_pedido 
WHERE p.id_pedido = 8;
CALL registrar_entrega(8, '2026-09-15 21:40:00');
SELECT p.id_pedido, p.estado, d.hora_entrega 
FROM Pedidos p 
LEFT JOIN Domicilios d ON p.id_pedido = d.id_pedido 
WHERE p.id_pedido = 8;

DELIMITER ;