# 🚗 Iron Cars Shop

A full-featured vehicle marketplace platform with **AI-driven lead generation**, **automatic offer matching**, **an integrated negotiation CRM**, and a **paid analytics dashboard (Stripe subscriptions)**.

> Buying and selling a car should feel easy, clear, and secure.

![Iron Cars Shop](https://github.com/user-attachments/assets/af48828e-e076-4811-abf3-7afb28720632)

---

## 📌 About the project

Iron Cars Shop connects car buyers and sellers by automating the slowest parts of a traditional marketplace: **lead qualification**, **matching against the right inventory**, and **negotiation**.

The flow was designed to reduce friction at every step:

1. **AI chatbot capture** — A conversational assistant on the landing page asks questions to identify the vehicle the visitor is looking for (make, model, budget, location, etc.) and collects their contact information.
2. **Automatic lead creation** — Using the collected data, the system generates a structured lead that enters the queue in the **admin panel**.
3. **AI-powered distribution** — From the admin panel, an operator can trigger automatic distribution: the AI scans the vehicle database and looks for the **best matching offer** for that lead's profile.
4. **Match & notification** — Once a match is found, the buyer receives a **match email**, and the buyer and seller are connected directly within the platform.
5. **CRM negotiation** — Inside the user area, buyer and seller can chat, adjust terms, and the buyer can submit **bids (offers)** until a deal is closed.

---

## ✨ Key features

### 🤖 AI-powered lead funnel
- Conversational chatbot for lead qualification on the landing page
- Structured intent extraction (make, model, price range, etc.)
- Automatic lead creation from the conversation

### 🗂️ Admin Panel (Leads CRM)
- Real-time metrics dashboard: total leads, new leads today, open negotiations, revenue potential
- Visual Kanban pipeline by status: **New → Contacted → Negotiation → Won / Lost**
- AI-assisted lead distribution, searching for the best matching offer in the inventory
- Filters by status, sales agent, and date range

### 🔄 Automatic matching
- Recommendation engine that cross-references lead criteria against available vehicles in the database
- Automatic email notification to the buyer when a match is found

### 💬 Negotiation CRM (user area)
- Conversations organized by vehicle/negotiation
- Offer history (sent, rejected, and accepted offers)
- Negotiation status (e.g., accepted, vehicle reserved for N days)

### 💳 Analytics + Subscription (Stripe)
Paid analytics area for sellers, with recurring plans:

| Plan | Price | Benefits |
|---|---|---|
| **Iron Cars Pro** | $19/month | Up to 5 listed cars |
| **Iron Cars Premium** | $49/month | More than 5 listed cars |
| **Iron Cars Premium AI** | $69/month | Everything in Premium + AI insights |

- Route: `GET /user/analytics`
- Users with an active subscription can access the dashboard; without one, they see the paywall with plan options.

---

## 🖼️ Screenshots

**Landing page with lead-qualification chatbot**
> AI assistant identifies the desired vehicle and collects the visitor's contact information.
<img width="1917" height="900" alt="Captura de tela 2026-07-20 104811" src="https://github.com/user-attachments/assets/e193ba91-301b-4c16-bd42-2a4afd0111ae" />

**Leads Management (Admin)**
> Kanban pipeline with leads across New, Contacted, Negotiation, Won, and Lost, plus revenue potential metrics.
<img width="1917" height="940" alt="Captura de tela 2026-07-20 105228" src="https://github.com/user-attachments/assets/35c5571a-410b-4a0a-be20-01716f441104" />

**Negotiations (user area)**
> Negotiation chat between buyer and seller, with offer history and transaction status.
<img width="1917" height="955" alt="image" src="https://github.com/user-attachments/assets/017b264e-3793-413a-b80d-efa9c39c96da" />

---

## 🏎️ Performance & architecture

The system was designed to handle high data volume and request throughput with fast, lean queries:

- **Eager loading** (`includes(:vehicle_listing)`) to avoid **N+1** issues when loading analytics data
- **In-memory aggregation** from preloaded collections, avoiding multiple database round-trips to build the dashboard cards
- Backend queries optimized for high-traffic scenarios

---

## ⚙️ Tech stack

> Adjust this section to match the project's actual technologies.

- **Backend:** Ruby on Rails
- **Database:** PostgreSQL (or the DBMS in use)
- **Payments:** Stripe (recurring subscriptions)
- **AI:** chatbot engine + lead-matching engine

---

## 🔧 Configuration

### Environment variables (Stripe)

Add these values to your `.env`/deployment secrets:

```bash
STRIPE_SECRET_KEY=sk_live_or_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

### Produtos/preços no Stripe

Crie 3 preços recorrentes mensais no Stripe com as seguintes **lookup keys**:

- `iron_cars_pro_monthly`
- `iron_cars_premium_monthly`
- `iron_cars_premium_ai_monthly`

### Webhook

Configure o endpoint de webhook do Stripe:

- `POST /webhooks/stripe`

Eventos recomendados:
- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`

### Banco de dados

Rode as migrações:

```bash
bin/rails db:migrate
```

Isso cria a tabela `subscriptions` e adiciona suporte a cliente Stripe na tabela `users`.

---

## 🚀 Rodando localmente

```bash
# clone o repositório
git clone <url-do-repositorio>
cd iron-cars-shop

# instale as dependências
bundle install

# configure o banco
bin/rails db:setup

# rode as migrações
bin/rails db:migrate

# inicie o servidor
bin/rails server
```

---

## 📄 Licença

Defina aqui a licença do projeto (ex: MIT).
