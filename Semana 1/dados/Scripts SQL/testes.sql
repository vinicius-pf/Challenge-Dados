USE ANALISE_RISCO;

SELECT loan_amnt, count(loan_amnt) as frequency FROM emprestimos group by loan_amnt;