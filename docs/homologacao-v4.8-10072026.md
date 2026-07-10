# Homologação V4.8 — 10/07/2026

## Situação

A V4.8 do Projeto Fênix Estoque foi homologada com sucesso na Várzea Gás.

## Escopo validado

A tela `Vendas do dia` passou a consultar diretamente o Supabase por meio da função:

```text
consultar_vendas_dia_mvp(p_data_operacional date)
```

A consulta foi validada com a data operacional de 07/07/2026.

## Resultado da homologação

Foram exibidos corretamente:

```text
5 lançamentos
57 produtos vendidos
2 cascos vendidos
```

Também foram confirmados:

```text
- canais Portaria, Rogério, André e João;
- agrupamento por lançamento e produto;
- quantidade de líquido;
- quantidade de casco;
- identificação separada de correção;
- exclusão de lançamentos e movimentos cancelados;
- leitura pela data operacional;
- conversão dos horários para São Paulo;
- consulta funcionando também para dia fechado.
```

## Ajuste de permissão necessário

Para permitir a leitura da função pelo navegador com a chave pública `anon`, a função foi ajustada no Supabase:

```sql
alter function public.consultar_vendas_dia_mvp(date)
security definer;

alter function public.consultar_vendas_dia_mvp(date)
set search_path = public, pg_temp;

grant execute
on function public.consultar_vendas_dia_mvp(date)
to anon, authenticated;
```

Esse ajuste não altera nem apaga vendas. Ele apenas permite a execução da função específica pela aplicação.

## Marco aprovado

A V4.8 passa a ser o novo marco aprovado para a consulta oficial de vendas do dia.

A V4.7 permanece preservada como marco anterior de homologação do fluxo operacional.

## Próximo passo sugerido

Evoluir para a próxima versão sem alterar a V4.8 aprovada, priorizando:

```text
1. resumo por canal de venda;
2. resumo por produto;
3. total de líquido e casco por período;
4. filtros diário, semanal, mensal e personalizado;
5. preparação do relatório gerencial da revenda.
```

## Regra de ouro

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
