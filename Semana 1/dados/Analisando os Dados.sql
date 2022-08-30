USE ANALISE_RISCO;

#Vendo frequencia de valores em casos de valores em branco
SELECT cb_person_default_on_file, count(cb_person_default_on_file) as frequency FROM historicos_banco group by cb_person_default_on_file;

#Vendo quantidade de valores nulos link = 'https://www.sqlshack.com/working-with-sql-null-values/'
SELECT SUM(CASE WHEN cb_person_cred_hist_length is null THEN 1 ELSE 0 END) AS 'Number Of Null Values', COUNT(cb_person_cred_hist_length)
AS 'Number Of Non-Null Values' FROM historicos_banco;



