# ==============================================================================
# Script en R: Simulación de Métricas DevOps con NA Condicionales
# Proyecto Integrador: Probabilidad y Estadística Computacional
# Genera el archivo reproducible 'devops_metrics.csv' (N = 5.000 observaciones)
# ==============================================================================

# 1. Fijar semilla para reproducibilidad exacta
set.seed(42)
n <- 5000

# ------------------------------------------------------------------------------
# 2. Variables Cuantitativas (Continuas y Discretas)
# ------------------------------------------------------------------------------
# Gamma: Tiempos de build y despliegue en minutos (asimetría positiva)
build_time_min  <- round(rgamma(n, shape = 4, scale = 2.5) + 1.5, 2)
deploy_time_min <- round(rgamma(n, shape = 3, scale = 1.8) + 0.5, 2)

# Beta: Cobertura de pruebas (acotada entre 0% y 100%)
test_coverage_pct <- round(rbeta(n, shape1 = 8, shape2 = 2.5) * 100, 2)

# Poisson: Conteo de bugs post-despliegue
num_bugs <- rpois(n, lambda = 1.2)

# Poisson + Binomial: Líneas de código modificadas (alta homogeneidad, CV bajo)
commit_size_loc <- as.integer(rpois(n, lambda = 120) + rbinom(n, size = 500, prob = 0.2))

# Exponencial: Horas para resolver tickets (alta asimetría positiva y colas pesadas)
ticket_resolution_h <- round(rexp(n, rate = 1 / 24) + 0.5, 2)

# ------------------------------------------------------------------------------
# 3. Variables Cualitativas (Nominales y Ordinales)
# ------------------------------------------------------------------------------
# Nominal: Equipos de ingeniería
teams_pool <- c("Alpha", "Beta", "Gamma", "Delta")
team <- sample(teams_pool, size = n, replace = TRUE, prob = c(0.28, 0.27, 0.25, 0.20))

# Nominal: Módulo del sistema intervenido
modules_pool <- c("auth", "api", "ui", "database", "payments", "notifications")
module <- sample(modules_pool, size = n, replace = TRUE, prob = c(0.20, 0.30, 0.25, 0.10, 0.08, 0.07))

# Nominal: Estado final del pipeline en producción
status_pool <- c("success", "failed", "rolled_back")
deploy_status <- sample(status_pool, size = n, replace = TRUE, prob = c(0.82, 0.12, 0.06))

# Ordinal: Nivel de criticidad formal
priorities_pool <- c("baja", "media", "alta", "crítica")
priority <- factor(
  sample(priorities_pool, size = n, replace = TRUE, prob = c(0.35, 0.40, 0.18, 0.07)),
  levels = c("baja", "media", "alta", "crítica"),
  ordered = TRUE
)

# ------------------------------------------------------------------------------
# 4. Construcción del Data Frame Analítico
# ------------------------------------------------------------------------------
devops_df <- data.frame(
  build_time_min      = build_time_min,
  deploy_time_min     = deploy_time_min,
  commit_size_loc     = commit_size_loc,
  num_bugs            = num_bugs,
  test_coverage_pct   = test_coverage_pct,
  ticket_resolution_h = ticket_resolution_h,
  team                = team,
  module              = module,
  priority            = priority,
  deploy_status       = deploy_status,
  stringsAsFactors    = FALSE
)

# ------------------------------------------------------------------------------
# 5. Inyección Condicional y Realista de Valores Faltantes (NA)
# ------------------------------------------------------------------------------
# A) Si el despliegue falló, el pase a producción se interrumpió y no hay tiempo final
devops_df$deploy_time_min[devops_df$deploy_status == "failed"] <- NA

# B) Caídas aleatorias de telemetría/sonda en suites de pruebas rápidas (~1.5%)
skip_test_mask <- (devops_df$build_time_min < 5.0 & runif(n) < 0.20) | (runif(n) < 0.01)
devops_df$test_coverage_pct[skip_test_mask] <- NA

# C) Tickets que no registraron cierre porque el incidente fue cancelado o rolled back
unresolved_mask <- devops_df$deploy_status != "success" & runif(n) < 0.30
devops_df$ticket_resolution_h[unresolved_mask] <- NA

# D) Despliegues revertidos (rolled_back) que no auditaron métrica de bugs
unreviewed_bugs_mask <- devops_df$deploy_status == "rolled_back" & runif(n) < 0.50
devops_df$num_bugs[unreviewed_bugs_mask] <- NA

# ------------------------------------------------------------------------------
# 6. Exportación y Auditoría de Integridad
# ------------------------------------------------------------------------------
output_filename <- "devops_metrics.csv"
write.csv(devops_df, file = output_filename, row.names = FALSE)

cat("==================================================================\n")
cat(" Archivo '", output_filename, "' exportado exitosamente.\n", sep = "")
cat(" Dimensiones: ", nrow(devops_df), " filas x ", ncol(devops_df), " columnas.\n", sep = "")
cat("==================================================================\n\n")

cat("Resumen de valores faltantes (NA) por columna:\n")
print(colSums(is.na(devops_df)))
