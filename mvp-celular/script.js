/*
  Projeto Fênix Estoque — MVP Celular
  Versão inicial: modo teste local com localStorage.

  Preparado para Supabase:
  - A URL pública já está preenchida.
  - Cole apenas a ANON PUBLIC KEY quando for conectar.
  - Nunca colocar service_role key no frontend.
*/

const CONFIG = {
  supabaseUrl: "https://pxlapmdypnmvymgbpzhi.supabase.co",
  supabaseAnonKey: "COLE_A_CHAVE_ANON_PUBLIC_AQUI",
  useSupabase: false
};

const PRODUCTS = [
  { code: "P13", name: "Botijão P13" },
  { code: "P05", name: "Botijão P05" },
  { code: "P20", name: "Botijão P20" },
  { code: "P45", name: "Botijão P45" },
  { code: "AGUA", name: "Água / Galão" }
];

const CHANNELS = ["André", "João", "Rogério", "Portaria", "Outros"];

const OPENING_EXAMPLE = {
  P13: { full: 100, empty: 30 },
  P05: { full: 10, empty: 5 },
  P20: { full: 10, empty: 2 },
  P45: { full: 10, empty: 10 },
  AGUA: { full: 50, empty: 10 }
};

const STORAGE_KEY = "fenix_estoque_mvp_varzea_v1";

const emptyState = () => ({
  revenda: "Várzea Gás",
  date: new Date().toISOString().slice(0, 10),
  dayStatus: "aguardando_abertura",
  opening: {},
  movements: [],
  closing: null
});

let state = loadState();
let cascoEnabled = false;

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : emptyState();
  } catch {
    return emptyState();
  }
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function resetState() {
  state = emptyState();
  saveState();
  renderAll();
  toast("Teste reiniciado.");
}

function moneylessDate(dateString) {
  const [year, month, day] = dateString.split("-");
  return `${day}/${month}/${year}`;
}

function byId(id) {
  return document.getElementById(id);
}

function toast(message) {
  const el = byId("toast");
  el.textContent = message;
  el.classList.remove("hidden");
  clearTimeout(window.__toastTimer);
  window.__toastTimer = setTimeout(() => el.classList.add("hidden"), 2600);
}

function showScreen(name) {
  document.querySelectorAll(".screen").forEach((screen) => {
    screen.classList.remove("active");
  });
  byId(`screen-${name}`).classList.add("active");
  if (name === "summary") renderSummary();
  if (name === "closing") renderClosingForm();
  window.scrollTo({ top: 0, behavior: "smooth" });
}

function fillSelect(select, items, getValue = (x) => x, getText = (x) => x) {
  select.innerHTML = "";
  items.forEach((item) => {
    const option = document.createElement("option");
    option.value = getValue(item);
    option.textContent = getText(item);
    select.appendChild(option);
  });
}

function renderDashboard() {
  byId("todayLabel").textContent = `Operação de ${moneylessDate(state.date)}`;

  const statusMap = {
    aguardando_abertura: "Status: aguardando abertura da manhã.",
    aberto: "Status: dia aberto para lançamentos.",
    em_fechamento: "Status: fechamento em andamento.",
    inconsistente: "Status: estoque inconsistente. Revisão obrigatória.",
    fechado: "Status: dia fechado."
  };

  byId("dayStatusText").textContent = statusMap[state.dayStatus] || "Status: indefinido.";

  const alert = byId("dashboardAlert");
  alert.classList.add("hidden");

  if (state.dayStatus === "aguardando_abertura") {
    alert.textContent = "Faça a abertura da manhã antes de lançar vendas ou entradas.";
    alert.classList.remove("hidden");
  }

  if (state.dayStatus === "inconsistente") {
    alert.textContent = "Existe divergência no fechamento. O dia não pode ser encerrado.";
    alert.classList.remove("hidden");
  }

  byId("connectionBadge").textContent = CONFIG.useSupabase ? "Supabase" : "Modo teste local";
  byId("connectionBadge").className = CONFIG.useSupabase ? "badge badge-ok" : "badge badge-warn";
}

