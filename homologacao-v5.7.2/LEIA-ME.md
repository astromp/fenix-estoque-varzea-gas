# Projeto Fênix Estoque — Interface de homologação V5.7.2

Esta pasta foi criada para testar a entrada de carga no frontend autenticado sem substituir a aplicação existente.

## O que está incluído

- login com e-mail e senha pelo Supabase Auth;
- botão Mostrar/Ocultar senha;
- troca obrigatória da senha inicial;
- leitura do usuário e da revenda autorizada por `consultar_meu_acesso_fenix()`;
- revenda obtida da sessão, sem seletor livre para o operador;
- consulta do status do dia;
- entrada de carga por `registrar_entrada_carga_mvp(uuid,date,text,integer)`;
- confirmação visual de cheios recebidos e vazios entregues;
- mensagem amigável para vazios insuficientes;
- consulta do estoque calculado.

## Configuração

Edite `config.js` e preencha somente:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

A chave anon/publishable é pública e foi criada para uso no navegador. Nunca coloque nesta pasta:

- service_role;
- senha do banco;
- JWT secret;
- DATABASE_URL;
- senha de usuário.

## Publicação de homologação

Publique os quatro arquivos da pasta juntos:

```text
index.html
style.css
app.js
config.js
```

Use HTTPS para o teste com o usuário Alex.

## Critérios do teste

1. Alex entra com o próprio e-mail e senha.
2. A tela mostra somente a Várzea Gás.
3. Um dia aberto libera o botão Entrada de carga.
4. O operador informa produto e quantidade.
5. A tela confirma a mesma quantidade de cheios recebidos e vazios entregues.
6. Quantidade maior que os vazios disponíveis é bloqueada sem gravação parcial.
7. O estoque calculado reflete cheios + quantidade e vazios - quantidade.

Não lançar o estoque inicial oficial antes da publicação e homologação desta interface.
