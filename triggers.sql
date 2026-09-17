USE DonPiccolo;

DELIMITER //

-- 1. TRIGGER: Actualizar stock de ingredientes
CREATE TRIGGER trg_actualizar_stock
AFTER INSERT ON Detalle_Pedidos
FOR EACH ROW
BEGIN
    UPDATE Ingredientes i
    JOIN Pizza_Ingredientes pi ON i.id_ingrediente = pi.id_ingrediente
    SET i.stock_actual = i.stock_actual - (pi.cantidad_requerida * NEW.cantidad)
    WHERE pi.id_pizza = NEW.id_pizza;
END //

DELIMITER ;

SELECT i.id_ingrediente, i.nombre, i.stock_actual 
FROM Ingredientes i
JOIN Pizza_Ingredientes pi ON i.id_ingrediente = pi.id_ingrediente
WHERE pi.id_pizza = 1;

INSERT INTO Detalle_Pedidos (id_pedido, id_pizza, cantidad, precio_unitario) 
VALUES (6, 1, 2, 25000.00);

SELECT i.id_ingrediente, i.nombre, i.stock_actual 
FROM Ingredientes i
JOIN Pizza_Ingredientes pi ON i.id_ingrediente = pi.id_ingrediente
WHERE pi.id_pizza = 1;


DELIMITER //

-- 2. TRIGGER: Auditoría de precios de pizzas
CREATE TRIGGER trg_auditoria_precios
AFTER UPDATE ON Pizzas
FOR EACH ROW
BEGIN
    IF OLD.precio_base <> NEW.precio_base THEN
        INSERT INTO Historial_Precios (id_pizza, precio_anterior, precio_nuevo, usuario_modifico)
        VALUES (NEW.id_pizza, OLD.precio_base, NEW.precio_base, CURRENT_USER());
    END IF;
END //

DELIMITER ;

SELECT id_pizza, nombre, precio_base FROM Pizzas WHERE id_pizza = 2;

UPDATE Pizzas 
SET precio_base = 38000.00 
WHERE id_pizza = 2;

SELECT * FROM Historial_Precios WHERE id_pizza = 2;


DELIMITER //

-- 3. TRIGGER: Liberar repartidor al terminar un domicilio
CREATE TRIGGER trg_liberar_repartidor
AFTER UPDATE ON Domicilios
FOR EACH ROW
BEGIN
    IF OLD.hora_entrega IS NULL AND NEW.hora_entrega IS NOT NULL THEN
        UPDATE Repartidores
        SET estado = 'disponible'
        WHERE id_repartidor = NEW.id_repartidor;
    END IF;
END //

DELIMITER ;

SELECT r.id_repartidor, r.nombre, r.estado AS estado_repartidor, d.hora_entrega 
FROM Repartidores r
JOIN Domicilios d ON r.id_repartidor = d.id_repartidor
WHERE r.id_repartidor = 2;
UPDATE Domicilios 
SET hora_entrega = NOW() 
WHERE id_repartidor = 2;

SELECT r.id_repartidor, r.nombre, r.estado AS estado_repartidor, d.hora_entrega 
FROM Repartidores r
JOIN Domicilios d ON r.id_repartidor = d.id_repartidor
WHERE r.id_repartidor = 2;