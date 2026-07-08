# Validação do Estoque Calculado no Supabase — 08/07/2026

## Status

Validação realizada com sucesso.

O frontend local conseguiu consultar o estoque calculado no Supabase usando a função controlada `consultar_estoque_mvp`.

## Resultado geral

Resultado interpretado no teste:

```text
Consulta: OK
Itens retornados: 5
P13 cheios: 80
P13 vazios: 49
P13 total: 129
```

## Resultado detalhado do P13

Abertura registrada:

```text
P13: 100 cheios / 30 vazios / total 130
```

Movimentos gravados:

```text
Movimentos em cheios: -20
Movimentos em vazios: +19
```

Estoque calculado retornado pelo Supabase:

```text
P13: 80 cheios / 49 vazios / total 129
```

## Interpretação operacional

O resultado confirma que o Supabase aplicou corretamente as regras:

### Venda do líquido

```text
cheios diminuem
vazios aumentam
```

### Venda de casco

```text
vazios diminuem
total de cascos diminui
```

### Resultado prático validado

Com abertura de 100 cheios e 30 vazios, após duas vendas de 10 unidades de P13, sendo uma delas com 1 casco vendido, o resultado esperado é:

```text
cheios: 100 - 20 = 80
vazios: 30 + 20 - 1 = 49
total: 80 + 49 = 129
```

O Supabase retornou exatamente esse resultado.

## Demais produtos

Os demais produtos permaneceram sem movimentação neste teste:

```text
P05: 10 cheios / 5 vazios / total 15
P20: 10 cheios / 2 vazios / total 12
P45: 10 cheios / 10 vazios / total 20
AGUA: 50 cheios / 10 vazios / total 60
```

## Função usada

```text
consultar_estoque_mvp
```

A função apenas consulta os dados e calcula o estoque esperado a partir da abertura e dos movimentos ativos.

## Próximo passo

Com abertura, venda e estoque calculado validados no Supabase, o próximo passo é registrar o fechamento físico da noite.

A próxima função deve:

1. receber a contagem física final;
2. calcular o estoque esperado;
3. comparar físico x calculado;
4. gravar `fechamentos`;
5. gravar `itens_fechamento`;
6. marcar cada item como `conferido` ou `inconsistente`;
7. bloquear encerramento se houver divergência.

## Regra de ouro preservada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
