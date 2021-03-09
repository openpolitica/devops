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

## Actualización de la base de datos
Actualmente, el proyecto cuenta con dos servidores: **staging** para las
pruebas con el backend y **producción** para el despliegue en producción del
backend.

En el caso de la base de datos, el repositorio de backend cuenta con un script
en `/src/dbtools/reset_mysql.sh` el cual se encarga de obtener la bases de
datos del repositorio que extrae los datos del JNE y adapta la información en
el formato requerido para el backend. No obstante, este procedimiento es
destructivo y toma un tiempo elevado, a su vez, que no siempre se requiere
actualizar la base de datos al no haber cambios en los datos originales.

Ante tal situación, se ha planteado el siguiente procedimiento para poder
realizar la actualización de la base de datos en producción sin que demande un
tiempo excesivo y solamente se realice cuando sea necesario. Este procedimiento
contempla los siguientes pasos:
1. **En el servidor staging:**
   Este servidor es de pruebas, por lo que servirá para realizar las
	modificaciones necesarias en la base de datos y constatar si realmente
	requiere de una actualización. Para ello se realiza lo siguiente:
	
	* Se efectúa el reset de la base de datos con el script `reset_mysql.sh` y se
			crea un backup de esta base de datos.
	* Se compara el backup con la base de datos que se encuentra en el
			repositorio (previamente creado con una versión anterior de la base de
			datos). Si se detecta que son diferentes, entonces se procede a realizar
			un commit y un push en el repositorio. De lo contrario, se termina el
			proceso hasta lanzarlo nuevamente, ya sea manualmente o mediante un
			evento de cron.

2. **En el servidor de producción:**
  Este servidor es el que es utilizado por los usuarios finales, por lo que la
	actualización no debe tomar mucho tiempo y a su vez, solo debe realizarse
	cuando es necesaria. En este caso, se realiza el siguiente procedimiento:
	* Se realiza un pull en el repositorio para obtener la versión mas actual de
			la base de datos.
	* Se crea una imagen de la base de datos actual en el servidor de producción
			y se compara con la imagen que se encuentra en el repositorio. Si son
			iguales, no se reemplaza la base de datos existente y se termina el
			proceso. Si son diferentes, se elimina la base de datos actual en el
			servidor y se reemplaza por la base de datos del repositorio. Al
			encontrarse en el mismo formato de mysql, el tiempo para recuperar la
			base de datos es alrededor de 30 segundos.

## Estructura de directorios
Tanto en staging como en producción se recomienda tener una estructura de
directorios tal como se muestra a continuación:
```
$HOME (Ejemplo: /home/ubuntu)
 |- services (root de servicios, por defecto:services)
 |  |- nginx-proxy (carpeta de proxy-reverso, autogenerado)
 |  |- open-politica-backend (carpeta de backend, autogenerado)
 |  |- otro-servicio (servicios adicionales)
 |- devops (este repositorio)
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

### Para actualizar base de datos
Los scripts para actualizar la base de datos se encuentran en fase de pruebas, por lo
que están en una rama diferente a la principal. Para probarlos, es
necesario realizar lo siguiente:
```
git checkout database-update
```

## Uso de scripts

### Automatización de despliegue en servidor
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

### Actualización de base de datos en servidor staging y producción
Como se mencionó en [Actualización de la base de datos](#actualización-de-la-base-de-datos), se realiza en dos etapas: una en el servidor staging y otra en el servidor de producción.

Los scripts para ejecutar estas tareas se encuentran dentro de la carpeta
`database` de este repositorio.

El procedimiento para usarlos es el siguiente (se asume que tanto en el sevidor
de producción como en el staging se ha clonado este repositorio):

1. En el servidor staging:
	* Ejecutar el script `update-staging.sh`. Este script requiere que el
	     despliegue tenga una estructura de directorios como el mostrado en [Estructura de directorios](#estructura-de-directorios). Este script también generará una imagen de la base de datos con el nombre `database.back.sql`.

	* Ejecutar el script `upload-backup.sh`. Este script requiere de ingresar el
			 nombre de usuario y contraseña de GIT. No obstante, esto se puede
			 efectuar mediante variables de entorno:
			 
			 - ̣`GIT_USER` es el nombre de usuario (requerido para commit).
			 - `GIT_EMAIL` es el email del usuario (requerido para commit).
			 - `GIT_API` es el token del usuario (requerido para push).
		
   Un ejemplo de uso empleado estas variables es la siguiente:

```
./update-staging.sh
GIT_USER=Myuser GIT_EMAIL=user@email.com GIT_API=AKjshkkk...Sdj ./upload-backup
```

   Este script subirá los cambios solo si el contenido de la nueva base de
    datos es diferente a la del repositorio.


2. En el servidor de producción:
	
	* Ejecutar el script `update-production.sh`. Este script obtiene la versión
			 más actual de la base de datos en este repositorio. Luego, crea una
			 copia de la base de datos actual en producción y la compara con la del
			 repositorio. Solo en el caso que sea diferente, realiza la actualización
			 de la base de datos en producción.

```
./update-production.sh
```
#### Utilizando el servicio cron
Dentro de la carpeta `database` hay una carpeta `services` donde se encuentra
los archivos para la configuración de un servicio cron para la ejecución del
script en el servidor staging. Para utilizar estos archivos realizar los
siguientes pasos:

1. Modificar el archivo `op-updatedb` en la variable de entorno
	 `DATABASE_SCRIPT_DIR` de acuerdo a la ubicación de los scripts en la máquina
	 virtual. Lamentablemente, cron no admite una recursión en el reemplazo de
	 las variables por lo que no se ha podido emplear una variable dentro de
	 `DATABASE_SCRIPT_DIR`.
2. Ejecutar el script `add-cron.sh` con sudo, el cual se encarga de subir este
	 archivo en el directorio `/etc/cron.d/`.
```bash
sudo ./add-cron.sh
```

**Nota importante:**

*  Para poder verificar que el evento cron se ha ejecutado se
	 puede verificar en el log del sistema ubicado en `/var/log/syslog`, donde en la
	 hora que se encuentra configurado, se debe visualizar el log de la ejecución.
	 Recordar también que la hora que figura en cron, posiblemente se encuentre en UTC, por
	 lo que no coincida con el mismo valor en el log. Para ello simplemente se tendría que buscar
	 su equivalente en la zona horaria actual.

* Para hacer un debug del evento cron, es necesario tener un medio de
	 via mail en el sistema, puesto que es lo que emplea cron para enviar sus
	 logs. En ese caso, se puede instalar en el sistema el programa `postfix` tal
	 como se sugiere en esta [respuesta](https://askubuntu.com/a/234884). Luego
	 se puede ver el resultado en `/var/mail/<user>`. Donde, para este caso, user
	 es `deploy`.
