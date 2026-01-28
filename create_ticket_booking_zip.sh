#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="ticket-booking"

echo "Creating project tree in ./${ROOT_DIR} ..."

# remove any previous folder to avoid conflicts (comment out if you prefer)
rm -rf "${ROOT_DIR}"
mkdir -p "${ROOT_DIR}"

# helper to write files
write_file() {
  local path="$1"; shift
  mkdir -p "$(dirname "${ROOT_DIR}/${path}")"
  cat > "${ROOT_DIR}/${path}" <<'EOF'
'"$@"
EOF
}

# Create files
mkdir -p "${ROOT_DIR}"

# .gitignore
cat > "${ROOT_DIR}/.gitignore" <<'EOF'
/target
/backend/target
/frontend/node_modules
/frontend/dist
/.idea
/.vscode
/.env
/.DS_Store
EOF

# README.md
cat > "${ROOT_DIR}/README.md" <<'EOF'
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
EOF

# backend/pom.xml
mkdir -p "${ROOT_DIR}/backend"
cat > "${ROOT_DIR}/backend/pom.xml" <<'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>ticket-booking-backend</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>
  <name>ticket-booking-backend</name>
  <properties>
    <java.version>17</java.version>
    <spring.boot.version>3.2.0</spring.boot.version>
  </properties>
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-dependencies</artifactId>
        <version>${spring.boot.version}</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>org.postgresql</groupId>
      <artifactId>postgresql</artifactId>
      <scope>runtime</scope>
    </dependency>
    <dependency>
      <groupId>jakarta.persistence</groupId>
      <artifactId>jakarta.persistence-api</artifactId>
    </dependency>
    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
    </dependency>
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <optional>true</optional>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
EOF

# backend Java files
mkdir -p "${ROOT_DIR}/backend/src/main/java/com/example/ticketbooking"
cat > "${ROOT_DIR}/backend/src/main/java/com/example/ticketbooking/TicketBookingApplication.java" <<'EOF'
package com.example.ticketbooking;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TicketBookingApplication {
    public static void main(String[] args) {
        SpringApplication.run(TicketBookingApplication.class, args);
    }
}
EOF

cat > "${ROOT_DIR}/backend/src/main/java/com/example/ticketbooking/model/Ticket.java" <<'EOF'
package com.example.ticketbooking.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
public class Ticket {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String eventId;
    private String userId;
    private int quantity;
    private double price;
    private LocalDateTime bookedAt;

    public Ticket() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getEventId() { return eventId; }
    public void setEventId(String eventId) { this.eventId = eventId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public LocalDateTime getBookedAt() { return bookedAt; }
    public void setBookedAt(LocalDateTime bookedAt) { this.bookedAt = bookedAt; }
}
EOF

mkdir -p "${ROOT_DIR}/backend/src/main/java/com/example/ticketbooking/repository"
cat > "${ROOT_DIR}/backend/src/main/java/com/example/ticketbooking/repository/TicketRepository.java" <<'EOF'
package com.example.ticketbooking.repository;

import com.example.ticketbooking.model.Ticket;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TicketRepository extends JpaRepository<Ticket, Long> {
    List<Ticket> findByUserId(String userId);
}
EOF

mkdir -p "${ROOT_DIR}/backend/src/main/java/com/example/ticketbooking/service"
cat > "${ROOT_DIR}/backend/src/main/java/com/example/ticketbooking/service/SuggestionService.java" <<'EOF'
package com.example.ticketbooking.service;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class SuggestionService {
    public List<String> suggestEvents(String userId) {
        List<String> suggestions = new ArrayList<>();
        suggestions.add("event-popular-1");
        suggestions.add("event-popular-2");
        suggestions.add("event-local-1");
        return suggestions;
    }
}
EOF

mkdir -p "${ROOT_DIR}/backend/src/main/java/com/example/ticketbooking/controller"
cat > "${ROOT_DIR}/backend/src/main/java/com/example/ticketbooking/controller/TicketController.java" <<'EOF'
package com.example.ticketbooking.controller;

import com.example.ticketbooking.model.Ticket;
import com.example.ticketbooking.repository.TicketRepository;
import com.example.ticketbooking.service.SuggestionService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class TicketController {
    private final TicketRepository ticketRepository;
    private final SuggestionService suggestionService;

    public TicketController(TicketRepository ticketRepository, SuggestionService suggestionService) {
        this.ticketRepository = ticketRepository;
        this.suggestionService = suggestionService;
    }

    @GetMapping("/tickets")
    public List<Ticket> allTickets() {
        return ticketRepository.findAll();
    }

    @PostMapping("/tickets")
    public Ticket bookTicket(@RequestBody Ticket ticket) {
        ticket.setBookedAt(java.time.LocalDateTime.now());
        return ticketRepository.save(ticket);
    }

    @GetMapping("/suggestions")
    public List<String> suggestions(@RequestParam(required = false) String userId) {
        return suggestionService.suggestEvents(userId);
    }
}
EOF

# backend resources
mkdir -p "${ROOT_DIR}/backend/src/main/resources"
cat > "${ROOT_DIR}/backend/src/main/resources/application.yml" <<'EOF'
spring:
  datasource:
    url: jdbc:postgresql://postgres:5432/ticketdb
    username: ticket
    password: ticket
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: false

server:
  port: 8080
EOF

# backend Dockerfile
cat > "${ROOT_DIR}/backend/Dockerfile" <<'EOF'
# Multi-stage build: build with Maven, run with JRE
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn -B -DskipTests package

FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app
COPY --from=build /build/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
EOF

# frontend
mkdir -p "${ROOT_DIR}/frontend/src/components"
cat > "${ROOT_DIR}/frontend/package.json" <<'EOF'
{
  "name": "ticket-booking-frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.4.0"
  },
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "start": "vite"
  },
  "devDependencies": {
    "vite": "^5.0.0",
    "@vitejs/plugin-react": "^4.0.0"
  }
}
EOF

