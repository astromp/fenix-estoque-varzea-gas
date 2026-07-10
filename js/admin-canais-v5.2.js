/* Projeto Fênix Estoque — V5.2
   Administração autenticada de canais por revenda.
   A V5.1 permanece preservada. */

(function iniciarAdminCanaisV52() {
  const estadoAdmin = {
    sessao: null,
    revendas: [],
    canais: [],
    revendaId: null
  };

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
    if (!grade || !principal || document.querySelector('[data-nav="admin-channels"]')) return;

    const botao = document.createElement("button");
    botao.className = "action-card";
    botao.dataset.nav = "admin-channels";
    botao.innerHTML = "<strong>Administrar canais</strong><span>Cadastrar, editar, ativar e desativar</span>";
    grade.insertBefore(botao, grade.querySelector('[data-nav="log"]'));

    const secao = document.createElement("section");
    secao.id = "screen-admin-channels";
    secao.className = "screen";
    secao.innerHTML = `
      <div class="screen-title">
        <button class="back-button" data-nav="dashboard">←</button>
        <div>
          <p class="eyebrow">Administração V5.2</p>
          <h2>Gestão de canais</h2>
        </div>
      </div>

      <div id="adminLoginCard" class="card">
        <h3>Acesso administrativo</h3>
        <p class="muted">Entre com um usuário autenticado do Supabase. As funções administrativas não aceitam acesso público.</p>
        <label for="adminEmail">E-mail</label>
        <input id="adminEmail" type="email" autocomplete="username" placeholder="administrador@empresa.com" />
        <label for="adminPassword">Senha</label>
        <input id="adminPassword" type="password" autocomplete="current-password" placeholder="Senha" />
        <button id="adminLoginButton" class="primary-button">Entrar</button>
      </div>

      <div id="adminPanel" class="hidden">
        <div class="card">
          <div class="status-line">
            <strong>Usuário autenticado</strong>
            <span id="adminUserEmail" class="ok">—</span>
          </div>
          <button id="adminLogoutButton" class="ghost-button">Sair da administração</button>
        </div>

        <div class="card">
          <label for="adminRevendaSelect">Revenda</label>
          <select id="adminRevendaSelect"></select>
          <button id="adminRefreshButton" class="ghost-button">Atualizar canais</button>
        </div>

        <div class="card">
          <h3>Novo canal</h3>
          <label for="adminNewChannelName">Nome do canal</label>
          <input id="adminNewChannelName" type="text" maxlength="80" placeholder="Ex.: Balcão" />
          <button id="adminCreateChannelButton" class="primary-button">Cadastrar canal</button>
        </div>

        <div class="card">
          <h3>Canais da revenda</h3>
          <div id="adminChannelsList"><p class="muted">Carregando canais...</p></div>
        </div>
      </div>`;
    principal.appendChild(secao);
  }

  function client() {
    return supabaseClient();
  }

  function mostrarSessao(sessao) {
    estadoAdmin.sessao = sessao || null;
    const login = document.querySelector("#adminLoginCard");
    const painel = document.querySelector("#adminPanel");
    const email = document.querySelector("#adminUserEmail");
    if (!login || !painel) return;

    if (sessao?.user) {
      login.classList.add("hidden");
      painel.classList.remove("hidden");
      if (email) email.textContent = sessao.user.email || "usuário autenticado";
    } else {
      login.classList.remove("hidden");
      painel.classList.add("hidden");
      if (email) email.textContent = "—";
    }
  }

  async function verificarSessao() {
    const { data, error } = await client().auth.getSession();
    if (error) throw error;
    mostrarSessao(data.session);
    if (data.session) await carregarRevendas();
  }

  async function entrar() {
    const email = document.querySelector("#adminEmail")?.value.trim();
    const password = document.querySelector("#adminPassword")?.value || "";
    if (!email || !password) {
      toast("Informe e-mail e senha.", "error");
      return;
    }
    const botao = document.querySelector("#adminLoginButton");
    if (botao) botao.disabled = true;
    try {
      const { data, error } = await client().auth.signInWithPassword({ email, password });
      if (error) throw error;
      mostrarSessao(data.session);
      await carregarRevendas();
      toast("Acesso administrativo liberado.", "success");
    } catch (err) {
      toast(err.message || "Falha no login.", "error");
      log("Login administrativo V5.2 — erro", err.message || String(err));
    } finally {
      if (botao) botao.disabled = false;
    }
  }

  async function sair() {
    const { error } = await client().auth.signOut();
    if (error) {
      toast(error.message, "error");
      return;
    }
    estadoAdmin.revendas = [];
    estadoAdmin.canais = [];
    estadoAdmin.revendaId = null;
    mostrarSessao(null);
    toast("Sessão administrativa encerrada.", "success");
  }

  async function carregarRevendas() {
    const { data, error } = await client().rpc("listar_revendas_ativas");
    if (error) throw error;
    estadoAdmin.revendas = data || [];
    const select = document.querySelector("#adminRevendaSelect");
    if (!select) return;
    select.innerHTML = estadoAdmin.revendas.map((r) =>
      `<option value="${escaparHtml(r.revenda_id)}">${escaparHtml(r.nome)}${r.cidade ? ` — ${escaparHtml(r.cidade)}` : ""}</option>`
    ).join("");
    estadoAdmin.revendaId = select.value || null;
    await carregarCanais();
  }

  async function carregarCanais() {
    const select = document.querySelector("#adminRevendaSelect");
    estadoAdmin.revendaId = select?.value || estadoAdmin.revendaId;
    if (!estadoAdmin.revendaId) {
      document.querySelector("#adminChannelsList").innerHTML = '<p class="muted">Nenhuma revenda ativa encontrada.</p>';
      return;
    }
    const { data, error } = await client().rpc("listar_canais_revenda", {
      p_revenda_id: estadoAdmin.revendaId,
      p_incluir_inativos: true
    });
    if (error) throw error;
    estadoAdmin.canais = data || [];
    renderizarCanais();
  }

  function renderizarCanais() {
    const lista = document.querySelector("#adminChannelsList");
    if (!lista) return;
    if (!estadoAdmin.canais.length) {
      lista.innerHTML = '<p class="muted">Nenhum canal cadastrado nesta revenda.</p>';
      return;
    }

    lista.innerHTML = estadoAdmin.canais.map((canal) => `
      <div class="card" data-channel-id="${escaparHtml(canal.canal_venda_id)}">
        <div class="status-line">
          <strong>${escaparHtml(canal.nome)}</strong>
          <span class="${canal.ativo ? "ok" : "warn"}">${canal.ativo ? "ativo" : "inativo"}</span>
        </div>
        <label>Novo nome</label>
        <input class="admin-channel-rename" type="text" maxlength="80" value="${escaparHtml(canal.nome)}" />
        <button class="ghost-button admin-rename-button">Renomear</button>
        <button class="ghost-button admin-toggle-button">${canal.ativo ? "Desativar" : "Ativar"}</button>
        <button class="danger-button admin-delete-button">Excluir se nunca utilizado</button>
      </div>
    `).join("");

    lista.querySelectorAll("[data-channel-id]").forEach((card) => {
      const id = card.dataset.channelId;
      const canal = estadoAdmin.canais.find((c) => c.canal_venda_id === id);
      card.querySelector(".admin-rename-button")?.addEventListener("click", () => renomearCanal(id, card));
      card.querySelector(".admin-toggle-button")?.addEventListener("click", () => definirStatus(id, !canal.ativo));
      card.querySelector(".admin-delete-button")?.addEventListener("click", () => excluirCanal(id, canal.nome));
    });
  }

  async function cadastrarCanal() {
    const input = document.querySelector("#adminNewChannelName");
    const nome = input?.value.trim();
    if (!nome) {
      toast("Informe o nome do canal.", "error");
      return;
    }
    try {
      const { error } = await client().rpc("cadastrar_canal_revenda", {
        p_revenda_id: estadoAdmin.revendaId,
        p_nome: nome
      });
      if (error) throw error;
      input.value = "";
      await carregarCanais();
      toast("Canal cadastrado.", "success");
    } catch (err) {
      toast(err.message || "Erro ao cadastrar canal.", "error");
    }
  }

  async function renomearCanal(id, card) {
    const nome = card.querySelector(".admin-channel-rename")?.value.trim();
    if (!nome) {
      toast("Informe o novo nome.", "error");
      return;
    }
    try {
      const { error } = await client().rpc("renomear_canal_revenda", {
        p_canal_id: id,
        p_novo_nome: nome
      });
      if (error) throw error;
      await carregarCanais();
      toast("Canal renomeado.", "success");
    } catch (err) {
      toast(err.message || "Erro ao renomear canal.", "error");
    }
  }

  async function definirStatus(id, ativo) {
    try {
      const { error } = await client().rpc("definir_status_canal_revenda", {
        p_canal_id: id,
        p_ativo: ativo
      });
      if (error) throw error;
      await carregarCanais();
      toast(ativo ? "Canal ativado." : "Canal desativado.", "success");
    } catch (err) {
      toast(err.message || "Erro ao alterar status.", "error");
    }
  }

  async function excluirCanal(id, nome) {
    if (!window.confirm(`Excluir definitivamente o canal "${nome}"? Isso só funcionará se ele nunca tiver sido utilizado.`)) return;
    try {
      const { error } = await client().rpc("excluir_canal_sem_historico", {
        p_canal_id: id
      });
      if (error) throw error;
      await carregarCanais();
      toast("Canal sem histórico excluído.", "success");
    } catch (err) {
      toast(err.message || "Canal com histórico deve ser desativado.", "error");
    }
  }

  function ligarEventos() {
    document.querySelectorAll('[data-nav="admin-channels"]').forEach((botao) => {
      botao.addEventListener("click", async () => {
        navegar("admin-channels");
        try {
          await verificarSessao();
        } catch (err) {
          toast(err.message || "Erro ao verificar sessão.", "error");
        }
      });
    });
    document.querySelectorAll('#screen-admin-channels [data-nav="dashboard"]').forEach((botao) => {
      botao.addEventListener("click", () => navegar("dashboard"));
    });
    document.querySelector("#adminLoginButton")?.addEventListener("click", entrar);
    document.querySelector("#adminLogoutButton")?.addEventListener("click", sair);
    document.querySelector("#adminRefreshButton")?.addEventListener("click", carregarCanais);
    document.querySelector("#adminCreateChannelButton")?.addEventListener("click", cadastrarCanal);
    document.querySelector("#adminRevendaSelect")?.addEventListener("change", carregarCanais);
  }

  function iniciar() {
    criarInterface();
    ligarEventos();
    log("V5.2 carregada", "Tela administrativa autenticada de canais disponível para homologação.");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", iniciar);
  } else {
    iniciar();
  }
})();