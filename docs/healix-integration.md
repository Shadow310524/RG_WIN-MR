# Healix Product Catalog Integration Specification

**Document Version:** 1.0.0  
**Phase:** Phase 0 — Existing Healix System & API Verification  
**Status:** Verified & Frozen for Phase 0  
**Authoritative Product System:** Healix Healthcare Platform  
**Target Consumer System:** RG WIN — Field Sales & Doctor CRM  

---

## 1. System Overview & Discovery Findings

RG WIN Field Sales & Doctor CRM is built to manage doctor interactions, field visits, samples/promotional distributions, follow-ups, prescriptions, orders, and sales performance. 

As established in the core business rules:
> **The Healix Product Master already exists and is the sole authoritative source of truth.**  
> RG WIN must **never** create a competing product master, provide product CRUD endpoints (Create/Edit/Delete), or allow manual re-entry of product master data.

### 1.1 Verified Production Deployments
- **Catalog Web Application:** `https://healix-rgwin.vercel.app/products`
  - **Technology:** React (SPA) + Vite + Tailwind CSS + Lucide React + Framer Motion.
  - **Static Script Bundle:** `/assets/index-BifxkeV_.js` (analyzed and confirmed).
- **Authoritative Backend API:** `https://healix-rgwin.onrender.com/api/v1`
  - **Technology:** Python FastAPI + SQLAlchemy + PostgreSQL.
  - **OpenAPI 3.1.0 Contract:** `https://healix-rgwin.onrender.com/api/v1/openapi.json` (verified live status `200 OK`).
  - **Asset CDN:** Cloudinary (`https://res.cloudinary.com/dnzkcmrkm/image/upload/...`).

---

## 2. Verified Authoritative Product API Contract

### 2.1 Endpoint Catalog & Security Matrix

| Method | Endpoint | Security / Auth | RG WIN Usage | Description |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/products/` | **None (Public)** | **Sync & Cache Engine** | Returns complete catalog of active products (verified 31 products). |
| `GET` | `/api/v1/products/{id}` | **None (Public)** | **On-Demand Detail** | Returns full clinical profile for a specific product ID. |
| `GET` | `/api/v1/categories/` | **None (Public)** | **Category Master Sync** | Returns all 10 product categories. |
| `POST` | `/api/v1/products/` | `OAuth2PasswordBearer` | **FORBIDDEN IN CRM** | Product creation (owned solely by Healix Master). |
| `PUT` | `/api/v1/products/{id}` | `OAuth2PasswordBearer` | **FORBIDDEN IN CRM** | Product update (owned solely by Healix Master). |
| `DELETE` | `/api/v1/products/{id}` | `OAuth2PasswordBearer` | **FORBIDDEN IN CRM** | Product deletion (owned solely by Healix Master). |
| `POST` | `/api/v1/upload/image` | `OAuth2PasswordBearer` | **FORBIDDEN IN CRM** | Product image upload (owned solely by Healix Master). |
| `GET` | `/health` | **None (Public)** | **Health Check** | Verifies upstream service availability. |
| `GET` | `/ready` | **None (Public)** | **Readiness Check** | Verifies upstream database readiness. |

---

## 3. Product & Category Data Schemas

### 3.1 Product Schema (`Product`)
Verified against the live OpenAPI spec and 31 live database records:

```json
{
  "id": 15,
  "name": "Cureova Tablets",
  "category_id": 7,
  "category": {
    "id": 7,
    "name": "Infertility"
  },
  "mrp": "300",
  "price": "",
  "description": "Cureova Tablets is an advanced nutritional formulation containing Myo-Inositol, D-Chiro Inositol, N-Acetylcysteine, Astaxanthin, Chromium Picolinate, L-Methylfolate, Alpha Lactalbumin, vitamins, and essential minerals...",
  "image_url": "https://res.cloudinary.com/dnzkcmrkm/image/upload/v1781811247/healix_products/opzpyosdoygvzwkxf2ly.png",
  "ingredients": [
    "Myo-Inositol – 550 mg",
    "D-Chiro Inositol – 13.8 mg",
    "N-Acetylcysteine – 600 mg",
    "Astaxanthin – 4 mg",
    "Chromium Picolinate – 200 mcg",
    "L-Methylfolate – 0.5 mg",
    "Alpha Lactalbumin – 50 mg",
    "Biotin – 30 mcg",
    "Vitamin B12 – 1.5 mcg"
  ],
  "benefits": [
    "Improves Insulin Sensitivity",
    "Supports PCOS Management",
    "Promotes Healthy Ovulation",
    "Supports Hormonal Balance",
    "Helps Restore Fertility",
    "Supports Reproductive Health",
    "Rich in Antioxidants",
    "Supports Metabolic Health",
    "Provides Folate & Vitamin Support",
    "Supports Women's Wellness"
  ]
}
```

### 3.2 Field Specifications & Parsing Rules

| Field Name | Authoritative Type | RG WIN Storage / Type | Parsing / Validation Rule |
| :--- | :--- | :--- | :--- |
| `id` | `integer` | `INTEGER` (Unique Index) | Must be preserved exactly as `healix_product_id`. Foreign key for all interactions. |
| `name` | `string` | `VARCHAR(255)` | Non-null, trimmed, indexed for autocomplete/search. |
| `category_id`| `integer` | `INTEGER` | Matches category ID in Healix master. |
| `category.name` | `string` | `VARCHAR(100)` | Denormalized into `cached_category` for high-speed offline display. |
| `mrp` | `string` (e.g. `"300"`, `"66.78"`) | `NUMERIC(10, 2)` | Parsed via `Decimal(str(mrp).strip())`. 100% of live products parse cleanly as decimal. |
| `price` | `string` (empty string in live) | Ignored / Optional `NUMERIC` | Fallback to MRP if price is empty. |
| `description` | `string` | `TEXT` | Sanitized text for Clinical Profile view. |
| `image_url` | `string` (URI) | `VARCHAR(512)` | Validated Cloudinary HTTPS URL; cached locally on Flutter client. |
| `ingredients` | `array of strings` | `JSONB` / List of Strings | Stored as JSON array of clinical composition items with strength. |
| `benefits` | `array of strings` | `JSONB` / List of Strings | Stored as JSON array of clinical advantages. |

### 3.3 Verified Active Product Categories (10 Categories)
1. `Hormone Therapy` (ID 1)
2. `Supplements` (ID 2)
3. `Vaginal Health` (ID 3)
4. `Cardiovascular` (ID 4)
5. `Gynecology` (ID 5)
6. `Endometriosis` (ID 6)
7. `Infertility` (ID 7)
8. `Pregnancy Care` (ID 8)
9. `Hypertension` (ID 9)
10. `Women's Supplements` (ID 10)

