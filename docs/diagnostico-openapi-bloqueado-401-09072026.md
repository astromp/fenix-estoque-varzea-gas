# Diagnóstico OpenAPI bloqueado — 09/07/2026

## Resultado do diagnóstico local

Foi gerado um arquivo local para consultar a documentação REST/OpenAPI do Supabase e listar as funções RPC expostas.

O retorno foi:

```text
HTTP status: 401
Total de funções RPC encontradas: 0
Funções contendo venda: []
```

## Interpretação

O endpoint de documentação REST/OpenAPI do Supabase não liberou a listagem de funções para a chave anon usada no teste.

Isso não significa que a aplicação não esteja conectando.

A conexão já foi confirmada por chamadas RPC bem-sucedidas:

```text
consultar_status_dia_mvp
registrar_abertura_mvp
```

## Próximo caminho técnico

Para descobrir a assinatura real da função de venda, é necessário consultar o catálogo do banco pelo SQL Editor do Supabase.

Consulta recomendada:

```sql
select
  n.nspname as schema,
  p.proname as function_name,
  pg_get_function_arguments(p.oid) as arguments,
  pg_get_function_result(p.oid) as returns
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and (
    p.proname ilike '%venda%'
    or p.proname ilike '%mov%'
    or p.proname ilike '%lanc%'
    or p.proname ilike '%estoque%'
    or p.proname ilike '%abertura%'
    or p.proname ilike '%fech%'
    or p.proname ilike '%corr%'
    or p.proname ilike '%status%'
  )
order by p.proname;
```

## Objetivo

Encontrar a assinatura real de:

```text
registrar_venda_mvp
```

ou identificar se a função correta de venda está com outro nome.
