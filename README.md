# Reformly Flutter App

Flutter mobile app consuming the Shopify Storefront API.

Built as a technical demo for Reformly — demonstrating a headless commerce architecture where a Flutter app and a Next.js storefront share the same Shopify backend.

## Stack

- **Flutter** — cross-platform mobile (iOS + Android)
- **Shopify Storefront API** — GraphQL via http package
- **Provider** — state management for cart
- **shared_preferences** — cart persistence across sessions
- **url_launcher** — native checkout handoff

## Features

- Product listing — fetches live from Shopify
- Product detail with variant selector
- Add to cart with loading states
- Cart persistence — survives app backgrounding and restarts
- Checkout handoff — opens Shopify native checkout in browser
- Warm editorial UI — cream, terracotta, clean typography

## Architecture
```
/lib
  main.dart
  models/
    product.dart         → typed product + variant models
    cart.dart            → typed cart + line item models
  services/
    shopify_service.dart → GraphQL client, all queries + mutations
    deep_link_service.dart → checkout handoff + deep link handling
  state/
    cart_provider.dart   → ChangeNotifier, cart lifecycle
  screens/
    product_list.dart    → product grid
    product_detail.dart  → detail + variant selector + add to cart
    cart.dart            → cart screen + checkout CTA
```

## Cart Persistence

Cart ID stored in shared_preferences. On app launch, CartProvider checks for an existing cart ID and hydrates from Shopify. Cart state lives on Shopify's servers — the device just holds a reference.

## Checkout Handoff

The checkoutUrl returned by every cart mutation is passed to url_launcher which opens Shopify's native checkout in the device browser. This is the same URL used by the web storefront — enabling cart recovery flows across both surfaces.

## Setup
```bash
flutter pub get
```

Update credentials in `lib/services/shopify_service.dart`:
```dart
static const String _storeDomain = 'your-store.myshopify.com';
static const String _storefrontToken = 'your_token';
```
```bash
flutter run
```

## Related

- [Reformly Storefront](https://github.com/sa3oud/reformly-storefront) — companion Next.js web app on the same Storefront API

---

Built by [Saad Sahmad](https://github.com/sa3oud) · North Digital
