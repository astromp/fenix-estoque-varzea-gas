/* Projeto Fênix Estoque — V5.1
   Comparação gerencial entre dois períodos.
   A V5.0 permanece congelada e preservada. */

(function iniciarComparacaoV51() {
  const estadoV51 = { periodoA: [], periodoB: [] };

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

  function escaparHtml(valor) {
    return String(valor ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#039;");
  }

  function criarInterface() {
    const grade = document.querySelector(".grid-actions");
    const principal = document.querySelector("main");
    if (!grade || !principal || document.querySelector('[data-nav="comparison"]')) return;

    const botao = document.createElement("button");
    botao.className = "action-card";
    botao.dataset.nav = "comparison";
    botao.innerHTML = "<strong>Comparar períodos</strong><span>Variação de vendas e cascos</span>";
    grade.insertBefore(botao, grade.querySelector('[data-nav="log"]'));

    const secao = document.createElement("section");
    secao.id = "screen-comparison";
    secao.className = "screen";
    secao.innerHTML = `
      <div class="screen-title">
        <button class="back-button" data-nav="dashboard">←</button>
        <div>
          <p class="eyebrow">Gestão V5.1</p>
          <h2>Comparação entre períodos</h2>
        </div>
      </div>

      <div class="card">
        <h3>Período A</h3>
        <div class="two-cols">
          <div><label>Data inicial</label><input id="comparisonAStart" type="date" /></div>
          <div><label>Data final</label><input id="comparisonAEnd" type="date" /></div>
        </div>
      </div>

      <div class="card">
        <h3>Período B</h3>
        <div class="two-cols">
          <div><label>Data inicial</label><input id="comparisonBStart" type="date" /></div>
          <div><label>Data final</label><input id="comparisonBEnd" type="date" /></div>
        </div>
        <button id="comparisonPresetButton" class="ghost-button">Comparar dia selecionado com o dia anterior</button>
        <button id="comparisonQueryButton" class="primary-button">Comparar períodos</button>
      </div>

      <div class="card" id="comparisonPrintableArea">
        <p class="eyebrow">Projeto Fênix Estoque — ${escaparHtml(typeof revendaNome === "function" ? revendaNome() : "Revenda")}</p>
        <h3 id="comparisonTitle">Resultado da comparação</h3>
        <div id="comparisonTotals"><p class="muted">Clique em comparar.</p></div>
        <h3 style="margin-top:18px">Comparação por canal</h3>
        <div id="comparisonChannels"><p class="muted">Aguardando consulta.</p></div>
        <h3 style="margin-top:18px">Comparação por produto</h3>
        <div id="comparisonProducts"><p class="muted">Aguardando consulta.</p></div>
      </div>

      <div class="card">
        <button id="comparisonPrintButton" class="ghost-button" disabled>Imprimir relatório gerencial</button>
      </div>`;

    principal.appendChild(secao);
  }

  function resumir(vendas) {
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
    return { lancamentos: lancamentos.size, liquido, casco, correcoes };
  }

  function agrupar(vendas, campo) {
    const mapa = new Map();
    vendas.forEach((item) => {
      const chave = item[campo] || "Não informado";
      const atual = mapa.get(chave) || { liquido: 0, casco: 0 };
      atual.liquido += Number(item.quantidade_liquido || 0);
      atual.casco += Number(item.quantidade_casco || 0);
      mapa.set(chave, atual);
    });
    return mapa;
  }

  function percentual(a, b) {
    if (a === 0 && b === 0) return "0,0%";
    if (a === 0) return b > 0 ? "+100,0%" : "-100,0%";
    const valor = ((b - a) / Math.abs(a)) * 100;
    return `${valor >= 0 ? "+" : ""}${valor.toFixed(1).replace(".", ",")}%`;
  }

  function classeVariacao(a, b) {
    if (b > a) return "ok";
    if (b < a) return "danger";
    return "warn";
  }

  function linhaComparacao(rotulo, a, b) {
    const diferenca = b - a;
    return `<div class="table-row"><strong>${escaparHtml(rotulo)}</strong><span class="${classeVariacao(a,b)}">A: ${a} · B: ${b} · ${diferenca >= 0 ? "+" : ""}${diferenca} (${percentual(a,b)})</span></div>`;
  }

  function tabelaGrupos(mapaA, mapaB) {
    const nomes = [...new Set([...mapaA.keys(), ...mapaB.keys()])].sort();
    if (!nomes.length) return '<p class="muted">Nenhum dado nos períodos informados.</p>';
    return `<div class="table-like">${nomes.map((nome) => {
      const a = mapaA.get(nome) || { liquido: 0, casco: 0 };
      const b = mapaB.get(nome) || { liquido: 0, casco: 0 };
      return `<div class="card" style="margin-top:8px"><strong>${escaparHtml(nome)}</strong>${linhaComparacao("Produtos", a.liquido, b.liquido)}${linhaComparacao("Cascos", a.casco, b.casco)}</div>`;
    }).join("")}</div>`;
  }

  function renderizar(vendasA, vendasB, aInicio, aFim, bInicio, bFim) {
    const resumoA = resumir(vendasA);
    const resumoB = resumir(vendasB);
    document.querySelector("#comparisonTitle").textContent = `A: ${formatarData(aInicio)} a ${formatarData(aFim)} · B: ${formatarData(bInicio)} a ${formatarData(bFim)}`;
    document.querySelector("#comparisonTotals").innerHTML = `<div class="table-like">
      ${linhaComparacao("Lançamentos", resumoA.lancamentos, resumoB.lancamentos)}
      ${linhaComparacao("Produtos vendidos", resumoA.liquido, resumoB.liquido)}
      ${linhaComparacao("Cascos vendidos", resumoA.casco, resumoB.casco)}
      ${linhaComparacao("Linhas de correção", resumoA.correcoes, resumoB.correcoes)}
    </div>`;
    document.querySelector("#comparisonChannels").innerHTML = tabelaGrupos(agrupar(vendasA, "canal_venda"), agrupar(vendasB, "canal_venda"));
    document.querySelector("#comparisonProducts").innerHTML = tabelaGrupos(agrupar(vendasA, "produto_codigo"), agrupar(vendasB, "produto_codigo"));
    document.querySelector("#comparisonPrintButton").disabled = false;
  }

  async function buscarPeriodo(inicio, fim) {
    const datas = intervaloDatas(inicio, fim);
    if (datas.length > 93) throw new Error("Cada período pode ter no máximo 93 dias nesta homologação.");
    const client = supabaseClient();
    const respostas = await Promise.all(datas.map(async (dataOperacionalItem) => {
      const { data, error } = await client.rpc("consultar_vendas_dia_mvp", { p_data_operacional: dataOperacionalItem });
      if (error) throw error;
      return data || [];
    }));
    return respostas.flat();
  }

  async function comparar() {
    const aInicio = document.querySelector("#comparisonAStart")?.value;
    const aFim = document.querySelector("#comparisonAEnd")?.value;
    const bInicio = document.querySelector("#comparisonBStart")?.value;
    const bFim = document.querySelector("#comparisonBEnd")?.value;
    const botao = document.querySelector("#comparisonQueryButton");

    if (![aInicio,aFim,bInicio,bFim].every(Boolean)) return toast("Informe as quatro datas.", "error");
    if (aInicio > aFim || bInicio > bFim) return toast("Confira as datas iniciais e finais.", "error");

    if (botao) botao.disabled = true;
    try {
      toast("Comparando períodos...");
      const [vendasA, vendasB] = await Promise.all([buscarPeriodo(aInicio,aFim), buscarPeriodo(bInicio,bFim)]);
      estadoV51.periodoA = vendasA;
      estadoV51.periodoB = vendasB;
      renderizar(vendasA, vendasB, aInicio, aFim, bInicio, bFim);
      log("Comparação V5.1 — sucesso", { aInicio,aFim,bInicio,bFim, linhasA:vendasA.length, linhasB:vendasB.length });
      toast("Comparação atualizada.", "success");
    } catch (err) {
      log("Erro na comparação V5.1", err.message || String(err));
      toast(err.message || "Erro ao comparar períodos.", "error");
    } finally {
      if (botao) botao.disabled = false;
    }
  }

  function preencherPreset() {
    const selecionada = dataOperacional();
    const anterior = adicionarDias(selecionada, -1);
    document.querySelector("#comparisonAStart").value = anterior;
    document.querySelector("#comparisonAEnd").value = anterior;
    document.querySelector("#comparisonBStart").value = selecionada;
    document.querySelector("#comparisonBEnd").value = selecionada;
  }

  function imprimir() {
    const area = document.querySelector("#comparisonPrintableArea");
    if (!area) return;
    const janela = window.open("", "_blank");
    if (!janela) return toast("O navegador bloqueou a janela de impressão.", "error");
    janela.document.write(`<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><title>Comparação gerencial</title><style>body{font-family:Arial,sans-serif;padding:24px;color:#172033}.card{margin:12px 0;padding:14px;border:1px solid #d9e1ef;border-radius:12px}.table-row{display:flex;justify-content:space-between;gap:20px;padding:9px 0;border-bottom:1px solid #e8edf5}.ok{color:#157347}.danger{color:#c91f2f}.warn{color:#8a6500}.eyebrow{text-transform:uppercase;font-size:12px;font-weight:bold;color:#687386}@media print{body{padding:0}}</style></head><body>${area.innerHTML}</body></html>`);
    janela.document.close();
    janela.focus();
    janela.print();
  }

  function ligarEventos() {
    document.querySelectorAll('[data-nav="comparison"]').forEach((botao) => botao.addEventListener("click", () => { preencherPreset(); navegar("comparison"); }));
    document.querySelectorAll('#screen-comparison [data-nav="dashboard"]').forEach((botao) => botao.addEventListener("click", () => navegar("dashboard")));
    document.querySelector("#comparisonPresetButton")?.addEventListener("click", preencherPreset);
    document.querySelector("#comparisonQueryButton")?.addEventListener("click", comparar);
    document.querySelector("#comparisonPrintButton")?.addEventListener("click", imprimir);
  }

  function iniciar() {
    criarInterface();
    preencherPreset();
    ligarEventos();
    log("V5.1 carregada", "Comparação entre períodos e impressão gerencial disponíveis para homologação.");
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", iniciar);
  else iniciar();
})();
