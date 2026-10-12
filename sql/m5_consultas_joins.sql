-- Motor utilizado: SQL Server (SSMS)
-- =====================================================================
-- Proyecto RetailPro - Pre-entrega Módulo 5: Consultas con JOINs
-- Base: Ventas_Tech_DB (esquema del Checkpoint del Módulo 3)
-- Dimensiones disponibles: clientes (incluye ciudad, que funciona como
-- dimensión geográfica), productos y categorias.
-- =====================================================================
USE Ventas_Tech_DB;
GO

-- =====================================================================
-- Consulta 1 - Vista base del proyecto (INNER JOIN)
-- Una fila por venta con los datos descriptivos de cliente, producto y
-- categoría. Es la fuente principal para Power BI:
--   - columna para agrupar: nombre_categoria
--   - columna para filtrar: ciudad
-- =====================================================================
SELECT
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre                           AS nombre_cliente,
    c.ciudad,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario     AS total_venta
FROM ventas AS v
INNER JOIN clientes   AS c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  AS p   ON v.id_producto  = p.id_producto
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
-- Resultado esperado: 10 filas (todas las ventas tienen cliente, producto
-- y categoría válidos, así que el INNER JOIN no descarta ninguna).

-- =====================================================================
-- Consulta 2 - Clientes sin ventas (LEFT JOIN + IS NULL)
-- El LEFT JOIN conserva todos los clientes; los que no tienen ventas
-- quedan con v.id_venta en NULL, y ese es el filtro.
-- =====================================================================
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
-- Resultado con los datos actuales: 0 filas. Los 5 clientes registrados
-- compraron al menos una vez. Ver prueba de control al final del archivo.

-- =====================================================================
-- Consulta 3 - Productos sin ventas (LEFT JOIN + IS NULL)
-- =====================================================================
SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos AS p
LEFT JOIN ventas     AS v   ON p.id_producto  = v.id_producto
LEFT JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL;
-- Resultado con los datos actuales: 0 filas. Los 6 productos del catálogo
-- tienen al menos una venta. Ver prueba de control al final del archivo.
-- Se usa LEFT JOIN también contra categorias para no perder un producto
-- que tuviera la categoría en NULL.

-- =====================================================================
-- Consulta 4 - Consolidado por origen (UNION ALL)
-- La columna "canal" no existe en la tabla: se crea como valor literal en
-- cada SELECT. Criterio de separación: período de la venta
-- (primera quincena de marzo hasta el día 10 / resto del mes).
-- Se usa UNION ALL y no UNION para que ninguna venta se descarte por
-- coincidir en todos sus valores con otra: cada venta se cuenta una vez.
-- =====================================================================
SELECT
    canal,
    COUNT(*)   AS cantidad_ventas,
    SUM(total) AS total_canal
FROM (
    SELECT fecha_venta,
           cantidad * precio_unitario AS total,
           'Periodo 1 (01 al 10 de marzo)' AS canal
    FROM ventas
    WHERE fecha_venta <  '2024-03-11'
    UNION ALL
    SELECT fecha_venta,
           cantidad * precio_unitario AS total,
           'Periodo 2 (11 al 31 de marzo)' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-11'
) AS consolidado
GROUP BY canal
ORDER BY canal;
-- Resultado esperado: Periodo 1 = 5 ventas / USD 3.620,00
--                     Periodo 2 = 5 ventas / USD 2.824,00
-- Total = USD 6.444,00 (coincide con el total facturado de M4: no se
-- perdió ni se duplicó ninguna venta).

-- =====================================================================
-- PRUEBA DE CONTROL (opcional) para las consultas 2 y 3
-- Como hoy devuelven 0 filas, se valida la lógica insertando un cliente
-- y un producto sin ventas DENTRO de una transacción que se deshace al
-- final (ROLLBACK). La base queda exactamente igual que antes.
-- =====================================================================
BEGIN TRANSACTION;

    INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro)
    VALUES (99, 'Cliente de Prueba', 'prueba@mail.com', 'Rosario', '2024-03-20');

    INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo)
    VALUES (99, 'Producto de Prueba', 4, 50.00, 10, 1);

    -- Debe devolver 1 fila: Cliente de Prueba
    SELECT c.nombre, c.email, c.fecha_registro
    FROM clientes AS c
    LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
    WHERE v.id_venta IS NULL;

    -- Debe devolver 1 fila: Producto de Prueba
    SELECT p.nombre_producto, cat.nombre_categoria AS categoria, p.precio
    FROM productos AS p
    LEFT JOIN ventas     AS v   ON p.id_producto  = v.id_producto
    LEFT JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
    WHERE v.id_venta IS NULL;

ROLLBACK TRANSACTION;
