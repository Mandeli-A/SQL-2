-- Crear la base de datos y usarla
CREATE DATABASE IF NOT EXISTS DonPiccolo;
USE DonPiccolo;

-- 1. TABLAS MAESTRAS
CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    correo VARCHAR(100)
);

CREATE TABLE Repartidores (
    id_repartidor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    zona_asignada VARCHAR(100) NOT NULL,
    estado ENUM('disponible', 'no disponible') DEFAULT 'disponible'
);

CREATE TABLE Ingredientes (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    stock_actual DECIMAL(10,2) NOT NULL DEFAULT 0,
    stock_minimo DECIMAL(10,2) NOT NULL DEFAULT 10,
    costo_unidad DECIMAL(10,2) NOT NULL
);

-- 2. TABLAS DE PRODUCTOS (PIZZAS Y RECETAS)
CREATE TABLE Pizzas (
    id_pizza INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tamano ENUM('Pequeña', 'Mediana', 'Familiar') NOT NULL,
    precio_base DECIMAL(10,2) NOT NULL,
    tipo ENUM('vegetariana', 'especial', 'clásica') NOT NULL
);

CREATE TABLE Pizza_Ingredientes (
    id_pizza_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    id_pizza INT NOT NULL,
    id_ingrediente INT NOT NULL,
    cantidad_requerida DECIMAL(10,2) NOT NULL, -- Cantidad que se descuenta del stock por cada pizza
    FOREIGN KEY (id_pizza) REFERENCES Pizzas(id_pizza) ON DELETE CASCADE,
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente) ON DELETE CASCADE
);

-- 3. TABLAS TRANSACCIONALES (PEDIDOS Y DOMICILIOS)

CREATE TABLE Pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    metodo_pago ENUM('efectivo', 'tarjeta', 'app') NOT NULL,
    estado ENUM('pendiente', 'en preparación', 'entregado', 'cancelado') DEFAULT 'pendiente',
    total DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

CREATE TABLE Detalle_Pedidos (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_pizza INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(10,2) NOT NULL, -- Se guarda para mantener el historial del precio al momento de la compra
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_pizza) REFERENCES Pizzas(id_pizza)
);

CREATE TABLE Domicilios (
    id_domicilio INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE, -- UNIQUE porque es 1 domicilio por cada 1 pedido
    id_repartidor INT NOT NULL,
    hora_salida DATETIME,
    hora_entrega DATETIME,
    distancia_km DECIMAL(5,2),
    costo_envio DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_repartidor) REFERENCES Repartidores(id_repartidor)
);

-- 4. TABLA DE AUDITORÍA
CREATE TABLE Historial_Precios (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_pizza INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo DECIMAL(10,2) NOT NULL,
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario_modifico VARCHAR(50), 
    FOREIGN KEY (id_pizza) REFERENCES Pizzas(id_pizza) ON DELETE CASCADE
);


/*  DATOS INSERTADOS*/

USE DonPiccolo;

-- 1. Insertar Clientes
INSERT INTO Clientes (nombre, telefono, direccion, correo) VALUES
('Juan Pérez', '3151234567', 'Calle 10 # 5-20', 'juan@correo.com'),
('María Gómez', '3109876543', 'Cra 20 # 15-40', 'maria@correo.com'),
('Carlos Ruiz', '3205554433', 'Av 1 # 10-10', 'carlos@correo.com');

-- 2. Insertar Repartidores
INSERT INTO Repartidores (nombre, zona_asignada, estado) VALUES
('Andrés Felipe', 'Centro', 'disponible'),
('Luis Martínez', 'Norte', 'no disponible'),
('Javier Torres', 'Sur', 'disponible');

-- 3. Insertar Ingredientes
INSERT INTO Ingredientes (nombre, stock_actual, stock_minimo, costo_unidad) VALUES
('Masa (Unidad)', 50, 10, 2000.00),
('Queso Mozzarella (Kg)', 20, 5, 15000.00),
('Pepperoni (Kg)', 15, 3, 25000.00),
('Champiñones (Kg)', 2, 5, 8000.00),  -- Ojo: ¡Stock intencionalmente bajo para la vista!
('Piña (Kg)', 8, 4, 3000.00),
('Jamón (Kg)', 10, 5, 12000.00),
('Salsa de Tomate (L)', 30, 5, 4000.00);

