CREATE DATABASE insumais;
USE insumais;

CREATE TABLE cliente(
	id INT PRIMARY KEY AUTO_INCREMENT,
    nmFantasia VARCHAR(255) NOT NULL,
    cnpj CHAR(14) UNIQUE NOT NULL,
    senha VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    CONSTRAINT chkEmail CHECK(email LIKE '%@%')
); -- Okay

CREATE TABLE insumo(
	id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(100),
    fabricante VARCHAR(255),
    custoPorTon DECIMAL(10,2)
); -- Okay

CREATE TABLE sensor(
	id INT PRIMARY KEY AUTO_INCREMENT,
    medicao INT, 
    orientacao CHAR(1),
    dt_instalacao DATETIME DEFAULT NOW(),
    ativo TINYINT NOT NULL DEFAULT 1,
    colmo_id INT, -- Ligação com [outra tabela]
    CONSTRAINT chkOrientacao CHECK(orientacao IN('V','H'))
); -- Okay, adendo: Medição -> 9999.99 cm = 99m MAX

CREATE TABLE canavial(
	ID INT PRIMARY KEY AUTO_INCREMENT,
    idDono INT,   -- Ligação com [outra tabela]
    metaVol INT -- Toneladas
); -- Okay

CREATE TABLE amostra(
	ID INT PRIMARY KEY AUTO_INCREMENT,
	idCanavial INT,
    idInsumo int,
    qtdInsumo INT, -- KG
    dtCicloInit DATE,
    dtColeta DATE DEFAULT NULL
); -- Aguarda revisão.

CREATE TABLE colmo(
	ID INT PRIMARY KEY AUTO_INCREMENT,
    nomeColmo VARCHAR(32), -- serve para histórico Ex.:120BA
    idAmostra INT,
    altura INT, -- em CM
    raio INT, -- em CM
    dtPlantado DATETIME DEFAULT NULL
); -- Aguarda revisão, dtPlantado talvez seja desnecessário. Alocar dtReg para transformar a tabela em um histórico.

/*
	Inserção de dados
*/
INSERT INTO cliente (nmFantasia, cnpj, senha, email) VALUES
('Usina Raizen Teste', '12345678000199', 'senha123', 'contato@raizen.com');

INSERT INTO insumo (tipo, fabricante, custoPorTon) VALUES
('Fertilizante nitrogenado', 'Yara', 335.00),
('Herbicida', 'Ihara', 300.00);

INSERT INTO canavial (idDono, metaVol) VALUES (1, 5000);

INSERT INTO amostra (idCanavial, idInsumo, qtdInsumo, dtCicloInit, dtColeta) VALUES
(1, 1, 50, '2026-01-01', NULL),
(1, 2, 30, '2026-01-01', NULL);

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

INSERT INTO sensor (medicao, orientacao, dt_instalacao, ativo, colmo_id) VALUES
(45, 'V', '2026-01-05', 1, 1), (2, 'H', '2026-01-05', 1, 1),
(47, 'V', '2026-01-05', 1, 2), (2, 'H', '2026-01-05', 1, 2),
(44, 'V', '2026-01-05', 1, 3), (2, 'H', '2026-01-05', 1, 3),
(46, 'V', '2026-01-05', 1, 4), (2, 'H', '2026-01-05', 1, 4),
(45, 'V', '2026-01-05', 1, 5), (2, 'H', '2026-01-05', 1, 5);

/*
	Selects de demonstração.
*/

-- Mostra os sensores, suas orientações e se está ativo ou inativo
SELECT id AS IdSensor,
       CASE orientacao WHEN 'V' THEN 'Vertical' WHEN 'H' THEN 'Horizontal' ELSE 'Não definida' END AS Orientacao,
       CASE ativo WHEN 1 THEN 'Ativo' ELSE 'Inativo' END AS Status,
       colmo_id AS Colmo
FROM sensor;

-- Mostra os colmos, aqui o dtPlantado para de fazer sentido
SELECT nomeColmo AS Nome,
       altura AS AlturaCM,
       raio AS RaioCM,
       IFNULL(dtPlantado, 'Sem data nesta leitura') AS DataPlantio
FROM colmo
ORDER BY nomeColmo, ID;

-- Grupo de amostra, insumo utilizado, inicio do ciclo e termino dele
SELECT a.ID AS Amostra,
       i.tipo AS Insumo,
       a.qtdInsumo AS QtdKg,
       a.dtCicloInit AS InicioCiclo,
       CASE WHEN ISNULL(a.dtColeta) THEN 'Coleta pendente' ELSE a.dtColeta END AS DataColeta
FROM amostra a
JOIN insumo i ON a.idInsumo = i.id;

-- Colmos e comparativa de crescimento. Tecnicamente não usa fk
SELECT c1.nomeColmo AS Colmo,
       c1.altura AS AlturaInicial,
       c2.altura AS AlturaFinal,
       CASE WHEN c2.altura > c1.altura THEN 'Cresceu' ELSE 'Sem crescimento' END AS Situacao
FROM colmo c1
JOIN colmo c2 ON c1.nomeColmo = c2.nomeColmo AND c1.idAmostra = 1 AND c2.idAmostra = 2;