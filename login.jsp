<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
    <title>SaaS Pharma - Login</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f6f9; text-align: center; color: #333; }
        .box { max-width: 400px; background: white; padding: 25px; border-radius: 8px; margin: 0 auto; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h2 { color: #0284c7; }
        input { width: 90%; padding: 10px; margin: 8px 0; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        .btn { background-color: #0284c7; color: white; padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; width: 90%; margin-top: 10px; }
        .btn:hover { opacity: 0.9; }
        .msg-success { color: #15803d; font-weight: bold; margin-top: 15px; }
        .msg-error { color: #b91c1c; font-weight: bold; margin-top: 15px; }
        .back-link { display: inline-block; margin-top: 15px; color: #0284c7; text-decoration: none; font-weight: bold; }
    </style>
</head>
<body>
<div class="box">
    <h2>Autenticação SaaS</h2>

    <%
        String user = request.getParameter("user");
        String pass = request.getParameter("password");

        if (user != null && pass != null) {
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pharma_db", "root", "");

                // Valida usuário e senha criptografada em MD5
                String sql = "SELECT token FROM login WHERE user = ? AND password = MD5(?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, user);
                ps.setString(2, pass);

                rs = ps.executeQuery();

                if (rs != null && rs.next()) {
                    String token = rs.getString(1);
                    session.setAttribute("token", token);
                    out.print("<p class='msg-success'>Conectado</p>");
                    out.print("<p><a href='index.html' class='back-link'>Ir para o Início</a></p>");
                } else {
                    out.print("<p class='msg-error'>TOKEN NÃO ENCONTRADO. ASSINE OU ATUALIZE O PLANO...</p>");
                }
            } catch (Exception e) {
                out.print("<h3 class='msg-error'>ERRO NO ACESSO</h3>");
            } finally {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            }
        }
    %>

    <form action="login.jsp" method="POST">
        <input type="text" name="user" placeholder="E-mail de usuário" required><br>
        <input type="password" name="password" placeholder="Senha" required><br>
        <button type="submit" class="btn">Entrar</button>
    </form>
</div>
</body>
</html>
