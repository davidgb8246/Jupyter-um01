# JupyterLab con Entornos de SageMath y Estadística

Este repositorio contiene la configuración de Docker para distintos entornos de JupyterLab. La imagen utiliza **Ubuntu 22.04** como base y gestiona sus dependencias mediante **Miniconda**.

## 📄 Licencia

Este proyecto está bajo la **Licencia MIT**, lo que significa que es de libre uso, copia y distribución, tanto para fines académicos como personales.

Consulta el archivo [LICENSE](LICENSE) para más detalles (o visita [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT)).

## 🌳 Ramas Disponibles

El proyecto cuenta con **3 ramas especializadas**, cada una optimizada para diferentes casos de uso:

### 1. **Rama `sage`** 📐
Contiene únicamente el entorno de **SageMath**. Ideal para cálculo algebraico y matemático avanzado.

- **Imagen Docker:** [`davidgb8246/jupyter-um01:sage-v0.1`](https://hub.docker.com/layers/davidgb8246/jupyter-um01/sage-v0.1/)
- **Tamaño:** Reducido, solo dependencias matemáticas

### 2. **Rama `statistics`** 📊
Contiene únicamente el entorno de **Estadística**. Perfecto para análisis de datos y visualizaciones estadísticas.

- **Imagen Docker:** [`davidgb8246/jupyter-um01:statistics-v0.1`](https://hub.docker.com/layers/davidgb8246/jupyter-um01/statistics-v0.1/)
- **Tamaño:** Ligero, enfocado en análisis de datos

### 3. **Rama `sage-statistics`** 🔀
Contiene **ambos entornos integrados**: SageMath y Estadística. Es la solución completa "todo en uno".

- **Imagen Docker:** [`davidgb8246/jupyter-um01:sage-statistics-v0.1`](https://hub.docker.com/layers/davidgb8246/jupyter-um01/sage-statistics-v0.1/) (o [`latest`](https://hub.docker.com/layers/davidgb8246/jupyter-um01/latest/))
- **Tamaño:** Completo, con todas las herramientas

## 🎞️ ¿Qué incluye cada imagen?

### Entorno SageMath
Basado en **Python 3.12**, incluye:
* Suite completa de `sage`
* `jupyterlab` y su kernel correspondiente
* Herramientas de cálculo algebraico y simbólico

### Entorno de Estadística
Basado en **Python 3.11**, incluye:
* `pandas`, `numpy` y `scipy` para análisis de datos
* `matplotlib`, `seaborn` y `pillow` para visualización
* `empiricaldist` para modelado estadístico

### Ambos entornos incluyen
* **Herramientas de Sistema:** Compiladores y utilidades esenciales como `git`, `cmake`, `build-essential` y `curl`

## 🚀 Inicio Rápido (Docker Hub)

No necesitas construir la imagen localmente. Las imágenes ya se encuentran disponibles en **Docker Hub** como [`davidgb8246/jupyter-um01`](https://hub.docker.com/repository/docker/davidgb8246/jupyter-um01/).

### Comando de Despliegue Recomendado (Ejemplo: Rama `sage-statistics`)

Para ejecutar el contenedor con todas las opciones de configuración avanzada, usa el siguiente comando:

```bash
docker run -d \
    --rm \
    -p 7777:8888 \
    -e JUPYTER_PASSWD="your_secure_password" \
    -e GIT_REPOS="https://github.com/user01/repo01" \
    -v $(pwd)/mi_trabajo:/home/jupyter/work \
    --name jupyter-um01 \
    davidgb8246/jupyter-um01:sage-statistics-v0.1
```

```bash
bash <(curl -s https://github.com/davidgb8246/Jupyter-um01/run.sh)
```

### 📋 Explicación Detallada de Parámetros

#### **Parámetros de Ejecución**

| Parámetro | Opcional | Valor Ejemplo | Descripción |
|-----------|----------|--------------|-------------|
| **`-d`** | ✅ Sí | — | Ejecuta el contenedor en **modo desatendido (detached)**. **Sin `-d`**: El contenedor bloquea la terminal hasta que se detenga. **Con `-d`**: Funciona en segundo plano. **Recomendado:** Siempre usar para no bloquear la terminal. |
| **`--rm`** | ✅ Sí | — | **Elimina automáticamente** el contenedor al detenerlo. **Sin `--rm`**: El contenedor permanece en tu sistema consumiendo espacio. **Con `--rm`**: Se limpia automáticamente. **Recomendado:** Usar para desarrollo iterativo y mantener limpio el sistema. |
| **`-p 7777:8888`** | ❌ No | `7777` → `8888` | **Mapeo de puertos**: Conecta tu máquina local con el contenedor. `7777` es tu puerto local, `8888` el del contenedor. **Sin `-p`**: JupyterLab no será accesible desde tu navegador. **Con `-p`**: Accedes a través de [`http://localhost:7777`](http://localhost:7777). Puedes usar cualquier puerto disponible en lugar de `7777`. |
| **`--name`** | ✅ Sí | `jupyter-um01` | **Nombre identificable** del contenedor. **Sin `--name`**: Docker asigna un nombre aleatorio. **Con `--name`**: Fácil de gestionar con `docker stop jupyter-um01` o `docker logs jupyter-um01`. **Recomendado:** Facilita la administración. |
| **Imagen** | ❌ No | `davidgb8246/jupyter-um01:sage-statistics-v0.1` | **Obligatorio.** Especifica cuál imagen y versión usar: `sage-vX.X`, `statistics-vX.X`, `sage-statistics-vX.X`, o `latest`. Debe ser el último parámetro del comando. |

#### **Variables de Entorno (`-e`)**

| Variable | Opcional | Valor Ejemplo | Descripción |
|----------|----------|--------------|-------------|
| **`JUPYTER_PASSWD`** | ✅ Sí | `"tu_contraseña_segura"` | **Opcional.** Define una **contraseña** para proteger el acceso a JupyterLab. **Sin esta variable**: JupyterLab no pide contraseña (útil solo en desarrollo local). **Con esta variable**: Se cifra automáticamente y requiere contraseña al acceder. **Recomendado:** Usar en producción o servidores compartidos. |
| **`GIT_REPOS`** | ✅ Sí | `"https://github.com/user01/repo01,https://github.com/user02/repo02"` | **Opcional.** **Repositorios Git** que se clonarán automáticamente en `/home/jupyter/work/` al iniciar. **Sin esta variable**: Los directorios de repositorios no se crean automáticamente. **Con esta variable**: Se descargan los proyectos directamente. Los URLs se separan por **comas sin espacios**. **Recomendado:** Usar para cargar proyectos automáticamente. |

#### **Volumen (`-v`)**

| Aspecto | Detalles |
|--------|----------|
| **Propósito** | Sincroniza directorios entre tu máquina local y el contenedor. Ambos "ven" los mismos archivos en tiempo real. |
| **Sintaxis** | `-v ruta-local:ruta-contenedor` (separa ambas rutas con `:`) |
| **Opcional** | ✅ Sí. **Sin `-v`**: Los archivos dentro del contenedor se pierden al detenerlo. **Con `-v`**: Los datos persisten en tu máquina local. **Recomendado:** Siempre usar para proteger tu trabajo. |
| **Ruta Local** | `$(pwd)/mi_trabajo` — Tu computadora. `$(pwd)` es el directorio actual. En Windows PowerShell usa: `${PWD}\mi_trabajo`. **Variantes:** Rutas absolutas como `/home/usuario/datos` o `C:\Users\Usuario\datos` |
| **Ruta Contenedor** | `/home/jupyter/work` — Dentro del contenedor. Es donde aparecen los archivos para JupyterLab. |
| **Sincronización** | **Bidireccional:** Los cambios en tu carpeta local se reflejan en el contenedor y viceversa. Archivos creados en JupyterLab aparecen en tu carpeta local. |
| **Persistencia** | **Total:** Aunque elimines el contenedor (`--rm`), los archivos en tu máquina local permanecen intactos. |
| **Ejemplos** | `-v /home/usuario/datos:/home/jupyter/work` **o** `-v C:\datos:/home/jupyter/work` — Carpeta `C:\datos` accesible como `/home/jupyter/work` en el contenedor. |

#### **Selección de Rama/Imagen**

Reemplaza el tag de imagen según necesites:

```bash
# Solo SageMath
davidgb8246/jupyter-um01:sage-v0.1

# Solo Estadística  
davidgb8246/jupyter-um01:statistics-v0.1

# Ambos (SageMath + Estadística)
davidgb8246/jupyter-um01:sage-statistics-v0.1
# o simplemente:
davidgb8246/jupyter-um01:latest
```

#### **Acceso a JupyterLab**

Una vez ejecutado el comando anterior, abre tu navegador web y dirígete a:

```
http://localhost:7777
```

> **Nota:** Si usaste `JUPYTER_PASSWD="your_secure_password"`, ingresa esa contraseña en la pantalla de autenticación.

---

## ⚙️ Personalización y Modificación

El proyecto contiene tres Dockerfiles especializados, cada uno en su propio directorio. Aunque no son ramas de Git, representan tres configuraciones distintas que puedes modificar y construir localmente según tus necesidades.

### Paso 1: Clonar el repositorio

```bash
git clone https://github.com/davidgb8246/Jupyter-um01
cd Jupyter-um01
```

### Paso 2: Seleccionar y Modificar la Configuración

A continuación se muestra el ejemplo completo para la configuración **`sage-statistics`** (que incluye ambos entornos). Las otras configuraciones (`sage` y `statistics`) siguen el mismo proceso.

#### 🔀 Ejemplo: Modificar la configuración `sage-statistics`

1. **Abre el archivo** `sage-statistics/Dockerfile` con tu editor preferido:

```bash
# En Linux/macOS
nano sage-statistics/Dockerfile

# O en Windows
notepad sage-statistics\Dockerfile
```

2. **Modifica el Dockerfile según necesites:**

```dockerfile
# Ejemplo: Agregar librerías adicionales al entorno SageMath
RUN conda install -n sage -c conda-forge \
    sympy \
    networkx \
    otra-libreria-nueva

# Ejemplo: Agregar librerías adicionales al entorno de Estadística
RUN conda install -n statistics -c conda-forge \
    scikit-learn \
    xgboost \
    otra-libreria-stats
```

### Paso 3: Construir la imagen personalizada

Una vez editado el Dockerfile, construye la imagen **desde la raíz del proyecto**, especificando la ruta al Dockerfile:

```bash
docker build \
    -f sage-statistics/Dockerfile \
    -t mi-jupyter-sage-statistics:v1.0 \
    .
```

**Explicación del comando:**
- **`-f sage-statistics/Dockerfile`**: Especifica cuál Dockerfile construir (ruta relativa desde la raíz)
- **`-t mi-jupyter-sage-statistics:v1.0`**: Asigna un nombre y versión a la imagen
- **`.`**: Establece la raíz del proyecto como contexto de construcción (permite acceder a archivos compartidos)

### Paso 4: Ejecutar tu versión personalizada

```bash
docker run -d \
    --rm \
    -p 7777:8888 \
    -e JUPYTER_PASSWD="your_secure_password" \
    -e GIT_REPOS="https://github.com/usuario/repo" \
    -v $(pwd)/mi_trabajo:/home/jupyter/work \
    --name jupyter-personalizado \
    mi-jupyter-sage-statistics:v1.0
```

### 📝 Configurar otras variantes

Para modificar la configuración `sage` o `statistics`, simplemente repite los pasos anteriores especificando el Dockerfile correcto:

```bash
# Para la configuración sage (solo SageMath)
docker build \
    -f sage/Dockerfile \
    -t mi-jupyter-sage:v1.0 \
    .

# Para la configuración statistics (solo Estadística)
docker build \
    -f statistics/Dockerfile \
    -t mi-jupyter-statistics:v1.0 \
    .
```

Luego ejecuta cada una con su respectiva imagen:

```bash
# Ejecutar versión sage personalizada
docker run -d --rm -p 7777:8888 \
    -v $(pwd)/mi_trabajo:/home/jupyter/work \
    mi-jupyter-sage:v1.0

# Ejecutar versión statistics personalizada
docker run -d --rm -p 7777:8888 \
    -v $(pwd)/mi_trabajo:/home/jupyter/work \
    mi-jupyter-statistics:v1.0
```

### 💡 Consejos Útiles

- **Prueba cambios pequeños:** Modifica y reconstruye un cambio por vez para identificar problemas rápidamente.
- **Verifica la sintaxis del Dockerfile:** Asegúrate de que sea correcta antes de construir (`docker build --no-cache ...` reconstruye sin caché).
- **Limpia imágenes antiguas:** `docker image prune` para liberar espacio.
- **Usa tags descriptivos:** En lugar de `v1.0`, usa nombres como `sage-statistics-opencv-v1.0` para identificar cambios específicos.
- **Inspecciona el contenedor en ejecución:** `docker exec -it jupyter-personalizado bash` para acceder a la terminal del contenedor.
- **Ver logs de construcción:** Si hay errores, `docker build --no-cache -f archivo/Dockerfile -t nombre .` mostrará más detalles.

---

## 👥 Contribuidores

Este proyecto ha sido desarrollado y es mantenido por:

* **David G.B.** - [davidgb8246](https://github.com/davidgb8246)
