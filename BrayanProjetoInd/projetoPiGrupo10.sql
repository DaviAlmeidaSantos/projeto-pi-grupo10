CREATE DATABASE insumais;
USE insumais;

-- CONSTANTES:
-- densidade da cana
-- distância vertical máxima do sensor
-- distância horizontal máxima do sensor

CREATE TABLE cliente(
	id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    senha VARCHAR(30) NOT NULL
);

CREATE TABLE canavial(
	id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- Ligação com cliente
    cliente_nome INT
);

CREATE TABLE insumo(
	id INT PRIMARY KEY AUTO_INCREMENT,
	tipo VARCHAR(100),
    preco_ton DECIMAL(10,2),
    fabricante VARCHAR(100)
);
    
CREATE TABLE amostra(
	id INT PRIMARY KEY AUTO_INCREMENT,
    insumo_qtd DECIMAL(6,2),
    dt_plantacao DATETIME,
    
    -- Ligação com canavial
    canavial_id VARCHAR(200),
    
    -- Ligação com insumo
    insumo_tipo VARCHAR(100)
);

CREATE TABLE cana(
	id INT PRIMARY KEY AUTO_INCREMENT,
	altura DECIMAL(6,2),
    raio DECIMAL(5,2),
    
    -- Ligação com amostra
    amostra_insumo_tipo VARCHAR(100),
    amostra_insumo_qtd DECIMAL(6,2)
);

CREATE TABLE sensor(
	id INT PRIMARY KEY AUTO_INCREMENT,
	cana_id INT,
    orientacao CHAR(1),
    captura DECIMAL(6,2),
    CONSTRAINT chkOrientacao CHECK(orientacao IN('V', 'H')),
    
    -- Ligação com cana
    cana_id INT
);