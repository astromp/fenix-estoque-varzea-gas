# RETOMAR AQUI — Projeto Fênix Estoque

**Versão homologada em produção:** V5.6.2  
**Backend homologado no Supabase:** V5.7.2 — entrada de carga  
**Interface V5.7.2 criada:** pasta separada de homologação; teste real pendente  
**Data:** 11/07/2026

## Estado homologado

- V5.4 operação multi-revenda homologada.
- V5.5 relatórios multi-revenda homologados.
- V5.6.2 login seguro homologado.
- Backend V5.7.2 da entrada de carga homologado no Supabase.
- Todas as operações novas exigem `p_revenda_id`.
- Várzea Gás e Vinhedo Gás foram testadas e permaneceram segregadas.
- CSV de ambas as unidades foi validado.
- Impressão gerencial foi validada.
- Acesso anônimo às funções operacionais foi bloqueado.

## Usuário do piloto

- Nome: Alex
- E-mail: `varzeaglp@gmail.com`
- Perfil: `operador_conferente`
- Revenda exclusiva: Várzea Gás
- Usuário ativo: sim
- Vínculo ativo: sim
- Troca de senha no primeiro acesso: obrigatória

Não registrar senha no GitHub ou em documentos do projeto.

## Segurança homologada

Para as funções operacionais protegidas:

```text
authenticated_pode_executar = true
anon_pode_executar = false
public_pode_executar = false
```

## V5.7.2 — entrada de carga

Arquivos principais do backend:

- `sql/v5.7-entrada-carga-etapa-1-tipos.sql`;
- `sql/v5.7-entrada-carga-etapa-2-funcao.sql`;
- `docs/implementacao-v5.7-entrada-carga-11072026.md`.

Função instalada:

```text
registrar_entrada_carga_mvp(uuid, date, text, integer)
```

Regra:

```text
entrou cheio → aumenta cheio
saiu vazio → diminui vazio
mesma quantidade
total de cascos permanece estável
```

Cada entrada gera:

```text
1 lançamento do tipo entrada_carga
1 movimento entrada_cheia
1 movimento saida_vazio vinculado
```

## Compatibilidade corrigida

O esquema real usa colunas `text` com restrições `CHECK`. As restrições foram ampliadas, preservando todos os valores antigos e acrescentando somente:

```text
entrada_carga
saida_vazio
```

## Homologação aprovada no Supabase

Dia exclusivo de homologação:

```text
Várzea Gás
11/07/2099
P13
abertura: 100 cheios / 30 vazios / 130 cascos
entrada: 5 unidades
```

Resultado do estoque:

```text
105 cheios
25 vazios
130 cascos
1 lançamento
2 movimentos
movimentos vinculados = true
```

Bloqueio de saldo insuficiente:

```text
tentativa: 26
vazios disponíveis: 25
resultado: bloqueado
lançamentos: 1 antes / 1 depois
movimentos: 2 antes / 2 depois
```

Fechamento:

```text
status_dia = fechado
status_fechamento = conferido
P13 = 105 cheios / 25 vazios / diferenças 0
P05 = 10 cheios / 5 vazios / diferenças 0
P20 = 10 cheios / 2 vazios / diferenças 0
P45 = 10 cheios / 10 vazios / diferenças 0
AGUA = 50 cheios / 10 vazios / diferenças 0
```

Conclusão:

```text
backend da entrada de carga homologado
regra de cascos confirmada
bloqueio sem gravação parcial confirmado
reflexo correto no fechamento confirmado
estoque fechado, turno encerrado
```

## Interface de homologação criada

Como o código-fonte da tela autenticada V5.6.2 não foi localizado no repositório nem no Drive, foi criada uma pasta nova e isolada, sem substituir a versão publicada:

```text
homologacao-v5.7.2/
```

Arquivos:

```text
index.html
style.css
app.js
config.js
LEIA-ME.md
```

A interface inclui:

1. login pelo Supabase Auth;
2. Mostrar/Ocultar senha;
3. troca obrigatória da senha inicial;
4. leitura de `consultar_meu_acesso_fenix()`;
5. revenda obtida da sessão autenticada, sem seletor livre;
6. consulta do status do dia;
7. botão Entrada de carga liberado apenas com o dia aberto;
8. produto e quantidade;
9. confirmação antes da gravação;
10. chamada exata de `registrar_entrada_carga_mvp`;
11. confirmação de cheios recebidos e vazios entregues;
12. mensagem amigável para vazios insuficientes;
13. consulta do estoque calculado.

A interface passou por validação local de sintaxe JavaScript e correspondência entre os elementos usados pelo código e os IDs do HTML. Isso não substitui o teste real com Supabase e com o usuário Alex.

Nenhuma URL, chave ou senha real foi gravada no GitHub. O arquivo `config.js` permanece com placeholders.

## Ponto exato para continuar

Não reconstruir o banco nem refazer os testes de backend já aprovados. Continuar daqui:

1. copiar a URL pública e a chave anon/publishable para o `config.js` somente no ambiente de homologação;
2. publicar a pasta `homologacao-v5.7.2` em endereço HTTPS separado;
3. entrar com o usuário Alex;
4. confirmar que somente a Várzea Gás aparece;
5. usar um dia de homologação aberto para testar a entrada pela tela;
6. confirmar cheios + quantidade, vazios - quantidade e total de cascos inalterado;
7. testar pela tela uma quantidade superior aos vazios e confirmar bloqueio amigável;
8. confirmar o estoque calculado na própria tela;
9. remover os registros exclusivos de homologação somente após o teste visual aprovado;
10. integrar a operação à aplicação definitiva ou promover a pasta aprovada;
11. publicar a versão definitiva em HTTPS;
12. registrar a homologação final da V5.7.2 completa.

## Regra do estoque inicial

O estoque inicial **não será lançado antes de tudo estar concluído**.

O estoque inicial é o marco zero oficial. No momento em que ele for lançado, o controle começa imediatamente e todas as movimentações do mesmo dia deverão ser registradas no Fênix.

Sequência oficial após homologar a tela da V5.7.2:

1. publicar a versão definitiva em HTTPS;
2. confirmar o acesso do Alex;
3. definir o momento exato de início;
4. fazer a contagem física inicial da Várzea Gás;
5. lançar o estoque inicial;
6. iniciar o controle oficial no mesmo instante;
7. manter o controle atual em paralelo por cinco a sete dias;
8. encerrar cada dia somente com estoque conferido.

**Não reconstruir versões anteriores. O próximo trabalho é publicar e testar a pasta `homologacao-v5.7.2` com o usuário Alex, sem alterar a versão atualmente publicada.**
