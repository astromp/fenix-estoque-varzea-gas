# Validação de Gravação da Abertura no Supabase — 08/07/2026

## Status

Validação realizada com sucesso.

O frontend local conseguiu gravar a abertura da manhã no Supabase usando a função controlada `registrar_abertura_mvp`.

## Resultado confirmado

Retorno recebido no teste:

```json
{
  "ok": true,
  "mensagem": "Abertura da manhã registrada com sucesso.",
  "itens_registrados": 5,
  "dia_operacional_id": "47df8eba-29cd-4877-9811-19c108ba92b1",
  "conferencia_abertura_id": "23cd02ff-e4bd-4b44-9597-b8c2b615731d"
}
```

Resultado interpretado:

```text
Gravação: OK
Mensagem: Abertura da manhã registrada com sucesso.
Itens registrados: 5
Dia operacional ID: gerado
Conferência ID: gerado
```

## Tabelas envolvidas

A função controlada gravou a abertura nas estruturas relacionadas a:

```text
dias_operacionais
conferencias_abertura
itens_conferencia_abertura
```

## Segurança aplicada

A gravação foi feita por função controlada no Supabase, e não por insert direto liberado ao frontend.

Função usada:

```text
registrar_abertura_mvp
```

A função foi concedida ao papel `anon` por meio de `grant execute`, mantendo a lógica de gravação centralizada no banco.

## Validações da função

A função foi criada com as seguintes proteções:

- exige lista de itens em JSON;
- localiza apenas a revenda ativa `Várzea Gás`;
- impede gravação se o dia operacional já estiver fechado;
- impede sobrescrever abertura real/manual;
- permite repetir teste MVP cancelando apenas abertura anterior do próprio MVP;
- exige exatamente os 5 produtos iniciais: P13, P05, P20, P45 e AGUA.

## Observação técnica

A primeira versão da função tentou usar o tipo `status_dia_operacional`, mas o banco real não tinha esse tipo disponível.

A versão corrigida passou a tratar o status como `text`, aumentando a compatibilidade com a estrutura real do Supabase.

## Próximo passo

Com a abertura gravando no Supabase, o próximo movimento é criar uma função controlada para registrar venda:

```text
registrar_venda_mvp
```

Essa função deverá gravar:

```text
lancamentos
movimentos_estoque
```

E deverá respeitar as travas:

```text
quantidade_liquido > 0
quantidade_casco >= 0
quantidade_casco <= quantidade_liquido
venda_casco só existe junto com venda_liquido
venda exige canal de venda
Portaria é canal de venda
```

## Regra de ouro preservada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
