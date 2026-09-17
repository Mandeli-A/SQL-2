USE DonPiccolo;

DELIMITER //

-- 1. TRIGGER: Actualizar stock de ingredientes
-- Se dispara cada vez que se agrega una pizza a un pedido

CREATE TRIGGER trg_actualizar_stock
AFTER INSERT ON Detalle_Pedidos
FOR EACH ROW
BEGIN
    UPDATE Ingredientes i
    JOIN Pizza_Ingredientes pi ON i.id_ingrediente = pi.id_ingrediente
    SET i.stock_actual = i.stock_actual - (pi.cantidad_requerida * NEW.cantidad)
    WHERE pi.id_pizza = NEW.id_pizza;
END //

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

UPDATE Pizzas SET precio_base = 38000.00 WHERE id_pizza = 2;
UPDATE Domicilios SET hora_entrega = NOW() WHERE id_repartidor = 2;