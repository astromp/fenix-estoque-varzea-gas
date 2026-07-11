# RETOMAR AQUI — Projeto Fênix Estoque

**Versão homologada em produção:** V5.6.2  
**Evolução em implementação:** V5.7.1 — entrada de carga  
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

## V5.7.1 — entrada de carga criada e revisada no GitHub

Em 11/07/2026 foram criados e revisados:

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
2. autorização fail-closed para a revenda;
3. revenda ativa;
4. data operacional obrigatória;
5. dia operacional aberto;
6. abertura ativa;
7. produto ativo e permitido;
8. quantidade maior que zero;
9. saldo suficiente de vazios;
10. transação única;
11. bloqueio contra consumo simultâneo do mesmo saldo;
12. execução somente por `authenticated`.

## Ponto exato para continuar

A V5.7.1 ainda **não está homologada**, porque os SQLs precisam ser executados no Supabase e testados com dados de homologação.

Sequência:

1. executar `sql/v5.7-entrada-carga-etapa-1-tipos.sql` sozinho;
2. confirmar que aparecem os valores `entrada_carga` e `saida_vazio`;
3. executar `sql/v5.7-entrada-carga-etapa-2-funcao.sql` sozinho;
4. confirmar permissões: `authenticated=true`, `anon=false`, `public=false`;
5. abrir um dia de teste da Várzea Gás;
6. consultar o estoque antes;
7. registrar uma entrada de 5 unidades de produto com ao menos 5 vazios;
8. confirmar cheios aumentados em 5 e vazios reduzidos em 5;
9. confirmar total de cascos inalterado;
10. confirmar a criação de um lançamento e dois movimentos vinculados;
11. tentar quantidade superior aos vazios disponíveis e confirmar bloqueio;
12. confirmar reflexo correto no fechamento;
13. integrar e testar a tela de entrada de carga na aplicação autenticada.

## Regra do estoque inicial

O estoque inicial **não será lançado antes de tudo estar concluído**.

O estoque inicial é o marco zero oficial. No momento em que ele for lançado, o controle começa imediatamente e todas as movimentações do mesmo dia deverão ser registradas no Fênix.

Sequência oficial após homologar a V5.7.1:

1. publicar a versão definitiva em HTTPS;
2. confirmar o acesso do Alex;
3. definir o momento exato de início;
4. fazer a contagem física inicial da Várzea Gás;
5. lançar o estoque inicial;
6. iniciar o controle oficial no mesmo instante;
7. manter o controle atual em paralelo por cinco a sete dias;
8. encerrar cada dia somente com estoque conferido.

**Não reconstruir versões anteriores. Continuar exatamente da V5.6.2 homologada e concluir a homologação da V5.7.1.**
