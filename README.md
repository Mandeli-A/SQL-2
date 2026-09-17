
# README GENERAL - SISTEMA DE GESTION DE BASE DE DATOS: PIZZERIA "DON PICCOLO"

---
<img width="728" height="565" alt="Captura de pantalla 2026-09-17 121456" src="https://github.com/user-attachments/assets/ad62c826-69b2-42f7-8616-895e763774db" />

## 1. INTRODUCCION Y DESCRIPCION GENERAL DEL PROYECTO

El presente documento constituye la documentacion tecnica y explicativa del sistema de base de datos relacional disenado para la pizzeria **"Don Piccolo"**. Este sistema gestiona de manera integral todos los procesos operativos y administrativos del negocio, abarcando el control de clientes, repartidores, inventario de ingredientes, gestion de recetas, procesamiento de pedidos, asignacion de domicilios y auditoria de precios.

La base de datos ha sido desarrollada bajo el motor **MySQL** , estructurandose en multiples tablas maestras, transaccionales, intermedias y de auditoria, complementadas con componentes programables avanzados como **consultas SQL complejas, vistas, funciones almacenadas, procedimientos almacenados y disparadores (triggers)**.

---

## 2. ESTRUCTURA DE LA BASE DE DATOS (DATABASE SCHEMA)

La base de datos se denomina `DonPiccolo` y se divide en cuatro bloques estructurales principales:

### 2.1 Tablas Maestras (Entidades Principales)
*   **`Clientes`**: Almacena la informacion de los compradores de la pizzeria.
    *   `id_cliente` (INT, PK, Auto_Increment): Identificador unico del cliente.
    *   `nombre` (VARCHAR): Nombre completo del cliente.
    *   `telefono` (VARCHAR): Numero telefonico de contacto.
    *   `direccion` (VARCHAR): Direccion de envio predeterminada.
    *   `correo` (VARCHAR): Correo electronico para notificaciones.
*   **`Repartidores`**: Gestiona al personal encargado de los domicilios.
    *   `id_repartidor` (INT, PK, Auto_Increment): Identificador unico del repartidor.
    *   `nombre` (VARCHAR): Nombre completo del repartidor.
    *   `zona_asignada` (VARCHAR): Zona geografica de cobertura (Ej. 'Centro', 'Norte', 'Sur').
    *   `estado` (ENUM): Estado operativo del repartidor (`'disponible'`, `'no disponible'`).
*   **`Ingredientes`**: Controla el inventario de materias primas.
    *   `id_ingrediente` (INT, PK, Auto_Increment): Identificador unico del ingrediente.
    *   `nombre` (VARCHAR): Nombre del insumo (Ej. 'Queso Mozzarella', 'Masa').
    *   `stock_actual` (DECIMAL): Cantidad actual disponible en inventario.
    *   `stock_minimo` (DECIMAL): Umbral minimo permitido antes de considerarse stock critico.
    *   `costo_unidad` (DECIMAL): Costo de adquisicion por unidad o medida.

### 2.2 Tablas de Productos y Recetas
*   **`Pizzas`**: Catalogo de productos ofrecidos a la venta.
    *   `id_pizza` (INT, PK, Auto_Increment): Identificador unico de la pizza.
    *   `nombre` (VARCHAR): Nombre comercial de la pizza (Ej. 'Pepperoni', 'Hawaiana').
    *   `tamano` (ENUM): Tamano de la pizza (`'Pequeña'`, `'Mediana'`, `'Familiar'`).
    *   `precio_base` (DECIMAL): Precio de venta base del producto.
    *   `tipo` (ENUM): Categoria culinaria (`'vegetariana'`, `'especial'`, `'clásica'`).
*   **`Pizza_Ingredientes` (Tabla Intermedia / Recetas)**: Define la receta de cada pizza y la cantidad de insumo que consume.
    *   `id_pizza_ingrediente` (INT, PK, Auto_Increment).
    *   `id_pizza` (INT, FK): Relacion con la tabla `Pizzas`.
    *   `id_ingrediente` (INT, FK): Relacion con la tabla `Ingredientes`.
    *   `cantidad_requerida` (DECIMAL): Cantidad exacta que se descuenta del inventario por cada unidad de pizza elaborada.

### 2.3 Tablas Transaccionales
*   **`Pedidos`**: Cabecera de las transacciones de compra realizadas por los clientes.
    *   `id_pedido` (INT, PK, Auto_Increment).
    *   `id_cliente` (INT, FK): Cliente que realiza el pedido.
    *   `fecha_hora` (DATETIME): Marca temporal de la creacion del pedido.
    *   `metodo_pago` (ENUM): Forma de pago (`'efectivo'`, `'tarjeta'`, `'app'`).
    *   `estado` (ENUM): Ciclo de vida del pedido (`'pendiente'`, `'en preparación'`, `'entregado'`, `'cancelado'`).
    *   `total` (DECIMAL): Monto total monetario de la transaccion.
