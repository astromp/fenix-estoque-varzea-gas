# Arquitetura com Banco Próprio — Projeto Fênix

Este documento registra a decisão estratégica de construir uma base própria do Projeto Fênix, usando o AHGas/GasDelivery apenas como destino final do pedido lançado.

## 1. Decisão estratégica

Após a resposta da AHGas, ficou definido:

```text
Construiremos nosso próprio banco de dados.
O Projeto Fênix/Bolt usará esse banco para reconhecer clientes, endereços, preferências e histórico.
O AHGas/GasDelivery receberá apenas o pedido final lançado para dar continuidade operacional.
Aos poucos, o Projeto Fênix poderá evoluir para um sistema próprio mais completo.
```

## 2. Motivo da decisão

A AHGas informou que a API pública disponível não permite consulta de clientes, histórico, pedidos em andamento, estoque, preços, atualização cadastral, cancelamento ou alteração de pedidos.

A única integração confirmada é:

```text
POST /partner/order
```

Portanto, o AHGas deve ser tratado como destino de criação de pedidos, não como fonte de consulta para o Bolt.

## 3. Papel de cada sistema

## Projeto Fênix / Banco próprio

Responsável por:

- armazenar clientes;
- armazenar telefones;
- armazenar endereços;
- armazenar preferências;
- registrar histórico próprio de atendimento/pedidos;
- apoiar o Bolt no WhatsApp;
- facilitar reconhecimento do cliente antes de enviar o pedido;
- preparar o pedido completo para envio ao AHGas;
- permitir evolução gradual para sistema próprio.

## AHGas / GasDelivery

Responsável por:

- receber o pedido final via API;
- reconhecer internamente se o cliente já existe;
- vincular o pedido ao cadastro existente;
- cadastrar cliente novo, se necessário;
- dar continuidade operacional ao pedido no ambiente AHGas/GasDelivery.

## 4. Fluxo operacional desejado

```text
Cliente chama no WhatsApp
Bolt consulta o banco próprio do Projeto Fênix
Se encontrar cliente, confirma dados principais
Se não encontrar cliente, coleta dados completos
Bolt monta o pedido
Bolt envia o pedido final ao AHGas via POST /partner/order
AHGas vincula ou cadastra o cliente internamente
Equipe acompanha e executa o pedido
```

## 5. Dados iniciais do banco próprio

A primeira base própria deve começar simples.

Campos mínimos de cliente:

- id interno;
- nome;
- telefone principal;
- telefones adicionais, se houver;
- endereço principal;
- número;
- complemento;
- bairro;
- cidade;
- CEP, se disponível;
- observações de entrega;
- data de criação;
- data da última atualização.

Campos úteis para atendimento:

- produto mais comprado;
- última compra;
- forma de pagamento mais usada;
- preferências de entrega;
- restrições/observações do cliente.

## 6. Relação com o cadastro exportado do AHGas

O usuário já disponibilizou uma base/cadastro de clientes extraída do AHGas, com aproximadamente 1.999 registros.

Essa base deve servir como ponto de partida para o banco próprio do Projeto Fênix.

Prioridade inicial de limpeza/importação:

```text
telefone
nome
endereço
```

Campos como e-mail, aniversário ou dados complementares podem ficar para fase posterior.

## 7. Estratégia de evolução

Fase 1 — Base simples:

```text
telefone + nome + endereço
```

Fase 2 — Atendimento inteligente:

```text
reconhecimento por telefone
confirmação automática de endereço
preferências de produto e pagamento
```

Fase 3 — Histórico próprio:

```text
pedidos feitos pelo Bolt
última compra
frequência de compra
observações de atendimento
```

Fase 4 — Integração operacional:

```text
enviar pedido ao AHGas
registrar status interno
comparar pedido enviado x pedido executado
```

Fase 5 — Sistema próprio completo:

```text
cadastro
pedido
estoque
fechamento
relatórios
integração ou substituição gradual de dependências externas
```

## 8. Regra de ouro

```text
O AHGas recebe o pedido.
O Projeto Fênix constrói a inteligência.
```

## 9. Próximo passo

O próximo passo é desenhar o modelo inicial do banco de dados do Projeto Fênix, começando pelas tabelas:

- clientes;
- endereços;
- pedidos;
- itens_pedido;
- produtos;
- formas_pagamento;
- revendas.

Depois disso, o projeto deve definir como importar, limpar e padronizar o cadastro exportado do AHGas.
