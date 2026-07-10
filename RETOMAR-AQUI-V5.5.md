# RETOMAR AQUI — Projeto Fênix Estoque

**Versão atual homologada:** V5.5  
**Data:** 10/07/2026

## Estado do projeto

- V5.4 operação multi-revenda homologada.
- V5.5 relatórios multi-revenda homologados.
- Todas as operações novas exigem `p_revenda_id`.
- Várzea Gás e Vinhedo Gás foram testadas e permaneceram segregadas.
- CSV de ambas as unidades foi validado.
- Impressão gerencial foi validada.

## Evidência principal

Em 10/07/2026:

- Várzea Gás: fechado, 2 lançamentos, 3 movimentos.
- Vinhedo Gás: fechado, 1 lançamento, 1 movimento.

## Arquivos essenciais

- `sql/funcoes-operacionais-multirrevenda-v5.4.sql`
- `docs/homologacao-v5.4-v5.5-multirrevenda-10072026.md`

## Próximo passo recomendado

Consolidar a V5.5 como versão oficial da aplicação e, somente depois de verificar que nenhuma tela antiga depende delas, bloquear as funções sem `revenda_id`.

**Não reconstruir as versões anteriores. Continuar exatamente deste ponto.**
