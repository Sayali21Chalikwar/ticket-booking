```markdown
# Ticket Booking App

Minimal ticket booking application (Spring Boot backend + React frontend) with Docker and Kubernetes manifests.

What this scaffold includes:
- Spring Boot REST backend (book tickets, list events, suggestions)
- React frontend (browse events, book tickets, suggestions)
- Dockerfiles for backend and frontend
- docker-compose for local development (includes PostgreSQL)
- Kubernetes manifests for deployments and services
- GitHub Actions workflow to build backend and frontend artifacts

Quick start (local with Docker Compose)

1. Copy `.env.example` to `.env` and optionally edit DB credentials.

2. Build and run with Docker Compose:
   docker compose up --build

3. Backend: http://localhost:8080
   Frontend: http://localhost:3000

Local development (without Docker)
- Backend:
  - Ensure Java 17 and Maven are installed.
  - From `backend/` run:
    mvn -B -DskipTests package
    java -jar target/ticket-booking-backend-0.0.1-SNAPSHOT.jar
- Frontend:
  - Ensure Node 18+ and npm installed.
  - From `frontend/` run:
    npm ci
    npm run dev
  - Vite dev server will run on port 3000 (configured) so frontend will proxy /api to backend.

Create & push to GitHub (example using Git CLI)
1. From project root:
   git init
   git add .
   git commit -m "Initial commit - full scaffold"
   git remote add origin https://github.com/YOUR_USER/ticket-booking.git
   git branch -M main
   git push -u origin main

Kubernetes
- Use the manifests in `k8s/` for a simple deploy (works on kind/minikube/Docker Desktop).
- Replace images in manifests with your registry (ghcr.io or Docker Hub) and push images before applying.

If you want, I can help create a PR instead of pushing to main—tell me and I’ll provide the exact git commands to create the branch and PR.
```