(() => {
  "use strict";

  const PRODUTOS = [
    { codigo: "P13", nome: "P13" },
    { codigo: "P05", nome: "P05" },
    { codigo: "P20", nome: "P20" },
    { codigo: "P45", nome: "P45" },
    { codigo: "AGUA", nome: "Água / galão" }
  ];

  const estado = {
    client: null,
    session: null,
    acesso: null,
    revenda: null,
    status: "nao_consultado",
    busy: false
  };

  const $ = (selector) => document.querySelector(selector);
  const $$ = (selector) => Array.from(document.querySelectorAll(selector));

  const ui = {
    badge: $("#connectionBadge"),
    screenConfig: $("#screen-config"),
    screenLogin: $("#screen-login"),
    screenPassword: $("#screen-password"),
    screenApp: $("#screen-app"),
    loginForm: $("#loginForm"),
    loginEmail: $("#loginEmail"),
    loginPassword: $("#loginPassword"),
    toggleLoginPassword: $("#toggleLoginPassword"),
    loginButton: $("#loginButton"),
    loginMessage: $("#loginMessage"),
    passwordForm: $("#passwordForm"),
    newPassword: $("#newPassword"),
    confirmPassword: $("#confirmPassword"),
    toggleNewPassword: $("#toggleNewPassword"),
    savePasswordButton: $("#savePasswordButton"),
    passwordMessage: $("#passwordMessage"),
    userLabel: $("#userLabel"),
    revendaLabel: $("#revendaLabel"),
    logoutButton: $("#logoutButton"),
    operationDate: $("#operationDate"),
    dateTitle: $("#dateTitle"),
    dashboardMessage: $("#dashboardMessage"),
    statusPanel: $("#statusPanel"),
    refreshStatusButton: $("#refreshStatusButton"),
    openEntryButton: $("#openEntryButton"),
    openStockButton: $("#openStockButton"),
    entryProduct: $("#entryProduct"),
    entryQty: $("#entryQty"),
    previewFull: $("#previewFull"),
    previewEmpty: $("#previewEmpty"),
    saveEntryButton: $("#saveEntryButton"),
    entryResultCard: $("#entryResultCard"),
    entryResult: $("#entryResult"),
    queryStockButton: $("#queryStockButton"),
    stockList: $("#stockList"),
    toast: $("#toast")
  };

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

  function hojeISO() {
    const agora = new Date();
    const local = new Date(agora.getTime() - agora.getTimezoneOffset() * 60000);
    return local.toISOString().slice(0, 10);
  }

  function dataOperacional() {
    return ui.operationDate.value || hojeISO();
  }

  function numeroInteiroPositivo(valor) {
    const numero = Number(valor);
    return Number.isInteger(numero) && numero > 0 ? numero : 0;
  }

  function showScreen(screen) {
    [ui.screenConfig, ui.screenLogin, ui.screenPassword, ui.screenApp].forEach((item) => item.classList.add("hidden"));
    screen.classList.remove("hidden");
  }

  function showView(nome) {
    $$(".view").forEach((view) => view.classList.remove("active"));
    $(`#view-${nome}`).classList.add("active");
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  function toast(mensagem, tipo = "") {
    ui.toast.textContent = mensagem;
    ui.toast.className = `toast ${tipo}`.trim();
    clearTimeout(window.__fenixToastTimer);
    window.__fenixToastTimer = setTimeout(() => ui.toast.classList.add("hidden"), 4200);
  }

  function setBadge(texto, tipo = "warn") {
    ui.badge.textContent = texto;
    ui.badge.className = `badge badge-${tipo}`;
  }

  function setBusy(busy, botao = null) {
    estado.busy = busy;
    [ui.loginButton, ui.savePasswordButton, ui.refreshStatusButton, ui.saveEntryButton, ui.queryStockButton].forEach((item) => {
      if (item) item.disabled = busy;
    });
    if (!busy) aplicarBloqueiosStatus();
    if (botao) botao.dataset.originalText ||= botao.textContent;
    if (botao) botao.textContent = busy ? "Aguarde..." : botao.dataset.originalText;
  }

  function friendlyError(error) {
    const raw = String(error?.message || error || "Erro inesperado.");
    const lower = raw.toLowerCase();
    if (lower.includes("vazios insuficientes")) {
      const detalhe = raw.match(/Disponível:\s*\d+,\s*solicitado:\s*\d+\.?/i)?.[0];
      return `Não há vazios suficientes para esta entrada.${detalhe ? ` ${detalhe}` : " Confira o saldo e tente novamente."}`;
    }
    if (lower.includes("usuário não autenticado") || lower.includes("jwt")) return "Sua sessão expirou. Entre novamente.";
    if (lower.includes("sem autorização")) return "Seu usuário não tem autorização para esta revenda.";
    if (lower.includes("dia operacional não encontrado") || lower.includes("faça a abertura")) return "Faça a abertura do dia antes de registrar a entrada de carga.";
    if (lower.includes("somente com o dia aberto") || lower.includes("dia já está fechado")) return "A entrada de carga só pode ser registrada enquanto o dia estiver aberto.";
    if (lower.includes("invalid login credentials")) return "E-mail ou senha incorretos.";
    if (lower.includes("email not confirmed")) return "O e-mail ainda não foi confirmado no Supabase.";
    return raw;
  }

  function perfilLegivel(perfil) {
    return perfil === "operador_conferente" ? "operador/conferente" : String(perfil || "usuário").replaceAll("_", "/");
  }

  function statusNormalizado(retorno) {
    return String(retorno?.status_dia || retorno?.status || "nao_consultado").toLowerCase();
  }

  function statusClasse(status) {
    if (status === "aberto" || status === "fechado") return "ok";
    if (status === "inconsistente") return "danger";
    return "warn";
  }

  function statusTexto(status) {
    return ({
      nao_consultado: "não consultado",
      sem_abertura: "sem abertura",
      aberto: "aberto",
      inconsistente: "inconsistente",
      fechado: "fechado"
    })[status] || status;
  }

  function aplicarBloqueiosStatus() {
    if (estado.busy) return;
    const diaAberto = estado.status === "aberto";
    const temDia = !["nao_consultado", "sem_abertura"].includes(estado.status);
    ui.openEntryButton.disabled = !diaAberto;
    ui.openStockButton.disabled = !temDia;
    ui.saveEntryButton.disabled = !diaAberto;
  }

  function renderStatus(retorno = null) {
    const status = estado.status;
    ui.dateTitle.textContent = `Operação diária — ${dataOperacional()}`;
    ui.dashboardMessage.textContent = retorno?.mensagem || ({
      nao_consultado: "Atualize o status do dia.",
      sem_abertura: "Dia sem abertura. Faça a contagem inicial antes de lançar movimentos.",
      aberto: "Dia aberto. Entrada de carga liberada.",
      inconsistente: "Estoque inconsistente. Revise antes de encerrar.",
      fechado: "Estoque fechado, turno encerrado."
    })[status] || "Status do dia atualizado.";

    ui.statusPanel.innerHTML = `
      <div class="status-line"><strong>Status</strong><span class="${statusClasse(status)}">${statusTexto(status)}</span></div>
      <div class="status-line"><strong>Revenda</strong><span>${escapeHtml(estado.revenda?.nome || "-")}</span></div>
      <div class="status-line"><strong>Data</strong><span>${escapeHtml(dataOperacional())}</span></div>
    `;
    aplicarBloqueiosStatus();
  }

  function escapeHtml(value) {
    return String(value ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#039;");
  }

  function client() {
    if (estado.client) return estado.client;
    if (!window.supabase) throw new Error("Biblioteca do Supabase não carregou.");
    if (!configPronta()) throw new Error("Configuração do Supabase pendente.");
    estado.client = window.supabase.createClient(config().SUPABASE_URL, config().SUPABASE_ANON_KEY, {
      auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true }
    });
    return estado.client;
  }

  async function rpc(nome, parametros = {}) {
    const { data, error } = await client().rpc(nome, parametros);
    if (error) throw error;
    return data;
  }

  async function carregarAcesso() {
    const acesso = await rpc("consultar_meu_acesso_fenix");
    if (!acesso?.ok) throw new Error(acesso?.mensagem || "Usuário sem acesso ativo ao Projeto Fênix.");
    if (!Array.isArray(acesso.revendas) || acesso.revendas.length === 0) throw new Error("Nenhuma revenda autorizada foi encontrada para este usuário.");

    estado.acesso = acesso;
    estado.revenda = acesso.revendas[0];
    ui.userLabel.textContent = `${acesso.nome} · ${perfilLegivel(acesso.perfil || estado.revenda.perfil)}`;
    ui.revendaLabel.textContent = `${estado.revenda.nome}${estado.revenda.cidade ? ` — ${estado.revenda.cidade}` : ""}`;

    if (acesso.trocar_senha_primeiro_acesso) {
      setBadge("Trocar senha", "warn");
      showScreen(ui.screenPassword);
      return;
    }

    setBadge("Conectado", "ok");
    showScreen(ui.screenApp);
    showView("dashboard");
    await consultarStatus();
  }

  async function restaurarSessao() {
    if (!configPronta()) {
      setBadge("Configurar", "warn");
      showScreen(ui.screenConfig);
      return;
    }

    try {
      const { data, error } = await client().auth.getSession();
      if (error) throw error;
      estado.session = data.session;
      if (!estado.session) {
        setBadge("Desconectado", "warn");
        showScreen(ui.screenLogin);
        return;
      }
      await carregarAcesso();
    } catch (error) {
      setBadge("Erro de acesso", "danger");
      showScreen(ui.screenLogin);
      ui.loginMessage.textContent = friendlyError(error);
      ui.loginMessage.className = "form-message danger";
    }
  }

  async function entrar(event) {
    event.preventDefault();
    const email = ui.loginEmail.value.trim();
    const password = ui.loginPassword.value;
    if (!email || !password) {
      ui.loginMessage.textContent = "Informe o e-mail e a senha.";
      ui.loginMessage.className = "form-message danger";
      return;
    }

    setBusy(true, ui.loginButton);
    ui.loginMessage.textContent = "Entrando...";
    ui.loginMessage.className = "form-message muted";
    try {
      const { data, error } = await client().auth.signInWithPassword({ email, password });
      if (error) throw error;
      estado.session = data.session;
      ui.loginPassword.value = "";
      await carregarAcesso();
    } catch (error) {
      ui.loginMessage.textContent = friendlyError(error);
      ui.loginMessage.className = "form-message danger";
    } finally {
      setBusy(false, ui.loginButton);
    }
  }

  async function trocarSenha(event) {
    event.preventDefault();
    const senha = ui.newPassword.value;
    const confirmacao = ui.confirmPassword.value;
    if (senha.length < 8) {
      ui.passwordMessage.textContent = "A nova senha precisa ter pelo menos 8 caracteres.";
      ui.passwordMessage.className = "form-message danger";
      return;
    }
    if (senha !== confirmacao) {
      ui.passwordMessage.textContent = "As duas senhas precisam ser iguais.";
      ui.passwordMessage.className = "form-message danger";
      return;
    }

    setBusy(true, ui.savePasswordButton);
    ui.passwordMessage.textContent = "Salvando nova senha...";
    ui.passwordMessage.className = "form-message muted";
    try {
      const { error } = await client().auth.updateUser({ password: senha });
      if (error) throw error;
      await rpc("concluir_primeiro_acesso_fenix");
      ui.newPassword.value = "";
      ui.confirmPassword.value = "";
      toast("Nova senha salva com sucesso.", "success");
      await carregarAcesso();
    } catch (error) {
      ui.passwordMessage.textContent = friendlyError(error);
      ui.passwordMessage.className = "form-message danger";
    } finally {
      setBusy(false, ui.savePasswordButton);
    }
  }

  async function sair() {
    setBusy(true, ui.logoutButton);
    try {
      await client().auth.signOut();
    } finally {
      estado.session = null;
      estado.acesso = null;
      estado.revenda = null;
      estado.status = "nao_consultado";
      setBadge("Desconectado", "warn");
      showScreen(ui.screenLogin);
      setBusy(false, ui.logoutButton);
    }
  }

  async function consultarStatus() {
    if (!estado.revenda?.id) return;
    setBusy(true, ui.refreshStatusButton);
    try {
      const retorno = await rpc("consultar_status_dia_mvp", {
        p_revenda_id: estado.revenda.id,
        p_data_operacional: dataOperacional()
      });
      estado.status = statusNormalizado(retorno);
      renderStatus(retorno);
      toast(`Status do dia: ${statusTexto(estado.status)}.`, estado.status === "inconsistente" ? "error" : "success");
    } catch (error) {
      estado.status = "nao_consultado";
      renderStatus();
      toast(friendlyError(error), "error");
    } finally {
      setBusy(false, ui.refreshStatusButton);
    }
  }

  function atualizarPreview() {
    const quantidade = numeroInteiroPositivo(ui.entryQty.value);
    ui.previewFull.textContent = String(quantidade);
    ui.previewEmpty.textContent = String(quantidade);
  }

  async function registrarEntrada() {
    const produto = ui.entryProduct.value;
    const quantidade = numeroInteiroPositivo(ui.entryQty.value);
    if (estado.status !== "aberto") {
      toast("A entrada de carga só pode ser registrada com o dia aberto.", "error");
      return;
    }
    if (!produto || quantidade <= 0) {
      toast("Informe o produto e uma quantidade inteira maior que zero.", "error");
      return;
    }

    const confirmou = window.confirm(
      `Confirmar entrada de ${quantidade} ${produto}?\n\n` +
      `${quantidade} cheios entrarão e ${quantidade} vazios sairão.`
    );
    if (!confirmou) return;

    setBusy(true, ui.saveEntryButton);
    try {
      const retorno = await rpc("registrar_entrada_carga_mvp", {
        p_revenda_id: estado.revenda.id,
        p_data_operacional: dataOperacional(),
        p_produto_codigo: produto,
        p_quantidade: quantidade
      });

      ui.entryResult.innerHTML = `
        <div class="table-row"><strong>Produto</strong><span>${escapeHtml(retorno.produto || produto)}</span></div>
        <div class="table-row"><strong>Cheios recebidos</strong><span class="ok">+${escapeHtml(retorno.cheios_adicionados ?? quantidade)}</span></div>
        <div class="table-row"><strong>Vazios entregues</strong><span class="warn">-${escapeHtml(retorno.vazios_retirados ?? quantidade)}</span></div>
        <div class="table-row"><strong>Vazios antes</strong><span>${escapeHtml(retorno.vazios_antes ?? "-")}</span></div>
        <div class="table-row"><strong>Vazios depois</strong><span>${escapeHtml(retorno.vazios_depois ?? "-")}</span></div>
      `;
      ui.entryResultCard.classList.remove("hidden");
      ui.entryQty.value = "";
      atualizarPreview();
      toast("Entrada registrada: cheios recebidos e vazios entregues.", "success");
      await consultarStatus();
    } catch (error) {
      toast(friendlyError(error), "error");
    } finally {
      setBusy(false, ui.saveEntryButton);
    }
  }

  async function consultarEstoque() {
    setBusy(true, ui.queryStockButton);
    ui.stockList.innerHTML = '<p class="muted">Consultando estoque...</p>';
    try {
      const retorno = await rpc("consultar_estoque_mvp", {
        p_revenda_id: estado.revenda.id,
        p_data_operacional: dataOperacional()
      });
      const itens = Array.isArray(retorno?.itens) ? retorno.itens : [];
      if (!itens.length) throw new Error("O banco não retornou os produtos do estoque.");
      ui.stockList.innerHTML = itens.map((item) => `
        <div class="stock-card">
          <div class="stock-card-head"><strong>${escapeHtml(item.produto)}</strong><span>${escapeHtml(item.nome || "")}</span></div>
          <div class="stock-numbers">
            <div><span>Cheios</span><b>${escapeHtml(item.cheios_calculados)}</b></div>
            <div><span>Vazios</span><b>${escapeHtml(item.vazios_calculados)}</b></div>
            <div><span>Total</span><b>${escapeHtml(item.total_calculado)}</b></div>
          </div>
        </div>
      `).join("");
      toast("Estoque consultado.", "success");
    } catch (error) {
      ui.stockList.innerHTML = `<p class="danger">${escapeHtml(friendlyError(error))}</p>`;
      toast(friendlyError(error), "error");
    } finally {
      setBusy(false, ui.queryStockButton);
    }
  }

  function togglePassword(input, button) {
    const mostrar = input.type === "password";
    input.type = mostrar ? "text" : "password";
    button.textContent = mostrar ? "Ocultar" : "Mostrar";
    button.setAttribute("aria-pressed", mostrar ? "true" : "false");
  }

  function ligarEventos() {
    ui.loginForm.addEventListener("submit", entrar);
    ui.passwordForm.addEventListener("submit", trocarSenha);
    ui.toggleLoginPassword.addEventListener("click", () => togglePassword(ui.loginPassword, ui.toggleLoginPassword));
    ui.toggleNewPassword.addEventListener("click", () => togglePassword(ui.newPassword, ui.toggleNewPassword));
    ui.logoutButton.addEventListener("click", sair);
    ui.refreshStatusButton.addEventListener("click", consultarStatus);
    ui.operationDate.addEventListener("change", () => {
      estado.status = "nao_consultado";
      ui.entryResultCard.classList.add("hidden");
      renderStatus();
      showView("dashboard");
    });
    ui.openEntryButton.addEventListener("click", () => showView("entry"));
    ui.openStockButton.addEventListener("click", () => showView("stock"));
    $$('[data-view]').forEach((button) => button.addEventListener("click", () => showView(button.dataset.view)));
    ui.entryQty.addEventListener("input", atualizarPreview);
    ui.saveEntryButton.addEventListener("click", registrarEntrada);
    ui.queryStockButton.addEventListener("click", consultarEstoque);
  }

  async function iniciar() {
    ui.operationDate.value = hojeISO();
    atualizarPreview();
    ligarEventos();

    if (configPronta()) {
      client().auth.onAuthStateChange((_event, session) => {
        estado.session = session;
      });
    }

    await restaurarSessao();
  }

  document.addEventListener("DOMContentLoaded", iniciar);
})();
