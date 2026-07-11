# Projeto Fênix Estoque — Homologação da interface V5.7.2.1

**Data:** 11/07/2026  
**Status:** homologação funcional concluída e dados fictícios removidos

## Ambiente de teste

```text
Revenda: Várzea Gás
Usuário autenticado: Alex
Data operacional: 12/07/2099
Produto: P13
Abertura: 100 cheios / 30 vazios / total 130
```

## Fluxo principal aprovado

A interface registrou uma entrada de 5 P13 pela função protegida:

```text
registrar_entrada_carga_mvp(uuid,date,text,integer)
```

Resultado apresentado no estoque calculado:

```text
P13 = 105 cheios / 25 vazios / total 130
P05 = 10 cheios / 5 vazios / total 15
P20 = 10 cheios / 2 vazios / total 12
P45 = 10 cheios / 10 vazios / total 20
AGUA = 50 cheios / 10 vazios / total 60
```

Conclusão:

```text
cheios +5
vazios -5
total de cascos preservado
produtos não envolvidos permaneceram inalterados
```

## Bloqueio por vazios insuficientes aprovado

Com 25 vazios disponíveis, foi tentada uma entrada de 26 P13.

A interface mostrou:

```text
Entrada não registrada
Operação bloqueada
Não há vazios suficientes para esta entrada.
Disponível: 25, solicitado: 26.
Estoque sem alteração
```

Após o bloqueio, a consulta final confirmou:

```text
P13 = 105 cheios / 25 vazios / total 130
```

Portanto, nenhuma gravação adicional ocorreu.

## Correção visual V5.7.2.1 aprovada

A tela foi ajustada para:

- limpar o resultado anterior antes de cada nova tentativa;
- não manter um cartão de sucesso visível quando a operação for recusada;
- mostrar `Entrada não registrada`;
- mostrar `Operação bloqueada`;
- apresentar o motivo em linguagem operacional;
- informar `Estoque sem alteração`.

## Segurança confirmada

A revenda é obtida da sessão autenticada, sem seletor livre para o operador. A função permanece com as permissões:

```text
authenticated = true
anon = false
public = false
```

## Limpeza dos dados fictícios concluída

Após autorização expressa de Marco, os dias fictícios da Várzea Gás foram removidos:

```text
11/07/2099
12/07/2099
```

Resultado final apresentado pelo Supabase:

```text
resultado = LIMPEZA CONCLUÍDA
dias_ficticios_restantes = 0
```

Evidência detalhada:

```text
docs/limpeza-dados-homologacao-v5.7.2.1-11072026.md
```

## Conclusão final

A interface V5.7.2.1 está funcionalmente homologada para a entrada de carga da Várzea Gás:

1. reconhece o usuário autenticado e sua revenda;
2. libera entrada somente com o dia aberto;
3. registra entrada de cheio e saída equivalente de vazio;
4. preserva o total de cascos;
5. bloqueia saldo insuficiente sem gravação parcial;
6. exibe mensagens claras ao operador;
7. mantém o estoque calculado correto após sucesso e após bloqueio;
8. teve todos os dados fictícios removidos após a homologação.

## Próximos passos

1. promover ou integrar a interface homologada à aplicação definitiva;
2. publicar a versão definitiva em HTTPS;
3. confirmar o acesso do Alex no endereço definitivo;
4. registrar a homologação publicada;
5. definir o momento do estoque inicial oficial.

**O estoque inicial oficial continua bloqueado até a publicação definitiva e a definição do início do piloto.**