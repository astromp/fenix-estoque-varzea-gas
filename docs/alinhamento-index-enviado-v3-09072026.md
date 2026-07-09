# Alinhamento do index enviado — Operação Celular V3 — 09/07/2026

## Status

O arquivo `index(31).html` enviado pelo usuário foi usado como base visual da Operação Celular V3.

## Ajuste feito

Para evitar conflito com os arquivos anteriores `css/style.css` e `js/app.js`, o `index.html` principal do repositório passou a apontar para arquivos novos e compatíveis com esta interface:

```text
css/operacao-celular-v3.css
js/operacao-celular-v3.js
```

O arquivo de configuração permanece:

```text
js/config.js
```

## Telas preservadas do index enviado

```text
Dashboard
Abertura da manhã
Lançar venda
Estoque calculado
Fechamento físico
Correção
Histórico da tela
```

## Segurança

O GitHub continua sem chave real do Supabase. O `js/config.js` deve ser editado apenas localmente para teste.

## Regra de ouro

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
