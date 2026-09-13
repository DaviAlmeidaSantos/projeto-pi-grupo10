CREATE DATABASE Insumais;
USE insumais;

CREATE TABLE cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL
);

CREATE TABLE insumo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(100) NOT NULL,
    preco_ton DECIMAL(10, 2),
    fabricante VARCHAR(100)
);

CREATE TABLE amostra (
    id INT AUTO_INCREMENT PRIMARY KEY,
    insumo_id INT NOT NULL,
    insumo_qtd DECIMAL(10, 2),
    dt_plantacao DATE NOT NULL,
    max_vertical DECIMAL(10, 2),
    max_horizontal DECIMAL(10, 2),
    densidade_cana DECIMAL(10, 2)
);

CREATE TABLE canavial (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    amostra_id INT NOT NULL
);

CREATE TABLE cana (
    id INT AUTO_INCREMENT PRIMARY KEY,
    amostra_id INT NOT NULL,
    altura DECIMAL(10, 2),
    raio DECIMAL(10, 2),
    densidade DECIMAL(10, 2),
    max_vert DECIMAL(10, 2),
    max_hori DECIMAL(10, 2)
);