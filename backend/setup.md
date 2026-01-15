# Backend Setup Guide

This guide explains how to run the FastAPI backend using Docker, as requested.

## Prerequisites
- Docker
- Docker Compose

## Quick Start
1. Navigate to the `backend` directory:
   ```bash
   cd backend
   ```

2. Build and start the containers:
   ```bash
   docker-compose up --build
   ```
   This will start:
   - **PostgreSQL Database** on port 5433 (Mapped from 5432 to avoid conflict)
   - **FastAPI Backend** on port 8000

3. Access the API documentation:
   Open your browser and go to [http://localhost:8000/docs](http://localhost:8000/docs).

## API Wrapper & Testing
The Swagger UI at `/docs` allows you to interact with all endpoints.

### 1. Create Users
You need to create users first to test the roles. Use `POST /api/v1/users/` (wait, I didn't enable auth for user creation so you can bootstrap, but in a real app you might want public registration).
*Actually, the code I wrote for `POST /users/` does NOT have `Depends` on token for creation, so it is open for registration.*

Create 3 users:
- **Admin**: `{"email": "admin@example.com", "password": "pass", "role": "admin"}`
- **Buyer**: `{"email": "buyer@example.com", "password": "pass", "role": "buyer"}`
- **Developer**: `{"email": "dev@example.com", "password": "pass", "role": "developer"}`

### 2. Login
Use `POST /api/v1/auth/login` with `username` (email) and `password` to get an `access_token`.
Click the "Authorize" button in Swagger UI and paste the token to authenticate future requests.

### 3. Workflow
1. **Login as Buyer**.
2. **Create Project**: `POST /projects/`.
3. **Create Task**: `POST /tasks/` (assign to Developer ID).
4. **Login as Developer**.
5. **Get Tasks**: `GET /tasks/assigned`.
6. **Submit Task**: `POST /tasks/{id}/submit` (Upload ZIP file).
7. **Login as Buyer**.
8. **View Task**: `GET /projects` -> list tasks (logic needs to be verified if list projects shows tasks, currently implies basic list).
9. **Pay**: `POST /payments/{task_id}`.
10. **Download**: `GET /tasks/{task_id}/download`.

### 4. Admin Stats
Login as **Admin** and check `GET /stats/`.

## Database Details
- **Username**: postgres
- **Password**: 8135
- **DB Name**: project_platform