---

## 4. Ownership Boundary Matrix

| Capability / Entity | Existing Healix System (Owner) | RG WIN CRM (Consumer) |
| :--- | :---: | :---: |
| Product Creation (`POST /products`) | **YES (Authoritative)** | **NO (Forbidden)** |
| Product Modification (`PUT /products/{id}`) | **YES (Authoritative)** | **NO (Forbidden)** |
| Product Deletion (`DELETE /products/{id}`) | **YES (Authoritative)** | **NO (Forbidden)** |
| Image Upload (`POST /upload/image`) | **YES (Authoritative)** | **NO (Forbidden)** |
| Clinical Claims / Ingredients / Benefits | **YES (Authoritative)** | **Read-Only Display** |
| Product References Cache (`product_references` table) | NO | **YES (Local Mirror)** |
| Field Visits & Products Discussed | NO | **YES (Authoritative)** |
| Samples / Free Supplies / Units Given | NO | **YES (Authoritative)** |
| Doctor Feedback & Response | NO | **YES (Authoritative)** |
| Follow-ups Generated | NO | **YES (Authoritative)** |
| Prescriptions Recorded | NO | **YES (Authoritative)** |
| Commercial Orders & Order Items | NO | **YES (Authoritative)** |
| Sales Invoices & Realized Revenue | NO | **YES (Authoritative)** |
| Promotional Investment & ROI Analytics | NO | **YES (Authoritative)** |

---

## 5. Integration Architecture & Caching Strategy

