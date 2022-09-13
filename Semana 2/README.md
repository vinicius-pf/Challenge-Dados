# [Semana 2](link)

Após a [limpeza dos dados da primeira semana e da exportação para um arquivo csv](https://github.com/vinicius-pf/Challenge-Dados/tree/main/Semana%201), a empresa requisitou que fosse criado um modelo de machine learning supervisionado capaz de prever se um empréstimo sofrerá ou não inadimplência.

Antes da criação do modelo, no entanto, será necessário adequar os dados, utilizando técnicas de *encoding*, balanceamento e também de remoção de *features* correlacionadas.

Além a criação do modelo, a empresa também requisitou que o mesmo fosse exportado como um arquivo pickle, permitindo assim uso do modelo em outras aplicações.

## Preparando os dados

Primeiramente os [dados gerados após a semana 1](https://github.com/vinicius-pf/Challenge-Dados/blob/main/Semana%201/dados/dados_inner.csv) foram importados utilizando a biblioteca [Pandas](https://pandas.pydata.org/).

```python
import pandas as pd

url = 'https://raw.githubusercontent.com/vinicius-pf/Challenge-Dados/Semana_2/Semana%202/dados/dados_inner.csv'

dados = pd.read_csv(url, sep = ';')
dados.head()
```

img 1

Algumas informações não passaram por processo de tradução. As colunas `tipo_imovel`, `motivo_emprestimo` e `foi_inadimplente` possuiam informações em inglês que foram traduzidas. Além disso, as variáveis numéricas precisaram ser novamente analisadas para encontrar possíveis *outliers*.

### Traduzindo

Primeiramente as informações necessárias foram traduzidas do inglês para o português. Isso foi feito para manter a padronização dos dados, tendo em vista que os nomes das colunas também foram alterados para o português durante o tratamento dos dados em SQL.

#### Colunas `tipo_imovel` e `motivo_emprestimo`

Para a coluna `tipo_imovel` foi criado um dicionário Python com as informações em inglês como chave e as traduções como valores. Após isso, foi efetuado o método [replace()](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.replace.html) para fazer a tradução dos registros.

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

### Verificando *Outliers*

Após a tradução dos dados, foi efetuada uma verificação de *outliers* nas colunas numéricas. Esses valores poderiam atrapalhar o treinamento do modelo, por isso deveriam ser vistos e verificados.

Para realizar isso, foram definidas duas funções. Uma que retorna um [boxplot](https://seaborn.pydata.org/generated/seaborn.boxplot.html) da coluna e a outra conta a quantidade de outliers da coluna. Após a definição, as funções foram executadas pra cada variável numérica fosse visualizada e entendida.

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

As variáveis `idade_pessoa`, `salario_anual`, `anos_trabalhados`, `valor_emprestimo`, `taxa_juros`, `renda_percentual`, `anos_primeiro_emprestimo` foram analisadas com as funções definidas e alguns comportamentos similares foram percebidos.

A coluna `taxa_juros` foi a única coluna numérica que não possuia uma forte assimetria à direita, apesar do boxplot apresentar uma pequena assimetria. As outras colunas apresentaram uma característica de assimetria forte. Todas as colunas possuiam outliers. Esses outliers representavam entre 0.44%, para a coluna `taxa_juros`, e 5.30%, na variável `valor_emprestimo`, dos dados de cada coluna.

A baixa quantidade de *outliers* para a coluna `taxa_juros` e a sua assimetria mais fraca podem se dar ao fato de haver muitos valores `0` na coluna. Em análises posteriores, foi percebido que essa alta quantidade de valores `0` corresponde a quantidade de valores nulos na base de dados SQL.

Após o processo de análise dos outliers, foi efetuada uma análise da correlação entre as variáveis, onde algumas colunas poderiam ser excluídas do sistema. Além disso, foram feitos também processos de encoding e normalização dos dados. Por isso os outliers não foram removidos das colunas.

### Removendo as variáveis indesejadas

Após a análise dos outliers, foi efetuada uma análise de correlação entre as variáveis. Para isso se utilizou a biblioteca [pandas-profilling](https://pypi.org/project/pandas-profiling/), que gera um [relatório HTML](link relatorio) com informações pertinentes a respeito de cada coluna. Com esse relatório foi possível definir quais colunas eram importantes para o modelo e quais poderiam ser descartadas.

Com o relatório exibido, foi possível perceber alguns comportamentos indesejados:

1 - As colunas `idade_pessoa` e `anos_primeiro_emprestimo` possuem alta correlação entre si. A coluna `anos_primeiro_emprestimo` foi mantida por conter uma quantidade menor de *outliers* enquanto a coluna `idade_pessoa` foi removida do modelo. 

2 - As colunas `renda_percentual` e `valor_emprestimo` possuem alta correlação entre si. Como a coluna `renda_percentual` possuia um número menor de *outliers*, ela foi mantida e a coluna `valor_emprestimo` foi removida das análises.

3 - A coluna `anos_trabalhados` possui um grande número de valores 0. Isso não é um problema, tendo em vista que muitas pessoas que recém começaram a trabalhar podem necessitar de um empréstimo.

4 - Por último as colunas `taxa_juros`, `foi_inadimplente` e `pontuacao_emprestimo` possuiam alta correlação entre si. Como a coluna `taxa_juros` possui um alto número de valores zero, ela foi excluída do modelo. Também foi removida a coluna `foi_inadimplente`.

### Aplicando Encoding nos dados

Como modelos de machine learning não conseguem entender dados textuais, é necessário aplicar técnicas de *encoding* para variáveis categóricas. Para esse modelo adotou-se a técnica de *One-Hot Encoding*. Como a empresa deseja exportar o modelo de machine learning, a biblioteca sklearn disponilibiliza o módulo [One Hot Encoder](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.OneHotEncoder.html).

```python
from sklearn.compose import make_column_transformer
from sklearn.preprocessing import OneHotEncoder

colunas_categoricas = ['tipo_imovel', 'motivo_emprestimo', 'pontuacao_emprestimo']

one_hot_enc = make_column_transformer(
    (OneHotEncoder(handle_unknown = 'ignore'),
    colunas_categoricas),
    remainder='passthrough')

dados_encode = one_hot_enc.fit_transform(dados)
dados_encode = pd.DataFrame(dados_encode, columns=one_hot_enc.get_feature_names_out())
```

A aplicação da técnica de One Hot cria colunas adicionais para cada categoria nas variáveis categóricas. Por isso o dataset aumentou de 12 para 26 colunas.

### Normalizando os dados numéricos.

Além das colunas categóricas, as colunas numéricas também sofreram processamento antes da criação do modelo. Esse processo de normalização deixou os diferentes dados numéricos no mesmo nível de grandeza para facilitar o entendimento do modelo de machine learning. Para isto, foi utilizado o [StandartScaler](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.StandardScaler.html). Esse método normaliza os dados de acordo com a média e o desvio padrão de cada coluna.

```python
from sklearn.preprocessing import StandardScaler

numericas = ['salario_anual', 'anos_trabalhados', 'renda_percentual', 'anos_primeiro_emprestimo']

scaler = StandardScaler()

dados_encode[numericas] = scaler.fit_transform(dados_encode[numericas])
```

Após a normalização dos dados, foi efetuado o balanceamento da variável target.


### Balanceando os dados

A variável target apresenta desbalanceamento que deve ser corrigido. Nos primeiros testes, foi efetuado balanceamento por *oversampling*, porém o modelo apresentou overfitting e não conseguiu melhorar as métricas. Por isso foi incluida uma técnica de undersampling.

Antes disso, no entanto, para evitar que dados sintéticos ficassem no grupo de testes, o dataset foi dividido em dados de treino e teste utilizando o ´train_test_split()](https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.train_test_split.html).

```python
from sklearn.model_selection import train_test_split

SEED = 42

X = dados_encode.drop('possibilidade_inadimplencia', axis = 1)
y = dados_encode['possibilidade_inadimplencia']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=SEED, stratify = y)

dados_antes = pd.concat([y_train,X_train], axis = 1)
```

Após isso, foi aplicada o algoritmo SMOTE e RandomUndersampling para que as distribuições ficassem mais parecidas. Para isso, foi criada uma pipeline da biblioteca imbalanced-learn

```python
from imblearn.over_sampling import SMOTE
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline

SEED = 42

over = SMOTE(random_state = SEED, sampling_strategy=0.4)
under = RandomUnderSampler(sampling_strategy=0.5)


steps = [('o', over), ('u', under)]
pipeline = Pipeline(steps=steps)
X_train, y_train = pipeline.fit_resample(X_train, y_train)

dados_treino = pd.concat([y_train,X_train], axis = 1)
```

Com isso foram alterados registros.

```python
Haviam 5039 registros na classe minoritária. Foram criados 2195 registros para essa clase.
Haviam 18087 registros na classe majoritária. Foram removidos 3619 registros dessa classe.
```

Após o balanceamento, é possível passar para a criação e validação dos modelos.

## Criação e avaliação dos modelos

Com os dados preparados, é possível criar e validar os modelos de machine learning.

### Criação

Foram criados 5 modelos de machine learning do tipo classificador, tendo em vista a característica da variável target. Os modelos criados foram um Random Forest, um Suport Vector Machine (SVC), um K-Nearest Neighbors e um AdaBoost. Além deles, também foi criado um Dummy Classifier para servir como base de comparação. 

Além da criação, também foi definida uma função que retorna as previsões de cada modelo para os dados de teste.  

```python
def executa_modelo(modelo):

    modelo.fit(X_train,y_train)
    y_pred = modelo.predict(X_test)

    return y_pred
```

```python
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.dummy import DummyClassifier
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier
from sklearn.ensemble import AdaBoostClassifier
SEED = 42

dummy = DummyClassifier(random_state = SEED)
rf = RandomForestClassifier(random_state = SEED)
svc = SVC(random_state = SEED, probability = True)
knc = KNeighborsClassifier()
ada = AdaBoostClassifier(random_state=SEED)

modelos = [dummy, rf, svc, knc, ada]
resultados = {}


for modelo in modelos:
    y_pred = executa_modelo(modelo)
    resultados[modelo] = y_pred
```

### Avaliação

Após a criação dos modelos e da geração de previsões, foi possível avaliar os modelos utilizando métricas de machine learning. Foram utilizadas as métricas precisão, acurácia, *recall*, *F1* e *ROC*. Além disso, também foram geradas matrizes de confusão para cada modelo. Essas métricas foram calculadas e retornadas por meio de uma função.

Apesar de verificar diversas métricas, o modelo escolhido foi aquele que obteve melhores valores na métrica *recall*, tendo em vista o desejo da empresa em diminuir o número de empréstimos concedidos que acabam em inadimplência.

```python
from sklearn import metrics

def valida_modelo(modelo, y_test, y_pred):
    acuracia = metrics.accuracy_score(y_test, y_pred).round(4)
    precisao = metrics.precision_score(y_test, y_pred).round(4)
    recall = metrics.recall_score(y_test, y_pred).round(4)
    f1 = metrics.f1_score(y_test, y_pred).round(4)

    y_pred_proba = modelo.predict_proba(X_test)[::,1]
    auc = metrics.roc_auc_score(y_test, y_pred_proba)

    metricas = [acuracia, precisao, recall, f1, auc]

    matriz = metrics.confusion_matrix(y_test, y_pred)

    return metricas, matriz
```

```python
import matplotlib.pyplot as plt
%matplotlib inline

index = ['Acurácia', 'Precisão', 'Recall', 'F1', 'RoC AUC']
df = pd.DataFrame(index = index)

for modelo, resultado in resultados.items():
    df[modelo], matriz = valida_modelo(modelo, y_test, resultado)
    disp = metrics.ConfusionMatrixDisplay(confusion_matrix = matriz)
    disp.plot()
    plt.title(f'Matriz de confusão do modelo {modelo}')
```

Após a visualização da matriz de confusão, também foram verificadas as métricas por meio de um dataframe do pandas.

```python
df.columns = ['Dummy', 'RandomForest', 'SVC', 'K-Neighbors', 'Ada Boost']
df.T.style.highlight_max(color='green')
```

Com as métricas visualizadas, percebeu-se que o modelo RandomForest teve resultados melhores não apenas na métrica *recall*, mas também nas outras métricas calculadas.

## Otimizando e validando o melhor modelo

Após a escolha do modelo, foi necessário efetuar uma otimização do mesmo. O modelo apresentou valores altos em todas as métricas, o que poderia ser um sinal de *overfitting* do modelo.

### Validação cruzada

Para entender o comportamento do modelo e confirmar que ele estava tendo bons resultados, foi necessário efetuar uma validação cruzada do modelo. Para isso foi utilizado o StratifiedKFold e o método cross_validate.

```python
def dataframe_metricas(resultados):

    acuracia_teste = round(resultados['test_accuracy'].mean(),4)*100
    acuracia_treino = round(resultados['train_accuracy'].mean(),4) * 100
    f1_teste = round(resultados['test_f1'].mean(),4) * 100
    f1_treino = round(resultados['train_f1'].mean(),4) * 100
    precision_teste = round(resultados['test_precision'].mean(),4) * 100
    precision_treino = round(resultados['train_precision'].mean(),4) * 100
    recall_teste = round(resultados['test_recall'].mean(),4) * 100
    recall_treino = round(resultados['train_recall'].mean(),4) * 100

    acuracia = [acuracia_teste, acuracia_treino]
    f1 = [f1_teste, f1_treino]
    precision = [precision_teste, precision_treino]
    recall = [recall_teste, recall_treino]

    index = ['Média do Teste', 'Média do Treino']
    columns = ['Acurácia', 'Precisão', 'Recall', 'F1']
    df = pd.DataFrame(index = index, columns = columns)

    df['Acurácia'] = acuracia
    df['F1'] = f1
    df['Precisão'] = precision
    df['Recall'] = recall

    return df
```

```pyton
from sklearn.model_selection import StratifiedKFold
from sklearn.model_selection import cross_validate


def validacao_cruzada(modelo):
    scoring = ['accuracy','f1', 'precision','recall']
    cv = StratifiedKFold(n_splits = 10)
    resultados = cross_validate(modelo, X, y, cv = cv, return_train_score=True, scoring = scoring)
    metricas = dataframe_metricas(resultados)
    return metricas
```

```python
SEED = 42

modelo = RandomForestClassifier(random_state = SEED)
teste = validacao_cruzada(modelo)
teste.style.format('{:.2f} %')
```

Com a validação cruzada efetuada, foi constatado o *overfitting* do modelo dentro dos grupos de treino. Para corrigir isso e melhorar o resultado para os dados de teste, foi efetuada uma otimização nos hiper parâmetros do modelo.

### RandomizedSearchCV

Foi utilizado o método [GridSearchCV](https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.GridSearchCV.html). Demorou tanto que eu to documentando enquanto ele termina porque não tem como fazer nada.

Após isso foi feito novamente a validação cruzada para garantir que o modelo é melhor que o overfitted.

## Exportando as informações

Com o modelo treinado e validado, as etapas de pré processamento e o modelo foram exportados para um arquivo pickle. Esses dados serão incluidos em uma API que será conectada ao power BI.
