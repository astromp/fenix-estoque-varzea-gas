# Modelo de Dados do Estoque — Projeto Fênix Estoque / Várzea Gás

Este documento define o modelo inicial de banco de dados para transformar as regras operacionais do Projeto Fênix Estoque em sistema.

O objetivo é guardar abertura, lançamentos, vendas, venda de casco, fechamento, divergências e correções de forma simples, rastreável e conferível.

## 1. Princípios do modelo

O banco de dados deve respeitar estas regras:

```text
Entrada: cheio sobe, vazio desce.
Venda do líquido: cheio desce, vazio sobe.
Venda de casco: só existe junto com venda do líquido e reduz o total de cascos.
Fechamento: calculado x físico.
Estoque inconsistente não encerra o dia.
```

O modelo deve permitir:

- abrir o dia com contagem física;
- lançar entradas;
- lançar vendas do líquido;
- lançar venda de casco vinculada à venda do líquido;
- separar vendas por canal/personagem;
- calcular estoque esperado;
- registrar fechamento físico;
- apontar divergências;
- corrigir lançamentos;
- manter histórico.

## 2. Tabelas principais

Modelo inicial sugerido:

```text
revendas
produtos
canais_venda
usuarios
dias_operacionais
conferencias_abertura
itens_conferencia_abertura
lancamentos
movimentos_estoque
fechamentos
itens_fechamento
divergencias_fechamento
correcoes
```

## 3. Tabela: revendas

Guarda as revendas/unidades do Projeto Fênix.

Campos sugeridos:

```text
id
nome
cidade
ativa
criado_em
atualizado_em
```

Exemplo inicial:

```text
id: 1
nome: Várzea Gás
cidade: Várzea Paulista/SP
ativa: sim
```

## 4. Tabela: produtos

Guarda os produtos controlados no estoque.

Campos sugeridos:

```text
id
codigo
nome
tipo
controla_cheio_vazio
ativo
ordem_exibicao
criado_em
atualizado_em
```

Produtos iniciais:

```text
P13
P05
P20
P45
Água/galão
Outros
```

Observação: o P05 entrou na simulação operacional e deve ser incluído como produto controlado quando existir na revenda.

Tipos possíveis:

```text
botijao
galao_agua
outro
```

## 5. Tabela: canais_venda

Guarda os canais/personagens de venda.

Campos sugeridos:

```text
id
revenda_id
nome
ativo
ordem_exibicao
criado_em
atualizado_em
```

Canais iniciais da Várzea Gás:

```text
André
João
Rogério
Portaria
Outros
```

Regra obrigatória:

```text
Portaria é canal de venda.
```

Portaria não deve ser tratada como portão físico, retirada, conferência ou etapa intermediária.

## 6. Tabela: usuarios

Guarda quem usa o sistema.

No desenho atual da Várzea Gás, o mesmo usuário pode:

```text
lançar
conferir
corrigir
fechar
```

Campos sugeridos:

```text
id
nome
telefone
email
perfil
ativo
criado_em
atualizado_em
```

Perfis possíveis, mesmo que no início a mesma pessoa faça tudo:

```text
operador
conferente
administrador
```

## 7. Tabela: dias_operacionais

Representa o dia de trabalho da revenda.

Como definido:

```text
Abertura: conferência de manhã.
Fechamento: uma vez por dia, à noite.
```

Campos sugeridos:

```text
id
revenda_id
data_operacional
status
aberto_por_usuario_id
aberto_em
fechado_por_usuario_id
fechado_em
observacao
```

Status possíveis:

```text
aberto
em_fechamento
inconsistente
fechado
```

Regra:

```text
Só pode fechar se todos os produtos estiverem conferidos.
```

## 8. Tabela: conferencias_abertura

Guarda a conferência física da manhã.

Campos sugeridos:

```text
id
dia_operacional_id
revenda_id
usuario_id
data_hora
status
observacao
```

Status possíveis:

```text
registrada
revisada
cancelada
```

## 9. Tabela: itens_conferencia_abertura

Guarda a contagem física inicial por produto.

Campos sugeridos:

```text
id
conferencia_abertura_id
produto_id
cheios_fisicos
vazios_fisicos
total_fisico
observacao
```

Regra:

```text
total_fisico = cheios_fisicos + vazios_fisicos
```

