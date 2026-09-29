<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Alunos | Administração PowerFit</title>
<link rel="stylesheet" href="css/admin.css?v=1">
<script src="js/admin.js?v=1" defer></script>
</head>
<body>
<a class="pular" href="#conteudo">Pular para o conteúdo</a>
<header class="cabecalho">
<a class="marca" href="index.jsp"><span>PF</span><div>PowerFit<small>ACADEMIA</small></div></a>
<span class="area">Área administrativa</span>
<a class="voltar" href="index.jsp">Voltar ao site ↗</a>
</header>
<main id="conteudo">
<div class="titulo-pagina">
<div><p class="etiqueta">GESTÃO DA ACADEMIA</p><h1>Alunos</h1><p>Organize os cadastros e acompanhe os planos em um só lugar.</p></div>
<button class="botao principal" id="novo-aluno" type="button">+ Cadastrar aluno</button>
</div>
<p class="aviso-previa">Prévia com dados fictícios. As alterações ficam apenas nesta página e são descartadas ao recarregar.</p>
<noscript><p class="aviso-previa">Ative o JavaScript para testar os cadastros desta prévia.</p></noscript>
<section class="resumo" aria-label="Resumo dos cadastros">
<article><span>Alunos cadastrados</span><strong id="total-alunos">—</strong></article>
<article><span>Plano anual</span><strong id="total-anual">—</strong></article>
<article><span>Outros planos</span><strong id="total-outros">—</strong></article>
</section>
<section class="painel" aria-labelledby="titulo-lista">
<div class="barra-lista"><div><h2 id="titulo-lista">Lista de alunos</h2><p id="contagem" role="status" aria-live="polite"></p></div>
<div class="filtros"><label for="busca">Buscar aluno<input id="busca" type="search" placeholder="Nome, e-mail ou telefone" autocomplete="off"></label>
<label for="filtro-plano">Plano<select id="filtro-plano"><option value="">Todos os planos</option><option>Mensal</option><option>Trimestral</option><option>Semestral</option><option>Anual</option></select></label></div></div>
<p id="resultado-acao" class="resultado" role="status" aria-live="polite"></p>
<div class="tabela-area"><table><caption class="somente-leitor">Alunos e ações de cadastro</caption><thead><tr><th scope="col">Aluno</th><th scope="col">Contato</th><th scope="col">Plano</th><th scope="col">Ações</th></tr></thead><tbody id="lista-alunos"></tbody></table></div>
<div id="lista-vazia" class="vazio" hidden><h3>Nenhum aluno encontrado</h3><p>Altere a busca ou cadastre um novo aluno.</p><button id="limpar-filtros" type="button" class="botao secundario">Limpar filtros</button></div>
</section>
<p class="rodape">PowerFit Academia · Gestão de alunos</p>
</main>
<dialog id="dialogo-aluno" aria-labelledby="titulo-formulario">
<form id="formulario-aluno">
<div class="topo-dialogo"><div><p class="etiqueta">CADASTRO</p><h2 id="titulo-formulario">Cadastrar aluno</h2></div><button class="fechar" type="button" data-fechar aria-label="Fechar cadastro">×</button></div>
<p class="ajuda">Preencha os dados do aluno. Todos os campos são obrigatórios.</p>
<input type="hidden" name="id">
<label>Nome completo<input name="nome" autocomplete="name" minlength="2" maxlength="120" required></label>
<label>E-mail<input name="email" type="email" autocomplete="email" maxlength="120" required></label>
<div class="campos-duplos"><label>Telefone<input name="telefone" type="tel" autocomplete="tel" placeholder="(11) 99999-9999" maxlength="20" aria-describedby="ajuda-telefone" required><small id="ajuda-telefone">Informe o DDD e o número.</small></label>
<label>Plano<select name="plano" required><option value="">Selecione</option><option>Mensal</option><option>Trimestral</option><option>Semestral</option><option>Anual</option></select></label></div>
<p id="erro-formulario" class="erro" role="alert"></p>
<div class="acoes-dialogo"><button type="button" class="botao secundario" data-fechar>Cancelar</button><button type="submit" class="botao principal" id="salvar-aluno">Cadastrar aluno</button></div>
</form>
</dialog>
<dialog id="dialogo-excluir" aria-labelledby="titulo-excluir" aria-describedby="descricao-excluir">
<div class="topo-dialogo"><h2 id="titulo-excluir">Excluir cadastro?</h2><button type="button" class="fechar" data-fechar aria-label="Fechar confirmação">×</button></div>
<p id="descricao-excluir"></p><p class="ajuda">O aluno será removido da lista desta prévia.</p>
<div class="acoes-dialogo"><button type="button" class="botao secundario" data-fechar autofocus>Cancelar</button><button type="button" class="botao perigo" id="confirmar-exclusao">Excluir aluno</button></div>
</dialog>
</body>
</html>
