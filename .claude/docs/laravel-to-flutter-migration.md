# Laravel → Flutter feature migration playbook

Reference for porting API endpoints from the Laravel project
(`C:\clearance-marketplace-admin`) into this Flutter app (`rdb`,
`d:\Ramaaz_Digital_Bank\rdb`). Only Laravel **`api/` routes** are in scope
(`mobile/*`, `web/*`, `customer/*`, and the shared resource groups).

Used by the `/migrate-feature` command. The flow is always:
**read the Laravel vertical slice → propose a plan → get approval → implement
across the Flutter layers with cleaner Dart code → analyze & test.**

---

## A. Laravel side — locate an endpoint's vertical slice

Given a URI (e.g. `mobile/product/details/{slug}`), find its pieces in order:

1. **Route** — match the URI prefix to a file under `routes/api/v1/`:
   - `mobile.php` → `mobile/*` (mobile app)
   - `web.php` → `web/*` (website; product detail is split into
     `globalDetails`/`qtyPriceDetails`/`shippingDetails`/`simpleDetails`)
   - `customer.php` → authenticated `customer/*` (all `auth:api`)
   - `auth.php` → `auth/*` (OTP, register-guest, logout)
   - inline groups in `routes/api/v1/api.php` → shared `products/*`,
     `categories/*`, `brands/*`, `cart/*`, `flash-deals/*`, `banners/*`,
     `notifications/*`, `config`, …
   - The **entire v1 group runs under the `api_lang` middleware**
     (`App\Http\Middleware\APILocalizationMiddleware`) — reads `lang`/`country`
     headers, sets locale + currency. Routes are identified by URI, not by name.

2. **Controller** — the route gives `[SomeController::class, 'method']`. Resolve
   the `use` alias at the top of the route file, then open the controller under
   `app/Http/Controllers/api/v1/{Mobile,Web,Android,Auth,Order,Invoice,Shop,...}/`.
   - ⚠️ There are **three `ProductController`s** (Mobile / Web / Android), imported
     as `MobileProductController` / `WebProductController` / `AndroidProductController`.
     Match the alias to the folder.

3. **Validation** — a type-hinted `*Request` in the method signature →
   `app/Http/Requests/...` (base classes `ApiFormRequest` / `CustomFormRequest`;
   API-specific under `app/Http/Requests/api/v1/`). GET endpoints usually have
   none (input is a route param).

4. **Models** — check in this order:
   - `app/Domain/<Area>/.../Model/` — newer Eloquent models (Product, Category,
     Brand, Boutique, Color, Currency, Country).
   - `app/Model/` (singular, legacy) — Review, OldCart, OrderDetail, Attribute,
     ShippingMethod, HomeSection, Searcher, …
   - `app/Models/` (plural) — User, SellerUser, `*Log` audit models.

5. **Response shape** — a `SomethingResource::make(...)` / `::collection(...)` →
   `app/Resources/v1/...` (**NOT** `app/Http/Resources`, which is mostly unused).
   Mobile/web resources are separated (`app/Resources/v1/Mobile/...`,
   `.../Pos/`, `.../QuickProductsEditing/`). The resource's `toArray()` is the
   authoritative field list to reproduce.

6. **Heavy logic** — thin controllers delegate to `app/CPU/*Manager.php`
   (`ProductManager`, `CartManager`, `OrderManager`, `CategoryManager`,
   `ImageManager`, `Helpers`) or `app/Services/*` (`ProductService`,
   `CurrencyConverter`). Read there for the real behavior, not just the controller.

---

## B. Cross-cutting mappings (apply on every migration)

### Response envelope
Laravel `Helpers::sendSuccess($msg, $data)` (`app/CPU/Helpers.php`) returns:
```json
{ "isSuccessful": true, "hasContent": true, "code": 200,
  "message": "...", "detailed_error": null, "data": { } }
```
Flutter equivalent — the datasource sends the dio request through the app's HTTP
client (`GetClient`/`PostClient`/… in `lib/core/api/methods/`) and reads the
result through **`ResponseValue`**, the response wrapper that exposes
`isSuccessful` / `code` / `message` / `data`. On success it extracts `data` and
maps it into a `*_model.dart` via `fromJson`; the same envelope keys are honoured
exactly as Laravel emits them.

Errors: a non-success envelope or a dio failure is thrown as a typed exception in
the datasource (e.g. `ServerException`, `UnauthorizedException`,
`NetworkException`), then mapped in the repository impl to a dartz `Failure`
(`Left(...)`) — `ServerFailure`, `AuthFailure`, `NetworkFailure`, etc. Never let a
raw dio exception escape the data layer; the UI only ever sees `Either<Failure,T>`.

