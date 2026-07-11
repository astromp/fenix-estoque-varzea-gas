# RETOMAR AQUI — Projeto Fênix Estoque

**Versão publicada atual:** V5.6.2  
**Backend homologado no Supabase:** V5.7.2 — entrada de carga  
**Interface homologada funcionalmente:** V5.7.2.1  
**Data:** 11/07/2026

## Estado oficial

- V5.4 operação multi-revenda homologada.
- V5.5 relatórios multi-revenda homologados.
- V5.6.2 login seguro homologado.
- Backend V5.7.2 da entrada de carga homologado.
- Interface V5.7.2.1 homologada funcionalmente.
- A versão definitiva em HTTPS ainda não foi publicada.
- O estoque inicial oficial ainda não foi lançado.

## Usuário do piloto

```text
Nome: Alex
E-mail: varzeaglp@gmail.com
Perfil: operador_conferente
Revenda exclusiva: Várzea Gás
Usuário ativo: sim
Vínculo ativo: sim
```

Não registrar senha no GitHub ou em documentos do projeto.

## Segurança homologada

```text
authenticated = true
anon = false
public = false
```

A revenda é obtida da sessão autenticada, sem seletor livre para o operador.

## Entrada de carga homologada

Função:

```text
registrar_entrada_carga_mvp(uuid,date,text,integer)
```

Regra:

```text
entrou cheio → aumenta cheio
saiu vazio → diminui vazio
mesma quantidade
total de cascos permanece estável
```

Cada operação gera:

```text
1 lançamento entrada_carga
1 movimento entrada_cheia
1 movimento saida_vazio vinculado
```

## Backend aprovado

Dia fictício de teste:

```text
Várzea Gás
11/07/2099
P13
abertura: 100 cheios / 30 vazios / total 130
entrada: 5
resultado: 105 cheios / 25 vazios / total 130
```

Também foram aprovados:

- bloqueio por vazios insuficientes;
- nenhuma gravação parcial;
- fechamento com diferenças zeradas;
- cinco produtos conferidos;
- `estoque fechado, turno encerrado`.

## Interface V5.7.2.1 aprovada

Dia fictício de teste visual:

```text
Várzea Gás
12/07/2099
status: aberto
produto: P13
entrada: 5
```

Resultado mostrado pela própria tela:

```text
P13 = 105 cheios / 25 vazios / total 130
P05 = 10 cheios / 5 vazios / total 15
P20 = 10 cheios / 2 vazios / total 12
P45 = 10 cheios / 10 vazios / total 20
AGUA = 50 cheios / 10 vazios / total 60
```

Tentativa bloqueada:

```text
disponível: 25
solicitado: 26
Entrada não registrada
Operação bloqueada
Estoque sem alteração
```

A conferência final após o bloqueio manteve:

```text
P13 = 105 cheios / 25 vazios / total 130
```

Portanto, o fluxo principal, o bloqueio amigável e a correção visual V5.7.2.1 estão homologados.

Evidência:

```text
docs/validacao-interface-entrada-carga-v5.7.2-11072026.md
```

## Ponto exato para continuar

Não reconstruir o banco e não repetir os testes já aprovados.

Próxima sequência:

1. executar diagnóstico somente de leitura dos registros fictícios de `11/07/2099` e `12/07/2099`;
2. após autorização expressa do Marco, remover somente esses registros de homologação;
3. promover ou integrar a interface V5.7.2.1 à aplicação definitiva;
4. publicar em HTTPS;
5. confirmar login e operação do Alex no endereço definitivo;
6. registrar a homologação publicada;
7. definir o momento exato do estoque inicial oficial.

## Regra do estoque inicial

O estoque inicial é o marco zero do controle. Não lançar antes da publicação definitiva e da definição do início do piloto.

Quando for autorizado:

1. fazer a contagem física inicial da Várzea Gás;
2. lançar o estoque inicial;
3. iniciar o controle oficial imediatamente;
4. registrar todas as movimentações do mesmo dia;
5. manter o controle atual em paralelo por cinco a sete dias;
6. encerrar cada dia somente com estoque conferido.

**Próximo trabalho: diagnóstico e limpeza autorizada dos dados fictícios, seguida da publicação definitiva da V5.7.2.1.**