Exemplo da simulação:

```text
P13: 100 cheios / 30 vazios / total 130
P05: 10 cheios / 5 vazios / total 15
P20: 10 cheios / 2 vazios / total 12
P45: 10 cheios / 10 vazios / total 20
Água/galão: 50 cheios / 10 vazios / total 60
```

## 10. Tabela: lancamentos

Representa o cabeçalho de uma operação lançada no sistema.

Um lançamento pode agrupar um ou mais movimentos.

Exemplos:

```text
Venda do João: 10 P13, sendo 1 com casco.
```

Esse lançamento pode gerar:

```text
movimento 1: venda do líquido de 10 P13
movimento 2: venda de casco de 1 P13 vinculada ao mesmo lançamento
```

Campos sugeridos:

```text
id
dia_operacional_id
revenda_id
usuario_id
canal_venda_id
tipo_lancamento
data_hora
status
observacao
```

Tipos de lançamento:

```text
entrada
venda
ajuste
correcao
```

Status possíveis:

```text
ativo
corrigido
cancelado
```

Observação:

- em lançamentos de venda, o canal/personagem deve ser obrigatório;
- em lançamentos de entrada, o canal/personagem pode ficar vazio.

## 11. Tabela: movimentos_estoque

Esta é a tabela central da movimentação do estoque.

Cada registro representa o efeito operacional de uma movimentação sobre um produto.

Campos sugeridos:

```text
id
lancamento_id
dia_operacional_id
revenda_id
produto_id
canal_venda_id
usuario_id
tipo_movimento
quantidade
movimento_vinculado_id
status
observacao
criado_em
corrigido_em
cancelado_em
```

Tipos de movimento:

```text
entrada_cheia
venda_liquido
venda_casco
ajuste_entrada
ajuste_saida
correcao
```

## 12. Efeito de cada tipo de movimento

## entrada_cheia

```text
cheio += quantidade
vazio -= quantidade
total_cascos não muda
```

## venda_liquido

```text
cheio -= quantidade
vazio += quantidade
total_cascos não muda
```

## venda_casco

```text
vazio -= quantidade
total_cascos -= quantidade
```

Regra obrigatória:

```text
venda_casco só pode existir se houver venda_liquido no mesmo lançamento ou vinculada à venda do líquido.
```

Trava obrigatória:

```text
quantidade_venda_casco <= quantidade_venda_liquido
```

## 13. Como representar venda com casco

Exemplo:

```text
João vendeu 10 P13, sendo 1 com casco.
```

Registro em `lancamentos`:

```text
tipo_lancamento: venda
canal_venda: João
```

Registros em `movimentos_estoque`:

```text
movimento 1:
produto: P13
tipo_movimento: venda_liquido
quantidade: 10

movimento 2:
produto: P13
tipo_movimento: venda_casco
quantidade: 1
movimento_vinculado_id: movimento 1
```

Resultado no estoque:

```text
cheios -10
vazios +9
total de cascos -1
```

## 14. Tabela: fechamentos

Guarda o fechamento da noite.

Campos sugeridos:

```text
id
dia_operacional_id
revenda_id
usuario_id
data_hora_inicio
data_hora_fim
status
observacao
```

Status possíveis:

```text
em_andamento
conferido
inconsistente
corrigido_apos_revisao
cancelado
```

Regra:

```text
Fechamento inconsistente não encerra o dia operacional.
```

## 15. Tabela: itens_fechamento

Guarda a contagem física final por produto e a comparação com o calculado.

Campos sugeridos:

```text
id
fechamento_id
produto_id
cheios_calculados
vazios_calculados
total_calculado
cheios_fisicos
vazios_fisicos
total_fisico
diferenca_cheios
diferenca_vazios
diferenca_total
status
observacao
```

Fórmulas:

```text
total_calculado = cheios_calculados + vazios_calculados
total_fisico = cheios_fisicos + vazios_fisicos

diferenca_cheios = cheios_fisicos - cheios_calculados
diferenca_vazios = vazios_fisicos - vazios_calculados
diferenca_total = total_fisico - total_calculado
```

Status possíveis:

```text
conferido
inconsistente
corrigido
```

## 16. Tabela: divergencias_fechamento

Guarda o diagnóstico das divergências.

Campos sugeridos:

