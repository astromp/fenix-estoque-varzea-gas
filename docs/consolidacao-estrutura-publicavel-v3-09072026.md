# Consolidação da Estrutura Publicável V3 — 09/07/2026

## Status

A estrutura publicável da Operação Celular Integrada V3 foi consolidada no repositório `astromp/fenix-estoque-varzea-gas`.

## Arquivos gravados na raiz do projeto

```text
index.html
css/style.css
js/app.js
js/config.js
js/config.example.js
.gitignore
LEIA-ME.txt
```

## O que foi preservado

A consolidação preserva o ponto de retomada já validado:

```text
sem abertura -> aberto -> fechado
aberto -> inconsistente -> corrigido -> fechado
```

Também preserva as funções Supabase documentadas para o MVP:

```text
registrar_abertura_mvp
registrar_venda_mvp
consultar_estoque_mvp
registrar_fechamento_mvp
registrar_correcao_venda_casco_mvp
consultar_status_dia_mvp
```

## Segurança

O arquivo `js/config.js` foi gravado apenas com placeholder:

```text
SUPABASE_URL: "COLE_AQUI_A_URL_DO_SUPABASE"
SUPABASE_ANON_KEY: "COLE_AQUI_A_ANON_PUBLIC_KEY"
```

Nenhuma chave real deve ser gravada no GitHub público.

Nunca usar no frontend:

```text
service_role
senha do banco
DATABASE_URL
connection string
```

## Próximo passo

Baixar ou abrir o projeto, editar localmente `js/config.js`, colar a URL pública do Supabase e a anon public key, e testar novamente pelo celular.

Depois do teste, evoluir a tela para uso operacional real:

```text
1. mensagens mais simples para colaborador;
2. botões maiores e menos histórico técnico;
3. fluxo guiado para abertura, venda e fechamento;
4. bloqueio de cálculo esperado antes da contagem física;
5. preparação futura de login e perfil.
```

## Regra de ouro

```text
Estoque fechado, turno encerrado.
Estoque inconsistente, revisar até corrigir.
```
