# RETOMAR AQUI — Projeto Fênix Estoque

**Versão atual homologada:** V5.6.2  
**Data:** 10/07/2026

## Estado do projeto

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

Para as sete funções operacionais multi-revenda:

```text
authenticated_pode_executar = true
anon_pode_executar = false
public_pode_executar = false
```

A tela autenticada mostrou corretamente:

- `Alex · operador/conferente`;
- botão Sair;
- Várzea Gás selecionada automaticamente e bloqueada;
- sessão conectada;
- status do dia consultado corretamente;
- opção Mostrar/Ocultar senha.

## Evidência multi-revenda principal

Em 10/07/2026:

- Várzea Gás: fechado, 2 lançamentos, 3 movimentos.
- Vinhedo Gás: fechado, 1 lançamento, 1 movimento.

## Arquivos essenciais

- `sql/funcoes-operacionais-multirrevenda-v5.4.sql`
- `docs/homologacao-v5.4-v5.5-multirrevenda-10072026.md`
- `docs/homologacao-v5.6.2-login-seguro-10072026.md`

## Tarefa oficial de amanhã — 11/07/2026

Criar e testar a operação de **entrada de carga cheia com saída equivalente de vazios**.

Regra obrigatória:

```text
entrou cheio → aumenta cheio
saiu vazio → diminui vazio
mesma quantidade
estoque total de cascos permanece estável
```

Escopo de amanhã:

1. criar a função segura no banco exigindo `p_revenda_id` e usuário autorizado;
2. criar a tela de entrada de carga;
3. registrar produto e quantidade;
4. gerar os dois movimentos vinculados: `entrada_cheia` e saída equivalente de vazios;
5. impedir quantidade maior de vazios do que o saldo disponível;
6. testar na Várzea Gás com dados de homologação;
7. confirmar reflexo correto no estoque calculado e no fechamento;
8. registrar a homologação no GitHub.

## Regra do estoque inicial

O estoque inicial **não será lançado antes de tudo estar concluído**.

O estoque inicial é o marco zero oficial. No momento em que ele for lançado, o controle começa imediatamente e todas as movimentações do mesmo dia deverão ser registradas no Fênix.

Portanto, a sequência oficial será:

1. concluir e homologar a entrada de carga;
2. publicar a versão definitiva em HTTPS;
3. confirmar o acesso do Alex;
4. definir o momento exato de início;
5. fazer a contagem física inicial da Várzea Gás;
6. lançar o estoque inicial;
7. iniciar o controle oficial no mesmo instante;
8. manter o controle atual em paralelo por cinco a sete dias;
9. encerrar cada dia somente com estoque conferido.

**Não reconstruir as versões anteriores. Continuar exatamente da V5.6.2 homologada e iniciar pela entrada de carga.**