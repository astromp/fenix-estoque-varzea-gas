# Validação de Leitura do Supabase pelo Frontend — 08/07/2026

## Status

Validação realizada com sucesso.

O frontend de teste conseguiu conectar ao Supabase usando a chave pública `anon` e ler os cadastros básicos necessários para iniciar o MVP.

## Resultado confirmado

Resultado interpretado no teste:

```text
Conexão: OK
Revenda Várzea Gás: encontrada
Produtos ativos: 5
Canal Portaria: encontrado
```

## Tabelas lidas pelo teste

O teste realizou leitura das seguintes tabelas:

```text
revendas
produtos
canais_venda
```

## Ajuste aplicado no Supabase

Foi necessário habilitar leitura pública controlada para o papel `anon`.

As políticas criadas permitem leitura somente dos cadastros ativos:

```text
revendas ativas
produtos ativos
canais de venda ativos
```

## Observação de segurança

A chave utilizada é a `anon public key`, apropriada para frontend quando combinada com políticas RLS adequadas.

Não foi utilizada nem registrada no GitHub nenhuma chave secreta, service_role key, senha do banco ou string de conexão direta.

## Interpretação operacional

Com a leitura validada, o MVP já consegue:

- confirmar a revenda inicial Várzea Gás;
- buscar produtos ativos;
- buscar canais de venda ativos;
- reconhecer Portaria como canal de venda.

## Próximo passo

A próxima etapa é habilitar gravação controlada, começando pela abertura da manhã.

A ordem recomendada de gravação é:

1. `dias_operacionais`
2. `conferencias_abertura`
3. `itens_conferencia_abertura`

Depois de validar abertura, avançar para:

4. `lancamentos`
5. `movimentos_estoque`
6. `fechamentos`
7. `itens_fechamento`

## Regra de ouro preservada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
