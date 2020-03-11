'''
OSAR
Analise Consorcios

@claudioalvesmonteiro 2020
'''


# importar bibliotecas
import pandas as pd
import numpy as np 


# importar base
df = pd.read_csv('dataset.csv')

# remover casos sem consorcio
df = df.dropna(subset=['consorcio']).reset_index()

# PIB agregado por consorcio/ano
agg = df[['PIB', 'consorcio', 'anos']].groupby(['consorcio', 'anos']).agg({'PIB': ['mean']}).reset_index()
agg.columns = ['consorcio', 'anos', 'PIB_consorcio']

# selecionar variaveis de teste para os consorcios
datagg = pd.DataFrame(columns=['consorcio', 'anos', 'tendencia', 'nivel', 'pos_intervencao'])

for consorcio in df['consorcio'].unique():
    status = True
    for i in range(len(df)):
        if df['consorcio'][i] == consorcio and status == True:
            dtc = df[i:i+16]
            datagg = pd.concat([dtc, datagg])
            status = False

# combinar pib e base para teste
dataset2 = pd.merge(datagg, agg, on=['consorcio', 'anos'])

# selecionar colunas de interesse e salvar base
dataset2 = dataset2[['consorcio','anos', 'nivel', 'tendencia', 'pos_intervencao', 'PIB_consorcio']]

# salvar base
dataset2.to_csv('resultados/dataset_consorcios.csv')