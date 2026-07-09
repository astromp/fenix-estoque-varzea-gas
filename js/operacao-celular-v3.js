/* Projeto Fênix Estoque — Operação Celular Integrada V3
   Regra de ouro: estoque fechado, turno encerrado. Estoque inconsistente, revisar até corrigir. */

const FENIX_PRODUTOS = [
  { codigo: "P13", nome: "P13" },
  { codigo: "P05", nome: "P05" },
  { codigo: "P20", nome: "P20" },
  { codigo: "P45", nome: "P45" },
  { codigo: "AGUA", nome: "Água / galão" }
];
const FENIX_CANAIS = ["Portaria", "Rogério", "André", "João", "Outros"];
const FENIX_EXEMPLO_ABERTURA = {
  P13: { cheios: 100, vazios: 30 },
  P05: { cheios: 10, vazios: 5 },
  P20: { cheios: 10, vazios: 2 },
  P45: { cheios: 10, vazios: 10 },
  AGUA: { cheios: 50, vazios: 10 }
};

const estado = { status: "nao_consultado", supabase: null, cascoAtivo: false, ultimoEstoque: null, ultimoFechamento: null };
const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => Array.from(document.querySelectorAll(selector));
const ui = {
  badge: $("#badge"), operationDate: $("#operationDate"), dateTitle: $("#dateTitle"), dashboardText: $("#dashboardText"),
  dayStatusPanel: $("#dayStatusPanel"), refreshStatusButton: $("#refreshStatusButton"),
  openingList: $("#openingList"), fillOpeningButton: $("#fillOpeningButton"), saveOpeningButton: $("#saveOpeningButton"),
  saleChannel: $("#saleChannel"), saleProduct: $("#saleProduct"), saleQty: $("#saleQty"), toggleCascoButton: $("#toggleCascoButton"), cascoField: $("#cascoField"), cascoQty: $("#cascoQty"), quickPortariaButton: $("#quickPortariaButton"), quickJoaoButton: $("#quickJoaoButton"), saveSaleButton: $("#saveSaleButton"),
  queryStockButton: $("#queryStockButton"), stockList: $("#stockList"),
  closingList: $("#closingList"), fillClosingCalculatedButton: $("#fillClosingCalculatedButton"), simulateDivergenceButton: $("#simulateDivergenceButton"), saveClosingButton: $("#saveClosingButton"), closingItems: $("#closingItems"),
  correctionChannel: $("#correctionChannel"), correctionProduct: $("#correctionProduct"), correctionQty: $("#correctionQty"), runCorrectionButton: $("#runCorrectionButton"), correctionResult: $("#correctionResult"),
  clearLogButton: $("#clearLogButton"), logBox: $("#logBox"), toast: $("#toast")
};

