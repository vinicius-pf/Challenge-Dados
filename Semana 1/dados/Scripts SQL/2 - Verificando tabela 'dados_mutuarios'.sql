USE ANALISE_RISCO;

#Iniciando com a tabela 'dados_mutuarios'
SELECT * FROM DADOS_MUTUARIOS;

#Criando a chave primária
DELETE FROM DADOS_MUTUARIOS WHERE PERSON_ID = '';

ALTER TABLE DADOS_MUTUARIOS ADD CONSTRAINT 
PRIMARY KEY (person_id);


#Verificando a coluna 'person_age'
SELECT person_age, COUNT(person_age) FROM DADOS_MUTUARIOS GROUP BY person_age; 
SELECT SUM(CASE WHEN person_age is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(person_age) AS 'Valores Não Nulos'
FROM DADOS_MUTUARIOS;
SELECT * FROM DADOS_MUTUARIOS where person_age IS NULL;

#Verificando frequencia em comparação com outra coluna
SELECT person_home_ownership, COUNT(person_home_ownership) FROM DADOS_MUTUARIOS GROUP BY person_home_ownership; 
SELECT person_home_ownership, COUNT(person_home_ownership) FROM DADOS_MUTUARIOS where person_age IS NULL GROUP BY person_home_ownership;

#Excluindo dados nulos de 'person_age'
DELETE FROM dados_mutuarios WHERE person_age IS NULL;

#Vendo mais 'person_age'
SELECT person_age, COUNT(person_age) AS CONTAGEM FROM dados_mutuarios GROUP BY person_age ORDER BY person_age DESC;
DELETE FROM dados_mutuarios	WHERE person_age > 120;


#Verificando a coluna 'person_income'
SELECT SUM(CASE WHEN person_income is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(person_income) AS 'Valores Não Nulos'
FROM DADOS_MUTUARIOS;

#Verificando frequencia em comparação com outra coluna
SELECT person_home_ownership, COUNT(person_home_ownership) FROM DADOS_MUTUARIOS GROUP BY person_home_ownership; 
SELECT person_home_ownership, COUNT(person_home_ownership) FROM DADOS_MUTUARIOS where person_income IS NULL GROUP BY person_home_ownership;


# Passando para a coluna 'person_home_ownership'
SELECT person_home_ownership, COUNT(person_home_ownership) FROM DADOS_MUTUARIOS GROUP BY person_home_ownership; 

# Alterando valores em branco pra other
UPDATE dados_mutuarios SET person_home_ownership = 'Other' WHERE person_home_ownership = '';




#Verificando a coluna 'person_emp_length'
SELECT person_emp_length, COUNT(person_emp_length) FROM DADOS_MUTUARIOS GROUP BY person_emp_length; 

SELECT SUM(CASE WHEN person_emp_length is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(person_emp_length) AS 'Valores Não Nulos'
FROM DADOS_MUTUARIOS;

SELECT * FROM DADOS_MUTUARIOS WHERE person_emp_length > person_age;

DELETE FROM dados_mutuarios	WHERE person_emp_length > person_age;

#Verificando frequencia em comparação com outra coluna
SELECT person_home_ownership, COUNT(person_home_ownership) FROM DADOS_MUTUARIOS GROUP BY person_home_ownership; 

SELECT person_home_ownership, COUNT(person_home_ownership) FROM DADOS_MUTUARIOS where person_emp_length IS NULL GROUP BY person_home_ownership;


