CREATE DATABASE insumais;
USE insumais;

CREATE TABLE cliente(
	id INT PRIMARY KEY AUTO_INCREMENT,
    nmFantasia VARCHAR(255) NOT NULL,
    cnpj CHAR(14) UNIQUE NOT NULL,
    senha VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    
    CONSTRAINT chkEmail CHECK(email LIKE '%@%')
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
    
    CONSTRAINT chkOrientacao CHECK(orientacao IN('V','H')),
    
    -- Ligação com [outra tabela]
    colmo_id INT
);

CREATE TABLE canavial(
	ID INT PRIMARY KEY AUTO_INCREMENT,
  -- Ligação com [outra tabela]
    idDono INT,
    metaVol INT -- Toneladas
);

CREATE TABLE amostra(
	ID INT PRIMARY KEY AUTO_INCREMENT,
	idCanavial INT,
    idInsumo int,
    qtdInsumo INT, -- KG
    dtCicloInit DATE,
    dtColeta DATE DEFAULT NULL
);

CREATE TABLE colmo(
	ID INT PRIMARY KEY AUTO_INCREMENT,
    nomeColmo VARCHAR(32), -- serve para histórico Ex.:120BA
    idAmostra INT,
    altura INT, -- CM
    raio INT, -- CM
    dtPlantado DATETIME DEFAULT NULL -- Porque NULO: A data de registro não
									 -- necessariamente é a data de plantação 
);


-- Cliente
INSERT INTO cliente (nmFantasia, cnpj, senha, email) VALUES
('Usina Raizen Teste', '12345678000199', 'senha123', 'contato@raizen.com');

-- Insumo
INSERT INTO insumo (tipo, fabricante, custoPorTon) VALUES
('Fertilizante nitrogenado', 'Yara', 335.00),
('Herbicida', 'Ihara', 300.00);

-- Canavial
INSERT INTO canavial (idDono, metaVol) VALUES (1, 5000);

-- Amostra (2 coletas do mesmo canavial, insumos diferentes)
INSERT INTO amostra (idCanavial, idInsumo, qtdInsumo, dtCicloInit, dtColeta) VALUES
(1, 1, 50, '2026-01-01', '2026-02-01'),
(1, 2, 30, '2026-01-01', '2026-02-16');

-- Colmo (5 plantas físicas, cada uma medida nas 2 coletas = 10 linhas)
INSERT INTO colmo (nomeColmo, idAmostra, altura, raio, dtPlantado) VALUES
('120BA', 1, 45, 2, '2026-01-05'),
('121BA', 1, 47, 2, '2026-01-05'),
('122BA', 1, 44, 2, '2026-01-05'),
('123BA', 1, 46, 2, '2026-01-05'),
('124BA', 1, 45, 2, '2026-01-05'),
('120BA', 2, 68, 3, NULL),
('121BA', 2, 70, 3, NULL),
('122BA', 2, 66, 3, NULL),
('123BA', 2, 69, 3, NULL),
('124BA', 2, 67, 3, NULL);

-- Sensor (V + H por colmo físico, apontando pro primeiro registro de cada um)
INSERT INTO sensor (medicao, orientacao, dt_instalacao, ativo, colmo_id) VALUES
(45, 'V', '2026-01-05', 1, 1), (2, 'H', '2026-01-05', 1, 1),
(47, 'V', '2026-01-05', 1, 2), (2, 'H', '2026-01-05', 1, 2),
(44, 'V', '2026-01-05', 1, 3), (2, 'H', '2026-01-05', 1, 3),
(46, 'V', '2026-01-05', 1, 4), (2, 'H', '2026-01-05', 1, 4),
(45, 'V', '2026-01-05', 1, 5), (2, 'H', '2026-01-05', 1, 5);

-- 1. Sensores com orientação e status legíveis
SELECT id AS IdSensor,
       CASE orientacao WHEN 'V' THEN 'Vertical' WHEN 'H' THEN 'Horizontal' ELSE 'Não definida' END AS Orientacao,
       CASE ativo WHEN 1 THEN 'Ativo' ELSE 'Inativo' END AS Status,
       colmo_id AS Colmo
FROM sensor;

-- 2. Histórico de colmos, com data de plantio tratada quando ausente
SELECT nomeColmo AS Nome,
       altura AS AlturaCM,
       raio AS RaioCM,
       IFNULL(dtPlantado, 'Sem data nesta leitura') AS DataPlantio
FROM colmo
ORDER BY nomeColmo, ID;

-- 3. Amostras com insumo e status da coleta
SELECT a.ID AS Amostra,
       i.tipo AS Insumo,
       a.qtdInsumo AS QtdKg,
       a.dtCicloInit AS InicioCiclo,
       CASE WHEN ISNULL(a.dtColeta) THEN 'Coleta pendente' ELSE a.dtColeta END AS DataColeta
FROM amostra a
JOIN insumo i ON a.idInsumo = i.id;

-- 4. Comparativo de crescimento por colmo (primeira x segunda coleta)
SELECT c1.nomeColmo AS Colmo,
       c1.altura AS AlturaInicial,
       c2.altura AS AlturaFinal,
       CASE WHEN c2.altura > c1.altura THEN 'Cresceu' ELSE 'Sem crescimento' END AS Situacao
FROM colmo c1
JOIN colmo c2 ON c1.nomeColmo = c2.nomeColmo AND c1.idAmostra = 1 AND c2.idAmostra = 2;