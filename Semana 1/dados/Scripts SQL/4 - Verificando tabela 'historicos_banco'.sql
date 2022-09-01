USE ANALISE_RISCO;

#Iniciando com a tabela 'historicos_banco'
SELECT * FROM historicos_banco;

#Criando a chave primária
DELETE FROM historicos_banco WHERE cb_id = '';

ALTER TABLE historicos_banco ADD CONSTRAINT 
PRIMARY KEY (cb_id);


#Verificando a coluna 'cb_person_default_on_file'
SELECT cb_person_default_on_file, COUNT(cb_person_default_on_file) FROM historicos_banco GROUP BY cb_person_default_on_file; 

DELETE FROM historicos_banco WHERE cb_person_default_on_file = '';


#Verificando a coluna 'cb_person_cred_hist_length'
SELECT SUM(CASE WHEN cb_person_cred_hist_length is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(cb_person_cred_hist_length) AS 'Valores Não Nulos'
FROM historicos_banco;

DELETE FROM historicos_banco WHERE cb_person_cred_hist_length IS NULL;


