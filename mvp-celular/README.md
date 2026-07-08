# MVP Celular — Projeto Fênix Estoque / Várzea Gás

Primeira versão visual e funcional do fluxo operacional pelo celular.

## Arquivos

```text
index.html
style.css
script.js
```

## O que esta versão faz

Esta versão roda em **modo teste local**, usando `localStorage` do navegador.

Ela permite testar:

- painel do dia;
- abertura da manhã;
- lançamento de venda;
- venda com casco;
- lançamento de entrada;
- resumo parcial;
- fechamento da noite;
- bloqueio de encerramento quando houver divergência.

## Regra operacional preservada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```

## Produtos iniciais

```text
P13
P05
P20
P45
AGUA
```

## Canais iniciais

```text
André
João
Rogério
Portaria
Outros
```

Observação:

```text
Portaria é canal de venda, assim como André, João e Rogério.
```

## Supabase

A URL pública já está registrada no `script.js`:

```text
https://pxlapmdypnmvymgbpzhi.supabase.co
```

Ainda não foi colocada a chave pública `anon key`.

Nunca colocar no frontend:

```text
service_role key
senha do banco
DATABASE_URL
```

## Como testar

1. Abrir `index.html` no navegador.
2. Clicar em **Abertura da manhã**.
3. Preencher a abertura ou clicar em **Preencher exemplo validado**.
4. Voltar ao painel.
5. Clicar em **Lançar venda**.
6. Registrar vendas por canal.
7. Conferir o **Resumo parcial**.
8. Fazer o **Fechamento da noite**.

## Próximo passo

Conectar as ações do protótipo ao Supabase validado.
