# Operação Celular Integrada V3 — Status do Dia Operacional

## Status

Versão gerada para teste local.

A Operação Celular Integrada V3 adiciona uma camada de controle visual para o status do dia operacional.

## Função Supabase criada

Foi criada a função:

```text
consultar_status_dia_mvp
```

Essa função consulta o estado atual do dia operacional da Várzea Gás e retorna informações para a interface decidir o que pode ou não ser feito.

## Status possíveis

A tela passa a exibir no topo:

```text
sem abertura
aberto
inconsistente
fechado
```

## Regras visuais da V3

A interface bloqueia visualmente ações que não fazem sentido para cada status:

```text
sem abertura -> permite abertura
aberto -> permite venda, consulta de estoque e fechamento
inconsistente -> permite fechamento e correção
fechado -> bloqueia nova operação
```

## Informações exibidas

O painel de status mostra:

```text
Status do dia
Quantidade de lançamentos
Quantidade de movimentos
Quantidade de itens inconsistentes
Mensagem operacional
```

## Objetivo operacional

Evitar que o colaborador tente:

- lançar venda antes da abertura;
- lançar venda depois do dia fechado;
- corrigir quando não existe inconsistência;
- fechar novamente um dia já encerrado;
- operar em data errada sem perceber.

## Segurança

A tela V3 de teste local contém a chave pública `anon` embutida para facilitar teste no navegador.

Ela não deve ser enviada para repositório público com a chave dentro.

Para produção, a chave deve ser tratada em ambiente de build/configuração adequada.

## Próximo passo recomendado

Testar a V3 em celular com três cenários:

1. data sem abertura;
2. data aberta;
3. data fechada.

Depois disso, o próximo passo técnico é separar o frontend em arquivos de projeto e preparar uma versão sem credenciais embutidas para deploy controlado.

## Regra de ouro preservada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
