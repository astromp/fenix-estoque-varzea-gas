# Regras Operacionais — Várzea Gás

Este documento registra as regras combinadas para o controle de estoque da Várzea Gás dentro do Projeto Fênix Estoque.

## 1. Implantação por revenda

O controle será implantado e desenhado uma revenda por vez.

A primeira revenda trabalhada nesta base é a Várzea Gás.

## 2. Fluxo único de lançamento

Mesmo que cada revenda tenha responsáveis, vendedores ou personagens diferentes, a forma de lançar produtos deve ser padronizada.

A lógica de lançamento e fechamento deve ser única para todas as revendas, variando principalmente os nomes dos canais/personagens de venda de cada unidade.

## 3. Produtos controlados

O controle deve tratar botijões e água/galões como itens de estoque com movimentação de cheios e vazios/cascos.

Produtos inicialmente previstos:

- P13 / gás de cozinha 13 kg;
- P20;
- P45;
- água mineral / galão;
- outros produtos que venham a ser adicionados futuramente.

## 4. Regra das entradas

As entradas representam a chegada de produtos cheios.

Quando entra produto cheio, deve sair a mesma quantidade de vazio/casco.

Portanto, no lançamento de entrada:

- o estoque cheio aumenta;
- o estoque vazio/casco diminui;
- a quantidade total de cascos permanece estável.

Exemplo:

Entrada de 10 P13 cheios:

- P13 cheio: +10;
- P13 vazio: -10;
- total físico de cascos P13: permanece igual.

## 5. Regra da venda do líquido

Venda do líquido é a venda normal em que o cliente recebe o produto cheio e devolve o casco vazio.

Portanto, no lançamento de venda do líquido:

- o estoque cheio diminui;
- o estoque vazio/casco aumenta;
- a quantidade total de cascos permanece estável.

Exemplo:

Venda do líquido de 5 P13:

- P13 cheio: -5;
- P13 vazio: +5;
- total físico de cascos P13: permanece igual.

## 6. Regra da venda de casco

A operação não deve ser chamada de venda sem troca.

O nome correto é venda de casco.

Venda de casco significa que o cliente compra também o casco, junto com o produto cheio.

Regra obrigatória:

- toda venda de casco deve estar vinculada a uma venda do líquido;
- não deve existir venda de casco isolada;
- o sistema deve impedir ou alertar se alguém tentar lançar casco sem líquido correspondente.

Na prática, quando há venda de casco:

- primeiro existe a venda do líquido;
- depois o casco também é vendido;
- o estoque cheio diminui;
- o estoque vazio/casco não aumenta no resultado final;
- o total de cascos da revenda diminui.

Exemplo:

Venda de 2 P13 com venda de casco:

- P13 cheio: -2;
- P13 vazio: não muda no resultado final;
- total físico de cascos P13: -2.

## 7. Conferência obrigatória

Ao final do dia ou turno, o colaborador deve informar a quantidade física que sobrou no estoque.

O sistema não deve apenas mostrar o erro. Ele deve cobrar revisão e orientar onde provavelmente ocorreu a divergência.

## 8. Inconsistência de estoque

Se houver diferença entre o estoque calculado e o estoque físico informado, o sistema deve apontar a inconsistência e conduzir o colaborador à correção.

Princípio definido:

> Estoque fechado, turno encerrado. Estoque inconsistente, o turno não deve ser encerrado até revisar e corrigir.

## 9. Responsabilidade operacional

A responsabilidade é fechar o estoque corretamente, independentemente do que tenha ocorrido durante o dia.

O sistema deve facilitar a correção, mas não deve permitir que a pendência seja simplesmente ignorada.
