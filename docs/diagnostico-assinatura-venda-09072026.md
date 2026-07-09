# Diagnóstico de assinatura da venda — 09/07/2026

## Situação

A V4.3 validou abertura da manhã com sucesso, mas a venda ainda não encaixou na assinatura da função `registrar_venda_mvp`.

Na V4.4, foram testadas 48 combinações incluindo:

```text
p_dia_operacional_id
p_data_operacional
p_revenda_codigo
p_canal
p_canal_venda
p_produto
p_produto_codigo
p_quantidade
p_quantidade_casco
p_venda
p_movimento
p_itens
p_vendas
p_movimentos
```

Todas retornaram erro de schema cache indicando que a assinatura real da função é diferente das tentativas.

## Conclusão

A partir deste ponto, não é eficiente continuar por tentativa e erro.

É necessário descobrir a assinatura real no Supabase.

## Caminho escolhido

Foi gerado um arquivo local de diagnóstico para consultar a documentação REST/OpenAPI do Supabase e listar as funções RPC disponíveis, especialmente as relacionadas a:

```text
venda
movimento
lançamento
abertura
fechamento
correção
estoque
status
```

O resultado desse diagnóstico deve indicar:

```text
1. se a função registrar_venda_mvp está exposta no schema REST;
2. quais parâmetros ela espera;
3. ou se a função correta de venda tem outro nome.
```

## Segurança

O diagnóstico é local e não deve ser gravado no GitHub com chave real.

O GitHub registra apenas a decisão técnica e o motivo do diagnóstico.
