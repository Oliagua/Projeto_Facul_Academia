// Prévia de interface: substituir esta lista por dados do Servlet na integração.
(function () {
  let alunos = [
    { id: 1, nome: 'Fernanda Lima', email: 'fernanda@example.com', telefone: '(11) 99999-1001', plano: 'Anual' },
    { id: 2, nome: 'André Silva', email: 'andre@example.com', telefone: '(11) 99999-1002', plano: 'Mensal' },
    { id: 3, nome: 'Juliana Reis', email: 'juliana@example.com', telefone: '(11) 99999-1003', plano: 'Semestral' },
    { id: 4, nome: 'Bruno Almeida', email: 'bruno@example.com', telefone: '(11) 99999-1004', plano: 'Trimestral' }
  ];
  let proximoId = 5;
  let idExclusao = null;
  const lista = document.querySelector('#lista-alunos');
  const busca = document.querySelector('#busca');
  const filtro = document.querySelector('#filtro-plano');
  const formulario = document.querySelector('#formulario-aluno');
  const dialogo = document.querySelector('#dialogo-aluno');
  const exclusao = document.querySelector('#dialogo-excluir');
  const resultado = document.querySelector('#resultado-acao');
  const erro = document.querySelector('#erro-formulario');

  function normalizar(texto) {
    return texto.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
  }

  function elemento(tag, classe, texto) {
    const item = document.createElement(tag);
    item.className = classe;
    item.textContent = texto;
    return item;
  }

  function renderizar() {
    const termo = normalizar(busca.value.trim());
    const encontrados = alunos.filter(function (aluno) {
      const texto = normalizar(aluno.nome + ' ' + aluno.email + ' ' + aluno.telefone);
      const numero = termo.replace(/\D/g, '');
      const telefoneEncontrado = numero.length >= 3 && /^[\d\s()+-]+$/.test(termo)
        && aluno.telefone.replace(/\D/g, '').includes(numero);
      return (texto.includes(termo) || telefoneEncontrado) && (!filtro.value || aluno.plano === filtro.value);
    });
    lista.replaceChildren();
    encontrados.forEach(function (aluno) {
      const linha = document.createElement('tr');
      const nome = document.createElement('td');
      nome.append(elemento('span', 'nome-aluno', aluno.nome), elemento('span', 'numero-aluno', '#' + aluno.id));
      const contato = document.createElement('td');
      contato.append(elemento('span', 'email', aluno.email), elemento('span', 'telefone', aluno.telefone));
      const plano = document.createElement('td');
      plano.append(elemento('span', 'plano' + (aluno.plano === 'Anual' ? ' anual' : ''), aluno.plano));
      const acoes = document.createElement('td');
      const grupo = elemento('div', 'acoes', '');
      const editar = elemento('button', '', 'Editar');
      editar.type = 'button';
      editar.setAttribute('aria-label', 'Editar ' + aluno.nome);
      editar.onclick = function () { abrirFormulario(aluno); };
      const excluir = elemento('button', 'excluir', 'Excluir');
      excluir.type = 'button';
      excluir.setAttribute('aria-label', 'Excluir ' + aluno.nome);
      excluir.onclick = function () {
        idExclusao = aluno.id;
        document.querySelector('#descricao-excluir').textContent = 'Deseja excluir o cadastro de ' + aluno.nome + '?';
        exclusao.showModal();
      };
      grupo.append(editar, excluir);
      acoes.append(grupo);
      linha.append(nome, contato, plano, acoes);
      lista.append(linha);
    });
    document.querySelector('#total-alunos').textContent = alunos.length;
    const anuais = alunos.filter(function (aluno) { return aluno.plano === 'Anual'; }).length;
    document.querySelector('#total-anual').textContent = anuais;
    document.querySelector('#total-outros').textContent = alunos.length - anuais;
    document.querySelector('#contagem').textContent = encontrados.length + ' de ' + alunos.length + ' cadastros';
    document.querySelector('#lista-vazia').hidden = encontrados.length > 0;
  }

  function abrirFormulario(aluno) {
    formulario.reset();
    erro.textContent = '';
    formulario.elements.id.value = aluno ? aluno.id : '';
    ['nome', 'email', 'telefone', 'plano'].forEach(function (campo) {
      formulario.elements[campo].value = aluno ? aluno[campo] : '';
      formulario.elements[campo].setCustomValidity('');
    });
    document.querySelector('#titulo-formulario').textContent = aluno ? 'Editar aluno' : 'Cadastrar aluno';
    document.querySelector('#salvar-aluno').textContent = aluno ? 'Salvar alterações' : 'Cadastrar aluno';
    dialogo.showModal();
    formulario.elements.nome.focus();
  }

  function limparFiltros() {
    busca.value = '';
    filtro.value = '';
  }

  formulario.addEventListener('input', function (evento) {
    evento.target.setCustomValidity('');
    erro.textContent = '';
  });
  formulario.addEventListener('submit', function (evento) {
    evento.preventDefault();
    const id = Number(formulario.elements.id.value);
    const nome = formulario.elements.nome.value.trim();
    const email = formulario.elements.email.value.trim().toLowerCase();
    const telefone = formulario.elements.telefone.value.trim();
    const plano = formulario.elements.plano.value;
    let campoInvalido = null;
    let mensagem = '';
    if (nome.length < 2) {
      campoInvalido = formulario.elements.nome;
      mensagem = 'Informe um nome com pelo menos dois caracteres.';
    } else if (!/^\d{10,11}$/.test(telefone.replace(/\D/g, ''))) {
      campoInvalido = formulario.elements.telefone;
      mensagem = 'Informe um telefone com DDD e 10 ou 11 números.';
    } else if (alunos.some(function (aluno) { return aluno.email.toLowerCase() === email && aluno.id !== id; })) {
      campoInvalido = formulario.elements.email;
      mensagem = 'Este e-mail já está cadastrado em outro aluno.';
    }
    if (campoInvalido) {
      erro.textContent = mensagem;
      campoInvalido.setCustomValidity(mensagem);
      campoInvalido.reportValidity();
      return;
    }
    const aluno = { id: id || proximoId++, nome: nome, email: email, telefone: telefone, plano: plano };
    if (id) alunos = alunos.map(function (item) { return item.id === id ? aluno : item; });
    else alunos.push(aluno);
    dialogo.close();
    limparFiltros();
    renderizar();
    resultado.textContent = nome + (id ? ': alterações salvas nesta prévia.' : ': cadastro adicionado nesta prévia.');
    document.querySelector('#novo-aluno').focus();
  });

  document.querySelector('#confirmar-exclusao').onclick = function () {
    const aluno = alunos.find(function (item) { return item.id === idExclusao; });
    if (!aluno) return;
    alunos = alunos.filter(function (item) { return item.id !== idExclusao; });
    exclusao.close();
    renderizar();
    resultado.textContent = aluno.nome + ': cadastro excluído desta prévia.';
    busca.focus();
  };
  exclusao.addEventListener('close', function () { idExclusao = null; });
  document.querySelectorAll('[data-fechar]').forEach(function (botao) {
    botao.onclick = function () { botao.closest('dialog').close(); };
  });
  document.querySelector('#novo-aluno').onclick = function () { abrirFormulario(null); };
  document.querySelector('#limpar-filtros').onclick = function () { limparFiltros(); renderizar(); busca.focus(); };
  busca.addEventListener('input', renderizar);
  filtro.addEventListener('change', renderizar);
  renderizar();
})();
