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

## 5. Regra das vendas

Na venda comum por troca, o cheio sai e o vazio/casco volta.

Portanto, no lançamento de venda por troca:

- o estoque cheio diminui;
- o estoque vazio/casco aumenta;
- a quantidade total de cascos permanece estável.

Exemplo:

Venda de 5 P13:

- P13 cheio: -5;
- P13 vazio: +5;
- total físico de cascos P13: permanece igual.

## 6. Conferência obrigatória

Ao final do dia ou turno, o colaborador deve informar a quantidade física que sobrou no estoque.

O sistema não deve apenas mostrar o erro. Ele deve cobrar revisão e orientar onde provavelmente ocorreu a divergência.

## 7. Inconsistência de estoque

Se houver diferença entre o estoque calculado e o estoque físico informado, o sistema deve apontar a inconsistência e conduzir o colaborador à correção.

Princípio definido:

> Estoque fechado, turno encerrado. Estoque inconsistente, o turno não deve ser encerrado até revisar e corrigir.

## 8. Responsabilidade operacional

A responsabilidade é fechar o estoque corretamente, independentemente do que tenha ocorrido durante o dia.

O sistema deve facilitar a correção, mas não deve permitir que a pendência seja simplesmente ignorada.
