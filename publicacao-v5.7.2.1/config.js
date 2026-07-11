// Projeto Fênix Estoque — configuração pública do frontend.
// Preencha somente a URL pública e a chave anon/publishable do Supabase.
// Nunca coloque service_role, senha do banco, JWT secret ou connection string aqui.
window.FENIX_CONFIG = {
  SUPABASE_URL: "COLE_AQUI_A_URL_DO_SUPABASE",
  SUPABASE_ANON_KEY: "COLE_AQUI_A_CHAVE_ANON_OU_PUBLISHABLE",

  // Trava de segurança do piloto.
  // Manter false até Marco autorizar expressamente a contagem inicial oficial.
  OPERACAO_LIBERADA: false
};