```text
id
fechamento_id
item_fechamento_id
produto_id
tipo_divergencia
diferenca_cheios
diferenca_vazios
diferenca_total
hipotese_provavel
prioridade_revisao
status
criado_em
resolvido_em
```

Tipos de divergência:

```text
diferenca_cheio
diferenca_vazio
diferenca_total_cascos
divergencia_combinada
```

Status possíveis:

```text
pendente
em_revisao
resolvida
sem_conclusao
```

## 17. Regra de diagnóstico inteligente

Regra aprendida na simulação:

```text
Cheio a menos + vazio igual + total menor = provável venda com casco não lançada.
```

Em termos de diferença:

```text
diferenca_cheios < 0
diferenca_vazios = 0
diferenca_total < 0
```

Hipótese provável:

```text
venda de casco não lançada
```

Exemplo da simulação:

```text
P45 calculado: 7 cheios / 13 vazios / total 20
P45 físico: 6 cheios / 13 vazios / total 19

Diferença:
cheios: -1
vazios: 0
total: -1

Hipótese:
1 P45 vendido com casco e não lançado como venda de casco.
```

## 18. Tabela: correcoes

Guarda correções realizadas após divergência.

Campos sugeridos:

```text
id
divergencia_id
lancamento_original_id
movimento_original_id
usuario_id
tipo_correcao
descricao
lancamento_correcao_id
movimento_correcao_id
criado_em
```

Tipos de correção:

```text
corrigir_quantidade
corrigir_produto
corrigir_canal
adicionar_venda_casco
adicionar_venda_liquido
cancelar_lancamento
```

Exemplo:

```text
Divergência: P45 com 1 cheio a menos e vazio igual.
Correção provável: adicionar venda de casco de 1 P45 se a venda do líquido já estava lançada.
```

## 19. Cálculo do estoque esperado

O estoque esperado de cada produto deve partir da abertura da manhã.

Fórmulas:

```text
cheios_calculados = cheios_abertura + entradas_cheias - vendas_liquido + ajustes_cheio
```

```text
vazios_calculados = vazios_abertura - entradas_cheias + vendas_liquido - vendas_casco + ajustes_vazio
```

```text
total_calculado = cheios_calculados + vazios_calculados
```

Para a primeira versão, se possível, evitar ajustes manuais livres. Correções devem ser preferencialmente vinculadas ao lançamento errado.

## 20. Validações obrigatórias

O banco/sistema deve impedir:

- quantidade menor ou igual a zero;
- produto inexistente;
- canal inexistente em venda;
- venda sem canal/personagem;
- venda de casco sem venda do líquido;
- venda de casco maior que venda do líquido;
- fechamento com produto inconsistente;
- fechamento sem contagem física de todos os produtos ativos.

## 21. Exemplo da simulação no modelo

## Abertura

Criar 1 registro em `dias_operacionais`:

```text
revenda: Várzea Gás
data_operacional: 07/07/2026
status: aberto
```

Criar 1 registro em `conferencias_abertura`.

Criar itens em `itens_conferencia_abertura`:

```text
P13: 100 cheios / 30 vazios
P05: 10 cheios / 5 vazios
P20: 10 cheios / 2 vazios
P45: 10 cheios / 10 vazios
Água: 50 cheios / 10 vazios
```

## Vendas

Criar lançamentos por canal/personagem:

```text
Portaria: vendas de P13, P05, P20 e P45
Rogério: vendas de P13, P20 e P45
André: venda de P13
João: venda de P13 com 1 casco
```

Criar movimentos correspondentes em `movimentos_estoque`.

## Fechamento

Criar 1 registro em `fechamentos`.

Criar itens em `itens_fechamento`:

```text
P13: conferido
P05: conferido
P20: conferido
P45: inconsistente
Água: conferido
```

Criar divergência em `divergencias_fechamento` para P45:

```text
tipo_divergencia: divergencia_combinada
diferenca_cheios: -1
diferenca_vazios: 0
diferenca_total: -1
hipotese_provavel: provável venda de casco não lançada
status: pendente
```

## 22. Próximo passo

Depois deste modelo de dados, o próximo passo é criar o modelo de telas do lançamento diário, principalmente:

- abertura da manhã;
- lançamento de venda;
- lançamento de entrada;
- correção de divergência;
- fechamento da noite.
