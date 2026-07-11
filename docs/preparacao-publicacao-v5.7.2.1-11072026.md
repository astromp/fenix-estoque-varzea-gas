# Projeto Fênix Estoque — preparação da publicação V5.7.2.1

**Data:** 11/07/2026  
**Status:** pacote definitivo integrado e tecnicamente validado; publicação HTTPS pendente

## Pacote integrado

A interface definitiva reúne:

1. login pelo Supabase Auth;
2. troca obrigatória da senha inicial;
3. revenda obtida da sessão autenticada, sem seletor livre;
4. canais somente da revenda autorizada;
5. abertura da manhã;
6. entrada de carga;
7. venda com troca ou com casco;
8. estoque calculado;
9. fechamento físico sem mostrar o calculado antes da confirmação;
10. correção de divergência;
11. vendas do dia;
12. histórico técnico da tela.

Fonte arquivada em:

```text
publicacao-v5.7.2.1/
```

## Trava do piloto

O pacote de publicação está configurado com:

```js
OPERACAO_LIBERADA: false
```

Consequências:

- login pode ser testado;
- usuário e revenda podem ser confirmados;
- status pode ser consultado;
- abertura, entrada, venda, fechamento e correção permanecem bloqueados;
- o estoque inicial não pode ser iniciado acidentalmente pela interface.

A trava só poderá ser alterada para `true` após autorização expressa do Marco e definição do momento exato da contagem física inicial.

## Validações técnicas realizadas

```text
sintaxe de app.js = aprovada
sintaxe de config.js = aprovada
IDs HTML únicos = 79
IDs usados pelo JavaScript e ausentes no HTML = 0
arquivos obrigatórios = presentes
index.html por HTTP = 200
style.css por HTTP = 200
app.js por HTTP = 200
config.js por HTTP = 200
```

Também foram conferidos:

- chamadas operacionais com `p_revenda_id`;
- ausência de seletor livre de revenda;
- mensagens de operação bloqueada;
- fechamento sem exibir o estoque calculado antes da confirmação física;
- trava do início oficial ativa por padrão.

## Pacotes entregues

```text
fenix-estoque-v5.7.2.1-publicar.zip
SHA-256: ce17953686f27889b70501abab9aed89fd656f8924972f888524d6ef9d0c54b7

fenix-estoque-v5.7.2.1-definitiva-fonte.zip
SHA-256: d2b602ede83697c02757c5c66c3b828f4ab136adc37d22d2055d9364b8ca09d6
```

O ZIP de publicação contém somente a configuração pública necessária no navegador; nenhuma senha, `service_role`, JWT secret ou conexão administrativa foi incluída.

## Pendente

1. definir endereço ou subdomínio HTTPS;
2. publicar o ZIP definitivo;
3. testar login real do Alex;
4. confirmar somente Várzea Gás;
5. conferir celular e computador;
6. registrar homologação publicada;
7. definir o início oficial do estoque.

**O estoque inicial continua bloqueado.**
