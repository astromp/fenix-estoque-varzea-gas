# Integração AHGas / GasDelivery — Projeto Fênix

Este documento registra o que já foi tratado sobre a possível integração entre o Projeto Fênix, o atendimento automático por WhatsApp/Bolt e o ambiente AHGas/GasDelivery.

## 1. Objetivo da integração

Criar uma automação de atendimento e pedido que consiga operar com informações do sistema usado pela empresa, reduzindo dependência de atendimento manual.

Objetivo desejado inicialmente:

```text
Cliente chama no WhatsApp
IA/Bolt identifica o telefone
Sistema consulta cadastro/endereço/histórico
Cliente confirma produto e forma de pagamento
Pedido é criado automaticamente
Equipe recebe o pedido para entrega
```

Após resposta da AHGas, esse objetivo precisa ser ajustado, porque a API pública disponível não permite consultas diretas de cliente, histórico, estoque ou preços.

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

## 5. Resposta oficial da AHGas

Em 2026-07-07, o usuário encaminhou a resposta recebida da AHGas.

Resumo da resposta:

- a documentação da Front API foi considerada a documentação disponível;
- não há documentação complementar;
- não há outra API disponível além da já encaminhada;
- a única API disponibilizada para integração é a de criação de pedidos;
- o endpoint disponível para esse fim é `POST /partner/order`;
- o reconhecimento de clientes e tratamento dos pedidos é feito pelo próprio AHGas por meio desse endpoint;
- quando o pedido é enviado ao AHGas pela API, o sistema identifica automaticamente se o cliente já possui cadastro;
- se o cliente já existir, o pedido é vinculado ao cadastro correspondente;
- se o cliente não existir, o sistema realiza o cadastro conforme as informações enviadas na requisição.

Trecho conceitual importante da resposta:

```text
Atualmente, a única API disponibilizada para integração é a de criação de pedidos, por meio do método POST /partner/order.
Todo o processo de reconhecimento de clientes e tratamento dos pedidos é realizado através desse endpoint.
```

## 6. Funcionalidades não disponíveis publicamente

A AHGas informou que as seguintes funcionalidades não possuem endpoints públicos disponíveis para integração no momento:

- consulta de clientes;
- histórico de compras;
- pedidos em andamento;
- estoque;
- preços;
- atualização cadastral;
- cancelamento de pedidos;
- alteração de pedidos.

## 7. Endpoint confirmado para integração

Endpoint principal confirmado:

```text
POST /partner/order
```

Finalidade:

- enviar/criar pedido no AHGas/GasDelivery;
- permitir que o AHGas reconheça internamente se o cliente já existe;
- vincular o pedido ao cliente existente, quando houver cadastro;
- cadastrar novo cliente conforme as informações enviadas, quando não houver cadastro.

## 8. Endpoints citados na documentação

Endpoints citados/tratados anteriormente na documentação:

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

Finalidade confirmada:

- criar pedido no ambiente GasDelivery/AHGas.

Também foram citados endpoints relacionados a parceiro, avaliação e meios de pagamento, como:

```text
GET /partner/{hashid}/review
POST /partner/{hashid}/review
GET /partner/{hashid}/means-of-payment
```

## 9. Consequência para o Projeto Fênix Atendimento/Bolt

A arquitetura do Fênix Atendimento/Bolt precisa considerar que o AHGas não funcionará como base consultiva aberta.

Portanto, o Bolt não poderá depender da AHGas para:

- consultar cliente antes do pedido;
- buscar histórico;
- buscar endereço automaticamente antes de enviar pedido;
- consultar estoque;
- consultar preços;
- alterar ou cancelar pedido por API pública.

O fluxo mais viável passa a ser:

```text
Cliente conversa com o Bolt no WhatsApp
Bolt coleta os dados necessários do pedido
Bolt envia o pedido completo para o AHGas via POST /partner/order
AHGas identifica internamente se o cliente já existe
AHGas vincula o pedido ao cadastro existente ou cria novo cadastro
Equipe acompanha o pedido no AHGas/GasDelivery
```

## 10. Dados que o Bolt provavelmente precisará coletar

Como a API não permite consulta prévia de cadastro, o Bolt deve coletar ou confirmar os dados necessários antes de enviar o pedido.

Campos prováveis:

- telefone do cliente;
- nome;
- endereço;
- número;
- complemento;
- bairro;
- cidade;
- CEP, se necessário;
- produto;
- quantidade;
- forma de pagamento;
- observação para entrega.

Observação: os campos exatos devem ser conferidos no corpo esperado pelo endpoint `POST /partner/order` da documentação.

## 11. Relação com o Projeto Fênix Estoque

A integração AHGas/GasDelivery não é a mesma coisa que o controle de estoque da Várzea Gás, mas faz parte do ecossistema maior do Projeto Fênix.

Divisão conceitual:

```text
Fênix Estoque:
controle interno de cheio, vazio/casco, venda do líquido, venda de casco e fechamento.

Fênix Atendimento/Bolt:
atendimento automático por WhatsApp, coleta de dados do cliente e criação de pedido.

Integração AHGas/GasDelivery:
ponte técnica limitada ao envio/criação de pedidos via POST /partner/order.
```

## 12. Decisão técnica atual

A decisão técnica atual é:

```text
Não depender da AHGas para consultas.
Usar a AHGas/GasDelivery como destino de criação de pedidos.
Montar o Bolt para coletar dados suficientes e enviar o pedido completo.
```

## 13. Caminhos possíveis

Com a resposta da AHGas, o projeto deve trabalhar com dois caminhos:

```text
Caminho A: usar apenas POST /partner/order para criar pedidos no AHGas.

Caminho B: criar uma base intermediária do Projeto Fênix para consulta rápida de clientes, histórico, preferências e endereços, usando o AHGas apenas para receber o pedido final.
```

## 14. Próximo passo

Analisar o corpo obrigatório do `POST /partner/order` na documentação para montar:

- modelo de payload;
- campos obrigatórios;
- campos opcionais;
- fluxo do Bolt no WhatsApp;
- validações antes de enviar o pedido;
- tratamento de erro quando o AHGas recusar ou não processar o pedido.
