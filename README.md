# RG WIN — Healix Field Sales & Doctor CRM

A production-grade Field Sales & Doctor CRM for **Healix**, designed to maintain doctor relationships, record field visits, track product sample distribution, manage follow-ups, prescriptions, orders, and sales, and measure authoritative business performance.

---

## Architecture Overview

```
RG WIN CRM
├── backend/                  # FastAPI + SQLAlchemy (Async) + PostgreSQL
│   ├── alembic/              # Database schema migrations
│   ├── app/
│   │   ├── api/v1/           # API router & versioned endpoints (/auth, /health)
│   │   ├── core/             # Configuration, DB engine, security, rate limiting
│   │   ├── dependencies/     # Server-side auth & RBAC guards
│   │   ├── models/           # 19 normalized relational database models
│   │   ├── repositories/     # Data access layer
│   │   ├── schemas/          # Pydantic v2 schemas
│   │   └── services/         # Business logic services
│   ├── scripts/              # Database seeder (Admin & MR accounts)
│   └── tests/                # Automated Pytest test suite (22 tests)
│
├── frontend/                 # Flutter 3.44.2 (Dart 3.12.2)
│   ├── lib/
│   │   ├── core/             # Design system tokens, widgets, routing, storage, network
│   │   └── features/
│   │       ├── auth/         # Login screen, AuthController, secure session storage
│   │       ├── dashboard/    # Responsive shell & KPI dashboard
│   │       ├── doctors/      # Doctor directory shell
│   │       ├── visits/       # Visits management shell
│   │       ├── products/     # Healix product mirror shell
│   │       └── followups/    # Follow-ups schedule shell
│   └── test/                 # Automated Flutter unit & widget tests (22 tests)
│
└── docs/                     # Architecture & integration contracts
    └── healix-integration.md # Upstream catalog integration spec (31 products)
```

---

## Tech Stack

### Backend
- **Framework**: FastAPI (Python 3.12+)
- **Database**: PostgreSQL (`rg_win_dev`) via asyncpg & SQLAlchemy 2.0 (async)
- **Migrations**: Alembic
- **Security**: Argon2id password hashing (`passlib`), PyJWT (HS256)
- **Rate Limiting**: Slowapi (token bucket)
- **Testing**: Pytest, pytest-asyncio, HTTPX

### Frontend
- **Framework**: Flutter 3.44.2 / Dart 3.12.2 (Cross-platform: Desktop, Mobile, Web)
- **State Management**: Flutter Riverpod 3.x (`Notifier`, `Provider`)
- **Navigation**: GoRouter with authenticated route redirection
- **Design System**: Material 3 with customized Healix design tokens
- **Persistence**: `flutter_secure_storage` (DPAPI on Windows, Keychain on iOS, Encrypted SharedPreferences on Android)
- **HTTP Client**: Dio with interceptors and retry policies

---

## Security Highlights

- **Argon2id**: Memory-hard password hashing parameters (64MB memory, 3 iterations, 4 parallelism lanes).
- **Signed Session Linkage**: Access tokens (15m expiry) embed a signed claim to their companion rotating refresh token JTI (`refresh_jti`).
- **Complete Revocation on Logout**: `/api/v1/auth/logout` invalidates both the access token and the active refresh token, even if the access token has already expired.
- **Server-Side RBAC**: Authorization enforced strictly on the server (`ADMIN` vs `MR` roles).
- **Zero Token Exposure**: Raw JWTs and plaintext passwords are never logged or stored in audit trails.
- **Brute-Force Protection**: Slowapi rate limits active on authentication endpoints (`20/min` on login, `30/min` on refresh).

---

## Getting Started

### 1. Backend Setup (Local PostgreSQL)

The application connects to a local PostgreSQL 16 database named `rg_win_dev`.

```bash
cd backend

# Create virtual environment & install dependencies
python -m venv .venv
.venv\Scripts\activate  # Windows
pip install -r requirements.txt

# Configure environment
copy .env.example .env

# Run database migrations
alembic upgrade head

# Seed initial admin and MR users
python scripts/seed_db.py

# Run tests
pytest tests/ -v

# Start development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Default seeded credentials:
- **Admin**: `admin@healix.com` / `AdminPass123!`
- **Medical Representative**: `mr.ravi@healix.com` / `MrPass123!`

### 2. Frontend Setup (Flutter)

```bash
cd frontend

# Get dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run tests
flutter test

# Run application
flutter run -d windows  # or chrome, android
```

---

## Project Status

- [x] **Phase 0**: System & Upstream API Verification (Signed Off)
- [x] **Phase 1**: Production Foundation, Database Architecture & Design System (Approved)
- [x] **Phase 2**: Authentication, RBAC, Security & Production Login UI (Approved & Verified)
- [ ] **Phase 3**: Doctor & Area Management & Drift Offline Database (Next)
- [ ] **Phase 4**: Visit Logging & Product Sampling Core Workflow
- [ ] **Phase 5**: Follow-ups & Reminders Engine
- [ ] **Phase 6**: Prescriptions, Orders, Sales & Commercial Tracking
- [ ] **Phase 7**: Expenses & Financial Tracking
- [ ] **Phase 8**: Analytics, Doctor P&L & Authoritative ROI Engine
- [ ] **Phase 9**: Offline Sync Engine & Conflict Resolution
- [ ] **Phase 10**: Production Hardening, Audit & Deployment

---

## License

Proprietary — Healix Operations. All Rights Reserved.
