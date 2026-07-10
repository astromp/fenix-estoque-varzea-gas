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

## Próximo passo oficial

Criar a operação de **entrada de carga cheia com saída equivalente de vazios**, mantendo a regra aprovada:

```text
entrou cheio → aumenta cheio
saiu vazio → diminui vazio
mesma quantidade
```

Depois:

1. publicar a aplicação em endereço HTTPS;
2. iniciar o piloto na Várzea Gás;
3. fazer a contagem física inicial no começo do primeiro dia;
4. lançar as movimentações do mesmo dia normalmente;
5. manter o controle atual em paralelo por cinco a sete dias;
6. encerrar diariamente somente com estoque conferido.

**Não reconstruir as versões anteriores. Continuar exatamente da V5.6.2 homologada.**