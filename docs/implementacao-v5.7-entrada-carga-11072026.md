# Projeto Fênix Estoque — Implementação V5.7.2

**Data:** 11/07/2026  
**Situação:** função instalada no Supabase; teste principal e bloqueio por vazios insuficientes aprovados; homologação complementar ainda em andamento

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

## Compatibilidade com o esquema real — V5.7.2

O diagnóstico do Supabase confirmou que:

- `lancamentos.tipo_lancamento` é `text` com restrição `CHECK`;
- `movimentos_estoque.tipo_movimento` é `text` com restrição `CHECK`.

As restrições foram ampliadas preservando todos os valores anteriores e acrescentando somente:

```text
entrada_carga
saida_vazio
```

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

## Reforço de concorrência

Antes de calcular os vazios disponíveis, a função:

1. bloqueia a linha do dia operacional com `FOR UPDATE`;
2. bloqueia temporariamente novas inserções em `movimentos_estoque` com `SHARE ROW EXCLUSIVE`;
3. recalcula o saldo dentro da transação protegida;
4. somente depois grava o lançamento e os dois movimentos.

## Permissões confirmadas

```text
authenticated_pode_executar = true
anon_pode_executar = false
public_pode_executar = false
```

## Teste principal aprovado

Dia exclusivo de homologação:

```text
Revenda: Várzea Gás
Data: 11/07/2099
Produto: P13
Abertura: 100 cheios e 30 vazios
Entrada registrada: 5 unidades
```

Resultado confirmado:

```text
cheios_calculados = 105
vazios_calculados = 25
total_cascos = 130
lancamentos_entrada = 1
movimentos_entrada = 2
movimentos_vinculados = true
```

Conclusão do teste principal:

```text
cheios +5
vazios -5
total de cascos inalterado
um lançamento
dois movimentos vinculados
```

## Bloqueio por vazios insuficientes aprovado

Com 25 vazios disponíveis, foi tentada uma entrada de 26 unidades de P13.

Resultado:

```text
resultado = BLOQUEIO APROVADO
erro_recebido = Vazios insuficientes. Disponível: 25, solicitado: 26.
lancamentos_antes = 1
lancamentos_depois = 1
movimentos_antes = 2
movimentos_depois = 2
```

Conclusão:

- a operação incorreta foi recusada;
- nenhum lançamento adicional foi criado;
- nenhum movimento adicional foi criado;
- não houve gravação parcial.

## Observação sobre o cálculo já homologado

A função `consultar_estoque_mvp` da V5.4 já trata `entrada_cheia` como aumento de cheios e redução equivalente de vazios. O movimento `saida_vazio` funciona como evidência operacional vinculada e não deve ser descontado novamente no cálculo, evitando redução em duplicidade.

## Testes ainda pendentes

1. confirmar reflexo correto no fechamento;
2. integrar e testar a tela de entrada de carga na aplicação autenticada;
3. testar a tela com o usuário Alex;
4. remover os dados exclusivos de homologação após a conclusão;
5. registrar a homologação final.

**Não lançar o estoque inicial antes da homologação completa da V5.7.2 e da publicação definitiva.**