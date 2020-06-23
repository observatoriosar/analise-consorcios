#------------------------#
#  Artigo Consórcios PE  #
#    Geórgia Ribeiro     #
# github @georgiaribeiro #
#------------------------#
#   ~   Base ICMS    ~   #
#------------------------#

#Carregar pacotes [1. Analises 2. DataViz]
#library(tidyverse) # nunca carregar tidyverse todo, apenas os pacotes necessarios, consome mta memoria 
library(tidyselect)
library(readxl)
library(plyr)
library(tibble)

library(ggplot2)
library(plotly)
library(wesanderson)

#1. Percentual 2004-2012
# ~~~ Ajustes iniciais ~~~ #
#Carregar todas as planilhas
excel_sheets("dados/ICMS_2004-2012.xlsx")

planilhas = excel_sheets("dados/ICMS_2004-2012.xlsx")
list_all = lapply(planilhas, function(x) read_excel("dados/ICMS_2004-2012.xlsx", sheet = x))
str(list_all)

names(list_all) = c("2004","2005","2006","2007","2008","2009","2010","2011","2012")

#incluir coluna de ano (menos 2004)
df = Map(cbind, list_all[c(2:9)], Ano=planilhas[2:9])
df = rbind.fill(df)
# - reordenar pra combinar com 2004
df = df[,c(4,1,2,3)]

#combinar
df_icms = rbind(list_all[[1]], df)

# ~~~ Organizar banco ~~~ #
#renomear (RS= Residuo Solido; UC= Unidade de Conservacao)
names(df_icms) = c("ano", "municipio", "rs", "uc")

#remover linhas vazias
df_icms = df_icms %>% filter(!is.na(municipio))

#substituir NA por zero
df_icms$rs[is.na(df_icms$rs)] = 0

#calcular valores anuais 2004
df2004 = df_icms %>% filter(ano %in% c("1 semestre 2004", "2 semestre 2004")) %>%
  group_by(municipio) %>%
  summarise(rs = sum(rs),
            uc = sum(uc))
# - incluir ano e reordenar coluna
df2004$ano = 2004
df2004 = df2004[,c(4,1,2,3)]

# - excluir semestres e incluir ano 2004
perc_icms = rbind ((df_icms %>% filter(!ano %in% c("1 semestre 2004", "2 semestre 2004"))), df2004)

#=========================#

#2. Repasses Liquidos 2004-2012
# 2.1 - 2004
# ~~~ Ajustes iniciais ~~~ #
#Carregar planilhas
excel_sheets("dados/Repasses_ICMS_Liquidos_2004.xlsx")

planilhas = excel_sheets("dados/Repasses_ICMS_Liquidos_2004.xlsx")
all_2004 = lapply(planilhas, function(x) read_excel("dados/Repasses_ICMS_Liquidos_2004.xlsx", sheet = x))
names(all_2004) = excel_sheets("dados/Repasses_ICMS_Liquidos_2004.xlsx")
View(all_2004)

#Selecionar municipios
meses04 = all_2004[[1]]
meses04 = meses04[,c(1)]

#agrupar acumulado mensal
meses04 = cbind(meses04, as.data.frame(sapply(all_2004, `[[`, "acumulado")))

#somar meses
# - excluir pontos
meses04 <- data.frame(lapply(meses04, function(x) {
  gsub("\\.", "", x)
}))
# - decimais com virgulas
meses04 <- data.frame(lapply(meses04, function(x) {
  gsub("\\,", ".", x)
}))
# - transformar em variaveis numericas
meses04[,2:13] = data.frame(sapply(meses04[,2:13], function(x) as.numeric(as.character(x))))

# - somar                            
meses04$total2004 = rowSums(meses04[,c(-1)])


# 2.2 - 2005
# ~~~ Ajustes iniciais ~~~ #
#Carregar planilhas
excel_sheets("dados/Repasses_ICMS_Liquidos_2005.xlsx")

planilhas = excel_sheets("dados/Repasses_ICMS_Liquidos_2005.xlsx")
all_2005 = lapply(planilhas, function(x) read_excel("dados/Repasses_ICMS_Liquidos_2005.xlsx", sheet = x))
names(all_2005) = excel_sheets("dados/Repasses_ICMS_Liquidos_2005.xlsx")

#Selecionar municipios
meses05 = all_2005[[1]]
meses05 = meses05[,c(1)]

#agrupar acumulado mensal
meses05 = cbind(meses05, as.data.frame(sapply(all_2005, `[[`, "acumulado")))

#somar meses
# - excluir pontos
meses05 <- data.frame(lapply(meses05, function(x) {
  gsub("\\.", "", x)
}))
# - decimais com virgulas
meses05 <- data.frame(lapply(meses05, function(x) {
  gsub("\\,", ".", x)
}))
# - transformar em variaveis numericas
meses05[,2:13] = data.frame(sapply(meses05[,2:13], function(x) as.numeric(as.character(x))))

# - somar                            
meses05$total2005 = rowSums(meses05[,c(-1)])



#2.3 - 2006-2012
# ~~~ Ajustes iniciais ~~~ #
#Carregar planilhas
excel_sheets("dados/Repasses_ICMS_Liquidos_2006-2012.xlsx")

planilhas = excel_sheets("dados/Repasses_ICMS_Liquidos_2006-2012.xlsx")
list_all = lapply(planilhas, function(x) read_excel("dados/Repasses_ICMS_Liquidos_2006-2012.xlsx", sheet = x))
names(list_all) = excel_sheets("dados/Repasses_ICMS_Liquidos_2006-2012.xlsx")

#Selecionar municipios
icms_06a12 = list_all[[1]]
icms_06a12 = icms_06a12[,c(1)]

#agrupar acumulado mensal
icms_06a12 = cbind(icms_06a12, as.data.frame(sapply(list_all, `[[`, "Acumulado")))

#2.4. Juntar anos
icms_liq = cbind(meses04[,c(1,14)], meses05[,c(14)], icms_06a12[,c(2:8)])
colnames(icms_liq)[2] = "2004"
colnames(icms_liq)[3] = "2005"

#=========================#


# para cada município multiplicar o valor repassado  por ano (coluna de icms_liq) pelo percentual de RS (perc_icsm).
#E depois fazer o mesmo com o percentual de UC

# nem precisa fazer loop, segue abaixo passos para solucoes (ver ponto 4 antes de começar):

# 1. usar funcoes reshape/pivot para transformar colunas de anos em icms_liq em 
# uma coluna unica com os anos e outra coluna com os valores, que fica:
# | municipios  | anos   | repasse |
icms_liq = gather(icms_liq, ano, repasses, 2:10)
names(icms_liq) = c("municipio","ano","repasses")

# 2. merge icms_liq com perc_icsm, baseado em 'municpio' e 'ano'
df = merge(perc_icms, icms_liq)

# 3. multiplicar 'repasse' por 'rs', salvar em coluna; 
# multiplicar 'repasse' por 'uc', salvar em coluna; 
df$repasses_rs = df$repasses*df$rs

# 4. somar colunas resultantes do passo 3
# ATENCAO!!!!!!!: para esse processa estar correto, a porcentagem perc_icms
# tem que ser relativa ao total que o municipio recebeu, nao ao total que todos os municipios receberam naquele ano
# verificar isso


# :* txi amu

