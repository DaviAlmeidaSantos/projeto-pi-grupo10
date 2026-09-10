CREATE DATABASE Insumais;
USE Insumais;

CREATE TABLE cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL
);

CREATE TABLE propriedade (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(100),
    area_total DECIMAL(10,2)
);

CREATE TABLE canavial (
    id INT AUTO_INCREMENT PRIMARY KEY,
    propriedade_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    area_hectares DECIMAL(10,2) NOT NULL,
    dt_plantacao DATE NOT NULL
);

CREATE TABLE insumo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(100) NOT NULL,
    preco_ton DECIMAL(10,2),
    fabricante VARCHAR(100)
);

CREATE TABLE aplicacao_insumo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    canavial_id INT NOT NULL,
    insumo_id INT NOT NULL,
    quantidade DECIMAL(10,2) NOT NULL,
    dt_aplicacao DATE NOT NULL
);

CREATE TABLE medicao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    canavial_id INT NOT NULL,
    dt_medicao DATE NOT NULL,
    altura DECIMAL(10,2),
    raio DECIMAL(10,2),
    densidade DECIMAL(10,2)
);