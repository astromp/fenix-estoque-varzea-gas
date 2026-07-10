# Projeto Fênix Estoque — Várzea Gás

Repositório criado para arquivar a memória técnica, as regras operacionais, a lógica de cálculo e a estrutura publicável do controle de estoque da Várzea Gás.

Este material serve como ponto de recuperação rápida caso alguma informação se perca durante o desenvolvimento.

## Objetivo

Criar um controle simples, confiável e conferível para o estoque de botijões e água, com foco em:

- fechamento correto do estoque por turno/dia;
- rastreabilidade dos lançamentos;
- identificação de inconsistências;
- relatórios de vendas por canal/personagem;
- padronização da lógica para futuras revendas do Projeto Fênix Estoque.

## Unidade inicial

- Revenda: Várzea Gás
- Projeto: Fênix Estoque
- Versão documental inicial: 1.0
- Estrutura publicável consolidada: Operação Celular Integrada V3
- Marco operacional aprovado: V5.0 — Relatório gerencial com filtros, detalhamento e CSV
- Marco anterior preservado: V4.9 — Painel gerencial por dia e período
- Data de registro: 2026-07-07
- Data de consolidação V3: 2026-07-09
- Data de homologação V4.8: 2026-07-10
- Data de homologação V4.9: 2026-07-10
- Data de homologação V5.0: 2026-07-10

## Estrutura publicável V3

```text
index.html
css/style.css
js/app.js
js/config.js
js/config.example.js
.gitignore
LEIA-ME.txt
```

O arquivo `js/config.js` fica no GitHub apenas com placeholder. Para teste local, substituir:

```text
SUPABASE_URL: "COLE_AQUI_A_URL_DO_SUPABASE"
SUPABASE_ANON_KEY: "COLE_AQUI_A_ANON_PUBLIC_KEY"
```

Nunca subir chave real, `service_role`, senha do banco, `DATABASE_URL` ou connection string.

## Documentos principais

- `docs/regras-operacionais.md` — regras combinadas para a Várzea Gás.
- `docs/formula-estoque.md` — fórmula e lógica de movimentação do estoque.
- `docs/canais-de-venda.md` — canais/personagens de venda.
- `docs/modelo-lancamento.md` — campos, regras e exemplos práticos de lançamento.
- `docs/modelo-fechamento.md` — regras de conferência física e fechamento do estoque.
- `docs/fluxo-celular-fechamento.md` — fluxo de tela para fechamento pelo celular.
- `docs/simulacao-operacao-fechamento.md` — exemplo prático de operação, fechamento e diagnóstico de divergência.
- `docs/modelo-dados-estoque.md` — estrutura inicial de tabelas e regras do banco de dados do estoque.
- `docs/relatorios-vendas.md` — armazenamento operacional e relatórios de vendas por canal de venda.
- `docs/modelo-telas-operacao-diaria.md` — desenho das telas para abertura, lançamentos, correções, fechamento e relatórios.
- `docs/integracao-ahgas-gasdelivery.md` — memória da integração AHGas/GasDelivery, API, endpoints e decisão técnica.
- `docs/arquitetura-banco-proprio.md` — decisão estratégica de construir banco próprio do Projeto Fênix.
- `docs/recuperacao-rapida.md` — resumo curto para recuperar o raciocínio do projeto.
- `docs/estrutura-publicavel-v3-08072026.md` — registro da estrutura publicável V3.
- `docs/ponto-de-retomada-09072026.md` — ponto exato de retomada do projeto.
- `docs/consolidacao-estrutura-publicavel-v3-09072026.md` — registro da consolidação feita no GitHub.
- `docs/homologacao-v4.8-10072026.md` — homologação da consulta oficial de vendas do dia no Supabase.
- `docs/homologacao-v4.9-10072026.md` — homologação do painel gerencial diário, semanal e por período personalizado.
- `docs/homologacao-v5.0-10072026.md` — homologação dos filtros, detalhamento diário e exportação CSV.

