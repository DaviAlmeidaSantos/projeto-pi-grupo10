CREATE DATABASE Grupo10;
USE Grupo10;
CREATE TABLE Colmo(
  idCana INT PRIMARY KEY AUTO_INCREMENT,
  fkCanavial INT,
  dtPlantado DATE
);

CREATE TABLE Canavial(
  idCanavial INT PRIMARY KEY AUTO_INCREMENT,
  fkInsumo INT,
  fkCliente INT,
  CicloInit DATE NOT NULL DEFAULT NOW(),
  CicloFim DATE,
  metaVolume INT
);

CREATE TABLE Amostra(
  idAmostra INT PRIMARY KEY AUTO_INCREMENT,
  fkColmo INT,
  fkSensorV INT,
  fkSensorH INT,
  altura FLOAT,
  Raio FLOAT,
  dtRegistro DATETIME DEFAULT NOW()
);

CREATE TABLE Sensor(
  idSensor INT PRIMARY KEY AUTO_INCREMENT,
  fkCanavial INT,
  Direcao CHAR(1), -- V -> Vertical ou H -> Horizontal
  Estado VARCHAR(30), -- Em uso, parado, a implementar
  dtImplementado DATE
);

CREATE TABLE Insumos(
  idInsumo INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(45) NOT NULL UNIQUE,
  custo decimal(5,2) NOT NULL,
  fabricante VARCHAR(45)
);

CREATE TABLE Cliente(
  IDCliente INT PRIMARY KEY AUTO_INCREMENT,
  CNPJ VARCHAR(20) NOT NULL UNIQUE,
  NomeFantasia VARCHAR(100),
  dtCompraServico DATE DEFAULT NOW(),
  EmailContact VARCHAR(100)
);