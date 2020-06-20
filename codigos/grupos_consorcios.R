#----------------------------------#
#       Artigo Consórcios PE       #
#         Geórgia Ribeiro          #
#      github @georgiaribeiro      #
#----------------------------------#
# ~   Consorciados ambientais    ~ #
#----------------------------------#

#Carregar pacotes [1. Analises 2. DataViz]
library(tidyverse)
library(tidyselect)
library(readxl)

library(ggplot2)
library(plotly)

# ~~~ Ajustes inicias ~~~ #
#Carregar bancos de dados
df = read_xlsx("dados/consorcios.xlsx", sheet = 1)
df = df[, 2:8] #excluir primeira coluna

#transformar colunas de IDH para formato de analise
df = df %>% gather(ano.idh, idh, IDH1991:IDH2010)
df$ano.idh = str_sub(df$ano.idh, start = 4) #manter somente o ano

#renomear variaveis
colnames(df) = c("município", "consorciado", "consorciado.amb",
                 "pib", "ano.idh", "idh")

# ~~~ Analise ~~~ #
#comparar IDH e PIB por tipo de vinculo com consorcios
#municipios nao consorciados [1/3]
nao_cons= df %>%
  filter(consorciado==0) %>%
  group_by(ano.idh) %>%
  summarise(media.idh = mean(idh), media.pib = mean(pib))

nao_cons$grupo = "Não Consorciados"  

#municipios consorciados [2/3]
cons= df %>%
  filter(consorciado==1) %>%
  group_by(ano.idh) %>%
  summarise(media.idh = mean(idh), media.pib = mean(pib))
view(cons)

cons$grupo = "Consorciados"

#municipios consorciados ambientais[3/3]
cons_amb = df %>%
  filter(consorciado.amb>0) %>%
  group_by(ano.idh) %>%
  summarise(media.idh = mean(idh), media.pib = mean(pib))
view(cons_amb)

cons_amb$grupo = "Consorciados Ambientais"

#juntar os tres bancos
grupos = rbind(nao_cons, cons, cons_amb)

  