### Localization
- Laravel resolves locale from the `lang` / `country` request headers via the
  `api_lang` middleware; `translate($key)` handles UI strings; **content**
  translations use the `custom*` relation pattern (`customProducts`,
  `customCategories`, `customBoutiques`, `customBrands`, `customColors`) keyed by
  `language_code`, with base-name fallback.
- Flutter mirrors this exactly: the `lang` / `country` headers are attached by a
  **dio interceptor** (via `RequestConfig`) from the user's selected locale, and
  content the backend already localizes arrives pre-resolved in `data`. The app's
  own UI strings use **easy_localization**: `"<key>".tr()` with the keys living in
  `assets/languages/*.json`.
- Defaults: language `en`, country `tr` (Cart is the exception — country defaults
  to `us`), matching the Laravel edge.
- **UI strings — `translate("…")` / `__("…")` → `"…".tr()`.** Any string the
  Laravel slice runs through `translate()` (response/success/error messages,
  labels) MUST be resolved through easy_localization in Flutter — **never**
  hard-code the raw literal into a widget. Keep the **same message key**; it both
  keys the translation and is the fallback when the key is absent from the bundle,
  exactly matching Laravel's `translate()`. Resolve it in the presentation layer
  (page/widget) where the `BuildContext`/locale is available. Example:
  `Text("Data Got!".tr())`.
- **Seed the key into all language bundles.** Every `"<key>".tr()` MUST be present
  in **all** `assets/languages/*.json` bundles, or that language falls back to the
  raw key and parity breaks. Copy the **authentic** values from Laravel's
  `resources/lang/<lang>/messages.php` (entry `'<key>' => '…'`) verbatim; when
  Laravel lacks a translation/dir for a language, mirror its fallback and use the
  key itself as the value. Keep each file valid JSON and confirm the key resolves
  in every language. Example (`"Data Got!"`): en `"Data Got!"`, ar
  `"تم الحصول على البيانات!"`, tr `"Veri Alındı!"`, ku `"Data Got!"` (fallback).

### Auth
- Laravel `->middleware('auth:api')` (Passport) → Flutter: the endpoint is called
  with the bearer token attached automatically by the **dio auth interceptor**,
  which reads the token from **secure storage** (`prefs_repository` /
  `prefs_repository_impl.dart`). The datasource sets any per-request auth needs via
  `RequestConfig`; no token is ever hand-passed through UI code.
- Public Laravel route → Flutter call with no auth header (public `RequestConfig`).
- Auth failures surface as `401`/`403` in the envelope → mapped to an
  `AuthFailure` and **handled and surfaced in the UI** (session expiry, re-auth
  prompt) — never swallowed.

---

## C. Flutter side — file-by-file checklist (dependency order)

Reference slice to copy: `getUserProfile`
(`auth_remote_datasource.dart` → `auth_repository_impl.dart` →
`get_user_profile_usecase.dart` → **AuthBloc**).

- **New method on an existing feature** (e.g. another authentication endpoint):
  steps 1–6, 7, 8, 9, 10 (reuse the existing datasource/repository/bloc; add the
  method/event/state).
- **Brand-new feature area**: all steps.

0. **Contract gate.** If the endpoint's request/response contract or its model is
   **ambiguous** — the Laravel `Resource::toArray()` field list is unclear, or the
   shape can't be determined from the source — **STOP and ask** the operator. Do
   **not** invent or guess response fields, defaults, or types. Wait for the
   authoritative contract before writing the model. (See `/migrate-feature`
   Step 2.5.)
1. **`data/models/<entity>_model.dart`** — hand-written model whose `fromJson`
   mirrors the Laravel Resource `toArray()` field list **EXACTLY** (same keys,
   same nesting, same nullability/defaults). Add `toJson` for request bodies
   (POST/PUT/PATCH). Use `json_serializable` (`@JsonSerializable()`) only where the
   codebase already does; otherwise stay hand-written for parity clarity.
2. **`common/constant/configuration/<area>_url_routes.dart`** — add the endpoint
   path as a constant (mirrors the Laravel URI, e.g.
   `static const getUserProfile = "/api/v1/customer/profile";`). Group by area
   (`auth_url_routes.dart`, `wallet_url_routes.dart`, `kyc_url_routes.dart`, …).
3. **`data/data_sources/<feature>_remote_datasource.dart`** (`@injectable`) — add
   the call: pick `GetClient`/`PostClient`/`PatchClient`/`PutClient`/`DeleteClient`
   (`lib/core/api/methods/`), pass a `RequestConfig` (path, headers, auth, body),
   the correct `ServerName`, and read the result through `ResponseValue`; on
   success map `data` → `<Entity>Model.fromJson`, on a non-success envelope /
   dio error throw the typed exception. Conventions: interface + `@injectable`
   impl, constructor-injected client(s).
