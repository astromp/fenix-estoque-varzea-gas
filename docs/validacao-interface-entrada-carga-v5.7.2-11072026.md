# Projeto Fênix Estoque — Validação visual da interface V5.7.2

**Data:** 11/07/2026  
**Situação:** fluxo principal aprovado; bloqueio amigável aprovado; correção visual V5.7.2.1 criada

## Ambiente de homologação

```text
Revenda: Várzea Gás
Data operacional: 12/07/2099
Status do dia: aberto
Produto: P13
Entrada lançada: 5 unidades
```

## Evidência do fluxo principal

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

## Bloqueio amigável aprovado

Com 25 vazios disponíveis para P13, a interface recebeu tentativa de entrada de 26 unidades.

Mensagem apresentada:

```text
Não há vazios suficientes para esta entrada.
Disponível: 25, solicitado: 26.
```

Portanto, a tela traduziu corretamente o erro técnico da função para linguagem operacional.

## Ajuste visual identificado

Na tentativa bloqueada, o cartão de sucesso da entrada anterior permaneceu visível atrás do aviso vermelho. Embora a operação tenha sido recusada, isso poderia confundir o operador.

Foi criada a correção visual V5.7.2.1:

```text
- limpa o resultado anterior ao iniciar nova tentativa;
- mostra “Entrada não registrada” quando houver bloqueio;
- mostra “Operação bloqueada”;
- informa o motivo;
- informa “Estoque sem alteração”.
```

Commits principais:

```text
84bad1f99b88e3e46d86798b46363ef49f234af5
5fad6a7419815d3e14ab352997411d1fbf94e35e
c4791b6dd9dbb1e317a36833be9c0aa545345681
```

## Conclusão atual

A interface autenticada conseguiu:

1. reconhecer a Várzea Gás do usuário autenticado;
2. consultar um dia aberto;
3. liberar a operação de entrada de carga;
4. registrar a entrada pela RPC homologada;
5. refletir corretamente o movimento no estoque calculado;
6. preservar o total de cascos;
7. bloquear quantidade superior aos vazios disponíveis;
8. apresentar mensagem amigável.

## Última conferência antes da homologação final

Após aplicar a V5.7.2.1, repetir a tentativa de 26 P13 e confirmar que a tela mostra somente o cartão de bloqueio. Em seguida, consultar o estoque e confirmar:

```text
P13 = 105 cheios / 25 vazios / total 130
```

Depois dessa conferência, remover os registros exclusivos de homologação, promover/publicar a interface definitiva em HTTPS e registrar a homologação final.

**O estoque inicial oficial continua bloqueado até a publicação definitiva.**
