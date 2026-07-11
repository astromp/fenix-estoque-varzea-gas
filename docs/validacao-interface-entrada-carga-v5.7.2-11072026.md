# Projeto Fênix Estoque — Validação visual da interface V5.7.2

**Data:** 11/07/2026  
**Situação:** fluxo principal da entrada de carga validado pela interface autenticada

## Ambiente de homologação

```text
Revenda: Várzea Gás
Data operacional: 12/07/2099
Status do dia: aberto
Produto: P13
Entrada lançada: 5 unidades
```

## Evidência observada na interface

Após registrar a entrada pela tela e consultar o estoque calculado, a interface mostrou:

```text
P13
cheios = 105
vazios = 25
total = 130
```

Os demais produtos permaneceram inalterados:

```text
P05 = 10 cheios / 5 vazios / total 15
P20 = 10 cheios / 2 vazios / total 12
P45 = 10 cheios / 10 vazios / total 20
AGUA = 50 cheios / 10 vazios / total 60
```

## Regra comprovada pela interface

Partindo de:

```text
100 cheios
30 vazios
130 cascos
```

A entrada de 5 unidades produziu:

```text
cheios +5
vazios -5
total de cascos inalterado
```

Resultado:

```text
105 cheios
25 vazios
130 cascos
```

## Conclusão

A interface autenticada conseguiu:

1. reconhecer a Várzea Gás do usuário autenticado;
2. consultar um dia aberto;
3. liberar a operação de entrada de carga;
4. registrar a entrada pela RPC homologada;
5. refletir corretamente o movimento no estoque calculado;
6. preservar o total de cascos.

## Teste ainda pendente na interface

Falta validar visualmente o bloqueio amigável quando a quantidade solicitada supera os vazios disponíveis.

Cenário recomendado:

```text
vazios disponíveis para P13 = 25
tentativa = 26
resultado esperado = operação bloqueada e nenhuma alteração no estoque
```

Depois desse teste, remover os registros exclusivos de homologação, promover/publicar a interface definitiva em HTTPS e registrar a homologação final da V5.7.2.

**O estoque inicial oficial continua bloqueado até a conclusão da homologação da interface e da publicação definitiva.**