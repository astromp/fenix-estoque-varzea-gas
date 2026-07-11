# RETOMAR AQUI — Projeto Fênix Estoque

**Versão homologada em produção:** V5.6.2  
**Evolução em implementação:** V5.7 — entrada de carga  
**Data:** 11/07/2026

## Estado homologado

- V5.4 operação multi-revenda homologada.
- V5.5 relatórios multi-revenda homologados.
- V5.6.2 login seguro homologado.
- Todas as operações novas exigem `p_revenda_id`.
- Várzea Gás e Vinhedo Gás foram testadas e permaneceram segregadas.
- CSV de ambas as unidades foi validado.
- Impressão gerencial foi validada.
- Acesso anônimo às funções operacionais foi bloqueado.

## Usuário do piloto

- Nome: Alex
- E-mail: `varzeaglp@gmail.com`
- Perfil: `operador_conferente`
- Revenda exclusiva: Várzea Gás
- Usuário ativo: sim
- Vínculo ativo: sim
- Troca de senha no primeiro acesso: obrigatória

Não registrar senha no GitHub ou em documentos do projeto.

## Segurança homologada

Para as sete funções operacionais multi-revenda:

```text
authenticated_pode_executar = true
anon_pode_executar = false
public_pode_executar = false
```

## V5.7 — entrada de carga criada no GitHub

Em 11/07/2026 foram criados:

- `sql/v5.7-entrada-carga-etapa-1-tipos.sql`;
- `sql/v5.7-entrada-carga-etapa-2-funcao.sql`;
- `docs/implementacao-v5.7-entrada-carga-11072026.md`.

Função criada:

```text
registrar_entrada_carga_mvp(uuid, date, text, integer)
```

Regra obrigatória:

```text
entrou cheio → aumenta cheio
saiu vazio → diminui vazio
mesma quantidade
estoque total de cascos permanece estável
```

Cada entrada gera um lançamento e dois movimentos vinculados:

```text
entrada_cheia
saida_vazio
```

Proteções incluídas:

1. usuário autenticado;
2. autorização para a revenda;
3. dia operacional aberto;
4. produto ativo e permitido;
5. quantidade maior que zero;
6. saldo suficiente de vazios;
7. execução somente por `authenticated`.

## Ponto exato para continuar

A V5.7 ainda **não está homologada**, porque os SQLs precisam ser executados no Supabase e testados com dados de homologação.

Sequência:

1. executar `sql/v5.7-entrada-carga-etapa-1-tipos.sql` sozinho;
2. executar `sql/v5.7-entrada-carga-etapa-2-funcao.sql` sozinho;
3. abrir um dia de teste da Várzea Gás;
4. consultar o estoque antes;
5. registrar uma entrada de carga;
6. confirmar cheios aumentados e vazios reduzidos na mesma quantidade;
7. confirmar total de cascos inalterado;
8. confirmar bloqueio por vazios insuficientes;
9. confirmar permissões: authenticated=true, anon=false, public=false;
10. integrar e testar a tela de entrada de carga na aplicação autenticada.

## Regra do estoque inicial

O estoque inicial **não será lançado antes de tudo estar concluído**.

O estoque inicial é o marco zero oficial. No momento em que ele for lançado, o controle começa imediatamente e todas as movimentações do mesmo dia deverão ser registradas no Fênix.

Sequência oficial após homologar a V5.7:

1. publicar a versão definitiva em HTTPS;
2. confirmar o acesso do Alex;
3. definir o momento exato de início;
4. fazer a contagem física inicial da Várzea Gás;
5. lançar o estoque inicial;
6. iniciar o controle oficial no mesmo instante;
7. manter o controle atual em paralelo por cinco a sete dias;
8. encerrar cada dia somente com estoque conferido.

**Não reconstruir versões anteriores. Continuar exatamente da V5.6.2 homologada e concluir a homologação da V5.7.**