4. **`domain/repositories/<feature>_repository.dart`** — add the method to the
   repository **interface**, returning `Future<Either<Failure, T>>` (dartz).
5. **`data/repositories/<feature>_repository_impl.dart`** — implement it: call the
   datasource inside a try/catch, return `Right(model)` on success and map thrown
   exceptions → the matching **`Failure`** on error (`Left`). No transport types
   leak upward.
6. **`domain/use_cases/<action>_usecase.dart`** (`@injectable`) — a
   `UseCase<T, Params>` that calls the repository method; define a `Params` class
   for inputs, or use `NoParams` when there are none. One use case = one action
   (e.g. `GetUserProfileUseCase`).
7. **`presentation/manager/auth_event.dart` + `auth_state.dart` +
   `auth_bloc.dart`** — route the feature through the **SINGLE `AuthBloc`**: add an
   event (`auth_event.dart`), the loading/success/failure states
   (`auth_state.dart`), and a handler in `auth_bloc.dart` that calls the use case
   and emits states from the `Either` result. **Do NOT create a new Bloc/Cubit** —
   a parallel bloc is an architecture violation and is `high_risk`.
8. **`presentation/pages|widgets`** — consume the state via `BlocBuilder` /
   `BlocListener` on `AuthBloc`: dispatch the event, render loading/success/error,
   and surface auth failures (401/403) in the UI.
9. **Run `dart run build_runner build --delete-conflicting-outputs`** — regenerates
   DI wiring (`*.config.dart`, `lib/core/di/di_container.config.dart`) for the new
   `@injectable` datasource/use case and any `json_serializable` `*.g.dart`.
   **Never hand-edit generated code** — always regenerate.
10. **Localization** — every Laravel `translate("x")` / `__("x")` in the slice →
    `"x".tr()` (easy_localization), with the key seeded into **all**
    `assets/languages/*.json` bundles (authentic values from Laravel's
    `resources/lang/<lang>/messages.php`; key-as-fallback where a language is
    missing).

---

## D. Conventions to preserve

- Layering `presentation (AuthBloc) → use case → repository interface →
  repository impl → remote datasource → api client (dio)`; each layer depends on
  the **interface** above/below it, wired once by `get_it` + `injectable`
  (`build_runner`-generated DI).
- **Single AuthBloc.** All feature state routes through the one `AuthBloc` in
  `lib/features/authentication/presentation/manager/`. Never add a parallel
  Bloc/Cubit — it is an architecture violation and a high-risk change.
- **Functional errors.** The data/domain layers speak `Either<Failure, T>`
  (dartz); exceptions are caught at the repository impl and mapped to `Failure`.
  The UI never handles raw exceptions.
- **Auth/session scoping.** A user only ever accesses their own account/session;
  tokens/passcodes/biometric state come from secure storage and are never leaked
  or cross-used. Money/KYC calls are authorized and scoped to the authenticated
  user.
- **Preserve Laravel parity** — name the PHP source in a Dart doc-comment
  (e.g. `/// Mirrors PHP ProductManager::get_product`). Same request/response
  shape, same fields, defaults, arguments, and edge cases. If the source looks
  wrong, **STOP and ask** — do not silently "fix" behavior. Reuse existing
  models/use cases/clients rather than duplicating them.
- **Update CLAUDE.md** — add/adjust the "Modules (Backbones)" entry when a new
  feature/module lands (self-maintenance note).
- **Validation commands: `flutter analyze` and `flutter test` only.**
  Do **not** hand-edit generated files (`*.g.dart`, `*.config.dart`); regenerate
  them with `dart run build_runner build --delete-conflicting-outputs`.

---

## E. Governance flag

The repo's own governance (`.claude/project-config.yaml`, CLAUDE.md) marks
**auth/session/passcode, wallet/KYC/money, api/composition, and the single
AuthBloc as high-risk paths** normally requiring the formal `high_risk` workflow
(ADR + 2 approvals + rollback rehearsal). `/migrate-feature` deliberately uses a
**lightweight standalone flow** and bypasses that ceremony — acceptable for solo
incremental porting of read endpoints. **Call it out and recommend `high_risk`**
when a migration touches **money/wallet/KYC** (balances shown or money moved) or
**auth/session/passcode** (login/OTP/token/biometric), or would introduce a new
Bloc; those genuinely warrant the heavier review.
