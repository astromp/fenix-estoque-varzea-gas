# Marco aprovado V4.6 e início da Homologação V4.7 — 09/07/2026

## Marco congelado

A V4.6 fica congelada como marco aprovado do MVP operacional.

Foram validados:

```text
1. Ciclo principal:
   sem_abertura -> aberto -> vendas -> estoque calculado -> fechamento conferido

2. Ciclo de exceção:
   aberto -> fechamento inconsistente -> correção -> fechamento conferido
```

## Regra de ouro confirmada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```

## Início da V4.7 Homologação

A V4.7 inicia a fase de homologação para uso real, sem alterar a lógica de estoque já validada.

## Ajustes da V4.7

```text
1. linguagem mais limpa para colaborador;
2. botões menos técnicos;
3. identificação de versão: V4.7 Homologação;
4. suporte técnico mantido, mas mais discreto;
5. nova tela Vendas do dia;
6. lista local das vendas registradas na própria tela durante a homologação;
7. arquivo SQL auxiliar para descobrir tabelas/colunas necessárias à consulta oficial de vendas do dia.
```

## Observação sobre Vendas do dia

Nesta V4.7, a tela `Vendas do dia` lista as vendas registradas localmente no navegador durante a homologação.

As vendas oficiais continuam sendo gravadas no Supabase pela função:

```text
registrar_venda_mvp
```

Para consultar todas as vendas oficiais diretamente do banco, a próxima etapa será criar uma função RPC no Supabase:

```text
consultar_vendas_dia_mvp(p_data_operacional date)
```

Antes disso, é necessário identificar as tabelas e colunas reais de lançamentos/movimentos.

## Segurança

Nenhuma chave real do Supabase deve ser gravada no GitHub público.

O repositório continua guardando apenas memória técnica, decisões e arquivos sem segredos.
