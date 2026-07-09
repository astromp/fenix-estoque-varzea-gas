/*
  Projeto Fênix Estoque — Operação Celular Integrada V3
  Unidade inicial: Várzea Gás

  Regra de ouro:
  - Estoque fechado, turno encerrado.
  - Estoque inconsistente, revisar até corrigir.
*/

const PRODUTOS = [
  { codigo: "P13", nome: "P13" },
  { codigo: "P05", nome: "P05" },
  { codigo: "P20", nome: "P20" },
  { codigo: "P45", nome: "P45" },
  { codigo: "AGUA", nome: "Água / galão" }
];

const CANAIS = ["Portaria", "Rogério", "André", "João", "Outros"];

const ESTADO = {
  status: "nao_consultado",
  ultimoRetorno: null
};

const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => Array.from(document.querySelectorAll(selector));

const el = {
  data: $("#dataOperacional"),
  statusPill: $("#statusPill"),
  statusDescricao: $("#statusDescricao"),
  mensagens: $("#mensagens"),
  aberturaProdutos: $("#aberturaProdutos"),
  fechamentoProdutos: $("#fechamentoProdutos"),
  canalVenda: $("#canalVenda"),
  produtoVenda: $("#produtoVenda"),
  qtdVenda: $("#qtdVenda"),
  campoSemTroca: $("#campoSemTroca"),
  qtdSemTroca: $("#qtdSemTroca"),
  estoqueResultado: $("#estoqueResultado"),
  produtoCorrecao: $("#produtoCorrecao"),
  canalCorrecao: $("#canalCorrecao"),
  qtdCorrecao: $("#qtdCorrecao"),
  motivoCorrecao: $("#motivoCorrecao"),
  btnConsultarStatus: $("#btnConsultarStatus"),
  btnRegistrarAbertura: $("#btnRegistrarAbertura"),
  btnRegistrarVenda: $("#btnRegistrarVenda"),
  btnConsultarEstoque: $("#btnConsultarEstoque"),
  btnRegistrarFechamento: $("#btnRegistrarFechamento"),
  btnRegistrarCorrecao: $("#btnRegistrarCorrecao")
};

function hojeISO() {
  const agora = new Date();
  const offset = agora.getTimezoneOffset();
  const local = new Date(agora.getTime() - offset * 60 * 1000);
  return local.toISOString().slice(0, 10);
}

function config() {
  return window.FENIX_CONFIG || {};
}

function configPronta() {
  const cfg = config();
  return Boolean(
    cfg.SUPABASE_URL &&
    cfg.SUPABASE_ANON_KEY &&
    !cfg.SUPABASE_URL.includes("COLE_AQUI") &&
    !cfg.SUPABASE_ANON_KEY.includes("COLE_AQUI")
  );
}

function getSupabase() {
  if (!window.supabase) {
    throw new Error("Biblioteca do Supabase não carregou. Confira a conexão com a internet.");
  }
  if (!configPronta()) {
    throw new Error("Configure js/config.js com SUPABASE_URL e SUPABASE_ANON_KEY antes de testar.");
  }
  const cfg = config();
  return window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);
}

function dataOperacional() {
  if (!el.data.value) {
    el.data.value = hojeISO();
  }
  return el.data.value;
}

function revendaCodigo() {
  return config().REVENDA_CODIGO || "varzea_gas";
}

function revendaNome() {
  return config().REVENDA_NOME || "Várzea Gás";
}

function numero(input) {
  const valor = Number(input.value || 0);
  return Number.isFinite(valor) ? valor : 0;
}

function mensagem(tipo, titulo, texto) {
  const div = document.createElement("div");
  div.className = `message ${tipo || ""}`.trim();
  div.innerHTML = `<small>${titulo}</small>${texto}`;
  el.mensagens.prepend(div);
}

