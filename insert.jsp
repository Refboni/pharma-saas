<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.naming.*, javax.sql.*" %>
<%
    // Desabilita o cache no servidor durante a fase de desenvolvimento
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>SaaS Pharma - Solicitar Orçamento</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f6f9; color: #333; }
        .container { max-width: 600px; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin: 0 auto; }
        h2 { color: #0284c7; }
        label { display: block; margin-top: 15px; font-weight: bold; }
        input[type="text"], input[type="email"], textarea { width: 100%; padding: 10px; margin-top: 5px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        textarea { height: 100px; }
        .btn { background-color: #0284c7; color: white; padding: 12px 20px; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; margin-top: 20px; width: 100%; }
        .btn:hover { opacity: 0.9; }
        .msg-success { color: #15803d; font-weight: bold; margin-top: 15px; text-align: center; }
        .msg-error { color: #b91c1c; font-weight: bold; margin-top: 15px; text-align: center; }
        .back-link { display: inline-block; margin-top: 20px; color: #0284c7; text-decoration: none; font-weight: bold; }
    </style>
</head>
<body>
<div class="container">
    <h2>Solicitação de Fórmula Manipulada</h2>

    <%
        String nome = request.getParameter("nome");
        String email = request.getParameter("email");
        String telefone = request.getParameter("telefone");
        String formula = request.getParameter("formula");
        String posologia = request.getParameter("posologia");

        if (nome != null && email != null && formula != null) {
            Connection conn = null;
            PreparedStatement psCliente = null;
            PreparedStatement psPedido = null;
            ResultSet rs = null;

            try {
                Context initContext = new InitialContext();
                Context envContext  = (Context)initContext.lookup("java:/comp/env");
                DataSource ds = (DataSource)envContext.lookup("jdbc/pharma_db");
                conn = ds.getConnection();

                // Insere ou atualiza o cliente
                String sqlCliente = "INSERT INTO clientes (nome, email, telefone) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE id_cliente=LAST_INSERT_ID(id_cliente)";
                psCliente = conn.prepareStatement(sqlCliente, Statement.RETURN_GENERATED_KEYS);
                psCliente.setString(1, nome);
                psCliente.setString(2, email);
                psCliente.setString(3, telefone);
                psCliente.executeUpdate();

                rs = psCliente.getGeneratedKeys();
                int idCliente = 0;
                if (rs.next()) {
                    idCliente = rs.getInt(1);
                }

                // Insere o pedido
                String sqlPedido = "INSERT INTO pedidos_formulas (id_cliente, descricao_formula, posologia, status) VALUES (?, ?, ?, 'EM_ANALISE')";
                psPedido = conn.prepareStatement(sqlPedido);
                psPedido.setInt(1, idCliente);
                psPedido.setString(2, formula);
                psPedido.setString(3, posologia);
                psPedido.executeUpdate();

                out.print("<p class='msg-success'>Pedido cadastrado com sucesso!</p>");
            } catch (Exception e) {
                out.print("<p class='msg-error'>Erro ao cadastrar pedido: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) rs.close();
                if (psCliente != null) psCliente.close();
                if (psPedido != null) psPedido.close();
                if (conn != null) conn.close();
            }
        }
    %>

    <form action="insert.jsp" method="POST">
        <label for="nome">Nome Completo:</label>
        <input type="text" id="nome" name="nome" required>

        <label for="email">E-mail de Contacto:</label>
        <input type="email" id="email" name="email" required>

        <label for="telefone">Telefone:</label>
        <input type="text" id="telefone" name="telefone">

        <label for="formula">Descrição da Fórmula:</label>
        <textarea id="formula" name="formula" required></textarea>

        <label for="posologia">Posologia Recomendada:</label>
        <input type="text" id="posologia" name="posologia">

        <button type="submit" class="btn">Enviar Pedido</button>
    </form>

    <a href="index.html" class="back-link">← Voltar para o início</a>
</div>
</body>
</html>
