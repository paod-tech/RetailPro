-- Motor utilizado: SQL Server (SSMS)
-- =====================================================================
-- Proyecto RetailPro - Pre-entrega Módulo 4: Consultas SQL de negocio
-- Base: Ventas_Tech_DB (creada en el Módulo 3)
-- Se trabaja solo sobre la tabla ventas. El total de cada venta se
-- calcula como cantidad * precio_unitario.
-- =====================================================================
USE Ventas_Tech_DB;
GO

-- =====================================================================
-- Consulta 1 - Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes.
-- =====================================================================
SELECT
    YEAR(fecha_venta)                                  AS anio,
    MONTH(fecha_venta)                                 AS mes,
    SUM(cantidad * precio_unitario)                    AS total_facturado,
    COUNT(*)                                           AS cantidad_pedidos,
    CAST(SUM(cantidad * precio_unitario) / COUNT(*) AS DECIMAL(10,2)) AS ticket_promedio
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;
-- Se agrupa también por año para que, cuando la base tenga más de un año
-- de datos, marzo 2024 y marzo 2025 no se sumen en una misma fila.

-- =====================================================================
-- Consulta 2 - Ranking de productos (Top 5 por total facturado)
-- =====================================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad)                   AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- =====================================================================
-- Consulta 3 - Clientes recurrentes (más de un pedido)
-- =====================================================================
SELECT
    id_cliente,
    COUNT(*)                        AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- =====================================================================
-- Consulta 4 - Meses por encima / por debajo del promedio mensual
-- 1) La CTE calcula el total facturado de cada mes.
-- 2) La consulta final lo compara contra el promedio de esos totales.
-- =====================================================================
WITH ventas_mensuales AS (
    SELECT
        YEAR(fecha_venta)               AS anio,
        MONTH(fecha_venta)              AS mes,
        SUM(cantidad * precio_unitario) AS total_mes
    FROM ventas
    GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
)
SELECT
    anio,
    mes,
    total_mes,
    CAST(AVG(total_mes) OVER () AS DECIMAL(10,2)) AS promedio_mensual,
    CASE
        WHEN total_mes > AVG(total_mes) OVER () THEN 'Por encima'
        WHEN total_mes < AVG(total_mes) OVER () THEN 'Por debajo'
        ELSE 'En el promedio'
    END AS posicion_vs_promedio
FROM ventas_mensuales
ORDER BY anio, mes;
-- Nota: con los datos actuales todas las ventas son de marzo 2024, por lo
-- que el único mes coincide con el promedio y se etiqueta 'En el promedio'.
-- Se agregó esa tercera etiqueta para no marcar un mes como 'Por debajo'
-- cuando en realidad es igual al promedio. La consulta ya queda lista para
-- cuando se carguen más meses.

-- =====================================================================
-- BLOQUE DE CIERRE - Hallazgos
-- =====================================================================
-- Hallazgo 1: El producto 1 (Laptop Pro 15) concentra USD 3.600 de los
--   USD 6.444 facturados en marzo 2024, es decir el 55,9% del total con
--   solo 3 unidades. Junto con el producto 3 (Monitor 4K 27) suman el
--   76,8%: la facturación depende fuertemente de la categoría Computación.
-- Hallazgo 2: El producto 2 (Mouse Inalámbrico) es el de mayor volumen
--   (13 unidades, 44,8% de las 29 unidades vendidas) pero aporta solo
--   USD 364 (5,6% de la facturación). Volumen y facturación no van de la mano:
--   el ranking por unidades y el ranking por importe cuentan historias distintas.
-- Hallazgo 3: Los 5 clientes compraron exactamente 2 veces en el mes (100%
--   de recurrencia). Los clientes 1 y 5 explican USD 4.740 (73,6% del total)
--   porque sus pedidos incluyen laptops: el ticket promedio de USD 644,40
--   está empujado por pocas ventas de alto valor.
