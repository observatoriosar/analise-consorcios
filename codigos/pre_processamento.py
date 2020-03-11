'''
OSAR
Analise Consorcios

@claudioalvesmonteiro 2020
'''


# importar bibliotecas
import pandas as pd

#=============================================
# preprocessamento dos municipios/consorcios
#=============================================

# importar dados, selecionar colunas de interesse e renomea-las
data = pd.read_csv('dados/oficial_consorcios.csv')
data =  data[[ 'Município',  'Ano de ingresso consórcio', 'Consorcio1']] ###### PENSAR EM JUSTIFICATIVA/ESTRATEGIA
data.columns = ['municipio', 'ano_ingresso', 'consorcio']

# filtrar municipios consorciados
df = data.dropna(subset=['ano_ingresso'])
df.reset_index(inplace=True)

# transformar ano float em inteiro
df['ano_ingresso'] = df['ano_ingresso'].map(lambda x: int(x))

#=============================================
# TENDENCIA, NIVEL, POS INTERVENCAO
#=============================================

# criar dataframe com anos ate data de inicio do primeiro projeto
dataset = pd.DataFrame(columns=['municipio','consorcio', 'anos', 'tendencia', 'nivel', 'pos_intervencao'])

for i in range(len(df)):
    print(df['municipio'][i])
    # criar listas de cada pais
    municipio = ((df['municipio'][i]+'_') * 16).split('_')[:-1]
    consorcio = ((df['consorcio'][i]+'_') * 16).split('_')[:-1]
    anos = list(range(2002, 2018))
    tendencia = list(range(1,17))
    nivel = [0]*(df['ano_ingresso'][i] - 2002) + [1]*(2018-df['ano_ingresso'][i]) 
    pos_intervencao = [0]*(df['ano_ingresso'][i] - 2002)  + list(range(1, len([1]*(2019-df['ano_ingresso'][i]))))

    # criar dataframe e adicionar 
    data = pd.DataFrame({
        'municipio': municipio,
        'consorcio': consorcio,
        'anos': anos,
        'tendencia': tendencia ,
        'nivel' : nivel,
        'pos_intervencao': pos_intervencao
    })

    dataset = pd.concat([dataset, data], )


#=============================================
# PIB por municipio
#=============================================

# importar base
pib = pd.read_excel('dados/pib_ibge.xls')[:-1]

# criar variavel do nome do municipio
cont = 0
nomes = []
while cont < 2950:
    try:
        nome = pib['Município'][cont]
        nomes = nomes + ((((nome[:-5]+'_')*16).split('_'))[:-1])
        cont = cont + 16
    except:
        print('finalizado')

pib['municipio'] = nomes

# remover colunas e transformar ano em inteiro
pib['anos'] = pib['Ano'].map(lambda x: int(x))
pib.drop(['Município', 'Ano'],axis=1, inplace=True)

# combinar com base de dados dos consorcios
dataset = pd.merge(dataset, pib, on=['municipio', 'anos'])


#========================
# incluir dados do snis
#=======================


#========================
# incluir dados de idh
#=======================

#====================
# salvar dados
#====================

dataset.to_csv('dataset.csv', index=False)