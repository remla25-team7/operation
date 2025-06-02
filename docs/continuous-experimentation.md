# Continuous Experimentation: Canary Release of Model Service

## 1. Experiment Setup

- **Change introduced:**  
  Deployed a new version (`v2`) of the `model-service` alongside the existing version (`v1`) in the Kubernetes cluster. Traffic is split between the two versions using Istio's VirtualService and DestinationRule.

- **Hypothesis:**  
  The new version of the model-service (`v2`) will provide equal or better response time and accuracy compared to the current version (`v1`), without increasing error rates.

- **Metrics:**
  - Response time
  - Error rate
  - Request count per version

## 2. Implementation

- **Deployment details:**

  - Both `model-service-v1` and `model-service-v2` are deployed as separate Kubernetes Deployments.
  - Istio Gateway and VirtualService are configured to expose the application.
  - Istio DestinationRule is used to split traffic: 90% to `v1`, 10% to `v2` (canary).
  - Sticky sessions are enabled.

- **Traffic routing:**

  - The VirtualService routes 90% of traffic to `model-service-v1` and 10% to `model-service-v2`.
  - Sticky sessions are implemented using Istio session affinity based on cookies.

- **Metrics collection:**
  - Both versions expose a `/metrics` endpoint.
  - Prometheus is configured to scrape metrics from both services.

## 3. Results

<!-- - **Grafana screenshot:** -->

- **Data summary:**
  - Response time for `v2` is not comparable to `v1`.
  - No significant increase in error rates for `v2`.
  - Traffic split is as expected (approx. 90% to `v1`, 10% to `v2`).

## 4. Decision Process

- **Interpretation:**  
  The metrics indicate that the new version (`v2`) performs as well as the current version (`v1`) in terms of latency and error rate.

- **Conclusion:**  
  Based on the experiment, it is safe to proceed with `model-service-v2`.

---

**Note:**

- The actual screenshot still needs to be taken from Grafana dashboard.
