# Projeto Fênix Estoque — Várzea Gás

Repositório criado para arquivar a memória técnica, as regras operacionais e a lógica de cálculo do controle de estoque da Várzea Gás.

Este material serve como ponto de recuperação rápida caso alguma informação se perca durante o desenvolvimento.

## Objetivo

Criar um controle simples, confiável e conferível para o estoque de botijões e água, com foco em:

- fechamento correto do estoque por turno/dia;
- rastreabilidade dos lançamentos;
- identificação de inconsistências;
- padronização da lógica para futuras revendas do Projeto Fênix Estoque.

## Unidade inicial

- Revenda: Várzea Gás
- Projeto: Fênix Estoque
- Versão documental inicial: 1.0
- Data de registro: 2026-07-07

## Documentos principais

- `docs/regras-operacionais.md` — regras combinadas para a Várzea Gás.
- `docs/formula-estoque.md` — fórmula e lógica de movimentação do estoque.
- `docs/canais-de-venda.md` — canais/personagens de venda.
- `docs/modelo-lancamento.md` — campos, regras e exemplos práticos de lançamento.
- `docs/integracao-ahgas-gasdelivery.md` — memória da integração AHGas/GasDelivery, API, endpoints e pendências técnicas.
- `docs/recuperacao-rapida.md` — resumo curto para recuperar o raciocínio do projeto.

## Princípio central

O estoque deve bater. Se houver inconsistência, o sistema deve orientar o colaborador a revisar o lançamento e corrigir o erro antes de encerrar o turno/dia.

## Regra operacional resumida

```text
Entrada: cheio sobe, vazio desce.
Venda do líquido: cheio desce, vazio sobe.
Venda de casco: só existe junto com venda do líquido e reduz o total de cascos.
Portaria é canal de venda.
```

## Integração futura

O projeto também mantém memória técnica sobre a possível integração com AHGas/GasDelivery para atendimento automático, consulta de cliente e criação de pedidos via WhatsApp/Bolt.
