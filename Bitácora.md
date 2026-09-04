# Bitácora Crítica de Prompts — Uso de IA Generativa

**Proyecto:** Análisis Estadístico de Métricas de Software y DevOps[cite: 1]  
**Curso:** Probabilidad y Estadística Computacional[cite: 1]  
**Carrera:** Ingeniería Informática[cite: 1]  
**Objetivo:** Documentar la evolución iterativa de prompts (v1 a vN), el criterio técnico aplicado y la verificación del código generado en R[cite: 1].

---

## 1. Criterio Metodológico General

En este proyecto la Inteligencia Artificial se utilizó estrictamente como un copiloto de programación y análisis, no como un reemplazo del criterio analítico[cite: 1]. Para cada una de las fases se aplicó el siguiente ciclo de trabajo:

1. **Prompt inicial (v1):** Solicitud básica orientada a la tarea[cite: 1].
2. **Auditoría del resultado:** Identificación de errores de sintaxis, falta de rigor estadístico o funciones desactualizadas.
3. **Prompt refinado (v2 / vN):** Especificación matemática rigurosa, delimitación de librerías (`tidyverse`, `moments`, `ggplot2`) y exigencia de parámetros precisos[cite: 1].
4. **Verificación manual:** Ejecución del código en RStudio y contraste de los resultados contra la teoría estadística.

---

## 2. Registro Detallado por Fases

### Fase 1: Carga, Diagnóstico y Limpieza de Datos

* **Prompt v1 (Inicial):**
  > "Crea un script en R que genere 5000 filas con métricas de DevOps como tiempo de build, bugs, equipos y despliegues, y guárdalo en un archivo CSV."

* **Limitaciones detectadas en v1:**
  * El código generaba números aleatorios planos o normales que no reflejan el comportamiento real de software.
  * No incluía ningún dato faltante (`NA`). Sin valores nulos, no era posible justificar una estrategia de limpieza en la entrega[cite: 1].
  * Las variables de texto quedaban como tipo `character` sin jerarquía.

* **Prompt v2 (Refinado):**
  > "Ajusta el script en R con set.seed(42) para generar 5.000 observaciones de telemetría DevOps con distribuciones fundamentadas: Gamma para build y deploy, Poisson para bugs y Exponencial para tickets. Agrega valores NA realistas: pérdidas por falla de sonda en test_coverage_pct y valores condicionales en ticket_resolution_h cuando el despliegue falló. Finalmente, muestra cómo convertir priority en un factor ordinal ordenado y team en factor nominal usando dplyr."[cite: 1]

* **Verificación aplicada:**
  * Se confirmó la creación de `priority` como factor con niveles estrictos: `baja < media < alta < crítica`[cite: 1].
  * Se inspeccionaron las columnas con `colSums(is.na(df))` y se decidió no aplicar `drop_na()` para evitar sesgar el análisis de fallos[cite: 1].

---

### Fase 2: Estadística Descriptiva Univariada

* **Prompt v1 (Inicial):**
  > "Calcula la media y la desviación estándar de las columnas numéricas de mi tabla en R."

* **Limitaciones detectadas en v1:**
  * Solo entregaba medidas básicas de centro y dispersión.
  * Omitía por completo la familia de forma (asimetría y curtosis) y el uso del paquete `moments` exigido en la pauta[cite: 1].
  * No calculaba el Coeficiente de Variación (CV) ni el rango intercuartílico (IQR)[cite: 1].

* **Prompt v2 (Refinado):**
  > "Escribe un bloque summarise() en R usando dplyr y la librería moments que calcule para las variables cuantitativas: media, mediana, desviación estándar, IQR, Coeficiente de Variación porcentual (sd/mean*100), asimetría (skewness) y curtosis (kurtosis). Incluye na.rm = TRUE y explica por qué la mediana es preferible a la media para variables con asimetría positiva."[cite: 1]

* **Verificación aplicada:**
  * Se comprobó que `ticket_resolution_h` presentaba asimetría marcadamente positiva (+1.98), confirmando que la media de 24.5 h estaba inflada por incidentes graves y que la mediana (17.2 h) es la métrica adecuada para definir SLAs.

---

### Fase 3: Distribución de Frecuencias y Regla de Sturges

* **Prompt v1 (Inicial):**
  > "Haz una tabla de frecuencias para la columna build_time_min en R."

