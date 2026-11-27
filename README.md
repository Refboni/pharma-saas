# SaaS Pharma - Gestão e Pedidos para Farmácia de Manipulação

## 1. Esboço da Aplicação
O **Pharma** é uma plataforma SaaS voltada para farmácias de manipulação e seus clientes. A aplicação permite a solicitação, orçamento e acompanhamento de fórmulas magistrais e oficinais personalizadas.

### Problema
Farmácias de manipulação dependem frequentemente de canais informais (como e-mail ou mensagens instantâneas) para receber receitas e pedidos de fórmulas, gerando perda de histórico, erros na interpretação de dosagens e falta de rastreabilidade.

### Solução SaaS
Uma plataforma centralizada na nuvem onde:
- **Clientes / Pacientes**: Cadastram-se e enviam solicitações de orçamentos de fórmulas manipuladas.
- **Farmácia (Tenants)**: Gerenciam os pedidos recebidos, definem os status de manipulação (Em análise, Em produção, Pronto, Entregue) e mantêm o histórico centralizado.

---

## 2. Status das Funcionalidades

- [x] **Modelagem e Banco de Dados Relacional**: Estrutura inicial de clientes, pedidos de fórmulas e tabela de autenticação (`conf/script.sql`).
- [x] **Driver JDBC Integrado**: Conector MySQL (`mysql-connector-j-26.7.0.jar`) incluído diretamente em `WEB-INF/lib/` para portabilidade entre ambientes.
- [x] **Autenticação de Usuários**: Tela de login (`login.jsp`) com validação de credenciais (hash MD5) e criação de sessão (`HttpSession`).
- [x] **Camada de Segurança e Controle de Acesso**: Filtro Java (`AuthFilter`) mapeado via `web.xml` para interceptar requisições, bloquear acessos sem sessão ativa e impedir cache de páginas protegidas no navegador.
- [x] **Solicitação de Fórmulas**: Formulário de cadastro e envio de pedidos (`insert.jsp`).
- [x] **Consulta de Pedidos**: Listagem e acompanhamento das solicitações registradas (`select.jsp`).
- [ ] **Encerramento de Sessão**: Implementação da rota `logout.jsp` e botão de saída na interface principal (em desenvolvimento).

---

## 3. Estrutura do Projeto

```text
pharma-saas/
├── conf/
│   ├── context.xml                                    # Configuração de referência do DataSource JDBC
│   └── script.sql                                     # Script de criação do banco, tabelas e dados de teste
├── WEB-INF/
│   ├── classes/com/pharma/security/AuthFilter.class   # Filtro de autenticação e controle de cache (Java 21)
│   ├── lib/mysql-connector-j-26.7.0.jar               # Driver JDBC do MySQL empacotado com a aplicação
│   └── web.xml                                        # Mapeamento do AuthFilter e configurações da aplicação
├── index.html                                         # Página inicial / painel de navegação
├── login.jsp                                          # Autenticação de usuários e criação de sessão
├── insert.jsp                                         # Cadastro e solicitação de orçamento de fórmulas
├── select.jsp                                         # Consulta e listagem de pedidos
└── README.md                                          # Documentação técnica e ADRs do projeto
```

---

## 4. ADR (Architecture Decision Record)

### ADR 001: Definição da Arquitetura do Sistema e Banco de Dados Inicial

- **Status**: Aprovado
- **Data**: Outubro / 2026

#### Contexto
Para atender aos requisitos da disciplina de SaaS Infrastructure e garantir um ponto de partida escalável, é necessário definir a arquitetura inicial da aplicação em 3 camadas (Apresentação, Regra de Negócio e Banco de Dados) e a modelagem do banco de dados relacional.

#### Decisões
1. **Arquitetura 3 Camadas**:
   - **Camada 1 (Banco de Dados)**: MySQL rodando em servidor dedicado ou VM.
   - **Camada 2 (Aplicação / Servidor Web)**: Java (JSP/Servlets) no Apache Tomcat 10.
   - **Camada 3 (Apresentação)**: Interface Web responsiva (HTML5/CSS3/JavaScript).
2. **Modelagem de Dados**:
   - Criação de tabela de clientes (`clientes`) e tabela de pedidos de fórmulas (`pedidos_formulas`).
   - Aplicação de restrições de integridade referencial com `FOREIGN KEY` e ação em cascata (`ON DELETE CASCADE ON UPDATE CASCADE`).
3. **Controle de Versão e Deploy**:
   - O código da aplicação e as configurações de banco de dados (`conf/`) são mantidos em repositório GitHub e sincronizados com o ambiente de aplicação.

#### Consequências
- **Positivas**: Estrutura simples, de fácil manutenção, alinhada com os padrões de SaaS em 3 camadas e preparada para futura migração para microsserviços.
- **Negativas / Riscos**: Exige gestão rigorosa do banco de dados ao excluir registros principais para evitar remoções acidentais em cascata.

