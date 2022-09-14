USE ANALISE_RISCO;

#Selecionando a tabela
SELECT * FROM dados_inner;
SELECT COUNT(*) FROM DADOS_INNER;

#Tradução colunas
ALTER TABLE dados_inner
RENAME COLUMN cb_id TO hb_id,
RENAME COLUMN loan_id to em_id,
RENAME COLUMN person_id TO dm_id,
RENAME COLUMN person_age TO idade_pessoa,
RENAME COLUMN person_income TO salario_anual,
RENAME COLUMN person_home_ownership TO tipo_imovel,
RENAME COLUMN person_emp_length TO anos_trabalhados,
RENAME COLUMN loan_intent TO motivo_emprestimo,
RENAME COLUMN loan_grade TO pontuacao_emprestimo,
RENAME COLUMN loan_amnt TO valor_emprestimo,
RENAME COLUMN loan_int_rate TO taxa_juros,
RENAME COLUMN loan_status TO possibilidade_inadimplencia,
RENAME COLUMN loan_percent_income TO renda_percentual,
RENAME COLUMN cb_person_default_on_file TO foi_inadimplente,
RENAME COLUMN cb_person_cred_hist_length TO anos_primeiro_emprestimo;

# Vendo coluna `renda_percentual`
SELECT renda_percentual, valor_emprestimo, salario_anual from dados_inner
where renda_percentual is null and valor_emprestimo is not null and salario_anual is not null;

UPDATE dados_inner SET	renda_percentual = valor_emprestimo / salario_anual 
where renda_percentual is null and valor_emprestimo is not null and salario_anual is not null;

SELECT renda_percentual, valor_emprestimo, salario_anual from dados_inner
where renda_percentual is null;

DELETE FROM dados_inner where renda_percentual is null;

# vendo salario_anual
SELECT renda_percentual, valor_emprestimo, salario_anual from dados_inner
where salario_anual is null and valor_emprestimo is not null and renda_percentual is not null;

UPDATE dados_inner SET	salario_anual = valor_emprestimo / renda_percentual 
where salario_anual is null and valor_emprestimo is not null and renda_percentual is not null;

SELECT renda_percentual, valor_emprestimo, salario_anual from dados_inner
where salario_anual is null;

DELETE FROM dados_inner where salario_anual is null;


# Vendo a coluna `valor_emprestimo`
SELECT renda_percentual, valor_emprestimo, salario_anual from dados_inner
where valor_emprestimo is null and salario_anual is not null and renda_percentual is not null;

UPDATE dados_inner SET	valor_emprestimo = salario_anual * renda_percentual 
where valor_emprestimo is null and salario_anual is not null and renda_percentual is not null;

SELECT renda_percentual, valor_emprestimo, salario_anual from dados_inner
where valor_emprestimo is null;

DELETE FROM dados_inner where valor_emprestimo is null;

# Vendo a coluna `taxa_juros`
SELECT count(*) from dados_inner where taxa_juros is null