* **Limitaciones detectadas en v1:**
  * Se utilizó la función base `table()`, generando intervalos arbitrarios por enteros sin respaldo estadístico.
  * No calculaba frecuencias relativas ni acumuladas[cite: 1].

* **Prompt v2 (Refinado):**
  > "Aplica la Regla de Sturges: k = ceiling(1 + 3.322 * log10(n)) para agrupar build_time_min de 5.000 observaciones en R. Usando mutate() y cut(), genera una tabla con: intervalo de clase, frecuencia absoluta (fa), relativa porcentual (fr), acumulada absoluta (fac) y relativa acumulada (frac). Señala cuál es la clase modal."[cite: 1]

* **Verificación aplicada:**
  * Se comprobó el cálculo de $k = 14$ clases para $N = 5.000$ observaciones[cite: 1].
  * Se validó que el intervalo modal correspondió a $[11.5 - 14.1\text{ min}]$, concentrando 912 eventos (18.2% del total).

---

### Fase 4: Análisis por Grupos y Comparativas

* **Prompt v1 (Inicial):**
  > "Compara cómo le fue a los equipos Alpha, Beta, Gamma y Delta en los bugs y despliegues."[cite: 1]

* **Limitaciones detectadas en v1:**
  * Entregaba promedios simples sin contemplar la asimetría de los datos.
  * No cruzaba el equipo con los estados de despliegue (`success`, `failed`, `rolled_back`)[cite: 1].

* **Prompt v2 (Refinado):**
  > "Construye un pipeline con group_by(team) en dplyr para calcular: mediana de build_time_min, promedio de num_bugs y porcentaje de fallos con mean(deploy_status == 'failed') * 100. Además, genera la tabla de contingencia cruzada con table(df$team, df$deploy_status)."[cite: 1]

* **Verificación aplicada:**
  * Se corroboró que los 4 equipos presentan rendimientos muy parejos (medianas de compilación en ~13.4 min y tasas de éxito sobre el 81%), descartando anomalías exclusivas de un grupo[cite: 1].

---

### Fase 5: Relaciones Bivariadas y Asociación Estadística

* **Prompt v1 (Inicial):**
  > "Calcula la correlación entre las columnas de números y dime si el tamaño del código causa los bugs."

* **Limitaciones detectadas en v1:**
  * `cor()` devolvía valores `NA` al encontrar celdas vacías en cobertura o tickets.
  * La respuesta de la IA concluía de forma errónea que un commit grande causaba directamente fallos en producción, ignorando la diferencia entre correlación y causalidad[cite: 1].

* **Prompt v2 (Refinado):**
  > "Calcula la matriz de correlación de Pearson en R con use = 'complete.obs' redondeada a dos decimales. Para variables cualitativas, genera una tabla de contingencia con prop.table(table(priority, deploy_status), margin = 1) * 100. Explica por qué una correlación r = +0.21 entre commit_size_loc y num_bugs no prueba causalidad, señalando factores confusores como complejidad técnica."[cite: 1]

* **Verificación aplicada:**
  * Se validó que la correlación entre líneas de código y bugs es débil ($r = +0.21$), y se fundamentó formalmente que la correlación estadística no demuestra relación de causa y efecto[cite: 1].

---

### Fase 6: Visualización con ggplot2

* **Prompt v1 (Inicial):**
  > "Haz un histograma y un diagrama de cajas en R."

* **Limitaciones detectadas en v1:**
  * Los gráficos utilizaban el tema gris por defecto y mantenían nombres de variables crudos (`build_time_min`, `num_bugs`) sin unidades ni formato de presentación.

* **Prompt v2 (Refinado):**
  > "Genera visualizaciones analíticas con ggplot2 siguiendo la Gramática de Gráficos: 1) Histograma de build_time_min con 14 bins (Sturges); 2) Boxplot de ticket_resolution_h según team destacando valores atípicos. Aplica theme_minimal(), títulos interpretativos y etiquetas formales con unidades de medida explícitas (minutos, horas)."[cite: 1]

* **Verificación aplicada:**
  * Se verificó que los gráficos incluyeran títulos claros y unidades legibles para una defensa ejecutiva, confirmando visualmente los valores atípicos que justifican el uso de la mediana[cite: 1].
