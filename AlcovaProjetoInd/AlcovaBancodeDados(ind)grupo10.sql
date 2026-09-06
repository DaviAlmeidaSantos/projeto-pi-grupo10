CREATE DATABASE insumais;
USE insumais;
CREATE TABLE cana(
id_canavial INT AUTO_INCREMENT PRIMARY KEY,
terreno_hectar DECIMAL (10,2),
data_plantacao DATETIME,
qtd_insumos INT,
altura_atual DECIMAL (10,2),
raio_atual DECIMAL (10,2),
variacao_altura DECIMAL (10,2),
variacao_raio DECIMAL (10,2)
);

CREATE TABLE insumo(
id_insumo INT AUTO_INCREMENT PRIMARY KEY,
nome VARCHAR(50),
txa_efieciencia FLOAT,
custo_hectar DECIMAL (10,2),
custo_total DECIMAL (10,2),
fk_cana INT, 
CONSTRAINT cFKCana foreign key (fk_cana)
REFERENCES cana (id_canavial)
);