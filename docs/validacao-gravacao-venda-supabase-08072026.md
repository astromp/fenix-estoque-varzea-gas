# Validação de Gravação de Venda no Supabase — 08/07/2026

## Status

Validação realizada com sucesso.

O frontend local conseguiu gravar venda no Supabase usando a função controlada `registrar_venda_mvp`.

## Resultado confirmado

O teste confirmou gravação com sucesso para venda com casco:

```text
Gravação: OK
Mensagem: Venda registrada com sucesso.
Canal: João
Produto: P13
Líquido: 10
Casco: 1
Lançamento ID: gerado
```

## Tabelas envolvidas

A função controlada grava nas estruturas relacionadas a:

```text
lancamentos
movimentos_estoque
```

## Regra operacional validada

Venda com casco registrada corretamente:

```text
Produto: P13
Canal: João
Venda do líquido: 10
Venda de casco: 1
```

Efeito esperado no estoque:

```text
cheios: -10
vazios: +10 pela venda do líquido
vazios: -1 pela venda de casco
resultado líquido em vazios: +9
total de cascos: -1
```

## Segurança aplicada

A gravação foi feita por função controlada no Supabase, e não por insert direto liberado ao frontend.

Função usada:

```text
registrar_venda_mvp
```

A função foi concedida ao papel `anon` por meio de `grant execute`, mantendo a lógica de gravação centralizada no banco.

## Travas da função

A função controla:

- canal de venda obrigatório;
- produto obrigatório;
- quantidade do líquido maior que zero;
- quantidade de casco não negativa;
- quantidade de casco não maior que a venda do líquido;
- venda somente em dia operacional existente;
- bloqueio de venda em dia fechado;
- exigência de abertura ativa antes de vender;
- canal ativo da Várzea Gás;
- produto ativo.

## Observação operacional

Portaria continua tratada como canal de venda, assim como André, João e Rogério.

## Próximo passo

Com abertura e venda gravando no Supabase, o próximo passo é validar o estoque calculado a partir da abertura e dos movimentos gravados.

A próxima tela/função deve consultar o estoque esperado por produto e confirmar se a venda com casco alterou o saldo corretamente.

## Regra de ouro preservada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
