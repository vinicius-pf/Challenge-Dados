# Semana 1

Para a primeira semana do challenge, a empresa disponibilizou uma cópia dump do banco de dados da empresa com as informações de alguns dados dos clientes em conjunto com um dicionário descrevendo os valores de cada coluna. Esses dados foram disponibilizados via [trello](https://trello.com/b/wjOlcef2/challenge-dados-semana-1), que também possui demandas feitas pela empresa a respeito dos dados.

## Conhecendo os dados

Após o dump do banco de dados ser recuperado, foram feitas query sql.

```sql
select * from emprestimos;

select * from dados_mutuarios;

select * from historicos_banco;

select * from id;
```

O resultado das queries foi verificado em conjunto com o dicionário para cada tabela. isso ajudou a entender alguns pontos. 

### Tabela `dados_mutuarios`

Essa tabela contém os dados pessoais de cada solicitante. Ela possue 34489 registros e 5 colunas.

| Feature | Descrição | Característica
| --- | --- | --- |
|`person_id` |ID da pessoa solicitante| Chave primária do tipo `varchar(16)`. Não possue valores em branco
|`person_age` | Idade da pessoa - em anos - que solicita empréstimo | Tipo `int`. Há pessoas com idade superior a 100 anos.
|`person_income` | Salário anual da pessoa solicitante | Tipo `int`. Há valores em branco
|`person_home_ownership` | Situação da propriedade que a pessoa possui| A empresa informou que haviam 4 valores distintos do tipo `varchar(8)`. Essa coluna apresenta valores vazios.
|`person_emp_length` | Tempo - em anos - que a pessoa trabalhou | Tipo `double`. Há casos com 123 anos trabalhados e valores em branco.

A coluna `person_id` não está sendo considerada como uma chave primária da tabela, o que é necessário. Além disso, é necessário entender melhor a tabela para se definir como serão tratados os dados faltantes e os *outliers* descobertos..

### Tabela `emprestimos`

Essa tabela contém informações de cada empréstimo solicitado. Ela possue 34489 registros e 7 colunas.

| Feature | Descrição | Característica
| --- | --- | --- |
|`loan_id`| ID da solicitação de empréstico de cada solicitante | Chave primária do tipo `varchar(16)`
|`loan_intent` | Motivo do empréstimo| Há 6 valores do tipo `varchar(32)` distintos e a coluna possue valores vazios.
|`loan_grade` | Pontuação de empréstimos | Há 7 níveis distintos do tipo `varchar(1)` e há valores em branco.
|`loan_amnt` | Valor total do empréstimo solicitado | Uma coluna do tipo `int` possuindo valores nulos
|`loan_int_rate` | Taxa de juros | Uma coluna `double` possuindo valores nulos
|`loan_status` | Possibilidade de inadimplência | Coluna `int` com registros nulos.
|`loan_percent_income` | Renda percentual entre o *valor total do empréstimo* e o *salário anual* | Coluna `double` com valores nulos

Novamente a coluna que deveria ser a chave primária não está configurada como tal na tabela. Também é necessária uma análise mais detalhada para entender os valores faltantes.  

### Tabela `historicos_banco`

Essa tabela detalha os dados dos empréstimo de cada cliente. Ela possue 34489 registros e 3 colunas.

| Feature | Descrição | Característica
| --- | --- | --- |
|`cb_id`|ID do histórico de cada solicitante| Chave primária da tabela. Não contém valores únicos.
|`cb_person_default_on_file` | Indica se a pessoa já foi inadimplente| Coluna do tipo `varchar(1)` com 2 valores distintos e valores em branco
|`cb_person_cred_hist_length` | Tempo - em anos - desde a primeira solicitação de crédito ou aquisição de um cartão de crédito | Coluna tipo `int` com um valor em branco.

A primeira coluna necessita ser configurada como chave primária. Além disso, as outras colunas também requerem atenção para efetuar o melhor tratamento.

### Tabela `id`

Essa tabela relaciona os IDs de cada tabela. Ela contém 14952 registros e 3 colunas.

| Feature | Descrição | Característica
| --- | --- | --- |
|`person_id`|ID da pessoa solicitante| Chave estrangeira relacionada com `dados_mutuarios` com valores `text`
|`loan_id`|ID da solicitação de empréstico de cada solicitante| Chave estrangeira relacionada com `emprestimos` com valores `text`
|`cb_id`|ID do histórico de cada solicitante| Chave estrangeira relacionada com `historicos_banco` com valores `text`

Essa tabela precisa receber as chaves primárias das outras tabelas e armazenar como chaves estrangeiras.

Após a conclusão da análise das tabelas, percebeu-se a necessidade de tratamento dos dados dentro das tabelas, além de acrescentar chaves nas tabelas. 

## Verificando e corrigindo inconsistências

Após a análise, foi possível investigar mais a fundo cada tabela para que as inconsistências fossem encontradas e tratadas da melhor maneira.

### Tabela `dados_mutuarios`

#### Coluna `person_id`

Primeiramente foi tentada a criação da chave primária para a tabela. No entanto ocorreu um erro.

img 1

Esse erro se deu pelo fato de haver 4 registros com essa coluna em branco. Nesse caso, por se tratar de um número muito pequeno em relação a quantidade de registros da tabela, esses registros serão deletados e depois será definida a chave primária.

```sql
SELECT * FROM DADOS_MUTUARIOS where person_id = '';
```

img 2

```sql
DELETE FROM DADOS_MUTUARIOS WHERE PERSON_ID = '';

ALTER TABLE DADOS_MUTUARIOS ADD CONSTRAINT 
PRIMARY KEY (person_id);
```

#### Coluna `person_age`

Como a coluna possui registros nulos, é necessário entender o motivo dos dados estarem faltando. Para isso, podemos utilizar uma outra coluna do dataset e comparar a frequência de ocorrencia dos valores dessa outra coluna. Para isso, foi utilizada a coluna `person_home_ownership`. Primeiro foi efetuada a consulta com todos os valores para saber qual a frequencia global

```sql
SELECT person_home_ownership, COUNT(person_home_ownership) FROM DADOS_MUTUARIOS GROUP BY person_home_ownership; 
```

img 3

Após isso, foi efetuada a query novamente, dessa vez com filtro considerando apenas os usuários com registros vazios.

```sql
SELECT person_home_ownership, COUNT(person_home_ownership) FROM DADOS_MUTUARIOS where person_age IS NULL GROUP BY person_home_ownership; 
```

img 4

Comparando os valores, percebeu-se que os dados possuem distribução parecida com o dado completo. Por conta disso, os dados serão considerados como MCAR e serão excluidos do banco de dados. 

```sql
DELETE FROM dados_mutuarios WHERE person_age IS NULL;
```

Ao verificar as idades das pessoas, se percebeu que há valores que podem estar errados. Há pessoas no sistema com 144 e 123 anos, o que pode indicar erro de digitação. Como são 5 registros, esses também serão excluidos do sistema

```sql
SELECT person_age, COUNT(person_age) AS CONTAGEM FROM dados_mutuarios GROUP BY person_age ORDER BY person_age DESC
```

img 5

```sql
DELETE FROM dados_mutuarios	WHERE person_age > 120
```

#### Coluna `person_income`

Ao se fazer a mesma estratégia da coluna anterior, a frequencia trazida foi diferente da apresentada pelo total. Isso significa que pode haver algum fator fazendo com que esses dados estejam em branco. Por enquanto esses valores serão mantidos na tabela.

#### Coluna `person_home_ownership`

Essa coluna possue 4 valores distintos: `Rent`,`Mortgage`,`Own` e `Other`. Além disso, há dados em branco nessa coluna também que precisam ser tratados. Como a categoria `Other` existe, os dados em branco serão trocados para essa categoria. Como existem mais dados em branco do que dados da categoria `Other`, pode existir um conflito ou um problema no momento das análises gráficas.

```sql
UPDATE dados_mutuarios SET person_home_ownership = 'Other' WHERE person_home_ownership = '';
```

img 6

#### Coluna 'person_emp_length'

Há 1213 valores nulos, além de valores estranhos. Como se trata de tempo de serviço, há dois valores em que a coluna está maior que a coluna de idade, o que não deveria ser permitido, por isso os dados serão excluidos da tabela.

```sql
SELECT * FROM DADOS_MUTUARIOS WHERE person_emp_length > person_age
```

img 7

```sql
DELETE FROM dados_mutuarios	WHERE person_emp_length > person_age;
```

Os dados em branco receberam o mesmo tratamento da coluna `person_age`. Novamente, por não apresentar uma frequencia parecida com a original, os dados em branco estão mantidos até reavaliados.

### Tabela `emprestimos`

#### Coluna `loan_id`

Essa coluna é a chave primária, então necessitou garantir que não haviam valores em branco ou duplicados. Após isso, a coluna foi definida como chave primária.

```sql
ALTER TABLE emprestimos ADD CONSTRAINT 
PRIMARY KEY (loan_id);
```


#### Coluna `loan_intent`

Ha coluna possue categorias de escolhas, contendo valores em branco. Esses valores são 312 regisros e serão excluidos sistema.  

```sql
SELECT loan_intent, COUNT(loan_intent) FROM emprestimos GROUP BY loan_intent; 
DELETE FROM emprestimos WHERE loan_intent = '';
```

img 8

#### Coluna `loan_grade`

Assim como a anterior, essa possue poussue 310 regisros em branco que serão excluídos.

```sql
SELECT loan_grade, COUNT(loan_grade) FROM emprestimos GROUP BY loan_grade;
```

img 9


#### Coluna `loan_amnt`

Essa coluna possue valores vazios. No entanto, ela pode ser calculada considerando-se outras colunas. Isso será feito após a união de todas as tabelas.

```sql
SELECT SUM(CASE WHEN loan_amnt is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(loan_amnt) AS 'Valores Não Nulos'
FROM emprestimos;
```

img 10 


#### Coluna `loan_int_rate`

Assim como a coluna anterior, essa coluna valores vazios. Porém eles compõe uma parte grande da base de dados, por isso serão mantidos no sistema.

```sql
SELECT SUM(CASE WHEN loan_int_rate is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(loan_int_rate) AS 'Valores Não Nulos'
FROM emprestimos;
```

img 11

#### Coluna `loan_status`

Essa coluna possue valores nulos que não podem ser calculados. 325 deles. por isso eles serão deletados

```sql
SELECT SUM(CASE WHEN loan_status is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(loan_status) AS 'Valores Não Nulos'
FROM emprestimos;
```

img 12

#### Coluna `loan_percent_income`

Mais uma coluna calculável com valores nulos que serão tratados posteriormente.

```sql
```

img 13


### Tabela `historicos_banco`

#### Coluna `cb_id`

Coluna que foi definida como chave primária do sistema

```sql
ALTER TABLE historicos_banco ADD CONSTRAINT 
PRIMARY KEY (cb_id);
```

#### Coluna `cb_person_default_on_file`

Coluna com valorews em branco que foram deletados.

```sql
SELECT cb_person_default_on_file, COUNT(cb_person_default_on_file) FROM historicos_banco GROUP BY cb_person_default_on_file; 
DELETE FROM historicos_banco WHERE cb_person_default_on_file = '';
```

img 14

#### Coluna `cb_person_cred_hist_length`
Havia apenas um valor nulo que foi excluido

```sql
```

img 15


### Tabela `id`

Primeiro tentei fazer as chaves estrangeiras, depois deu erro porque o tinha duplicata. Teve que deletar 571 coisas.

```sql
```
img 16

Depois de fazer isso e deletar, deu de fazer as chaves estrangeiras

```sql
ALTER TABLE id
ADD CONSTRAINT FK_DADOS_MUTUARIOS 
FOREIGN KEY (person_id) REFERENCES dados_mutuarios (person_id);

ALTER TABLE id
ADD CONSTRAINT FK_EMPRESTIMOS
FOREIGN KEY (loan_id) REFERENCES emprestimos (loan_id);


ALTER TABLE id
ADD CONSTRAINT FK_HISTORICOS_BANCO
FOREIGN KEY (cb_id) REFERENCES historicos_banco (cb_id);
```

img 17

Com isso o relacionamento correto foi configurado no sistema

img 18


### Próximos passos
Depois da criação das chaves secundárias, podemos passar para a união das tabelas e conferir o que faltou nas colunas ``,``,`erer` e `erer`.

## Unindo tabelas

Para unir as tabelas, foram utilizadas as chaves primária e estrangeiras. Para isso se seguiu o relacionamento

Para unir as tabelas, foi criada uma tabela que receberá os valores.

```sql
CREATE TABLE dados_inner (SELECT * FROM dados_mutuarios dm 
INNER JOIN id id USING (person_id)
INNER JOIN emprestimos em USING (loan_id) 
INNER JOIN historicos_banco hb USING (cb_id))
```

14381 registros totais

##Corrigindo

### Traduzindo 
usei rename

```sql
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
```

Apesar do nome das colunas ter sido traduzido, os registros em lingua inglesa não foram. Isso será efetuado quando a empresa requisitar as visualizações.

### Encontrando valores em branco

#### coluna `renda_percentual`
Corrigiu os que dava, os que não deu, deletou: 27

```sql
UPDATE dados_inner SET	renda_percentual = valor_emprestimo / salario_anual 
where renda_percentual is null and valor_emprestimo is not null and salario_anual is not null;

DELETE FROM dados_inner where renda_percentual is null;
```

#### coluna `salario anual`
Corrigiu os que dava, os que não deu, deletou: 11

```sql
UPDATE dados_inner SET	salario_anual = valor_emprestimo / renda_percentual 
where salario_anual is null and valor_emprestimo is not null and renda_percentual is not null;

DELETE FROM dados_inner where salario_anual is null;
```

#### coluna `valor emprestimo`
Corrigiu o que dava e acabou com os nulos
```sql
UPDATE dados_inner SET	salario_anual = valor_emprestimo / renda_percentual 
where salario_anual is null and valor_emprestimo is not null and renda_percentual is not null;

DELETE FROM dados_inner where salario_anual is null;
```

## Exportando 'csv'

Após a transformação dos dados, a tabela foi exporta para um arquivo csv que servirá como base para as visualizações futuras.
