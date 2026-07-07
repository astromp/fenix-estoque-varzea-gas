# Fórmula de Estoque — Projeto Fênix Estoque

Este documento registra a lógica central do estoque de cheios e vazios/cascos.

## 1. Conceitos

Para cada produto, controlar separadamente:

- estoque cheio;
- estoque vazio/casco;
- total físico de cascos.

Produtos como botijão e água seguem a mesma lógica operacional quando houver controle de cheio e vazio.

## 2. Conceito comercial correto

A operação não deve ser chamada de venda sem troca.

O conceito correto é:

- venda do líquido;
- venda de casco.

A venda normal é a venda do líquido: o cliente recebe o produto cheio e devolve o casco vazio.

A venda de casco só pode existir se também existir venda do líquido junto. Ou seja: não se vende casco isolado. Quando há venda de casco, o cliente está comprando o produto cheio e também ficando com o casco.

## 3. Fórmula geral

Para cada produto:

```text
estoque_cheio_final = estoque_cheio_inicial + entradas_cheias - vendas_liquido
```

```text
estoque_vazio_final = estoque_vazio_inicial - entradas_cheias + vendas_liquido - vendas_casco
```

```text
total_cascos = estoque_cheio + estoque_vazio
```

Nas entradas e nas vendas apenas do líquido, o total de cascos permanece estável.

Na venda de casco, o total de cascos diminui, porque o casco sai definitivamente da revenda junto com o produto cheio.

## 4. Entrada de produto cheio

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

## 5. Venda do líquido

Venda do líquido é a venda normal em que o cliente recebe o produto cheio e devolve o casco vazio.

```text
cheio = cheio - quantidade_vendida
vazio = vazio + quantidade_vendida
```

Exemplo:

```text
Venda do líquido de 8 P13
cheio = cheio - 8
vazio = vazio + 8
```

Resultado no total de cascos:

```text
total_cascos não muda
```

## 6. Venda de casco

Venda de casco é a operação em que o cliente compra também o casco.

Regra obrigatória:

```text
venda_de_casco só pode existir junto com venda_do_liquido
```

Não deve existir venda de casco isolada.

Na prática, quando há venda de casco, a operação completa é:

```text
venda_do_liquido:
cheio = cheio - quantidade
vazio = vazio + quantidade

venda_de_casco:
vazio = vazio - quantidade
```

Resultado final da operação completa:

```text
cheio = cheio - quantidade
vazio não muda
total_cascos = total_cascos - quantidade
```

Exemplo:

```text
Venda de 2 P13 com venda de casco
cheio = cheio - 2
vazio não muda
total_cascos = total_cascos - 2
```

Essa movimentação precisa ficar separada da venda apenas do líquido, porque ela altera o total de cascos da revenda.

## 7. Conferência física

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

## 8. Diagnóstico da divergência

O sistema deve tentar apontar onde o erro provavelmente ocorreu.

Exemplos de verificações:

- canal/personagem com lançamento fora do padrão;
- venda lançada em produto errado;
- entrada não lançada;
- entrada lançada sem baixa correspondente de vazio;
- venda do líquido lançada sem retorno de vazio;
- venda de casco lançada sem venda do líquido correspondente;
- venda de casco esquecida em uma operação em que o cliente ficou com o casco;
- quantidade física incompatível com a movimentação do dia.

## 9. Regra-mãe

```text
Entrada cheia aumenta cheio e diminui vazio na mesma quantidade.
Venda do líquido diminui cheio e aumenta vazio na mesma quantidade.
Venda de casco só existe junto com venda do líquido.
Venda de casco diminui o total de cascos da revenda.
```
