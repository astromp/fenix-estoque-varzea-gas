# Homologação V5.1 — Comparação entre períodos e impressão gerencial

Data da homologação: 10/07/2026

## Escopo

A V5.1 acrescenta ao Projeto Fênix Estoque:

- comparação entre dois períodos;
- diferença absoluta;
- variação percentual;
- comparação por canal de venda;
- comparação por produto;
- impressão gerencial.

A V5.0 permanece preservada como marco anterior.

## Teste realizado

Período A:

```text
06/07/2026 a 06/07/2026
```

Período B:

```text
07/07/2026 a 07/07/2026
```

Resultado confirmado para o período B:

```text
5 lançamentos
57 produtos vendidos
2 cascos vendidos
1 linha de correção
```

## Comparação por canal confirmada

```text
André: 10 produtos, 0 cascos
João: 10 produtos, 1 casco
Portaria: 15 produtos, 1 casco
Rogério: 22 produtos, 0 cascos
```

## Comparação por produto confirmada

```text
P05: 1 produto, 0 cascos
P13: 50 produtos, 1 casco
P20: 2 produtos, 0 cascos
P45: 4 produtos, 1 casco
```

## Impressão gerencial

A impressão foi validada em PDF com:

- identificação da Várzea Gás;
- períodos A e B;
- totais gerais;
- diferenças absolutas;
- variações percentuais;
- comparação por canal;
- comparação por produto.

O conteúdo e os cálculos foram aprovados.

Observação visual: o navegador acrescentou cabeçalho e rodapé próprios, com data, título, endereço `about:blank` e paginação. Isso não afeta os dados e pode ser refinado em versão posterior.

## Regra multirrevenda reafirmada

Os canais de venda não podem ser fixos para todas as revendas.

```text
Cada revenda possui seus próprios canais.
Os canais devem ser carregados conforme a revenda_id.
Portaria, Rogério, André e João pertencem à Várzea Gás.
Outras revendas terão outros canais e personagens.
```

## Arquivo funcional principal

```text
js/comparacao-periodos-v5.1.js
```

## Resultado

A V5.1 está homologada e congelada como marco aprovado.

Novas evoluções devem ocorrer em versão posterior, preservando esta entrega.
