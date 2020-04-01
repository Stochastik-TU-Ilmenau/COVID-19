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

lookup_world <- read.csv(file.path('./johns_hopkins/csse_covid_19_data/',
                                   'UID_ISO_FIPS_LookUp_Table.csv'))
lookup_world <- lookup_world[1:173, ]
lookup_world <- unique(subset(lookup_world,
                              select = c('iso3', 'Country_Region')))
missing <- data.frame(iso3=c('CAN', 'AUS', 'CHN', 'USA'),
                      Country_Region=c('Canada', 'Australia', 'China', 'US'))
lookup_world <- merge(lookup_world, missing, all=TRUE)
lookup_world <- lookup_world[-c(1,2),]
names(lookup_world) <- c('reg0.id', 'reg0.name')
write.csv(lookup_world, file='./clean/lookup_world_jh.csv', row.names=FALSE)
## =============================================================================


## 1) region: world; all data ==================================================
#
# Johns-Hopkins data
#
path <- './johns_hopkins/csse_covid_19_data/csse_covid_19_time_series/'
world_cases <- read.csv(paste0(path,
                               'time_series_covid19_confirmed_global.csv'))
world_dead <- read.csv(paste0(path,
                              'time_series_covid19_deaths_global.csv'))
world_recovered <- read.csv(paste0(path,
                                   'time_series_covid19_recovered_global.csv'))
# date in correct format:
dates <- tail(names(world_cases), -4)
dates <- gsub('X', '', dates)
dates <- parse_date_time(dates, orders='%m%d%y')
# wide too long format:
world_cases2 <- reshape(world_cases, varying=tail(names(world_cases), -4),
                        direction = 'l', timevar = 'date',
                        v.names = 'tot.cases', times = dates)[, -c(3, 4, 7)]
world_dead2 <- reshape(world_dead, varying=tail(names(world_dead), -4),
                       direction = 'l', timevar = 'date',
                       v.names = 'tot.dead', times = dates)[, -c(3, 4, 7)]
world_recovered2 <- reshape(world_recovered,
                            varying=tail(names(world_recovered), -4),
                            direction = 'l', timevar = 'date',
                            v.names = 'tot.recovered',
                            times = dates)[, -c(3, 4, 7)]
world <- merge(merge(world_cases2, world_dead2, all=TRUE),
               world_recovered2, all=TRUE)
# reordering:
world <- world[, c("date", "Country.Region", "Province.State",
                   "tot.cases", "tot.dead", "tot.recovered")]
# renaming:
names(world) <- c("date", "reg0.name", "reg1.name",
                  "tot.cases", "tot.dead", "tot.recovered")
world$yday <- yday(world$date) # add yday
world$day <- world$yday - min(world$yday) # add day
world <- world[order(world$reg0.name),] # reorder
world <- world[order(world$day),] # reorder
# aggregating reg1:
australia <- aggregate(cbind(tot.cases, tot.dead, tot.recovered)
                       ~ day + yday + date + reg0.name,
                       data=subset(world, reg0.name == 'Australia'), sum)
australia$reg1.name <- ''
world <- world[!(world$reg0.name == 'Australia'),] # remove australia
world <- merge(world, australia, all=TRUE)
canada <- aggregate(cbind(tot.cases, tot.dead)
                    ~ day + yday + date + reg0.name,
                    data=subset(world, reg0.name == 'Canada'
                                       & reg1.name != ''), sum)
canada2 <- aggregate(tot.recovered ~ day + yday + date + reg0.name,
                     data=subset(world, reg0.name == 'Canada'
                                        & reg1.name == ''), sum)
canada$reg1.name <- ''
canada <- merge(canada, canada2)
world <- world[!(world$reg0.name == 'Canada'),] # remove canada
world <- merge(world, canada, all=TRUE)
china <- aggregate(cbind(tot.cases, tot.dead, tot.recovered)
                   ~ day + yday + date + reg0.name,
                   data=subset(world, reg0.name == 'China'), sum)
china$reg1.name <- ''
world <- world[!(world$reg0.name == 'China'),] # remove china
world <- merge(world, china, all=TRUE)
# removing colonies:
world <- world[!(world$reg0.name == 'Denmark' & world$reg1.name != ''),]
world <- world[!(world$reg0.name == 'France' & world$reg1.name != ''),]
world <- world[!(world$reg0.name == 'Netherlands' & world$reg1.name != ''),]
world <- world[!(world$reg0.name == 'United Kingdom' & world$reg1.name != ''),]
# removing ships: Diamond Princess, MS Zaandam
world <- world[!(world$reg0.name == 'Diamond Princess'),]
world <- world[!(world$reg0.name == 'MS Zaandam'),]
# add reg0.id:
world <- merge(world, lookup_world)
# reorder:
world <- world[order(world$reg0.id),]
world <- world[order(world$day),]
# add case statistics:
for (id in world$reg0.id) {
  mask <- world$reg0.id == id
  world$new.cases[mask] <- diff(c(0, world$tot.cases[mask]))
} # add new.cases
for (id in world$reg0.id) {
  mask <- world$reg0.id == id
  world$new.dead[mask] <- diff(c(0, world$tot.dead[mask]))
} # add new.dead
for (id in world$reg0.id) {
  mask <- world$reg0.id == id
  world$new.recovered[mask] <- diff(c(0, world$tot.recovered[mask]))
} # add new.recovered
# reordering:
world <- world[, c("day", "yday", "date",
               "reg0.id", "reg0.name",
               "tot.cases", "tot.dead", "tot.recovered",
               "new.cases", "new.dead", "new.recovered")]
#world <- world[order(world$reg0.id),]
#world <- world[order(world$day),]
write.csv(world, file='./clean/data_world_jh.csv', row.names=FALSE)
