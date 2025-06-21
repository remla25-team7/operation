# Extension Proposal: Decouple Model from Docker Image

## Identified Shortcoming

Currently, our deployment strategy tightly couples the trained ML models with the model service container image. Each time a new model is trained, we are required to rebuild and release a new Docker image for the model service that includes the updated `model.pkl` and `vectorizer.pkl` files. This approach introduces significant workload in our release process and violates the principle of separation of concerns.

### Effects of the Shortcoming

- **Slows iteration cycles**: Retraining a model requires a full image build and redeployment.
- **Hinders experimentation**: Canary or shadow testing of model variants is difficult without image duplication.
- **Reduces maintainability**: Makes it harder to test, deploy, or roll back model versions independently.
- **Waste of CI resources**: Rebuilding the entire image is unnecessary if only the model changes.

---

## Proposed Extension

We propose to unlink the model artifact from the model service image by dynamically downloading the model at runtime. Instead of embedding the model in the container image, we will configure the model service to fetch it from a remote source, such as a Google Drive via DVC.

### Key Changes

- Add support for a `MODEL_URL` environment variable in `app.py` to download the model at runtime.
- Implement local downloading: if the model already exists locally and matches the desired version, skip downloading.
- Modify the Dockerfile to exclude model files from the image.

### Updated Architecture

#### Before:

Docker Image: model service
```
├── app.py
├── model.pkl ← hardcoded into image
└── vectorizer.pkl ← hardcoded into image

```
#### After:

Docker Image: model service
```
├── app.py
└── ⤵️ Downloads model.pkl and vectorizer.pkl from MODEL_URL on startup
↳ Caches locally in /app/models
```

---

## References

- [MLflow Model Registry](https://mlflow.org/docs/latest/model-registry.html) – Industry-standard for decoupling models from services.
- [Google’s ML Test Score](https://research.google/pubs/the-ml-test-score-a-rubric-for-ml-production-readiness-and-technical-debt-reduction/) – Recommends separating model training and serving.
- [Best Practices for Serving ML Models – O’Reilly](https://www.oreilly.com/library/view/machine-learning-model/9781803249902/) – "Model loading should be dynamic and externally configurable."

---

## Evaluation and Validation

We will evaluate the success of this extension using the following criteria:

### Metrics to Track

- **Mean time to deploy a new model** (from training to availability in production).
- **Container startup time** (with vs. without local cache).
- **Failure rate of model loading** in deployment logs.

### Experiment

We will run an experiment comparing the current image service approach and the new dynamic loading version by:

1. Training and releasing a new model via our existing `train_publish_model.yml` pipeline.
2. Deploying the updated model using only a change to the `MODEL_URL` environment variable.
3. Measuring the time and effort difference.
4. Monitoring metrics in Prometheus and observing system logs for model loading behavior.

---

## Benefits

This refactoring brings the following advantages:

- Speeds up model release cycles and promotes experimentation.
- Prepares the system for future additions like model registry integration or automated rollback.
---

## Limitations

- Requires model hosting with reliable access and version control.
- Slight increase in container startup time because of caching.
- A model integrity check should be considered to ensure the downloaded model is correct.
---
