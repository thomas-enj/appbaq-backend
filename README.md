# AppBaq - Backend

The core business logic, REST API endpoints, and relational data management for the Azure Quiz (AppBaq) project are handled by this repository.

## 🌐 The AppBaq Ecosystem & Deployment Order
The project is split across three interconnected repositories. A strict deployment sequence must be followed:
1. **[Infrastructure](https://github.com/thomas-enj/appbaq-infra-terraform):** The Azure cloud resources must be provisioned first.
2. **[Backend](https://github.com/thomas-enj/appbaq-backend):** The database schemas and API services must be deployed second (Current Repository).
3. **[Frontend](https://github.com/thomas-enj/appbaq-frontend):** The user interface must be deployed last.

## 🎯 Scope & Design Choices

The Java Spring Boot application and its `Dockerfile` were supplied as-is by the base repository and were not selected as part of this work (see the [legacy documentation](LEGACY_README.md)). The choices made here concern the way the image is published, deployed, and operated on Azure, and are aligned with those of the infrastructure repository:

| Axis | Choice |
| --- | --- |
| CI/CD tooling | GitHub Actions |
| Deployment target | Azure Kubernetes Service (AKS), through a Helm chart |
| Image registry | The project Azure Container Registry, resolved by tags |
| Secret delivery | Azure Key Vault, mounted by the Secrets Store CSI driver |
| Backing services | PostgreSQL Flexible Server, Azure Managed Redis, Azure Storage |

## 🗺️ Architecture Diagram

> **Status: work in progress.**

The application architecture diagram (draw.io) will be published here, covering the request flow from the frontend to the API and the calls issued towards the database, the cache, and the storage account.

## 🏗️ Application Architecture
*Note: The core application code and its original documentation were migrated from a separate, pre-existing repository.*

A robust Java API is built using the Spring Boot framework and managed via Maven (`pom.xml`). The internal architecture is organized into specialized packages:
* **Controllers & Services:** API endpoints and business rules are defined to manage Certifications, Training Modules, and Quiz Sessions (`CertificationController`, `ModuleController`, `QuizSessionController`).
* **Data Transfer & Entities:** Data is structured using specialized DTOs (`AnswerOptionDto`, `SubmitAnswerRequest`, etc.) and mapped to the database via JPA Entities (`QuizSession`, `Question`, `Certification`).
* **Security & Configuration:** Access is secured by an API Key filter (`ApiKeyFilter.java`), and performance is optimized through dedicated caching configurations (`CacheConfig.java`).

## 🗄️ Database Management

Database initialization and schema updates are fully automated.
* **Migrations:** SQL schemas and mock data are managed by Flyway through 15 sequential migration scripts located in `src/main/resources/db/migration/`, applied at application startup.
* **Data Seeding:** The database is automatically seeded with Azure modules (e.g., Cloud Concepts, Azure Architecture, Azure Networking) and multiple mock exams. Translations to English are also enforced via these scripts.

## 📦 Containerization & Kubernetes Deployment

The backend is built to run natively within a Kubernetes environment.
* **Docker:** The image is produced by the inherited multi-stage `Dockerfile` (JDK 21 for the build, JRE 21 for the runtime), which already runs the application under a dedicated non-root user and therefore satisfies the restricted Pod Security Standards enforced on the cluster. A `docker-compose.yml` is also provided for local development.
* **Helm Chart:** The Kubernetes resources — namespace, Deployment, ClusterIP Service, ConfigMap, NetworkPolicies, and `SecretProviderClass` — are orchestrated by the chart located in `helm/appbaq/`, and are deployed into the project namespace alongside the frontend.
* **Runtime configuration:** Liveness and readiness probes are wired to `/actuator/health`, CPU and memory requests and limits are declared, and non-sensitive settings (active Spring profile, allowed CORS origins, storage container name) are supplied through the ConfigMap.

## 🔐 Network & Secret Management

* **Ingress isolation:** A `default-deny-ingress` NetworkPolicy is applied to the namespace, and a single companion policy allows traffic on port 8080 from the frontend pods only. The API is exposed through a ClusterIP Service and is therefore never reachable from outside the cluster.
* **Application-level control:** Requests are additionally filtered by an API key (`ApiKeyFilter`), and CORS is restricted to the exact frontend origin.
* **Secret injection:** Database, Redis, and Storage credentials are mounted by the Secrets Store CSI driver through a `SecretProviderClass`, using the AKS managed identity, and synchronized into a Kubernetes secret consumed as environment variables. No credential is stored in the chart, in the image, or in the repository.

## 🚀 CI/CD Pipelines & Automation

Manual deployments are bypassed in favor of complete automation. Both workflows authenticate to Azure through OIDC federated credentials.

* **Build & release preparation (`backend-release-prep.yml`):** The application is built and tested with Maven, the image is built and pushed to the ACR, and a pull request bumping the image tag and the chart version is opened automatically.
* **Deployment (`helm.yml`):** The chart is linted and rendered, then released to AKS with `helm upgrade --install`. Manual `deploy`, `destroy`, and `diagnose` actions are exposed through `workflow_dispatch`.
* **Resource discovery:** The AKS cluster, the Container Registry, and the Key Vault are resolved at runtime by querying Azure on their tags (`owner`, `environment`, `cohort`, `scope`). No resource name is hard-coded in the pipelines.

## 🛠️ Code Quality & Governance

* **Dependency Management:** Dependencies are kept up-to-date automatically by Dependabot (`.github/dependabot.yml`).
* **Code Ownership:** Review responsibilities are formally defined in `.github/CODEOWNERS`.
* **Verified Commits:** Commits are signed so that the *Verified* badge is obtained, and an incremental, prefixed commit history is maintained.
* **Automated Checks:** Application changes are gated by a Maven `clean package`, which compiles the project and runs the unit test suite, while chart changes are gated by `helm lint --strict` and a manifest render. Both checks run on pushes and on pull requests. Azure access relies on OIDC federated credentials, so no long-lived credential is stored in the repository.
* **Security Scanning:** Secret detection is delegated to GitHub's native secret scanning, which is enabled on the repository and raises an alert as soon as a credential is pushed. Vulnerable dependencies are reported by Dependabot alerts, and private vulnerability reporting is enabled so that issues can be disclosed responsibly. Code scanning (SAST) has not been set up, and no container image scan is executed by the pipelines.

## 📚 Inherited Application Documentation

This README covers the Azure deployment of the service. The functional and technical documentation of the application itself — endpoints, domain model, local execution, and configuration properties — was written by the base repository and has been kept unchanged:

👉 **[Read the inherited backend documentation](LEGACY_README.md)**

> The deployment details mentioned in that document (App Service, Static Web Apps, managed-identity access to Storage) describe an earlier target and have been superseded by the AKS setup described above.