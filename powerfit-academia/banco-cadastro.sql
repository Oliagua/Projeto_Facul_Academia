-- Tabelas plano e usuario (modelo do grupo, igual ao app). Banco: powerfit, o mesmo do Conexao.java.
CREATE DATABASE IF NOT EXISTS powerfit CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE powerfit;

CREATE TABLE IF NOT EXISTS plano (
    id_plano      INT PRIMARY KEY,
    nome_plano    VARCHAR(30)   NOT NULL UNIQUE,
    duracao_meses INT           NOT NULL CHECK (duracao_meses > 0),
    preco         DECIMAL(10,2) NOT NULL CHECK (preco > 0)
);

INSERT IGNORE INTO plano (id_plano, nome_plano, duracao_meses, preco) VALUES
    (1, 'Plano Mensal',     1, 119.00),
    (2, 'Plano Trimestral', 3, 109.00),
    (3, 'Plano Semestral',  6,  99.00),
    (4, 'Plano Anual',     12,  89.00);

-- A coluna senha guarda "salt:hash". O telefone é da versão web.
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome       VARCHAR(100) NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    telefone   VARCHAR(20)  NULL,
    senha      VARCHAR(255) NOT NULL,
    id_plano   INT          NOT NULL,
    FOREIGN KEY (id_plano) REFERENCES plano (id_plano)
);

-- Se a tabela usuario já existir com outras colunas, ajuste só o que faltar:
-- ALTER TABLE usuario ADD COLUMN telefone VARCHAR(20) NULL;
-- ALTER TABLE usuario ADD UNIQUE KEY uq_usuario_email (email);

-- Usuários inseridos na mão (senha sem "salt:hash") não conseguem entrar. Apague e cadastre de novo:
-- DELETE FROM usuario WHERE senha IS NULL OR senha NOT LIKE '%:%';
