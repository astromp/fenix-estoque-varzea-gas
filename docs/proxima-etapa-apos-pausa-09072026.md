# Próxima etapa após pausa — 09/07/2026

## Ponto de parada

Encerramos a sessão após validar a V4.7 Homologação.

## Situação atual

A V4.6 ficou congelada como marco aprovado do MVP operacional.

A V4.7 Homologação foi testada e validada, preservando a lógica da V4.6 e acrescentando uma experiência mais limpa para uso real.

## O que já está validado

```text
1. Ciclo principal:
   sem_abertura -> aberto -> vendas -> estoque calculado -> fechamento conferido

2. Ciclo de exceção:
   aberto -> fechamento inconsistente -> correção -> fechamento conferido

3. Homologação V4.7:
   abertura, vendas, vendas do dia local, fechamento conferido e status final fechado
```

## Próximo passo oficial

Criar no Supabase a função oficial:

```text
consultar_vendas_dia_mvp(p_data_operacional date)
```

## Objetivo dessa função

Permitir que a tela `Vendas do dia` busque todas as vendas oficiais gravadas no banco, e não apenas as vendas locais do navegador usado durante a homologação.

## Antes de criar a função

É necessário identificar as tabelas e colunas reais onde estão gravados:

```text
1. dia operacional;
2. lançamentos de venda;
3. canal da venda;
4. produto vendido;
5. quantidade de líquido;
6. quantidade de casco;
7. horário/data do lançamento;
8. relacionamento com movimentos, se necessário.
```

## Consulta auxiliar sugerida

Rodar no SQL Editor do Supabase:

```sql
select
  table_schema,
  table_name,
  column_name,
  data_type
from information_schema.columns
where table_schema = 'public'
  and (
    table_name ilike '%venda%'
    or table_name ilike '%lanc%'
    or table_name ilike '%lanç%'
    or table_name ilike '%mov%'
    or table_name ilike '%dia%'
    or table_name ilike '%estoque%'
  )
order by table_name, ordinal_position;
```

## Depois disso

Com o resultado das tabelas e colunas, criar a função:

```text
consultar_vendas_dia_mvp(p_data_operacional date)
```

E atualizar a V4.7 para buscar as vendas oficiais do Supabase.

## Regra de ouro preservada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