-- 4. Insertar Pizzas
INSERT INTO Pizzas (nombre, tamano, precio_base, tipo) VALUES
('Pepperoni', 'Mediana', 25000.00, 'clásica'),
('Hawaiana', 'Familiar', 35000.00, 'especial'),
('Champiñones', 'Pequeña', 18000.00, 'vegetariana');

-- 5. Vincular Recetas (Pizza_Ingredientes)
INSERT INTO Pizza_Ingredientes (id_pizza, id_ingrediente, cantidad_requerida) VALUES
(1, 1, 1.00),    -- 1 Masa
(1, 2, 0.25),    -- 250g de Queso
(1, 7, 0.10),    -- 100ml de Salsa
(1, 3, 0.20);    -- 200g de Pepperoni

-- Receta Pizza 2 (Hawaiana)
INSERT INTO Pizza_Ingredientes (id_pizza, id_ingrediente, cantidad_requerida) VALUES
(2, 1, 1.00),    -- 1 Masa
(2, 2, 0.35),    -- 350g de Queso
(2, 7, 0.15),    -- 150ml de Salsa
(2, 5, 0.30),    -- 300g de Piña
(2, 6, 0.20);    -- 200g de Jamón

-- 6. Insertar Pedidos (Juan Pérez tendrá 6 pedidos para ser "Cliente Frecuente")
INSERT INTO Pedidos (id_cliente, fecha_hora, metodo_pago, estado, total) VALUES
(1, '2026-09-01 19:30:00', 'efectivo', 'entregado', 30000.00),
(1, '2026-09-05 20:15:00', 'tarjeta', 'entregado', 40000.00),
(1, '2026-09-10 18:45:00', 'app', 'entregado', 25000.00),
(1, '2026-09-12 19:00:00', 'efectivo', 'entregado', 35000.00),
(1, '2026-09-14 20:30:00', 'tarjeta', 'entregado', 30000.00),
(1, '2026-09-16 12:00:00', 'app', 'pendiente', 25000.00), 
(2, '2026-09-15 19:00:00', 'tarjeta', 'en preparación', 35000.00),
(3, '2026-09-15 21:00:00', 'efectivo', 'entregado', 18000.00);

-- 7. Insertar Detalles de los Pedidos
INSERT INTO Detalle_Pedidos (id_pedido, id_pizza, cantidad, precio_unitario) VALUES
(1, 1, 1, 25000.00),
(2, 2, 1, 35000.00),
(3, 1, 1, 25000.00),
(4, 2, 1, 35000.00),
(5, 1, 1, 25000.00),
(6, 1, 1, 25000.00),
(7, 2, 1, 35000.00),
(8, 3, 1, 18000.00);

-- 8. Insertar Domicilios (Vincular pedido con repartidor)
INSERT INTO Domicilios (id_pedido, id_repartidor, hora_salida, hora_entrega, distancia_km, costo_envio) VALUES
(1, 1, '2026-09-01 19:50:00', '2026-09-01 20:15:00', 3.5, 5000.00),
(2, 3, '2026-09-05 20:30:00', '2026-09-05 20:50:00', 2.0, 5000.00),
(3, 1, '2026-09-10 19:00:00', '2026-09-10 19:25:00', 4.0, 0.00),
(4, 3, '2026-09-12 19:20:00', '2026-09-12 19:40:00', 1.5, 0.00),
(5, 1, '2026-09-14 20:45:00', '2026-09-14 21:10:00', 3.0, 5000.00),
(8, 3, '2026-09-15 21:20:00', '2026-09-15 21:35:00', 2.5, 0.00);

-- 9. Insertar un dato manual de Historial de Precios para tener algo de muestra
INSERT INTO Historial_Precios (id_pizza, precio_anterior, precio_nuevo, usuario_modifico) VALUES
(1, 22000.00, 25000.00, 'admin');