*   **`Detalle_Pedidos`**: Detalle de las pizzas solicitadas dentro de cada pedido.
    *   `id_detalle` (INT, PK, Auto_Increment).
    *   `id_pedido` (INT, FK): Pedido al que pertenece el detalle.
    *   `id_pizza` (INT, FK): Pizza solicitada.
    *   `cantidad` (INT): Numero de unidades de dicha pizza.
    *   `precio_unitario` (DECIMAL): Precio congelado al momento de la compra para proteger el historial financiero.
*   **`Domicilios`**: Gestion de la logistica de entrega asociada a un pedido.
    *   `id_domicilio` (INT, PK, Auto_Increment).
    *   `id_pedido` (INT, FK, UNIQUE): Relacion uno a uno estricta con el pedido.
    *   `id_repartidor` (INT, FK): Repartidor asignado a la entrega.
    *   `hora_salida` (DATETIME): Hora en que el repartidor sale del establecimiento.
    *   `hora_entrega` (DATETIME): Hora efectiva de entrega al cliente.
    *   `distancia_km` (DECIMAL): Distancia estimada del recorrido en kilometros.
    *   `costo_envio` (DECIMAL): Costo monetario cobrado por el servicio de domicilio.

### 2.4 Tabla de Auditoría
*   **`Historial_Precios`**: Registra los cambios de precios realizados en las pizzas.
    *   `id_historial` (INT, PK, Auto_Increment).
    *   `id_pizza` (INT, FK): Pizza modificada.
    *   `precio_anterior` (DECIMAL): Precio antes del cambio.
    *   `precio_nuevo` (DECIMAL): Nuevo precio establecido.
    *   `fecha_cambio` (DATETIME): Momento en que ocurrio la modificacion.
    *   `usuario_modifico` (VARCHAR): Usuario de base de datos que ejecuto la operacion.

---

## 3. CONSULTAS SQL EXPLICADAS (consultas.sql)

El archivo de consultas recopila operaciones analíticas y de filtrado esenciales para la administracion diaria del negocio:

1.  **Clientes con pedidos entre dos fechas (`BETWEEN`):**
    *   *Funcionamiento:* Realiza un `JOIN` entre `Clientes` y `Pedidos`, filtrando mediante el operador `BETWEEN` un rango estricto de fecha y hora (`fecha_hora`). El uso de `DISTINCT` asegura que si un cliente realizo multiples pedidos en el rango, no aparezca duplicado en una consulta simple de listado de clientes activos.
2.  **Pizzas más vendidas (`GROUP BY`, `SUM` y ordenamiento):**
    *   *Funcionamiento:* Conecta las tablas `Pizzas` y `Detalle_Pedidos`, agrupando por identificador y nombre de pizza. Utiliza la funcion de agregacion `SUM(dp.cantidad)` para sumar el volumen total de unidades despachadas y ordena el resultado de forma descendente (`DESC`) para destacar el producto estrella.
3.  **Pedidos por repartidor (`JOIN` multiple):**
    *   *Funcionamiento:* Conecta la tabla `Repartidores` con `Domicilios` y posteriormente con `Pedidos`. Permite visualizar la trazabilidad completa de que repartidor atendio cual pedido, su estado actual y metodo de pago.
4.  **Promedio de entrega por zona en minutos (`TIMESTAMPDIFF` y `AVG`):**
    *   *Funcionamiento:* Cruza `Repartidores` y `Domicilios`, filtrando aquellos registros donde la entrega ya se haya efectuado (`hora_entrega IS NOT NULL`). Utiliza `TIMESTAMPDIFF(MINUTE, hora_salida, hora_entrega)` para calcular la duracion exacta del trayecto en minutos, agrupando por `zona_asignada` y aplicando la funcion `AVG()` para obtener el rendimiento logistico promedio por zona.
5.  **Clientes que gastaron más de un monto específico (`HAVING`):**
    *   *Funcionamiento:* Agrupa los pedidos por cliente sumando su gasto total (`SUM(p.total)`). A diferencia del filtro `WHERE`, la clausula `HAVING total_gastado > 50000` filtra los grupos agregados despues de realizar la suma, mostrando unicamente a los clientes de mayor valor comercial (VIP).
6.  **Búsqueda por coincidencia parcial (`LIKE`):**
    *   *Funcionamiento:* Emplea el operador `LIKE '%Peppe%'` sobre la tabla `Pizzas` para realizar busquedas flexibles por texto, encontrando coincidencias sin importar si el patron esta al inicio, en medio o al final del nombre.
7.  **Subconsulta para clientes frecuentes (Filtro avanzado con `IN`):**
    *   *Funcionamiento:* Utiliza una subconsulta anidada que evalua los pedidos del mes actual (Septiembre 2026), agrupando por `id_cliente` y filtrando mediante `HAVING COUNT(id_pedido) > 5`. La consulta principal devuelve los datos de contacto de dichos clientes frecuentes.

---

## 4. VISTAS SQL EXPLICADAS (vistas.sql)

Las vistas son consultas almacenadas que se comportan como tablas virtuales, simplificando la lectura de informacion compleja y protegiendo la estructura interna:

