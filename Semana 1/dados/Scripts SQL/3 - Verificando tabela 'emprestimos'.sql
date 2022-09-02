USE ANALISE_RISCO;

#Iniciando com a tabela 'emprestimos'
SELECT * FROM emprestimos;

#Criando a chave primária
DELETE FROM emprestimos WHERE loan_id = '';

ALTER TABLE emprestimos ADD CONSTRAINT 
PRIMARY KEY (loan_id);


#Verificando a coluna 'loan_intent'
SELECT loan_intent, COUNT(loan_intent) FROM emprestimos GROUP BY loan_intent;
DELETE FROM emprestimos WHERE loan_intent = '';


#Verificando a coluna 'loan_grade'
SELECT loan_grade, COUNT(loan_grade) FROM emprestimos GROUP BY loan_grade;
DELETE FROM emprestimos WHERE loan_grade = '';


# Passando para a coluna 'loan_amnt'
SELECT SUM(CASE WHEN loan_amnt is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(loan_amnt) AS 'Valores Não Nulos'
FROM emprestimos;


# Passando para a coluna 'loan_int_rate'
SELECT SUM(CASE WHEN loan_int_rate is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(loan_int_rate) AS 'Valores Não Nulos'
FROM emprestimos;


#Verificando a coluna 'loan_status'
SELECT SUM(CASE WHEN loan_status is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(loan_status) AS 'Valores Não Nulos'
FROM emprestimos;

DELETE FROM emprestimos WHERE loan_status IS NULL;

SELECT loan_status, COUNT(loan_status) FROM emprestimos GROUP BY loan_status;


#Verificando a coluna 'loan_percent_income'
SELECT SUM(CASE WHEN loan_percent_income is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(loan_percent_income) AS 'Valores Não Nulos'
FROM emprestimos;
