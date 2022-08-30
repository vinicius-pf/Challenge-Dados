# Semana 1

Para a primeira semana do challenge, a empresa disponibilizou uma cópia dump do banco de dados da empresa com as informações de alguns dados dos clientes em conjunto com um dicionário descrevendo os valores de cada coluna. Esses dados foram disponibilizados via [trello](https://trello.com/b/wjOlcef2/challenge-dados-semana-1), que também possui demandas feitas pela empresa a respeito dos dados.

## Entendendo os dados

Após o dump do banco de dados ser recuperado, foram feitas query sql.

```sql
select * from emprestimos;

select * from dados_mutuarios;

select * from historicos_banco;

select * from id;
```

O resultado das queries foi verificado em conjunto com o dicionário para cada tabela. isso ajudou a entender alguns pontos. 

### Tabela `dados_mutuarios`

Tabela contendo os dados pessoais de cada solicitante

| Feature | Descrição | Característica
| --- | --- | --- |
|`person_id` |ID da pessoa solicitante| Chave primária do tipo `varchar(16)`. Não possue valores em branco
|`person_age` | Idade da pessoa - em anos - que solicita empréstimo | Tipo `int`. Há pessoas com idade superior a 100 anos.
|`person_income` | Salário anual da pessoa solicitante | Tipo `int`. Há valores em branco
|`person_home_ownership` | Situação da propriedade que a pessoa possui| A empresa informou que haviam 4 valores distintos do tipo `varchar(8)`. Essa coluna apresenta valores vazios.
|`person_emp_length` | Tempo - em anos - que a pessoa trabalhou | Tipo `double`. Há casos com 123 anos trabalhados e valores em branco.

### Tabela `emprestimos`

Tabela contendo as informações do empréstimo solicitado

| Feature | Descrição | Característica
| --- | --- | --- |
|`loan_id`| ID da solicitação de empréstico de cada solicitante | Chave primária do tipo varchar(16)
|`loan_intent` | Motivo do empréstimo| Há 6 valores do tipo `varchar(32)` distintos e a coluna possue valores vazios.
|`loan_grade` | Pontuação de empréstimos, por nível variando de `A` a `G` | Há 7 níveis distintos e há valores em branco.
|`loan_amnt` | Valor total do empréstimo solicitado |
|`loan_int_rate` | Taxa de juros |
|`loan_status` | Possibilidade de inadimplência |
|`loan_percent_income` | Renda percentual entre o *valor total do empréstimo* e o *salário anual* |


### historicos_banco

Histório de emprétimos de cada cliente

| Feature | Descrição | Característica
| --- | --- | --- |
|`cb_id`|ID do histórico de cada solicitante|
| `cb_person_default_on_file` | Indica se a pessoa já foi inadimplente: sim (`Y`,`YES`) e não (`N`,`NO`) |
| `cb_person_cred_hist_length` | Tempo - em anos - desde a primeira solicitação de crédito ou aquisição de um cartão de crédito |

### id

Tabela que relaciona os IDs de cada informação da pessoa solicitante

| Feature | Descrição | Característica
| --- | --- | --- |
|`person_id`|ID da pessoa solicitante|
|`loan_id`|ID da solicitação de empréstico de cada solicitante|
|`cb_id`|ID do histórico de cada solicitante|

## Inconcistencias

## Unindo tabelas

## Exportando 'csv'
