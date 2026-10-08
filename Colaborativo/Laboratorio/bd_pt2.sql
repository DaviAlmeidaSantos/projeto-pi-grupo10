CREATE DATABASE insumais; 
USE insumais; 

-- Tabela Cliente: Empresa que compra a solução
CREATE TABLE cliente(
    id INT PRIMARY KEY AUTO_INCREMENT,
    nmFantasia VARCHAR(255) NOT NULL,
    cnpj CHAR(14) UNIQUE NOT NULL,
    senha VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    CONSTRAINT chkEmail CHECK(email LIKE '%@%')
);

-- Tabela Insumo: Produtos aplicados nas amostras
CREATE TABLE insumo(
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(100) NOT NULL,
    fabricante VARCHAR(255) NOT NULL,
    custoPorTon DECIMAL(10,2) NOT NULL
);

-- Tabela Canavial: Pertence a um cliente específico
CREATE TABLE canavial(
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_dono INT NOT NULL,
    metaVol INT NOT NULL,
    CONSTRAINT fk_canavial_cliente FOREIGN KEY (fk_dono) REFERENCES cliente(id) ON DELETE CASCADE
);

-- Tabela Amostra: Lotes de teste dentro de um canavial
CREATE TABLE amostra(
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_canavial INT NOT NULL,
    fk_insumo INT NOT NULL,
    dtCicloInit DATE NOT NULL,
    dtColeta DATE DEFAULT NULL,
    CONSTRAINT fk_amostra_canavial FOREIGN KEY (fk_canavial) REFERENCES canavial(id) ON DELETE CASCADE,
    CONSTRAINT fk_amostra_insumo FOREIGN KEY (fk_insumo) REFERENCES insumo(id)
);

-- Tabela Colmo: Plantas individuais monitoradas
CREATE TABLE colmo(
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_amostra INT NOT NULL,
    altura INT NOT NULL,
    raio INT NOT NULL,
    dtPlantado DATETIME DEFAULT NULL,
    dtUltimaLeitura DATETIME DEFAULT NOW(),
    CONSTRAINT fk_colmo_amostra FOREIGN KEY (fk_amostra) REFERENCES amostra(id) ON DELETE CASCADE
);

-- Tabela Sensor: Dispositivos IoT instalados nos colmos
CREATE TABLE sensor(
    id INT PRIMARY KEY AUTO_INCREMENT,
    medicao INT NOT NULL,
    orientacao CHAR(1) NOT NULL,
    dtInstalacao DATETIME DEFAULT NOW(),
    ativo TINYINT NOT NULL DEFAULT 1,
    fk_colmo INT NOT NULL,
    CONSTRAINT chkOrientacao CHECK(orientacao IN('V','H')),
    CONSTRAINT fk_sensor_colmo FOREIGN KEY (fk_colmo) REFERENCES colmo(id) ON DELETE CASCADE
);

-- Tabela Historico: Linha do tempo do crescimento do colmo
CREATE TABLE historico(
    idHist INT PRIMARY KEY AUTO_INCREMENT,
    fk_colmo INT NOT NULL,
    alturaPast INT NOT NULL,
    raioPast INT NOT NULL,
    dtReg DATETIME DEFAULT NOW(),
    CONSTRAINT fk_historico_colmo FOREIGN KEY (fk_colmo) REFERENCES colmo(id) ON DELETE CASCADE
);

-- Inserção de dados iniciais
INSERT INTO cliente (nmFantasia, cnpj, senha, email) 
VALUES ('Usina Raizen Teste', '12345678000199', 'senha123', 'contato@raizen.com');

INSERT INTO insumo (tipo, fabricante, custoPorTon) 
VALUES ('Fertilizante nitrogenado', 'Yara', 335.00), 
       ('Herbicida', 'Ihara', 300.00);

INSERT INTO canavial (fk_dono, metaVol) 
VALUES (1, 5000);

INSERT INTO amostra (fk_canavial, fk_insumo, dtCicloInit, dtColeta) 
VALUES (1, 1, '2026-01-01', NULL), 
       (1, 2, '2026-01-01', NULL);

INSERT INTO colmo (fk_amostra, altura, raio, dtPlantado) VALUES 
(1, 45, 2, '2026-01-05'), 
(1, 47, 2, '2026-01-05'), 
(1, 44, 2, '2026-01-05'), 
(1, 46, 2, '2026-01-05'), 
(1, 45, 2, '2026-01-05');

INSERT INTO sensor (medicao, orientacao, dtinstalacao, ativo, fk_colmo) VALUES 
(45, 'V', '2026-01-05', 1, 1), (2, 'H', '2026-01-05', 1, 1), 
(47, 'V', '2026-01-05', 1, 2), (2, 'H', '2026-01-05', 1, 2), 
(44, 'V', '2026-01-05', 1, 3), (2, 'H', '2026-01-05', 1, 3), 
(46, 'V', '2026-01-05', 1, 4), (2, 'H', '2026-01-05', 1, 4), 
(45, 'V', '2026-01-05', 1, 5), (2, 'H', '2026-01-05', 1, 5);

INSERT INTO historico (fk_colmo, alturaPast, raioPast, dtReg) VALUES 
(1, 45, 2, '2026-01-05'), 
(2, 47, 2, '2026-01-05'), 
(3, 44, 2, '2026-01-05'), 
(4, 46, 2, '2026-01-05'), 
(5, 45, 2, '2026-01-05');

-- Atualização simulando crescimento da planta
UPDATE colmo SET altura = 68, raio = 3, fk_amostra = 2 WHERE id = 1;
UPDATE colmo SET altura = 70, raio = 3, fk_amostra = 2 WHERE id = 2;
UPDATE colmo SET altura = 66, raio = 3, fk_amostra = 2 WHERE id = 3;
UPDATE colmo SET altura = 69, raio = 3, fk_amostra = 2 WHERE id = 4;
UPDATE colmo SET altura = 67, raio = 3, fk_amostra = 2 WHERE id = 5;

-- Consulta 1: Estado atual das plantas
SELECT 
    id AS 'Identificador do colmo', 
    altura AS 'Altura em CM', 
    raio AS 'Raio em CM', 
    dtPlantado AS 'Data de Plantio' 
FROM colmo 
ORDER BY id;

-- Consulta 2: Insumos aplicados e dados da colheita
SELECT 
    a.id AS 'Amostra', 
    i.tipo AS 'Insumo', 
    a.dtCicloInit AS 'Inicio do Ciclo', 
    a.dtColeta AS 'Data da Coleta' 
FROM amostra a
JOIN insumo i ON a.fk_insumo = i.id;

-- Consulta 3: Comparação de crescimento
SELECT 
    c.id AS 'Colmo', 
    h.alturaPast AS 'Altura Anterior', 
    c.altura AS 'Altura Atual'
FROM colmo c
	JOIN historico h 
		ON h.fk_colmo = c.id;

-- Consulta 4: Relatório geral do canavial
SELECT 
    cli.nmFantasia AS 'Cliente', 
    can.id AS 'Canavial', 
    can.metaVol AS 'Meta de Toneladas', 
    CONCAT(i.tipo, ' do ', i.fabricante) AS 'Info. do Insumo', 
    a.dtCicloInit AS 'Inicio do ciclo', 
    a.dtColeta AS 'Status de Coleta' 
FROM cliente cli
	JOIN canavial can 
		ON can.fk_dono = cli.id
	JOIN amostra a 
		ON a.fk_canavial = can.id
	JOIN insumo i 
		ON a.fk_insumo = i.id
ORDER BY cli.nmFantasia;
