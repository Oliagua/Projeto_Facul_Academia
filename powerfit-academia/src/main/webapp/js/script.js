document.addEventListener('DOMContentLoaded', () => {
  const menu = document.querySelector('.menu-btn'); const nav = document.querySelector('nav');
  if (menu) menu.addEventListener('click', () => nav.classList.toggle('open'));
  document.querySelectorAll('nav a').forEach(a => a.addEventListener('click', () => nav.classList.remove('open')));
  const form = document.querySelector('#contato-form');
  if (form) form.addEventListener('submit', e => {
    const campos = [...form.querySelectorAll('[required]')]; const msg = document.querySelector('#form-msg');
    if (campos.some(c => !c.value.trim())) { e.preventDefault(); msg.textContent = 'Preencha todos os campos para enviar sua mensagem.'; return; }
    if (!form.email.value.includes('@')) { e.preventDefault(); msg.textContent = 'Informe um e-mail válido.'; return; }
    if (!form.reportValidity() || !/^\d{10,11}$/.test(form.telefone.value.replace(/\D/g, ''))) { e.preventDefault(); msg.textContent = 'Confira o e-mail e informe telefone com DDD (10 ou 11 números).'; }
  });
});
function validarLogin(event) { event.preventDefault(); document.querySelector('#login-msg').textContent = 'Login demonstrativo: a integração será realizada posteriormente.'; return false; }
