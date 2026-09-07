USE sprint1;

-- DADOS PRIMÁRIOS

CREATE TABLE cliente (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cnpj CHAR(14) UNIQUE NOT NULL,
    senha VARCHAR(300) NOT NULL
);

CREATE TABLE insumo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(50) NOT NULL,
    preco_ton DECIMAL(10, 2),
    fabricante VARCHAR(100)
);

CREATE TABLE cana (
    id INT PRIMARY KEY AUTO_INCREMENT,
    densidade DECIMAL(5, 2),
    dt_plantacao DATE,
    insumo_tipo VARCHAR(50),
    insumo_qtd DECIMAL(10, 2),
    max_vert DECIMAL(5, 2),
    max_hori DECIMAL(5, 2)
);

CREATE TABLE sensor (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_cana INT,
    orientacao VARCHAR(20),
    captura DATETIME,
    CONSTRAINT fk_sensor_cana FOREIGN KEY (id_cana) REFERENCES cana(id)
);

-- COM TABELA AMOSTRA

CREATE TABLE cliente_v2 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cnpj CHAR(14) UNIQUE NOT NULL,
    senha VARCHAR(300) NOT NULL
);

CREATE TABLE insumo_v2 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(50) NOT NULL,
    fabricante VARCHAR(100)
);

CREATE TABLE amostra (
    id INT PRIMARY KEY AUTO_INCREMENT,
    insumo_tipo VARCHAR(50),
    insumo_qtd DECIMAL(10, 2),
    dt_plantacao DATE
);

CREATE TABLE canavial (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    amostra_id INT,
    CONSTRAINT fk_canavial_cliente FOREIGN KEY (cliente_id) REFERENCES cliente_v2(id),
    CONSTRAINT fk_canavial_amostra FOREIGN KEY (amostra_id) REFERENCES amostra(id)
);

CREATE TABLE cana_v2 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    amostra_id INT,
    altura DECIMAL(5, 2),
    raio DECIMAL(5, 2),
    CONSTRAINT fk_cana_amostra FOREIGN KEY (amostra_id) REFERENCES amostra(id)
);

CREATE TABLE sensor_v2 (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_cana INT,
    captura DATETIME,
    orientacao VARCHAR(20),
    CONSTRAINT fk_sensor_cana_v2 FOREIGN KEY (id_cana) REFERENCES cana_v2(id)
);