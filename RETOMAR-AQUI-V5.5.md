# RETOMAR AQUI — Projeto Fênix Estoque

**Versão publicada atual:** V5.6.2  
**Backend homologado no Supabase:** V5.7.2 — entrada de carga  
**Interface homologada funcionalmente:** V5.7.2.1  
**Dados fictícios:** removidos com sucesso  
**Data:** 11/07/2026

## Estado oficial

- V5.4 operação multi-revenda homologada.
- V5.5 relatórios multi-revenda homologados.
- V5.6.2 login seguro homologado.
- Backend V5.7.2 da entrada de carga homologado.
- Interface V5.7.2.1 homologada funcionalmente.
- Bloqueio por vazios insuficientes homologado.
- Correção visual de operação recusada homologada.
- Dias fictícios `11/07/2099` e `12/07/2099` removidos.
- Resultado da limpeza: `LIMPEZA CONCLUÍDA`, `dias_ficticios_restantes = 0`.
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

## Homologação funcional aprovada

Fluxo principal:

```text
abertura P13: 100 cheios / 30 vazios / total 130
entrada: 5
resultado: 105 cheios / 25 vazios / total 130
```

Bloqueio aprovado:

```text
disponível: 25
solicitado: 26
Entrada não registrada
Operação bloqueada
Estoque sem alteração
```

Conferência final após o bloqueio:

```text
P13 = 105 cheios / 25 vazios / total 130
```

Evidências:

```text
docs/validacao-interface-entrada-carga-v5.7.2-11072026.md
docs/limpeza-dados-homologacao-v5.7.2.1-11072026.md
```

## Limpeza dos dados fictícios

Dias removidos:

```text
Várzea Gás
11/07/2099
12/07/2099
```

Contagens previamente auditadas:

```text
2 dias operacionais
2 conferências de abertura
10 itens de abertura
2 lançamentos
4 movimentos de estoque
1 fechamento
5 itens de fechamento
```

Resultado final:

```text
LIMPEZA CONCLUÍDA
dias_ficticios_restantes = 0
```

## Ponto exato para continuar

Não reconstruir o banco e não repetir os testes já aprovados.

Próxima sequência:

1. promover ou integrar a interface V5.7.2.1 à aplicação definitiva;
2. publicar a versão definitiva em HTTPS;
3. confirmar login e operação do Alex no endereço definitivo;
4. registrar a homologação publicada;
5. definir o momento exato do estoque inicial oficial.

## Regra do estoque inicial

O estoque inicial é o marco zero do controle. Não lançar antes da publicação definitiva e da definição do início do piloto.

Quando for autorizado:

1. fazer a contagem física inicial da Várzea Gás;
2. lançar o estoque inicial;
3. iniciar o controle oficial imediatamente;
4. registrar todas as movimentações do mesmo dia;
5. manter o controle atual em paralelo por cinco a sete dias;
6. encerrar cada dia somente com estoque conferido.

**Próximo trabalho: publicar a interface V5.7.2.1 em HTTPS e validar o acesso do Alex.**