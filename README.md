# Proyecto de Infraestructura en la Nube con Terraform y AWS

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

## Instalación

1. Clona este repositorio en tu máquina local:
   ```bash
   git clone https://github.com/tu_usuario/tu_repositorio.git
2. Navega a la carpeta del proyecto:
   ```bash
   cd tu_repositorio
3. Inicializa Terraform:
   ```bash
   terraform init
4. Aplica la infraestructura de Terraform:
   ```bash
   terraform apply
5. Para construir y subir la imagen Docker a ECR:
    ```bash
   docker build -t <nombre_imagen> .
   docker tag <nombre_imagen> <aws_account_id>.dkr.ecr.<region>.amazonaws.com/<nombre_repositorio>:latest
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
   docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/<nombre_repositorio>:latest
## Buenas Prácticas

- **Seguridad**: Utilizamos **IAM Roles** con permisos mínimos necesarios y almacenamos las credenciales de la base de datos en **AWS Secrets Manager**.

- **Escalabilidad**: La infraestructura está diseñada para ser escalable automáticamente con **ECS Fargate**.

- **Infraestructura como Código (IaC)**: Todo está gestionado por **Terraform**, garantizando un entorno reproducible.

- **Manejo de Logs**: Utilizamos **AWS CloudWatch Logs** para el monitoreo y la recolección de logs de la aplicación.

- **Despliegue Continuo**: Todo el flujo de trabajo de implementación está automatizado utilizando **CI/CD**.
