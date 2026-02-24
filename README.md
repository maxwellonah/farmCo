# FarmConnect NG (Flutter)

## Runtime Adapter Mode

The app now supports two service backends through `AppServices`:

- `AppServices.api(...)` (default)
- `AppServices.inMemory()` (demo/local fallback)

Configured in `lib/app/app.dart` using compile-time flags:

- `FARMCONNECT_USE_IN_MEMORY` (`true` or `false`, default `false`)
- `FARMCONNECT_API_BASE_URL` (default `http://localhost:8080/api`)

## Run Examples

Use REST adapter (default):

```bash
flutter run --dart-define=FARMCONNECT_API_BASE_URL=http://localhost:8080/api
```

Use in-memory adapter:

```bash
flutter run --dart-define=FARMCONNECT_USE_IN_MEMORY=true
```

## Adapter Location

REST adapter implementation is in:

- `lib/core/services/api/`

Service contracts are in:

- `lib/core/services/`
