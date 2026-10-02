CREATE DATABASE insumais;
USE insumais;
 
-- Tabela para armazenar dados do cliente que comprará a nossa solução
CREATE TABLE cliente(
	id INT PRIMARY KEY AUTO_INCREMENT,
	razaoSocial VARCHAR(100) NOT NULL UNIQUE,
	nmFantasia VARCHAR(100),
	cnpj CHAR(14) UNIQUE NOT NULL,
	senha VARCHAR(50) NOT NULL,
	email VARCHAR(255) NOT NULL,
	CONSTRAINT chkEmail CHECK(email LIKE '%@%') -- Confirma se o campo email recebeu um registro válido
);
 
-- Tabela para armazenar informações relacionadas ao insumo
CREATE TABLE insumo(
	id INT PRIMARY KEY AUTO_INCREMENT,
	tipo VARCHAR(100),
	fabricante VARCHAR(255),
	custoPorTon DECIMAL(10,2) -- Custo por tonelada
);
 
-- Guarda dados do canavial inteiro, como quem é o dono e qual a meta de volume
CREATE TABLE canavial(
	id INT PRIMARY KEY AUTO_INCREMENT,
	fkDono INT, -- Ligação com [cliente]
	metaVol INT, -- Toneladas
	CONSTRAINT chkFkDono FOREIGN KEY (fkDono) REFERENCES cliente (id)
);
 
-- Guarda dados de grupos de colmos dentro de um canavial, diz qual insumo está sendo utilizado e quando o grupo foi plantado
CREATE TABLE amostra(
	id INT PRIMARY KEY AUTO_INCREMENT,
	fkCanavial INT, -- Ligação com [canavial]
	fkInsumo INT, -- Ligação com [insumo]
	dtCicloInit DATE,
	dtColeta DATE DEFAULT NULL,
	CONSTRAINT chkFkCanavial FOREIGN KEY (fkCanavial) REFERENCES canavial (id),
	CONSTRAINT chkFkInsumo FOREIGN KEY (fkInsumo) REFERENCES insumo (id)
);
 
-- Tabela para o colmo (cana) individual, altura e raio são dados em constante atualização conforme o crescimento do colmo
CREATE TABLE colmo(
	id INT PRIMARY KEY AUTO_INCREMENT,
	fkAmostra INT, -- Qual grupo ele pertence (ligação com [amostra])
	altura INT, -- em CM
	raio INT, -- em CM
	dtPlantado DATETIME DEFAULT NULL,
	dtUltimaLeitura DATETIME DEFAULT NOW(),
	CONSTRAINT chkFkAmostra FOREIGN KEY (fkAmostra) REFERENCES amostra (id)
);
 
-- Tabela feita para guardar o status do sensor
CREATE TABLE sensor(
	id INT PRIMARY KEY AUTO_INCREMENT,
	medicao INT, -- tamanho máximo calculável pelo sensor (em cm)
	orientacao CHAR(1),
	dtInstalacao DATETIME DEFAULT NOW(),
	ativo TINYINT NOT NULL DEFAULT 1,
	fkColmo INT, -- Ligação com [colmo]
	CONSTRAINT chkOrientacao CHECK(orientacao IN('V','H')),
	CONSTRAINT chkFkColmo FOREIGN KEY (fkColmo) REFERENCES colmo (id)
); -- Adendo: Medição -> 9999.99 cm = 99m MAX
 
-- Guarda os valores passados do colmo, armazenando os valores anteriores para pesquisa
CREATE TABLE historico(
	idHist INT PRIMARY KEY AUTO_INCREMENT,
	fkColmo INT, -- Ligação com [colmo]
	alturaPast INT, -- em CM
	raioPast INT, -- em CM
	dtReg DATETIME DEFAULT NOW(), -- Data do registro
	CONSTRAINT chkFkColmoHistorico FOREIGN KEY (fkColmo) REFERENCES colmo (id)
);
 
/*
	Inserção de dados arbitrários
*/
 
