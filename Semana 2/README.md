# [Semana 2](link)

Após a limpeza dos dados da primeira semana e da exportação para um arquivo csv, a empresa requisitou que fosse criado um modelo de machine learning capaz de prever se um empréstimo sofrerá ou não inadimplência.

Antes da criação do modelo, no entanto, será necessário adequar os dados, utilizando técnicas de *encoding*, balanceamento e também de remoção de *features* correlacionadas.

## Preparando os dados

Após as análises e remoções de linhas da semana 1, algumas informações não foram tratadas. Haviam colunas com informações em inglês e que deveriam ser traduzidas para o português. Além disso, as variáveis numéricas precisaram ser novamente analisadas para encontrar possíveis outliers.

Para isso, foram utilizadas duas bibliotecas python. A blibioteca [Pandas](https://pandas.pydata.org/) foi utilizada para importação dos dados e para manipulação dos mesmos. A bilioteca [Seaborn](https://seaborn.pydata.org/) foi usada para a criação dos gráficos boxplot.

### Traduzindo

Primeiramente as informações das colunas `tipo_imovel`, `motivo_emprestimo` e `foi_inadimplente` foram traduzidas do inglês para o português. Isso foi feito para manter a padronização dos dados, tendo em vista que os nomes das colunas também foi alterado para o português na semana anterior.

#### Colunas `tipo_imovel` e `motivo_emprestimo`

Para a coluna `tipo_imovel` foi criado um dicionário Python com as informações em inglês como chave e as traduções como valores. Após isso, foi efetuado o método [replace()](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.replace.html) para fazer a tradução dos valores.

```python
mapa = {
    'Rent': 'Aluguel',
    'Mortgage':'Hipoteca',
    'Own':'Próprio',
    'Other': 'Outro'
}

dados['tipo_imovel'].replace(mapa, inplace = True)
```

A coluna `motivo_emprestimo` foi tratada da mesma maneira.

```python
mapa = {
    'Debtconsolidation': 'Pagamento de Débitos',
    'Medical':'Médico',
    'Homeimprovement':'Melhoria do Lar',
    'Education': 'Educação',
    'Personal': 'Pessoal',
    'Venture': 'Empreendimento'
    }
    
dados['motivo_emprestimo'].replace(mapa, inplace = True)
```

#### Coluna `foi_inadimplente`

Essa coluna possuía valores `Y` e `N`. Como são valores binários, não foi efetuada uma tradução e sim uma adequação dos dados para o modelo de machine learning. Os casos onde a coluna possuía valor `Y` foram alterados para `1`, enquanto os outros casos receberam valores `0`.

```python
mapa = {
    'Y':1,
    'N':0
}

dados['foi_inadimplente'].replace(mapa, inplace = True)
```

### Verificando Outliers

Após a tradução dos dados, foi efetuada uma verificação de outliers nas colunas numéricas. Esses outliers poderiam atrapalhar o treinamento do modelo, por isso deveriam ser vistos e verificados.

Para efetuar isso, foram definidas duas funções. Uma que desenha um boxplot da coluna e outra que conta a quantidade de outliers da coluna. Após a definição, as funções foram executadas pra cada variável numérica fosse visualizada e entendida.

```python
import seaborn as sns
import matplotlib.pyplot as plt


def desenha_boxplot(coluna,dados,xlabel):
    ''' Desenha um boxplot da coluna desejada. '''
    x = coluna
    dados = dados
    titulo_x = xlabel

    plt.figure(figsize=(12, 6))

    sns.boxplot(x = x, data = dados)

    plt.title(f"Boxplot da coluna '{coluna}'")
    plt.xlabel(titulo_x)
    plt.show()
```

```python
def encontrando_outliers(coluna):
    ''' Informa a quantidade e o percentual de outliers da coluna. '''
    q1 = dados[coluna].quantile(q=0.25)
    q3 = dados[coluna].quantile(q=0.75)
    iiq = q3 - q1
    limite_inferior = q1 - 1.5 * iiq
    limite_superior = q3 + 1.5 * iiq

    outliers = dados.query(f"{coluna} < @limite_inferior | {coluna} > @limite_superior")

    total = len(dados[coluna])
    qtd_outliers = len(outliers)
    percentual = (qtd_outliers/total)*100

    print(f'Há {len(outliers)} outliers na coluna. Isso representa {percentual:.2f} %')
```

#### Lições

As variáveis `idade_pessoa`, `salario_anual`, `anos_trabalhados`, `valor_emprestimo`, `taxa_juros`, `renda_percentual`, `anos_primeiro_emprestimo` foram analisadas com as funções definidas e alguns comportamentos foram percebidos.

A coluna `taxa_juros` foi a única coluna numérica que não possuia uma forte assimetria à direita. Apesar do boxplot apresentar uma pequena assimetria, as outras colunas apresentaram uma característica de assimetria forte. Todas as colunas possuiam outliers. Esses outliers representavam entre 0.44%, para a coluna `taxa_juros`, e 5.30%, na variável `valor_emprestimo`, dos dados de cada coluna.

Após o processo de análise dos outliers, foi efetuada uma análise da correlação entre as variáveis, onde algumas colunas poderiam ser excluídas do sistema. Além disso, foram feitos também processos de encoding e normalização dos dados. Por isso os outliers não foram removidos das colunas.

### Removendo as variáveis indesejadas

Após a análise dos outliers, foi efetuada uma análise de correlação entre as variáveis. Para isso se utilizou a biblioteca [pandas-profilling](https://pypi.org/project/pandas-profiling/), que gera um relatório HTML com informações pertinentes a respeito de cada coluna. Com esse relatório foi possível definir quais colunas eram importantes para o modelo e quais poderiam ser descartadas.

Com o relatório exibido, foi possível perceber alguns comportamentos indesejados:

1 - As colunas `idade_pessoa` e `anos_primeiro_emprestimo` possuem alta correlação entre si. A coluna `anos_primeiro_emprestimo` foi mantida por conter uma quantidade menor de outliers enquanto a coluna `idade_pessoa` foi removida do modelo. 

2 - As colunas `renda_percentual` e `valor_emprestimo` possuem alta correlação entre si por possuírem dados que foram calculados com base nessas colunas. Como a coluna `renda_percentual` possuia umm número menor de outliers, ela foi mantida e a coluna `valor_emprestimo` foi removida das análises.

3 - A coluna `anos_trabalhados` possui um grande número de valores 0. Isso não é um problema, tendo em vista que muitas pessoas que recém começaram a trabalhar podem necessitar de um empréstimo.

4 - Por último as colunas `taxa_juros`, `foi_inadimplente` e `pontuacao_emprestimo` possuiam alta correlação entre si. Como a coluna `taxa_juros` possui um alto número de valores zero, ela foi excluída do modelo. Também foi removida a coluna `foi_inadimplente`.

### Aplicando Encoding nos dados

Como modelos de machine learning não conseguem entender dados textuais, é necessário aplicar técnicas de *encoding* para variáveis categóricas. Para esse modelo será utilizada a técnica de *One-Hot Encoding*.

Os computadores não sabem ler bem valores textuais, então as variáveis categóricas receberam o processo One Hot Encoder. Esse processo é melhor para modelos que serão exportados.

### Normalizando os dados numéricos.

Dados numéricos precisam entar em ordem de granzedas parecidas para o modelo trabalhar melhor. por isso foi aplicada uma normalização nas variáveis numéricas.

### Balanceando os dados

Como a variável target está desbalanceada, é necessário balancear utilizando oversampling.

## Criação e avaliação dos modelos

Com os dados preparados, é possível criar e validar os modelos de machine learning.

### Criação

Foram criados 4 modelos e um modelo dummy para comparação.

### Avaliação

Os modelos foram comparados por meio de métricas de precisão, acurácia, recall, f1 e curva roc. O melhor modelo foi escolhido e otimizado

## Otimizando e validando o melhor modelo

### Validação cruzada

Para garantir as métricas e entender o modelo, foi feito uma validação cruzada utilizando o cross_validate. Isso permitiu perceber o overfitting do modelo, por isso ele foi otimizado alterando seus hiperparametros.

### RandomizedSearchCV

Se um dia o código parar de rodar, eu consigo escrever sobre.

