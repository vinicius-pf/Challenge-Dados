USE analise_risco;

#Verificando o import
SELECT * FROM dados_mutuarios;
SELECT * FROM emprestimos;
SELECT * FROM historicos_banco;
SELECT * FROM id;

#Contando quantidade de registros das tabelas
SELECT COUNT(*) AS 'QUANTIDADE DE REGISTROS' FROM dados_mutuarios;
SELECT COUNT(*) AS 'QUANTIDADE DE REGISTROS' FROM emprestimos;
SELECT COUNT(*) AS 'QUANTIDADE DE REGISTROS' FROM historicos_banco;
SELECT COUNT(*) AS 'QUANTIDADE DE REGISTROS' FROM id;
