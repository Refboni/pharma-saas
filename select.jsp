<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.naming.*, javax.sql.*" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>SaaS Pharma - Listagem de Pedidos</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f6f9; color: #333; }
        .container { max-width: 900px; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin: 0 auto; }
        h2 { color: #0284c7; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: #0284c7; color: white; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .badge { padding: 4px 8px; border-radius: 4px; font-size: 0.85em; font-weight: bold; }
        .status-analise { background-color: #fef08a; color: #854d0e; }
        .status-producao { background-color: #bae6fd; color: #0369a1; }
        .back-link { display: inline-block; margin-top: 20px; color: #0284c7; text-decoration: none; font-weight: bold; }
    </style>
</head>
<body>
<div class="container">
    <h2>Pedidos de Fórmulas Cadastrados</h2>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Cliente</th>
                <th>E-mail</th>
                <th>Fórmula Solicitada</th>
                <th>Posologia</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <%
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;

                try {
                    Context initContext = new InitialContext();
                    Context envContext  = (Context)initContext.lookup("java:/comp/env");
                    DataSource ds = (DataSource)envContext.lookup("jdbc/pharma_db");
                    conn = ds.getConnection();

                    String sql = "SELECT p.id_pedido, c.nome, c.email, p.descricao_formula, p.posologia, p.status " +
                                 "FROM pedidos_formulas p " +
                                 "JOIN clientes c ON p.id_cliente = c.id_cliente " +
                                 "ORDER BY p.id_pedido DESC";

                    stmt = conn.createStatement();
                    rs = stmt.executeQuery(sql);

                    while (rs.next()) {
                        String status = rs.getString("status");
                        String statusClass = "EM_PRODUCAO".equalsIgnoreCase(status) ? "status-producao" : "status-analise";
            %>
            <tr>
                <td><%= rs.getInt("id_pedido") %></td>
                <td><%= rs.getString("nome") %></td>
                <td><%= rs.getString("email") %></td>
                <td><%= rs.getString("descricao_formula") %></td>
                <td><%= rs.getString("posologia") != null ? rs.getString("posologia") : "-" %></td>
                <td><span class="badge <%= statusClass %>"><%= status %></span></td>
            </tr>
            <%
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='6'>Erro ao carregar dados: " + e.getMessage() + "</td></tr>");
                } finally {
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                    if (conn != null) conn.close();
                }
            %>
        </tbody>
    </table>

    <a href="index.html" class="back-link">← Voltar para o início</a>
</div>
</body>
</html>