function renderOpeningForm() {
  const container = byId("openingList");
  container.innerHTML = "";

  PRODUCTS.forEach((product) => {
    const row = document.createElement("div");
    row.className = "product-row";
    row.innerHTML = `
      <h3>${product.code} — ${product.name}</h3>
      <div class="two-cols">
        <div>
          <label>Cheios</label>
          <input id="open-full-${product.code}" type="number" min="0" inputmode="numeric" value="${state.opening?.[product.code]?.full ?? ""}">
        </div>
        <div>
          <label>Vazios</label>
          <input id="open-empty-${product.code}" type="number" min="0" inputmode="numeric" value="${state.opening?.[product.code]?.empty ?? ""}">
        </div>
      </div>
    `;
    container.appendChild(row);
  });
}

function renderClosingForm() {
  const container = byId("closingList");
  container.innerHTML = "";
  const current = calculateStock();

  PRODUCTS.forEach((product) => {
    const existing = state.closing?.items?.[product.code];
    const row = document.createElement("div");
    row.className = "product-row";
    row.innerHTML = `
      <h3>${product.code} — ${product.name}</h3>
      <p class="muted">Informe a contagem física. O calculado será comparado depois.</p>
      <div class="two-cols">
        <div>
          <label>Cheios físicos</label>
          <input id="close-full-${product.code}" type="number" min="0" inputmode="numeric" value="${existing?.full ?? ""}">
        </div>
        <div>
          <label>Vazios físicos</label>
          <input id="close-empty-${product.code}" type="number" min="0" inputmode="numeric" value="${existing?.empty ?? ""}">
        </div>
      </div>
    `;
    container.appendChild(row);
  });

  byId("closingResult").classList.add("hidden");
}

function parseNonNegativeNumber(value, fieldName) {
  const number = Number(value);
  if (!Number.isFinite(number) || number < 0 || !Number.isInteger(number)) {
    throw new Error(`${fieldName} precisa ser um número inteiro maior ou igual a zero.`);
  }
  return number;
}

function parsePositiveNumber(value, fieldName) {
  const number = Number(value);
  if (!Number.isFinite(number) || number <= 0 || !Number.isInteger(number)) {
    throw new Error(`${fieldName} precisa ser um número inteiro maior que zero.`);
  }
  return number;
}

function saveOpening() {
  const opening = {};
  PRODUCTS.forEach((product) => {
    const full = parseNonNegativeNumber(byId(`open-full-${product.code}`).value, `${product.code} cheio`);
    const empty = parseNonNegativeNumber(byId(`open-empty-${product.code}`).value, `${product.code} vazio`);
    opening[product.code] = { full, empty };
  });

  state.opening = opening;
  state.dayStatus = "aberto";
  state.closing = null;
  saveState();
  renderAll();
  toast("Abertura da manhã confirmada.");
  showScreen("dashboard");
}

function fillOpeningExample() {
  state.opening = JSON.parse(JSON.stringify(OPENING_EXAMPLE));
  state.dayStatus = "aberto";
  saveState();
  renderAll();
  toast("Exemplo validado preenchido.");
}

function requireOpenDay() {
  if (state.dayStatus === "aguardando_abertura") {
    throw new Error("Faça a abertura da manhã antes de lançar movimentos.");
  }
  if (state.dayStatus === "fechado") {
    throw new Error("O dia já está fechado. Novos lançamentos estão bloqueados.");
  }
}

function saveSale(keepOnScreen = false) {
  requireOpenDay();

  const channel = byId("saleChannel").value;
  const productCode = byId("saleProduct").value;
  const qty = parsePositiveNumber(byId("saleQty").value, "Quantidade vendida do líquido");
  const cascoQty = cascoEnabled ? parseNonNegativeNumber(byId("saleCascoQty").value || "0", "Quantidade de cascos") : 0;

  if (!channel) throw new Error("Selecione o canal de venda.");
  if (cascoQty > qty) {
    throw new Error("A quantidade de cascos vendidos não pode ser maior que a venda do líquido.");
  }

  const saleId = crypto.randomUUID ? crypto.randomUUID() : `${Date.now()}-${Math.random()}`;
  const now = new Date().toISOString();

  state.movements.push({
    id: saleId,
    createdAt: now,
    channel,
    productCode,
    type: "venda_liquido",
    qty,
    label: `Venda do líquido — ${channel}`
  });

  if (cascoQty > 0) {
    state.movements.push({
      id: crypto.randomUUID ? crypto.randomUUID() : `${Date.now()}-${Math.random()}`,
      linkedTo: saleId,
      createdAt: now,
      channel,
      productCode,
      type: "venda_casco",
      qty: cascoQty,
      label: `Venda de casco — ${channel}`
    });
  }

  saveState();
  renderAll();
  clearSaleForm();
  toast("Venda lançada.");

  if (!keepOnScreen) showScreen("dashboard");
}

