CREATE DATABASE insumais;
USE insumais;

-- Tabela para armazenar dados do cliente que comprará a nossa solução
CREATE TABLE cliente(
    id INT PRIMARY KEY AUTO_INCREMENT,
    razaoSocial VARCHAR(100) NOT NULL UNIQUE,
    nmFantasia VARCHAR(255),
    cnpj CHAR(14) UNIQUE NOT NULL,
    senha VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    CONSTRAINT chkEmail CHECK(email LIKE '%@%') -- Confirma se o campo email recebeu um registro válido
);

-- Tabela para armazenar informações relacionadas ao insumo
CREATE TABLE insumo(
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(100) NOT NULL,
    fabricante VARCHAR(255) NOT NULL,
    custoPorTon DECIMAL(10,2) NOT NULL -- Custo por tonelada
);

-- Guarda dados do canavial inteiro, como quem é o dono e qual a meta de volume
CREATE TABLE canavial(
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_dono INT NOT NULL, -- Ligação com [cliente]
    metaVol INT NOT NULL, -- Toneladas
    CONSTRAINT fk_canavial_cliente FOREIGN KEY (fk_dono) REFERENCES cliente(id)
);

-- Guarda dados de grupos de colmos dentro de um canavial, diz qual insumo está sendo utilizado e quando o grupo foi plantado
CREATE TABLE amostra(
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_canavial INT NOT NULL, -- Ligação com [canavial]
    fk_insumo INT NOT NULL, -- Ligação com [insumo]
    dtCicloInit DATE NOT NULL,
    dtColeta DATE DEFAULT NULL,
    CONSTRAINT fk_amostra_canavial FOREIGN KEY (fk_canavial) REFERENCES canavial(id),
    CONSTRAINT fk_amostra_insumo FOREIGN KEY (fk_insumo) REFERENCES insumo(id)
);

-- Tabela para o colmo (cana) individual, altura e raio são dados em constante atualização conforme o crescimento do colmo
CREATE TABLE colmo(
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_amostra INT NOT NULL, -- Qual grupo ele pertence (ligação com [amostra])
    altura INT NOT NULL, -- em CM
    raio INT NOT NULL, -- em CM
    dtPlantado DATETIME DEFAULT NULL,
    dtUltimaLeitura DATETIME DEFAULT NOW(),
    CONSTRAINT fk_colmo_amostra FOREIGN KEY (fk_amostra) REFERENCES amostra(id)
);

-- Tabela feita para guardar o status do sensor
CREATE TABLE sensor(
    id INT PRIMARY KEY AUTO_INCREMENT,
    medicao INT NOT NULL, -- tamanho máximo calculável pelo sensor (em cm)
    orientacao CHAR(1) NOT NULL, -- V = vertical (altura) | H = horizontal (raio)
    dtInstalacao DATETIME DEFAULT NOW(),
    ativo TINYINT NOT NULL DEFAULT 1,
    fk_colmo INT NOT NULL, -- Ligação com [colmo]
    CONSTRAINT chkOrientacao CHECK(orientacao IN('V','H')),
    CONSTRAINT fk_sensor_colmo FOREIGN KEY (fk_colmo) REFERENCES colmo(id)
); -- Adendo: Medição -> 9999.99 cm = 99m MAX

-- Guarda os valores passados do colmo, armazenando os valores anteriores para pesquisa
CREATE TABLE historico(
    idHist INT PRIMARY KEY AUTO_INCREMENT,
    fk_colmo INT NOT NULL, -- Ligação com [colmo]
    alturaPast INT NOT NULL, -- em CM
    raioPast INT NOT NULL, -- em CM
    dtReg DATETIME DEFAULT NOW(), -- Data do registro
    CONSTRAINT fk_historico_colmo FOREIGN KEY (fk_colmo) REFERENCES colmo(id)
);

/*
    Inserção de dados arbitrários
*/

INSERT INTO cliente (razaoSocial, nmFantasia, cnpj, senha, email) VALUES
('Usina Raizen Teste', NULL, '12345678000199', 'senha123', 'contato@raizen.com');

INSERT INTO insumo (tipo, fabricante, custoPorTon) VALUES
('Fertilizante nitrogenado', 'Yara', 335.00),
('Herbicida', 'Ihara', 300.00);

INSERT INTO canavial (fk_dono, metaVol) VALUES (1, 5000);

