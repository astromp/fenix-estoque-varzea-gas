# Projeto Fênix Estoque — Várzea Gás

Repositório criado para arquivar a memória técnica, as regras operacionais, a lógica de cálculo e a estrutura publicável do controle de estoque da Várzea Gás.

Este material serve como ponto de recuperação rápida caso alguma informação se perca durante o desenvolvimento.

## Objetivo

Criar um controle simples, confiável e conferível para o estoque de botijões e água, com foco em:

- fechamento correto do estoque por turno/dia;
- rastreabilidade dos lançamentos;
- identificação de inconsistências;
- relatórios de vendas por canal/personagem;
- padronização da lógica para futuras revendas do Projeto Fênix Estoque.

## Unidade inicial

- Revenda: Várzea Gás
- Projeto: Fênix Estoque
- Versão documental inicial: 1.0
- Estrutura publicável consolidada: Operação Celular Integrada V3
- Data de registro: 2026-07-07
- Data de consolidação V3: 2026-07-09

## Estrutura publicável V3

```text
index.html
css/style.css
js/app.js
js/config.js
js/config.example.js
.gitignore
LEIA-ME.txt
```

O arquivo `js/config.js` fica no GitHub apenas com placeholder. Para teste local, substituir:

```text
SUPABASE_URL: "COLE_AQUI_A_URL_DO_SUPABASE"
SUPABASE_ANON_KEY: "COLE_AQUI_A_ANON_PUBLIC_KEY"
```

Nunca subir chave real, `service_role`, senha do banco, `DATABASE_URL` ou connection string.

## Documentos principais

- `docs/regras-operacionais.md` — regras combinadas para a Várzea Gás.
- `docs/formula-estoque.md` — fórmula e lógica de movimentação do estoque.
- `docs/canais-de-venda.md` — canais/personagens de venda.
- `docs/modelo-lancamento.md` — campos, regras e exemplos práticos de lançamento.
- `docs/modelo-fechamento.md` — regras de conferência física e fechamento do estoque.
- `docs/fluxo-celular-fechamento.md` — fluxo de tela para fechamento pelo celular.
- `docs/simulacao-operacao-fechamento.md` — exemplo prático de operação, fechamento e diagnóstico de divergência.
- `docs/modelo-dados-estoque.md` — estrutura inicial de tabelas e regras do banco de dados do estoque.
- `docs/relatorios-vendas.md` — armazenamento operacional e relatórios de vendas por canal de venda.
- `docs/modelo-telas-operacao-diaria.md` — desenho das telas para abertura, lançamentos, correções, fechamento e relatórios.
- `docs/integracao-ahgas-gasdelivery.md` — memória da integração AHGas/GasDelivery, API, endpoints e decisão técnica.
- `docs/arquitetura-banco-proprio.md` — decisão estratégica de construir banco próprio do Projeto Fênix.
- `docs/recuperacao-rapida.md` — resumo curto para recuperar o raciocínio do projeto.
- `docs/estrutura-publicavel-v3-08072026.md` — registro da estrutura publicável V3.
- `docs/ponto-de-retomada-09072026.md` — ponto exato de retomada do projeto.
- `docs/consolidacao-estrutura-publicavel-v3-09072026.md` — registro da consolidação feita no GitHub.

## Princípio central

O estoque deve bater. Se houver inconsistência, o sistema deve orientar o colaborador a revisar o lançamento e corrigir o erro antes de encerrar o turno/dia.

## Regra operacional resumida

```text
Entrada: cheio sobe, vazio desce.
Venda por troca: cheio desce, vazio sobe.
Venda sem troca/casco: cheio desce e reduz o total de cascos em posse da revenda.
Portaria é canal de venda.
Toda venda precisa registrar canal de venda para permitir relatórios confiáveis.
```

## Armazenamento e relatórios

```text
O GitHub guarda o projeto.
O banco de dados guarda a operação real.
```

As vendas lançadas no sistema deverão alimentar relatórios diários, semanais, mensais e por período personalizado, sempre com filtro por revenda, produto e canal/personagem de venda.

## Integração futura

O projeto também mantém memória técnica sobre a possível integração com AHGas/GasDelivery para atendimento automático e criação de pedidos via WhatsApp/Bolt.

## Estratégia de independência

```text
O AHGas recebe o pedido.
O Projeto Fênix constrói a inteligência.
```

Aos poucos, o Projeto Fênix deve construir seu próprio banco de dados e evoluir para um sistema próprio mais completo.

## Regra de ouro

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
