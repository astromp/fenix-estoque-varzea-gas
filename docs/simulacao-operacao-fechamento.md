# Simulação de Operação e Fechamento — Várzea Gás

Este documento registra uma simulação prática da operação diária da Várzea Gás para validar as regras do Projeto Fênix Estoque.

A simulação demonstra abertura, vendas, fechamento físico e diagnóstico de divergência.

## 1. Produtos controlados na simulação

Produtos utilizados:

- P13;
- P05;
- P20;
- P45;
- água/galão.

Observação: o P05 apareceu na simulação operacional e deve ser tratado como produto controlado quando existir na revenda.

## 2. Canais/personagens de venda

Canais usados na simulação:

- Portaria;
- Rogério;
- André;
- João.

Regra mantida:

```text
Portaria é canal de venda.
```

## 3. Abertura da manhã

Estoque inicial informado:

```text
P13:
100 cheios
30 vazios
Total de cascos: 130

P05:
10 cheios
5 vazios
Total de cascos: 15

P20:
10 cheios
2 vazios
Total de cascos: 12

P45:
10 cheios
10 vazios
Total de cascos: 20

Água/galão:
50 cheios
10 vazios
Total de vasilhames: 60
```

Total geral controlado na abertura:

```text
P13: 130
P05: 15
P20: 12
P45: 20
Água/galão: 60

Total geral: 237
```

## 4. Entradas do dia

Neste dia não houve entrada de produto cheio.

```text
P13: 0
P05: 0
P20: 0
P45: 0
Água/galão: 0
```

## 5. Vendas do dia

Vendas informadas:

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

Interpretação da simulação:

```text
Todas as vendas foram venda do líquido,
exceto 1 P13 do João, que foi venda do líquido + venda de casco.
```

## 6. Total vendido por produto

```text
P13:
Venda do líquido: 50
Venda de casco: 1

P05:
Venda do líquido: 1
Venda de casco: 0

P20:
Venda do líquido: 2
Venda de casco: 0

P45:
Venda do líquido: 3
Venda de casco: 0

Água/galão:
Venda do líquido: 0
Venda de casco/vasilhame: 0
```

## 7. Estoque calculado após vendas

## P13

```text
Inicial: 100 cheios / 30 vazios
Venda do líquido: 50
Venda de casco: 1

Cheios finais calculados: 100 - 50 = 50
Vazios finais calculados: 30 + 50 - 1 = 79
Total de cascos calculado: 50 + 79 = 129
```

## P05

```text
Inicial: 10 cheios / 5 vazios
Venda do líquido: 1
Venda de casco: 0

Cheios finais calculados: 10 - 1 = 9
Vazios finais calculados: 5 + 1 = 6
Total de cascos calculado: 9 + 6 = 15
```

## P20

```text
Inicial: 10 cheios / 2 vazios
Venda do líquido: 2
Venda de casco: 0

Cheios finais calculados: 10 - 2 = 8
Vazios finais calculados: 2 + 2 = 4
Total de cascos calculado: 8 + 4 = 12
```

## P45

```text
Inicial: 10 cheios / 10 vazios
Venda do líquido: 3
Venda de casco: 0

Cheios finais calculados: 10 - 3 = 7
Vazios finais calculados: 10 + 3 = 13
Total de cascos calculado: 7 + 13 = 20
```

## Água/galão

```text
Inicial: 50 cheios / 10 vazios
Venda do líquido: 0
Venda de casco/vasilhame: 0

Cheios finais calculados: 50
Vazios finais calculados: 10
Total calculado: 60
```

## 8. Resumo calculado

```text
P13: 50 cheios / 79 vazios / total 129
P05: 9 cheios / 6 vazios / total 15
P20: 8 cheios / 4 vazios / total 12
P45: 7 cheios / 13 vazios / total 20
Água/galão: 50 cheios / 10 vazios / total 60
```

## 9. Fechamento físico informado

Contagem física da noite:

```text
P13: 50 cheios / 79 vazios
P05: 9 cheios / 6 vazios
P20: 8 cheios / 4 vazios
P45: 6 cheios / 13 vazios
Água/galão: 50 cheios / 10 vazios
```

## 10. Comparação calculado x físico

## P13

```text
Calculado: 50 cheios / 79 vazios / total 129
Físico:    50 cheios / 79 vazios / total 129
Status: conferido
```

## P05

```text
Calculado: 9 cheios / 6 vazios / total 15
Físico:    9 cheios / 6 vazios / total 15
Status: conferido
```

## P20

```text
Calculado: 8 cheios / 4 vazios / total 12
Físico:    8 cheios / 4 vazios / total 12
Status: conferido
```

## P45

```text
Calculado: 7 cheios / 13 vazios / total 20
Físico:    6 cheios / 13 vazios / total 19
Status: inconsistente
```

## Água/galão

```text
Calculado: 50 cheios / 10 vazios / total 60
Físico:    50 cheios / 10 vazios / total 60
Status: conferido
```

## 11. Resultado do fechamento

```text
P13: conferido
P05: conferido
P20: conferido
P45: inconsistente
Água/galão: conferido
```

O fechamento não pode ser encerrado enquanto o P45 estiver inconsistente.

## 12. Diagnóstico da divergência do P45

Diferença encontrada:

```text
P45 cheio: -1
P45 vazio: 0
Total de cascos P45: -1
```

Interpretação provável:

```text
Existe forte indício de 1 venda de P45 com casco não lançada.
```

Motivo:

Na venda do líquido normal:

```text
cheio -1
vazio +1
total de cascos não muda
```

Na venda do líquido com venda de casco:

```text
cheio -1
vazio não muda no resultado final
total de cascos -1
```

Como o fechamento físico mostrou 1 cheio a menos, vazio igual e total de cascos 1 menor, a hipótese mais provável é venda de casco não lançada.

## 13. Revisão sugerida pelo sistema

Mensagem sugerida:

```text
P45 inconsistente.

Calculado:
7 cheios / 13 vazios / total 20

Contado:
6 cheios / 13 vazios / total 19

Diferença:
-1 cheio
0 vazio
-1 total de cascos

Possível causa:
1 P45 vendido com casco e não lançado como venda de casco.
```

Ordem de revisão:

```text
1. Recontar P45 cheio.
2. Conferir se houve 1 venda de P45 com casco.
3. Revisar vendas de P45 da Portaria.
4. Revisar venda de P45 do Rogério.
5. Corrigir o lançamento e recalcular.
```

## 14. Correção provável

Se confirmado que houve 1 venda de P45 com casco, corrigir o lançamento incluindo:

```text
Venda de casco: 1 P45
```

Novo cálculo esperado do P45:

```text
Cheios: 7 calculado anteriormente, mas a venda com casco já estava no líquido vendido.
Vazios: 13 - 1 = 12 se o líquido já tinha sido lançado como venda comum.
```

Atenção: a forma correta de corrigir depende de como a venda foi lançada originalmente.

Se faltou lançar a venda inteira:

```text
cheio -1
vazio +1
venda_casco -1
resultado: cheio -1, vazio não muda, total -1
```

Se a venda já foi lançada como líquido, mas faltou marcar o casco:

```text
vazio -1
```

O sistema deve mostrar a opção de correção conforme o lançamento original encontrado.

## 15. Aprendizado da simulação

Esta simulação prova que o sistema não deve apenas dizer “erro”.

Ele deve apontar a provável causa:

```text
Cheio a menos + vazio igual + total menor = provável venda com casco não lançada.
```

Essa inteligência reduz o trabalho do conferente e aumenta a chance de correção rápida.