## Marco V4.8

A V4.8 foi homologada com consulta direta ao Supabase por meio da função:

```text
consultar_vendas_dia_mvp(p_data_operacional date)
```

Na data operacional de 07/07/2026 foram confirmados:

```text
5 lançamentos
57 produtos vendidos
2 cascos vendidos
```

A tela identificou corretamente canais, produtos, líquido, casco, correções e horários, ignorando movimentos cancelados.

## Marco V4.9

A V4.9 acrescentou o painel gerencial sobre a base oficial homologada na V4.8.

Foram aprovados três modos de consulta:

```text
Dia selecionado
Últimos 7 dias
Período personalizado
```

Testes homologados:

- dia selecionado: 07/07/2026;
- últimos 7 dias: 01/07/2026 a 07/07/2026;
- período personalizado: 05/07/2026 a 07/07/2026.

Nos três testes foram confirmados:

```text
5 lançamentos
57 produtos vendidos
2 cascos vendidos
1 linha de correção
```

O painel apresentou totais coerentes por canal e por produto, sem duplicação visível e sem erros durante a homologação.

Arquivo funcional principal:

```text
js/painel-gerencial-v4.9.js
```

## Marco V5.0

A V5.0 acrescentou filtros e exportação sobre o painel gerencial homologado.

Funcionalidades aprovadas:

```text
Filtro por canal
Filtro por produto
Detalhamento diário
Exportação CSV
```

Teste geral em 07/07/2026:

```text
5 lançamentos
57 produtos vendidos
2 cascos vendidos
1 linha de correção
```

Filtro Portaria:

```text
2 lançamentos
15 produtos vendidos
1 casco vendido
1 linha de correção
```

Filtro P13 com todos os canais:

```text
4 lançamentos
50 produtos vendidos
1 casco vendido
```

Distribuição do P13:

```text
Portaria: 10
Rogério: 20
André: 10
João: 10
```

Os arquivos CSV respeitaram os filtros e permaneceram coerentes com os totais exibidos na tela.

Arquivo funcional principal:

```text
js/relatorio-gerencial-v5.0.js
```

A V5.0 está congelada como marco aprovado. Novas evoluções devem ocorrer em versão posterior.

## Próxima etapa

A próxima versão deverá evoluir a gestão sem alterar a V5.0 homologada. Prioridades sugeridas:

- comparação entre períodos;
- impressão em formato gerencial;
- exportação em PDF;
- seleção de revenda;
- preparação multiunidade;
- indicadores e gráficos gerenciais.

## Princípio central

O estoque deve bater. Se houver inconsistência, o sistema deve orientar o colaborador a revisar o lançamento e corrigir o erro antes de encerrar o turno/dia.

## Regra operacional resumida

```text
Entrada: cheio sobe, vazio desce.
Venda por troca: cheio desce, vazio sobe.
Venda sem troca/casco: cheio desce e reduz o total de cascos em posse da revenda.
Portaria é canal de venda.
Toda venda precisa registrar canal de venda para permitir relatórios confiáveis.
```

## Armazenamento e relatórios

```text
O GitHub guarda o projeto.
O banco de dados guarda a operação real.
```

As vendas lançadas no sistema deverão alimentar relatórios diários, semanais, mensais e por período personalizado, sempre com filtro por revenda, produto e canal/personagem de venda.

## Integração futura

O projeto também mantém memória técnica sobre a possível integração com AHGas/GasDelivery para atendimento automático e criação de pedidos via WhatsApp/Bolt.

## Estratégia de independência

```text
O AHGas recebe o pedido.
O Projeto Fênix constrói a inteligência.
```

Aos poucos, o Projeto Fênix deve construir seu próprio banco de dados e evoluir para um sistema próprio mais completo.

## Regra de ouro

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
Versão homologada, preservar antes de evoluir.
```
