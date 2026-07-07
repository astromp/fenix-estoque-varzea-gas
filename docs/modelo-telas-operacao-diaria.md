# Modelo de Telas da Operação Diária — Projeto Fênix Estoque / Várzea Gás

Este documento define o primeiro desenho das telas que o colaborador usará no celular para operar o Projeto Fênix Estoque.

O objetivo é transformar as regras, o banco de dados e os relatórios em uma experiência simples de uso diário.

## 1. Princípio das telas

As telas devem ser simples, rápidas e guiadas.

Regra de experiência:

```text
Poucos botões.
Poucos campos.
Linguagem direta.
Sem termos técnicos desnecessários.
Tudo precisa gerar registro no banco de dados.
```

O colaborador deve conseguir fazer pelo celular:

- abrir o dia;
- lançar vendas;
- lançar venda com casco;
- lançar entradas;
- consultar resumo parcial;
- corrigir erro;
- fazer fechamento da noite;
- revisar divergências;
- encerrar o dia somente se estiver conferido.

## 2. Fluxo geral da operação diária

```text
1. Entrar no sistema
2. Escolher a revenda
3. Abrir o dia com conferência física da manhã
4. Lançar vendas e entradas durante o dia
5. Consultar resumo parcial quando necessário
6. Fazer fechamento físico da noite
7. Corrigir divergências, se houver
8. Encerrar o dia
9. Gerar relatórios
```

## 3. Tela: início

Nome sugerido:

```text
Projeto Fênix Estoque
```

Elementos:

```text
[Entrar]
```

Ou, se o usuário já estiver identificado:

```text
Bom dia, operador.

[Iniciar operação]
```

## 4. Tela: seleção da revenda

No início, haverá apenas Várzea Gás, mas o sistema deve nascer preparado para outras revendas.

Exemplo:

```text
Selecione a revenda

[Várzea Gás]
[Outras revendas futuras]
```

Ao selecionar a revenda, o sistema abre ou consulta o `dia_operacional` correspondente.

## 5. Tela: painel do dia

Esta será a tela principal da operação.

Exemplo:

```text
Várzea Gás
Data: 07/07/2026
Status: Aberto

[Abertura da manhã]
[Lançar venda]
[Lançar entrada]
[Resumo parcial]
[Fechamento da noite]
[Relatórios]
```

Regras:

- se a abertura da manhã ainda não foi feita, bloquear lançamento de vendas;
- se o dia estiver fechado, bloquear novos lançamentos;
- se houver fechamento inconsistente, destacar revisão pendente.

## 6. Tela: abertura da manhã

Objetivo:

Registrar a contagem física inicial do dia.

Exemplo:

```text
Abertura da manhã

Conte os produtos disponíveis no estoque.
```

Produtos exibidos:

```text
P13
P05
P20
P45
Água/galão
Outros, quando ativado
```

Para cada produto:

```text
P13
Cheios: [___]
Vazios/cascos: [___]

[Salvar produto]
```

Ao final:

```text
Resumo da abertura

P13: 100 cheios / 30 vazios
P05: 10 cheios / 5 vazios
P20: 10 cheios / 2 vazios
P45: 10 cheios / 10 vazios
Água: 50 cheios / 10 vazios

[Confirmar abertura do dia]
```

Regra:

```text
Sem abertura da manhã, não iniciar a operação do dia.
```

## 7. Tela: lançar venda

Objetivo:

Registrar venda do líquido e, quando existir, venda de casco.

Exemplo:

```text
Lançar venda

Canal de venda:
[André]
[João]
[Rogério]
[Portaria]
[Outros]
```

Depois de escolher o canal:

```text
Produto:
[P13]
[P05]
[P20]
[P45]
[Água/galão]
[Outros]

Quantidade vendida do líquido:
[___]

Teve venda de casco?
[Não]
[Sim]
```

Se marcar `Sim`:

```text
Quantidade de cascos vendidos:
[___]
```

Botões:

```text
[Salvar venda]
[Salvar e lançar outra]
[Cancelar]
```

## 8. Regra da venda de casco na tela

A tela deve impedir venda de casco sem venda do líquido.

Exemplo proibido:

```text
Quantidade vendida do líquido: 0
Quantidade de cascos vendidos: 1
```

Mensagem:

```text
Venda de casco só pode existir junto com venda do líquido.
```

Outra trava:

