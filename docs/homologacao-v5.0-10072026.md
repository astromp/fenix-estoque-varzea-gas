# Homologação V5.0 — Relatório gerencial com filtros e exportação

Data da homologação: 10/07/2026
Revenda: Várzea Gás
Projeto: Fênix Estoque

## Objetivo

Homologar a primeira entrega da V5.0, preservando a V4.9 aprovada e acrescentando recursos de análise e exportação.

## Funcionalidades homologadas

- relatório geral por data/período;
- filtro por canal de venda;
- filtro por produto;
- detalhamento diário;
- exportação em CSV;
- manutenção dos totais de líquido, casco e correção.

## Base de teste

Data operacional utilizada: 07/07/2026.

Resultado geral confirmado:

```text
5 lançamentos
57 produtos vendidos
2 cascos vendidos
1 linha de correção
```

## Teste do filtro por canal

Canal selecionado: Portaria.

Resultado confirmado:

```text
2 lançamentos
15 produtos vendidos
1 casco vendido
1 linha de correção
```

Composição exportada:

```text
P13: 10
P05: 1
P20: 1
P45: 3
```

## Teste do filtro por produto

Produto selecionado: P13.
Canal selecionado: Todos.

Resultado confirmado:

```text
4 lançamentos
50 produtos P13 vendidos
1 casco vendido
```

Distribuição por canal:

```text
Portaria: 10
Rogério: 20
André: 10
João: 10
```

O casco foi identificado corretamente no lançamento do João.

## Exportação CSV

A exportação CSV foi validada com sucesso nos cenários testados. Os arquivos gerados respeitaram os filtros aplicados e mantiveram coerência com os totais exibidos na tela.

## Arquivo funcional principal

```text
js/relatorio-gerencial-v5.0.js
```

## Decisão

A V5.0 está homologada e deve ser preservada como novo marco operacional aprovado.

Novas evoluções devem ocorrer em versão posterior, sem alterar esta versão.

## Próxima etapa sugerida

- comparação entre períodos;
- impressão em formato gerencial;
- exportação em PDF;
- seleção de revenda;
- preparação multiunidade;
- indicadores e gráficos gerenciais.

## Regra de ouro

```text
Versão homologada, preservar antes de evoluir.
```
