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
- Estrutura publicável consolidada: Operação Celular Integrada V3
- Marco operacional aprovado: V5.1 — comparação entre períodos e impressão gerencial
- Marco anterior preservado: V5.0 — relatório gerencial com filtros, detalhamento e CSV
- Data de registro: 2026-07-07
- Data de homologação V4.8: 2026-07-10
- Data de homologação V4.9: 2026-07-10
- Data de homologação V5.0: 2026-07-10
- Data de homologação V5.1: 2026-07-10

## Segurança da configuração

O arquivo `js/config.js` deve permanecer no GitHub apenas com placeholder:

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
- `docs/modelo-dados-estoque.md` — estrutura inicial de tabelas e regras do banco de dados.
- `docs/relatorios-vendas.md` — armazenamento operacional e relatórios de vendas.
- `docs/arquitetura-banco-proprio.md` — decisão estratégica de construir banco próprio.
- `docs/recuperacao-rapida.md` — resumo para recuperar o raciocínio do projeto.
- `docs/homologacao-v4.8-10072026.md` — vendas oficiais do dia via Supabase.
- `docs/homologacao-v4.9-10072026.md` — painel gerencial diário e por período.
- `docs/homologacao-v5.0-10072026.md` — filtros, detalhamento e exportação CSV.
- `docs/homologacao-v5.1-10072026.md` — comparação entre períodos e impressão gerencial.

## Marco V4.8

Consulta oficial ao Supabase por meio da função:

```text
consultar_vendas_dia_mvp(p_data_operacional date)
```

Em 07/07/2026 foram confirmados:

```text
5 lançamentos
57 produtos vendidos
2 cascos vendidos
```

## Marco V4.9

Painel gerencial aprovado nos modos:

```text
Dia selecionado
Últimos 7 dias
Período personalizado
```

Totais confirmados:

```text
5 lançamentos
57 produtos vendidos
2 cascos vendidos
1 linha de correção
```

Arquivo principal:

```text
js/painel-gerencial-v4.9.js
```

## Marco V5.0

Funcionalidades aprovadas:

```text
Filtro por canal
Filtro por produto
Detalhamento diário
Exportação CSV
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

Arquivo principal:

```text
js/relatorio-gerencial-v5.0.js
```

## Marco V5.1

A V5.1 acrescentou:

```text
Comparação entre dois períodos
Diferença absoluta
Variação percentual
Comparação por canal
Comparação por produto
Impressão gerencial
```

Teste homologado:

```text
Período A: 06/07/2026
Período B: 07/07/2026
```

Resultado do período B:

```text
5 lançamentos
57 produtos vendidos
2 cascos vendidos
1 linha de correção
```

Comparação por canal:

```text
André: 10 produtos, 0 cascos
João: 10 produtos, 1 casco
Portaria: 15 produtos, 1 casco
Rogério: 22 produtos, 0 cascos
```

Comparação por produto:

```text
P05: 1 produto, 0 cascos
P13: 50 produtos, 1 casco
P20: 2 produtos, 0 cascos
P45: 4 produtos, 1 casco
```

A impressão em PDF foi validada quanto ao conteúdo e aos cálculos. O cabeçalho e o rodapé automáticos do navegador poderão ser refinados em versão posterior.

Arquivo principal:

```text
js/comparacao-periodos-v5.1.js
```

A V5.1 está congelada como marco aprovado.

## Regra multirrevenda

Os canais de venda não são compartilhados automaticamente entre as revendas.

```text
Cada revenda possui seus próprios canais.
Os canais devem ser carregados conforme a revenda_id.
Portaria, Rogério, André e João pertencem à Várzea Gás.
Outras revendas terão outros canais e personagens.
```

Cada unidade terá seus próprios usuários, lançamentos, estoque e relatórios.

## Próxima etapa

A próxima versão deverá evoluir sem alterar a V5.1 homologada. Prioridades:

- melhorar o layout da impressão;
- exportação PDF controlada pelo sistema;
- seleção de revenda pela `revenda_id`;
- carregamento dinâmico dos canais de cada unidade;
- indicadores e gráficos gerenciais;
- preparação multiunidade.

## Princípio central

O estoque deve bater. Se houver inconsistência, o sistema deve orientar o colaborador a revisar o lançamento e corrigir o erro antes de encerrar o turno/dia.

## Regra operacional resumida

```text
Entrada: cheio sobe, vazio desce.
Venda por troca: cheio desce, vazio sobe.
Venda sem troca/casco: cheio desce e reduz o total de cascos em posse da revenda.
Portaria é canal de venda da Várzea Gás.
Toda venda precisa registrar canal de venda para permitir relatórios confiáveis.
```

## Armazenamento

```text
O GitHub guarda o projeto.
O banco de dados guarda a operação real.
```

## Regra de ouro

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
Versão homologada, preservar antes de evoluir.
```
