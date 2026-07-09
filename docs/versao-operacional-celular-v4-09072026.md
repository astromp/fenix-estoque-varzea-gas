# Versão Operacional Celular V4 — 09/07/2026

## Objetivo

Após validar a conexão do arquivo corrigido com o Supabase, a próxima etapa foi preparar uma versão mais simples para uso operacional no celular.

## O que foi confirmado antes da V4

```text
1. O CSS carregou corretamente.
2. O JavaScript carregou corretamente.
3. A configuração local com Supabase URL e anon public key funcionou.
4. O badge mudou para Conectado.
5. A consulta de status retornou fechado para 09/07/2026.
```

A leitura `fechado` confirma que o sistema conseguiu consultar o banco e reconhecer um dia operacional já encerrado.

## O que a V4 melhora

A V4 mantém a lógica já validada, mas melhora a experiência do colaborador:

```text
1. textos mais simples;
2. botões com ordem operacional;
3. painel de Próximo passo;
4. orientação conforme o status do dia;
5. menor dependência de leitura técnica pelo usuário;
6. histórico tratado como suporte técnico, não como tela principal.
```

## Ordem operacional da tela

```text
1. Abrir o dia
2. Registrar venda
3. Fechar o dia
Corrigir estoque, se houver inconsistência
Conferir saldo, como consulta administrativa
Suporte técnico, apenas para mensagens do sistema
```

## Regras de status preservadas

```text
sem_abertura -> permite abertura
aberto -> permite venda, estoque e fechamento
inconsistente -> permite correção e novo fechamento
fechado -> bloqueia operação normal
```

## Segurança

A versão local de teste pode conter configuração local do Supabase, mas nenhuma chave real deve ser gravada no GitHub público.

O repositório deve continuar guardando apenas documentação, placeholders e versões sem segredo real.

## Regra de ouro

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
