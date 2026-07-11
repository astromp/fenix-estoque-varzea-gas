# RETOMAR AQUI — Projeto Fênix Estoque

**Versão homologada em produção:** V5.6.2  
**Backend homologado no Supabase:** V5.7.2 — entrada de carga  
**Integração visual pendente:** tela autenticada  
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

Arquivos principais:

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

## Ponto exato para continuar

Não reconstruir banco nem refazer testes já aprovados. Continuar daqui:

1. localizar a aplicação autenticada V5.6.2 atualmente publicada/usada no piloto;
2. integrar uma tela ou botão `Entrada de carga`;
3. campos obrigatórios: data operacional, produto e quantidade;
4. usar a revenda da sessão autenticada, sem permitir escolha de outra revenda pelo operador;
5. chamar `registrar_entrada_carga_mvp(p_revenda_id, p_data_operacional, p_produto_codigo, p_quantidade)`;
6. exibir confirmação clara: quantidade de cheios recebidos e vazios entregues;
7. exibir erro de vazios insuficientes sem linguagem técnica;
8. testar a tela com o usuário Alex;
9. remover os registros do dia exclusivo de homologação somente depois do teste da tela;
10. publicar a versão definitiva em HTTPS;
11. registrar a homologação final da V5.7.2 completa.

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

**Não reconstruir versões anteriores. O próximo trabalho é exclusivamente a integração da entrada de carga à tela autenticada V5.6.2.**