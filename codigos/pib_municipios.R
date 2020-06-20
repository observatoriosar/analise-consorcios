#------------------------#
#  Artigo Consórcios PE  #
#    Geórgia Ribeiro     #
# github @georgiaribeiro #
#------------------------#
# ~   PIB Municipal    ~ #
#------------------------#

#Carregar pacotes [1. Analises 2. DataViz]
library(tidyverse)
library(tidyselect)
library(readxl)

library(ggplot2)
library(plotly)
library(wesanderson)

# ~~~ Ajustes iniciais ~~~ #
#Carregar bancos de dados
df_pib = read_xlsx("dados/tabela5938-PIBMunicipios.xlsx", sheet = 1, skip = 2)
df_part = read_xlsx("dados/tabela5938-PIBMunicipios.xlsx", sheet = 2, skip = 2)

#ajustar formato do banco
df_pib = df_pib %>% gather(ano, pib, 2:12)
df_part = df_part %>% gather(ano, participacao, 2:12)

#definir categoria coluna ano
df_pib$ano <- format(df_pib$ano, format="%Y")
df_part$ano <- format(df_part$ano, format="%Y")

# ~~~ Analise ~~~ #
#TOP 10 maiores PIBs por ano
top_pib = df_pib %>%
  group_by(ano) %>%
  arrange(desc(pib)) %>% 
  slice(1:5) %>% 
  ungroup()

# ~~~ Visualizacao ~~~ #
library(scales) #tirar escala y de numero científico

ggplot(top_pib, aes(ano, pib/1000000, group= municipio)) + 
  geom_line(aes(y=pib, color = municipio), size = 0.6) +
  labs(title="Municípios com maiores PIB por ano",
       caption="Fonte: IBGE | Elaboração própria", 
       x="Ano",
       y="Produto Interno Bruto (PIB)", 
       color=NULL) +
  scale_y_continuous(labels = comma)+
  theme_light() +
  theme(title = element_text(size = 11, face="bold"))
  

