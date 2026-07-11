# Projeto Fênix Estoque — pacote definitivo V5.7.2.1

**Situação:** interface integrada e preparada para publicação; ainda não publicada.

## O que esta versão reúne

- login pelo Supabase Auth;
- troca obrigatória da senha inicial;
- revenda obtida da sessão autenticada, sem seletor livre;
- canais somente da revenda autorizada;
- abertura da manhã;
- entrada de carga com entrada de cheios e saída equivalente de vazios;
- venda com troca ou com venda de casco;
- estoque calculado;
- fechamento físico sem revelar o calculado antes da confirmação;
- correção de venda com casco não lançada;
- consulta das vendas do dia;
- histórico técnico da tela;
- mensagens claras de operação recusada;
- bloqueio do início oficial do piloto.

## Fonte do app.js

Por limite de tamanho da integração com o GitHub, a fonte está arquivada em cinco partes dentro de `fonte/`.

Para reconstruir o arquivo final:

```bash
python montar-app.py
```

O comando cria `app.js` pela concatenação ordenada das cinco partes. O ZIP de publicação entregue ao Marco já contém o `app.js` montado e validado.

## Trava do início oficial

O arquivo `config.js` contém:

```js
OPERACAO_LIBERADA: false
```

Enquanto permanecer `false`, o Alex pode testar login e consultar o status, mas os botões que gravam abertura, entrada, venda, fechamento e correção ficam bloqueados.

Somente depois da autorização expressa do Marco e da definição do momento exato da contagem física inicial, alterar para:

```js
OPERACAO_LIBERADA: true
```

## Configuração segura

No `config.js`, usar somente:

- URL pública do projeto Supabase;
- chave `anon` ou `publishable`;
- a trava `OPERACAO_LIBERADA`.

Nunca usar no navegador:

- `service_role`;
- senha do banco;
- JWT secret;
- connection string;
- senha de usuário.

## Publicação

Publicar juntos, na mesma pasta do endereço HTTPS:

```text
index.html
style.css
app.js
config.js
```

Depois da publicação:

1. abrir o endereço em janela anônima;
2. confirmar que aparece a tela de login;
3. entrar com o usuário do Alex;
4. confirmar `Alex · operador/conferente`;
5. confirmar que aparece somente `Várzea Gás`;
6. confirmar que a operação oficial continua bloqueada;
7. testar em celular e computador;
8. somente depois definir o início oficial do estoque.

## Estado do banco

Os dias fictícios `11/07/2099` e `12/07/2099` foram removidos com sucesso. O banco retornou:

```text
LIMPEZA CONCLUÍDA
dias_ficticios_restantes = 0
```

**Não lançar o estoque inicial antes da publicação HTTPS, do teste de acesso do Alex e da autorização expressa do início do piloto.**
