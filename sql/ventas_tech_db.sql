-- Motor utilizado: SQL Server (SSMS)
-- =====================================================================
-- Proyecto RetailPro / TechStore - Checkpoint Módulo 3
-- Script de ingeniería de datos: base Ventas_Tech_DB
-- Modelo: categorias (1) -- (N) productos (1) -- (N) ventas (N) -- (1) clientes
-- El script es repetible: se puede ejecutar varias veces sin errores.
-- =====================================================================

-- Creación y selección de la base (solo la crea si no existe)
IF DB_ID('Ventas_Tech_DB') IS NULL
    CREATE DATABASE Ventas_Tech_DB;
GO
USE Ventas_Tech_DB;
GO

-- =====================================================================
-- === SECCIÓN 1: DROP ===
-- Orden inverso a las dependencias: primero la tabla de hechos (ventas),
-- después productos (depende de categorias) y al final las dimensiones base.
-- =====================================================================
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;
GO

-- =====================================================================
-- === SECCIÓN 2: CREATE ===
-- Primero las tablas que no dependen de nadie, al final la tabla de hechos.
-- Importes en DECIMAL(10,2): nunca FLOAT, para evitar errores de redondeo.
-- =====================================================================

-- Dimensión: categorías de producto (tabla propia para cumplir 3NF)
CREATE TABLE categorias (
    id_categoria      INT           NOT NULL,
    nombre_categoria  VARCHAR(50)   NOT NULL,
    descripcion       VARCHAR(200)  NULL,
    CONSTRAINT pk_categorias PRIMARY KEY (id_categoria)
);

-- Dimensión: clientes
CREATE TABLE clientes (
    id_cliente      INT           NOT NULL,
    nombre          VARCHAR(100)  NOT NULL,
    email           VARCHAR(100)  NULL,
    ciudad          VARCHAR(50)   NULL,
    fecha_registro  DATE          NOT NULL,
    CONSTRAINT pk_clientes PRIMARY KEY (id_cliente),
    CONSTRAINT uq_clientes_email UNIQUE (email)
);

-- Dimensión: productos (referencia a categorias)
CREATE TABLE productos (
    id_producto      INT            NOT NULL,
    nombre_producto  VARCHAR(100)   NOT NULL,
    id_categoria     INT            NULL,
    precio           DECIMAL(10,2)  NOT NULL,
    stock            INT            NULL CONSTRAINT df_productos_stock  DEFAULT 0,
    activo           BIT            NULL CONSTRAINT df_productos_activo DEFAULT 1,
    CONSTRAINT pk_productos PRIMARY KEY (id_producto),
    CONSTRAINT fk_productos_categorias FOREIGN KEY (id_categoria)
        REFERENCES categorias (id_categoria)
);

-- Hechos: ventas (referencia a clientes y productos)
CREATE TABLE ventas (
    id_venta         INT            NOT NULL,
    id_cliente       INT            NULL,
    id_producto      INT            NULL,
    cantidad         INT            NOT NULL,
    precio_unitario  DECIMAL(10,2)  NOT NULL,
    fecha_venta      DATE           NOT NULL,
    CONSTRAINT pk_ventas PRIMARY KEY (id_venta),
    CONSTRAINT fk_ventas_clientes FOREIGN KEY (id_cliente)
        REFERENCES clientes (id_cliente),
    CONSTRAINT fk_ventas_productos FOREIGN KEY (id_producto)
        REFERENCES productos (id_producto)
);
GO

-- =====================================================================
-- === SECCIÓN 3: INSERT ===
-- 25 registros en total. Orden lógico: categorias y clientes antes que
-- productos y ventas, para que las foreign keys encuentren a qué apuntar.
-- =====================================================================

-- categorias: 4 registros
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
    (1, 'Computación',    'Laptops, PCs y monitores'),
    (2, 'Accesorios',     'Periféricos y complementos'),
    (3, 'Audio',          'Auriculares y parlantes'),
    (4, 'Almacenamiento', 'Discos y memorias');

-- clientes: 5 registros
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
    (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
    (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
    (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
    (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
    (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');

-- productos: 6 registros
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
    (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
    (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
    (3, 'Monitor 4K 27',      1,  450.00, 12, 1),
    (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
    (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
    (6, 'Teclado Mecánico',   2,   95.00, 40, 1);

-- ventas: 10 registros
INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    ( 1, 1, 1, 2, 1200.00, '2024-03-05'),
    ( 2, 2, 2, 5,   28.00, '2024-03-06'),
    ( 3, 3, 3, 1,  450.00, '2024-03-07'),
    ( 4, 1, 4, 2,  120.00, '2024-03-08'),
    ( 5, 4, 5, 3,  130.00, '2024-03-10'),
    ( 6, 2, 6, 4,   95.00, '2024-03-11'),
    ( 7, 5, 1, 1, 1200.00, '2024-03-12'),
    ( 8, 3, 2, 8,   28.00, '2024-03-13'),
    ( 9, 4, 4, 1,  120.00, '2024-03-14'),
    (10, 5, 3, 2,  450.00, '2024-03-15');
GO

-- =====================================================================
-- === SECCIÓN 4: VALIDACIÓN ===
-- Resultado esperado: 4, 5, 6 y 10 filas respectivamente.
-- =====================================================================
SELECT * FROM categorias;   -- esperado: 4 filas
SELECT * FROM clientes;     -- esperado: 5 filas
SELECT * FROM productos;    -- esperado: 6 filas
SELECT * FROM ventas;       -- esperado: 10 filas
