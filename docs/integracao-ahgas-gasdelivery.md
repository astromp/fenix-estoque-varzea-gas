# Integração AHGas / GasDelivery — Projeto Fênix

Este documento registra o que já foi tratado sobre a possível integração entre o Projeto Fênix, o atendimento automático por WhatsApp/Bolt e o ambiente AHGas/GasDelivery.

## 1. Objetivo da integração

Criar uma automação de atendimento e pedido que consiga operar com informações do sistema usado pela empresa, reduzindo dependência de atendimento manual.

Objetivo desejado:

```text
Cliente chama no WhatsApp
IA/Bolt identifica o telefone
Sistema consulta cadastro/endereço/histórico
Cliente confirma produto e forma de pagamento
Pedido é criado automaticamente
Equipe recebe o pedido para entrega
```

## 2. Sistema envolvido

Sistema/ambiente mencionado:

- AHGas;
- GasDelivery;
- Portal GasDelivery: `https://portal.gasdelivery.com.br/login`;
- documentação recebida: `API_-_Developers_documentation_1.0.5.pdf`;
- título da documentação: `Front API - gasdelivery v1.0.5`.

## 3. URL base tratada

URL base identificada/tratada na conversa:

```text
https://livefrontapp-api.gasdelivery.com.br
```

Essa URL deve ser confirmada tecnicamente com o suporte AHGas/GasDelivery antes de qualquer integração em produção.

## 4. GD Group Hash da revenda

Hash informado para a revenda:

```text
c5ef82ce2918a2cf2229ee62d3abfdbf
```

Header tratado:

```text
gd-group-hash: c5ef82ce2918a2cf2229ee62d3abfdbf
```

Observação: a documentação de exemplo pode trazer outro hash demonstrativo. O hash acima foi o informado pelo usuário para a revenda e deve ser tratado como referência do projeto até validação técnica.

## 5. Endpoints já identificados na documentação

Endpoints citados/tratados:

```text
GET /product
```

Finalidade esperada:

- listar produtos disponíveis, como P-13, P-20, P-45 e Assistência Técnica.

```text
GET /partner/{zip_code}/product/{product_name}
```

Finalidade esperada:

- buscar parceiro/revenda por CEP e produto.

```text
POST /partner/order
```

Finalidade esperada:

- criar pedido no ambiente GasDelivery/AHGas.

Também foram citados endpoints relacionados a parceiro, avaliação e meios de pagamento, como:

```text
GET /partner/{hashid}/review
POST /partner/{hashid}/review
GET /partner/{hashid}/means-of-payment
```

## 6. Pontos que ainda precisam de confirmação técnica

A documentação recebida indica caminhos para produtos, parceiros e criação de pedido, mas ainda precisamos confirmar com o técnico AHGas/GasDelivery se a API permite:

- consultar cliente pelo telefone;
- retornar cadastro completo do cliente;
- retornar endereço do cliente;
- retornar histórico de compras;
- consultar pedidos em andamento;
- alterar ou cancelar pedido;
- consultar estoque disponível;
- consultar preços por cidade/revenda;
- atualizar cadastro do cliente;
- ambiente de homologação/sandbox;
- limites de uso, autenticação e segurança;
- recomendação oficial para integrar IA/WhatsApp ao AHGas/GasDelivery.

## 7. Mensagem/assunto tratado com o suporte técnico

O contato com o suporte técnico deveria explicar que já temos a documentação `Front API - gasdelivery v1.0.5`, mas que precisamos confirmar se ela atende ao projeto de atendimento automático por WhatsApp.

Pontos principais a solicitar ao técnico:

```text
1. Essa API permite criar pedidos automaticamente?
2. Existe endpoint para consultar cliente pelo telefone?
3. Existe endpoint para buscar cadastro, endereço e histórico do cliente?
4. É possível consultar preços e produtos por cidade/revenda?
5. É possível consultar estoque ou disponibilidade?
6. É possível alterar/cancelar pedidos?
7. Existe ambiente de homologação/sandbox?
8. Qual é a forma correta de autenticação?
9. A AHGas/GasDelivery recomenda algum fluxo oficial para integrar IA/WhatsApp?
```

## 8. Relação com o Projeto Fênix

A integração AHGas/GasDelivery não é a mesma coisa que o controle de estoque da Várzea Gás, mas faz parte do ecossistema maior do Projeto Fênix.

Divisão conceitual:

```text
Fênix Estoque:
controle interno de cheio, vazio/casco, venda do líquido, venda de casco e fechamento.

Fênix Atendimento/Bolt:
atendimento automático por WhatsApp, consulta de cliente e criação de pedido.

Integração AHGas/GasDelivery:
ponte técnica para consultar dados e registrar pedidos no sistema existente.
```

## 9. Decisão operacional importante

Como a AHGas ainda não foi confirmada como fornecedora direta de um Bolt de WhatsApp, o projeto deve manter dois caminhos possíveis:

```text
Caminho A: integração oficial via API AHGas/GasDelivery, se houver suporte técnico suficiente.

Caminho B: base própria intermediária do Projeto Fênix, caso a API não permita consultar clientes, histórico ou estoque da forma necessária.
```

## 10. Próximo passo

Aguardar ou provocar resposta técnica da AHGas/GasDelivery sobre os pontos pendentes.

Depois da resposta, decidir:

- se seguimos com integração direta;
- se montamos uma base intermediária;
- se usamos exportação CSV/Excel de clientes como solução provisória;
- se o pedido será apenas encaminhado ou registrado automaticamente no sistema.
