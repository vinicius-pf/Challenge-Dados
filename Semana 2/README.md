# [Semana 2](link)

Para a semana 2, a empresa requisitou um modelo de machine learning capaz de prever se um empréstimo sofrerá inadimplencia ou não.

## Preparando os dados

Para preparar os dados, será necessário traduzir alguns registros que não foram traduzidos na semana 1. Além disso, também é necessário analisar possíveis outliers que não foram percebidos durante os tratamentos em SQL.

### Traduzindo

Haviam colunas com valores em ingles. Esses valores foram traduzidos para o português.

### Verificando Outliers

Nas colunas numéricas foram verificados os outliers por meio de boxplot e cálculo matemático. Todas as colunas numéricas continham outliers. Esses não foram tratados por haver colunas correlacionadas.

### Removendo as variáveis indesejadas

As variáveis foram verificadas com a biblioteca pandas_profilling. Utilizando ela deu-se para perceber como as variáveis estão correlacionadas e excluir informações possivelmente dúbias no sistema.

### Aplicando Encoding nos dados

Os computadores não sabem ler bem valores textuais, então as variáveis categóricas receberam o processo One Hot Encoder. Esse processo é melhor para modelos que serão exportados.

### Normalizando os dados numéricos.

Dados numéricos precisam entar em ordem de granzedas parecidas para o modelo trabalhar melhor. por isso foi aplicada uma normalização nas variáveis numéricas.

### Balanceando os dados

Como a variável target está desbalanceada, é necessário balancear utilizando oversampling.

## Criação e avaliação dos modelos

### Criação

### Avaliação

## Otimizando e validando o melhor modelo

### Validação cruzada

### RandomizedSearchCV
