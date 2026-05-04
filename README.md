# Stream Backend API

Production-ready FastAPI backend with async/await architecture, SQLAlchemy 2.0, and PostgreSQL.

## Features

✅ **Async-First Architecture** - Fully async with SQLAlchemy 2.0 + asyncpg  
✅ **Layered Architecture** - Router → Service → Repository → Database pattern  
✅ **Dependency Injection** - FastAPI's built-in DI system  
✅ **JWT Authentication** - Secure token-based authentication  
✅ **PEP8 Compliant** - Strict code quality standards  
✅ **Pydantic v2** - Modern data validation with ConfigDict  
✅ **Docker & Docker Compose** - Multi-stage production-ready containers  
✅ **Error Handling** - Comprehensive exception management  

## Project Structure

```
backend/
├── api/              # Route handlers
├── services/         # Business logic
├── repositories/     # Database access layer
├── models/          # SQLAlchemy ORM models
├── schemas/         # Pydantic validation schemas
├── core/            # Configuration settings
├── utils/           # Utility functions (JWT, etc)
├── main.py          # Application entry point
├── database.py      # SQLAlchemy setup
├── requirements.txt # Dependencies
└── Dockerfile       # Multi-stage container build
```

## Installation & Setup

### Prerequisites
- Docker & Docker Compose
- Python 3.11+ (for local development)

### Quick Start

1. **Clone and navigate:**
```bash
cd stream_app
```

2. **Configure environment (optional):**
```bash
cp .env.example .env
# Edit .env for custom settings (default values work for local dev)
```

3. **Start services:**
```bash
docker compose up -d --build
```

4. **Verify health:**
```bash
curl http://localhost:8000/health
```

5. **Access API documentation:**
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API Endpoints

### Authentication

**Register User**
```bash
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Login User**
```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

### Health Check
```bash
GET /health
```

## Development

### Running Locally (without Docker)

1. **Create virtual environment:**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. **Install dependencies:**
```bash
pip install -r backend/requirements.txt
```

3. **Set environment variables:**
```bash
export DATABASE_URL="postgresql+asyncpg://stream_user:stream_password@localhost:5432/stream_db"
export SECRET_KEY="your-secret-key"
```

4. **Start PostgreSQL (Docker only):**
```bash
docker compose up -d db
```

5. **Run application:**
```bash
cd backend
uvicorn main:app --reload
```

## Configuration

All settings are loaded from `.env` file using Pydantic BaseSettings:

| Variable | Description | Default |
|----------|-------------|---------|
| `DEBUG` | Debug mode | `False` |
| `DATABASE_URL` | PostgreSQL connection | `postgresql+asyncpg://...` |
| `SECRET_KEY` | JWT signing key | `your-secret-key...` |
| `ALGORITHM` | JWT algorithm | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Token expiry time | `30` |

## Architecture Details

### Async Layered Architecture

```
FastAPI Router
    ↓ (HTTP Request)
APIRouter (api/auth.py)
    ↓ (Dependency Injection)
Service (services/auth.py)
    ↓ (Business Logic)
Repository (repositories/user.py)
    ↓ (Data Access)
Database (SQLAlchemy AsyncSession)
    ↓
PostgreSQL
```

### Database Lifecycle

- **Startup**: Creates async engine, initializes tables via SQLAlchemy metadata
- **Request**: Each request gets fresh AsyncSession via dependency injection
- **Response**: Session auto-closes after request completes
- **Shutdown**: Engine disposes all connections gracefully

## Docker Compose Services

### Database Service (PostgreSQL)
- Image: `postgres:16-alpine`
- Port: `5432`
- Health check: `pg_isready`
- Volume: `postgres_data` (persistent)

### API Service (FastAPI)
- Build: Multi-stage Dockerfile
- Port: `8000`
- Depends on: Database service
- Runs as: Non-root user (security)

## Database Migrations

Currently using SQLAlchemy metadata.create_all() for schema initialization. For production with Alembic:

```bash
# Initialize Alembic
alembic init alembic

# Create migration
alembic revision --autogenerate -m "Initial migration"

# Apply migrations
alembic upgrade head
```

## Security Considerations

✅ **Non-root user** in Docker containers  
✅ **Password hashing** with bcrypt  
✅ **JWT tokens** with configurable expiry  
✅ **Environment variables** for secrets  
✅ **SQL injection protection** via SQLAlchemy ORM  
✅ **HTTPS ready** (configure reverse proxy in production)  

## Production Deployment

For production:

1. **Update `.env`:**
   - Change `SECRET_KEY` to secure random value
   - Set `DEBUG=False`
   - Update `DATABASE_URL` to production database
   - Configure `ALGORITHM` and token expiry

2. **Scale with Gunicorn:**
```bash
gunicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker
```

3. **Use reverse proxy** (nginx/traefik) for HTTPS

4. **Setup monitoring** for logs and metrics

## Troubleshooting

**Database connection fails:**
```bash
docker compose logs db
docker compose down -v  # Remove volumes and retry
```

**Port already in use:**
```bash
# Change port in .env
API_PORT=8001
docker compose up -d --build
```

**Permission errors:**
```bash
docker compose exec api chown -R appuser:appuser /app
```

## Technologies

- **Framework**: FastAPI 0.104.1
- **Database**: PostgreSQL 16 + SQLAlchemy 2.0.23
- **Async Driver**: asyncpg 0.29.0
- **Validation**: Pydantic 2.5.0
- **Authentication**: JWT (python-jose) + Bcrypt
- **Web Server**: Uvicorn 0.24.0
- **Containerization**: Docker & Docker Compose

## License

MIT

## Support

For issues and questions, please refer to FastAPI and SQLAlchemy documentation:
- FastAPI: https://fastapi.tiangolo.com
- SQLAlchemy Async: https://docs.sqlalchemy.org/en/20/orm/extensions/asyncio.html
