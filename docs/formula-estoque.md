# Fórmula de Estoque — Projeto Fênix Estoque

Este documento registra a lógica central do estoque de cheios e vazios/cascos.

## 1. Conceitos

Para cada produto, controlar separadamente:

- estoque cheio;
- estoque vazio/casco;
- total físico de cascos.

Produtos como botijão e água seguem a mesma lógica operacional quando houver controle de cheio e vazio.

## 2. Fórmula geral

Para cada produto:

```text
estoque_cheio_final = estoque_cheio_inicial + entradas_cheias - saidas_cheias
```

```text
estoque_vazio_final = estoque_vazio_inicial - entradas_cheias + retornos_vazios
```

```text
total_cascos = estoque_cheio + estoque_vazio
```

A regra desejada é que o total de cascos permaneça estável, salvo quando houver compra, perda, baixa, devolução definitiva ou ajuste autorizado.

## 3. Entrada de produto cheio

Entrada significa chegada de botijão ou água cheia.

Como a mesma quantidade de cheio que entra deve sair de vazio/casco:

```text
cheio = cheio + quantidade_entrada
vazio = vazio - quantidade_entrada
```

Exemplo:

```text
Entrada de 12 P13 cheios
cheio = cheio + 12
vazio = vazio - 12
```

## 4. Venda por troca

Na venda por troca, o cliente recebe cheio e devolve vazio/casco.

```text
cheio = cheio - quantidade_vendida
vazio = vazio + quantidade_vendida
```

Exemplo:

```text
Venda de 8 P13
cheio = cheio - 8
vazio = vazio + 8
```

## 5. Conferência física

No fechamento, o sistema deve comparar:

```text
estoque_calculado_cheio x estoque_fisico_cheio_informado
```

```text
estoque_calculado_vazio x estoque_fisico_vazio_informado
```

Se houver divergência, gerar alerta de estoque inconsistente.

## 6. Diagnóstico da divergência

O sistema deve tentar apontar onde o erro provavelmente ocorreu.

Exemplos de verificações:

- canal/personagem com lançamento fora do padrão;
- venda lançada em produto errado;
- entrada não lançada;
- entrada lançada sem baixa correspondente de vazio;
- venda lançada sem retorno correspondente de vazio;
- quantidade física incompatível com a movimentação do dia.

## 7. Regra-mãe

```text
Entrada cheia aumenta cheio e diminui vazio na mesma quantidade.
Venda por troca diminui cheio e aumenta vazio na mesma quantidade.
O total de cascos deve bater.
```