INSERT INTO cliente (razaoSocial, nmFantasia, cnpj, senha, email) VALUES
('Usina Raizen Teste', NULL, '12345678000199', 'senha123', 'contato@raizen.com');
 
INSERT INTO insumo (tipo, fabricante, custoPorTon) VALUES
('Fertilizante nitrogenado', 'Yara', 335.00),
('Herbicida', 'Ihara', 300.00);
 
INSERT INTO canavial (fkDono, metaVol) VALUES (1, 5000);
 
INSERT INTO amostra (fkCanavial, fkInsumo, dtCicloInit, dtColeta) VALUES
(1, 1, '2026-01-01', NULL),
(1, 2, '2026-01-01', NULL);
 
INSERT INTO colmo (fkAmostra, altura, raio, dtPlantado) VALUES
(1, 45, 2, '2026-01-05'),
(1, 47, 2, '2026-01-05'),
(1, 44, 2, '2026-01-05'),
(1, 46, 2, '2026-01-05'),
(1, 45, 2, '2026-01-05');
 
INSERT INTO sensor (medicao, orientacao, dtInstalacao, ativo, fkColmo) VALUES
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
 
INSERT INTO historico (fkColmo, alturaPast, raioPast, dtReg) VALUES
(1, 45, 2, '2026-01-05'),
(2, 47, 2, '2026-01-05'),
(3, 44, 2, '2026-01-05'),
(4, 46, 2, '2026-01-05'),
(5, 45, 2, '2026-01-05');
 
UPDATE colmo SET altura = 68, raio = 3 WHERE id = 1; -- era 45,2
UPDATE colmo SET altura = 70, raio = 3 WHERE id = 2; -- era 47,2
UPDATE colmo SET altura = 66, raio = 3 WHERE id = 3; -- era 44,2
UPDATE colmo SET altura = 69, raio = 3 WHERE id = 4; -- era 46,2
UPDATE colmo SET altura = 67, raio = 3 WHERE id = 5; -- era 45,2
 
/*
	Selects de demonstração.
*/
 
-- Como estão minhas plantas hoje?
SELECT id AS 'Identificador do colmo',
       altura AS 'Altura em CM',
       raio AS 'Raio em CM',
       IFNULL(dtPlantado, 'Sem data de plantio') AS 'Data de Plantio'
FROM colmo ORDER BY id;
 
-- O que eu apliquei em cada área, já foi colhido?
SELECT amostra.id AS Amostra,
       insumo.tipo AS Insumo,
       amostra.dtCicloInit AS 'Inicio do Ciclo',
       CASE WHEN ISNULL(amostra.dtColeta) THEN 'Coleta pendente' ELSE amostra.dtColeta END AS 'Data da Coleta'
FROM amostra
       JOIN insumo ON amostra.fkInsumo = insumo.id;
 
-- Minha cana cresceu?
SELECT colmo.id AS 'Colmo',
       historico.alturaPast AS 'Altura Anterior',
       colmo.altura AS 'Altura Atual',
       CASE WHEN colmo.altura > historico.alturaPast THEN 'Cresceu' ELSE 'Sem crescimento' END AS 'Situação de crescimento'
FROM colmo
       JOIN historico ON historico.fkColmo = colmo.id;
 
-- Visão geral do canavial
SELECT cliente.razaoSocial AS 'Cliente',
       canavial.id AS 'Canavial',
       canavial.metaVol AS 'Meta de Toneladas',
       CONCAT(insumo.tipo, ' do ', insumo.fabricante) AS 'Info. do Insumo',
       amostra.dtCicloInit AS 'Inicio do ciclo',
       CASE WHEN ISNULL(amostra.dtColeta) THEN 'Em andamento' ELSE amostra.dtColeta END AS 'Status de Coleta'
FROM cliente
       JOIN canavial ON canavial.fkDono = cliente.id
       JOIN amostra ON amostra.fkCanavial = canavial.id
       JOIN insumo ON amostra.fkInsumo = insumo.id
-- Cada ON liga uma tabela à anterior pela FK; sem eles o select combinaria todos os registros e retornaria 4 linhas duplicadas
ORDER BY cliente.razaoSocial;