INSERT INTO amostra (fk_canavial, fk_insumo, dtCicloInit, dtColeta) VALUES
(1, 1, '2026-01-01', NULL),
(1, 2, '2026-01-01', NULL);

INSERT INTO colmo (fk_amostra, altura, raio, dtPlantado) VALUES
(1, 45, 2, '2026-01-05'),
(1, 47, 2, '2026-01-05'),
(1, 44, 2, '2026-01-05'),
(1, 46, 2, '2026-01-05'),
(1, 45, 2, '2026-01-05');

INSERT INTO sensor (medicao, orientacao, dtInstalacao, ativo, fk_colmo) VALUES
(45, 'V', '2026-01-05', 1, 1), (2, 'H', '2026-01-05', 1, 1),
(47, 'V', '2026-01-05', 1, 2), (2, 'H', '2026-01-05', 1, 2),
(44, 'V', '2026-01-05', 1, 3), (2, 'H', '2026-01-05', 1, 3),
(46, 'V', '2026-01-05', 1, 4), (2, 'H', '2026-01-05', 1, 4),
(45, 'V', '2026-01-05', 1, 5), (2, 'H', '2026-01-05', 1, 5);

/*
    Funcionamento abstraído do historico;
    Valor atualmente em colmo é colocado na tabela historico
    Tabela colmo atualiza com os valores atuais
*/

INSERT INTO historico (fk_colmo, alturaPast, raioPast, dtReg) VALUES
(1, 45, 2, '2026-01-05'),
(2, 47, 2, '2026-01-05'),
(3, 44, 2, '2026-01-05'),
(4, 46, 2, '2026-01-05'),
(5, 45, 2, '2026-01-05');

-- Atualização simulando crescimento da planta (os colmos também passam para a amostra 2)
UPDATE colmo SET altura = 68, raio = 3, fk_amostra = 2 WHERE id = 1; -- era 45,2
UPDATE colmo SET altura = 70, raio = 3, fk_amostra = 2 WHERE id = 2; -- era 47,2
UPDATE colmo SET altura = 66, raio = 3, fk_amostra = 2 WHERE id = 3; -- era 44,2
UPDATE colmo SET altura = 69, raio = 3, fk_amostra = 2 WHERE id = 4; -- era 46,2
UPDATE colmo SET altura = 67, raio = 3, fk_amostra = 2 WHERE id = 5; -- era 45,2

/*
    Selects de demonstração.
*/

-- Consulta 1: Como estão minhas plantas hoje?
SELECT
    id AS 'Identificador do colmo',
    altura AS 'Altura em CM',
    raio AS 'Raio em CM',
    IFNULL(dtPlantado, 'Sem data de plantio') AS 'Data de Plantio'
FROM colmo
ORDER BY id;

-- Consulta 2: O que eu apliquei em cada área, já foi colhido?
SELECT
    a.id AS 'Amostra',
    i.tipo AS 'Insumo',
    a.dtCicloInit AS 'Inicio do Ciclo',
    CASE WHEN a.dtColeta IS NULL THEN 'Coleta pendente' ELSE a.dtColeta END AS 'Data da Coleta'
FROM amostra a
    JOIN insumo i
        ON a.fk_insumo = i.id;

-- Consulta 3: Minha cana cresceu?
SELECT
    c.id AS 'Colmo',
    h.alturaPast AS 'Altura Anterior',
    c.altura AS 'Altura Atual',
    CASE WHEN c.altura > h.alturaPast THEN 'Cresceu' ELSE 'Sem crescimento' END AS 'Situação de crescimento'
FROM colmo c
    JOIN historico h
        ON h.fk_colmo = c.id;

-- Consulta 4: Visão geral do canavial
SELECT
    cli.razaoSocial AS 'Cliente',
    can.id AS 'Canavial',
    can.metaVol AS 'Meta de Toneladas',
    CONCAT(i.tipo, ' do ', i.fabricante) AS 'Info. do Insumo',
    a.dtCicloInit AS 'Inicio do ciclo',
    CASE WHEN a.dtColeta IS NULL THEN 'Em andamento' ELSE a.dtColeta END AS 'Status de Coleta'
FROM cliente cli
    JOIN canavial can
        ON can.fk_dono = cli.id
    JOIN amostra a
        ON a.fk_canavial = can.id
    JOIN insumo i
        ON a.fk_insumo = i.id
-- Cada ON liga uma tabela à anterior pela FK; sem eles o select combinaria todos os registros com todos (produto cartesiano)
ORDER BY cli.razaoSocial;