function hojeISO() {
  const agora = new Date();
  const offset = agora.getTimezoneOffset();
  return new Date(agora.getTime() - offset * 60000).toISOString().slice(0, 10);
}
function config() { return window.FENIX_CONFIG || {}; }
function revendaCodigo() { return config().REVENDA_CODIGO || "varzea_gas"; }
function revendaNome() { return config().REVENDA_NOME || "Várzea Gás"; }
function dataOperacional() { if (!ui.operationDate.value) ui.operationDate.value = hojeISO(); return ui.operationDate.value; }
function numero(input) { const valor = Number(input?.value || 0); return Number.isFinite(valor) ? valor : 0; }
function configPronta() {
  const cfg = config();
  return Boolean(cfg.SUPABASE_URL && cfg.SUPABASE_ANON_KEY && !cfg.SUPABASE_URL.includes("COLE_AQUI") && !cfg.SUPABASE_ANON_KEY.includes("COLE_AQUI"));
}
function supabaseClient() {
  if (estado.supabase) return estado.supabase;
  if (!window.supabase) throw new Error("Biblioteca do Supabase não carregou. Confira a internet ou o CDN no index.html.");
  if (!configPronta()) throw new Error("Configuração pendente: edite js/config.js com SUPABASE_URL e SUPABASE_ANON_KEY.");
  estado.supabase = window.supabase.createClient(config().SUPABASE_URL, config().SUPABASE_ANON_KEY);
  return estado.supabase;
}
function log(titulo, dados) {
  const hora = new Date().toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit", second: "2-digit" });
  const texto = typeof dados === "string" ? dados : JSON.stringify(dados, null, 2);
  const anterior = ui.logBox.textContent === "Aguardando operação." ? "" : ui.logBox.textContent + "\n\n";
  ui.logBox.textContent = `${anterior}[${hora}] ${titulo}\n${texto}`;
}
function toast(texto, tipo = "") {
  ui.toast.textContent = texto;
  ui.toast.className = `toast ${tipo}`.trim();
  window.setTimeout(() => ui.toast.classList.add("hidden"), 3200);
}
function preencherSelect(select, itens, chave = null) {
  select.innerHTML = "";
  itens.forEach((item) => {
    const opt = document.createElement("option");
    opt.value = chave ? item[chave] : item;
    opt.textContent = item.nome || item;
    select.appendChild(opt);
  });
}
function criarListaProdutos(container, prefixo) {
  container.innerHTML = "";
  FENIX_PRODUTOS.forEach((produto) => {
    const row = document.createElement("div");
    row.className = "product-row";
    row.innerHTML = `<div class="product-row-title"><strong>${produto.nome}</strong><small>${produto.codigo}</small></div><div class="product-inputs"><div><label for="${prefixo}_${produto.codigo}_cheios">Cheios</label><input id="${prefixo}_${produto.codigo}_cheios" type="number" min="0" inputmode="numeric" placeholder="0" /></div><div><label for="${prefixo}_${produto.codigo}_vazios">Vazios/cascos</label><input id="${prefixo}_${produto.codigo}_vazios" type="number" min="0" inputmode="numeric" placeholder="0" /></div></div>`;
    container.appendChild(row);
  });
}
function lerContagem(prefixo) {
  const contagem = {};
  FENIX_PRODUTOS.forEach((produto) => {
    const cheios = numero($(`#${prefixo}_${produto.codigo}_cheios`));
    const vazios = numero($(`#${prefixo}_${produto.codigo}_vazios`));
    contagem[produto.codigo] = { produto: produto.codigo, cheios, vazios, total_cascos: cheios + vazios };
  });
  return contagem;
}
function aplicarContagem(prefixo, contagem) {
  FENIX_PRODUTOS.forEach((produto) => {
    const item = contagem?.[produto.codigo] || { cheios: 0, vazios: 0 };
    $(`#${prefixo}_${produto.codigo}_cheios`).value = item.cheios ?? 0;
    $(`#${prefixo}_${produto.codigo}_vazios`).value = item.vazios ?? 0;
  });
}
function contagemVazia(contagem) { return Object.values(contagem).every((item) => item.cheios === 0 && item.vazios === 0); }
function flattenContagem(contagem, prefixoCampo) {
  const flat = {};
  FENIX_PRODUTOS.forEach((produto) => {
    const item = contagem[produto.codigo] || { cheios: 0, vazios: 0 };
    const chave = produto.codigo.toLowerCase();
    flat[`${chave}_${prefixoCampo}_cheios`] = item.cheios;
    flat[`${chave}_${prefixoCampo}_vazios`] = item.vazios;
    flat[`${chave}_cheios`] = item.cheios;
    flat[`${chave}_vazios`] = item.vazios;
  });
  return flat;
}
function payloadBase() {
  const data = dataOperacional(), revenda = revendaCodigo();
  return { p_data_operacional: data, p_data: data, data_operacional: data, p_revenda_codigo: revenda, p_revenda: revenda, revenda_codigo: revenda, revenda };
}
function erroDeAssinatura(err) {
  const msg = `${err?.message || err || ""}`.toLowerCase();
  return msg.includes("could not find the function") || msg.includes("schema cache") || msg.includes("parameter") || msg.includes("argument") || msg.includes("function") || msg.includes("pgrst202") || msg.includes("pgrst203");
}
async function chamarRpc(nome, tentativas, descricao) {
  const client = supabaseClient();
  const erros = [];
  for (const payload of tentativas) {
    const { data, error } = await client.rpc(nome, payload);
    if (!error) { log(`${descricao || nome} — sucesso`, data ?? "sem retorno"); return data; }
    erros.push(error.message || JSON.stringify(error));
    if (!erroDeAssinatura(error)) { log(`${descricao || nome} — erro`, error); throw error; }
  }
  throw new Error(`${descricao || nome} não encaixou nos parâmetros esperados. Último erro: ${erros.at(-1)}`);
}
function normalizarStatus(status) {
  const s = String(status || "").toLowerCase().trim().replaceAll(" ", "_").replaceAll("-", "_");
  if (["sem_abertura", "semabertura", "nao_aberto", "não_aberto", "sem_abertura_do_dia"].includes(s)) return "sem_abertura";
  if (["aberto", "em_operacao", "em_operação"].includes(s)) return "aberto";
  if (["inconsistente", "divergente", "pendente", "corrigido_apos_revisao", "corrigido_após_revisão"].includes(s)) return "inconsistente";
  if (["fechado", "encerrado", "concluido", "concluído"].includes(s)) return "fechado";
  return s || "sem_abertura";
}
function extrairStatus(retorno) {
  const data = Array.isArray(retorno) ? retorno[0] : retorno;
  if (!data) return "sem_abertura";
  if (typeof data === "string") return normalizarStatus(data);
  return normalizarStatus(data.status || data.status_dia || data.situacao || data.estado || data.dia_status || "sem_abertura");
}
function textoStatus(status) { return ({ nao_consultado: "não consultado", sem_abertura: "sem abertura", aberto: "aberto", inconsistente: "inconsistente", fechado: "fechado" })[status] || status; }
function classeStatus(status) { if (status === "aberto" || status === "fechado") return "ok"; if (status === "inconsistente") return "danger"; return "warn"; }
function resumoStatus(status) {
  return ({ nao_consultado: "Atualize o status do dia para liberar a operação.", sem_abertura: "Dia sem abertura. Faça a contagem inicial da manhã.", aberto: "Dia aberto. Vendas, estoque e fechamento liberados.", inconsistente: "Estoque inconsistente. Corrija antes de encerrar.", fechado: "Estoque fechado, turno encerrado." })[status] || `Status retornado pelo banco: ${status}`;
}
function aplicarStatus(status, retorno = null) {
  estado.status = normalizarStatus(status);
  estado.ultimoRetorno = retorno;
  ui.dateTitle.textContent = `Operação diária — ${dataOperacional()}`;
  ui.dashboardText.textContent = resumoStatus(estado.status);
  ui.dayStatusPanel.innerHTML = `<div class="status-line"><strong>Status</strong><span class="${classeStatus(estado.status)}">${textoStatus(estado.status)}</span></div><div class="status-line"><strong>Revenda</strong><span>${revendaNome()}</span></div><div class="status-line"><strong>Data</strong><span>${dataOperacional()}</span></div>`;
  if (configPronta()) {
    ui.badge.textContent = estado.status === "inconsistente" ? "Revisar" : "Conectado";
    ui.badge.className = `badge ${estado.status === "inconsistente" ? "badge-danger" : "badge-ok"}`;
  } else {
    ui.badge.textContent = "Configurar";
    ui.badge.className = "badge badge-warn";
  }
  bloquearAcoesPorStatus();
}
function bloquearAcoesPorStatus() {
  const s = estado.status;
  const regras = { opening: s !== "sem_abertura", sale: s !== "aberto", stock: s === "nao_consultado" || s === "sem_abertura", closing: s !== "aberto" && s !== "inconsistente", correction: s !== "inconsistente" };
  Object.entries(regras).forEach(([acao, bloqueado]) => {
    const botao = $(`[data-action="${acao}"]`);
    if (!botao) return;
    botao.classList.toggle("is-blocked", bloqueado);
    botao.dataset.blocked = bloqueado ? "true" : "false";
  });
}
function navegar(destino) {
  const screen = $(`#screen-${destino}`);
  if (!screen) return;
  $$(".screen").forEach((item) => item.classList.remove("active"));
  screen.classList.add("active");
  window.scrollTo({ top: 0, behavior: "smooth" });
}
function tabelaLinhas(linhas) {
  return `<div class="table-like">${linhas.map(([a, b, c]) => `<div class="table-row"><strong>${a}</strong><span class="${c || ""}">${b}</span></div>`).join("")}</div>`;
}
function normalizarEstoque(retorno) {
  const origem = Array.isArray(retorno) ? retorno : (retorno?.itens || retorno?.produtos || retorno?.estoque || []);
  const lista = Array.isArray(origem) ? origem : Object.entries(origem).map(([produto, valores]) => ({ produto, ...valores }));
  const estoque = {};
  lista.forEach((item) => {
    const codigo = String(item.produto || item.produto_codigo || item.codigo || item.nome || "").toUpperCase();
    if (!codigo) return;
    estoque[codigo] = { cheios: Number(item.cheios ?? item.qtd_cheios ?? item.estoque_cheio ?? item.cheio ?? 0), vazios: Number(item.vazios ?? item.qtd_vazios ?? item.estoque_vazio ?? item.vazio ?? 0) };
  });
  return estoque;
}
function renderEstoque(retorno) {
  const estoque = normalizarEstoque(retorno);
  estado.ultimoEstoque = estoque;
  if (!Object.keys(estoque).length) { ui.stockList.innerHTML = `<pre class="result-box">${JSON.stringify(retorno, null, 2)}</pre>`; return; }
  ui.stockList.innerHTML = tabelaLinhas(FENIX_PRODUTOS.map((p) => { const item = estoque[p.codigo] || { cheios: 0, vazios: 0 }; return [p.nome, `${item.cheios} cheios / ${item.vazios} vazios`, ""]; }));
}
function renderFechamento(retorno) {
  const data = Array.isArray(retorno) ? retorno : (retorno?.itens || retorno?.divergencias || retorno?.resultado || retorno);
  const status = extrairStatus(retorno);
  if (Array.isArray(data)) {
    ui.closingItems.innerHTML = tabelaLinhas(data.map((item) => {
      const produto = item.produto || item.produto_codigo || item.codigo || "Produto";
      const ok = item.conferido === true || item.status === "conferido" || item.divergente === false;
      return [produto, ok ? "conferido" : (item.mensagem || item.status || "verificar"), ok ? "ok" : "danger"];
    }));
    return;
  }
  ui.closingItems.innerHTML = tabelaLinhas([["Status", textoStatus(status), classeStatus(status)], ["Resultado", status === "fechado" ? "Estoque fechado, turno encerrado." : "Revise até corrigir.", status === "fechado" ? "ok" : "danger"]]);
}
function tentativasStatus() {
  const b = payloadBase();
  return [
    { p_data_operacional: b.p_data_operacional, p_revenda_codigo: b.p_revenda_codigo },
    { p_data_operacional: b.p_data_operacional, p_revenda: b.p_revenda },
    { p_data: b.p_data, p_revenda: b.p_revenda },
    { data_operacional: b.data_operacional, revenda_codigo: b.revenda_codigo },
    { p_data_operacional: b.p_data_operacional },
    { p_data: b.p_data }
  ];
}
async function consultarStatus() {
  try {
    toast("Consultando status...");
    const data = await chamarRpc("consultar_status_dia_mvp", tentativasStatus(), "Consultar status");
    const status = extrairStatus(data);
    aplicarStatus(status, data);
    toast(`Status: ${textoStatus(status)}`, status === "inconsistente" ? "error" : "success");
  } catch (err) {
    log("Erro ao consultar status", err.message || String(err));
    aplicarStatus("nao_consultado");
    toast(err.message || "Erro ao consultar status", "error");
  }
}
async function salvarAbertura() {
  const contagem = lerContagem("opening");
  if (contagemVazia(contagem)) { toast("Informe a contagem da abertura.", "error"); return; }
  try {
    const b = payloadBase(), flat = flattenContagem(contagem, "abertura");
    const retorno = await chamarRpc("registrar_abertura_mvp", [{ ...b, p_contagem: contagem }, { ...b, p_estoque_inicial: contagem }, { ...b, p_produtos: contagem }, { ...b, contagem }, { ...b, ...flat }], "Registrar abertura");
    aplicarStatus("aberto", retorno);
    toast("Abertura registrada. Dia aberto.", "success");
    navegar("dashboard");
  } catch (err) { log("Erro na abertura", err.message || String(err)); toast(err.message || "Erro na abertura", "error"); }
}
function setCascoAtivo(ativo) {
  estado.cascoAtivo = ativo;
  ui.toggleCascoButton.setAttribute("aria-pressed", ativo ? "true" : "false");
  ui.toggleCascoButton.textContent = ativo ? "Sim" : "Não";
  ui.cascoField.classList.toggle("hidden", !ativo);
  if (!ativo) ui.cascoQty.value = "";
}
async function salvarVenda() {
  const canal = ui.saleChannel.value, produto = ui.saleProduct.value, quantidade = numero(ui.saleQty), quantidadeCasco = estado.cascoAtivo ? numero(ui.cascoQty) : 0;
  if (!canal || !produto || quantidade <= 0) { toast("Informe canal, produto e quantidade.", "error"); return; }
  if (quantidadeCasco > quantidade) { toast("Casco não pode ser maior que a venda do líquido.", "error"); return; }
  try {
    const b = payloadBase();
    await chamarRpc("registrar_venda_mvp", [
      { ...b, p_canal: canal, p_produto: produto, p_quantidade_liquido: quantidade, p_quantidade_casco: quantidadeCasco, p_quantidade_sem_troca: quantidadeCasco },
      { ...b, p_canal_venda: canal, p_produto_codigo: produto, p_qtd_liquido: quantidade, p_qtd_casco: quantidadeCasco, p_qtd_sem_troca: quantidadeCasco },
      { ...b, canal, produto, quantidade, quantidade_casco: quantidadeCasco, quantidade_sem_troca: quantidadeCasco },
      { ...b, p_movimento: { canal, produto, quantidade_liquido: quantidade, quantidade_casco: quantidadeCasco } }
    ], "Registrar venda");
    ui.saleQty.value = ""; ui.cascoQty.value = ""; setCascoAtivo(false); estado.ultimoEstoque = null;
    toast("Venda registrada.", "success");
    await consultarStatus();
  } catch (err) { log("Erro na venda", err.message || String(err)); toast(err.message || "Erro na venda", "error"); }
}
async function consultarEstoque() {
  try {
    const b = payloadBase();
    const retorno = await chamarRpc("consultar_estoque_mvp", [
      { p_data_operacional: b.p_data_operacional, p_revenda_codigo: b.p_revenda_codigo },
      { p_data_operacional: b.p_data_operacional, p_revenda: b.p_revenda },
      { p_data: b.p_data, p_revenda: b.p_revenda },
      { data_operacional: b.data_operacional, revenda_codigo: b.revenda_codigo },
      { p_data_operacional: b.p_data_operacional }
    ], "Consultar estoque");
    renderEstoque(retorno); toast("Estoque consultado.", "success"); return retorno;
  } catch (err) { log("Erro ao consultar estoque", err.message || String(err)); toast(err.message || "Erro ao consultar estoque", "error"); return null; }
}
async function preencherFechamentoCalculado() {
  if (!estado.ultimoEstoque) await consultarEstoque();
  if (!estado.ultimoEstoque || !Object.keys(estado.ultimoEstoque).length) { toast("Consulte o estoque antes de preencher.", "error"); return; }
  aplicarContagem("closing", estado.ultimoEstoque);
  toast("Fechamento preenchido para teste.");
}
async function simularDivergencia() {
  await preencherFechamentoCalculado();
  const input = $("#closing_P13_cheios");
  if (input) input.value = Math.max(0, numero(input) - 1);
  toast("Divergência simulada em P13.");
}
async function salvarFechamento() {
  const contagem = lerContagem("closing");
  if (contagemVazia(contagem)) { toast("Informe a contagem física final.", "error"); return; }
  estado.ultimoFechamento = contagem;
  try {
    const b = payloadBase(), flat = flattenContagem(contagem, "fechamento");
    const retorno = await chamarRpc("registrar_fechamento_mvp", [{ ...b, p_contagem_fisica: contagem }, { ...b, p_fechamento: contagem }, { ...b, p_produtos: contagem }, { ...b, contagem_fisica: contagem }, { ...b, ...flat }], "Registrar fechamento");
    const status = extrairStatus(retorno);
    aplicarStatus(status, retorno); renderFechamento(retorno);
    toast(status === "fechado" ? "Estoque fechado, turno encerrado." : "Estoque inconsistente. Revisar até corrigir.", status === "fechado" ? "success" : "error");
  } catch (err) { log("Erro no fechamento", err.message || String(err)); toast(err.message || "Erro no fechamento", "error"); }
}
async function registrarCorrecao() {
  const canal = ui.correctionChannel.value, produto = ui.correctionProduct.value, quantidade = numero(ui.correctionQty);
  if (!canal || !produto || quantidade <= 0) { toast("Informe canal, produto e quantidade da correção.", "error"); return; }
  try {
    const b = payloadBase(), motivo = "Correção guiada após divergência no fechamento.";
    const retorno = await chamarRpc("registrar_correcao_venda_casco_mvp", [
      { ...b, p_produto: produto, p_canal: canal, p_quantidade_liquido: quantidade, p_quantidade_casco: quantidade, p_quantidade_sem_troca: quantidade, p_motivo: motivo },
      { ...b, p_produto_codigo: produto, p_canal_venda: canal, p_qtd_liquido: quantidade, p_qtd_casco: quantidade, p_qtd_sem_troca: quantidade, p_motivo: motivo },
      { ...b, produto, canal, quantidade_liquido: quantidade, quantidade_casco: quantidade, quantidade_sem_troca: quantidade, motivo },
      { ...b, p_correcao: { produto, canal, quantidade_liquido: quantidade, quantidade_casco: quantidade, quantidade_sem_troca: quantidade, motivo } }
    ], "Registrar correção");
    ui.correctionResult.innerHTML = tabelaLinhas([["Correção", `${canal} — ${produto} — ${quantidade}`, "ok"], ["Próximo passo", "refazer fechamento", "warn"]]);
    toast("Correção registrada.", "success"); log("Correção registrada", retorno ?? "sem retorno");
    if (estado.ultimoFechamento && !contagemVazia(estado.ultimoFechamento)) await salvarFechamento(); else await consultarStatus();
  } catch (err) { log("Erro na correção", err.message || String(err)); ui.correctionResult.innerHTML = tabelaLinhas([["Erro", err.message || String(err), "danger"]]); toast(err.message || "Erro na correção", "error"); }
}
function ligarEventos() {
  $$('[data-nav]').forEach((botao) => botao.addEventListener("click", () => {
    if (botao.dataset.blocked === "true") { toast("Etapa bloqueada pelo status atual do dia.", "error"); return; }
    navegar(botao.dataset.nav);
  }));
  ui.operationDate.addEventListener("change", () => {
    estado.ultimoEstoque = null; estado.ultimoFechamento = null;
    ui.stockList.innerHTML = '<p class="muted">Clique em consultar.</p>';
    ui.closingItems.innerHTML = '<p class="muted">O resultado aparecerá após gravar.</p>';
    aplicarStatus("nao_consultado");
  });
  ui.refreshStatusButton.addEventListener("click", consultarStatus);
  ui.fillOpeningButton.addEventListener("click", () => aplicarContagem("opening", FENIX_EXEMPLO_ABERTURA));
  ui.saveOpeningButton.addEventListener("click", salvarAbertura);
  ui.toggleCascoButton.addEventListener("click", () => setCascoAtivo(!estado.cascoAtivo));
  ui.quickPortariaButton.addEventListener("click", () => { ui.saleChannel.value = "Portaria"; ui.saleProduct.value = "P13"; ui.saleQty.value = "10"; setCascoAtivo(false); });
  ui.quickJoaoButton.addEventListener("click", () => { ui.saleChannel.value = "João"; ui.saleProduct.value = "P13"; ui.saleQty.value = "10"; ui.cascoQty.value = "1"; setCascoAtivo(true); });
  ui.saveSaleButton.addEventListener("click", salvarVenda);
  ui.queryStockButton.addEventListener("click", consultarEstoque);
  ui.fillClosingCalculatedButton.addEventListener("click", preencherFechamentoCalculado);
  ui.simulateDivergenceButton.addEventListener("click", simularDivergencia);
  ui.saveClosingButton.addEventListener("click", salvarFechamento);
  ui.runCorrectionButton.addEventListener("click", registrarCorrecao);
  ui.clearLogButton.addEventListener("click", () => { ui.logBox.textContent = "Aguardando operação."; });
}
function iniciar() {
  ui.operationDate.value = hojeISO();
  preencherSelect(ui.saleChannel, FENIX_CANAIS); preencherSelect(ui.correctionChannel, FENIX_CANAIS);
  preencherSelect(ui.saleProduct, FENIX_PRODUTOS, "codigo"); preencherSelect(ui.correctionProduct, FENIX_PRODUTOS, "codigo");
  criarListaProdutos(ui.openingList, "opening"); criarListaProdutos(ui.closingList, "closing");
  ligarEventos(); aplicarStatus("nao_consultado");
  if (!configPronta()) { log("Configuração pendente", "Edite js/config.js com SUPABASE_URL e SUPABASE_ANON_KEY."); toast("Configuração pendente no js/config.js", "error"); }
  else log("Configuração carregada", "Pronto para consultar o status do dia.");
}
document.addEventListener("DOMContentLoaded", iniciar);
