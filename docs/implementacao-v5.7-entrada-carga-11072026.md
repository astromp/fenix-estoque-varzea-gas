# Projeto Fênix Estoque — Implementação V5.7.1

**Data:** 11/07/2026  
**Situação:** código criado e revisado no GitHub; execução e homologação no Supabase ainda pendentes

## Operação criada

Função segura:

```text
registrar_entrada_carga_mvp(uuid, date, text, integer)
```

Parâmetros:

- revenda autorizada;
- data operacional;
- código do produto: P13, P05, P20, P45 ou AGUA;
- quantidade recebida.

## Regra operacional

Para cada quantidade informada, a função cria um único lançamento e dois movimentos vinculados:

```text
entrada_cheia: + quantidade de cheios
saida_vazio:   - mesma quantidade de vazios
```

O total de cascos permanece estável.

## Proteções implementadas

- exige usuário autenticado;
- exige vínculo ativo e autorização para a revenda;
- trata autorização nula como acesso negado;
- exige revenda ativa;
- exige data operacional;
- exige dia operacional aberto;
- exige abertura ativa no dia;
- aceita somente produtos ativos do Fênix;
- exige quantidade inteira maior que zero;
- bloqueia a operação quando não houver vazios suficientes;
- grava tudo na mesma transação;
- libera execução somente para `authenticated`;
- bloqueia `anon` e `public`.

## Reforço de concorrência V5.7.1

Antes de calcular os vazios disponíveis, a função:

1. bloqueia a linha do dia operacional com `FOR UPDATE`;
2. bloqueia temporariamente novas inserções em `movimentos_estoque` com `SHARE ROW EXCLUSIVE`;
3. recalcula o saldo já dentro da transação protegida;
4. somente depois grava o lançamento e os dois movimentos.

Essa proteção reduz o risco de duas operações simultâneas utilizarem o mesmo saldo de vazios.

As consultas permanecem disponíveis durante a gravação. O bloqueio dura apenas até o fim da transação da entrada de carga.

## Arquivos

1. `sql/v5.7-entrada-carga-etapa-1-tipos.sql`
2. `sql/v5.7-entrada-carga-etapa-2-funcao.sql`

Os arquivos devem ser executados nessa ordem e separadamente.

## Teste de homologação proposto

Com um dia de teste aberto na Várzea Gás:

1. consultar o estoque antes;
2. registrar entrada de 5 unidades de um produto que tenha ao menos 5 vazios;
3. confirmar a criação de um lançamento;
4. confirmar dois movimentos vinculados;
5. consultar o estoque depois;
6. confirmar `cheios +5`;
7. confirmar `vazios -5`;
8. confirmar que o total de cascos não mudou;
9. tentar quantidade superior aos vazios disponíveis e confirmar bloqueio;
10. confirmar bloqueio quando o dia não estiver aberto;
11. confirmar bloqueio quando não houver abertura ativa;
12. testar permissões e confirmar: `authenticated=true`, `anon=false`, `public=false`.

## Observação sobre o cálculo já homologado

A função `consultar_estoque_mvp` da V5.4 já trata `entrada_cheia` como aumento de cheios e redução equivalente de vazios. Por compatibilidade, o novo movimento `saida_vazio` funciona como evidência operacional vinculada e não deve ser descontado novamente no cálculo, evitando redução em duplicidade.

## Próxima ação

Executar os dois SQLs no Supabase, testar com dados de homologação e somente então integrar o botão de entrada de carga à tela autenticada V5.6.2.

**Não lançar o estoque inicial antes da homologação da V5.7.1 e da publicação definitiva.**