1.  **`vista_resumen_clientes`**:
    *   *Qué hace:* Genera un reporte consolidado de cada cliente, mostrando su nombre, el conteo total de pedidos realizados (`COUNT`) y la sumatoria historica monetaria gastada (`SUM(p.total)`). Utiliza un `LEFT JOIN` para incluir incluso a aquellos clientes que aun no han registrado ningun pedido (mostrando 0 en cantidad y gasto).
2.  **`vista_desempeno_repartidores`**:
    *   *Qué hace:* Evalua la eficiencia del personal de entrega. Calcula cuantas entregas ha completado cada repartidor y el tiempo promedio que tardan en minutos utilizando `TIMESTAMPDIFF` condicionado a entregas finalizadas.
3.  **`vista_stock_critico`**:
    *   *Qué hace:* Actúa como un semáforo de inventario. Filtra la tabla `Ingredientes` mostrando unicamente aquellos insumos cuyo `stock_actual` sea estrictamente menor al `stock_minimo` configurado, permitiendo al administrador reabastecer a tiempo antes de quedarse sin materia prima.

---

## 5. FUNCIONES Y PROCEDIMIENTOS ALMACENADOS EXPLICADOS (funciones.sql)

La programacion almacenada encapsula la logica de negocio directamente en el motor de base de datos:

1.  **Funcion `calcular_total_pedido(p_id_pedido INT)`:**
    *   *Cómo funciona:* Es una funcion deterministica que recibe el ID de un pedido. Calcula de forma automatizada el subcosto de las pizzas multiplicando precio unitario por cantidad, le suma el costo del domicilio obtenido de la tabla `Domicilios` y aplica de forma interna un impuesto de IVA del 19% (`v_iva = 0.19`), retornando el valor monetario final exacto a pagar.
2.  **Funcion `calcular_ganancia_diaria(p_fecha DATE)`:**
    *   *Cómo funciona:* Realiza un balance financiero para una fecha especifica. Por un lado, suma los ingresos totales de los pedidos entregados en ese dia; por otro lado, calcula el costo real de los ingredientes consumidos mediante el cruce de recetas (`Pizza_Ingredientes`) e inventario (`costo_unidad`). Retorna la resta matematica (`Ingresos - Costos = Ganancia Neta`).
3.  **Procedimiento Almacenado `registrar_entrega(IN p_id_pedido INT, IN p_hora_entrega DATETIME)`:**
    *   *Cómo funciona:* A diferencia de las funciones (que retornan un valor en una expresion), este procedimiento ejecuta una transaccion de escritura doble: actualiza la `hora_entrega` en la tabla `Domicilios` y simultaneamente cambia el estado del pedido a `'entregado'` en la tabla `Pedidos`.

---

## 6. TRIGGERS (DISPARADORES) EXPLICADOS (triggers.sql)

Los triggers son rutinas que se disparan de forma automatica ante eventos especificos de lenguaje de manipulacion de datos (`INSERT`, `UPDATE`, `DELETE`):

1.  **`trg_actualizar_stock` (Trigger `AFTER INSERT` en `Detalle_Pedidos`):**
    *   *Cómo funciona:* Cada vez que se inserta un nuevo detalle en un pedido (es decir, cuando se vende una pizza), este disparador se activa de forma automatica. Consulta la receta de esa pizza en `Pizza_Ingredientes` y descuenta proporcionalmente del stock actual de cada ingrediente la cantidad requerida multiplicada por la cantidad de pizzas vendidas. Esto automatiza el control de inventario en tiempo real.
2.  **`trg_auditoria_precios` (Trigger `AFTER UPDATE` en `Pizzas`):**
    *   *Cómo funciona:* Monitorea cambios en el precio base de las pizzas. Si el precio nuevo (`NEW.precio_base`) difiere del precio anterior (`OLD.precio_base`), inserta automaticamente un registro en la tabla `Historial_Precios` almacenando cual era el precio viejo, cual es el nuevo, la fecha exacta y el usuario de la base de datos que ejecuto la modificacion (`CURRENT_USER()`), garantizando trazabilidad y seguridad financiera.
3.  **`trg_liberar_repartidor` (Trigger `AFTER UPDATE` en `Domicilios`):**
    *   *Cómo funciona:* Detecta cuando un domicilio finaliza su entrega (cuando el campo `hora_entrega` pasa de ser `NULL` a contener una fecha valida). Al cumplirse esta condicion, actualiza de inmediato el estado del repartidor correspondiente en la tabla `Repartidores` a `'disponible'`, permitiendo que el sistema le asigne nuevos pedidos de forma inmediata.

---

## 7. INSTRUCCIONES DE DESPLIEGUE Y USO

1.  Ejecute el script de creacion de tablas e insercion de datos iniciales (`database.sql`).
2.  Cargue las consultas analiticas segun necesidad operativa (`consultas.sql`).
3.  Implemente las vistas de monitoreo (`vistas.sql`).
4.  Compile las funciones y procedimientos almacenados (`funciones.sql`).
5.  Active los triggers de automatizacion logica (`triggers.sql`).
