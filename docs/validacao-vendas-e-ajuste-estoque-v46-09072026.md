# Validação de vendas e ajuste de estoque — V4.6 — 09/07/2026

## Resultado das vendas

Na V4.5, com as assinaturas RPC confirmadas no SQL Editor do Supabase, as vendas foram registradas com sucesso.

## Data operacional

```text
14/07/2026
```

## Vendas registradas

```text
1. Portaria — P13 — 10 unidades — 0 casco
2. João — P13 — 10 unidades — 1 casco
```

## Retornos confirmados

Após a primeira venda:

```text
canal: Portaria
produto: P13
quantidade_liquido: 10
quantidade_casco: 0
qtd_movimentos: 1
qtd_lancamentos: 1
```

Após a segunda venda:

```text
canal: João
produto: P13
quantidade_liquido: 10
quantidade_casco: 1
qtd_movimentos: 3
qtd_lancamentos: 2
```

## Estoque calculado retornado pelo Supabase

```text
P13:
cheios_abertura: 100
vazios_abertura: 30
delta_cheios: -20
delta_vazios: 19
cheios_calculados: 80
vazios_calculados: 49
total_calculado: 129
```

A regra foi confirmada:

```text
Venda total de líquido: 20 -> cheios -20
Venda com troca de 19 unidades -> vazios +19
Venda de casco 1 unidade -> total de cascos cai de 130 para 129
```

## Problema encontrado na tela

O Supabase retornou o estoque corretamente, mas a tela mostrava zero porque estava lendo campos genéricos antigos:

```text
cheios
vazios
qtd_cheios
qtd_vazios
```

O retorno real usa:

```text
cheios_calculados
vazios_calculados
cheios_abertura
vazios_abertura
delta_cheios
delta_vazios
total_calculado
```

## Correção da V4.6

A V4.6 ajusta a leitura do estoque calculado para interpretar os campos reais retornados pelo Supabase.

Resultado esperado após abrir a V4.6 e clicar em Conferir saldo:

```text
P13: 80 cheios / 49 vazios / total 129
P05: 10 cheios / 5 vazios / total 15
P20: 10 cheios / 2 vazios / total 12
P45: 10 cheios / 10 vazios / total 20
Água: 50 cheios / 10 vazios / total 60
```
