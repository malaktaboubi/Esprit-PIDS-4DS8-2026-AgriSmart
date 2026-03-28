# AgriSmart Backend Microservices Guide

Welcome to the AgriSmart Backend! This system is built using a modern, domain-driven **Microservice Architecture**. 

Instead of one giant monolithic backend, the system is broken down into small, independent services (Authentication, Irrigation, Livestock, etc.). They all communicate through an **Nginx API Gateway**, and each has its own **isolated logical Database**.

---

## 🚀 How to Run the Backend

Because the architecture relies on multiple containers (PostgreSQL, Nginx, Mosquitto MQTT, and the Python microservices), you must run it using **Docker Compose**. 

1. **Open a terminal** and navigate to the infrastructure folder:
   ```bash
   cd ~/Desktop/AgriSmartOfficiel/AgriSmart/infrastructure
   ```
2. **Build and start the containers** in the background:
   ```bash
   docker compose up --build -d
   ```
3. **Verify everything is running:**
   ```bash
   docker ps
   ```
   You should see `agri_api_gateway`, `agri_auth_service`, `agri_db`, and `agri_mosquitto`.
4. **View live logs** (to debug API errors):
   ```bash
   docker compose logs -f
   # Or for a specific service:
   docker compose logs -f auth_service
   ```
5. **Stop the backend:**
   ```bash
   docker compose down
   ```

*(Note: Never run `uvicorn` manually on your machine anymore. Docker handles the API Gateway and Network now!)*

---

## 🛠️ How to Build a New Microservice (e.g., Irrigation)

If you or another developer wants to continue building the other pillars (`irrigation_service`, `livestock_service`, etc.), follow these exact 5 steps to ensure it wires up correctly:

### Step 1: Prepare the Service Folder
Every service should have its own environment. For example, for the Irrigation service:
1. Create `backend/irrigation_service/requirements.txt`
2. Create `backend/irrigation_service/Dockerfile`
3. Create `backend/irrigation_service/app/main.py` (FastAPI instance)

### Step 2: Use the Right Database
We’ve pre-created isolated databases for each pillar in `infrastructure/postgres/init.sql`. Never use `db_auth` for a different service!
* Irrigation -> `db_irrigation`
* Livestock -> `db_livestock`
* Crop Health -> `db_crop_health`
* Satellite -> `db_satellite`

### Step 3: Add to `docker-compose.yml`
Open `infrastructure/docker-compose.yml` and add your new service below `auth_service`. 
* **Important:** Give it a unique port (e.g., `8002`) to prevent conflicts!

```yaml
  irrigation_service:
    build: 
      context: ../backend/irrigation_service
      dockerfile: Dockerfile
    container_name: agri_irrigation_service
    networks:
      - agri_net
    restart: always
    depends_on:
      - db
    ports:
      - "8002:8002"
    environment:
      # Use the specific logical database!
      - DATABASE_URL=postgresql://admin:password123@agri_db:5432/db_irrigation
```

### Step 4: Expose it through the API Gateway (Nginx)
The Flutter mobile app only communicates with Port 80 (The API Gateway). Open `infrastructure/nginx/nginx.conf` and add a new routing block for your service:

```nginx
        # Inside the 'server' block:
        location /api/v1/irrigation/ {
            proxy_pass http://agri_irrigation_service:8002/api/v1/irrigation/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
```

### Step 5: Test Your New Endpoint
Rebuild your infrastructure so Docker picks up the new Compose and Nginx settings:
```bash
cd infrastructure
docker compose down
docker compose up --build -d
```
You can now test it from anywhere via the Gateway: `http://localhost/api/v1/irrigation/health`
