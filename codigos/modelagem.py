'''
OSAR
Analise Consorcios

@claudioalvesmonteiro 2020
'''

# importar pacotes
import pandas as pd 

# importar base
df = pd.read_csv('dataset.csv')
df2 = pd.read_csv('resultados/dataset_consorcios.csv')

#===========================================
# implementar modelo linear 
#===========================================

def SeriesTemporaisInterrompidas(target, features, muni, index, col_nominal):
    # importar modelo
    import statsmodels.api as sm
    from scipy import stats
    # treinar algoritmo
    X2 = sm.add_constant(features)
    est = sm.OLS(target, X2)
    est2 = est.fit()
    # resultados
    results =  pd.DataFrame.from_records({
                'index': [index],
                 col_nominal: muni,
                'intercept': round(est2.params[0], 3),
                'tendency_coeff': round(est2.params[1], 3), 
                'tendency_pvalue': round(est2.pvalues[1], 3), 
                'level_coeff': round(est2.params[2], 3), 
                'level_pvalue': round(est2.pvalues[2], 3), 
                'intervention_coeff': round(est2.params[3], 3), 
                'intervention_pvalue': round(est2.pvalues[3], 3), 
                'r2_adj': round(est2.rsquared_adj, 3)
    }, index='index')
    # retornar resultados
    return(results)



#==========================================
# automatizar geracao dos modelos e 
# salvar resultados em uma base
#==========================================

def autoModelagem(df, col_nominal):
    # criar base
    base = pd.DataFrame(columns=[col_nominal,
                                    'intercept',
                                    'tendency_coeff', 
                                    'tendency_pvalue', 
                                    'level_coeff', 
                                    'level_pvalue', 
                                    'intervention_coeff', 
                                    'intervention_pvalue', 
                                    'r2_adj'])

    cont = 0
    for case in df[col_nominal].unique():
        print('Auto Series Temporais Interrompidas: '+case)
        # selecionar dados do municipio
        data = df[df[col_nominal] == case]
        # separar alvo-features
        try:
            target = data['PIB']
        except:
            target = data['PIB_consorcio']
        features = data[['tendencia', 'nivel', 'pos_intervencao']]
        # executar modelo 
        resultados = SeriesTemporaisInterrompidas(target, features, case, cont, col_nominal)
        # concatenar com a base
        base = pd.concat([base, resultados])
        cont = cont + 1
    
    base.to_excel('resultados/resultados_'+col_nominal+'.xls', index=False)
    print(base.head())
    print('Algoritmo finalizado e resultados salvos na pasta!')


autoModelagem(df, 'municipio')
autoModelagem(df2, 'consorcio')

