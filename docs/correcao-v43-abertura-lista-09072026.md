# Correção V4.3 — Abertura em formato de lista — 09/07/2026

## Diagnóstico confirmado pelo histórico da tela

A conexão com Supabase foi confirmada porque a tela conseguiu consultar o status de duas datas:

```text
09/07/2026 -> fechado
14/07/2026 -> sem_abertura
```

O erro ocorreu apenas ao registrar a abertura.

Mensagem retornada pelo Supabase:

```text
Itens da abertura precisam ser enviados em formato de lista.
```

## Interpretação

A função `registrar_abertura_mvp` foi encontrada e executada, mas recusou o formato dos itens.

Isso confirma que:

```text
1. a conexão está funcionando;
2. a função existe;
3. o problema está no formato do payload da abertura;
4. a abertura deve ser enviada como lista/array de itens, não como objeto por produto.
```

## Correção aplicada na V4.3

A V4.3 passa a montar a contagem de abertura assim:

```text
[
  { produto: "P13", produto_codigo: "P13", cheios: 100, vazios: 30, qtd_cheios: 100, qtd_vazios: 30, total_cascos: 130 },
  { produto: "P05", produto_codigo: "P05", cheios: 10, vazios: 5, qtd_cheios: 10, qtd_vazios: 5, total_cascos: 15 },
  ...
]
```

E tenta primeiro enviar essa lista como:

```text
p_itens
p_abertura
p_contagem
p_estoque_inicial
p_produtos
```

## Ajuste complementar

O fechamento físico também foi preparado para enviar lista de itens primeiro, porque pode seguir padrão semelhante ao da abertura.

## Regra de ouro preservada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
