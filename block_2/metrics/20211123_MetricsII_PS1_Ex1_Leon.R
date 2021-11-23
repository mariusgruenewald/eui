rm(list=ls())

library("readxl")
library("tidyverse")
library("stargazer")

# Exercise 1

# d

dat_1 <- read_xls("data_q1.xls")

dat_1 %>% group_by(i) %>% mutate(y_dd = y - mean(y, na.rm = TRUE)) %>% 
  mutate(x1_dd = x1 - mean(x1, na.rm = TRUE)) %>% mutate(x2_dd = x2 - mean(x2, na.rm = TRUE)) %>%
  mutate(D_y = y-c(NA, head(y,-1))) %>% mutate(D_x1 = x1-c(NA, head(x1,-1))) %>% 
  mutate(D_x2 = x2-c(NA, head(x2,-1))) -> dat_1d

reg_d_FE <- lm(y_dd ~ x1_dd + x2_dd - 1, data = dat_1d)
summary(reg_d_FE)

reg_d_FD <- lm(D_y ~ D_x1 + D_x2 - 1, data = dat_1d)
summary(reg_d_FD)

stargazer(reg_d_FE, reg_d_FD)

# e

dat_1 %>% filter(t==1 | t==2) -> dat_1e
dat_1e %>% group_by(i) %>% mutate(y_dd = y - mean(y, na.rm = TRUE)) %>% 
  mutate(x1_dd = x1 - mean(x1, na.rm = TRUE)) %>% mutate(x2_dd = x2 - mean(x2, na.rm = TRUE)) %>%
  mutate(D_y = diff(y)) %>% mutate(D_x1 = diff(x1)) %>% mutate(D_x2 = diff(x2)) -> dat_1e

reg_e_FE <- lm(y_dd ~ x1_dd + x2_dd - 1, data = dat_1e)
# reg_e_FE <- lm(y_dd ~ x1_dd + x2_dd - 1, data = filter(dat_1e, t==2))
summary(reg_e_FE)

reg_e_FD <- lm(D_y ~ D_x1 + D_x2 - 1, data = filter(dat_1e, t==2))
# reg_e_FD <- lm(D_y ~ D_x1 + D_x2 - 1, data = dat_1e)
summary(reg_e_FD)

stargazer(reg_e_FE, reg_e_FD)

