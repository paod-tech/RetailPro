RetailPro – Proyecto integrador de Data Analytics
Sistema de análisis de ventas para RetailPro, una distribuidora de tecnología (caso de estudio del curso de Data Analytics). El proyecto recorre el flujo completo de un analista: definición del problema de negocio, modelado relacional, base de datos en SQL Server, consultas de negocio, ETL en Power Query, modelo en estrella con DAX y dashboard ejecutivo en Power BI.
Pregunta de negocio: ¿por qué cayó la facturación en el último trimestre y qué categorías, regiones y canales explican esa caída?
Herramientas
Herramienta	Uso en el proyecto
SQL Server + SSMS	Base `Ventas_Tech_DB` y consultas (módulos 3, 4, 5 y 10)
Power BI Desktop / Power Query (M)	Pipeline ETL, modelo de datos y medidas DAX (módulos 6 y 8)
Power BI Service	Publicación y dashboard (módulos 10 y 11)
Claude (IA)	Revisión de SQL, borrador de este README e insights, siempre validados manualmente
Estructura del repositorio
```
RetailPro/
├── sql/
│   ├── ventas_tech_db.sql          # M3: crea la base (DROP, CREATE, INSERT y validación)
│   ├── m4_consultas_negocio.sql    # M4: resumen mensual, ranking, clientes recurrentes
│   └── m5_consultas_joins.sql      # M5: vista base con JOINs, LEFT JOIN y UNION ALL
└── README.md
```
Los archivos `.pbix` de Power BI no se suben al repositorio por su tamaño: se comparten por link en los PDF de entrega de los módulos 6 y 8.
Cómo ejecutar los scripts
Requisito: SQL Server 2016 o superior (los scripts usan `DROP TABLE IF EXISTS`).
Abrir SSMS y conectarse a la instancia local.
Ejecutar primero `sql/ventas_tech_db.sql`. Crea la base `Ventas_Tech_DB` si no existe y carga 25 registros. Es repetible: se puede correr varias veces.
Verificar que las consultas de validación del final devuelvan 4, 5, 6 y 10 filas.
Recién después ejecutar `m4_consultas_negocio.sql` y `m5_consultas_joins.sql`, que consultan esa base.
Modelo de datos
```
categorias (1) ── (N) productos (1) ── (N) ventas (N) ── (1) clientes
```
`ventas` es la tabla de hechos; `categorias`, `productos` y `clientes` son dimensiones. El total de cada venta se calcula como `cantidad * precio_unitario`.
Limitaciones de los datos
La base de referencia tiene 10 ventas de un solo mes (marzo 2024). Sirve para validar la lógica de las consultas, pero no alcanza para sacar conclusiones de tendencia.
Las consultas de clientes y productos sin ventas (M5) devuelven 0 filas con estos datos; su lógica se valida con una prueba dentro de una transacción que se revierte (`ROLLBACK`).
Uso de IA
Usé IA como asistente para revisar consultas SQL, generar el borrador de este README y proponer hallazgos. Todas las cifras fueron verificadas contra los resultados reales de las consultas y las sugerencias se aceptaron o rechazaron con criterio propio (ver documento de la pre-entrega del Módulo 9).
Autora
Paola – Curso de Data Analytics, 2026.# RetailPro
RetailPro
