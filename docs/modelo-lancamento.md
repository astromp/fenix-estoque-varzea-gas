# Modelo de Lançamento — Projeto Fênix Estoque / Várzea Gás

Este documento transforma os conceitos do estoque em um modelo prático de lançamento para o colaborador usar no dia a dia.

## 1. Objetivo

Criar um lançamento simples, rápido e conferível, sem abrir espaço para interpretações erradas.

O sistema deve permitir lançar:

- entrada de produto cheio;
- venda do líquido;
- venda de casco vinculada à venda do líquido.

## 2. Campos mínimos do lançamento

Cada movimentação deve registrar, no mínimo:

| Campo | Obrigatório | Observação |
|---|---:|---|
| Data | Sim | Data da movimentação |
| Revenda | Sim | Inicialmente Várzea Gás |
| Produto | Sim | P13, P20, P45, água/galão etc. |
| Canal/personagem | Sim para venda | André, João, Rogério, Portaria etc. |
| Tipo de movimento | Sim | Entrada, venda do líquido ou venda de casco |
| Quantidade | Sim | Sempre número inteiro positivo |
| Operador | Sim | Quem lançou a movimentação |
| Observação | Não | Campo livre para justificar algo relevante |

## 3. Produtos iniciais

Produtos previstos para a primeira versão:

- P13;
- P20;
- P45;
- água/galão.

Cada produto deve ter controle separado de:

```text
cheio
vazio/casco
total de cascos
```

## 4. Canais/personagens da Várzea Gás

Canais/personagens iniciais:

- André;
- João;
- Rogério;
- Portaria.

Regra importante:

```text
Portaria é canal de venda.
```

Não interpretar Portaria como portão físico, retirada, conferência ou etapa intermediária.

## 5. Tipo 1 — Entrada de produto cheio

Entrada significa chegada de produto cheio na revenda.

O colaborador informa:

```text
Produto
Quantidade
Operador
Observação, se necessário
```

Regra de estoque:

```text
cheio += quantidade
vazio -= quantidade
total_cascos não muda
```

Exemplo:

```text
Produto: P13
Movimento: entrada de produto cheio
Quantidade: 10

Resultado:
P13 cheio +10
P13 vazio -10
total de cascos P13 não muda
```

## 6. Tipo 2 — Venda do líquido

Venda do líquido é a venda normal: o cliente recebe cheio e devolve vazio/casco.

O colaborador informa:

```text
Produto
Canal/personagem
Quantidade
Operador
Observação, se necessário
```

Regra de estoque:

```text
cheio -= quantidade
vazio += quantidade
total_cascos não muda
```

Exemplo:

```text
Produto: P13
Canal/personagem: André
Movimento: venda do líquido
Quantidade: 5

Resultado:
P13 cheio -5
P13 vazio +5
total de cascos P13 não muda
```

## 7. Tipo 3 — Venda de casco

Venda de casco significa que o cliente compra também o casco junto com o produto cheio.

Regra obrigatória:

```text
Venda de casco só pode existir junto com venda do líquido.
```

Não deve existir lançamento de venda de casco isolado.

O sistema deve impedir ou alertar se alguém tentar lançar venda de casco sem venda do líquido correspondente.

## 8. Como lançar venda de casco na prática

A forma mais simples para o colaborador é lançar a venda uma única vez, marcando se houve venda de casco.

Exemplo de tela mental:

```text
Produto: P13
Canal/personagem: Portaria
Quantidade vendida do líquido: 2
Houve venda de casco? Sim
Quantidade de cascos vendidos: 2
Operador: nome de quem lançou
```

O sistema calcula por trás:

```text
venda_do_liquido:
cheio -= 2
vazio += 2

venda_de_casco:
vazio -= 2
```

Resultado final:

```text
P13 cheio -2
P13 vazio não muda
total de cascos P13 -2
```

## 9. Trava obrigatória da venda de casco

A quantidade de cascos vendidos não pode ser maior que a quantidade de líquido vendido na mesma operação.

Regra:

```text
quantidade_venda_casco <= quantidade_venda_liquido
```

Exemplo permitido:

```text
Venda do líquido: 3 P13
Venda de casco: 1 P13
```

Exemplo proibido:

```text
Venda do líquido: 1 P13
Venda de casco: 2 P13
```

## 10. Resultado quando vende líquido e casco em quantidades diferentes

Exemplo:

```text
Venda do líquido: 3 P13
Venda de casco: 1 P13
```

Cálculo:

```text
venda_do_liquido:
cheio -= 3
vazio += 3

venda_de_casco:
vazio -= 1
```

Resultado final:

```text
P13 cheio -3
P13 vazio +2
total de cascos P13 -1
```

Interpretação:

- foram vendidos 3 líquidos;
- voltaram 2 cascos vazios;
- 1 casco foi vendido ao cliente.

## 11. Validações do sistema

O sistema deve validar:

- quantidade precisa ser maior que zero;
- produto precisa existir;
- canal/personagem precisa existir para venda;
- Portaria deve ser aceita como canal de venda;
- venda de casco não pode existir sem venda do líquido;
- venda de casco não pode ser maior que a venda do líquido;
- entrada de cheio deve baixar vazio na mesma quantidade;
- venda do líquido deve gerar retorno de vazio, salvo a parte vendida como casco.

## 12. Fechamento do dia ou turno

Ao fechar, o sistema deve calcular o estoque esperado e pedir a conferência física.

Perguntas de fechamento por produto:

```text
Quantos cheios ficaram?
Quantos vazios/cascos ficaram?
```

O sistema compara:

```text
cheio calculado x cheio físico informado
vazio calculado x vazio físico informado
total de cascos calculado x total de cascos físico
```

Se não bater, o sistema deve apontar estoque inconsistente e orientar a revisão.

## 13. Regra operacional final

```text
Entrada: cheio sobe, vazio desce.
Venda do líquido: cheio desce, vazio sobe.
Venda de casco: só existe junto com venda do líquido e reduz o total de cascos.
Portaria é canal de venda.
Estoque inconsistente não encerra turno/dia sem revisão.
```
