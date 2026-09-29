<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login | PowerFit Academia</title>
<link rel="stylesheet" href="css/style.css">
<link rel="stylesheet" href="css/acabamento.css?v=4">
</head>
<body class="login-page">
<main class="login-box">
<a class="brand" href="index.jsp">
<span>PF</span> PowerFit <small>Academia</small>
</a>
<p class="eyebrow">Área do aluno</p>
<h1>Bem-vindo de volta</h1>
<form class="login-form" onsubmit="return validarLogin(event)">
<label>E-mail<input id="login-email" type="email" autocomplete="username" placeholder="voce@email.com" required>
</label>
<label>Senha<input id="login-senha" type="password" autocomplete="current-password" placeholder="Sua senha" required>
</label>
<div class="login-actions">
<button type="button" id="mostrar-senha" class="text-button">Mostrar senha</button>
<a href="#" id="recuperar-senha">Esqueci minha senha</a>
</div>
<button class="btn btn-primary" type="submit">Entrar</button>
<p id="login-msg" class="form-msg" role="status" aria-live="polite">
</p>
</form>
<p class="back-link"><a href="admin.jsp">Conhecer a área administrativa (prévia)</a></p>
<p class="back-link">
<a href="index.jsp">← Voltar para o site</a>
</p>
</main>
<script src="js/script.js">
</script>
<script src="js/melhorias.js">
</script>
</body>
</html>
