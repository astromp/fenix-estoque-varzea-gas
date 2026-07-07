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
estoque_cheio_final = estoque_cheio_inicial + entradas_cheias - vendas_por_troca - vendas_sem_troca
```

```text
estoque_vazio_final = estoque_vazio_inicial - entradas_cheias + vendas_por_troca
```

```text
total_cascos = estoque_cheio + estoque_vazio
```

A regra normal é que o total de cascos permaneça estável nas entradas e nas vendas por troca.

A exceção operacional prevista nesta versão é a venda sem troca, porque nela sai um produto cheio e não retorna vazio/casco.

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

Resultado no total de cascos:

```text
total_cascos não muda
```

## 4. Venda por troca

Na venda por troca, o cliente recebe cheio e devolve vazio/casco.

```text
cheio = cheio - quantidade_vendida
vazio = vazio + quantidade_vendida
```

Exemplo:

```text
Venda por troca de 8 P13
cheio = cheio - 8
vazio = vazio + 8
```

Resultado no total de cascos:

```text
total_cascos não muda
```

## 5. Venda sem troca

Na venda sem troca, o cliente recebe o produto cheio e não entrega vazio/casco de volta.

Portanto:

```text
cheio = cheio - quantidade_vendida_sem_troca
vazio = vazio
```

Exemplo:

```text
Venda sem troca de 2 P13
cheio = cheio - 2
vazio = vazio
```

Resultado no total de cascos:

```text
total_cascos = total_cascos - quantidade_vendida_sem_troca
```

Essa movimentação precisa ficar separada da venda por troca, porque ela altera o total de cascos da revenda.

## 6. Conferência física

No fechamento, o sistema deve comparar:

```text
estoque_calculado_cheio x estoque_fisico_cheio_informado
```

```text
estoque_calculado_vazio x estoque_fisico_vazio_informado
```

```text
total_cascos_calculado x total_cascos_fisico
```

Se houver divergência, gerar alerta de estoque inconsistente.

## 7. Diagnóstico da divergência

O sistema deve tentar apontar onde o erro provavelmente ocorreu.

Exemplos de verificações:

- canal/personagem com lançamento fora do padrão;
- venda lançada em produto errado;
- entrada não lançada;
- entrada lançada sem baixa correspondente de vazio;
- venda por troca lançada como venda sem troca;
- venda sem troca lançada como venda por troca;
- quantidade física incompatível com a movimentação do dia.

## 8. Regra-mãe

```text
Entrada cheia aumenta cheio e diminui vazio na mesma quantidade.
Venda por troca diminui cheio e aumenta vazio na mesma quantidade.
Venda sem troca diminui cheio e não aumenta vazio.
O total de cascos só muda na venda sem troca.
```
