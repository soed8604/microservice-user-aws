# ☁️ Infraestructura como Servicio: Del Local a AWS

Este proyecto utiliza **Terraform** para provisionar una infraestructura en la nube en **AWS**. La infraestructura está diseñada para desplegar una aplicación de microservicios utilizando **Amazon ECS (Elastic Container Service)**, **Amazon RDS (Relational Database Service)**, **Amazon ALB (Application Load Balancer)**, **Amazon ECR (Elastic Container Registry)** y **AWS Secrets Manager**.

## 🖼️ Diagrama de Arquitectura

![Diagrama de Arquitectura](https://github.com/user-attachments/assets/70dd2e53-85cb-4694-8716-0ab6ac70e8bb)

## Arquitectura

La infraestructura está compuesta por los siguientes componentes:

- **Amazon ECS**: Para ejecutar y gestionar los contenedores Docker con la aplicación.
- **Amazon RDS**: Para alojar la base de datos PostgreSQL, con las credenciales gestionadas de manera segura en **AWS Secrets Manager**.
- **Amazon ALB**: Load Balancer que distribuye el tráfico entre los contenedores ECS.
- **Amazon ECR**: Registro privado de imágenes Docker utilizado para almacenar y gestionar las imágenes de la aplicación.
- **AWS Secrets Manager**: Para almacenar de forma segura las credenciales de la base de datos y otros secretos necesarios para la aplicación.

## Tecnologías Utilizadas

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![ECS](https://img.shields.io/badge/ECS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7A3E1B?style=for-the-badge&logo=terraform&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)

- **Terraform**: Para definir y provisionar los recursos en AWS como código (IaC).
- **Amazon ECS (Elastic Container Service)**: Para la orquestación de contenedores.
- **Amazon RDS**: Base de datos PostgreSQL gestionada.
- **AWS ALB (Application Load Balancer)**: Distribuye el tráfico HTTP hacia los servicios ECS.
- **AWS ECR (Elastic Container Registry)**: Almacenamiento de imágenes Docker.
- **AWS Secrets Manager**: Gestión de secretos como las credenciales de la base de datos.
- **Docker**: Para crear y gestionar los contenedores de la aplicación.
- **Node.js**: Para el backend de la aplicación.
- **PostgreSQL**: Base de datos relacional.

## Prerrequisitos para ejecutar los servicios localmente
- [Docker](https://docs.docker.com/get-docker/) (versión 20 o superior)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configurado con tus credenciales

## 🖥 Proceso para ejecutar en local

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/usuario/repositorio.git
   cd repositorio
2. Construir y levantar los servicios con Docker Compose:
   ```bash
   docker-compose up --build
3. Verificar que los servicios estén corriendo:
   ```bash
   Aplicación: http://localhost:8086
   
## ☁ Proceso para correrlo en la nube de AWS

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/usuario/repositorio.git
   cd repositorio # directorio Infra

2. Construir la imagen Docker:
    ```bash
   docker build -t nombre-imagen .

3. Etiquetar la imagen para ECR:
   ```bash
   docker tag nombre-imagen:latest <account-id>.dkr.ecr.<region>.amazonaws.com/nombre-repo:latest
4. Autenticarse en ECR:
   ```bash
     aws ecr get-login-password --region <region> \ |
     docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
5. Subir la imagen a ECR:
   ```bash
   docker push <account-id>.dkr.ecr.<region>.amazonaws.com/nombre-repo:latest
6. Verificar los servicio en ECS:
   - Ir a Amazon ECS en la consola de AWS
   - Seleccionar el cluster
   - Editar el servicio para usar la nueva imagen
   - Guardar cambios y esperar el despliegue
7. Verificar el acceso vía Load Balancer:
   - Obtener la URL pública del Application Load Balancer en la consola de AWS
   - En la cmd o terminal ejecutar el comando **nslookup** y la url del load balancer para obtener la ip 
   - Acceder a la aplicación desde el navegador por medio **http**

## Buenas Prácticas

- **Seguridad**: Utilizamos **IAM Roles** con permisos mínimos necesarios y almacenamos las credenciales de la base de datos en **AWS Secrets Manager**.

- **Escalabilidad**: La infraestructura está diseñada para ser escalable automáticamente con **ECS Fargate**.

- **Infraestructura como Código (IaC)**: Todo está gestionado por **Terraform**, garantizando un entorno reproducible.

- **Manejo de Logs**: Utilizamos **AWS CloudWatch Logs** para el monitoreo y la recolección de logs de la aplicación.

- **Despliegue Continuo**: Todo el flujo de trabajo de implementación está automatizado utilizando **CI/CD**.
