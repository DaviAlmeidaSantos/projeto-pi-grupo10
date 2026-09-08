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
    medicao INT, 
    orientacao CHAR(1),
    dtInstalacao DATETIME DEFAULT NOW(),
    ativo TINYINT NOT NULL DEFAULT 1,
    idColmo INT, -- Ligação com [outra tabela]
    CONSTRAINT chkOrientacao CHECK(orientacao IN('V','H'))
); -- Adendo: Medição -> 9999.99 cm = 99m MAX

CREATE TABLE canavial(
	id INT PRIMARY KEY AUTO_INCREMENT,
    idDono INT, -- Ligação com [outra tabela]
    metaVol INT -- Toneladas
);

CREATE TABLE amostra(
	id INT PRIMARY KEY AUTO_INCREMENT,
	idCanavial INT, -- Ligação com [outra tabela]
  idInsumo int, -- Ligação com [outra tabela]
  dtCicloInit DATE,
  dtColeta DATE DEFAULT NULL
);

CREATE TABLE colmo(
	id INT PRIMARY KEY AUTO_INCREMENT,
  idAmostra INT, -- Qual grupo ele pertence
  altura INT, -- em CM
  raio INT, -- em CM
  dtPlantado DATETIME DEFAULT NULL,
  dtUltimaLeitura
);

CREATE TABLE historico(
  idHist INT PRIMARY KEY AUTO_INCREMENT,
  idColmo INT,
  alturaPast INT, -- em CM
  raioPast INT, -- em CM
  dtReg DATETIME DEFAULT NOW()
);

/*
  Inserção de dados
*/

INSERT INTO cliente (nmFantasia, cnpj, senha, email) VALUES
('Usina Raizen Teste', '12345678000199', 'senha123', 'contato@raizen.com');

INSERT INTO insumo (tipo, fabricante, custoPorTon) VALUES
('Fertilizante nitrogenado', 'Yara', 335.00),
('Herbicida', 'Ihara', 300.00);

INSERT INTO canavial (idDono, metaVol) VALUES (1, 5000);

INSERT INTO amostra (idCanavial, idInsumo, dtCicloInit, dtColeta) VALUES
(1, 1, '2026-01-01', NULL),
(1, 2, '2026-01-01', NULL);

INSERT INTO colmo (idAmostra, altura, raio, dtPlantado) VALUES
(1, 45, 2, '2026-01-05'),
(1, 47, 2, '2026-01-05'),
(1, 44, 2, '2026-01-05'),
(1, 46, 2, '2026-01-05'),
(1, 45, 2, '2026-01-05');

INSERT INTO sensor (medicao, orientacao, dt_instalacao, ativo, colmo_id) VALUES
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

INSERT INTO historico (idColmo, alturaPast, raioPast, dtReg) VALUES
(1, 45, 2, '2026-01-05'),
(2, 47, 2, '2026-01-05'),
(3, 44, 2, '2026-01-05'),
(4, 46, 2, '2026-01-05'),
(5, 45, 2, '2026-01-05');

UPDATE colmo SET altura = 68, raio = 3, idAmostra = 2 WHERE id = 1; -- era 45,2
UPDATE colmo SET altura = 70, raio = 3, idAmostra = 2 WHERE id = 2; -- era 47,2
UPDATE colmo SET altura = 66, raio = 3, idAmostra = 2 WHERE id = 3; -- era 44,2
UPDATE colmo SET altura = 69, raio = 3, idAmostra = 2 WHERE id = 4; -- era 46,2
UPDATE colmo SET altura = 67, raio = 3, idAmostra = 2 WHERE id = 5; -- era 45,2

/*
	Selects de demonstração.
*/

-- Mostra os colmos
SELECT id AS 'Identificador do colmo',
       altura AS 'Altura em CM',
       raio AS 'Raio em CM',
       IFNULL(dtPlantado, 'Sem data de plantio') AS 'Data de Plantio'
FROM colmo
ORDER BY id;

-- Grupo de amostra, insumo utilizado, inicio do ciclo e termino dele
SELECT amostra.id AS Amostra,
       insumo.tipo AS Insumo,
       amostra.dtCicloInit AS 'Inicio do Ciclo',
       CASE WHEN ISNULL(amostra.dtColeta) THEN 'Coleta pendente' ELSE amostra.dtColeta END AS 'Data da Coleta'
FROM amostra
JOIN insumo ON amostra.idInsumo = insumo.id;

-- Comparação de altura atual do colmo com uma altura antiga
SELECT colmo.id AS 'Colmo',
       historico.alturaPast AS 'Altura Anterior',
       colmo.altura AS 'Altura Atual',
       CASE WHEN colmo.altura > historico.alturaPast THEN 'Cresceu' ELSE 'Sem crescimento' END AS 'Situação de crescimento'
FROM colmo
JOIN historico ON historico.idColmo = colmo.id;

SELECT cliente.nmFantasia AS 'Cliente',
       canavial.id AS 'Canavial',
       canavial.metaVol AS 'Meta de Toneladas',
       insumo.tipo AS 'Insumo Testado',
       insumo.fabricante AS 'Fabricante',
       amostra.dtCicloInit AS 'Inicio Ciclo',
       CASE WHEN ISNULL(amostra.dtColeta) THEN 'Em andamento' ELSE amostra.dtColeta END AS 'Status de Coleta'
FROM cliente
JOIN canavial ON canavial.idDono = cliente.id
JOIN amostra ON amostra.idCanavial = canavial.id
JOIN insumo ON amostra.idInsumo = insumo.id
ORDER BY cliente.nmFantasia;