function clearSaleForm() {
  byId("saleQty").value = "";
  byId("saleCascoQty").value = "";
  cascoEnabled = false;
  renderCascoToggle();
}

function saveEntry() {
  requireOpenDay();

  const productCode = byId("entryProduct").value;
  const qty = parsePositiveNumber(byId("entryQty").value, "Quantidade de entrada");

  const stock = calculateStock();
  if (qty > stock[productCode].empty) {
    throw new Error("Entrada maior que os vazios disponíveis. Regra especial futura precisa ser autorizada.");
  }

  state.movements.push({
    id: crypto.randomUUID ? crypto.randomUUID() : `${Date.now()}-${Math.random()}`,
    createdAt: new Date().toISOString(),
    channel: null,
    productCode,
    type: "entrada_cheia",
    qty,
    label: "Entrada de cheio"
  });

  byId("entryQty").value = "";
  saveState();
  renderAll();
  toast("Entrada lançada.");
  showScreen("dashboard");
}

function calculateStock() {
  const stock = {};

  PRODUCTS.forEach((product) => {
    stock[product.code] = {
      full: state.opening?.[product.code]?.full ?? 0,
      empty: state.opening?.[product.code]?.empty ?? 0
    };
  });

  state.movements.forEach((movement) => {
    const item = stock[movement.productCode];
    if (!item) return;

    if (movement.type === "entrada_cheia") {
      item.full += movement.qty;
      item.empty -= movement.qty;
    }

    if (movement.type === "venda_liquido") {
      item.full -= movement.qty;
      item.empty += movement.qty;
    }

    if (movement.type === "venda_casco") {
      item.empty -= movement.qty;
    }
  });

  return stock;
}

function renderSummary() {
  const stock = calculateStock();
  const stockSummary = byId("stockSummary");
  stockSummary.innerHTML = "";

  PRODUCTS.forEach((product) => {
    const item = stock[product.code];
    const row = document.createElement("div");
    row.className = "table-row";
    row.innerHTML = `
      <div>
        <strong>${product.code}</strong>
        <span class="muted">${product.name}</span>
      </div>
      <div>
        <strong>${item.full} cheios</strong>
        <span class="muted">${item.empty} vazios</span>
      </div>
    `;
    stockSummary.appendChild(row);
  });

  const movementSummary = byId("movementSummary");
  movementSummary.innerHTML = "";

  if (state.movements.length === 0) {
    movementSummary.innerHTML = `<p class="muted">Nenhum movimento lançado ainda.</p>`;
    return;
  }

  state.movements.slice().reverse().forEach((movement) => {
    const item = document.createElement("div");
    item.className = "movement-item";
    item.innerHTML = `
      <strong>${movement.productCode} — ${movement.qty}</strong>
      <p class="muted">${movement.label}${movement.channel ? ` • Canal: ${movement.channel}` : ""}</p>
    `;
    movementSummary.appendChild(item);
  });
}

