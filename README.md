# Proyecto Integrador: Análisis de Métricas DevOps y Software

**Curso:** Probabilidad y Estadística Computacional  
**Carrera:** Ingeniería Informática  
**Lenguaje y Entorno:** R (versión 4.2 o superior), RStudio, tidyverse, moments, rmarkdown / quarto  
**Modalidad:** Individual  

---

## 1. Descripción del Proyecto

Este repositorio contiene el análisis estadístico descriptivo e inferencial exploratorio aplicado a un conjunto de datos sintético y reproducible de **5.000 eventos de integración y despliegue continuo (CI/CD)** (`devops_metrics.csv`).

El proyecto aborda las siguientes etapas analíticas:
- **Calidad de Datos y Limpieza:** Auditoría de valores faltantes (NA) y tipificación formal de factores nominales y ordinales.
- **Estadística Descriptiva Univariada:** Evaluación de las tres familias estadísticas: tendencia central, dispersión y forma (asimetría y curtosis mediante el paquete `moments`).
- **Distribución de Frecuencias:** Agrupación empírica por intervalos mediante la Regla de Sturges e identificación de la clase modal.
- **Análisis por Grupos:** Comparación del rendimiento operativo y estabilidad entre los equipos de desarrollo (Alpha, Beta, Gamma y Delta).
- **Relaciones Bivariadas:** Matriz de correlación lineal de Pearson y tablas de contingencia normalizadas, distinguiendo formalmente asociación de causalidad.
- **Visualización Analítica:** Gráficos estadísticos con `ggplot2` bajo el paradigma de la Gramática de Gráficos, con escalas y unidades explícitas.

---

## 2. Estructura del Repositorio

```text
devops-analytics/
├── README.md                 # Guía general de uso y documentación técnica
├── bitacora_prompts.md       # Bitácora de iteraciones de prompts con IA (v1 a vN)
├── 01_simulacion_datos.R     # Script reproducible generador del dataset de 5.000 filas
├── devops_metrics.csv        # Dataset simulado con métricas de telemetría
└── reporte_devops.Rmd        # Reporte dinámico reproducible (RMarkdown)
