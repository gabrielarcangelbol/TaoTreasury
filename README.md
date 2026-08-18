### README.md (English) — copy this into `README.md`

# TaoTreasury

**TaoTreasury** is a lightweight web application to **register, reconcile and share payments and balances** across multiple custodians and payment routes (Zelle, Binance, cash, mobile payments, bank deposits). It focuses on treasury tracking, multi‑currency conversion, and auditability for small businesses and startups.

## Key features
- **Register payments** with date, payer, reference, method, custodian, currency and notes.  
- **Multi‑currency support** with stored exchange rates and consolidated balances.  
- **Custody tracking** (assign funds to custodians like Gabriel / Jefferson).  
- **Transaction history** with filters (date, account, method, status).  
- **Export CSV** for accounting and audits.  
- **User roles** (owner, partner, viewer) and secure sharing.  
- **Prototype-first approach**: single‑file HTML prototypes that can be migrated to a full stack.

## Quick start
1. Place your HTML prototypes in `/frontend` (recommended filenames: `index.html`, `payment_app_v2.html`, `payment_app_v3.html`, `payment_app_v4.html`).  
2. For a quick local test, open `index.html` in your browser or run a simple server:
   ```bash
   python -m http.server 8000
   # open http://localhost:8000
   ```
3. Use the repo as a starting point for adding a backend, DB and auth when ready.

## Suggested repo structure
```
/TaoTreasury
  /frontend
    index.html
    payment_app_v2.html
    payment_app_v3.html
    payment_app_v4.html
  /backend        # future: API, auth, DB
  README.md
  .gitignore
  CHANGELOG.md
  CONTRIBUTING.md
```

## Data model overview
- **User**: id, name, email, hashed_password, role  
- **Account**: id, name, type (Zelle, Binance, Cash, Mobile, Bank), currency, initial_balance  
- **Transaction**: id, account_id, type (income, expense, transfer), amount, currency, date, reference, payer, custodian, category, notes, created_by  
- **Transfer**: id, from_account_id, to_account_id, amount, fees, date, notes  
- **ExchangeRate**: id, from_currency, to_currency, rate, date

## Security and operations
- **Keep repo private** while integrating real accounts or API keys.  
- **Never commit secrets**; use `.env` locally and GitHub Secrets for CI.  
- **Store API keys** in GitHub Secrets (e.g., `BINANCE_API_KEY`).  
- **Audit log**: store `created_by` and `updated_by` for every transaction.  
- **Protect `main`** branch and require PR reviews before merging.

## Next steps roadmap (MVP)
1. Stabilize a single prototype (`payment_app_v4.html` → `index.html`).  
2. Add minimal backend with endpoints: `POST /payments`, `GET /payments`, `GET /balances`.  
3. Implement auth and roles.  
4. Create DB schema and migrations.  
5. Add CSV import/export and reconciliation UI.

---