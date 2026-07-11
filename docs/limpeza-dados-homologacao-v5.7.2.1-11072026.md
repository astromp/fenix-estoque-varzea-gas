# Projeto Fênix Estoque — Limpeza dos dados de homologação V5.7.2.1

**Data:** 11/07/2026  
**Status:** limpeza concluída com sucesso

## Autorização

Marco autorizou expressamente a remoção dos dias fictícios da Várzea Gás:

```text
11/07/2099
12/07/2099
```

## Diagnóstico anterior à limpeza

Registros confirmados:

```text
conferencias_abertura = 2
dias_operacionais = 2
fechamentos = 1
itens_conferencia_abertura = 10
itens_fechamento = 5
lancamentos = 2
movimentos_estoque = 4
```

Lançamentos e movimentos auditados:

```text
11/07/2099: 1 entrada_carga P13 de 5 unidades
12/07/2099: 1 entrada_carga P13 de 5 unidades
cada lançamento com 1 entrada_cheia e 1 saida_vazio vinculada
```

Também foram conferidas as chaves estrangeiras e dependências antes da exclusão.

## Execução

Foi executado o script transacional:

```text
sql/v5.7.2.1-limpeza-dias-ficticios-11072026.sql
```

O script possuía:

- escopo restrito à Várzea Gás;
- datas fixas `2099-07-11` e `2099-07-12`;
- validação das contagens homologadas;
- bloqueio diante de divergências ou correções inesperadas;
- exclusão dos movimentos e lançamentos na ordem segura;
- exclusão dos dias e dependências por cascata;
- verificação interna antes do `COMMIT`.

## Resultado informado pelo Supabase

```text
resultado = LIMPEZA CONCLUÍDA
dias_ficticios_restantes = 0
```

## Conclusão

A limpeza foi concluída integralmente. Não restaram dias fictícios de `11/07/2099` ou `12/07/2099` para a Várzea Gás.

A homologação funcional da interface V5.7.2.1 permanece válida e o banco está preparado para a etapa de publicação definitiva.

## Próxima etapa

1. promover ou integrar a interface V5.7.2.1 à aplicação definitiva;
2. publicar em HTTPS;
3. confirmar o login e a operação do Alex no endereço definitivo;
4. registrar a homologação publicada;
5. definir o momento exato do estoque inicial oficial.

**O estoque inicial oficial continua bloqueado até a publicação definitiva e a definição do início do piloto.**