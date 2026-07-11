# RETOMAR AQUI — Projeto Fênix Estoque

**Versão homologada em produção:** V5.6.2  
**Evolução em implementação:** V5.7.2 — entrada de carga  
**Data:** 11/07/2026

## Estado homologado

- V5.4 operação multi-revenda homologada.
- V5.5 relatórios multi-revenda homologados.
- V5.6.2 login seguro homologado.
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

## Teste principal aprovado

Dia exclusivo de homologação:

```text
Várzea Gás
11/07/2099
P13
abertura: 100 cheios / 30 vazios / 130 cascos
entrada: 5 unidades
```

Resultado:

```text
105 cheios
25 vazios
130 cascos
1 lançamento
2 movimentos
movimentos vinculados = true
```

Portanto, o núcleo da regra da entrada de carga foi comprovado no Supabase.

## Bloqueio por vazios insuficientes aprovado

Com 25 vazios disponíveis, foi tentada uma entrada de 26 unidades.

Resultado:

```text
BLOQUEIO APROVADO
Vazios insuficientes. Disponível: 25, solicitado: 26.
lancamentos: 1 antes / 1 depois
movimentos: 2 antes / 2 depois
```

A operação foi recusada sem gravação parcial.

## Ponto exato para continuar

A V5.7.2 ainda não está completamente homologada. Próximas etapas:

1. confirmar o fechamento correto com 105 cheios e 25 vazios de P13;
2. integrar a tela de entrada de carga à aplicação autenticada;
3. testar a tela com o usuário Alex;
4. remover o dia e os registros exclusivos de homologação;
5. registrar a homologação final no GitHub.

## Regra do estoque inicial

O estoque inicial **não será lançado antes de tudo estar concluído**.

O estoque inicial é o marco zero oficial. No momento em que ele for lançado, o controle começa imediatamente e todas as movimentações do mesmo dia deverão ser registradas no Fênix.

Sequência oficial após homologar a V5.7.2:

1. publicar a versão definitiva em HTTPS;
2. confirmar o acesso do Alex;
3. definir o momento exato de início;
4. fazer a contagem física inicial da Várzea Gás;
5. lançar o estoque inicial;
6. iniciar o controle oficial no mesmo instante;
7. manter o controle atual em paralelo por cinco a sete dias;
8. encerrar cada dia somente com estoque conferido.

**Não reconstruir versões anteriores. Continuar exatamente da V5.6.2 homologada e concluir a homologação da V5.7.2.**