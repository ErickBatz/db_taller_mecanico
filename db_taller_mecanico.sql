CREATE DATABASE if NOT EXISTS db_inventario_taller;
USE db_inventario_taller;

CREATE TABLE clientes(
	id_cliente INT PRIMARY KEY NOT NULL,
	nombre VARCHAR(60) NOT NULL ,
	nit VARCHAR(20),
	correo_electronico VARCHAR(255) NULL,
	direccion VARCHAR(200) NULL,
	telefono VARCHAR(10) NOT NULL 
);

CREATE TABLE vehiculo(
	id_vehiculo INT PRIMARY KEY NOT NULL,
	id_cliente INT,
	color VARCHAR(20) NOT NULL,
	marca VARCHAR(30) NOT NULL,
	anio YEAR NOT NULL,
	modelo VARCHAR(40) NOT NULL,
	placas VARCHAR(20) NOT NULL,
	
	CONSTRAINT fk_vehiculo_cliente FOREIGN KEY (id_cliente)
	REFERENCES clientes(id_cliente)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);

CREATE TABLE ordenes_trabajo(
	id_orden_trabajo INT PRIMARY KEY,
	id_vehiculo INT NOT NULL ,
	id_cliente INT NOT NULL ,
	fecha_ingreso DATE NOT NULL,
	fecha_salida DATE NOT NULL,
	kilomatraje INT UNSIGNED NOT NULL DEFAULT 0,
	diagnostico VARCHAR(255),
	observaciones VARCHAR(255),
	estado VARCHAR(20) NOT NULL,
	
	CONSTRAINT fk_orden_vehiculo FOREIGN KEY(id_vehiculo)
	REFERENCES vehiculo(id_vehiculo)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	CONSTRAINT fk_orden_cliente FOREIGN KEY(id_cliente)
	REFERENCES clientes(id_cliente)
	ON UPDATE CASCADE
	ON DELETE CASCADE 
);

CREATE TABLE proveedores(
	id_proveedor INT PRIMARY KEY,
	nombre VARCHAR(60) NOT NULL,
	nit VARCHAR(20) NOT NULL,
	telefono VARCHAR(20) NOT NULL,
	correo VARCHAR(255) NOT NULL,
	direccion VARCHAR(255) NOT NULL,
	estado VARCHAR(20) NOT NULL
);

CREATE TABLE categoria(
	id_categoria INT PRIMARY KEY,
	nombre VARCHAR(60) NOT NULL,
	descripcion TEXT NOT NULL,
	estado VARCHAR(20) NOT NULL
);

CREATE TABLE roles(
	id_roles INT PRIMARY KEY,
	nombre_rol VARCHAR(60) NOT NULL
);

CREATE TABLE usuarios(
	id_usuario INT PRIMARY KEY,
	id_roles INT NOT NULL,
	nombre VARCHAR(60) NOT NULL,
	correo VARCHAR(255) NOT NULL,
	contrasenia_hash VARCHAR(255) NOT NULL,
	estado VARCHAR(20) NOT NULL,
	
	CONSTRAINT fk_usuario_rol FOREIGN KEY(id_roles)
	REFERENCES roles(id_roles) 
	ON UPDATE CASCADE
	ON DELETE CASCADE	
);

CREATE TABLE repuestos(
	id_repuesto INT PRIMARY KEY,
	id_categoria INT NOT NULL,
	codigo_barras VARCHAR(50) UNIQUE,
	nombre VARCHAR(60) NOT NULL,
	precio_costo DECIMAL(10,2) NOT NULL,
	precio_venta DECIMAL(10,2) NOT NULL,
	stock_actual INT NOT NULL,
	stock_minimo INT NOT NULL,
	estado VARCHAR(20) NOT NULL,
	
	CONSTRAINT fk_repuestos_categoria FOREIGN KEY(id_categoria)
	REFERENCES categoria(id_categoria)
	ON UPDATE CASCADE
	ON DELETE CASCADE
	
);

CREATE TABLE movimiento_inventario(
	id_movimiento INT PRIMARY KEY,
	id_repuesto INT NOT NULL,
	id_usuario INT NOT NULL,
	tipo_movimiento VARCHAR(60) NOT NULL,
	cantidad INT NOT NULL,
	costo_unitario DECIMAL(10,2) NOT NULL,
	fecha DATE NOT NULL,
	referencia VARCHAR(50) NOT NULL,
	observaciones TEXT,
	
	CONSTRAINT fk_movimiento_respuesto FOREIGN KEY(id_repuesto)
	REFERENCES repuestos(id_repuesto)
	ON DELETE CASCADE 
	ON UPDATE CASCADE,
	
	CONSTRAINT fk_movimineto_usuario FOREIGN KEY(id_usuario)
	REFERENCES usuarios(id_usuario)
	ON DELETE CASCADE
	ON UPDATE CASCADE 
);

