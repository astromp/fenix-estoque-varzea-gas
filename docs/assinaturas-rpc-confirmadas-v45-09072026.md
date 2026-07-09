# Assinaturas RPC confirmadas — V4.5 — 09/07/2026

## Origem

As assinaturas foram confirmadas no SQL Editor do Supabase por consulta ao catálogo do banco.

## Funções confirmadas

```text
consultar_estoque_mvp(p_data_operacional date) -> jsonb
consultar_status_dia_mvp(p_data_operacional date) -> jsonb
registrar_abertura_mvp(p_data_operacional date, p_itens jsonb) -> jsonb
registrar_correcao_venda_casco_mvp(p_data_operacional date, p_canal_nome text, p_produto_codigo text, p_quantidade integer) -> jsonb
registrar_fechamento_mvp(p_data_operacional date, p_itens jsonb) -> jsonb
registrar_venda_mvp(p_data_operacional date, p_canal_nome text, p_produto_codigo text, p_quantidade_liquido integer, p_quantidade_casco integer DEFAULT 0) -> jsonb
```

## Correção aplicada na V4.5

A V4.5 deixa de usar tentativa e erro e passa a chamar as funções com as assinaturas exatas:

```text
status: somente p_data_operacional
estoque: somente p_data_operacional
abertura: p_data_operacional + p_itens
venda: p_data_operacional + p_canal_nome + p_produto_codigo + p_quantidade_liquido + p_quantidade_casco
fechamento: p_data_operacional + p_itens
correção: p_data_operacional + p_canal_nome + p_produto_codigo + p_quantidade
```

## Próximo teste

Com a data 14/07/2026 aberta, testar:

```text
1. Portaria P13 — 10 sem casco
2. João P13 — 10 com 1 casco
3. Consultar estoque calculado
4. Fechar dia
```

## Regra preservada

```text
Portaria é canal de venda.
Venda com troca: cheio diminui e vazio aumenta.
Venda com casco: cheio diminui e total de cascos em posse diminui.
```
