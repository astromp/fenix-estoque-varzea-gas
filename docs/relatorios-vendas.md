# Relatórios de Vendas — Projeto Fênix Estoque / Várzea Gás

Este documento registra como as informações serão armazenadas e como o sistema deverá gerar relatórios de vendas por canal de venda.

## 1. Onde as informações serão armazenadas

As informações reais da operação não ficam no GitHub.

O GitHub guarda:

- documentação;
- regras de negócio;
- código-fonte;
- histórico técnico do projeto.

As informações reais da operação ficam no banco de dados do Projeto Fênix.

Exemplos de informações que ficam no banco:

- abertura da manhã;
- vendas por canal/personagem;
- entradas;
- venda do líquido;
- venda de casco;
- fechamento da noite;
- divergências;
- correções;
- histórico de movimentações.

## 2. Banco de dados do Projeto Fênix

O Projeto Fênix deverá ter um banco de dados próprio.

Esse banco será a fonte dos relatórios.

Regra estratégica:

```text
O GitHub guarda o projeto.
O banco de dados guarda a operação real.
```

## 3. Tabelas usadas para relatórios de venda

Os relatórios de vendas serão gerados principalmente a partir destas tabelas:

```text
lancamentos
movimentos_estoque
canais_venda
produtos
dias_operacionais
revendas
usuarios
```

A tabela principal para relatórios será:

```text
movimentos_estoque
```

Motivo:

Cada venda gera movimento de estoque com:

- data;
- revenda;
- produto;
- canal/personagem de venda;
- tipo de movimento;
- quantidade;
- usuário que lançou;
- vínculo com o lançamento original.

## 4. Como uma venda vira dado para relatório

Exemplo de operação:

```text
Portaria vendeu 10 P13.
```

No sistema, isso gera um lançamento e um movimento:

```text
lancamento:
data: 07/07/2026
revenda: Várzea Gás
canal_venda: Portaria
tipo_lancamento: venda

movimento_estoque:
produto: P13
tipo_movimento: venda_liquido
quantidade: 10
```

Esse registro poderá aparecer em relatórios diários, semanais, mensais e anuais.

## 5. Venda de casco nos relatórios

Venda de casco deve ser registrada separadamente da venda do líquido.

Exemplo:

```text
João vendeu 10 P13, sendo 1 com casco.
```

No banco:

```text
movimento 1:
tipo_movimento: venda_liquido
produto: P13
quantidade: 10
canal_venda: João

movimento 2:
tipo_movimento: venda_casco
produto: P13
quantidade: 1
canal_venda: João
vinculado ao movimento 1
```

Assim será possível emitir relatórios separados:

- venda do líquido;
- venda de casco;
- total de produtos vendidos;
- total de cascos vendidos.

## 6. Relatório diário por canal de venda

Pergunta que o relatório responde:

```text
Quanto cada canal vendeu no dia?
```

Exemplo:

```text
Data: 07/07/2026
Revenda: Várzea Gás

Canal      P13   P05   P20   P45   Água
Portaria   10     1     1     2     0
Rogério    20     0     1     1     0
André      10     0     0     0     0
João       10     0     0     0     0
```

Também pode mostrar venda de casco:

```text
Canal      Produto   Casco vendido
João       P13       1
```

## 7. Relatório semanal por canal de venda

Pergunta que o relatório responde:

```text
Quanto cada canal vendeu na semana?
```

Agrupamento:

```text
por semana
por canal_venda
por produto
por tipo_movimento
```

Exemplo:

```text
Semana: 06/07/2026 a 12/07/2026
Revenda: Várzea Gás

Canal      P13   P05   P20   P45   Água
Portaria   __    __    __    __    __
Rogério    __    __    __    __    __
André      __    __    __    __    __
João       __    __    __    __    __
```

## 8. Relatório mensal por canal de venda

Pergunta que o relatório responde:

```text
Quanto cada canal vendeu no mês?
```

Agrupamento:

```text
por mês
por canal_venda
por produto
por tipo_movimento
```

Exemplo:

```text
Mês: Julho/2026
Revenda: Várzea Gás

Canal      P13   P05   P20   P45   Água
Portaria   __    __    __    __    __
Rogério    __    __    __    __    __
André      __    __    __    __    __
João       __    __    __    __    __
```

## 9. Relatório por período personalizado

O sistema também deve permitir consultar qualquer período.

Exemplos:

```text
01/07/2026 a 15/07/2026
01/01/2026 a 31/12/2026
últimos 30 dias
últimos 7 dias
```

Filtros sugeridos:

- revenda;
- data inicial;
- data final;
- canal de venda;
- produto;
- tipo de movimento;
- usuário que lançou.

## 10. Tipos de relatório necessários

Relatórios mínimos da primeira versão:

```text
Vendas diárias por canal de venda
Vendas semanais por canal de venda
Vendas mensais por canal de venda
Vendas por produto
Vendas de casco por canal de venda
Resumo geral por período
```

Relatórios futuros:

```text
Ranking de canais de venda
Comparativo entre períodos
Evolução mensal
Média diária por canal
Produtos mais vendidos
Relatório de divergências por período
Relatório de correções por usuário
```

## 11. Dados mínimos necessários em cada venda

Para gerar bons relatórios, cada venda precisa guardar:

```text
data_hora
revenda_id
produto_id
canal_venda_id
usuario_id
tipo_movimento
quantidade
lancamento_id
status
```

Sem `canal_venda_id`, não será possível gerar relatório confiável por canal.

Por isso, em venda, canal de venda deve ser obrigatório.

## 12. Exemplo usando a simulação

Vendas informadas na simulação:

```text
Portaria:
10 P13
1 P05
1 P20
2 P45

Rogério:
20 P13
1 P20
1 P45

André:
10 P13

João:
10 P13, sendo 1 com casco
```

Relatório diário esperado:

```text
Vendas do líquido por canal — 07/07/2026

Portaria:
P13: 10
P05: 1
P20: 1
P45: 2
Água: 0

Rogério:
P13: 20
P05: 0
P20: 1
P45: 1
Água: 0

André:
P13: 10
P05: 0
P20: 0
P45: 0
Água: 0

João:
P13: 10
P05: 0
P20: 0
P45: 0
Água: 0
```

Relatório de casco vendido:

```text
João:
P13 casco vendido: 1
```

## 13. Como o sistema calcula os relatórios

A lógica será somar os movimentos de estoque filtrando por período.

Venda do líquido:

```text
somar quantidade
onde tipo_movimento = venda_liquido
agrupar por canal_venda, produto e período
```

Venda de casco:

```text
somar quantidade
onde tipo_movimento = venda_casco
agrupar por canal_venda, produto e período
```

Entradas:

```text
somar quantidade
onde tipo_movimento = entrada_cheia
agrupar por produto e período
```

## 14. Importante sobre valores em dinheiro

O modelo atual está focado em controle físico de estoque.

Para relatórios financeiros, será necessário guardar também:

```text
preco_unitario
valor_total
forma_pagamento
status_pagamento
```

Na primeira versão, o relatório de vendas pode ser por quantidade.

Depois, o sistema pode evoluir para relatório financeiro.

## 15. Regra final

```text
Toda venda precisa virar movimento de estoque com data, produto, quantidade e canal de venda.
Sem isso, não existe relatório confiável.
```
