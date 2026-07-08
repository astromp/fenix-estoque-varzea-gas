# Supabase — Projeto Fênix Estoque / Várzea Gás

Este diretório guarda a configuração e as migrations SQL do Supabase para o Projeto Fênix Estoque.

## Projeto Supabase

URL do projeto:

```text
https://pxlapmdypnmvymgbpzhi.supabase.co
```

Nome tratado no projeto:

```text
estoque de fênix
```

## Aviso de segurança

A URL pública do Supabase pode ficar registrada no projeto.

Mas as chaves abaixo **não devem ser colocadas no GitHub público**:

- `service_role key`;
- senhas do banco;
- tokens privados;
- credenciais de integração;
- arquivos `.env` reais.

Quando for necessário criar variáveis de ambiente, usar apenas um arquivo de exemplo, como:

```text
.env.example
```

Nunca subir o arquivo real:

```text
.env
```

## Migration inicial

Arquivo criado:

```text
supabase/migrations/20260708143000_estrutura_inicial_estoque_varzea.sql
```

Esse arquivo cria a estrutura inicial do banco:

- revendas;
- produtos;
- canais de venda;
- usuários;
- dias operacionais;
- conferências de abertura;
- lançamentos;
- movimentos de estoque;
- fechamentos;
- divergências;
- correções;
- view de estoque calculado.

## Como executar manualmente no Supabase

1. Acessar o painel do Supabase.
2. Abrir o projeto `estoque de fênix`.
3. Entrar em **SQL Editor**.
4. Abrir o arquivo da migration no GitHub.
5. Copiar o conteúdo completo.
6. Colar no SQL Editor.
7. Executar.
8. Conferir no menu **Table Editor** se as tabelas foram criadas.

## Primeiro teste esperado

Após rodar a migration, devem aparecer os registros iniciais:

Revenda:

```text
Várzea Gás
```

Produtos:

```text
P13
P05
P20
P45
AGUA
```

Canais de venda:

```text
André
João
Rogério
Portaria
Outros
```

Observação importante:

```text
Portaria é canal de venda, assim como André, João e Rogério.
```
