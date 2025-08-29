## 🛠️ Networking: NAT vs VPC Endpoint

### Rule of Thumb

* Use VPC Endpoints (ECR, S3, etc.) if tasks only need to talk to AWS services → cheaper & more secure.
* Use a NAT Gateway if tasks also need outbound internet access (e.g., Docker Hub, external APIs).

### ECR VPC Endpoints
ECR requires two VPC Endpoints:
- `ecr.api` → for authentication & API calls
- `ecr.dkr` → for Docker image pulls

Both are mandatory if ECS tasks run in private subnets.
(Optionally add an S3 VPC Endpoint, since ECR stores image layers in S3.)

## 🌐 ALB Routing: Domain vs Path Based

You can switch between domain-based (host header) and path-based routing in the ALB listener rule by toggling the condition:
```bash
condition {
  host_header {
    values = [each.value.domain]   # For domain-based routing
  }
  # path_pattern {
  #   values = [each.value.path]   # For path-based routing
  # }
}
```
* Domain-based (Host Header): api.example.com → API service, app.example.com → frontend
* Path-based (Path Pattern): example.com/api/* → API service, example.com/app/* → frontend

### Rule of Thumb

* ✅ Use path-based routing if there are specific prefixes inside the app (e.g., /admin/*, /dashboard/*).