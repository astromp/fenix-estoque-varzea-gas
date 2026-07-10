# Homologação V5.2 — Gestão de canais por revenda

Data: 10/07/2026

## Objetivo

Validar a primeira etapa multirrevenda do Projeto Fênix Estoque, com gestão segura de canais de venda vinculados à respectiva `revenda_id`.

## Estrutura confirmada

Revenda cadastrada:

```text
Várzea Gás
revenda_id: 407b3516-e4ce-47bc-a048-3e9c8294245d
cidade: Várzea Paulista/SP
ativa: true
```

Canais encontrados:

```text
André — ativo
João — ativo
Portaria — ativo
Rogério — ativo
Outros — inativo
```

## Funções implantadas no Supabase

```text
listar_revendas_ativas
listar_canais_revenda
cadastrar_canal_revenda
renomear_canal_revenda
definir_status_canal_revenda
excluir_canal_sem_historico
```

## Regras homologadas

- cada canal pertence a uma única revenda;
- canais são carregados pela `revenda_id`;
- canal ativo aparece para novos lançamentos;
- canal inativo permanece no histórico;
- canal com histórico não pode ser excluído;
- canal sem histórico pode ser excluído;
- cadastro, edição, ativação, desativação e exclusão exigem usuário autenticado;
- a V5.1 permanece preservada.

## Testes realizados

### Cadastro

Foi criado um canal temporário:

```text
TESTE V5.2
```

Resultado: aprovado.

### Renomeação

O canal foi renomeado para:

```text
TESTE V5.2 RENOMEADO
```

Resultado: aprovado.

### Desativação e ativação

O canal temporário foi desativado e depois reativado.

Resultado: aprovado.

### Exclusão sem histórico

O canal temporário, ainda sem lançamentos ou movimentos, foi excluído.

Resultado: aprovado.

### Proteção do histórico

Foi tentada a exclusão do canal Portaria, que possui histórico.

Mensagem exibida:

```text
Este canal possui histórico e não pode ser excluído. Desative-o.
```

Resultado: aprovado.

## Conclusão

A V5.2 foi homologada como marco oficial da gestão de canais por revenda.

O sistema agora permite cadastrar, renomear, ativar, desativar e excluir canais sem histórico, preservando integralmente os vínculos de vendas e movimentos antigos.

## Regra permanente

```text
Canal com histórico nunca é apagado.
Canal com histórico pode apenas ser desativado.
Cada revenda possui seus próprios canais.
```
