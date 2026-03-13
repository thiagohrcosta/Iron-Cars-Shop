# Iron Cars Shop

## Analytics + Subscription (Stripe) setup

This project now includes a paid Analytics area for user accounts.

### Plans
- **Iron Cars Pro** — `$19/month` (up to 5 listed cars)
- **Iron Cars Premium** — `$49/month` (more than 5 listed cars)
- **Iron Cars Premium AI** — `$69/month` (same as Premium + AI insights)

### Access rules
- Route: `GET /user/analytics`
- If the user has an active subscription, they can see the analytics dashboard.
- If not, they see the paywall with monthly plan options.

### Stripe environment variables
Add these values to your `.env`/deployment secrets:

```bash
STRIPE_SECRET_KEY=sk_live_or_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

### Stripe product/price requirements
Create 3 recurring monthly prices in Stripe and set **lookup keys** exactly as:

- `iron_cars_pro_monthly`
- `iron_cars_premium_monthly`
- `iron_cars_premium_ai_monthly`

### Webhook
Configure Stripe webhook endpoint:

- `POST /webhooks/stripe`

Recommended events:

- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`

### Database
Run migrations:

```bash
bin/rails db:migrate
```

This creates the `subscriptions` table and adds Stripe customer support on `users`.

### Performance notes
- Analytics data loading uses eager loading with `includes(:vehicle_listing)` to reduce query count and avoid N+1 patterns.
- Data aggregation is computed in-memory from preloaded collections for current dashboard cards.
