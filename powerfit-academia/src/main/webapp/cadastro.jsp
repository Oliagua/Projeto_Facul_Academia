<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Cadastro | PowerFit Academia</title>
<link rel="stylesheet" href="css/style.css">
<link rel="stylesheet" href="css/acabamento.css?v=4">
<link rel="stylesheet" href="css/cadastro.css?v=1">
</head>
<body class="login-page">
<main class="login-box">
<a class="brand" href="index.jsp">
<span>PF</span> PowerFit <small>Academia</small>
</a>
<p class="eyebrow">Área do aluno</p>
<h1>Crie sua conta</h1>
<form id="form-cadastro" class="login-form" action="${pageContext.request.contextPath}/cadastro" method="post" novalidate>
<label>Nome completo
<input id="cad-nome" name="nome" type="text" autocomplete="name" maxlength="120" placeholder="Seu nome" required>
</label>
<label>E-mail
<input id="cad-email" name="email" type="email" autocomplete="email" maxlength="120" placeholder="voce@email.com" required>
</label>
<label>Telefone com DDD
<input id="cad-telefone" name="telefone" type="tel" autocomplete="tel" maxlength="20" placeholder="(11) 91234-5678" required>
</label>
<label>Plano
<select id="cad-plano" name="plano" required>
<option value="" disabled selected>Selecione um plano</option>
<option value="1">Plano Mensal</option>
<option value="2">Plano Trimestral</option>
<option value="3">Plano Semestral</option>
<option value="4">Plano Anual</option>
</select>
</label>
<label>Senha
<input id="cad-senha" name="senha" type="password" autocomplete="new-password" minlength="8" maxlength="72" placeholder="Mínimo de 8 caracteres" required>
</label>
<label>Confirmar senha
<input id="cad-confirmar" name="confirmar" type="password" autocomplete="new-password" minlength="8" maxlength="72" placeholder="Repita a senha" required>
</label>
<div class="login-actions">
<button type="button" id="cad-mostrar" class="text-button">Mostrar senha</button>
</div>
<button class="btn btn-primary" type="submit">Criar conta</button>
<p id="cadastro-msg" class="form-msg" role="status" aria-live="polite"></p>
</form>
<p class="back-link">Já tem conta? <a href="login.jsp">Entrar</a></p>
<p class="back-link">
<a href="index.jsp">← Voltar para o site</a>
</p>
</main>
<script src="js/cadastro.js"></script>
</body>
</html>
