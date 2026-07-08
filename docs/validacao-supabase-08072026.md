# Validação Supabase — Projeto Fênix Estoque / Várzea Gás — 08/07/2026

## Status

Validação realizada com sucesso.

O banco do Supabase já possui estrutura criada e dados de simulação operacional gravados.

Conclusão principal:

```text
Supabase validado. Banco do Projeto Fênix Estoque funcionando com simulação operacional salva.
```

## Projeto Supabase

Projeto tratado:

```text
estoque de fênix
```

URL pública do projeto:

```text
https://pxlapmdypnmvymgbpzhi.supabase.co
```

Observação de segurança:

```text
A URL pública pode ficar documentada. Chaves secretas, service_role key, senha do banco e arquivo .env real não devem ser publicados no GitHub.
```

## Alerta sobre tradução automática

Durante a conferência, o Chrome/Supabase aparentou traduzir visualmente alguns nomes de tabelas, exibindo acentos em nomes que no banco devem ser usados sem acento.

Regra prática:

```text
Nas consultas SQL, usar nomes sem acento.
```

Exemplos corretos:

```text
conferencias_abertura
correcoes
divergencias_fechamento
usuarios
```

## Contagem de registros confirmada

Resultado da consulta de contagem:

| Tabela | Registros |
|---|---:|
| revendas | 1 |
| produtos | 6 |
| canais_venda | 5 |
| usuarios | 2 |
| dias_operacionais | 1 |
| conferencias_abertura | 1 |
| itens_conferencia_abertura | 5 |
| lancamentos | 6 |
| movimentos_estoque | 16 |
| fechamentos | 1 |
| itens_fechamento | 5 |
| divergencias_fechamento | 0 |
| correcoes | 0 |

Interpretação:

- A estrutura do banco existe.
- A revenda inicial foi cadastrada.
- Produtos e canais de venda foram cadastrados.
- Existe 1 dia operacional de teste.
- Existe abertura de estoque.
- Existem lançamentos e movimentos de estoque.
- Existe fechamento final.
- Não há divergência pendente.
- Não há correção pendente registrada nas tabelas finais.

## Fechamento final confirmado

Resultado da consulta de itens de fechamento:

| Produto | Cheios calculados | Vazios calculados | Total calculado | Cheios físicos | Vazios físicos | Total físico | Diferença cheios | Diferença vazios | Diferença total | Status |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| AGUA | 50 | 10 | 60 | 50 | 10 | 60 | 0 | 0 | 0 | conferido |
| P05 | 9 | 6 | 15 | 9 | 6 | 15 | 0 | 0 | 0 | conferido |
| P13 | 50 | 79 | 129 | 50 | 79 | 129 | 0 | 0 | 0 | conferido |
| P20 | 8 | 4 | 12 | 8 | 4 | 12 | 0 | 0 | 0 | conferido |
| P45 | 6 | 13 | 19 | 6 | 13 | 19 | 0 | 0 | 0 | corrigido |

## Conclusão operacional

Todos os produtos fecharam com diferença zero:

```text
diferenca_cheios = 0
diferenca_vazios = 0
diferenca_total = 0
```

O produto P45 ficou com status `corrigido`, indicando que a simulação preservou o cenário de ajuste validado anteriormente.

## Regra validada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```

## Próximo passo recomendado

Com o Supabase validado, o próximo passo é construir o fluxo operacional de uso diário:

1. Abertura do estoque pelo celular.
2. Lançamento de vendas por canal.
3. Lançamento de entrada de carga.
4. Fechamento físico.
5. Diagnóstico automático de divergências.
6. Correção obrigatória antes de encerrar o dia.

## Observação final

A migration criada em `supabase/migrations/20260708143000_estrutura_inicial_estoque_varzea.sql` deve ser tratada como arquivo de referência/recuperação.

Como o banco atual do Supabase já possui tabelas e dados válidos, não é necessário rodar novamente a migration inteira sem antes comparar cuidadosamente com a estrutura existente.
