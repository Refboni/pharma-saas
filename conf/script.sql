-- Criacao da base de dados do SaaS Pharma
CREATE DATABASE IF NOT EXISTS pharma_db;
USE pharma_db;

-- Tabela de Clientes / Pacientes
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabela de Pedidos de Formulas Manipuladas
CREATE TABLE IF NOT EXISTS pedidos_formulas (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    descricao_formula TEXT NOT NULL,
    posologia VARCHAR(255),
    status VARCHAR(50) DEFAULT 'EM_ANALISE',
    valor_estimado DECIMAL(10, 2),
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pedido_cliente 
        FOREIGN KEY (id_cliente) 
        REFERENCES clientes(id_cliente) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Tabela de Autenticação e Tokens para o SaaS
CREATE TABLE IF NOT EXISTS login (
    id_login INT AUTO_INCREMENT PRIMARY KEY,
    user VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    token VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- Inserção de dados iniciais para testes
INSERT INTO clientes (nome, email, telefone) VALUES 
('Carlos Silva', 'carlos@email.com', '(11) 98888-1111'),
('Ana Souza', 'ana@email.com', '(11) 97777-2222');

INSERT INTO pedidos_formulas (id_cliente, descricao_formula, posologia, status, valor_estimado) VALUES 
(1, 'Vitamina C 500mg + Zinco 15mg (60 capsulas)', 'Tomar 1 capsula ao dia', 'EM_ANALISE', 45.00),
(2, 'Melatonina 3mg Sublingual (30 gotas)', 'Tomar 5 gotas antes de dormir', 'EM_PRODUCAO', 35.50);

-- Inserção de usuário de teste (Usuário: admin@pharma.com / Senha: 123456)
INSERT INTO login (user, password, token) 
VALUES ('admin@pharma.com', MD5('123456'), 'TOKEN-SAAS-PHARMA-2026');