```text
Quantidade de cascos vendidos não pode ser maior que a quantidade vendida do líquido.
```

Exemplo proibido:

```text
Venda do líquido: 1
Venda de casco: 2
```

Mensagem:

```text
A quantidade de cascos vendidos não pode ser maior que a venda do líquido.
```

## 9. Exemplo de lançamento de venda comum

Operação:

```text
Portaria vendeu 10 P13.
```

Tela:

```text
Canal: Portaria
Produto: P13
Venda do líquido: 10
Venda de casco: Não
```

Registro gerado:

```text
lancamento: venda
movimento: venda_liquido
produto: P13
quantidade: 10
canal: Portaria
```

## 10. Exemplo de lançamento de venda com casco

Operação:

```text
João vendeu 10 P13, sendo 1 com casco.
```

Tela:

```text
Canal: João
Produto: P13
Venda do líquido: 10
Venda de casco: Sim
Quantidade de cascos vendidos: 1
```

Registros gerados:

```text
movimento 1:
tipo: venda_liquido
produto: P13
quantidade: 10
canal: João

movimento 2:
tipo: venda_casco
produto: P13
quantidade: 1
canal: João
vinculado ao movimento 1
```

## 11. Tela: lançar entrada

Objetivo:

Registrar chegada de produto cheio.

Exemplo:

```text
Lançar entrada

Produto:
[P13]
[P05]
[P20]
[P45]
[Água/galão]
[Outros]

Quantidade de cheios que entrou:
[___]

[Salvar entrada]
```

Regra automática:

```text
Entrada de cheio aumenta cheio e diminui vazio na mesma quantidade.
```

Exemplo:

```text
Entrou 20 P13 cheios.

cheio +20
vazio -20
total de cascos não muda
```

Validação:

```text
Não permitir entrada maior que a quantidade de vazios disponíveis, salvo regra especial futura.
```

## 12. Tela: resumo parcial

Objetivo:

Permitir que o operador acompanhe o movimento do dia.

Exemplo:

```text
Resumo parcial — 07/07/2026

Vendas por canal:

Portaria
P13: 10
P05: 1
P20: 1
P45: 2

Rogério
P13: 20
P20: 1
P45: 1

André
P13: 10

João
P13: 10
Casco P13: 1
```

Também pode mostrar estoque calculado até o momento:

```text
Estoque calculado agora

P13: 50 cheios / 79 vazios
P05: 9 cheios / 6 vazios
P20: 8 cheios / 4 vazios
P45: 7 cheios / 13 vazios
Água: 50 cheios / 10 vazios
```

Observação importante:

```text
No fechamento, antes da contagem física, o sistema não deve mostrar o número esperado para o conferente copiar.
```

O resumo parcial pode existir para acompanhamento administrativo, mas a tela de fechamento deve cobrar contagem real.

## 13. Tela: lista de lançamentos do dia

Objetivo:

Permitir consulta e correção.

Exemplo:

```text
Lançamentos do dia

08:30 — Portaria — P13 — venda líquido 10
09:10 — Rogério — P13 — venda líquido 20
10:15 — João — P13 — venda líquido 10 + casco 1
```

Ao tocar em um lançamento:

```text
Detalhes do lançamento

Canal: João
Produto: P13
Venda do líquido: 10
Venda de casco: 1
Usuário: Operador
Horário: 10:15

[Corrigir]
[Cancelar lançamento]
[Voltar]
```

## 14. Tela: correção de lançamento

Objetivo:

Corrigir erro sem apagar histórico.

Regra:

```text
Correção deve preservar o lançamento original e registrar o que foi alterado.
```

Opções:

```text
Corrigir quantidade
Corrigir produto
Corrigir canal de venda
Adicionar venda de casco
Adicionar venda do líquido
Cancelar lançamento
```

Exemplo:

```text
Adicionar venda de casco

Produto: P45
Quantidade de cascos vendidos: 1
Motivo: divergência no fechamento

[Salvar correção]
```

## 15. Tela: fechamento da noite

Objetivo:

Registrar contagem física final e comparar com o calculado.

Tela inicial:

```text
Fechamento da noite

Conte o estoque físico antes de encerrar.

[Iniciar fechamento]
```

Para cada produto:

```text
P13
Cheios físicos: [___]
Vazios/cascos físicos: [___]

[Salvar e continuar]
```

