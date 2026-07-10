/* Projeto Fênix Estoque — V5.0
   Relatório gerencial com filtros, detalhamento diário e exportação CSV.
   A V4.9 permanece congelada e preservada. */

(function iniciarRelatorioGerencialV50() {
  let dadosBrutos = [];
  let periodoAtual = { inicio: "", fim: "" };

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
    if (!grade || !principal || document.querySelector('[data-nav="report-v50"]')) return;

    const botao = document.createElement("button");
    botao.className = "action-card";
    botao.dataset.nav = "report-v50";
    botao.innerHTML = "<strong>Relatório V5.0</strong><span>Filtros, detalhe diário e exportação CSV</span>";
    grade.insertBefore(botao, grade.querySelector('[data-nav="log"]'));

    const secao = document.createElement("section");
    secao.id = "screen-report-v50";
    secao.className = "screen";
    secao.innerHTML = `
      <div class="screen-title">
        <button class="back-button" data-nav="dashboard">←</button>
        <div><p class="eyebrow">Gestão avançada</p><h2>Relatório V5.0</h2></div>
      </div>

      <div class="card">
        <p class="muted">Consulte um período, filtre por canal e produto e exporte o resultado em CSV.</p>
        <div class="two-cols">
          <div><label for="v50StartDate">Data inicial</label><input id="v50StartDate" type="date" /></div>
          <div><label for="v50EndDate">Data final</label><input id="v50EndDate" type="date" /></div>
        </div>
        <div class="two-cols">
          <div><label for="v50Channel">Canal</label><select id="v50Channel"><option value="">Todos os canais</option></select></div>
          <div><label for="v50Product">Produto</label><select id="v50Product"><option value="">Todos os produtos</option></select></div>
        </div>
        <div class="two-cols">
          <button id="v50SelectedDayButton" class="ghost-button">Dia selecionado</button>
          <button id="v50WeekButton" class="ghost-button">Últimos 7 dias</button>
        </div>
        <button id="v50QueryButton" class="primary-button">Consultar relatório</button>
        <button id="v50ExportButton" class="ghost-button" disabled>Exportar CSV</button>
      </div>

      <div class="card"><h3 id="v50Title">Resumo</h3><div id="v50Totals"><p class="muted">Clique em consultar.</p></div></div>
      <div class="card"><h3>Resumo por canal</h3><div id="v50Channels"><p class="muted">Aguardando consulta.</p></div></div>
      <div class="card"><h3>Resumo por produto</h3><div id="v50Products"><p class="muted">Aguardando consulta.</p></div></div>
      <div class="card"><h3>Detalhamento diário</h3><div id="v50Daily"><p class="muted">Aguardando consulta.</p></div></div>`;
    principal.appendChild(secao);
  }

  function preencherFiltros(vendas) {
    const canalEl = document.querySelector("#v50Channel");
    const produtoEl = document.querySelector("#v50Product");
    const canalAtual = canalEl.value;
    const produtoAtual = produtoEl.value;
    const canais = [...new Set(vendas.map(v => v.canal_venda).filter(Boolean))].sort();
    const produtos = [...new Set(vendas.map(v => v.produto_codigo).filter(Boolean))].sort();
    canalEl.innerHTML = '<option value="">Todos os canais</option>' + canais.map(v => `<option value="${escaparHtml(v)}">${escaparHtml(v)}</option>`).join("");
    produtoEl.innerHTML = '<option value="">Todos os produtos</option>' + produtos.map(v => `<option value="${escaparHtml(v)}">${escaparHtml(v)}</option>`).join("");
    canalEl.value = canais.includes(canalAtual) ? canalAtual : "";
    produtoEl.value = produtos.includes(produtoAtual) ? produtoAtual : "";
  }

  function dadosFiltrados() {
    const canal = document.querySelector("#v50Channel")?.value || "";
    const produto = document.querySelector("#v50Product")?.value || "";
    return dadosBrutos.filter(item => (!canal || item.canal_venda === canal) && (!produto || item.produto_codigo === produto));
  }

  function agrupar(vendas, campo) {
    const grupos = new Map();
    vendas.forEach(item => {
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
    return `<div class="table-like">${grupos.map(([nome, d]) => `<div class="table-row"><strong>${escaparHtml(nome)}</strong><span>${d.liquido} vendidos · ${d.casco} cascos</span></div>`).join("")}</div>`;
  }

  function renderizar() {
    const vendas = dadosFiltrados();
    const lancamentos = new Set();
    let liquido = 0, casco = 0, correcoes = 0;
    vendas.forEach(item => {
      liquido += Number(item.quantidade_liquido || 0);
      casco += Number(item.quantidade_casco || 0);
      if (item.lancamento_id) lancamentos.add(item.lancamento_id);
      if (item.tipo_lancamento === "correcao") correcoes += 1;
    });

    document.querySelector("#v50Title").textContent = periodoAtual.inicio === periodoAtual.fim
      ? `Resumo de ${formatarData(periodoAtual.inicio)}`
      : `Resumo de ${formatarData(periodoAtual.inicio)} a ${formatarData(periodoAtual.fim)}`;
    document.querySelector("#v50Totals").innerHTML = `<div class="table-like">
      <div class="table-row"><strong>Lançamentos</strong><span>${lancamentos.size}</span></div>
      <div class="table-row"><strong>Produtos vendidos</strong><span>${liquido}</span></div>
      <div class="table-row"><strong>Cascos vendidos</strong><span>${casco}</span></div>
      <div class="table-row"><strong>Linhas de correção</strong><span>${correcoes}</span></div>
    </div>`;
    document.querySelector("#v50Channels").innerHTML = tabelaAgrupada(agrupar(vendas, "canal_venda"));
    document.querySelector("#v50Products").innerHTML = tabelaAgrupada(agrupar(vendas, "produto_codigo"));

    const dias = agrupar(vendas, "data_operacional").sort((a, b) => a[0].localeCompare(b[0]));
    document.querySelector("#v50Daily").innerHTML = dias.length
      ? `<div class="table-like">${dias.map(([data, d]) => `<div class="table-row"><strong>${formatarData(data)}</strong><span>${d.liquido} vendidos · ${d.casco} cascos · ${d.lancamentos.size} lançamentos</span></div>`).join("")}</div>`
      : '<p class="muted">Nenhuma venda ativa encontrada.</p>';

    document.querySelector("#v50ExportButton").disabled = vendas.length === 0;
  }

  async function consultar() {
    const inicio = document.querySelector("#v50StartDate")?.value;
    const fim = document.querySelector("#v50EndDate")?.value;
    const botao = document.querySelector("#v50QueryButton");
    if (!inicio || !fim) return toast("Informe a data inicial e final.", "error");
    if (inicio > fim) return toast("A data inicial não pode ser posterior à final.", "error");
    const datas = intervaloDatas(inicio, fim);
    if (datas.length > 93) return toast("Consulte no máximo 93 dias por vez.", "error");

    if (botao) botao.disabled = true;
    try {
      toast(`Consultando ${datas.length} dia(s)...`);
      const client = supabaseClient();
      const resultados = await Promise.all(datas.map(async data => {
        const { data: vendas, error } = await client.rpc("consultar_vendas_dia_mvp", { p_data_operacional: data });
        if (error) throw error;
        return vendas || [];
      }));
      dadosBrutos = resultados.flat();
      periodoAtual = { inicio, fim };
      preencherFiltros(dadosBrutos);
      renderizar();
      log("Relatório V5.0 — sucesso", { inicio, fim, linhas_retornadas: dadosBrutos.length });
      toast("Relatório V5.0 atualizado.", "success");
    } catch (err) {
      log("Erro no relatório V5.0", err.message || String(err));
      toast(err.message || "Erro ao consultar relatório.", "error");
    } finally {
      if (botao) botao.disabled = false;
    }
  }

  function exportarCsv() {
    const vendas = dadosFiltrados();
    if (!vendas.length) return;
    const cabecalho = ["data_operacional","canal_venda","produto_codigo","quantidade_liquido","quantidade_casco","tipo_lancamento","lancamento_id"];
    const linhas = vendas.map(item => cabecalho.map(chave => `"${String(item[chave] ?? "").replaceAll('"','""')}"`).join(";"));
    const csv = "\ufeff" + [cabecalho.join(";"), ...linhas].join("\r\n");
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8" });
    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = `fenix-relatorio-${periodoAtual.inicio}-a-${periodoAtual.fim}.csv`;
    document.body.appendChild(link);
    link.click();
    URL.revokeObjectURL(link.href);
    link.remove();
  }

  function preencherDia() {
    const data = dataOperacional();
    document.querySelector("#v50StartDate").value = data;
    document.querySelector("#v50EndDate").value = data;
  }

  function preencherSemana() {
    const fim = dataOperacional();
    document.querySelector("#v50EndDate").value = fim;
    document.querySelector("#v50StartDate").value = adicionarDias(fim, -6);
  }

  function ligarEventos() {
    document.querySelectorAll('[data-nav="report-v50"]').forEach(botao => botao.addEventListener("click", () => { preencherDia(); navegar("report-v50"); }));
    document.querySelectorAll('#screen-report-v50 [data-nav="dashboard"]').forEach(botao => botao.addEventListener("click", () => navegar("dashboard")));
    document.querySelector("#v50SelectedDayButton")?.addEventListener("click", preencherDia);
    document.querySelector("#v50WeekButton")?.addEventListener("click", preencherSemana);
    document.querySelector("#v50QueryButton")?.addEventListener("click", consultar);
    document.querySelector("#v50Channel")?.addEventListener("change", renderizar);
    document.querySelector("#v50Product")?.addEventListener("change", renderizar);
    document.querySelector("#v50ExportButton")?.addEventListener("click", exportarCsv);
  }

  function iniciar() {
    criarInterface();
    preencherDia();
    ligarEventos();
    log("V5.0 carregada", "Filtros, detalhamento diário e exportação CSV disponíveis para homologação.");
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", iniciar);
  else iniciar();
})();