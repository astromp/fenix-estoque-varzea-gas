# Fluxo Celular de Fechamento — Projeto Fênix Estoque / Várzea Gás

Este documento transforma o modelo de fechamento em um fluxo prático para uso no celular pelo colaborador.

A ideia é que o sistema conduza a pessoa passo a passo, sem entregar a resposta pronta, cobrando a conferência física e impedindo o encerramento com estoque inconsistente.

## 1. Objetivo da tela

Criar uma experiência simples para fechamento do estoque no celular.

O colaborador deve conseguir:

- iniciar o fechamento;
- informar a contagem física por produto;
- revisar inconsistências;
- corrigir lançamentos;
- recalcular o fechamento;
- encerrar apenas quando tudo estiver conferido.

## 2. Princípio da tela

```text
O sistema calcula.
O colaborador conta.
O sistema compara.
Se bater, fecha.
Se não bater, orienta revisão.
```

## 3. Tela inicial do fechamento

Nome sugerido da tela:

```text
Fechamento de Estoque
```

Informações exibidas:

- revenda;
- data;
- turno ou período;
- operador/conferente;
- botão para iniciar conferência.

Exemplo:

```text
Fechamento de Estoque

Revenda: Várzea Gás
Data: 07/07/2026
Período: Dia
Conferente: __________

[Iniciar conferência]
```

## 4. Tela de seleção de produto

O sistema deve conduzir produto por produto.

Produtos iniciais:

- P13;
- P20;
- P45;
- água/galão.

Exemplo:

```text
Produto 1 de 4
P13

Informe a contagem física do estoque.
```

## 5. Tela de contagem física

Para cada produto, o sistema deve perguntar:

```text
Quantos cheios ficaram?
Quantos vazios/cascos ficaram?
```

Exemplo prático:

```text
P13

Cheios físicos:
[____]

Vazios/cascos físicos:
[____]

[Salvar e continuar]
```

## 6. Regra importante: não mostrar o resultado antes da contagem

O sistema não deve mostrar ao colaborador o estoque calculado antes da contagem física.

Motivo:

```text
A conferência precisa ser real.
O colaborador deve contar o estoque, não copiar o número esperado pelo sistema.
```

Depois que o colaborador informar a contagem, o sistema pode comparar e apontar se bateu ou não.

## 7. Confirmação produto por produto

Depois de informar cheios e vazios de um produto, o sistema pode mostrar apenas o status daquele item.

Se bater:

```text
P13 conferido com sucesso.
```

Se não bater:

```text
P13 inconsistente.
Revise antes de encerrar o fechamento.
```

## 8. Tela de resumo do fechamento

Depois de todos os produtos informados, o sistema mostra um resumo.

Exemplo sem divergência:

```text
Resumo do Fechamento

P13: conferido
P20: conferido
P45: conferido
Água/galão: conferido

Estoque conferido com sucesso.
[Encerrar turno/dia]
```

Exemplo com divergência:

```text
Resumo do Fechamento

P13: inconsistente
P20: conferido
P45: conferido
Água/galão: conferido

Existem inconsistências.
Revise antes de encerrar.
[Ver divergências]
```

## 9. Tela de divergência

Quando houver divergência, o sistema deve apontar onde está o problema.

Exemplo:

```text
Divergência em P13

Cheios: diferença de -2
Vazios/cascos: diferença de 0
Total de cascos: diferença de -2
```

Ou:

```text
Divergência em P13

Cheios: OK
Vazios/cascos: diferença de -2
Total de cascos: diferença de -2
```

## 10. Tela de orientação de revisão

O sistema deve ajudar o colaborador a revisar na ordem mais provável.

Ordem sugerida:

```text
1. Recontar fisicamente o produto.
2. Revisar entradas do produto.
3. Revisar vendas do líquido.
4. Revisar vendas de casco.
5. Revisar produto errado ou quantidade digitada errada.
```

Exemplo:

```text
P13 está inconsistente.

Revise nesta ordem:

1. Reconte cheios e vazios P13.
2. Confira entradas de P13.
3. Confira vendas do líquido de P13.
4. Confira vendas de casco de P13.
5. Veja se algum P13 foi lançado como P20/P45 ou água.
```

## 11. Revisão por canal/personagem

Para vendas, o sistema deve permitir revisar por canal/personagem.

Canais iniciais da Várzea Gás:

- André;
- João;
- Rogério;
- Portaria.

Lembrete obrigatório:

```text
Portaria é canal de venda.
```

Exemplo de tela:

```text
Revisar vendas de P13

André: ___ vendas
João: ___ vendas
Rogério: ___ vendas
Portaria: ___ vendas

[Ver detalhes]
```

## 12. Revisão por tipo de movimento

A tela de revisão deve separar os movimentos:

```text
Entradas
Vendas do líquido
Vendas de casco
```

Exemplo:

```text
P13 — Revisão

[Entradas]
[Vendas do líquido]
[Vendas de casco]
[Voltar ao resumo]
```

## 13. Corrigir e recalcular

Depois de corrigir uma movimentação, o sistema deve recalcular o fechamento.

Fluxo:

```text
Colaborador corrige lançamento
Sistema recalcula estoque esperado
Sistema compara novamente com a contagem física
Sistema atualiza o status do produto
```

Botão sugerido:

```text
[Recalcular fechamento]
```

## 14. Bloqueio de encerramento

Enquanto houver qualquer produto inconsistente, o botão de encerramento deve ficar bloqueado.

Regra:

```text
Se algum produto estiver inconsistente, não permitir encerrar turno/dia.
```

Mensagem sugerida:

```text
Não é possível encerrar. Existem divergências pendentes.
```

## 15. Encerramento com sucesso

Quando todos os produtos estiverem conferidos, o sistema permite encerrar.

Mensagem sugerida:

```text
Estoque conferido com sucesso.
Turno/dia encerrado.
```

Ao encerrar, o sistema grava:

- data;
- revenda;
- operador/conferente;
- produtos conferidos;
- cheios físicos;
- vazios físicos;
- cheios calculados;
- vazios calculados;
- status final;
- horário do fechamento.

## 16. Histórico do fechamento

O sistema deve manter histórico dos fechamentos.

Campos sugeridos:

- data;
- revenda;
- turno/período;
- conferente;
- status final;
- produtos com divergência;
- horário de início;
- horário de encerramento;
- observações.

Status possíveis:

```text
conferido
inconsistente
corrigido após revisão
```

## 17. Linguagem da tela

A linguagem deve ser simples, direta e firme.

Evitar termos técnicos demais.

Exemplos bons:

```text
Conte os botijões cheios.
Conte os cascos vazios.
Revise antes de encerrar.
Produto conferido.
Estoque inconsistente.
```

Evitar:

```text
Divergência sistêmica não conciliada.
Saldo contábil incompatível com saldo físico.
```

## 18. Fluxo completo resumido

```text
1. Iniciar fechamento
2. Informar conferente
3. Contar P13 cheios e vazios
4. Contar P20 cheios e vazios
5. Contar P45 cheios e vazios
6. Contar água/galão cheio e vazio
7. Sistema compara calculado x físico
8. Sistema mostra resumo
9. Se bater, encerra
10. Se não bater, mostra divergências
11. Colaborador revisa e corrige
12. Sistema recalcula
13. Só encerra quando estiver conferido
```

## 19. Regra final da experiência

```text
O sistema deve facilitar a vida do conferente,
mas não pode permitir estoque inconsistente.
```