Regra:

```text
Não mostrar o estoque calculado antes da contagem física.
```

## 16. Tela: resultado do fechamento

Se todos os produtos baterem:

```text
Estoque conferido com sucesso.

P13: conferido
P05: conferido
P20: conferido
P45: conferido
Água: conferido

[Encerrar dia]
```

Se houver divergência:

```text
Estoque inconsistente.

P13: conferido
P05: conferido
P20: conferido
P45: inconsistente
Água: conferido

[Ver divergências]
```

Regra:

```text
Com divergência, bloquear encerramento do dia.
```

## 17. Tela: divergência encontrada

Exemplo da simulação:

```text
Divergência em P45

Calculado:
7 cheios / 13 vazios / total 20

Contado:
6 cheios / 13 vazios / total 19

Diferença:
-1 cheio
0 vazio
-1 total de cascos
```

Diagnóstico inteligente:

```text
Possível causa:
1 P45 vendido com casco e não lançado como venda de casco.
```

Botões:

```text
[Recontar P45]
[Revisar vendas de P45]
[Adicionar venda de casco]
[Voltar]
```

## 18. Tela: revisão por canal

Quando houver divergência, revisar por canal/personagem.

Exemplo:

```text
Revisar P45

Portaria: 2 vendas do líquido
Rogério: 1 venda do líquido
André: 0
João: 0

Possível venda de casco não lançada.
```

Botões:

```text
[Ver Portaria]
[Ver Rogério]
[Adicionar casco P45]
```

## 19. Tela: encerrar dia

Só aparece quando todos os produtos estiverem conferidos.

Exemplo:

```text
Tudo conferido.

Deseja encerrar o dia 07/07/2026 da Várzea Gás?

[Encerrar dia]
[Voltar]
```

Após encerrar:

```text
Dia encerrado com sucesso.
```

Regra:

```text
Depois de encerrado, novos lançamentos só podem ocorrer por reabertura autorizada ou correção administrativa futura.
```

## 20. Tela: relatórios

Objetivo:

Consultar vendas por período, canal e produto.

Opções mínimas:

```text
[Vendas do dia]
[Vendas da semana]
[Vendas do mês]
[Escolher período]
[Vendas de casco]
```

Filtros:

```text
Revenda
Data inicial
Data final
Canal de venda
Produto
Tipo de movimento
```

## 21. Tela: vendas do dia por canal

Exemplo:

```text
Vendas do dia — 07/07/2026

Canal      P13   P05   P20   P45   Água
Portaria   10     1     1     2     0
Rogério    20     0     1     1     0
André      10     0     0     0     0
João       10     0     0     0     0
```

Venda de casco:

```text
Cascos vendidos

João — P13: 1
```

## 22. Tela: vendas por período

Exemplo:

```text
Escolher período

Data inicial: [__/__/____]
Data final: [__/__/____]
Canal: [Todos]
Produto: [Todos]

[Gerar relatório]
```

Resultado:

```text
Relatório de vendas
Período: 01/07/2026 a 31/07/2026
Revenda: Várzea Gás
Canal: Todos
Produto: Todos
```

## 23. Regras de bloqueio

O sistema deve bloquear:

- lançamento sem abertura do dia;
- venda sem canal/personagem;
- venda sem produto;
- venda com quantidade menor ou igual a zero;
- venda de casco sem venda do líquido;
- venda de casco maior que venda do líquido;
- entrada maior que vazios disponíveis, salvo regra futura;
- fechamento sem todos os produtos contados;
- encerramento com divergência;
- lançamento em dia já encerrado.

## 24. Regras de facilidade

O sistema deve facilitar:

- botões grandes no celular;
- repetição rápida de venda;
- botão `Salvar e lançar outra`;
- produtos em ordem fixa;
- canais em ordem fixa;
- alertas claros;
- resumo por canal;
- revisão guiada de divergência.

## 25. Ordem inicial de desenvolvimento das telas

Prioridade sugerida:

```text
1. Tela de abertura da manhã
2. Tela de lançamento de venda
3. Tela de lançamento de entrada
4. Tela de resumo parcial
5. Tela de fechamento da noite
6. Tela de divergência e correção
7. Tela de relatórios
```

## 26. Regra final

```text
A tela não pode ser bonita apenas.
Ela precisa impedir erro, facilitar lançamento e gerar relatório confiável.
```
