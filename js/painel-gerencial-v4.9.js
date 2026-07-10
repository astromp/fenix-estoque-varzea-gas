/* Projeto Fênix Estoque — V4.9
   Painel gerencial baseado nas vendas oficiais do Supabase.
   A V4.8 permanece congelada e preservada. */

(function iniciarPainelGerencialV49() {
  function escaparHtml(valor) {
    return String(valor ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#039;");
  }

  function isoLocal(data) {
    const offset = data.getTimezoneOffset();
    return new Date(data.getTime() - offset * 60000).toISOString().slice(0, 10);
  }

  function adicionarDias(dataIso, dias) {
    const data = new Date(`${dataIso}T12:00:00`);
    data.setDate(data.getDate() + dias);
    return isoLocal(data);
  }

  function intervaloDatas(inicio, fim) {
    const datas = [];
    let atual = inicio;
    let seguranca = 0;
    while (atual <= fim && seguranca < 370) {
      datas.push(atual);
      atual = adicionarDias(atual, 1);
      seguranca += 1;
    }
    return datas;
  }

  function formatarData(dataIso) {
    if (!dataIso) return "—";
    const [ano, mes, dia] = dataIso.split("-");
    return `${dia}/${mes}/${ano}`;
  }

  function criarInterface() {
    const grade = document.querySelector(".grid-actions");
    const principal = document.querySelector("main");
    if (!grade || !principal || document.querySelector('[data-nav="manager"]')) return;

    const botao = document.createElement("button");
    botao.className = "action-card";
    botao.dataset.nav = "manager";
    botao.innerHTML = "<strong>Painel gerencial</strong><span>Resumo por canal, produto e período</span>";
    grade.insertBefore(botao, grade.querySelector('[data-nav="log"]'));

    const secao = document.createElement("section");
    secao.id = "screen-manager";
    secao.className = "screen";
    secao.innerHTML = `
      <div class="screen-title">
        <button class="back-button" data-nav="dashboard">←</button>
        <div>
          <p class="eyebrow">Gestão</p>
          <h2>Painel gerencial</h2>
        </div>
      </div>

      <div class="card">
        <p class="muted">Consulte vendas oficiais por dia ou período. Os totais são agrupados por canal e produto.</p>
        <div class="two-cols">
          <div>
            <label for="managerStartDate">Data inicial</label>
            <input id="managerStartDate" type="date" />
          </div>
          <div>
            <label for="managerEndDate">Data final</label>
            <input id="managerEndDate" type="date" />
          </div>
        </div>
        <div class="two-cols">
          <button id="managerTodayButton" class="ghost-button">Dia selecionado</button>
          <button id="managerWeekButton" class="ghost-button">Últimos 7 dias</button>
        </div>
        <button id="managerQueryButton" class="primary-button">Consultar painel</button>
      </div>

      <div class="card">
        <h3 id="managerTitle">Resumo do período</h3>
        <div id="managerTotals"><p class="muted">Clique em consultar.</p></div>
      </div>

      <div class="card">
        <h3>Resumo por canal</h3>
        <div id="managerChannels"><p class="muted">Aguardando consulta.</p></div>
      </div>

      <div class="card">
        <h3>Resumo por produto</h3>
        <div id="managerProducts"><p class="muted">Aguardando consulta.</p></div>
      </div>`;

    principal.appendChild(secao);
  }

  function agrupar(vendas, campo) {
    const grupos = new Map();
    vendas.forEach((item) => {
      const chave = item[campo] || "Não informado";
      const atual = grupos.get(chave) || { liquido: 0, casco: 0, lancamentos: new Set() };
      atual.liquido += Number(item.quantidade_liquido || 0);
      atual.casco += Number(item.quantidade_casco || 0);
      if (item.lancamento_id) atual.lancamentos.add(item.lancamento_id);
      grupos.set(chave, atual);
    });
    return [...grupos.entries()].sort((a, b) => b[1].liquido - a[1].liquido);
  }

  function tabelaAgrupada(grupos) {
    if (!grupos.length) return '<p class="muted">Nenhuma venda ativa encontrada.</p>';
    return `<div class="table-like">${grupos.map(([nome, dados]) => `
      <div class="table-row">
        <strong>${escaparHtml(nome)}</strong>
        <span>${dados.liquido} vendidos · ${dados.casco} cascos</span>
      </div>`).join("")}</div>`;
  }

  function renderizar(vendas, inicio, fim) {
    const totaisEl = document.querySelector("#managerTotals");
    const canaisEl = document.querySelector("#managerChannels");
    const produtosEl = document.querySelector("#managerProducts");
    const tituloEl = document.querySelector("#managerTitle");
    if (!totaisEl || !canaisEl || !produtosEl || !tituloEl) return;

    const lancamentos = new Set();
    let liquido = 0;
    let casco = 0;
    let correcoes = 0;

    vendas.forEach((item) => {
      liquido += Number(item.quantidade_liquido || 0);
      casco += Number(item.quantidade_casco || 0);
      if (item.lancamento_id) lancamentos.add(item.lancamento_id);
      if (item.tipo_lancamento === "correcao") correcoes += 1;
    });

    tituloEl.textContent = inicio === fim
      ? `Resumo de ${formatarData(inicio)}`
      : `Resumo de ${formatarData(inicio)} a ${formatarData(fim)}`;

    totaisEl.innerHTML = `
      <div class="table-like">
        <div class="table-row"><strong>Lançamentos</strong><span>${lancamentos.size}</span></div>
        <div class="table-row"><strong>Produtos vendidos</strong><span>${liquido}</span></div>
        <div class="table-row"><strong>Cascos vendidos</strong><span>${casco}</span></div>
        <div class="table-row"><strong>Linhas de correção</strong><span>${correcoes}</span></div>
      </div>`;

    canaisEl.innerHTML = tabelaAgrupada(agrupar(vendas, "canal_venda"));
    produtosEl.innerHTML = tabelaAgrupada(agrupar(vendas, "produto_codigo"));
  }

  async function consultarPainel() {
    const inicioEl = document.querySelector("#managerStartDate");
    const fimEl = document.querySelector("#managerEndDate");
    const botao = document.querySelector("#managerQueryButton");
    const inicio = inicioEl?.value;
    const fim = fimEl?.value;

    if (!inicio || !fim) {
      toast("Informe a data inicial e final.", "error");
      return;
    }
    if (inicio > fim) {
      toast("A data inicial não pode ser posterior à final.", "error");
      return;
    }

    const datas = intervaloDatas(inicio, fim);
    if (datas.length > 93) {
      toast("Nesta homologação, consulte no máximo 93 dias por vez.", "error");
      return;
    }

    if (botao) botao.disabled = true;
    try {
      toast(`Consultando ${datas.length} dia(s)...`);
      const client = supabaseClient();
      const resultados = await Promise.all(datas.map(async (data) => {
        const { data: vendas, error } = await client.rpc("consultar_vendas_dia_mvp", {
          p_data_operacional: data
        });
        if (error) throw error;
        return vendas || [];
      }));

      const vendas = resultados.flat();
      renderizar(vendas, inicio, fim);
      log("Painel gerencial V4.9 — sucesso", {
        inicio,
        fim,
        dias_consultados: datas.length,
        linhas_retornadas: vendas.length
      });
      toast("Painel gerencial atualizado.", "success");
    } catch (err) {
      log("Erro no painel gerencial V4.9", err.message || String(err));
      toast(err.message || "Erro ao consultar painel.", "error");
    } finally {
      if (botao) botao.disabled = false;
    }
  }

  function preencherDiaSelecionado() {
    const data = dataOperacional();
    document.querySelector("#managerStartDate").value = data;
    document.querySelector("#managerEndDate").value = data;
  }

  function preencherSemana() {
    const fim = dataOperacional();
    document.querySelector("#managerEndDate").value = fim;
    document.querySelector("#managerStartDate").value = adicionarDias(fim, -6);
  }

  function ligarEventos() {
    document.querySelectorAll('[data-nav="manager"]').forEach((botao) => {
      botao.addEventListener("click", () => {
        preencherDiaSelecionado();
        navegar("manager");
      });
    });
    document.querySelectorAll('#screen-manager [data-nav="dashboard"]').forEach((botao) => {
      botao.addEventListener("click", () => navegar("dashboard"));
    });
    document.querySelector("#managerTodayButton")?.addEventListener("click", preencherDiaSelecionado);
    document.querySelector("#managerWeekButton")?.addEventListener("click", preencherSemana);
    document.querySelector("#managerQueryButton")?.addEventListener("click", consultarPainel);
  }

  function iniciar() {
    criarInterface();
    preencherDiaSelecionado();
    ligarEventos();
    log("V4.9 carregada", "Painel gerencial por canal, produto e período disponível para homologação.");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", iniciar);
  } else {
    iniciar();
  }
})();
