import asyncio
from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.core.database import engine, Base
from app.core.config import settings

# Import routers
from app.modules.auth import routes as auth_routes
from app.modules.users import routes as user_routes
from app.modules.projects import routes as project_routes
from app.modules.tasks import routes as task_routes
from app.modules.payments import routes as payment_routes
from app.modules.stats import routes as stats_routes

# Import models for SQLAlchemy
from app.modules.users import models as user_models
from app.modules.projects import models as project_models
from app.modules.payments import models as payment_models

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Create tables with consistency check
    import os
    if not os.path.exists(settings.UPLOAD_DIR):
        os.makedirs(settings.UPLOAD_DIR)

    retries = 5
    while retries > 0:
        try:
            async with engine.begin() as conn:
                await conn.run_sync(Base.metadata.create_all)
            break
        except Exception as e:
            retries -= 1
            print(f"Database unavailable, retrying in 2s... ({retries} left)")
            await asyncio.sleep(2)
            if retries == 0:
                raise e
    yield
    # Shutdown

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    lifespan=lifespan
)

app.include_router(auth_routes.router, prefix=f"{settings.API_V1_STR}/auth", tags=["auth"])
app.include_router(user_routes.router, prefix=f"{settings.API_V1_STR}/users", tags=["users"])
app.include_router(project_routes.router, prefix=f"{settings.API_V1_STR}/projects", tags=["projects"])
app.include_router(task_routes.router, prefix=f"{settings.API_V1_STR}/tasks", tags=["tasks"])
app.include_router(payment_routes.router, prefix=f"{settings.API_V1_STR}/payments", tags=["payments"])
app.include_router(stats_routes.router, prefix=f"{settings.API_V1_STR}/stats", tags=["stats"])

@app.get("/")
def root():
    return {"message": "Welcome to Project Management API"}
