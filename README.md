# SaaS Pharma - Gestão e Pedidos para Farmácia de Manipulação

## 1. Esboço da Aplicação
O **Pharma** é uma plataforma SaaS voltada para farmácias de manipulação e seus clientes. A aplicação permite a solicitação, orçamento e acompanhamento de fórmulas magistrais e oficinais personalizadas.

### Problema
Farmácias de manipulação dependem frequentemente de canais informais (como e-mail ou mensagens instantâneas) para receber receitas e pedidos de fórmulas, gerando perda de histórico, erros na interpretação de dosagens e falta de rastreabilidade.

### Solução SaaS
Uma plataforma centralizada na nuvem onde:
* **Clientes / Pacientes**: Cadastram-se e enviam solicitações de orçamentos de fórmulas manipuladas.
* **Farmácia (Tenants)**: Gerenciam os pedidos recebidos, definem os status de manipulação (Em análise, Em produção, Pronto, Entregue) e mantêm o histórico centralizado.

---

## 2. ADR (Architecture Decision Record)

### ADR 001: Definição da Arquitetura do Sistema e Banco de Dados Inicial

* **Status**: Aprovado
* **Data**: Outubro / 2026

#### Contexto
Para atender aos requisitos da disciplina de SaaS Infrastructure e garantir um ponto de partida escalável, é necessário definir a arquitetura inicial da aplicação em 3 camadas (Apresentação, Regra de Negócio e Banco de Dados) e a modelagem do banco de dados relacional.

#### Decisões
1. **Arquitetura 3 Camadas**:
   * **Camada 1 (Banco de Dados)**: MySQL rodando em servidor dedicado ou VM.
   * **Camada 2 (Aplicação / Servidor Web)**: Java (JSP/Servlets) no Apache Tomcat 10.
   * **Camada 3 (Apresentação)**: Interface Web responsiva (HTML5/CSS3/JavaScript).
2. **Modelagem de Dados**:
   * Criação de tabela de clientes (`clientes`) e tabela de pedidos de fórmulas (`pedidos_formulas`).
   * Aplicação de restrições de integridade referencial com `FOREIGN KEY` e ação em cascata (`ON DELETE CASCADE ON UPDATE CASCADE`).
3. **Controle de Versão e Deploy**:
   * O código da aplicação e as configurações de banco de dados (`conf/`) são mantidos em repositório GitHub privado e clonados diretamente no ambiente de aplicação.

#### Consequências
* **Positivas**: Estrutura simples, de fácil manutenção, alinhada com os padrões de SaaS em 3 camadas e preparada para futura migração para microsserviços.
* **Negativas / Riscos**: Exige gestão rigorosa do banco de dados ao excluir registros principais para evitar remoções acidentais em cascata.
