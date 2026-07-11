# RETOMAR AQUI — Projeto Fênix Estoque

**Versão homologada em produção:** V5.6.2  
**Backend homologado no Supabase:** V5.7.2 — entrada de carga  
**Interface V5.7.2:** fluxo principal aprovado; bloqueio visual e publicação definitiva pendentes  
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

## Backend aprovado no Supabase

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

Conclusão do backend:

```text
backend da entrada de carga homologado
regra de cascos confirmada
bloqueio sem gravação parcial confirmado
reflexo correto no fechamento confirmado
estoque fechado, turno encerrado
```

## Interface de homologação

Pasta isolada, sem substituir a versão publicada:

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

Nenhuma URL, chave ou senha real foi gravada no GitHub. O arquivo `config.js` permanece com placeholders.

## Fluxo principal da interface aprovado

Dia de teste visual:

```text
Várzea Gás
12/07/2099
status: aberto
produto: P13
entrada: 5 unidades
```

A própria tela de estoque calculado mostrou:

```text
P13 = 105 cheios / 25 vazios / total 130
P05 = 10 cheios / 5 vazios / total 15
P20 = 10 cheios / 2 vazios / total 12
P45 = 10 cheios / 10 vazios / total 20
AGUA = 50 cheios / 10 vazios / total 60
```

Conclusão visual:

```text
entrada pela interface chegou ao Supabase
cheios +5
vazios -5
total de cascos preservado
produtos não envolvidos permaneceram inalterados
```

Evidência registrada em:

```text
docs/validacao-interface-entrada-carga-v5.7.2-11072026.md
```

## Ponto exato para continuar

Não reconstruir o banco nem refazer os testes já aprovados. Continuar daqui:

1. manter a data operacional de homologação `12/07/2099` aberta;
2. pela própria interface, tentar registrar `26 P13`, quando existem `25` vazios;
3. confirmar mensagem amigável de vazios insuficientes;
4. consultar novamente o estoque e confirmar que permanece `105 cheios / 25 vazios / total 130`;
5. registrar a prova visual do bloqueio;
6. remover os registros exclusivos de homologação de `11/07/2099` e `12/07/2099` somente depois da prova;
7. promover ou integrar a interface aprovada à aplicação definitiva;
8. publicar a versão definitiva em HTTPS;
9. registrar a homologação final da V5.7.2 completa.

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

**Não reconstruir versões anteriores. O próximo trabalho é exclusivamente o teste visual de vazios insuficientes na interface V5.7.2.**