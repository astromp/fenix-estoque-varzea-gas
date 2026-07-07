# Resultado da Simulação — Várzea Gás — 07/07/2026

## Status final

A simulação operacional da Várzea Gás foi concluída com sucesso.

O fluxo validado foi:

1. Abertura do estoque da manhã.
2. Lançamento de vendas por canal.
3. Cálculo do estoque esperado.
4. Fechamento físico da noite.
5. Identificação de divergência.
6. Diagnóstico provável da causa.
7. Correção do lançamento.
8. Recalculo do fechamento.
9. Encerramento do dia operacional.
10. Auditoria final com diferenças zeradas.

## Abertura inicial

| Produto | Cheios | Vazios | Total |
|---|---:|---:|---:|
| P13 | 100 | 30 | 130 |
| P05 | 10 | 5 | 15 |
| P20 | 10 | 2 | 12 |
| P45 | 10 | 10 | 20 |
| Água | 50 | 10 | 60 |

## Vendas finais por canal

### Portaria

| Produto | Tipo | Quantidade |
|---|---|---:|
| P13 | Líquido | 10 |
| P05 | Líquido | 1 |
| P20 | Líquido | 1 |
| P45 | Líquido | 3 |
| P45 | Casco | 1 |

### Rogério

| Produto | Tipo | Quantidade |
|---|---|---:|
| P13 | Líquido | 20 |
| P20 | Líquido | 1 |
| P45 | Líquido | 1 |

### André

| Produto | Tipo | Quantidade |
|---|---|---:|
| P13 | Líquido | 10 |

### João

| Produto | Tipo | Quantidade |
|---|---|---:|
| P13 | Líquido | 10 |
| P13 | Casco | 1 |

## Divergência encontrada

Durante o fechamento físico inicial, o P45 apresentou divergência:

| Produto | Cheio calculado | Vazio calculado | Total calculado | Cheio físico | Vazio físico | Total físico | Diferença cheio | Diferença vazio | Diferença total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| P45 | 7 | 13 | 20 | 6 | 13 | 19 | -1 | 0 | -1 |

Diagnóstico gerado:

> Provável venda de casco não lançada.

Prioridade de revisão:

1. Recontar P45 cheio.
2. Conferir se houve venda de P45 com casco.
3. Revisar os canais que venderam P45, especialmente Portaria e Rogério.

## Correção realizada

Foi lançada a correção:

| Canal | Produto | Movimento | Quantidade |
|---|---|---|---:|
| Portaria | P45 | Venda do líquido | 1 |
| Portaria | P45 | Venda de casco | 1 |

## Fechamento final auditado

Após a correção, o fechamento ficou zerado:

| Produto | Cheios calculados | Vazios calculados | Total calculado | Cheios físicos | Vazios físicos | Total físico | Diferença cheio | Diferença vazio | Diferença total | Status |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| P13 | 50 | 79 | 129 | 50 | 79 | 129 | 0 | 0 | 0 | Conferido |
| P05 | 9 | 6 | 15 | 9 | 6 | 15 | 0 | 0 | 0 | Conferido |
| P20 | 8 | 4 | 12 | 8 | 4 | 12 | 0 | 0 | 0 | Conferido |
| P45 | 6 | 13 | 19 | 6 | 13 | 19 | 0 | 0 | 0 | Corrigido |
| Água | 50 | 10 | 60 | 50 | 10 | 60 | 0 | 0 | 0 | Conferido |

## Conclusão

A simulação comprovou que o modelo do Projeto Fênix consegue:

- controlar estoque cheio e vazio;
- registrar vendas por canal;
- diferenciar venda do líquido e venda de casco;
- calcular estoque esperado;
- comparar estoque calculado com estoque físico;
- identificar divergência;
- sugerir hipótese provável;
- orientar revisão;
- registrar correção preservando histórico;
- recalcular o fechamento;
- encerrar o dia somente após a inconsistência ser resolvida.

Regra operacional validada:

> Estoque fechado, turno encerrado. Estoque inconsistente, revisar até corrigir.
