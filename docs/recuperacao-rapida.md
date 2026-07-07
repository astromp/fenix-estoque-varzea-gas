# Recuperação Rápida — Projeto Fênix Estoque / Várzea Gás

Este arquivo existe para recuperar rapidamente o raciocínio do projeto caso a memória se perca.

## Resumo do projeto

O Projeto Fênix Estoque é um controle de estoque para revendas de gás e água, começando pela Várzea Gás.

A lógica deve ser simples, padronizada e conferível pelo celular ou outro sistema operacional escolhido futuramente.

## Regra central das entradas

Entrada é chegada de produto cheio.

A mesma quantidade de cheio que entra deve sair de vazio/casco.

```text
entrada_cheia:
cheio += quantidade
vazio -= quantidade
```

## Regra central das vendas por troca

Venda por troca significa que sai cheio e volta vazio/casco.

```text
venda_por_troca:
cheio -= quantidade
vazio += quantidade
```

## Regra da venda sem troca

Venda sem troca significa que sai cheio e não volta vazio/casco.

```text
venda_sem_troca:
cheio -= quantidade
vazio não muda
```

Consequência:

```text
total_cascos -= quantidade
```

A venda sem troca deve ser lançada separadamente da venda por troca, porque ela muda o total de cascos da revenda.

## Regra de total de cascos

```text
total_cascos = cheio + vazio
```

Nas entradas e vendas por troca, o total de cascos permanece estável.

Na venda sem troca, o total de cascos diminui na quantidade vendida sem retorno de vazio/casco.

## Canais/personagens da Várzea Gás

- André;
- João;
- Rogério;
- Portaria.

Portaria é canal de venda, igual aos demais.

Não interpretar Portaria como portão físico, retirada, conferência ou etapa intermediária.

## Fechamento

O sistema deve cobrar a conferência física no encerramento.

Se o estoque calculado não bater com o estoque físico, o sistema deve apontar inconsistência e orientar a revisão.

## Lema operacional

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```

## Próximos passos sugeridos

1. Definir tela/fluxo de lançamento.
2. Definir produtos iniciais.
3. Definir campos mínimos de cada movimento.
4. Criar protótipo simples.
5. Testar com movimentações reais da Várzea Gás.
6. Só depois replicar para outra revenda.
