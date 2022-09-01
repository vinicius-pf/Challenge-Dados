USE ANALISE_RISCO;

# Selecionando a tabela 1
SELECT * FROM dados_mutuarios dm 
INNER JOIN id id USING (person_id)
INNER JOIN emprestimos em USING (loan_id) 
INNER JOIN historicos_banco hb USING (cb_id);

#Criando a tabela 1
DROP TABLE IF EXISTS dados_inner;

CREATE TABLE dados_inner (SELECT * FROM dados_mutuarios dm 
INNER JOIN id id USING (person_id)
INNER JOIN emprestimos em USING (loan_id) 
INNER JOIN historicos_banco hb USING (cb_id))