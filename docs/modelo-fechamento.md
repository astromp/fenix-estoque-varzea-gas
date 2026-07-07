# Modelo de Fechamento — Projeto Fênix Estoque / Várzea Gás

Este documento define como deve funcionar o fechamento de estoque no Projeto Fênix Estoque, começando pela Várzea Gás.

## 1. Objetivo

O fechamento deve garantir que o estoque calculado pelo sistema bate com o estoque físico contado pelo colaborador.

A regra principal é:

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```

## 2. O que o sistema calcula

Durante o dia/turno, o sistema calcula o saldo esperado de cada produto com base nos lançamentos.

Para cada produto, o sistema deve calcular:

```text
cheio_calculado
vazio_calculado
total_cascos_calculado = cheio_calculado + vazio_calculado
```

Produtos iniciais:

- P13;
- P20;
- P45;
- água/galão.

## 3. O que o colaborador precisa contar

No fechamento, o colaborador deve informar a contagem física real.

Para cada produto, o sistema deve perguntar:

```text
Quantos cheios ficaram?
Quantos vazios/cascos ficaram?
```

Exemplo:

```text
P13:
Cheios físicos: ___
Vazios físicos: ___

P20:
Cheios físicos: ___
Vazios físicos: ___

P45:
Cheios físicos: ___
Vazios físicos: ___

Água/galão:
Cheios físicos: ___
Vazios físicos: ___
```

## 4. Comparação do fechamento

Depois que o colaborador informa a contagem física, o sistema compara:

```text
cheio_calculado x cheio_fisico
vazio_calculado x vazio_fisico
total_cascos_calculado x total_cascos_fisico
```

Onde:

```text
total_cascos_fisico = cheio_fisico + vazio_fisico
```

## 5. Fechamento sem divergência

Se todos os valores baterem, o sistema permite o encerramento do turno/dia.

Condição:

```text
cheio_calculado = cheio_fisico
vazio_calculado = vazio_fisico
total_cascos_calculado = total_cascos_fisico
```

Mensagem sugerida:

```text
Estoque conferido com sucesso. Turno/dia pode ser encerrado.
```

## 6. Fechamento com divergência

Se houver diferença, o sistema não deve apenas mostrar erro. Ele deve orientar a revisão.

Condição de divergência:

```text
cheio_calculado diferente de cheio_fisico
ou
vazio_calculado diferente de vazio_fisico
ou
total_cascos_calculado diferente de total_cascos_fisico
```

Mensagem sugerida:

```text
Estoque inconsistente. Revise os lançamentos antes de encerrar.
```

## 7. Diferença de cheio

Quando a diferença está no estoque cheio, o sistema deve ajudar a revisar:

- entradas do produto;
- vendas do líquido;
- lançamentos no produto errado;
- quantidades digitadas incorretamente;
- movimentações lançadas no canal/personagem errado;
- vendas de casco registradas de forma incorreta, quando afetarem a interpretação da operação.

Exemplo:

```text
P13 cheio calculado: 40
P13 cheio físico: 38
Diferença: -2
```

Interpretação possível:

- pode ter venda não lançada;
- pode ter entrada lançada a maior;
- pode ter produto contado errado;
- pode ter venda lançada em outro produto.

## 8. Diferença de vazio/casco

Quando a diferença está no vazio/casco, o sistema deve ajudar a revisar:

- entradas de cheio, porque toda entrada baixa vazio;
- vendas do líquido, porque toda venda do líquido aumenta vazio;
- vendas de casco, porque a venda de casco reduz o vazio gerado pela venda do líquido;
- erro de contagem física de casco;
- lançamento de casco em quantidade errada.

Exemplo:

```text
P13 vazio calculado: 22
P13 vazio físico: 20
Diferença: -2
```

Interpretação possível:

- pode ter venda de casco não lançada;
- pode ter entrada lançada em quantidade errada;
- pode ter venda do líquido lançada a maior;
- pode ter erro na contagem dos vazios.

## 9. Diferença no total de cascos

O total de cascos é uma trava importante.

```text
total_cascos = cheio + vazio
```

Nas entradas e vendas apenas do líquido, o total de cascos permanece estável.

O total de cascos muda quando há venda de casco.

Se o total de cascos físico não bater com o total calculado, o sistema deve revisar principalmente:

- venda de casco não lançada;
- venda de casco lançada a maior;
- venda de casco lançada em produto errado;
- erro de contagem física;
- entrada registrada incorretamente;
- alguma movimentação excepcional ainda não prevista.

## 10. Diagnóstico por canal/personagem

Quando houver divergência, o sistema deve permitir revisar por canal/personagem de venda.

Canais/personagens da Várzea Gás:

- André;
- João;
- Rogério;
- Portaria.

Regra importante:

```text
Portaria é canal de venda.
```

O sistema pode sugerir revisão assim:

```text
Revise as vendas de P13 por canal/personagem:
- André
- João
- Rogério
- Portaria
```

## 11. Diagnóstico por tipo de movimento

A revisão deve ser organizada por tipo de movimento:

1. entradas de produto cheio;
2. vendas do líquido;
3. vendas de casco.

Ordem sugerida de revisão:

```text
1. Conferir contagem física novamente.
2. Conferir entradas lançadas.
3. Conferir vendas do líquido por canal/personagem.
4. Conferir vendas de casco.
5. Conferir produto errado ou quantidade digitada errada.
```

## 12. Exemplo completo de fechamento

Estoque inicial de P13:

```text
Cheios: 50
Vazios: 30
Total de cascos: 80
```

Movimentos do dia:

```text
Entrada de 20 P13 cheios:
cheio +20
vazio -20

Venda do líquido de 25 P13:
cheio -25
vazio +25

Venda de casco de 3 P13:
vazio -3
```

Estoque calculado:

```text
Cheios: 45
Vazios: 32
Total de cascos: 77
```

Conferência física informada:

```text
Cheios: 45
Vazios: 32
Total de cascos: 77
```

Resultado:

```text
Estoque fechado com sucesso.
```

## 13. Exemplo com divergência

Estoque calculado de P13:

```text
Cheios: 45
Vazios: 32
Total de cascos: 77
```

Conferência física informada:

```text
Cheios: 45
Vazios: 30
Total de cascos: 75
```

Resultado:

```text
Divergência em P13 vazio/casco: -2
Divergência no total de cascos: -2
```

Revisão sugerida:

```text
1. Recontar vazios/cascos P13.
2. Revisar vendas de casco de P13.
3. Revisar entradas de P13.
4. Revisar vendas do líquido de P13 por canal/personagem.
```

## 14. Regra de bloqueio

Enquanto houver divergência, o sistema não deve considerar o fechamento concluído.

Regra:

```text
Se estoque inconsistente, não encerrar turno/dia.
```

O sistema deve permitir corrigir lançamentos e recalcular o fechamento.

## 15. Registro do fechamento

Quando o fechamento for concluído, o sistema deve registrar:

- data;
- revenda;
- operador/conferente;
- produto;
- cheio calculado;
- cheio físico;
- vazio calculado;
- vazio físico;
- total de cascos calculado;
- total de cascos físico;
- status do fechamento;
- observação, se houver.

Status possíveis:

```text
conferido
inconsistente
corrigido após revisão
```

## 16. Regra operacional final

```text
O colaborador não recebe a resposta pronta.
O colaborador informa a contagem física.
O sistema compara e cobra revisão se não bater.
O sistema ajuda a encontrar o provável erro.
Estoque inconsistente não encerra turno/dia.
```
