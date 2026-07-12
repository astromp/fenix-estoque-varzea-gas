# Estoque Inicial da Várzea Gás

**Projeto:** Fênix Estoque  
**Revenda:** Várzea Gás — Várzea Paulista/SP  
**Status:** procedimento aprovado por Marco  
**Data do registro:** 11/07/2026

## Gatilho de retomada

Quando Marco disser **“vamos lançar o estoque inicial”**, o trabalho deverá ser retomado exatamente a partir deste procedimento.

## Objetivo

O estoque inicial será a fotografia física do estoque da Várzea Gás no momento da implantação.

Esse lançamento ocorrerá **uma única vez** e será o ponto de partida para todos os cálculos e movimentações futuras do Projeto Fênix.

## Escopo aprovado nesta etapa

O levantamento inicial será feito, produto por produto, para:

- P13;
- P20;
- P45;
- Água.

Para cada produto, deverão ser informadas separadamente:

- quantidade de cheios;
- quantidade de vazios.

O sistema calculará automaticamente:

```text
Total de cascos ou galões = cheios + vazios
```

## Natureza do lançamento

O estoque inicial **não é uma entrada de carga**.

Ele também não é venda, saída, correção comum ou qualquer outra movimentação operacional.

Sua única finalidade é registrar o que já existe fisicamente na revenda no momento da implantação:

```text
Cheios encontrados no depósito
Vazios encontrados no depósito
Total de cascos ou galões existentes
```

Por isso, o lançamento do estoque inicial não deverá gerar movimentações artificiais de entrada ou saída.

## Canais de venda

Os canais André, João, Rogério e Portaria **não terão estoque inicial separado**.

Eles são canais de venda da Várzea Gás. O estoque inicial representa o estoque físico total da revenda.

## Fluxo aprovado

1. Fazer a contagem física dos cheios e vazios da revenda.
2. Informar as quantidades por produto.
3. Calcular automaticamente o total de cascos ou galões.
4. Exibir um resumo completo para conferência.
5. Perguntar:

> As quantidades informadas correspondem à contagem física da Várzea Gás?

6. Registrar a confirmação com data, horário e responsável.
7. Bloquear o estoque inicial para alterações comuns.
8. Permitir correção posterior somente com perfil administrativo e justificativa.
9. Liberar oficialmente a operação.
10. Abrir o primeiro turno.

## Segurança e responsabilidade

Até a confirmação do estoque inicial, o sistema deverá permanecer em estado de piloto, sem operação oficial liberada.

Depois da confirmação:

- o estoque inicial passa a ser a base oficial do sistema;
- alterações comuns ficam bloqueadas;
- qualquer correção exige perfil administrativo e justificativa;
- a operação poderá ser liberada para o primeiro dia real.

## Regra operacional relacionada

A entrada de carga normal continua seguindo a regra:

```text
Cheios aumentam
Vazios diminuem na mesma quantidade
Total de cascos permanece estável
```

Essa regra não se aplica ao estoque inicial, pois o estoque inicial apenas registra a situação física já existente.

## Atenção de consistência antes do lançamento real

Uma validação técnica anterior da abertura MVP trabalhou com cinco produtos: P13, P05, P20, P45 e Água.

O escopo aprovado nesta etapa do estoque inicial menciona P13, P20, P45 e Água. Antes do lançamento real, confirmar se o P05 deverá ser incluído, para que o cadastro, a função de abertura e o estoque inicial permaneçam consistentes.

## Frase de retomada

```text
Vamos lançar o estoque inicial.
```

Ao receber essa frase, retomar pela contagem física da Várzea Gás e seguir integralmente este documento.
