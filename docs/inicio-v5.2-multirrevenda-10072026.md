# Projeto Fênix Estoque — Início da V5.2 Multi-revenda

Data: 10/07/2026

## Objetivo

Evoluir o sistema para múltiplas revendas sem misturar canais, lançamentos, estoque ou relatórios.

## Regra central

Cada revenda terá seus próprios:

- canais de venda;
- usuários;
- dias operacionais;
- lançamentos;
- movimentos de estoque;
- relatórios.

Os canais da Várzea Gás — Portaria, Rogério, André e João — não devem ser copiados automaticamente para outras unidades.

## Estratégia técnica

A V5.2 será construída com base em `revenda_id`.

Fluxo esperado:

```text
selecionar revenda
→ carregar canais daquela revenda
→ consultar apenas dias/lancamentos/movimentos daquela revenda
→ montar relatórios isolados por unidade
```

## Primeira etapa

Antes de criar novas RPCs ou telas, executar o diagnóstico:

```text
sql/diagnostico-multirrevenda-v5.2.sql
```

O diagnóstico é somente leitura e confirma:

- nome e estrutura da tabela de revendas;
- vínculo dos canais com `revenda_id`;
- chaves estrangeiras existentes;
- funções já disponíveis;
- definição da função `consultar_vendas_dia_mvp`;
- segregação atual dos lançamentos e movimentos por revenda.

## Próximo passo após o diagnóstico

Com o resultado real do banco, criar sem adivinhação:

1. função para listar revendas ativas;
2. função para listar canais ativos da revenda selecionada;
3. consulta de vendas com parâmetro obrigatório de revenda;
4. seletor de revenda na interface;
5. bloqueio de consultas sem revenda definida;
6. testes para provar que não há mistura entre unidades.

## Marco preservado

A V5.1 permanece congelada como versão aprovada. A V5.2 será homologada separadamente.
