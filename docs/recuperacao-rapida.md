# Recuperação Rápida — Projeto Fênix Estoque / Várzea Gás

Este arquivo existe para recuperar rapidamente o raciocínio do projeto caso a memória se perca.

## Resumo do projeto

O Projeto Fênix Estoque é um controle de estoque para revendas de gás e água, começando pela Várzea Gás.

A lógica deve ser simples, padronizada e conferível pelo celular ou outro sistema operacional escolhido futuramente.

## Regra central das entradas

Entrada é chegada de produto cheio.

A mesma quantidade de cheio que entra deve sair de vazio/casco.

```text
entrada_cheia:
cheio += quantidade
vazio -= quantidade
```

## Regra central da venda do líquido

Venda do líquido é a venda normal em que o cliente recebe o produto cheio e devolve o casco vazio.

```text
venda_do_liquido:
cheio -= quantidade
vazio += quantidade
```

Consequência:

```text
total_cascos não muda
```

## Regra da venda de casco

A operação não deve ser chamada de venda sem troca.

O nome correto é venda de casco.

Venda de casco só pode existir se vender o líquido junto.

Ou seja: não existe venda de casco isolada.

Quando há venda de casco, a operação completa é:

```text
venda_do_liquido:
cheio -= quantidade
vazio += quantidade

venda_de_casco:
vazio -= quantidade
```

Resultado final:

```text
cheio -= quantidade
vazio não muda
total_cascos -= quantidade
```

A venda de casco deve ser lançada separadamente da venda apenas do líquido, porque ela muda o total de cascos da revenda.

## Regra de total de cascos

```text
total_cascos = cheio + vazio
```

Nas entradas e vendas apenas do líquido, o total de cascos permanece estável.

Na venda de casco, o total de cascos diminui na quantidade de cascos vendidos junto com o produto cheio.

## Canais/personagens da Várzea Gás

- André;
- João;
- Rogério;
- Portaria.

Portaria é canal de venda, igual aos demais.

Não interpretar Portaria como portão físico, retirada, conferência ou etapa intermediária.

## Decisão estratégica do Projeto Fênix

Além do controle de estoque, ficou definido que o Projeto Fênix construirá seu próprio banco de dados.

Regra de ouro:

```text
O AHGas recebe o pedido.
O Projeto Fênix constrói a inteligência.
```

O banco próprio deve permitir, aos poucos:

- reconhecer clientes;
- guardar telefones e endereços;
- registrar preferências;
- manter histórico próprio;
- enviar ao AHGas apenas o pedido final lançado.

## Fechamento

O sistema deve cobrar a conferência física no encerramento.

Se o estoque calculado não bater com o estoque físico, o sistema deve apontar inconsistência e orientar a revisão.

## Lema operacional

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```

## Próximos passos sugeridos

1. Desenhar o fechamento de estoque.
2. Definir perguntas de conferência física por produto.
3. Definir como o sistema aponta divergências.
4. Criar protótipo simples.
5. Testar com movimentações reais da Várzea Gás.
6. Só depois replicar para outra revenda.
