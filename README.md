# Operation

## Overview 

The repository serves as the main entrypoint into the project - Sentiment Analysis System for Restaurant Reviews. 
The system includes a docker-compose configuration to streamline the deployment and simplify the operational management of the application.

### Related Repositories

- [Model Training](https://github.com/remla25-team7/model-training)
- [Model Service](https://github.com/remla25-team7/model-service)
- [Library for Machine Learning (lib-ml)](https://github.com/remla25-team7/lib-ml)
- [Library for Versioning (lib-version)](https://github.com/remla25-team7/lib-version)
- [Application Frontend and Service (app)](https://github.com/remla25-team7/app)


## Getting Started

### Prerequisites

- Docker
- Docker Compose


### Running the Application

1. Clone this repository to your local machine.
   ```bash
   git clone https://github.com/remla25-team7/operation.git
   cd operation
   ```
2. Create the secrets folder (if it doesn’t exist)
   ```bash
   mkdir -p secrets
   ```
   
3. Define the API Key for the model-service
   ```bash
   echo "API_KEY=your_actual_key_here" > secrets/model_credentials.txt
   ```

4. Start all services
   ```bash
   docker-compose up -d
   ```
## Code Structure

Below are presented the main files and directories of the deployment architecture:

| File/Directory                  | Purpose                                                                |
|---------------------------------|------------------------------------------------------------------------|
| `docker-compose.yml`            | The primary Docker Compose configuration file                          |
| `.env`                          | Environment variables configuration (ports, versions, resource limits) |
| `secrets`                       | Secure storage for sensitive credentials (API keys, tokens, passwords) used across services. Secrets are mounted at runtime and excluded from version control                         |
| `secrets\model_credentials.txt` | Stores the API key for model authentication, excluded from version control for security.|




## Assignment Progress Log

### Assignment A1

- **Model-Training**: Created the ML training pipeline using a Hugging Face model. 
- **Model-Service**: Containerized the ML model using Docker and exposed it via a Flask REST API endpoint. Implemented a GitHub Actions workflow to automatically build and publish the container.
- **Lib-ML**: Standardized preprocessing in PyPI package, used by both training and model-service components.
- **Lib-Version**: Built a version checker for the app-service
- **App**: A Dockerized web application built with HTML/Bootstrap 5 for the frontend and Flask for the backend.
- **Operation**: Main repository for deployment configurations, featuring Docker Compose for simplified launch and detailed README instruction.
- 