cat > "${ROOT_DIR}/frontend/vite.config.js" <<'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': 'http://localhost:8080'
    }
  },
  build: {
    outDir: 'dist'
  }
})
EOF

cat > "${ROOT_DIR}/frontend/index.html" <<'EOF'
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Ticket Booking</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

cat > "${ROOT_DIR}/frontend/src/main.jsx" <<'EOF'
import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import './index.css'

createRoot(document.getElementById('root')).render(<App />)
EOF

cat > "${ROOT_DIR}/frontend/src/App.jsx" <<'EOF'
import React from "react";
import BookingForm from "./components/BookingForm";

export default function App() {
  return (
    <div style={{ padding: 20 }}>
      <h1>Ticket Booking App</h1>
      <BookingForm />
    </div>
  );
}
EOF

cat > "${ROOT_DIR}/frontend/src/components/BookingForm.jsx" <<'EOF'
import React, { useState, useEffect } from "react";
import axios from "axios";

export default function BookingForm() {
  const [events] = useState([
    { id: "event-popular-1", name: "Concert A" },
    { id: "event-popular-2", name: "Concert B" }
  ]);
  const [selected, setSelected] = useState(events[0].id);
  const [qty, setQty] = useState(1);
  const [suggestions, setSuggestions] = useState([]);

  useEffect(() => {
    axios.get("/api/suggestions")
      .then(res => setSuggestions(res.data))
      .catch(err => console.error(err));
  }, []);

  const book = () => {
    axios.post("/api/tickets", {
      eventId: selected,
      userId: "guest",
      quantity: qty,
      price: 100.0
    }).then(() => alert("Booked!"))
      .catch(err => alert("Error: " + err));
  };

  return (
    <div>
      <h2>Book Ticket</h2>
      <select value={selected} onChange={e => setSelected(e.target.value)}>
        {events.map(ev => <option key={ev.id} value={ev.id}>{ev.name}</option>)}
      </select>
      <input type="number" value={qty} onChange={e => setQty(parseInt(e.target.value)||1)} min="1"/>
      <button onClick={book}>Book</button>

      <h3>Suggestions</h3>
      <ul>
        {suggestions.map(s => <li key={s}>{s}</li>)}
      </ul>
    </div>
  );
}
EOF

cat > "${ROOT_DIR}/frontend/src/index.css" <<'EOF'
body {
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
  margin: 0;
  padding: 0;
  background: #f7fafc;
  color: #111827;
}
EOF

cat > "${ROOT_DIR}/frontend/Dockerfile" <<'EOF'
FROM node:18-alpine as build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --silent || npm install
COPY . .
RUN npm run build

FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx","-g","daemon off;"]
EOF

# docker-compose.yml
cat > "${ROOT_DIR}/docker-compose.yml" <<'EOF'
version: "3.8"
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: ticketdb
      POSTGRES_USER: ticket
      POSTGRES_PASSWORD: ticket
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  backend:
    build: ./backend
    depends_on:
      - postgres
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/ticketdb
      SPRING_DATASOURCE_USERNAME: ticket
      SPRING_DATASOURCE_PASSWORD: ticket
    ports:
      - "8080:8080"
    restart: unless-stopped

  frontend:
    build: ./frontend
    ports:
      - "3000:80"
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  pgdata:
EOF

# k8s manifests
mkdir -p "${ROOT_DIR}/k8s"
cat > "${ROOT_DIR}/k8s/backend-deployment.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: ghcr.io/YOUR_USER/ticket-backend:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_DATASOURCE_URL
          value: jdbc:postgresql://postgres:5432/ticketdb
---
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: backend
  ports:
    - port: 8080
      targetPort: 8080
EOF

cat > "${ROOT_DIR}/k8s/frontend-deployment.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: ghcr.io/YOUR_USER/ticket-frontend:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 80
EOF

# CI workflow
mkdir -p "${ROOT_DIR}/.github/workflows"
cat > "${ROOT_DIR}/.github/workflows/ci.yml" <<'EOF'
name: CI
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: temurin
      - name: Build backend
        working-directory: ./backend
        run: mvn -B -DskipTests package

  build-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version: 18
      - name: Install & build frontend
        working-directory: ./frontend
        run: |
          npm ci
          npm run build
EOF

# .env.example
cat > "${ROOT_DIR}/.env.example" <<'EOF'
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/ticketdb
SPRING_DATASOURCE_USERNAME=ticket
SPRING_DATASOURCE_PASSWORD=ticket
EOF

# LICENSE
cat > "${ROOT_DIR}/LICENSE" <<'EOF'
MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED.
EOF

# Create ZIP
ZIP_NAME="ticket-booking.zip"
echo "Creating zip archive ${ZIP_NAME} ..."
cd "${ROOT_DIR}/.."
if command -v zip >/dev/null 2>&1; then
  zip -r "${ZIP_NAME}" "${ROOT_DIR}" >/dev/null
else
  # fallback using tar.gz if zip missing
  TAR_NAME="ticket-booking.tar.gz"
  tar -czf "${TAR_NAME}" "${ROOT_DIR}"
  echo "zip not found. Created ${TAR_NAME} instead."
  echo "Move ${TAR_NAME} from $(pwd) to where you want it."
  exit 0
fi

echo "Created ${ZIP_NAME} in $(pwd)."
echo ""
echo "Done. You can now download/open ${ZIP_NAME}."