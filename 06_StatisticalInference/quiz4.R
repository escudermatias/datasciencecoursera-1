s <- "Subject	Baseline	Week 2
1	140	132
2	138	135
3	150	151
4	148	146
5	135 130"
df <- read.delim(textConnection(s), header = TRUE, sep = "\t")
t.test(df$Baseline, df$Week.2, paired = T)

n <- 9
mu <- 1100
sd <- 30
mu0 <- mu - sd/sqrt(n) * qt(c(0.025, 0.975), n - 1)


pbinom(2, size = 4, prob = 0.5, lower.tail = FALSE)


pbinom(10, size = 1787, prob = 1/100, lower.tail = TRUE)


diff.treat <- -3
diff.plac <- 1
sd.treat <- 1.5
sd.plac <- 1.8

n <- 9
sp <- sqrt(((n-1)*sd.treat^2 + (n-1)*sd.plac^2) / (n + n - 2) )

tstat <- (diff.treat - diff.plac) / (sp * sqrt(1/n + 1/n))
pt(tstat, n + n - 2, lower.tail = TRUE)
pt(4.419, 19, lower.tail = FALSE)


(q <- qnorm(0.95, mean = 0, sd = 0.04/sqrt(100), lower.tail = TRUE))
pnorm(q, mean = 0.01, sd = 0.004, lower.tail = FALSE)

n <- c(120, 140, 160, 180)
q <- qnorm(0.95, mean = 0, sd = 0.04/sqrt(n), lower.tail = TRUE)
pnorm(q, mean = 0.01, sd = 0.04/sqrt(n), lower.tail = FALSE)
