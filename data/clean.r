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

## 2) region: "italy" - sub-regions: "regions" =================================
italy_r_t <- read.csv('./dati_italia/dati-regioni/dpc-covid19-ita-regioni.csv')
italy_r_t$date <- as_date(italy_r_t$data) # date in correct format
italy_r_t$date <- date(italy_r_t$date)
italy_r_t$yday <- yday(italy_r_t$date) # add yday
italy_r_t$day <- italy_r_t$yday - min(italy_r_t$yday) # add day
italy_r_t$reg0.name <- italy_r_t$denominazione_regione # rename
# create reg0.id:
reg_name <- sort(unique(italy_r_t$reg0.name))
id_reg <- paste0('ita_', 1:length(reg_name))
## 3) lookup table for italy and regions =======================================
lookup_italy_regions <- data.frame(reg0.id = id_reg, reg0.name = reg_name)
write.csv(lookup_italy_regions, file='./clean/lookup_italy_regions.csv')
# merge:
italy_r_t <- merge(italy_r_t, lookup_italy_regions)
# reorder rows by day:
italy_r_t <- italy_r_t[order(italy_r_t$day),]
# add case statistics:
italy_r_t$tot.cases <- italy_r_t$totale_casi # rename
italy_r_t$tot.dead <- italy_r_t$deceduti # rename
italy_r_t$tot.recovered <- italy_r_t$dimessi_guariti # rename
for (id in id_reg) {
  mask <- italy_r_t$reg0.id == id
  italy_r_t$new.cases[mask] <- diff(c(0, italy_r_t$tot.cases[mask]))
} # add new.cases
for (id in id_reg) {
  mask <- italy_r_t$reg0.id == id
  italy_r_t$new.dead[mask] <- diff(c(0, italy_r_t$tot.dead[mask]))
} # add new.dead
for (id in id_reg) {
  mask <- italy_r_t$reg0.id == id
  italy_r_t$new.recovered[mask] <- diff(c(0, italy_r_t$tot.recovered[mask]))
} # add new.recovered
# reorder column names:
italy_r_t <- italy_r_t[, c("day", "yday", "date",
                           "reg0.id", "reg0.name",
                           "tot.cases", "tot.dead", "tot.recovered",
                           "new.cases", "new.dead", "new.recovered")]
write.csv(italy_r_t, file='./clean/data_italy_regions.csv')
## =============================================================================


## 2) region: "italy" - sub-regions: "provinces" ===============================
italy_p_t <- read.csv('./dati_italia/dati-province/dpc-covid19-ita-province.csv')
# remove "In fase di definizione/aggiornamento":
italy_p_t <- italy_p_t[!grepl("In fase", italy_p_t$denominazione_provincia),]
italy_p_t$date <- as_date(italy_p_t$data) # date in correct format
italy_p_t$date <- date(italy_p_t$date)
italy_p_t$yday <- yday(italy_p_t$date) # add yday
italy_p_t$day <- italy_p_t$yday - min(italy_p_t$yday) # add day
italy_p_t$reg1.name <- italy_p_t$denominazione_provincia # rename
# create reg1.id:
reg_province <- italy_p_t[,c("denominazione_regione",
                             "denominazione_provincia")]
names(reg_province) <- c("reg0.name", "reg1.name")
reg_province <- unique(merge(reg_province, lookup_italy_regions))
reg_name <- sort(unique(italy_p_t$reg1.name))
reg_province$reg1.id <- paste0(reg_province$reg0.id, '_', 1:length(reg_name))
## 3) lookup table italy for regions and provinces =============================
lookup_italy_regions_provinces <- reg_province[, c("reg0.id", "reg0.name",
                                                   "reg1.id", "reg1.name")]
write.csv(lookup_italy_regions_provinces,
          file='./clean/lookup_italy_regions_provinces.csv')
# merge:
#province_as_reg <- data.frame(reg1.id=lookup_italy_regions_provinces$reg1.id,
#                              reg1.name=lookup_italy_regions_provinces$reg1.name)
#italy_p_t <- merge(italy_p_t, province_as_reg, by='reg1.name')
italy_p_t <- merge(italy_p_t, lookup_italy_regions_provinces)
# reorder rows by day:
italy_p_t <- italy_p_t[order(italy_p_t$day),]
# add case statistics:
italy_p_t$tot.cases <- italy_p_t$totale_casi # rename
for (id in italy_p_t$reg1.id) {
  mask <- italy_p_t$reg1.id == id
  italy_p_t$new.cases[mask] <- diff(c(0, italy_p_t$tot.cases[mask]))
} # add new.cases
# reorder column names:
italy_p_t <- italy_p_t[, c("day", "yday", "date",
                           "reg0.id", "reg0.name", "reg1.id", "reg1.name",
                           "tot.cases", "new.cases")]
italy_p_t <- italy_p_t[order(italy_p_t$reg1.id),]
italy_p_t <- italy_p_t[order(italy_p_t$reg0.id),]
italy_p_t <- italy_p_t[order(italy_p_t$day),]
write.csv(italy_p_t, file='./clean/data_italy_provinces.csv')
