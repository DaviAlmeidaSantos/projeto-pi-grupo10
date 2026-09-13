CREATE DATABASE insumais;
USE insumais;
DROP TABLE cana;

CREATE TABLE cliente(
id_cliente INT AUTO_INCREMENT,
nome VARCHAR (50) NOT NULL,
cnpj CHAR (14) NOT NULL UNIQUE,
senha VARCHAR (13) NOT NULL UNIQUE
); 

CREATE TABLE cana(
id INT AUTO_INCREMENT PRIMARY KEY,
terreno_hectar DECIMAL (10,2),
data_plantacao DATETIME,
previsao DATE,
qtd_insumos INT,
tipo_insumo VARCHAR (255),
meta_vol DECIMAL (10, 2)
);

CREATE TABLE insumo(
id_insumo INT AUTO_INCREMENT PRIMARY KEY,
nome VARCHAR(50) NOT NULL,
fabricante VARCHAR (50),
txa_efieciencia FLOAT NOT NULL,
custoportonelada DECIMAL (10,2),
id_cana INT,
num_aplicacoes INT
 );
 
CREATE TABLE sensor(
id_sensor INT AUTO_INCREMENT PRIMARY KEY,
id_cana INT,
dt_inicio DATETIME,
altura_atual DECIMAL (10,2),
raio_atual DECIMAL (10,2),
variacao_altura DECIMAL (10,2),
variacao_raio DECIMAL (10,2)
);