```
+-------------------------------------------------------------------------+
|                      Authoritative Healix Master                        |
|               (https://healix-rgwin.onrender.com/api/v1)                |
+-------------------------------------------------------------------------+
                                    |
                           GET /api/v1/products/
                           (Sync on Startup +
                           Daily Background Job +
                           Manual Admin Refresh)
                                    v
+-------------------------------------------------------------------------+
|                  RG WIN Backend — Integration Service                   |
|                   (HealixProductIntegrationService)                     |
+-------------------------------------------------------------------------+
                                    |
            Writes to PostgreSQL Read-Only Cache Table:
            product_references (healix_product_id, cached_name,
                                cached_mrp, cached_image_url,
                                cached_ingredients, cached_benefits,
                                last_synced_at)
                                    |
                  Exposes to CRM Mobile / Web Client:
                  - GET /api/v1/products
                  - GET /api/v1/products/{healix_product_id}
                  - POST /api/v1/products/sync (Admin Only)
                                    v
+-------------------------------------------------------------------------+
|                     RG WIN Flutter Mobile Client                        |
|                                                                         |
|  - Dio HTTP Client queries RG WIN /api/v1/products                      |
|  - Persists read-only catalog into Drift / SQLite (LocalProductRefs)   |
|  - Instant offline search & dropdown selection for MRs                 |
|  - Clinical Profile Viewer (Read-only ingredients & benefits)           |
|  - MR selects product -> Records Visit with samples -> Syncs offline    |
+-------------------------------------------------------------------------+
```

### 5.1 Three-Tier Caching Pipeline
1. **Tier 1 — Upstream Master Source:** `https://healix-rgwin.onrender.com/api/v1` is the authoritative source of truth.
2. **Tier 2 — Server-Side Relational Cache (`product_references` in PostgreSQL):**
   - Stores authoritative `healix_product_id` (Integer PK link).
   - Allows fast SQL joins between CRM business entities (`visits`, `visit_products`, `prescriptions`, `orders`, `sales`) and product data without making real-time HTTP calls during report generation or transaction processing.
   - Sync engine upserts new/updated products and flags discontinued products (`status = 'INACTIVE'`).
3. **Tier 3 — Client-Side Offline Database (Drift / SQLite on Flutter):**
   - Caches the synced product catalog on the MR's mobile device.
   - Enables instantaneous search and selection when entering visits in clinics with zero cell reception.

---

## 6. Integration Risks & Mitigation Strategies

| Identified Risk | Impact | Mitigation in RG WIN |
| :--- | :--- | :--- |
| **Upstream Service Latency or Cold Starts** (Render free tier sleeps after inactivity) | Backend requests could timeout if queries directly proxy the live master during visit creation. | **Asynchronous / Cached Architecture:** RG WIN backend serves product reads directly from its local `product_references` cache. Visit logging never synchronously blocks on the upstream Healix server. |
| **Schema Changes in Healix Master** (e.g. field renamed or new category format) | Product sync could throw deserialization errors. | **Pydantic v2 Resilient Model:** Use default values, optional fields, and defensive validation in `HealixProductIn` schema. Log warnings on unknown attributes without crashing. |
| **Network Failure in the Field** | MR cannot select products while inside hospital basement/clinic. | **Offline Drift Persistence:** All products cached locally in SQLite. The MR has immediate offline access to the full catalog of 31 products. |
| **MRP String Inconsistencies** | Non-numeric or dirty strings could break financial calculations. | **Strict Decimal Parser:** Ingest step strips whitespace and currency symbols, safely converting to Python `Decimal` and PostgreSQL `NUMERIC(10, 2)`. |
| **Accidental Product Deletion in Master** | Historical visits or orders could lose their foreign references. | **Referential Integrity & Soft Archive:** RG WIN references the integer `healix_product_id`. If a product is removed from the upstream catalog, RG WIN marks it as `ARCHIVED` in `product_references`, preserving historical visit and sales records. |

---

## 7. RG WIN Integration Schema (`product_references`)

```sql
CREATE TABLE product_references (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    healix_product_id INTEGER NOT NULL UNIQUE,
    cached_name VARCHAR(255) NOT NULL,
    cached_category VARCHAR(100),
    cached_mrp NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    cached_image_url VARCHAR(512),
    cached_description TEXT,
    cached_ingredients JSONB DEFAULT '[]'::jsonb,
    cached_benefits JSONB DEFAULT '[]'::jsonb,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    last_synced_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_references_healix_id ON product_references(healix_product_id);
CREATE INDEX idx_product_references_name ON product_references(cached_name);
CREATE INDEX idx_product_references_category ON product_references(cached_category);
CREATE INDEX idx_product_references_status ON product_references(status);
```

---

## 8. Summary for Phase 0 Sign-Off

Phase 0 verification is **100% complete**:
- Upstream catalog inspected and verified live.
- OpenAPI specification parsed and validated.
- All 31 active pharmaceutical products verified with zero null values across core fields.
- Public read-only access verified without credential leakage.
- Strict ownership boundary established: zero product management endpoints inside RG WIN.
- Three-tier caching and offline synchronization architecture designed.

**Phase 0 is complete and ready for verification before Phase 1 implementation.**
