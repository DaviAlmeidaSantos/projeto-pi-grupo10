CREATE DATABASE insumais;
USE insumais;

CREATE TABLE cliente(
	id INT PRIMARY KEY AUTO_INCREMENT,
    nmFantasia VARCHAR(255) NOT NULL,
    cnpj CHAR(14) UNIQUE NOT NULL,
    senha VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    
    CONSTRAINT chkEmail CHECK(email LIKE '%@%.com%')
);

CREATE TABLE insumo(
	id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(100),
    fabricante VARCHAR(255),
    custoPorTon DECIMAL(10,2)
);

CREATE TABLE sensor(
	id INT PRIMARY KEY AUTO_INCREMENT,
    medicao INT, -- 9999.99 cm = 99m MAX
    orientacao CHAR(1),
    dt_instalacao DATETIME DEFAULT NOW(),
    ativo TINYINT NOT NULL DEFAULT 1,
    idSensorV INT,
    idSensorH INT,
    
    CONSTRAINT chkOrientacao CHECK(orientacao IN('V','H')),
    
    -- Ligação com [outra tabela]
    cana_id INT
);

CREATE TABLE colmo(
	ID INT PRIMARY KEY AUTO_INCREMENT,
    idAmostra INT,
    altura INT, -- CM
    raio INT, -- CM
    dtPlantado DATETIME DEFAULT NULL -- Porque NULO: A data de registro não 
									 -- necessariamente é a data de plantação 
);

CREATE TABLE amostra(
	ID INT PRIMARY KEY AUTO_INCREMENT,
	idCanavial INT,
    nmInsumo VARCHAR(100),
    qtdInsumo INT, -- KG
    dtCicloInit DATE, 
    dtColeta DATE DEFAULT NULL
);

CREATE TABLE canavial(
	ID INT PRIMARY KEY AUTO_INCREMENT,
    emailDono INT,
    metaVol INT -- Toneladas
);






	
