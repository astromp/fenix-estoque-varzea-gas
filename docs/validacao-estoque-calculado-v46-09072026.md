# Validação do estoque calculado — V4.6 — 09/07/2026

## Resultado

A V4.6 corrigiu a exibição do estoque calculado na tela operacional.

## Data operacional testada

```text
14/07/2026
```

## Resultado exibido corretamente

```text
P13: 80 cheios / 49 vazios / total: 129 | mov.: -20 cheios / +19 vazios
P05: 10 cheios / 5 vazios / total: 15
P20: 10 cheios / 2 vazios / total: 12
P45: 10 cheios / 10 vazios / total: 20
Água/galão: 50 cheios / 10 vazios / total: 60
```

## Interpretação operacional

A tela agora interpreta corretamente os campos reais retornados pelo Supabase:

```text
cheios_calculados
vazios_calculados
total_calculado
delta_cheios
delta_vazios
```

## Validação da regra P13

Abertura P13:

```text
100 cheios / 30 vazios / total 130
```

Vendas registradas:

```text
Portaria P13 — 10 sem casco
João P13 — 10 com 1 casco
```

Resultado calculado:

```text
80 cheios / 49 vazios / total 129
```

Isso confirma:

```text
20 líquidos vendidos -> cheios -20
19 trocas -> vazios +19
1 casco vendido -> total de cascos -1
```

## Próximo passo

Validar o fechamento físico na V4.6:

```text
1. preencher fechamento com estoque calculado;
2. gravar fechamento;
3. confirmar status fechado;
4. depois testar divergência e correção.
```
