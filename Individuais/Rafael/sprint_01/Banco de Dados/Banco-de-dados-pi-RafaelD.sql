CREATE DATABASE PI_RafaelD;
USE PI_RafaelD;

CREATE TABLE insumo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(50) NOT NULL,
    fabricante VARCHAR(100) NOT NULL,
    rendimento DECIMAL (10,2),
    custo DECIMAL (20,2)
);

CREATE TABLE cliente (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(70),
    cnpj CHAR(14) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL UNIQUE,
    orcamento DECIMAL(20,2),
    email_contato VARCHAR(30)
);

CREATE TABLE amostra (
    id INT PRIMARY KEY AUTO_INCREMENT,
    insumo_tipo INT NOT NULL,
    insumo_qtd DECIMAL(10,2) NOT NULL,
    dt_plantacao DATE NOT NULL,
    dt_coleta DATE NOT NULL
);

CREATE TABLE cana (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(30),
    amostra_id INT NOT NULL,
    altura DECIMAL(10,2) NOT NULL,
    diametro DECIMAL(10,2) NOT NULL,
    volume DECIMAL(10,2) NOT NULL
);

CREATE TABLE sensor (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_cana INT NOT NULL,
    captura DATETIME NOT NULL,
    orientacao VARCHAR(50) NOT NULL,
    data_instalacao DATE,
    tempo_capturas DATETIME
);

CREATE TABLE capturas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    max_vertical DECIMAL(10,2) NOT NULL,
    max_horizontal DECIMAL(10,2) NOT NULL,
    densidade_cana DECIMAL(10,2) NOT NULL
);

CREATE TABLE canavial (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    amostra_id INT NOT NULL,
    capturas_id INT NOT NULL,
    insumo_id INT NOT NULL
);