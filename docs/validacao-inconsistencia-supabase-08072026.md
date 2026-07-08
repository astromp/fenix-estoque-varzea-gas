# Validação de Estoque Inconsistente no Supabase — 08/07/2026

## Status

Validação realizada com sucesso.

O frontend local executou um fluxo de teste com divergência simulada e o Supabase marcou o fechamento como `inconsistente`.

## Resultado confirmado

Resultado interpretado no teste:

```text
Fluxo: OK
Status fechamento: inconsistente
Mensagem: Estoque inconsistente. Revisar até corrigir.
Itens registrados: 5
Itens inconsistentes: 1
Resultado esperado: estoque inconsistente
```

## Fluxo executado

O teste automático executou:

1. abertura da manhã em uma nova data de teste;
2. venda Portaria P13 — 10 sem casco;
3. venda João P13 — 10 com 1 casco;
4. consulta do estoque calculado;
5. fechamento físico com divergência simulada no P13.

## Divergência validada

Produto inconsistente:

```text
P13
```

Resultado do P13:

```text
Calculado: 80 cheios / 49 vazios / total 129
Físico: 79 cheios / 49 vazios / total 128
Diferença: -1 cheio / 0 vazio / -1 total
Status: inconsistente
```

## Produtos conferidos

Os demais produtos permaneceram conferidos:

```text
AGUA: diferença 0 / 0 / 0
P05: diferença 0 / 0 / 0
P20: diferença 0 / 0 / 0
P45: diferença 0 / 0 / 0
```

## Interpretação operacional

A validação confirma que o sistema identifica corretamente uma situação clássica de divergência:

```text
cheio físico menor
vazio físico igual
total físico menor
```

Essa combinação indica provável movimentação não registrada, especialmente uma possível venda de casco não lançada ou outra saída física não refletida nos movimentos.

## Regra validada

```text
Estoque inconsistente, revisar até corrigir.
```

O sistema não tratou o fechamento como conferido. Ele marcou o fechamento como inconsistente e destacou o produto com diferença.

## Estado atual validado no Supabase real

Até este ponto, o Projeto Fênix Estoque já possui validação real no Supabase para:

```text
1. leitura de revendas, produtos e canais;
2. gravação da abertura da manhã;
3. gravação de venda comum;
4. gravação de venda com casco;
5. consulta do estoque calculado;
6. gravação do fechamento físico conferido;
7. gravação do fechamento físico inconsistente.
```

## Próximo passo

O próximo passo é construir o fluxo de correção:

1. listar produtos inconsistentes;
2. apresentar a hipótese provável;
3. orientar revisão do lançamento;
4. registrar correção sem apagar o histórico;
5. recalcular o fechamento;
6. encerrar o dia somente quando as diferenças ficarem zeradas.

## Regra de ouro preservada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
