USE ANALISE_RISCO;

#Iniciando com a tabela 'historicos_banco'
SELECT * FROM id;


#Verificando a coluna 'person_id'
SELECT person_id, COUNT(person_id) FROM id GROUP BY person_id ORDER BY count(person_id) desc; 

DELETE FROM historicos_banco WHERE cb_person_default_on_file = '';

#Verificando a coluna 'loan_id'
SELECT loan_id, COUNT(loan_id) FROM id GROUP BY loan_id ORDER BY count(loan_id) desc; 

#Verificando a coluna 'cb_id'
SELECT cb_id, COUNT(cb_id) FROM id GROUP BY cb_id ORDER BY count(cb_id) desc; 

#Criando as chaves estrangeiras
ALTER TABLE id
ADD CONSTRAINT FK_DADOS_MUTUARIOS 
FOREIGN KEY (person_id) REFERENCES dados_mutuarios (person_id);

#Encontrando discrepâncias
SELECT count(person_id) AS faltantes_totais FROM id 
WHERE 
	person_id not in (select person_id from dados_mutuarios) or 
    loan_id not in (select loan_id from emprestimos) or 
    cb_id not in (select cb_id from historicos_banco);
    
DELETE FROM id WHERE 
	person_id not in (select person_id from dados_mutuarios) or 
    loan_id not in (select loan_id from emprestimos) or 
    cb_id not in (select cb_id from historicos_banco);
    
#Criando as chaves estrangeiras
ALTER TABLE id
ADD CONSTRAINT FK_DADOS_MUTUARIOS 
FOREIGN KEY (person_id) REFERENCES dados_mutuarios (person_id);

ALTER TABLE id
ADD CONSTRAINT FK_EMPRESTIMOS
FOREIGN KEY (loan_id) REFERENCES emprestimos (loan_id);


ALTER TABLE id
ADD CONSTRAINT FK_HISTORICOS_BANCO
FOREIGN KEY (cb_id) REFERENCES historicos_banco (cb_id);

