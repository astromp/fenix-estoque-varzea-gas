# Estrutura Publicável — Operação Celular Integrada V3 — 08/07/2026

## Status

Estrutura de projeto gerada para a Operação Celular Integrada V3.

A versão anterior era um arquivo único de teste. Esta etapa separa a aplicação em arquivos próprios para facilitar evolução, manutenção e futura publicação.

## Estrutura gerada

```text
index.html
css/style.css
js/app.js
js/config.js
js/config.example.js
.gitignore
README.md
LEIA-ME.txt
```

## Objetivo

Transformar o protótipo local em uma estrutura mais próxima de projeto real, separando:

```text
HTML
CSS
JavaScript
Configuração Supabase
Documentação
```

## Segurança

A chave Supabase não fica mais cravada diretamente no `index.html`.

A configuração passa a ficar em:

```text
js/config.js
```

O arquivo contém placeholder para a chave `anon public`:

```text
SUPABASE_ANON_KEY: "COLE_AQUI_A_ANON_PUBLIC_KEY"
```

## Atenção

Mesmo sendo uma chave pública `anon`, o projeto mantém o cuidado de nunca usar no frontend:

```text
service_role
senha do banco
DATABASE_URL
connection string
```

A segurança real permanece nas políticas RLS e nas funções controladas do Supabase.

## Funcionalidades preservadas

A estrutura publicável preserva as funcionalidades da V3:

```text
1. status do dia operacional;
2. bloqueios visuais por status;
3. abertura da manhã;
4. lançamento de venda comum;
5. lançamento de venda com casco;
6. consulta de estoque calculado;
7. fechamento físico;
8. identificação de inconsistência;
9. correção;
10. refazimento de fechamento.
```

## Próximo passo recomendado

Testar a estrutura separada localmente:

1. editar `js/config.js`;
2. colar a anon public key;
3. abrir `index.html`;
4. testar uma data nova;
5. validar abertura, venda, estoque e fechamento.

Depois, o próximo passo será decidir a forma de publicação controlada.

## Regra de ouro preservada

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
