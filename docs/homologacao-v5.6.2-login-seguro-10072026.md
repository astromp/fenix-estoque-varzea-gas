# Projeto Fênix Estoque — Homologação V5.6.2

**Data:** 10/07/2026  
**Status:** homologada para o piloto da Várzea Gás

## Objetivo desta evolução

Criar o acesso autenticado do usuário operacional do piloto, vinculando-o exclusivamente à Várzea Gás e protegendo as funções do banco contra acesso anônimo ou uso em outra revenda.

## Usuário do piloto

- Nome: Alex
- E-mail de acesso: `varzeaglp@gmail.com`
- Perfil: `operador_conferente`
- Revenda autorizada: Várzea Gás
- UID Supabase: `263756f9-5950-492d-9fd2-d4d90457a23b`
- Status do usuário: ativo
- Status do vínculo: ativo
- Troca de senha no primeiro acesso: obrigatória

Não registrar senha no repositório.

## Estrutura de acesso criada

### `usuarios_sistema`

Mantém os dados do usuário do Projeto Fênix, incluindo nome, e-mail, situação e necessidade de troca da senha inicial.

### `usuarios_revendas`

Vincula cada usuário às revendas autorizadas e ao respectivo perfil. O Alex possui somente um vínculo ativo: Várzea Gás.

## Funções de autenticação e autorização

- `usuario_autorizado_na_revenda(uuid)`
- `consultar_meu_acesso_fenix()`
- `concluir_primeiro_acesso_fenix()`
- `listar_meus_canais_fenix(uuid)`

A tela consulta o usuário autenticado pelo `auth.uid()` e carrega somente as revendas e canais permitidos.

## Proteção das funções operacionais

As sete funções multi-revenda foram protegidas:

- `consultar_status_dia_mvp(uuid, date)`
- `registrar_abertura_mvp(uuid, date, jsonb)`
- `registrar_venda_mvp(uuid, date, text, text, integer, integer)`
- `consultar_estoque_mvp(uuid, date)`
- `registrar_fechamento_mvp(uuid, date, jsonb)`
- `registrar_correcao_venda_casco_mvp(uuid, date, text, text, integer)`
- `consultar_vendas_dia_mvp(uuid, date)`

Cada função valida:

1. usuário autenticado;
2. usuário ativo;
3. vínculo ativo com a revenda informada;
4. revenda autorizada para o usuário.

## Permissões homologadas

Resultado final das sete funções:

```text
authenticated_pode_executar = true
anon_pode_executar = false
public_pode_executar = false
```

Portanto, usuários sem login não conseguem executar abertura, venda, estoque, fechamento, correção ou consulta de vendas.

## Tela homologada

A V5.6.2 apresentou corretamente:

- tela de login por e-mail e senha;
- opção Mostrar/Ocultar senha;
- troca obrigatória da senha inicial;
- sessão autenticada;
- identificação `Alex · operador/conferente`;
- botão Sair;
- Várzea Gás selecionada automaticamente;
- seletor da revenda bloqueado;
- status do dia consultado com sucesso;
- canais restritos à Várzea Gás.

## Evidência visual da homologação

Na prova final, a tela mostrou:

```text
Alex · operador/conferente
Várzea Gás — Várzea Paulista/SP
Conectado
Status do dia: fechado
Estoque fechado, turno encerrado.
```

## Configuração do navegador

O arquivo `config.js` deve conter somente:

- `SUPABASE_URL`;
- chave `anon` ou `publishable`.

Nunca registrar no navegador ou no GitHub:

- `service_role`;
- senha do banco;
- JWT secret;
- senha do usuário.

## Estado oficial após esta homologação

- V5.4 operação multi-revenda: homologada.
- V5.5 relatórios multi-revenda: homologada.
- V5.6.2 login seguro: homologada.
- Alex vinculado exclusivamente à Várzea Gás: confirmado.
- Acesso anônimo às funções operacionais: bloqueado.
- Botão Mostrar/Ocultar senha: validado.

## Próximos passos antes do piloto

1. Criar a operação de entrada de carga cheia com saída equivalente de vazios.
2. Publicar a aplicação em endereço HTTPS.
3. Definir o dia oficial de início do piloto.
4. Fazer a contagem física inicial da Várzea Gás no início do primeiro dia.
5. Operar o controle atual em paralelo durante cinco a sete dias.
6. Conferir abertura, vendas, entradas, fechamento e relatórios diariamente.

**Não reconstruir versões anteriores. Continuar a partir da V5.6.2 homologada.**