function limparResultado() {
  el.estoqueResultado.textContent = "Sem consulta.";
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

function criarLinhasProdutos(container, prefixo) {
  container.innerHTML = "";
  PRODUTOS.forEach((produto) => {
    const row = document.createElement("div");
    row.className = "product-row";
    row.innerHTML = `
      <div class="product-title">
        <span>${produto.nome}</span>
        <small>${produto.codigo}</small>
      </div>
      <div class="product-inputs">
        <div>
          <label for="${prefixo}_${produto.codigo}_cheios">Cheios</label>
          <input id="${prefixo}_${produto.codigo}_cheios" data-prefix="${prefixo}" data-produto="${produto.codigo}" data-tipo="cheios" type="number" min="0" inputmode="numeric" placeholder="0" />
        </div>
        <div>
          <label for="${prefixo}_${produto.codigo}_vazios">Vazios/cascos</label>
          <input id="${prefixo}_${produto.codigo}_vazios" data-prefix="${prefixo}" data-produto="${produto.codigo}" data-tipo="vazios" type="number" min="0" inputmode="numeric" placeholder="0" />
        </div>
      </div>
    `;
    container.appendChild(row);
  });
}

function lerContagem(prefixo) {
  const contagem = {};
  PRODUTOS.forEach((produto) => {
    const cheios = numero($(`#${prefixo}_${produto.codigo}_cheios`));
    const vazios = numero($(`#${prefixo}_${produto.codigo}_vazios`));
    contagem[produto.codigo] = {
      produto: produto.codigo,
      cheios,
      vazios,
      total_cascos: cheios + vazios
    };
  });
  return contagem;
}

function contagemVazia(contagem) {
  return Object.values(contagem).every((item) => item.cheios === 0 && item.vazios === 0);
}

function flattenContagem(contagem, prefixoCampo) {
  const flat = {};
  PRODUTOS.forEach((produto) => {
    const item = contagem[produto.codigo] || { cheios: 0, vazios: 0 };
    const chave = produto.codigo.toLowerCase();
    flat[`${chave}_${prefixoCampo}_cheios`] = item.cheios;
    flat[`${chave}_${prefixoCampo}_vazios`] = item.vazios;
    flat[`${chave}_cheios`] = item.cheios;
    flat[`${chave}_vazios`] = item.vazios;
  });
  return flat;
}

function extrairStatus(retorno) {
  const data = Array.isArray(retorno) ? retorno[0] : retorno;
  if (!data) return "sem_abertura";
  if (typeof data === "string") return normalizarStatus(data);
  return normalizarStatus(
    data.status ||
    data.status_dia ||
    data.situacao ||
    data.estado ||
    data.dia_status ||
    "sem_abertura"
  );
}

function normalizarStatus(status) {
  const s = String(status || "").toLowerCase().trim().replaceAll(" ", "_").replaceAll("-", "_");
  if (["sem_abertura", "semabertura", "nao_aberto", "não_aberto", "sem_abertura_do_dia"].includes(s)) return "sem_abertura";
  if (["aberto", "em_operacao", "em_operação"].includes(s)) return "aberto";
  if (["inconsistente", "divergente", "pendente", "corrigido_apos_revisao", "corrigido_após_revisão"].includes(s)) return "inconsistente";
  if (["fechado", "encerrado", "concluido", "concluído"].includes(s)) return "fechado";
  return s || "sem_abertura";
}

function labelStatus(status) {
  const mapa = {
    nao_consultado: "Aguardando consulta",
    sem_abertura: "Sem abertura",
    aberto: "Aberto",
    inconsistente: "Inconsistente",
    fechado: "Fechado"
  };
  return mapa[status] || status;
}

function descricaoStatus(status) {
  const mapa = {
    nao_consultado: "Consulte a data para iniciar.",
    sem_abertura: "Dia sem abertura. Faça a contagem inicial para liberar lançamentos.",
    aberto: "Dia aberto. Vendas e fechamento estão liberados.",
    inconsistente: "Estoque inconsistente. Revise e corrija antes de fechar.",
    fechado: "Dia fechado. Turno encerrado; novos lançamentos ficam bloqueados."
  };
  return mapa[status] || `Status retornado pelo banco: ${status}`;
}

function aplicarStatus(status, retorno = null) {
  ESTADO.status = normalizarStatus(status);
  ESTADO.ultimoRetorno = retorno;

  el.statusPill.textContent = labelStatus(ESTADO.status);
  el.statusDescricao.textContent = descricaoStatus(ESTADO.status);

  $$('[data-step]').forEach((step) => {
    step.classList.toggle('active', step.dataset.step === ESTADO.status);
  });

  const podeAbrir = ESTADO.status === "sem_abertura";
  const podeOperar = ESTADO.status === "aberto";
  const podeCorrigir = ESTADO.status === "inconsistente" || ESTADO.status === "aberto";
  const podeConsultar = ESTADO.status !== "nao_consultado";

  travarPainel("abertura", !podeAbrir);
  travarPainel("venda", !podeOperar);
  travarPainel("fechamento", !podeOperar && ESTADO.status !== "inconsistente");
  travarPainel("correcao", !podeCorrigir);

  el.btnConsultarEstoque.disabled = !podeConsultar;
}

function travarPainel(nome, bloqueado) {
  const painel = $(`[data-panel="${nome}"]`);
  const selo = $(`[data-lock="${nome}"]`);
  if (!painel) return;
  painel.classList.toggle("locked", bloqueado);
  painel.querySelectorAll("input, select, textarea, button").forEach((campo) => {
    campo.disabled = bloqueado;
  });
  if (selo) {
    selo.textContent = bloqueado ? "Bloqueado" : "Liberado";
    selo.classList.toggle("open", !bloqueado);
  }
}

function erroDeAssinatura(err) {
  const msg = `${err?.message || err || ""}`.toLowerCase();
  return msg.includes("could not find the function") ||
    msg.includes("schema cache") ||
    msg.includes("parameter") ||
    msg.includes("argument") ||
    msg.includes("function") ||
    msg.includes("pgrst202") ||
    msg.includes("pgrst203");
}

async function chamarRpc(nome, tentativas, descricao) {
  const supabase = getSupabase();
  const erros = [];

  for (const payload of tentativas) {
    const { data, error } = await supabase.rpc(nome, payload);
    if (!error) {
      return data;
    }
    erros.push(error.message || JSON.stringify(error));
    if (!erroDeAssinatura(error)) {
      throw error;
    }
  }

  throw new Error(`${descricao || nome} não encaixou nos parâmetros esperados. Último erro: ${erros.at(-1)}`);
}

function payloadBase() {
  return {
    p_data_operacional: dataOperacional(),
    p_data: dataOperacional(),
    data_operacional: dataOperacional(),
    p_revenda_codigo: revendaCodigo(),
    p_revenda: revendaCodigo(),
    revenda_codigo: revendaCodigo(),
    revenda: revendaCodigo()
  };
}

function tentativasStatus() {
  const data = dataOperacional();
  const revenda = revendaCodigo();
  return [
    { p_data_operacional: data, p_revenda_codigo: revenda },
    { p_data_operacional: data, p_revenda: revenda },
    { p_data: data, p_revenda: revenda },
    { data_operacional: data, revenda_codigo: revenda },
    { p_data_operacional: data },
    { p_data: data }
  ];
}

async function consultarStatus() {
  try {
    mensagem("", "Consulta", `Consultando status de ${dataOperacional()}...`);
    const data = await chamarRpc("consultar_status_dia_mvp", tentativasStatus(), "Consulta de status");
    const status = extrairStatus(data);
    aplicarStatus(status, data);
    mensagem("success", "Status atualizado", `${revendaNome()} — ${labelStatus(status)}.`);
  } catch (err) {
    aplicarStatus("nao_consultado");
    mensagem("error", "Erro ao consultar status", err.message || String(err));
  }
}

async function registrarAbertura() {
  const contagem = lerContagem("abertura");
  if (contagemVazia(contagem)) {
    mensagem("error", "Abertura não enviada", "Informe pelo menos um produto com cheios ou vazios.");
    return;
  }

  try {
    const base = payloadBase();
    const flat = flattenContagem(contagem, "abertura");
    const tentativas = [
      { ...base, p_contagem: contagem },
      { ...base, p_estoque_inicial: contagem },
      { ...base, p_produtos: contagem },
      { ...base, contagem },
      { ...base, ...flat }
    ];

    mensagem("", "Abertura", "Registrando abertura da manhã...");
    const data = await chamarRpc("registrar_abertura_mvp", tentativas, "Registro de abertura");
    aplicarStatus("aberto", data);
    mensagem("success", "Abertura registrada", "Dia aberto. Vendas liberadas.");
  } catch (err) {
    mensagem("error", "Erro na abertura", err.message || String(err));
  }
}

async function registrarVenda() {
  const canal = el.canalVenda.value;
  const produto = el.produtoVenda.value;
  const quantidade = numero(el.qtdVenda);
  const tipo = $("input[name='tipoVenda']:checked")?.value || "troca";
  const quantidadeSemTroca = tipo === "sem_troca" ? numero(el.qtdSemTroca) : 0;

  if (!canal || !produto || quantidade <= 0) {
    mensagem("error", "Venda não enviada", "Informe canal, produto e quantidade vendida maior que zero.");
    return;
  }

  if (quantidadeSemTroca > quantidade) {
    mensagem("error", "Venda não enviada", "A quantidade sem troca/casco não pode ser maior que a venda do produto cheio.");
    return;
  }

  try {
    const base = payloadBase();
    const tentativas = [
      { ...base, p_canal: canal, p_produto: produto, p_quantidade_liquido: quantidade, p_quantidade_casco: quantidadeSemTroca, p_quantidade_sem_troca: quantidadeSemTroca },
      { ...base, p_canal_venda: canal, p_produto_codigo: produto, p_qtd_liquido: quantidade, p_qtd_casco: quantidadeSemTroca, p_qtd_sem_troca: quantidadeSemTroca },
      { ...base, canal, produto, quantidade, quantidade_casco: quantidadeSemTroca, quantidade_sem_troca: quantidadeSemTroca },
      { ...base, p_movimento: { canal, produto, quantidade_liquido: quantidade, quantidade_casco: quantidadeSemTroca, tipo_venda: tipo } }
    ];

    mensagem("", "Venda", `Salvando venda de ${quantidade} ${produto} pelo canal ${canal}...`);
    const data = await chamarRpc("registrar_venda_mvp", tentativas, "Registro de venda");
    mensagem("success", "Venda registrada", "Movimento salvo. O estoque foi atualizado pelo banco.");
    el.qtdVenda.value = "";
    el.qtdSemTroca.value = "";
    limparResultado();
    await consultarStatus();
    return data;
  } catch (err) {
    mensagem("error", "Erro ao salvar venda", err.message || String(err));
  }
}

async function consultarEstoque() {
  try {
    const base = payloadBase();
    const tentativas = [
      { p_data_operacional: base.p_data_operacional, p_revenda_codigo: base.p_revenda_codigo },
      { p_data_operacional: base.p_data_operacional, p_revenda: base.p_revenda },
      { p_data: base.p_data, p_revenda: base.p_revenda },
      { data_operacional: base.data_operacional, revenda_codigo: base.revenda_codigo },
      { p_data_operacional: base.p_data_operacional }
    ];
    mensagem("", "Estoque", "Consultando estoque calculado...");
    const data = await chamarRpc("consultar_estoque_mvp", tentativas, "Consulta de estoque");
    el.estoqueResultado.textContent = JSON.stringify(data, null, 2);
    mensagem("success", "Estoque consultado", "Resumo retornado pelo Supabase.");
  } catch (err) {
    mensagem("error", "Erro ao consultar estoque", err.message || String(err));
  }
}

async function registrarFechamento() {
  const contagem = lerContagem("fechamento");
  if (contagemVazia(contagem)) {
    mensagem("error", "Fechamento não enviado", "Informe a contagem física antes de conferir.");
    return;
  }

  try {
    const base = payloadBase();
    const flat = flattenContagem(contagem, "fechamento");
    const tentativas = [
      { ...base, p_contagem_fisica: contagem },
      { ...base, p_fechamento: contagem },
      { ...base, p_produtos: contagem },
      { ...base, contagem_fisica: contagem },
      { ...base, ...flat }
    ];

    mensagem("", "Fechamento", "Conferindo fechamento físico...");
    const data = await chamarRpc("registrar_fechamento_mvp", tentativas, "Registro de fechamento");
    const status = extrairStatus(data);
    aplicarStatus(status, data);

    if (normalizarStatus(status) === "fechado") {
      mensagem("success", "Estoque conferido", "Estoque fechado, turno encerrado.");
    } else {
      mensagem("error", "Estoque inconsistente", "Revise os lançamentos e corrija antes de encerrar.");
    }
  } catch (err) {
    mensagem("error", "Erro no fechamento", err.message || String(err));
  }
}

async function registrarCorrecao() {
  const produto = el.produtoCorrecao.value;
  const canal = el.canalCorrecao.value;
  const quantidade = numero(el.qtdCorrecao);
  const motivo = el.motivoCorrecao.value || "Correção após divergência no fechamento.";

  if (!produto || !canal || quantidade <= 0) {
    mensagem("error", "Correção não enviada", "Informe produto, canal e quantidade maior que zero.");
    return;
  }

  try {
    const base = payloadBase();
    const tentativas = [
      { ...base, p_produto: produto, p_canal: canal, p_quantidade_casco: quantidade, p_quantidade_sem_troca: quantidade, p_motivo: motivo },
      { ...base, p_produto_codigo: produto, p_canal_venda: canal, p_qtd_casco: quantidade, p_qtd_sem_troca: quantidade, p_motivo: motivo },
      { ...base, produto, canal, quantidade_casco: quantidade, quantidade_sem_troca: quantidade, motivo },
      { ...base, p_correcao: { produto, canal, quantidade_casco: quantidade, quantidade_sem_troca: quantidade, motivo } }
    ];

    mensagem("", "Correção", "Registrando correção guiada...");
    const data = await chamarRpc("registrar_correcao_venda_casco_mvp", tentativas, "Registro de correção");
    mensagem("success", "Correção registrada", "Agora refaça o fechamento para confirmar se o estoque bateu.");
    aplicarStatus("inconsistente", data);
    limparResultado();
  } catch (err) {
    mensagem("error", "Erro na correção", err.message || String(err));
  }
}

function ligarEventos() {
  el.btnConsultarStatus.addEventListener("click", consultarStatus);
  el.btnRegistrarAbertura.addEventListener("click", registrarAbertura);
  el.btnRegistrarVenda.addEventListener("click", registrarVenda);
  el.btnConsultarEstoque.addEventListener("click", consultarEstoque);
  el.btnRegistrarFechamento.addEventListener("click", registrarFechamento);
  el.btnRegistrarCorrecao.addEventListener("click", registrarCorrecao);

  $$('input[name="tipoVenda"]').forEach((radio) => {
    radio.addEventListener("change", () => {
      const semTroca = $("input[name='tipoVenda']:checked")?.value === "sem_troca";
      el.campoSemTroca.classList.toggle("hidden", !semTroca);
      if (!semTroca) el.qtdSemTroca.value = "";
    });
  });
}

function iniciar() {
  el.data.value = hojeISO();
  preencherSelect(el.canalVenda, CANAIS);
  preencherSelect(el.canalCorrecao, CANAIS);
  preencherSelect(el.produtoVenda, PRODUTOS, "codigo");
  preencherSelect(el.produtoCorrecao, PRODUTOS, "codigo");
  criarLinhasProdutos(el.aberturaProdutos, "abertura");
  criarLinhasProdutos(el.fechamentoProdutos, "fechamento");
  ligarEventos();
  aplicarStatus("nao_consultado");

  if (!configPronta()) {
    mensagem("error", "Configuração pendente", "Edite js/config.js e substitua os placeholders pela URL pública e pela anon public key do Supabase.");
  } else {
    mensagem("success", "Configuração carregada", "Pronto para consultar o status do dia operacional.");
  }
}

document.addEventListener("DOMContentLoaded", iniciar);
