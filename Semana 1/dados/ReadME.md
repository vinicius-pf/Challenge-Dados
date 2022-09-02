# Tratamento dos Dados

Para a primeira semana do challenge, a empresa disponibilizou uma cópia do [dump do banco de dados](https://github.com/vinicius-pf/Challenge-Dados/blob/Semana_1/Semana%201/dados/dump/Dump.sql) da empresa com as informações de alguns dados dos clientes em conjunto com um dicionário descrevendo os valores de cada coluna. Esses dados foram disponibilizados via [trello](https://trello.com/b/wjOlcef2/challenge-dados-semana-1), em conjunto com demandas feitas pela empresa a respeito dos dados.

Esses dados serão estudados e tratados de acordo com as demandas da empresa. Após o tratamento dos dados, eles serão exportados para um arquivo do tipo `.csv` que será utilizado para outras etapas do projeto.

## Conhecendo os dados

Com o [dump](https://github.com/vinicius-pf/Challenge-Dados/blob/Semana_1/Semana%201/dados/dump/Dump.sql) da base de dados recuperada, o primeiro passo foi conferir a integridade das informações disponibilizadas por meio de análises nas tabelas, e entender as informações presentes com o auxílio do [dicionário de dados disponibilizado](https://github.com/vinicius-pf/Challenge-Dados/blob/Semana_1/Semana%201/dados/Dicionario.md) pela empresa. Para isso, foram utilizadas as seguintes *queries* SQL:

```sql
select * from emprestimos;

select * from dados_mutuarios;

select * from historicos_banco;

select * from id;
```

### Tabela `dados_mutuarios`

A primeira tabela do banco de dados possui 34489 registros e 5 colunas com informações a respeito dos clientes da empresa.

| Feature | Descrição | Característica
| --- | --- | --- |
|`person_id` |ID da pessoa solicitante| Chave primária do tipo `varchar(16)`. Não possui valores em branco.
|`person_age` | Idade da pessoa - em anos - que solicita empréstimo | Coluna do tipo `int` com *outliers*.
|`person_income` | Salário anual da pessoa solicitante | Coluna do tipo `int`e com valores em branco. É utilizada para o calculo da coluna `loan_percent_income`.
|`person_home_ownership` | Situação da propriedade que a pessoa possui| Coluna do tipo `varchar(8)` com 4 valores distintos e valores em branco.
|`person_emp_length` | Tempo - em anos - que a pessoa trabalhou | Coluna do tipo `double` contendo valores em branco e *outliers*.

A coluna `person_id` não está sendo considerada como uma chave primária da tabela, o que é necessário. Além disso, é necessário entender melhor a tabela para se definir como serão tratados os dados faltantes e os *outliers* descobertos.

### Tabela `emprestimos`

A segunda tabela presente no banco de dados possue informações de cada empréstimo solicitado. Ela possui 34489 registros e 7 colunas.

| Feature | Descrição | Característica
| --- | --- | --- |
|`loan_id`| ID da solicitação de empréstico de cada solicitante | Chave primária do tipo `varchar(16)`. Não possui valores em branco.
|`loan_intent` | Motivo do empréstimo| Coluna do tipo `varchar(32)`, com 6 valores distintos e valores em branco.
|`loan_grade` | Pontuação de empréstimos | Coluna do tipo `varchar(1)`, com 7 níveis distintos e valores em branco.
|`loan_amnt` | Valor total do empréstimo solicitado | Coluna do tipo `int` contendo valores em branco.  É utilizada para o calculo da coluna `loan_percent_income`.
|`loan_int_rate` | Taxa de juros | Coluna do tipo `double` contendo valores em branco.
|`loan_status` | Possibilidade de inadimplência | Coluna do tipo `int` contendo valores em branco.
|`loan_percent_income` | Renda percentual entre o *valor total do empréstimo* e o *salário anual* | Coluna do tipo `double` com valores nulos. Pode ser calculada com as outras colunas

Novamente a coluna que deveria ser a chave primária não está configurada corretamente na tabela. Também é necessária uma análise mais detalhada para entender os valores faltantes.  

### Tabela `historicos_banco`

A terceira tabela do banco de dados 34489 registros e 3 colunas a respeito dos empréstimos realizados pela empresa.

| Feature | Descrição | Característica
| --- | --- | --- |
|`cb_id`|ID do histórico de cada solicitante| Chave primária da tabela do tipo `varchar(16)`. Não contém valores únicos.
|`cb_person_default_on_file` | Indica se a pessoa já foi inadimplente| Coluna do tipo `varchar(1)` com 2 valores distintos e valores em branco
|`cb_person_cred_hist_length` | Tempo - em anos - desde a primeira solicitação de crédito ou aquisição de um cartão de crédito | Coluna dotipo `int` e com valores em branco.

Além do tratamento da coluna que será a chave primária, também há a necessidade de entender os valores faltantes nas outras colunas.

### Tabela `id`

Essa tabela relaciona os IDs de cada tabela. Ela contém 14952 registros e 3 colunas.

| Feature | Descrição | Característica
| --- | --- | --- |
|`person_id`|ID da pessoa solicitante| Chave estrangeira relacionada com `dados_mutuarios` com valores `text`
|`loan_id`|ID da solicitação de empréstico de cada solicitante| Chave estrangeira relacionada com `emprestimos` com valores `text`
|`cb_id`|ID do histórico de cada solicitante| Chave estrangeira relacionada com `historicos_banco` com valores `text`

O tipo das colunas não corresponde aos tipos das colunas nas outras tabelas, o que precisará ser corrigido. Além disso, as colunas devem ser chaves estrangeiras para corrigir o relacionamento do banco de dados.

## Verificando e corrigindo inconsistências

Com as primeiras análises concluídas, pode-se começar a próxima etapa. Nessa etapa as colunas serão conferidas individualmente para corrigir dados faltantes ou com informações que não poderiam ser consideradas.

### Tabela `dados_mutuarios`

#### Coluna `person_id`

A coluna deve ser configurada como chave primária da tabela. No entanto, ao criar e executar a *query* SQL para isso, ocorreu um erro. 

![1](https://user-images.githubusercontent.com/6025360/187917589-784df3cd-114b-4bea-92b2-26258d4427c2.png)

Esse erro se deu pelo fato de haver 4 registros com essa coluna em branco. Nesse caso, por se tratar de um número muito pequeno em relação a quantidade de registros da tabela, esses registros serão deletados e depois será definida a chave primária.

```sql
SELECT * FROM DADOS_MUTUARIOS where person_id = '';
```

![2](https://user-images.githubusercontent.com/6025360/187917633-0fe8057c-8218-4ed3-83cc-3c79f1ed5ccf.png)

```sql
DELETE FROM DADOS_MUTUARIOS WHERE PERSON_ID = '';

ALTER TABLE DADOS_MUTUARIOS ADD CONSTRAINT 
PRIMARY KEY (person_id);
```

#### Coluna `person_age`

Primeiramente é necessário entender os valores nulos presentes na coluna. Aparentemente esses dados podem ser considerados como MCAR(Missing Completely at Random), o que será confirmado ao se comparar a distribuição de frequências.

Para confirmar o caso, é necessário comparar a frequência de registros de uma coluna no dataset completo com a frequência da mesma coluna considerando apenas os valores em branco. A coluna utilizada será a `person_home_ownership`. Primeiro foi efetuada a consulta com todos os valores para saber qual a frequencia global

```sql
SELECT person_home_ownership, COUNT(person_home_ownership) FROM DADOS_MUTUARIOS GROUP BY person_home_ownership; 
```

![3](https://user-images.githubusercontent.com/6025360/187920100-c1e77040-c88f-466e-b5fb-bcea63e70d82.png)

Após isso, foi efetuada a query novamente, dessa vez com filtro considerando apenas os usuários com registros vazios.

```sql
SELECT person_home_ownership, COUNT(person_home_ownership) FROM DADOS_MUTUARIOS where person_age IS NULL GROUP BY person_home_ownership; 
```

![4](https://user-images.githubusercontent.com/6025360/187920143-3ea1fa1e-4400-495c-8b28-77753d90f235.png)

Comparando os valores, percebeu-se que os dados possuem distribução parecida com o dado completo. Por conta disso, os dados serão considerados como MCAR e serão excluidos do banco de dados. 

```sql
DELETE FROM dados_mutuarios WHERE person_age IS NULL;
```

Além dos dados faltantes, também há valores que podem estar equivocados. Há pessoas no sistema com 144 e 123 anos, o que pode indicar erro de digitação. Como são 5 registros, esses também serão excluidos do sistema

```sql
SELECT person_age, COUNT(person_age) AS CONTAGEM FROM dados_mutuarios GROUP BY person_age ORDER BY person_age DESC
```

![5](https://user-images.githubusercontent.com/6025360/187920404-5ceea8ba-452b-4105-911c-2b211edbe5a8.png)

```sql
DELETE FROM dados_mutuarios WHERE person_age > 120
```

#### Coluna `person_income`

A coluna apresenta valores em branco. Porém, por se tratar de uma coluna que pode ser calculada se baseando em colunas da tabela `emprestimos`, esses dados serão mantidos e tratados novamente quando as tabelas forem unidas.

```sql
SELECT SUM(CASE WHEN person_income is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(person_income) AS 'Valores Não Nulos'
FROM DADOS_MUTUARIOS;
```

![19](https://user-images.githubusercontent.com/6025360/188207594-40d79b0e-d8c3-494c-8b8d-67492689505e.png)

#### Coluna `person_home_ownership`

Essa coluna possue 4 valores distintos: `Rent`,`Mortgage`,`Own` e `Other`. Além disso, há dados em branco nessa coluna também que precisam ser tratados. Como a categoria `Other` existe, os dados em branco serão trocados para essa categoria. Essa escolha pode trazer problemas futuros, tendo em vista que há mais valores em branco que os da categoria `Other`. Isso será informado à empresa e caso necessário a etapa será refeita.

```sql
UPDATE dados_mutuarios SET person_home_ownership = 'Other' WHERE person_home_ownership = '';
```

![6](https://user-images.githubusercontent.com/6025360/187922757-4f6e60c5-8d30-4325-8302-fb7d62d057de.png)

#### Coluna 'person_emp_length'

Nessa coluna há 1213 valores nulos, além de valores que não deviam ser possíveis. Há casos em que essa coluna, que mostra o tempo de serviço do cliente, é maior que a coluna idade. Como essa característica aparece só em 2 casos, eles serão excluídos da base de dados.

```sql
SELECT * FROM DADOS_MUTUARIOS WHERE person_emp_length > person_age
```

![7](https://user-images.githubusercontent.com/6025360/187924026-59e1a99b-395e-490a-951d-47b853b7dc0e.png)

```sql
DELETE FROM dados_mutuarios WHERE person_emp_length > person_age;
```

Os dados em branco foram avaliados, porém por representarem uma grande quantidade de dados, eles foram mantidos e poderão ser removidos em análises futuras.

Ao final do tratamento dos dados a tabela ficou com 34158 registos.

### Tabela `emprestimos`

#### Coluna `loan_id`

Essa coluna é a chave primária da tabela. O tratamento utilizado foi o mesmo da tabela `dados_mutuarios`. Como não foram encontrados valores em branco ou duplicados, não ocorreu erro na execução da *query*.

```sql
ALTER TABLE emprestimos ADD CONSTRAINT 
PRIMARY KEY (loan_id);
```

#### Coluna `loan_intent`

Essa coluna novamente apresenta categorias nos registros e contém valores em branco. Como são 312 registros, eles serão excluidos da tabela.

```sql
SELECT loan_intent, COUNT(loan_intent) FROM emprestimos GROUP BY loan_intent; 
DELETE FROM emprestimos WHERE loan_intent = '';
```

![8](https://user-images.githubusercontent.com/6025360/187928366-5f31ad5f-8929-4f97-811c-f6c109fef49c.png)

#### Coluna `loan_grade`

Assim como a coluna anterior, essa é uma coluna com dados categóricos e possui 276 regisros em branco, que serão excluídos.

```sql
SELECT loan_grade, COUNT(loan_grade) FROM emprestimos GROUP BY loan_grade;
```

![9](https://user-images.githubusercontent.com/6025360/187928940-4bdd6736-cd4e-487b-a531-8202564cceb9.png)


#### Coluna `loan_amnt`

Essa coluna possui valores em branco. No entanto, essa coluna pode ser calculada utilizando a coluna `loan_percent_income` e a coluna `person_income` na tabela `dados_mutuarios`, por isso os valores não serão excluidos no momento e serão tratados novamente após a união das tabelas.

```sql
SELECT SUM(CASE WHEN loan_amnt is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(loan_amnt) AS 'Valores Não Nulos'
FROM emprestimos;
```

![10](https://user-images.githubusercontent.com/6025360/187929605-0235f961-d81a-43d0-ba07-c8d8c54b1cd4.png)


#### Coluna `loan_int_rate`

Apesar de possuir valores em branco, ela apresenta um número elevado de valores faltantes. Esses valores serão mantidos e avaliados novamente após a união das tabelas.

```sql
SELECT SUM(CASE WHEN loan_int_rate is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(loan_int_rate) AS 'Valores Não Nulos'
FROM emprestimos;
```

![11](https://user-images.githubusercontent.com/6025360/187929686-4124d7e9-fbfd-410e-be9e-38fedb6f8c18.png)

#### Coluna `loan_status`

Essa coluna categórica apresenta 325 valores nulos que serão excluídos da base de dados.

```sql
SELECT SUM(CASE WHEN loan_status is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(loan_status) AS 'Valores Não Nulos'
FROM emprestimos;
```

![12](https://user-images.githubusercontent.com/6025360/187930433-a79762a3-1581-4608-afc5-c7dccf08adc8.png)

#### Coluna `loan_percent_income`

Essa coluna apresenta valores em branco que serão recalculados de acordo com as colunas `loan_amnt` e `person_income`.

```sql
SELECT SUM(CASE WHEN loan_percent_income is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(loan_percent_income) AS 'Valores Não Nulos'
FROM emprestimos;
```

![13](https://user-images.githubusercontent.com/6025360/187930633-02683b03-9894-4c59-88d9-f5a2a20a5ce0.png)

Ao final do tratamento, a tabela ficou com 33598 registos.

### Tabela `historicos_banco`

#### Coluna `cb_id`

Após garantir que não haveriam valores em branco, essa coluna foi alterada para ser a chave primária do sistema.

```sql
ALTER TABLE historicos_banco ADD CONSTRAINT 
PRIMARY KEY (cb_id);
```

#### Coluna `cb_person_default_on_file`

Essa coluna apresentou 367 regisros em branco que foram deletados por representarem uma quatidade pequena.

```sql
SELECT cb_person_default_on_file, COUNT(cb_person_default_on_file) FROM historicos_banco GROUP BY cb_person_default_on_file; 
DELETE FROM historicos_banco WHERE cb_person_default_on_file = '';
```

![14](https://user-images.githubusercontent.com/6025360/187931275-ee5b9e00-f4cf-419c-85a0-e7a0a9041124.png)

#### Coluna `cb_person_cred_hist_length`

Nesta coluna havia apenas um registro sem valor, por isso ele foi excluído.

```sql
SELECT SUM(CASE WHEN cb_person_cred_hist_length is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(cb_person_cred_hist_length) AS 'Valores Não Nulos'
FROM historicos_banco;

DELETE FROM historicos_banco WHERE cb_person_cred_hist_length IS NULL;
```

![15](https://user-images.githubusercontent.com/6025360/187931638-2290998e-392b-4419-ad67-8452ab92040a.png)

Ao final do tratamento, a tabela ficou com 34121 registros.

### Tabela `id`

Essa tabela relaciona as outras 3 tabelas entre si e as colunas são chaves estrangeiras que se conectam com as chaves primárias de cada tabela. Ao tentar criar as chaves estrangeiras, um erro aconteceu por haver inconsistência de dados entre as tabelas. Haviam alguns registros na tabela ID que não estavam nas outras tabelas. Ao executar o script, foi percebido que haviam 571 dados que deveriam ser excluídos.

```sql
SELECT count(person_id) AS faltantes_totais FROM id 
WHERE 
	person_id not in (select person_id from dados_mutuarios) or 
    loan_id not in (select loan_id from emprestimos) or 
    cb_id not in (select cb_id from historicos_banco);
```

![16](https://user-images.githubusercontent.com/6025360/187933767-10a77723-120b-49e6-9d26-7712495d3250.png)

Após a exclusão dos dados, também foi necessário alterar o tipo de dados das colunas. Na tabela `id` as colunas estavam com o tipo `TEXT` que foi alterado para o tipo `VARCHAR(16)` e coincidir com o tipo correto das colunas. Essa mudança foi feito por meio do assitente visual do MySQL. Com o tipo alterado e os dados inválidos retirados, foi possível criar as chaves primárias.

![20](https://user-images.githubusercontent.com/6025360/188207686-73d46c37-bf4b-4ab0-98b5-0052d042796b.png)

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

![17](https://user-images.githubusercontent.com/6025360/187934322-aecbcd6c-e291-4be2-9b91-620c2cd5b7be.png)

Com as configurações de chaves primárias e estrangeiras criadas, o relacionamento do banco de dados foi completo.

![18](https://user-images.githubusercontent.com/6025360/187934507-0917273f-ec06-4a41-8469-0a9ca38aa83f.png)

Após as correções, a tabela ficou com 14381 registros.

### Próximos passos

Com os dados corrigidos e o relacionamento criado, é possível efetuar a união das tabelas em uma única tabela contendo a informação de todos os empréstimos feitos por clientes do banco. As colunas `person_income`,`loan_amnt`, `loan_int_rate`, `loan_percent_income` não receberam tratamento completo e serão avaliadas novamente.

## Unindo tabelas

As tabelas serão unidas e o resultado da união será armazenado em um outra tabela. Isso permitirá reavaliar a junção das tabelas caso seja necessário. Para isso foi utilizado o INNER JOIN, que retorna apenas os registros presentes nas duas tabelas de acordo com a coluna de junção. 


```sql
CREATE TABLE dados_inner (SELECT * FROM dados_mutuarios dm 
INNER JOIN id id USING (person_id)
INNER JOIN emprestimos em USING (loan_id) 
INNER JOIN historicos_banco hb USING (cb_id))
```

Como a tabela `id` possue um número de registros menor que as outras colunas, essa tabela de união também recebeu menos registros, terminando com 14381 valores. Caso seja necessário, podem ser feitos outros tipos de JOIN. 

## Corrigindo inconsistências da tabela de união

### Traduzindo 
Para traduzir as colunas, foi utilizado o dicionário da empresa para definir o melhor nome para cada coluna de acordo com a tradução literal e o significado da coluna para a base de dados.

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

#### Coluna `renda_percentual`
Essa coluna pode ser calculada utilizando as colunas `salario_anual` e `valor_emprestimo`. Os dados que estavam em branco foram corrigidos se a pessoa possuía as duas informações. Em 27 casos não foi possível inserir os dados e por isso os registros foram excluídos da tabela.

```sql
UPDATE dados_inner SET	renda_percentual = valor_emprestimo / salario_anual 
where renda_percentual is null and valor_emprestimo is not null and salario_anual is not null;

DELETE FROM dados_inner where renda_percentual is null;
```

#### Coluna `salario_anual`

Assim como a coluna anterior, esta coluna pode ser calculada utilizando outras colunas da tabela. Após o cálculo, ainda haviam 11 registros em branco que foram excluídos.

```sql
UPDATE dados_inner SET	salario_anual = valor_emprestimo / renda_percentual 
where salario_anual is null and valor_emprestimo is not null and renda_percentual is not null;

DELETE FROM dados_inner where salario_anual is null;
```

#### Coluna `valor_emprestimo`

Novamente a coluna pode ser calculada utilizando as outras colunas da tabela. Após essa etapa, não houveram mais dados em branco na coluna para serem excluídos.

```sql
UPDATE dados_inner SET	valor_emprestimo = salario_anual * renda_percentual 
where valor_emprestimo is null and salario_anual is not null and renda_percentual is not null;

DELETE FROM dados_inner where valor_emprestimo is null;
```

#### Coluna `taxa_juros`

A coluna não pode ser tratada anteriormente por possuir um alto valor de registros nulos. Apesar da união ter excluído dados, esses valores nulos se mantiveram em alto percentual e serão mantidos no sistema no momento.

```sql
SELECT count(*) from dados_inner where taxa_juros is null
```

![image](https://user-images.githubusercontent.com/6025360/188207750-0fab8a4c-7187-420b-a15a-d203455379ac.png)

Após a limpeza das colunas calculadas, a base de dados ficou com 14343 registros.

## Exportando 'csv'
Para as próximas etapas do projeto, será necessário exportar a tabela de união para um arquivo csv. Para isso foi utilizado o assistente do MySQL. Durante a exortação foram excluídas as colunas `dm_id`, `em_id` e `hb_id` por possuírem alta cardinalidade. A tabela final pode ser conferida [aqui](link)
