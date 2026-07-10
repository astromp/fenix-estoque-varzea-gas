# Início da V4.9 — Painel Gerencial

Data: 10/07/2026

## Marco anterior preservado

A V4.8 permanece congelada como versão homologada da consulta oficial `Vendas do dia`.

## Objetivo da V4.9

Criar um painel gerencial conectado às vendas oficiais do Supabase, sem alterar as regras operacionais já aprovadas.

## Entrega inicial implementada

Arquivo criado:

```text
js/painel-gerencial-v4.9.js
```

O painel inclui:

1. consulta por dia selecionado;
2. consulta dos últimos 7 dias;
3. período personalizado de até 93 dias nesta homologação;
4. total de lançamentos;
5. total de produtos vendidos;
6. total de cascos vendidos;
7. identificação de linhas de correção;
8. resumo por canal de venda;
9. resumo por produto.

## Fonte dos dados

O painel usa exclusivamente a função oficial:

```text
consultar_vendas_dia_mvp(p_data_operacional date)
```

Para períodos, a V4.9 consulta cada data do intervalo e consolida os resultados na tela.

## Regras preservadas

- somente lançamentos ativos;
- somente movimentos ativos;
- cancelados não entram nos relatórios;
- Portaria é canal de venda;
- correções permanecem identificadas;
- V4.8 não deve ser sobrescrita durante a homologação.

## Próximo passo

Integrar o novo script à página de homologação V4.9, gerar pacote local completo e testar o painel com o período que inclui 07/07/2026.

## Regra de ouro

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
