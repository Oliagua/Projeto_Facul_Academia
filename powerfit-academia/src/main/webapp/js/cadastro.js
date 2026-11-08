// Validação do formulário de cadastro (o servidor valida de novo).
document.addEventListener('DOMContentLoaded', function () {
  var form = document.querySelector('#form-cadastro');
  if (!form) return;
  var msg = document.querySelector('#cadastro-msg');
  var senha = document.querySelector('#cad-senha');
  var confirmar = document.querySelector('#cad-confirmar');
  var mostrar = document.querySelector('#cad-mostrar');

  var erros = {
    dados: 'Confira nome, e-mail, telefone com DDD, plano e senha, e tente novamente.',
    senha: 'As senhas não conferem.',
    email: 'Este e-mail já está cadastrado. Tente entrar.',
    servidor: 'Não foi possível concluir o cadastro agora. Tente novamente em instantes.'
  };
  var codigo = new URLSearchParams(location.search).get('erro');
  if (codigo && erros[codigo]) msg.textContent = erros[codigo];

  mostrar.addEventListener('click', function () {
    var oculto = senha.type === 'password';
    senha.type = confirmar.type = oculto ? 'text' : 'password';
    mostrar.textContent = oculto ? 'Ocultar senha' : 'Mostrar senha';
  });

  form.addEventListener('submit', function (e) {
    var nome = form.elements.nome.value.trim();
    var email = form.elements.email.value.trim();
    var telefone = form.elements.telefone.value.replace(/\D/g, '');
    var problema = '';
    if (nome.length < 2) problema = 'Informe seu nome completo.';
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) problema = 'Informe um e-mail válido.';
    else if (!/^\d{10,11}$/.test(telefone)) problema = 'Informe o telefone com DDD (10 ou 11 números).';
    else if (!form.elements.plano.value) problema = 'Escolha um plano.';
    else if (senha.value.length < 8) problema = 'A senha precisa ter pelo menos 8 caracteres.';
    else if (senha.value !== confirmar.value) problema = erros.senha;
    if (problema) { e.preventDefault(); msg.textContent = problema; }
  });
});
