# Projeto Fênix Estoque — Implementação V5.7.2

**Data:** 11/07/2026  
**Situação:** backend da entrada de carga homologado no Supabase; integração da tela autenticada ainda pendente

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

## Homologação do núcleo da entrada

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

Conclusão:

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

## Fechamento homologado

O dia de homologação foi fechado com a contagem física correspondente ao estoque calculado.

Resultado geral:

```text
status_dia = fechado
status_fechamento = conferido
itens_registrados = 5
itens_inconsistentes = 0
```

Produtos conferidos:

```text
P13: 105 cheios / 25 vazios / diferenças 0 / conferido
P05: 10 cheios / 5 vazios / diferenças 0 / conferido
P20: 10 cheios / 2 vazios / diferenças 0 / conferido
P45: 10 cheios / 10 vazios / diferenças 0 / conferido
AGUA: 50 cheios / 10 vazios / diferenças 0 / conferido
```

Conclusão do backend:

```text
entrada de carga registrada corretamente
saldo de vazios protegido
nenhuma gravação parcial
reflexo correto no fechamento
estoque fechado, turno encerrado
```

## Observação sobre o cálculo homologado

A função `consultar_estoque_mvp` da V5.4 já trata `entrada_cheia` como aumento de cheios e redução equivalente de vazios. O movimento `saida_vazio` funciona como evidência operacional vinculada e não deve ser descontado novamente no cálculo, evitando redução em duplicidade.

## Próximas etapas

1. integrar a entrada de carga à aplicação autenticada V5.6.2;
2. testar a tela com o usuário Alex;
3. remover o dia e os registros exclusivos de homologação após o teste da tela;
4. publicar a versão definitiva em HTTPS;
5. registrar a homologação final da V5.7.2 completa.

**Não lançar o estoque inicial antes da integração da tela, do teste autenticado e da publicação definitiva.**