---

### ADR 002: Implementação de Autenticação e Camada de Segurança (Filtro de Sessão)

- **Status**: Aprovado e Implementado
- **Data**: Novembro / 2026

#### Contexto
Com as telas de cadastro (`insert.jsp`) e consulta (`select.jsp`) operacionais, tornou-se necessário impedir que usuários não autenticados acessem diretamente as rotas internas da aplicação pela URL ou visualizem páginas protegidas armazenadas no cache do navegador após o encerramento da sessão.

#### Decisões
1. **Controle de Sessão via JSP (`login.jsp`)**:
   - Validação das credenciais na tabela `login` do MySQL (`MD5`) e armazenamento do atributo de identificação do usuário na `HttpSession`.
2. **Interceptação Centralizada com Servlet Filter (`AuthFilter`)**:
   - Implementação da classe `com.pharma.security.AuthFilter` (utilizando a API `jakarta.servlet.Filter` compatível com Apache Tomcat 10 e compilada com `--release 21`).
   - Mapeamento no `WEB-INF/web.xml` para interceptar as requisições da aplicação (`/*`), liberando apenas a rota de autenticação (`login.jsp`) e redirecionando automaticamente qualquer acesso sem sessão válida para a tela de login.
3. **Prevenção de Cache no Navegador**:
   - Injeção de cabeçalhos HTTP (`Cache-Control: no-cache, no-store, must-revalidate`, `Pragma: no-cache` e `Expires: 0`) nas respostas filtradas para evitar que o botão "Voltar" do navegador exiba dados sensíveis após a expiração da sessão.

#### Consequências
- **Positivas**: Segurança centralizada em um único ponto sem necessidade de duplicar verificações de sessão em cada arquivo JSP; total compatibilidade com o Tomcat 10.
- **Negativas / Riscos**: Exige recompilação da classe `.java` e reinicialização do contexto no Tomcat sempre que regras de rotas públicas forem alteradas.

---

## 5. Guia de Implantação e Testes (Passo a Passo)

### Pré-requisitos do Ambiente
* **Java 21+** e **Apache Tomcat 10**
* **MySQL Server** configurado com o usuário `root` aceitando conexões locais sem senha (ou ajuste a senha nos arquivos `.jsp`).
  * *Caso seu MySQL no Ubuntu use `auth_socket` por padrão para o `root`, habilite o acesso local sem senha para testes:*
    ```bash
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;"
    ```

### Passo 1: Clonar o Repositório
```bash
git clone [https://github.com/Refboni/pharma-saas.git](https://github.com/Refboni/pharma-saas.git)
cd pharma-saas
```

### Passo 2: Criar o Banco de Dados e Dados Iniciais (MySQL)
Execute o script SQL para criar o banco `pharma_db`, as tabelas (`clientes`, `pedidos_formulas`, `login`) e os registros de teste:
```bash
sudo mysql -u root < conf/script.sql
```

### Passo 3: Publicar a Aplicação no Apache Tomcat 10
Copie os arquivos da aplicação (incluindo o driver JDBC em `WEB-INF/lib/`) para o diretório do Tomcat 10:
```bash
sudo mkdir -p /var/lib/tomcat10/webapps/pharma-saas/META-INF
sudo cp -r index.html login.jsp insert.jsp select.jsp WEB-INF /var/lib/tomcat10/webapps/pharma-saas/
sudo cp conf/context.xml /var/lib/tomcat10/webapps/pharma-saas/META-INF/context.xml
sudo chown -R tomcat:tomcat /var/lib/tomcat10/webapps/pharma-saas
sudo systemctl restart tomcat10
```

### Passo 4: Roteiro de Validação no Navegador

* **Credenciais de Teste:**
  * **Usuário:** `admin@pharma.com`
  * **Senha:** `123456`

1. **Teste de Bloqueio de Rota (Sem Sessão):**
   * Acesse `http://<IP_DA_VM>:8080/pharma-saas/select.jsp` sem estar logado.
   * **Resultado esperado:** O `AuthFilter` intercepta a requisição e redireciona automaticamente para `login.jsp`.
2. **Teste de Autenticação:**
   * Na tela `login.jsp`, informe `admin@pharma.com` e `123456`.
   * **Resultado esperado:** Exibe `"Conectado"` e o link `"Ir para o Início"`.
3. **Teste das Funcionalidades (CRUD):**
   * Acesse `http://<IP_DA_VM>:8080/pharma-saas/index.html` para navegar entre as telas.
   * Em `insert.jsp`, cadastre uma nova solicitação de fórmula.
   * Em `select.jsp`, confira os pedidos pré-cadastrados e o novo registro inserido.