function runClosing() {
  if (state.dayStatus === "aguardando_abertura") {
    throw new Error("Não é possível fechar sem abertura da manhã.");
  }

  const stock = calculateStock();
  const closingItems = {};
  let hasDivergence = false;

  PRODUCTS.forEach((product) => {
    const full = parseNonNegativeNumber(byId(`close-full-${product.code}`).value, `${product.code} cheio físico`);
    const empty = parseNonNegativeNumber(byId(`close-empty-${product.code}`).value, `${product.code} vazio físico`);
    const calculated = stock[product.code];

    const diffFull = full - calculated.full;
    const diffEmpty = empty - calculated.empty;
    const diffTotal = (full + empty) - (calculated.full + calculated.empty);

    if (diffFull !== 0 || diffEmpty !== 0 || diffTotal !== 0) {
      hasDivergence = true;
    }

    closingItems[product.code] = {
      calculatedFull: calculated.full,
      calculatedEmpty: calculated.empty,
      calculatedTotal: calculated.full + calculated.empty,
      full,
      empty,
      total: full + empty,
      diffFull,
      diffEmpty,
      diffTotal,
      status: diffFull === 0 && diffEmpty === 0 && diffTotal === 0 ? "conferido" : "inconsistente"
    };
  });

  state.closing = {
    createdAt: new Date().toISOString(),
    items: closingItems,
    status: hasDivergence ? "inconsistente" : "conferido"
  };
  state.dayStatus = hasDivergence ? "inconsistente" : "fechado";
  saveState();
  renderClosingResult();
  renderDashboard();
}

function renderClosingResult() {
  if (!state.closing) return;

  const result = byId("closingResult");
  result.classList.remove("hidden");

  const rows = PRODUCTS.map((product) => {
    const item = state.closing.items[product.code];
    const ok = item.status === "conferido";
    return `
      <div class="table-row">
        <div>
          <strong>${product.code}</strong>
          <span class="${ok ? "status-ok" : "status-bad"}">${item.status}</span>
        </div>
        <div>
          <strong>Dif.: ${item.diffFull}/${item.diffEmpty}/${item.diffTotal}</strong>
          <span class="muted">${item.full} cheios / ${item.empty} vazios</span>
        </div>
      </div>
    `;
  }).join("");

  const title = state.closing.status === "conferido"
    ? "Estoque conferido com sucesso."
    : "Estoque inconsistente. Revisão obrigatória.";

  const extra = state.closing.status === "conferido"
    ? `<p class="status-ok">Dia encerrado. Estoque fechado, turno encerrado.</p>`
    : `<p class="status-bad">Encerramento bloqueado até corrigir divergências.</p>`;

  result.innerHTML = `
    <h3>${title}</h3>
    <div class="table-like">${rows}</div>
    ${extra}
  `;
}

function renderCascoToggle() {
  const button = byId("toggleCascoButton");
  const field = byId("cascoField");
  button.textContent = cascoEnabled ? "Sim" : "Não";
  button.classList.toggle("active", cascoEnabled);
  button.setAttribute("aria-pressed", String(cascoEnabled));
  field.classList.toggle("hidden", !cascoEnabled);
}

function renderSelects() {
  fillSelect(byId("saleChannel"), CHANNELS);
  fillSelect(byId("saleProduct"), PRODUCTS, (x) => x.code, (x) => `${x.code} — ${x.name}`);
  fillSelect(byId("entryProduct"), PRODUCTS, (x) => x.code, (x) => `${x.code} — ${x.name}`);
}

function renderAll() {
  renderDashboard();
  renderOpeningForm();
  renderSelects();
  renderSummary();
}

function bindEvents() {
  document.querySelectorAll("[data-nav]").forEach((button) => {
    button.addEventListener("click", () => showScreen(button.dataset.nav));
  });

  byId("resetDemoButton").addEventListener("click", resetState);
  byId("saveOpeningButton").addEventListener("click", () => safeAction(saveOpening));
  byId("fillOpeningExampleButton").addEventListener("click", fillOpeningExample);
  byId("toggleCascoButton").addEventListener("click", () => {
    cascoEnabled = !cascoEnabled;
    renderCascoToggle();
  });
  byId("saveSaleButton").addEventListener("click", () => safeAction(() => saveSale(false)));
  byId("saveSaleAnotherButton").addEventListener("click", () => safeAction(() => saveSale(true)));
  byId("saveEntryButton").addEventListener("click", () => safeAction(saveEntry));
  byId("runClosingButton").addEventListener("click", () => safeAction(runClosing));
}

function safeAction(fn) {
  try {
    fn();
  } catch (error) {
    toast(error.message || "Erro ao executar operação.");
  }
}

bindEvents();
renderCascoToggle();
renderAll();
