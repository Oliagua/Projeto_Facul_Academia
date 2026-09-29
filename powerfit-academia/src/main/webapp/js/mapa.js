// Projeção usada pelos mapas de ruas: coordenadas para pixels.
(function () {
  const mapa = document.querySelector('#mapa');
  if (!mapa) return;
  const camada = mapa.querySelector('.mapa-imagens');
  const aviso = document.querySelector('#mapa-status');
  const ampliar = document.querySelector('#mapa-ampliar');
  const reduzir = document.querySelector('#mapa-reduzir');
  let zoom = 14;
  let centroX;
  let centroY;
  let arraste = null;
  let ativo = false;
  let quadro = null;

  function centralizar() {
    zoom = 14;
    const tamanho = 256 * Math.pow(2, zoom);
    const seno = Math.sin(-23.5500 * Math.PI / 180);
    centroX = (-46.6345 + 180) / 360 * tamanho;
    centroY = (0.5 - Math.log((1 + seno) / (1 - seno)) / (4 * Math.PI)) * tamanho;
    desenhar();
  }

  function desenhar() {
    if (!ativo) return;
    const quantidade = Math.pow(2, zoom);
    const tamanho = quantidade * 256;
    centroX = ((centroX % tamanho) + tamanho) % tamanho;
    centroY = Math.max(mapa.clientHeight / 2, Math.min(tamanho - mapa.clientHeight / 2, centroY));
    const esquerda = centroX - mapa.clientWidth / 2;
    const topo = centroY - mapa.clientHeight / 2;
    const visiveis = new Set();
    for (let x = Math.floor(esquerda / 256); x <= Math.floor((esquerda + mapa.clientWidth) / 256); x++) {
      for (let y = Math.floor(topo / 256); y <= Math.floor((topo + mapa.clientHeight) / 256); y++) {
        if (y < 0 || y >= quantidade) continue;
        const chave = zoom + '-' + x + '-' + y;
        visiveis.add(chave);
        let imagem = camada.querySelector('[data-chave="' + chave + '"]');
        if (!imagem) {
          imagem = document.createElement('img');
          imagem.alt = '';
          imagem.draggable = false;
          imagem.dataset.chave = chave;
          imagem.onload = function () { if (imagem.isConnected) atualizarAviso(); };
          imagem.onerror = function () { if (imagem.isConnected) atualizarAviso(); };
          const coluna = ((x % quantidade) + quantidade) % quantidade;
          imagem.src = mapa.dataset.tiles.replace('{z}', zoom).replace('{x}', coluna).replace('{y}', y);
          camada.appendChild(imagem);
        }
        imagem.style.left = Math.round(x * 256 - esquerda) + 'px';
        imagem.style.top = Math.round(y * 256 - topo) + 'px';
      }
    }
    camada.querySelectorAll('img').forEach(function (imagem) {
      if (!visiveis.has(imagem.dataset.chave)) imagem.remove();
    });
    ampliar.disabled = zoom >= 18;
    reduzir.disabled = zoom <= 3;
    atualizarAviso();
  }

  function atualizarAviso() {
    const imagens = Array.from(camada.querySelectorAll('img'));
    const completas = imagens.length > 0 && imagens.every(function (img) { return img.complete && img.naturalWidth > 0; });
    const falha = imagens.some(function (img) { return img.complete && img.naturalWidth === 0; });
    aviso.hidden = completas;
    aviso.textContent = falha ? 'Não foi possível carregar o mapa. Confira sua conexão ou abra o link abaixo.' : 'Carregando mapa…';
  }

  function mudarZoom(diferenca) {
    const proximo = Math.max(3, Math.min(18, zoom + diferenca));
    const escala = Math.pow(2, proximo - zoom);
    centroX *= escala;
    centroY *= escala;
    zoom = proximo;
    desenhar();
  }
  ampliar.onclick = function () { mudarZoom(1); };
  reduzir.onclick = function () { mudarZoom(-1); };
  document.querySelector('#mapa-centralizar').onclick = centralizar;
  mapa.addEventListener('pointerdown', function (evento) {
    if (evento.target.closest('button, a') || evento.button !== 0) return;
    arraste = { x: evento.clientX, y: evento.clientY, centroX: centroX, centroY: centroY };
    mapa.setPointerCapture(evento.pointerId);
    mapa.focus({ preventScroll: true });
  });
  mapa.addEventListener('pointermove', function (evento) {
    if (!arraste) return;
    centroX = arraste.centroX - (evento.clientX - arraste.x);
    centroY = arraste.centroY - (evento.clientY - arraste.y);
    if (!quadro) quadro = requestAnimationFrame(function () { quadro = null; desenhar(); });
  });
  mapa.addEventListener('lostpointercapture', function () { arraste = null; });
  mapa.addEventListener('pointerup', function () { arraste = null; });
  mapa.addEventListener('pointercancel', function () { arraste = null; });
  mapa.addEventListener('keydown', function (evento) {
    if (evento.target !== mapa) return;
    const passos = { ArrowLeft: [-80, 0], ArrowRight: [80, 0], ArrowUp: [0, -80], ArrowDown: [0, 80] };
    if (!passos[evento.key]) return;
    evento.preventDefault();
    centroX += passos[evento.key][0];
    centroY += passos[evento.key][1];
    desenhar();
  });
  new ResizeObserver(desenhar).observe(mapa);
  centralizar();
  // Carrega apenas a área que o visitante está vendo.
  const observador = new IntersectionObserver(function (entradas) {
    if (entradas[0].isIntersecting) { ativo = true; desenhar(); observador.disconnect(); }
  });
  observador.observe(mapa);
})();
