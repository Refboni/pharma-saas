<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.naming.*, javax.sql.*" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>SaaS Pharma - Solicitar Fórmula</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f6f9; color: #333; }
        .container { max-width: 600px; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin: 0 auto; }
        h2 { color: #0284c7; }
        label { display: block; margin-top: 12px; font-weight: bold; }
        input[type="text"], input[type="email"], textarea { width: 100%; padding: 8px; margin-top: 5px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        textarea { height: 80px; }
        .btn { background-color: #0284c7; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; margin-top: 15px; }
        .btn:hover { background-color: #0369a1; }
        .msg { padding: 10px; border-radius: 4px; margin-bottom: 15px; }
        .success { background-color: #d1e7dd; color: #0f5132; }
        .error { background-color: #f8d7da; color: #842029; }
        .back-link { display: inline-block; margin-top: 15px; color: #0284c7; text-decoration: none; }
    </style>
</head>
<body>
<div class="container">
    <h2>Solicitar Orçamento de Fórmula</h2>

    <%
        String method = request.getMethod();
        if ("POST".equalsIgnoreCase(method)) {
            request.setCharacterEncoding("UTF-8");
            String nome = request.getParameter("nome");
            String email = request.getParameter("email");
            String telefone = request.getParameter("telefone");
            String descricao = request.getParameter("descricao");
            String posologia = request.getParameter("posologia");

            Connection conn = null;
            PreparedStatement stmtCliente = null;
            PreparedStatement stmtPedido = null;
            ResultSet rs = null;

            try {
                Context initContext = new InitialContext();
                Context envContext  = (Context)initContext.lookup("java:/comp/env");
                DataSource ds = (DataSource)envContext.lookup("jdbc/pharma_db");
                conn = ds.getConnection();

                conn.setAutoCommit(false);

                // 1. Inserir ou obter o cliente
                String sqlCliente = "INSERT INTO clientes (nome, email, telefone) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE id_cliente=LAST_INSERT_ID(id_cliente)";
                stmtCliente = conn.prepareStatement(sqlCliente, Statement.RETURN_GENERATED_KEYS);
                stmtCliente.setString(1, nome);
                stmtCliente.setString(2, email);
                stmtCliente.setString(3, telefone);
                stmtCliente.executeUpdate();

                rs = stmtCliente.getGeneratedKeys();
                int idCliente = 0;
                if (rs.next()) {
                    idCliente = rs.getInt(1);
                }

                // 2. Inserir o pedido da fórmula vinculando ao id do cliente
                String sqlPedido = "INSERT INTO pedidos_formulas (id_cliente, descricao_formula, posologia) VALUES (?, ?, ?)";
                stmtPedido = conn.prepareStatement(sqlPedido);
                stmtPedido.setInt(1, idCliente);
                stmtPedido.setString(2, descricao);
                stmtPedido.setString(3, posologia);
                stmtPedido.executeUpdate();

                conn.commit();
                out.println("<div class='msg success'>Solicitação enviada com sucesso!</div>");
            } catch (Exception e) {
                if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
                out.println("<div class='msg error'>Erro ao processar solicitação: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) rs.close();
                if (stmtCliente != null) stmtCliente.close();
                if (stmtPedido != null) stmtPedido.close();
                if (conn != null) conn.close();
            }
        }
    %>

    <form action="insert.jsp" method="POST">
        <label for="nome">Nome Completo:</label>
        <input type="text" id="nome" name="nome" required>

        <label for="email">E-mail de Contato:</label>
        <input type="email" id="email" name="email" required>

        <label for="telefone">Telefone / WhatsApp:</label>
        <input type="text" id="telefone" name="telefone">

        <label for="descricao">Descrição da Fórmula (Ingredientes / Concentração):</label>
        <textarea id="descricao" name="descricao" required placeholder="Ex: Vitamina C 500mg + Zinco 15mg"></textarea>

        <label for="posologia">Posologia Recomendada:</label>
        <input type="text" id="posologia" name="posologia" placeholder="Ex: Tomar 1 cápsula via oral ao dia">

        <button type="submit" class="btn">Enviar Pedido</button>
    </form>

    <br>
    <a href="index.html" class="back-link">← Voltar para o início</a>
</div>
</body>
</html>
