/* Projeto Fênix Estoque — V4.8
   Extensão da V4.7 para consultar as vendas oficiais do dia no Supabase.
   A V4.7 permanece preservada no histórico do GitHub. */

(function iniciarVendasDiaV48() {
  function escaparHtml(valor) {
    return String(valor ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#039;");
  }

  function formatarHorarioSaoPaulo(dataHora) {
    if (!dataHora) return "—";
    const data = new Date(dataHora);
    if (Number.isNaN(data.getTime())) return "—";
    return new Intl.DateTimeFormat("pt-BR", {
      timeZone: "America/Sao_Paulo",
      hour: "2-digit",
      minute: "2-digit",
      hour12: false
    }).format(data);
  }

  function rotuloTipo(tipo) {
    return tipo === "correcao" ? "Correção" : "Venda";
  }

  function criarInterface() {
    const grade = document.querySelector(".grid-actions");
    const principal = document.querySelector("main");
    if (!grade || !principal || document.querySelector('[data-nav="sales-day"]')) return;

    const botao = document.createElement("button");
    botao.className = "action-card";
    botao.dataset.nav = "sales-day";
    botao.innerHTML = "<strong>Vendas do dia</strong><span>Consultar vendas oficiais do Supabase</span>";
    grade.insertBefore(botao, grade.querySelector('[data-nav="log"]'));

    const secao = document.createElement("section");
    secao.id = "screen-sales-day";
    secao.className = "screen";
    secao.innerHTML = `
      <div class="screen-title">
        <button class="back-button" data-nav="dashboard">←</button>
        <div>
          <p class="eyebrow">Consulta oficial</p>
          <h2>Vendas do dia</h2>
        </div>
      </div>
      <div class="card">
        <p class="muted">Os dados abaixo são lidos diretamente do Supabase conforme a data operacional selecionada.</p>
        <button id="querySalesDayButton" class="primary-button">Consultar vendas oficiais</button>
      </div>
      <div class="card">
        <h3 id="salesDayTitle">Resultado</h3>
        <div id="salesDaySummary"><p class="muted">Clique em consultar.</p></div>
        <div id="salesDayList"><p class="muted">Nenhuma consulta realizada.</p></div>
      </div>`;
    principal.appendChild(secao);
  }

  function renderizarVendas(vendas) {
    const lista = document.querySelector("#salesDayList");
    const resumo = document.querySelector("#salesDaySummary");
    const titulo = document.querySelector("#salesDayTitle");
    if (!lista || !resumo || !titulo) return;

    titulo.textContent = `Vendas de ${dataOperacional()}`;

    if (!Array.isArray(vendas) || vendas.length === 0) {
      resumo.innerHTML = '<div class="table-like"><div class="table-row"><strong>Total</strong><span>0 itens</span></div></div>';
      lista.innerHTML = '<p class="muted">Nenhuma venda ativa encontrada para esta data operacional.</p>';
      return;
    }

    const totais = vendas.reduce((acc, item) => {
      acc.liquido += Number(item.quantidade_liquido || 0);
      acc.casco += Number(item.quantidade_casco || 0);
      acc.lancamentos.add(item.lancamento_id);
      return acc;
    }, { liquido: 0, casco: 0, lancamentos: new Set() });

    resumo.innerHTML = `
      <div class="table-like">
        <div class="table-row"><strong>Lançamentos</strong><span>${totais.lancamentos.size}</span></div>
        <div class="table-row"><strong>Produtos vendidos</strong><span>${totais.liquido}</span></div>
        <div class="table-row"><strong>Cascos vendidos</strong><span>${totais.casco}</span></div>
      </div>`;

    lista.innerHTML = vendas.map((item) => {
      const tipo = rotuloTipo(item.tipo_lancamento);
      const tipoClasse = item.tipo_lancamento === "correcao" ? "warn" : "ok";
      const casco = Number(item.quantidade_casco || 0);
      return `
        <div class="card">
          <div class="status-line">
            <strong>${escaparHtml(item.canal_venda || "Canal não informado")}</strong>
            <span class="${tipoClasse}">${tipo}</span>
          </div>
          <div class="status-line"><strong>Horário</strong><span>${formatarHorarioSaoPaulo(item.data_hora)}</span></div>
          <div class="status-line"><strong>Produto</strong><span>${escaparHtml(item.produto_codigo || item.produto_nome)}</span></div>
          <div class="status-line"><strong>Quantidade</strong><span>${Number(item.quantidade_liquido || 0)}</span></div>
          <div class="status-line"><strong>Venda de casco</strong><span>${casco}</span></div>
        </div>`;
    }).join("");
  }

  async function consultarVendasDia() {
    const botao = document.querySelector("#querySalesDayButton");
    if (botao) botao.disabled = true;
    try {
      toast("Consultando vendas oficiais...");
      const client = supabaseClient();
      const { data, error } = await client.rpc("consultar_vendas_dia_mvp", {
        p_data_operacional: dataOperacional()
      });
      if (error) throw error;
      log("Consultar vendas do dia — sucesso", data ?? []);
      renderizarVendas(data ?? []);
      toast("Vendas do dia atualizadas.", "success");
    } catch (err) {
      log("Erro ao consultar vendas do dia", err.message || String(err));
      const lista = document.querySelector("#salesDayList");
      if (lista) lista.innerHTML = `<div class="table-like"><div class="table-row"><strong>Erro</strong><span class="danger">${escaparHtml(err.message || String(err))}</span></div></div>`;
      toast(err.message || "Erro ao consultar vendas do dia", "error");
    } finally {
      if (botao) botao.disabled = false;
    }
  }

  function ligarEventosV48() {
    document.querySelectorAll('[data-nav="sales-day"]').forEach((botao) => {
      botao.addEventListener("click", () => navegar("sales-day"));
    });
    document.querySelectorAll('#screen-sales-day [data-nav="dashboard"]').forEach((botao) => {
      botao.addEventListener("click", () => navegar("dashboard"));
    });
    document.querySelector("#querySalesDayButton")?.addEventListener("click", consultarVendasDia);
    document.querySelector("#operationDate")?.addEventListener("change", () => {
      const lista = document.querySelector("#salesDayList");
      const resumo = document.querySelector("#salesDaySummary");
      if (lista) lista.innerHTML = '<p class="muted">Clique em consultar para carregar a nova data.</p>';
      if (resumo) resumo.innerHTML = '<p class="muted">Aguardando consulta.</p>';
    });
  }

  function iniciar() {
    criarInterface();
    ligarEventosV48();
    log("V4.8 carregada", "Tela Vendas do dia conectada à função consultar_vendas_dia_mvp.");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", iniciar);
  } else {
    iniciar();
  }
})();
