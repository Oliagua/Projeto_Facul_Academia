// Detalhes de cada modalidade e seleção de plano.
document.addEventListener('DOMContentLoaded', function () {
  const descricoes = [
    'Treino com pesos livres e aparelhos. Cargas e exercícios são adaptados ao seu nível com orientação dos professores.',
    'Movimentos que combinam força, equilíbrio e coordenação, com opções para iniciantes.',
    'Circuitos com cordas, pesos e exercícios com o próprio corpo. A intensidade é ajustada ao seu condicionamento.',
    'Ciclismo indoor com música e variações de ritmo. Cada aluno regula a resistência da bicicleta.',
    'Movimentos controlados para trabalhar flexibilidade e mobilidade.',
    'Acompanhamento individual com planejamento específico. Serviço contratado separadamente: consulte disponibilidade e valores.'
  ];
  const dialogo = document.querySelector('#detalhes-modalidade');
  if (dialogo) {
    document.querySelectorAll('.modalities article').forEach(function (card, indice) {
      card.querySelector('a').addEventListener('click', function (evento) {
        evento.preventDefault();
        dialogo.querySelector('h2').textContent = card.querySelector('h3').textContent;
        dialogo.querySelector('.descricao-modalidade').textContent = descricoes[indice];
        dialogo.showModal();
      });
    });
    dialogo.querySelector('button').onclick = function () { dialogo.close(); };
    dialogo.querySelector('a').onclick = function () { dialogo.close(); };
  }
  document.querySelectorAll('.plans article').forEach(function (card) {
    card.querySelector('a').addEventListener('click', function () {
      document.querySelector('textarea').value = 'Olá! Gostaria de saber mais sobre o ' + card.querySelector('h3').textContent + '.';
    });
  });
  const menu = document.querySelector('.menu-btn');
  if (menu) {
    menu.setAttribute('aria-expanded', 'false');
    menu.addEventListener('click', function () { menu.setAttribute('aria-expanded', String(document.querySelector('nav').classList.contains('open'))); });
    document.querySelectorAll('nav a').forEach(function (link) {
      link.addEventListener('click', function () { menu.setAttribute('aria-expanded', 'false'); });
    });
    document.addEventListener('keydown', function (evento) {
      if (evento.key === 'Escape') { document.querySelector('nav').classList.remove('open'); menu.setAttribute('aria-expanded', 'false'); }
    });
  }
  const mostrar = document.querySelector('#mostrar-senha');
  if (mostrar) mostrar.onclick = function () {
    const campo = document.querySelector('#login-senha');
    campo.type = campo.type === 'password' ? 'text' : 'password';
    mostrar.textContent = campo.type === 'password' ? 'Mostrar senha' : 'Ocultar senha';
  };
  const recuperar = document.querySelector('#recuperar-senha');
  if (recuperar) recuperar.onclick = function (evento) {
    evento.preventDefault();
    document.querySelector('#login-msg').textContent = 'A recuperação estará disponível após a integração do cadastro. Nenhum e-mail foi enviado.';
  };
  const estado = new URLSearchParams(location.search).get('contato');
  const aviso = document.querySelector('#form-msg');
  if (aviso && estado) aviso.textContent = estado === 'validado'
    ? 'Dados validados pelo servidor. Esta demonstração não envia nem armazena mensagens.'
    : 'Confira os campos e tente novamente. Nenhum dado foi salvo.';
});
