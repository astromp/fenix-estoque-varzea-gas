# Ajuste V4.4 — Venda usando dia_operacional_id — 09/07/2026

## Situação confirmada

A V4.3 validou a abertura da manhã com sucesso.

O histórico da tela mostrou:

```text
Registrar abertura — sucesso
Abertura da manhã registrada com sucesso.
itens_registrados: 5
status posterior: aberto
pode_lancar_venda: true
```

Depois, ao testar a venda `Portaria P13 — 10 sem casco`, a função `registrar_venda_mvp` não encaixou nas 12 assinaturas testadas.

## Interpretação

A venda falhou por assinatura RPC, não por regra de estoque.

Como a abertura retornou `dia_operacional_id`, e a consulta de status também retorna esse identificador, a V4.4 passa a testar primeiro assinaturas que usam o ID do dia operacional aberto.

## Ajuste aplicado

A V4.4 usa:

```text
dia_operacional_id
```

extraído do último retorno de status/abertura, e testa assinaturas como:

```text
p_dia_operacional_id + p_canal + p_produto + p_quantidade
p_dia_operacional_id + p_canal + p_produto + p_quantidade + p_quantidade_casco
p_dia_operacional_id + p_canal_venda + p_produto_codigo + p_qtd_liquido + p_qtd_casco
p_dia_operacional_id + p_venda
p_dia_operacional_id + p_movimento
p_dia_operacional_id + p_itens
p_dia_operacional_id + p_vendas
```

Também mantém tentativas por data operacional como fallback.

## Próximo teste

Testar novamente:

```text
Portaria P13 — 10 sem casco
```

Depois, se a primeira venda funcionar:

```text
João P13 — 10 com 1 casco
```

## Regra operacional preservada

```text
Portaria é canal de venda.
Venda com troca: cheio diminui e vazio aumenta.
Venda com casco: cheio diminui e total de cascos em posse diminui.
```
