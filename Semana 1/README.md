# Semana 1 - Tratamento de Dados

Para a primeira semana do challenge, a empresa disponibilizou uma cópia dump do banco de dados da empresa com as informações de alguns dados dos clientes em conjunto com um dicionário descrevendo os valores de cada coluna. Esses dados foram disponibilizados via [trello](https://trello.com/b/wjOlcef2/challenge-dados-semana-1), que também possui demandas feitas pela empresa a respeito dos dados.

Esses dados serão estudados e tratados de acordo com as demandas da empresa. Após o tratamento dos dados, eles serão exportados para um arquivo do tipo `.csv` que será utilizado para outras etapas do projeto.

## Conhecendo os dados

Com o [dump](https://github.com/vinicius-pf/Challenge-Dados/blob/Semana_1/Semana%201/dados/dump/Dump.sql) da base de dados recuperada, o primeiro passo foi conferir a integridade das informações disponibilizadas por meio de análises nas tabelas com o auxílio do [dicionário de dados disponibilizado](https://github.com/vinicius-pf/Challenge-Dados/blob/Semana_1/Semana%201/dados/Dicionario.md) pela empresa. Com as *queries* usadas, foi possível entender alguns pontos

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
DELETE FROM dados_mutuarios	WHERE person_age > 120
```

#### Coluna `person_income`

A coluna apresenta valores em branco. Porém, por se tratar de uma coluna que pode ser calculada se baseando em colunas da tabela `emprestimos`, esses dados serão mantidos e tratados novamente quando as tabelas forem unidas.

```sql
SELECT SUM(CASE WHEN person_income is null THEN 1 ELSE 0 END) AS 'Valores Nulos', COUNT(person_income) AS 'Valores Não Nulos'
FROM DADOS_MUTUARIOS;
```

img ??

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
DELETE FROM dados_mutuarios	WHERE person_emp_length > person_age;
```

Os dados em branco foram avaliados, porém não apresentaram motivo para exclusão.

img ??

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
Depois da criação das chaves secundárias, podemos passar para a união das tabelas e conferir o que faltou nas colunas `person_income`,``,`erer` e `erer`.

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
