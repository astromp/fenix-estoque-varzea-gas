# Ajuste de Assinaturas RPC — V4.1 — 09/07/2026

## Situação encontrada

Durante o teste da V4 operacional em uma data nova, o status do dia retornou corretamente como `sem abertura`, confirmando que a conexão com o Supabase e a função de status estavam funcionando.

Na etapa de abertura, a tela retornou erro de assinatura na função:

```text
registrar_abertura_mvp
```

O erro indicou que a chamada estava enviando parâmetros demais e misturados, como combinações de `p_data_operacional`, `p_data`, `revenda`, `revenda_codigo`, campos simples e campos de abertura no mesmo payload.

## Interpretação

A falha não indica perda da lógica do MVP.

O ciclo principal da V3 já havia sido validado anteriormente:

```text
sem abertura -> aberto -> fechado
```

A falha está na camada nova da V4, que tentou generalizar chamadas RPC para diferentes possíveis assinaturas e acabou enviando uma combinação ampla demais na tentativa final.

## Ajuste feito na V4.1

A V4.1 passa a testar assinaturas limpas e separadas:

```text
1. payload com p_abertura JSON;
2. payload com p_contagem JSON;
3. payload com p_estoque_inicial JSON;
4. payload com p_itens JSON;
5. payload com nomes p_p13_cheios, p_p13_vazios etc.;
6. payload com nomes p13_cheios, p13_vazios etc.;
7. payload com nomes p13_abertura_cheios, p13_abertura_vazios etc.
```

O ponto principal é não misturar todas as formas no mesmo payload.

## Melhoria de suporte técnico

A V4.1 também registra no histórico técnico quais tentativas foram feitas, para facilitar identificar a assinatura exata caso uma função ainda retorne erro.

## Segurança

A correção documentada no GitHub não contém chave real do Supabase.

A chave real deve permanecer apenas em arquivo local de teste ou em ambiente controlado.

## Regra preservada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
