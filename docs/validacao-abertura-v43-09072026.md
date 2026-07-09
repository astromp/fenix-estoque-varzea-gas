# Validação da abertura — V4.3 — 09/07/2026

## Resultado

A V4.3 corrigiu o envio dos itens da abertura em formato de lista e conseguiu registrar a abertura da manhã com sucesso.

## Data testada

```text
14/07/2026
```

## Fluxo confirmado

```text
sem_abertura -> aberto
```

## Evidência operacional

Após clicar em `Gravar abertura no Supabase`, a tela retornou:

```text
Status: aberto
Mensagem: Dia aberto. Vendas, estoque e fechamento liberados.
Próximo passo: Dia aberto. Registre as vendas e faça o fechamento no final.
```

## Interpretação

A correção da V4.3 confirmou que a função `registrar_abertura_mvp` esperava os itens da abertura em formato de lista/array.

A conexão com Supabase, a consulta de status e o registro da abertura estão funcionando para a versão operacional de celular.

## Próximo teste recomendado

Validar o registro de venda na V4.3:

```text
1. Registrar venda Portaria P13 — 10 sem casco;
2. Registrar venda João P13 — 10 com 1 casco;
3. Consultar estoque calculado;
4. Fazer fechamento físico.
```

## Regra preservada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
