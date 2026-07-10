# Projeto Fênix Estoque — Registro oficial V5.4 e V5.5

**Data da homologação:** 10/07/2026  
**Responsável pela validação operacional:** Marco Antonio Vicensio  
**Regra central:** estoque fechado, turno encerrado; estoque inconsistente, revisar até corrigir.

## 1. Situação consolidada

As versões V5.4 e V5.5 foram homologadas com sucesso.

- V5.4 — operação multi-revenda: homologada.
- V5.5 — relatórios gerenciais multi-revenda: homologada.
- Segregação por revenda: confirmada no banco.
- Canais por revenda: confirmados.
- Exportação CSV: confirmada para Várzea Gás e Vinhedo Gás.
- Impressão gerencial: confirmada.

## 2. Revendas cadastradas

- Itatiba Gás — Itatiba/SP.
- Várzea Gás — Várzea Paulista/SP.
- Vicensio 14 — Jundiaí/SP.
- Vicensio Caxambu — Jundiaí/SP.
- Vinhedo Gás — Vinhedo/SP.

## 3. Canais cadastrados por revenda

### Itatiba Gás
- Portaria
- Giovanni

### Várzea Gás
- André
- João
- Portaria
- Rogério
- Outros — inativo

### Vicensio 14
- Paulo
- Antonio Marcos
- Durvalino
- Ederson
- Adevaldo
- Richard
- Celio
- Carlos
- Helio
- Várzea
- Itatiba
- Vinhedo
- Buriti
- Caxambu
- Portaria 14
- Outros

### Vicensio Caxambu
- Portaria
- Roberto
- Adriano

### Vinhedo Gás
- Jackson
- Gilson
- Portaria
- Outros

## 4. V5.4 — Operação multi-revenda

### Problema identificado

As funções operacionais antigas não recebiam `revenda_id` e procuravam literalmente a revenda `Várzea Gás`. Isso criava risco de lançamentos de outras unidades serem gravados na Várzea.

### Correção aplicada

Foram criadas sobrecargas das sete funções operacionais, todas exigindo `p_revenda_id`:

- `consultar_estoque_mvp(uuid, date)`
- `consultar_status_dia_mvp(uuid, date)`
- `consultar_vendas_dia_mvp(uuid, date)`
- `registrar_abertura_mvp(uuid, date, jsonb)`
- `registrar_correcao_venda_casco_mvp(uuid, date, text, text, integer)`
- `registrar_fechamento_mvp(uuid, date, jsonb)`
- `registrar_venda_mvp(uuid, date, text, text, integer, integer)`

Todas permanecem com `SECURITY DEFINER` e validam a revenda ativa.

### Arquivo oficial

- `sql/funcoes-operacionais-multirrevenda-v5.4.sql`

### Mudanças na tela operacional

- seleção obrigatória da revenda;
- carregamento dinâmico dos canais da unidade;
- envio de `p_revenda_id` em todas as operações;
- retirada dos atalhos fixos de Portaria e João;
- bloqueio das operações sem revenda selecionada;
- abertura, venda, estoque, fechamento, correção e status separados por unidade.

### Teste de segregação confirmado

Consulta realizada para 10/07/2026:

| Revenda | Status | Lançamentos | Movimentos |
|---|---:|---:|---:|
| Várzea Gás | fechado | 2 | 3 |
| Vinhedo Gás | fechado | 1 | 1 |

Conclusão: a operação da Vinhedo foi gravada na `revenda_id` correta e não alterou o histórico da Várzea.

## 5. V5.5 — Relatórios gerenciais multi-revenda

### Recursos homologados

- consulta por período personalizado;
- filtro por canal;
- filtro por produto;
- resumo de lançamentos, produtos, cascos e correções;
- agrupamento por canal;
- agrupamento por produto;
- detalhamento das vendas;
- exportação CSV;
- impressão gerencial.

Toda consulta usa `p_revenda_id` e a função `consultar_vendas_dia_mvp(uuid, date)`.

### CSV homologado — Vinhedo Gás

Data: 10/07/2026.

- Canal: Gilson.
- Produto: P13.
- Quantidade vendida: 5.
- Cascos vendidos: 0.
- Tipo: venda.

Conclusão: o CSV da Vinhedo não trouxe dados da Várzea.

### CSV homologado — Várzea Gás

Data: 10/07/2026.

- Portaria — P13 — 10 produtos — 0 cascos.
- João — P13 — 10 produtos — 1 casco.

Totais:

- 2 lançamentos;
- 20 produtos vendidos;
- 1 casco vendido.

Conclusão: o CSV da Várzea não trouxe dados da Vinhedo.

### Impressão gerencial homologada

Foi validado o PDF `Comparação gerencial`, com:

- identificação da Várzea Gás;
- períodos A e B;
- lançamentos;
- produtos vendidos;
- cascos vendidos;
- linhas de correção;
- comparação por canal;
- comparação por produto;
- percentuais e diferenças;
- quebra correta em duas páginas.

Observação visual: o navegador pode incluir `about:blank`, data, hora e título no cabeçalho/rodapé. Para retirar, desmarcar `Cabeçalhos e rodapés` na janela de impressão.

## 6. Resultado final da homologação

- Operação separada por revenda: aprovada.
- Canais separados: aprovados.
- Banco protegido por `revenda_id`: aprovado.
- Relatórios separados: aprovados.
- CSV separado: aprovado.
- Impressão gerencial: aprovada.
- Histórico da Várzea preservado: confirmado.

## 7. Ponto exato para retomada

O Projeto Fênix Estoque está encerrado e homologado até a V5.5.

Na próxima evolução, partir deste ponto, sem reconstruir as etapas já aprovadas. Prioridades possíveis:

1. consolidar os arquivos V5.4 e V5.5 na tela principal oficial;
2. bloquear ou retirar as assinaturas antigas sem `revenda_id`, depois de confirmar que nenhuma tela ainda as utiliza;
3. revisar autenticação e permissões por usuário/revenda;
4. iniciar a implantação operacional nas demais revendas, uma unidade por vez;
5. criar rotina de backup e auditoria.

## 8. Regra de continuidade

Não alterar as regras operacionais homologadas sem autorização expressa de Marco. Toda nova versão deve preservar:

- separação integral por revenda;
- canais próprios de cada unidade;
- estoque por cheios, vazios e cascos;
- fechamento obrigatório sem pendências;
- alerta e revisão de inconsistência;
- histórico já existente.
