# RETOMAR AQUI — Projeto Fênix Estoque

**Versão publicada atual:** V5.6.2  
**Backend homologado no Supabase:** V5.7.2 — entrada de carga  
**Interface homologada funcionalmente:** V5.7.2.1  
**Pacote definitivo integrado:** preparado em `publicacao-v5.7.2.1/`  
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
- Interface definitiva integrada e arquivada em `publicacao-v5.7.2.1/`.
- Pacote ZIP de publicação montado e validado fora do GitHub com a conexão pública necessária.
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

Resultado final:

```text
LIMPEZA CONCLUÍDA
dias_ficticios_restantes = 0
```

## Pacote definitivo integrado

Pasta no GitHub:

```text
publicacao-v5.7.2.1/
```

A interface reúne:

1. login e troca obrigatória de senha;
2. revenda e canais obtidos do usuário autenticado;
3. abertura da manhã;
4. entrada de carga;
5. venda com troca ou com casco;
6. estoque calculado;
7. fechamento físico sem mostrar o calculado antes da confirmação;
8. correção de divergência;
9. vendas do dia;
10. histórico da tela.

A fonte de `app.js` está arquivada em cinco partes dentro de `publicacao-v5.7.2.1/fonte/`. O comando abaixo reconstrói o arquivo final:

```bash
python publicacao-v5.7.2.1/montar-app.py
```

## Trava do início oficial

O pacote de publicação foi preparado com:

```js
OPERACAO_LIBERADA: false
```

Assim, o acesso do Alex pode ser testado no endereço definitivo sem permitir abertura, entrada, venda, fechamento ou correção.

Somente após autorização expressa do Marco e definição do momento da contagem física inicial, alterar para:

```js
OPERACAO_LIBERADA: true
```

## Ponto exato para continuar

Não reconstruir o banco e não repetir os testes já aprovados.

Próxima sequência:

1. definir o endereço ou subdomínio HTTPS da aplicação;
2. publicar o ZIP definitivo mantendo `OPERACAO_LIBERADA: false`;
3. confirmar o login do Alex no endereço definitivo;
4. confirmar `Alex · operador/conferente` e somente `Várzea Gás`;
5. testar em celular e computador;
6. registrar a homologação publicada;
7. definir o momento exato do estoque inicial oficial;
8. somente então liberar a operação e fazer a contagem física inicial.

## Regra do estoque inicial

O estoque inicial é o marco zero do controle. Não lançar antes da publicação definitiva, da validação do acesso e da autorização do início do piloto.

Quando for autorizado:

1. fazer a contagem física inicial da Várzea Gás;
2. liberar a operação no `config.js`;
3. lançar o estoque inicial;
4. iniciar o controle oficial imediatamente;
5. registrar todas as movimentações do mesmo dia;
6. manter o controle atual em paralelo por cinco a sete dias;
7. encerrar cada dia somente com estoque conferido.

**Próximo trabalho: publicar a interface V5.7.2.1 em HTTPS com a operação ainda bloqueada e validar o acesso do Alex.**
