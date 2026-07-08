# Plano do MVP Operacional pelo Celular — Projeto Fênix Estoque / Várzea Gás — 08/07/2026

## Status

Após a validação do Supabase, o próximo passo é construir a primeira versão operacional do sistema para uso diário pelo celular.

Este documento transforma o modelo de telas e a base validada no Supabase em um plano de construção do MVP.

## Objetivo do MVP

Criar uma primeira versão simples, funcional e testável para a Várzea Gás, permitindo:

1. Abrir o dia com conferência física da manhã.
2. Lançar vendas por canal/personagem.
3. Registrar venda do líquido.
4. Registrar venda de casco quando houver.
5. Lançar entrada de carga cheia.
6. Consultar resumo parcial.
7. Fazer fechamento físico da noite.
8. Comparar estoque calculado x estoque físico.
9. Bloquear encerramento se houver divergência.
10. Permitir correção antes de encerrar o dia.

## Regra de ouro

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```

## Decisão técnica inicial

Para o MVP, usar:

```text
Frontend: página web simples, mobile-first
Banco: Supabase já validado
Revenda inicial: Várzea Gás
```

O sistema deve nascer simples, mas organizado para permitir evolução para outras revendas.

## O que já está validado

O Supabase já possui:

- estrutura de tabelas criada;
- revenda cadastrada;
- produtos cadastrados;
- canais de venda cadastrados;
- usuários de teste;
- dia operacional de teste;
- abertura;
- lançamentos;
- movimentos;
- fechamento;
- itens de fechamento;
- simulação final com diferenças zeradas.

## Telas do MVP — versão 1

A ordem de construção deve ser:

```text
1. Painel do dia
2. Abertura da manhã
3. Lançar venda
4. Lançar entrada
5. Resumo parcial
6. Fechamento da noite
7. Resultado do fechamento
8. Correção de divergência
```

## 1. Painel do dia

Objetivo:

Ser a tela principal da operação.

Campos/elementos:

```text
Revenda: Várzea Gás
Data operacional
Status do dia
Botão: Abertura da manhã
Botão: Lançar venda
Botão: Lançar entrada
Botão: Resumo parcial
Botão: Fechamento da noite
Botão: Relatórios
```

Regras:

- se não houver abertura, bloquear venda e entrada;
- se o dia estiver fechado, bloquear lançamentos;
- se houver inconsistência, destacar revisão pendente.

Tabelas envolvidas:

```text
revendas
dias_operacionais
conferencias_abertura
fechamentos
```

## 2. Abertura da manhã

Objetivo:

Registrar o estoque físico inicial.

Produtos iniciais:

```text
P13
P05
P20
P45
AGUA
```

Campos por produto:

```text
cheios_fisicos
vazios_fisicos
```

Ao confirmar, gravar:

```text
dias_operacionais
conferencias_abertura
itens_conferencia_abertura
```

Regra:

```text
Sem abertura da manhã, o dia operacional não deve avançar.
```

## 3. Lançar venda

Objetivo:

Registrar venda do líquido e, se houver, venda de casco.

Campos:

```text
canal_venda
produto
quantidade_liquido
houve_venda_casco
quantidade_casco
```

Canais iniciais:

```text
André
João
Rogério
Portaria
Outros
```

Regra importante:

```text
Portaria é canal de venda.
```

Gravar:

```text
lancamentos
movimentos_estoque
```

Movimentos gerados:

Venda normal:

```text
venda_liquido
```

Venda com casco:

```text
venda_liquido
venda_casco vinculada à venda_liquido
```

Travas obrigatórias:

```text
quantidade_liquido > 0
quantidade_casco >= 0
quantidade_casco <= quantidade_liquido
venda_casco só existe junto com venda_liquido
venda sempre exige canal de venda
```

## 4. Lançar entrada

Objetivo:

Registrar chegada de produto cheio.

Campos:

```text
produto
quantidade_entrada_cheia
```

Movimento gerado:

```text
entrada_cheia
```

Regra operacional:

```text
cheio sobe
vazio desce na mesma quantidade
total de cascos permanece estável
```

Gravar:

```text
lancamentos
movimentos_estoque
```

Trava inicial:

```text
Não permitir entrada maior que os vazios disponíveis, salvo regra futura autorizada.
```

## 5. Resumo parcial

Objetivo:

Permitir acompanhamento administrativo do movimento do dia.

Mostrar:

```text
vendas por canal
vendas por produto
vendas de casco
estoque calculado até o momento
```

Atenção:

```text
O resumo parcial pode mostrar o calculado para administração.
A tela de fechamento não deve mostrar o estoque esperado antes da contagem física.
```

## 6. Fechamento da noite

Objetivo:

Registrar contagem física final.

Campos por produto:

```text
cheios_fisicos
vazios_fisicos
```

O sistema deve calcular internamente:

```text
cheios_calculados
vazios_calculados
total_calculado
total_fisico
diferenca_cheios
diferenca_vazios
diferenca_total
```

Gravar:

```text
fechamentos
itens_fechamento
divergencias_fechamento, se houver
```

Regra:

```text
Não mostrar o calculado antes da contagem física.
```

## 7. Resultado do fechamento

Se tudo bater:

```text
Produto: conferido
Diferenças: 0
Botão: Encerrar dia
```

Se houver divergência:

```text
Produto: inconsistente
Botão: Ver divergências
Encerramento bloqueado
```

Trava:

```text
O dia só pode ser encerrado se todos os produtos estiverem conferidos ou corrigidos.
```

## 8. Correção de divergência

Objetivo:

Corrigir erro sem apagar histórico.

Possíveis correções:

```text
corrigir_quantidade
corrigir_produto
corrigir_canal
adicionar_venda_casco
adicionar_venda_liquido
cancelar_lancamento
```

Regra:

```text
A correção deve preservar o lançamento original e registrar a alteração.
```

## Diagnóstico inteligente inicial

Primeira regra validada:

```text
Cheio a menos + vazio igual + total menor = provável venda de casco não lançada.
```

Exemplo:

```text
P45 calculado: 7 cheios / 13 vazios / total 20
P45 físico: 6 cheios / 13 vazios / total 19
Diferença: -1 cheio / 0 vazio / -1 total
Hipótese: provável venda de casco não lançada
```

## Critérios para considerar o MVP pronto

O MVP só deve ser considerado pronto quando conseguir executar este roteiro:

```text
1. Abrir o dia.
2. Registrar abertura de 5 produtos.
3. Lançar venda da Portaria.
4. Lançar venda do Rogério.
5. Lançar venda do André.
6. Lançar venda do João com casco.
7. Consultar resumo parcial.
8. Fazer fechamento físico.
9. Detectar divergência simulada.
10. Corrigir divergência.
11. Recalcular fechamento.
12. Encerrar o dia com diferenças zeradas.
```

## Primeira meta prática

A primeira meta de construção deve ser:

```text
Criar o painel do dia + abertura da manhã + lançamento de venda.
```

Somente depois avançar para entrada, fechamento e correção.

## Próxima entrega esperada

Criar uma primeira versão visual/protótipo funcional com:

```text
index.html
style.css
script.js
```

Conectado ou preparado para conexão com Supabase.

O protótipo deve priorizar uso no celular.

## Observação final

O MVP não precisa nascer bonito. Ele precisa nascer confiável.

Regra de construção:

```text
Primeiro funcionar.
Depois melhorar a aparência.
Depois automatizar.
```