CREATE TABLE entradas_inventario(
	id_entrada INT PRIMARY KEY,
	id_proveedor INT NOT NULL,
	fecha_entrada DATE NOT NULL,
	numero_documento VARCHAR(20) NOT NULL,
	observaciones TEXT,
	
	CONSTRAINT fk_entradas_proveedores FOREIGN KEY(id_proveedor)
	REFERENCES proveedores(id_proveedor)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);



CREATE TABLE detalle_entrada_inventario(
	id_detalle_entrada INT PRIMARY KEY,
	id_entrada INT NOT NULL,
	id_repuesto INT NOT NULL,
	cantidad INT NOT NULL,
	costo_unitario DECIMAL(10,2) NOT NULL,
	
	CONSTRAINT fk_detalleEntrada_entrada FOREIGN KEY(id_entrada)
	REFERENCES entradas_inventario(id_entrada)
	ON UPDATE CASCADE 
	ON DELETE CASCADE,
	
	CONSTRAINT fk_detalleEntrada_repuesto FOREIGN KEY(id_repuesto)
	REFERENCES repuestos(id_repuesto)
	ON UPDATE CASCADE 
	ON DELETE CASCADE	
);

CREATE TABLE detalle_repuesto_ot(
	id_detalle_ot INT PRIMARY KEY,
	id_orden_trabajo INT NOT NULL,
	id_repuesto INT,
	cantidad INT NOT NULL,
	precio_unitario DECIMAL(10,2) NOT NULL,
	
	CONSTRAINT fk_detalleRepuesto_orden FOREIGN KEY(id_orden_trabajo)
	REFERENCES ordenes_trabajo(id_orden_trabajo)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	CONSTRAINT fk_detalleRepuesto_repuesto FOREIGN KEY(id_repuesto)
	REFERENCES repuestos(id_repuesto)
	ON UPDATE CASCADE 
	ON DELETE CASCADE
);

CREATE TABLE detalle_trabajo_realizado(
	id_detalleTrabajo INT PRIMARY KEY,
	id_orden_trabajo INT NOT NULL,
	descripcion TEXT,
	precio DECIMAL(10,2) NOT NULL,
	id_usuario INT NOT NULL,
	
	CONSTRAINT fk_detalleTrabajo_orden FOREIGN KEY(id_orden_trabajo)
	REFERENCES ordenes_trabajo(id_orden_trabajo)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	CONSTRAINT fk_detalleTrabajo_usuario FOREIGN KEY(id_usuario)
	REFERENCES usuarios(id_usuario)
	ON UPDATE CASCADE 
	ON DELETE CASCADE
);

CREATE TABLE venta(
	id_venta INT PRIMARY KEY,
	id_orden_trabajo INT, 
	id_cliente INT NOT NULL,
	id_usuario INT NOT NULL,
	fecha_venta DATE NOT NULL,
	subTotal DECIMAL(10,2) NOT NULL,
	descuento DECIMAL(10,2) NOT NULL,
	impuesto DECIMAL(10,2), 
	total DECIMAL(10,2) NOT NULL,
	estado VARCHAR(20) NOT NULL,
	
	CONSTRAINT fk_venta_id_orden FOREIGN KEY(id_orden_trabajo)
		REFERENCES ordenes_trabajo(id_orden_trabajo)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	
	CONSTRAINT fk_venta_id_cliente FOREIGN KEY(id_cliente)
		REFERENCES clientes(id_cliente)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	
	CONSTRAINT fk_venta_id_usuario FOREIGN KEY(id_usuario)
		REFERENCES usuarios(id_usuario)
		ON UPDATE CASCADE 
		ON DELETE CASCADE
);

CREATE TABLE facturas_fel(
	id_factura INT PRIMARY KEY,
	id_venta INT NOT NULL,
	seriea VARCHAR(20) NOT NULL,
	numero VARCHAR(10) NOT NULL,
	estado VARCHAR(20) NOT NULL,
	
	CONSTRAINT fk_facturas_venta FOREIGN KEY(id_venta)
	REFERENCES venta(id_venta)
	ON UPDATE CASCADE 
	ON DELETE CASCADE
);

CREATE TABLE detalle_venta(
	id_detalle INT PRIMARY KEY,
	id_venta INT NOT NULL,
	id_repuesto INT NOT NULL,
	tipo VARCHAR(20) NOT NULL,
	descripcion TEXT NULL,
	cantidad INT UNSIGNED,
	precio_unitario DECIMAL(10,2) NOT NULL, 
	subTotal DECIMAL(10,2) NOT NULL,
	
	CONSTRAINT fk_detalleVenta_idVenta FOREIGN KEY(id_venta)
	REFERENCES venta(id_venta)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	CONSTRAINT fk_detalleVenta__idRepuesto FOREIGN KEY(id_repuesto)
	REFERENCES repuestos(id_repuesto)
	ON UPDATE CASCADE 
	ON DELETE CASCADE

);









