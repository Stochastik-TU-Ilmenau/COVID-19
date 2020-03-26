library(lubridate, warn.conflicts=FALSE)

## script for preprocessing data ===============================================
#
# 1) generate cleaned data frames for all available regions
#    with all available factors and uniform naming conventions
#
# 2) generate aggregated data frames from 1) for availiable
#    region - sub-region combinations
#    e.g. region: "italy"        - sub-regions: "regions"
#         region: "italy"        - sub-regions: "provinces"
#         region: "Deutschland"  - sub-regions: "Bundeslaender"
#         region: "Deutschland"  - sub-regions: "Lanndkreise"
#
# 3) generates lookup tables for regions: regX.id - regX.name
#    with (optional) meta data: lat, long, population, area, ...
#
# uniform column names: (not all factors are always available)
# time:  day (counter starting at 0), yday, date
# space: reg0.id, reg0.name, reg1.id, reg1.name, ... (so far no reg2)
# case:  tot.cases, new.cases,
#        tot.dead, new.dead,
#        tot.recovered, new.recovered,
#        tot.tested, new.tested
# meta:  age, sex, ...
#
## =============================================================================


## 1) region: germany; all data ================================================
#
# this data.frame does NOT contain ALL combinations of factors !
# and they are not completed either since too many combinations...
# all combinations only in derived data frames (see below)
#
ger <- read.csv('./rki_data/RKI_COVID19.csv')
# subsetting and reordering: (ignore "Datenstand" and "ObjectId")
ger <- subset(ger, select=c("Meldedatum", "IdBundesland", "Bundesland",
                            "IdLandkreis", "Landkreis", "AnzahlFall",
                            "AnzahlTodesfall", "Altersgruppe", "Geschlecht"))
# renaming:
names(ger) <- c("date", "reg0.id", "reg0.name", "reg1.id", "reg1.name",
                "new.cases", "new.dead", "age", "sex")
ger$date <- as_date(ger$date) # date in correct format
ger$yday <- yday(ger$date) # add yday
ger$day <- ger$yday - min(ger$yday) # add day
ger <- ger[order(ger$day),] # reorder
# for derived data frames additonal case statistics (tot.cases, ...) are added;
# here too many combinations of factors make this impractical !
# reordering:
ger <- ger[, c("day", "yday", "date",
               "reg0.id", "reg0.name", "reg1.id", "reg1.name",
               "new.cases", "new.dead",
               "age", "sex")]
write.csv(ger, file='./clean/data_ger_all.csv')
## 3) # create lookup table for ger all ========================================
lookup_ger <- subset(ger, select=c("reg0.id", "reg0.name",
                                   "reg1.id", "reg1.name"))
lookup_ger <- unique(lookup_ger[order(lookup_ger$reg0.id),])
write.csv(lookup_ger, file='./clean/lookup_ger_all.csv')

ger_b <- read.csv('./clean/data_ger_all.csv')
ger_b <- aggregate(cbind(new.cases, new.dead) ~ day + yday + date
                   + reg0.id + reg0.name, ger_b, sum)
ger_b <- ger_b[order(ger_b$reg0.id),]
ger_b <- ger_b[order(ger_b$day),]
# complete combinations of factors:
df1 <- unique(ger_b[, c("day", "yday", "date")])
df2 <- unique(ger_b[, c("reg0.id", "reg0.name")])
df3 <- merge(df1, df2)
ger_b <- merge(ger_b, df3, all=TRUE)
ger_b[is.na(ger_b)] <- 0
# add case statistics:
for (id in ger_b$reg0.id) {
  mask <- ger_b$reg0.id == id
  ger_b$tot.cases[mask] <- cumsum(ger_b$new.cases[mask])
} # add tot.cases
for (id in ger_b$reg0.id) {
  mask <- ger_b$reg0.id == id
  ger_b$tot.dead[mask] <- cumsum(ger_b$new.dead[mask])
} # add new.dead
# reorder column names:
ger_b <- ger_b[, c("day", "yday", "date",
                   "reg0.id", "reg0.name",
                   "tot.cases", "tot.dead",
                   "new.cases", "new.dead")]
write.csv(ger_b, file='./clean/data_ger_bundl.csv')
