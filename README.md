# 🧾 Mini POS Checkout - Flutter BLoC Task

This project is a Flutter-based point-of-sale (POS) checkout system built using BLoC.  
It fulfills all the assessment requirements for a Senior Flutter Engineer role.

---

## 🔧 Environment

- **Flutter SDK**: 3.29.3 (channel stable)
- **Dart**: 3.7.2

---

## 🚀 How to Run

```
flutter pub get
flutter run
```

## 🧪 How to Run Tests

```
flutter test
```

---

## ✅ Requirements Coverage

### 📦 CatalogBloc
- Loads from `assets/catalog.json`.
- Emits `CatalogLoading`, `CatalogLoaded`, and `CatalogError`.

### 🛒 CartBloc
- Adds, removes, changes quantity/discount.
- Emits updated `CartState` with live `totals`.

### 🧮 Business Rules
- `lineNet = price × qty × (1 – discount)`
- `VAT` = 15%
- `Totals = subtotal + VAT`

### 🧾 Receipt
- Receipt built via `buildReceipt(...)`.
- Checkout shows dialog with:
    - Date & time
    - Line items
    - Total price

### 🧪 Testing
- Includes `cart_bloc_test.dart` and `catalog_bloc_test.dart`.
- All tests pass using `bloc_test` package.

### 🎨 UI (Bonus)
- Product catalog on the left.
- Cart on the right.
- Checkout button styled.
- Receipt shown as flat dialog (no corners).

---

## ⏱️ Time Spent

- Total time: ~5 hours
- All features implemented, no skipped items.

---

## 📁 Structure

```
lib/
└── src/
    ├── catalog/
    │   ├── catalog_bloc.dart
    │   └── item.dart
    ├── cart/
    │   ├── cart_bloc.dart
    │   ├── models.dart
    │   └── receipt.dart
test/
├── catalog_bloc_test.dart
└── cart_bloc_test.dart
```
