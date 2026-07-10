# Projeto Fênix Estoque — Homologação V4.9

## Situação

A V4.9 foi homologada em 10/07/2026 como novo marco aprovado do Projeto Fênix Estoque para a Várzea Gás.

A V4.8 permanece preservada no histórico como marco anterior aprovado.

## Escopo homologado

A V4.9 acrescenta o painel gerencial baseado nas vendas oficiais retornadas pela função Supabase:

```sql
consultar_vendas_dia_mvp(p_data_operacional date)
```

O painel permite:

- consulta do dia selecionado;
- consulta dos últimos 7 dias;
- consulta por período personalizado;
- total de lançamentos;
- total de produtos vendidos;
- total de cascos vendidos;
- identificação de linhas de correção;
- resumo por canal de venda;
- resumo por produto;
- exclusão de registros cancelados conforme a consulta oficial do banco.

## Testes aprovados

### 1. Dia selecionado

Data testada: 07/07/2026.

Resultado validado:

- 5 lançamentos;
- 57 produtos vendidos;
- 2 cascos vendidos;
- 1 linha de correção.

Resumo por canal validado:

- Rogério: 22 vendidos e 0 cascos;
- Portaria: 15 vendidos e 1 casco;
- André: 10 vendidos e 0 cascos;
- João: 10 vendidos e 1 casco.

Resumo por produto validado:

- P13: 50 vendidos e 1 casco;
- P45: 4 vendidos e 1 casco;
- P20: 2 vendidos e 0 cascos;
- P05: 1 vendido e 0 cascos.

### 2. Últimos 7 dias

Período exibido no teste: 01/07/2026 a 07/07/2026.

Resultado:

- consolidação sem duplicação visível;
- 5 lançamentos;
- 57 produtos vendidos;
- 2 cascos vendidos;
- 1 linha de correção;
- totais por canal e produto fechando com o total geral.

### 3. Período personalizado

Período testado: 05/07/2026 a 07/07/2026.

Resultado:

- título do período correto;
- 5 lançamentos;
- 57 produtos vendidos;
- 2 cascos vendidos;
- 1 linha de correção;
- totais por canal fechando em 57;
- totais por produto fechando em 57;
- cascos separados corretamente;
- nenhuma duplicação ou erro visível.

## Arquivo principal da V4.9

```text
js/painel-gerencial-v4.9.js
```

## Decisão de congelamento

A V4.9 está aprovada e congelada como novo marco funcional.

Novas evoluções devem ser desenvolvidas em versão posterior, sem alterar o comportamento homologado desta versão.

## Próxima etapa sugerida

Evoluir o relatório gerencial com filtros adicionais e saída compartilhável, mantendo como base os totais homologados da V4.9.

Possíveis itens:

- filtro por canal;
- filtro por produto;
- detalhamento diário dentro do período;
- exportação ou impressão do relatório;
- comparação entre períodos;
- preparação do modelo para outras revendas.

## Regra de ouro

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
Versão homologada, preservar antes de evoluir.
```
