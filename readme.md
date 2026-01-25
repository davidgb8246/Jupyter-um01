# JupyterLab con Entornos de SageMath y Estadística

Este repositorio contiene la configuración de Docker para un entorno de JupyterLab. La imagen utiliza **Ubuntu 22.04** como base y gestiona sus dependencias mediante **Miniconda**.

## 🎞️ ¿Qué incluye esta imagen?

Esta configuración está diseñada para ser un "todo en uno" que incluye:

* **Entorno SageMath (Principal):** Basado en Python 3.12, incluye la suite completa de `sage`, `jupyterlab` y el kernel correspondiente.
* **Entorno de Estadística:** Un entorno dedicado con Python 3.11 que incluye:
    * `pandas`, `numpy` y `scipy` para análisis de datos.
    * `matplotlib`, `seaborn` y `pillow` para visualización.
    * `empiricaldist` para modelado estadístico.
* **Herramientas de Sistema:** Compiladores y utilidades esenciales como `git`, `cmake`, `build-essential` y `curl`.

## 🚀 Inicio Rápido (Docker Hub)

No necesitas construir la imagen localmente. Ya se encuentra disponible en **Docker Hub** como `davidgb8246/jupyter-um01`.

### Comando de Despliegue Recomendado

Para ejecutar el contenedor en **modo desatendido (background)**, con limpieza automática al cerrar (**--rm**), mapeo de puertos y persistencia de datos, usa el siguiente comando:

```bash
docker run -d \
  --rm \
  -p 8888:8888 \
  -v $(pwd)/mi_trabajo:/home/jupyter/work \
  --name jupyter-um \
  davidgb8246/jupyter-um01
```

### Explicación de los parámetros:

* **`-d`**: Ejecuta el contenedor en segundo plano (modo "detached"), permitiéndote seguir usando la terminal mientras el servidor funciona.
* **`--rm`**: Elimina automáticamente el contenedor al detenerlo, manteniendo tu sistema limpio de procesos antiguos y ahorrando espacio.
* **`-p 8888:8888`**: Mapea el puerto 8888 del contenedor al puerto 8888 de tu máquina local, habilitando el acceso a la interfaz web.
* **`-v $(pwd)/mi_trabajo:/home/jupyter/work`**: Crea un volumen vinculado. Mapea una carpeta local (en este caso una llamada `mi_trabajo` en tu directorio actual) a la ruta `/home/jupyter/work` dentro del contenedor. **Todo lo que guardes aquí persistirá en tu computadora aunque el contenedor se detenga.**
* **`davidgb8246/jupyter-um01`**: Es el nombre de la imagen que se descargará automáticamente desde Docker Hub.

---

## 🔐 Seguridad y Contraseñas

Por defecto, la imagen inicia sin token ni contraseña para facilitar el acceso rápido si se usa localmente. Si deseas añadir seguridad, puedes definir una contraseña mediante la variable de entorno `JUPYTER_PASSWD`:

```bash
docker run -d \
  --rm \
  -p 8888:8888 \
  -e JUPYTER_PASSWD="tu_contraseña_segura" \
  -v $(pwd)/mi_trabajo:/home/jupyter/work \
  --name jupyter-um \
  davidgb8246/jupyter-um01
```

Una vez ejecutado el contenedor, simplemente abre tu navegador y dirígete a: [http://localhost:8888](http://localhost:8888)

---

## 🛠️ Detalles Técnicos del Dockerfile
El contenedor realiza las siguientes acciones automáticas al iniciar:

* **Verificación de contraseña**: Revisa si existe un valor en la variable `JUPYTER_PASSWD`.
* **Generación de Hash**: Si existe, genera un hash de seguridad cifrado usando las herramientas de SageMath (`jupyter_server.auth`).
* **Ejecución**: Inicia JupyterLab bajo el entorno de SageMath, exponiéndolo en todas las redes (`0.0.0.0`) y apuntando al directorio de trabajo `/home/jupyter/work`.

---

## ⚙️ Personalización y Modificación

Si necesitas añadir librerías adicionales o realizar cambios en la configuración, puedes reconstruir la imagen tú mismo siguiendo estos pasos:

1. **Clonar el repositorio:**
```bash
git clone https://github.com/davidgb8246/Jupyter-um01
cd Jupyter-um01
```

2. **Modificar el Dockerfile:**
Edita el archivo Dockerfile con tu editor de texto preferido para añadir los cambios necesarios (por ejemplo, añadiendo paquetes en la sección de apt-get o nuevas librerías en conda).

3. **Construir la imagen de nuevo:**
Ejecuta el siguiente comando para generar tu propia versión local:

```bash
docker build -t mi-jupyter-personalizado .
```

4. **Ejecutar tu versión local:**

```bash
docker run -d --rm -p 8888:8888 -v $(pwd)/mi_trabajo:/home/jupyter/work mi-jupyter-personalizado
```