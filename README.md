# DevOps para diferentes componentes de OpenPolítica

Este repositorio está orientado a ofrecer los ficheros para la integración,
distribución e implementación de diferentes componentes del proyecto VOTU de
OpenPolítica.

Actualmente, el proyecto cuenta con componentes de frontend y backend.

## Automatización del backend

La automatización del backend comprende desde que el servidor se encuentra
activo hasta el despliegue de la aplicación de backend en un subdominio de
openpolitica mediante un proxy reverso implementado con nginx.

Las tareas para esta automatización comprenden:
1. Instalación de docker, docker-compose (para la gestión de contenedores) y
	 java (para la actualización de la base de datos).
2. Clonado de repositorio https://github.com/kassambara/nginx-multiple-https-websites-on-one-server.git para el despliegue de un proxy-reverso y la incorporación de servidores web desplegados en otros contenedores.
3. Adaptación de carpetas del repositorio y despliegue de contenedores nginx
	 (proxy reverso),nginx-gen (descubre otros contenedores en la red de
	 nginx-proxy) y nginx-letsencrypt (genera los certificados para servidores
	 descubiertos).
4. Clonado de repositorio de backend
	 https://github.com/openpolitica/open-politica-backend.git y checkout en
	 tag/v1.0 y branch 1.0
5. Copia los archivos  `Dockerfile` y `docker-compose.yml` para la creación
	 de la imagen del backend 
6. Creación de la imagen del contenedor en su versión v1.0.
7. Despliegue de la imagen del contenedor  del backend `votu_backend`(requiere de variables de entorno configuradas por
	 el usuario o la herramienta de automatización empleada) y de la base de
	 datos.
8. Actualización de la base de datos del contenedor `votu_backend_mariadb`
	 mediante la ejecución de un script en el repositorio del backend.

Es importante notar que para el despliegue del backend es necesario establecer
algunas variables de entorno, esto debido a que es información sensible y no se
ha considerado como parte del control de versiones. En
este caso, las variables de entorno se establecen en un archivo `.env` en la carpeta `backend`, donde se ubica también el archivo
`docker-compose.yml`. La información que debe tener archivo es la siguiente:
```
HOST_DOMAIN=<your_subdomain_for_backend>
EMAIL_DOMAIN=<your_registered_email>
```

## Instalación
Los scripts ubicados en este repositorio no requieren de un instalación
propiamente, solamente del clonado del repositorio, que podría ser en la
carpeta home del usuario una vez que inicia sesión mediante SSH:
```
ssh -i ./id_rsa user@ipaddress
cd
git clone https://github.com/openpolitica/devops.git
cd devops
```

## Uso de scripts
Como se mencionó en [Automatización del backend](#automatización-del-backend), es
necesario establecer las variables de entorno para configurar el dominio donde
se desplegará el backend `HOST_DOMAIN` y el correo asociado a su registro `EMAIL_DOMAIN`. Estas variables pueden ser
establecidas de tres maneras:

1. De forma global, mediante `export`:
```
export HOST_DOMAIN=<your_subdomain_for_backend>
export EMAIL_DOMAIN=<your_registered_email>
```
2. Dentro del archivo `.env` en la carpeta `backend` de este repositorio.

3. Como variables en shell acompañando al comando para ejecutar el script.

El script que realiza el despliegue completo en el servidor es `./deploy-all.sh`, y un ejemplo de uso, definiendo las variables en el shell, sería:
```
HOST_DOMAIN=mysubdomain.domain.com EMAIL_DOMAIN=myemail@mail.com ./deploy-all.sh
```

Para más información del uso de los otros scripts, puede visitar la [Wiki del
proyecto](https://github.com/openpolitica/devops/wiki).
