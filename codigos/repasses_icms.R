#------------------------#
#  Artigo Consórcios PE  #
#    Geórgia Ribeiro     #
# github @georgiaribeiro #
#------------------------#
#   ~   Base ICMS    ~   #
#------------------------#

#Carregar pacotes [1. Analises 2. DataViz]
library(tidyverse)
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

#2. Repasses 2004-2012
# ~~~ Ajustes iniciais ~~~ #
#Carregar todas as planilhas