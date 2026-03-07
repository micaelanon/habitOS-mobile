# habitOS Mobile — Análisis Estratégico y Plan de Construcción

> **Versión**: 1.0  
> **Fecha**: 2026-03-07  
> **Propósito**: Estudio exhaustivo del estado actual del mock iOS, plan de construcción dual-mode (B2C autónomo + B2B gestionado por nutricionista), y hoja de ruta técnica completa.

---

## ÍNDICE

1. [Estado Actual del Mock — Inventario](#1-estado-actual-del-mock--inventario)
2. [Diagnóstico: Qué Hay y Qué Falta](#2-diagnóstico-qué-hay-y-qué-falta)
3. [Modelo de Negocio Dual — La Gran Decisión](#3-modelo-de-negocio-dual--la-gran-decisión)
4. [Arquitectura Técnica Propuesta](#4-arquitectura-técnica-propuesta)
5. [Sistema de Roles y Permisos (RBAC)](#5-sistema-de-roles-y-permisos-rbac)
6. [Modelo de Datos — Esquema Completo](#6-modelo-de-datos--esquema-completo)
7. [Pantalla por Pantalla — Lo que hay vs lo que debe haber](#7-pantalla-por-pantalla--lo-que-hay-vs-lo-que-debe-haber)
8. [El Panel del Nutricionista — Pieza Clave B2B](#8-el-panel-del-nutricionista--pieza-clave-b2b)
9. [Sistema de Chat — Doble cerebro](#9-sistema-de-chat--doble-cerebro)
10. [Integraciones Técnicas](#10-integraciones-técnicas)
11. [Monetización y Tiers](#11-monetización-y-tiers)
12. [Hoja de Ruta por Fases](#12-hoja-de-ruta-por-fases)
13. [Riesgos y Mitigaciones](#13-riesgos-y-mitigaciones)
14. [Decisiones Inmediatas Requeridas](#14-decisiones-inmediatas-requeridas)

---

## 1. Estado Actual del Mock — Inventario

### 1.1 Lo que existe (33 archivos)

| Capa | Archivos | Estado |
|------|----------|--------|
| **App Entry** | `HabitOSUserDashboardApp.swift`, `ContentView.swift` | ✅ Funcional, TabView con 5 tabs |
| **Design System** | `Color+Brand.swift`, `Components.swift` | ✅ Excelente — paleta "lujo silencioso" (Vanilla/Ink/Sage/Line), tokens, componentes reutilizables |
| **Views** | `DashboardHomeView`, `MealPlanView`, `ChatView`, `ProgressChartView`, `ProfileView`, `HabitTrackerView` | ✅ Todas con diseño pulido, staggered animations, brand-aligned |
| **Models** | `UserProfile`, `DashboardModels`, `MacroSummary`, `MealPlan`, `Habit`, `StreakPoint` | ⚠️ Modelos básicos, sin Codable, sin relación con Supabase |
| **ViewModel** | `DashboardViewModel` | ⚠️ Usa `@Observable`, carga datos mock, lógica local |
| **Service** | `HabitOSDataService` | 🔴 100% hardcodeado, `Task.sleep()` simulando red, cero networking |
| **Config** | `Config.swift` | 🔴 Vacío, sin env vars ni Supabase URL |
| **Tests** | `UITests`, `UnitTests` | 🔴 Boilerplate de Xcode, sin tests reales |
| **Docs** | `HABITOS-IOS-APP-SPEC.md`, `brand-manual.html`, `README.md` | ✅ Brand Book HTML muy completo |
| **Xcode Project** | `project.pbxproj` | ✅ Compila, sin SPM dependencies |

### 1.2 Design System — Evaluación

El design system es **la joya del mock**. Está extremadamente bien hecho:

- **Paleta "Lujo Silencioso"**: Light mode con Vanilla (#F6F3EE), Sage (#6F7C68), Ink (#1C1D1A) — coherente con el Brand Book HTML
- **Tipografía editorial**: Georgia serif para headlines + SF Pro para body — decisión correcta para iOS
- **Componentes**: `HBCard`, `HBProgressRing`, `HBBadge`, `HBPrimaryButton`, `HBGhostButton`, `HBFloatingActionButton`, `HBWaterTracker`, `HBSectionHeader`, `HBLogoView`, `HBDivider`
- **Tokens**: Spacing, radius, shadows centralizados en `HBTokens`
- **Animaciones**: Staggered appear con `.staggered(index:)` modifier — elegante
- **Acento único**: Solo Sage, nada de multicolor — fiel al manifiesto

**Nota importante**: El mock usa modo CLARO (`.preferredColorScheme(.light)`), distinto del spec anterior que describía dark mode con `#0F0F0F`. La paleta Vanilla/Ink/Sage del Brand Book HTML es la correcta y la que el mock implementa. **Este es el camino a seguir**.

### 1.3 Lo que NO existe en absoluto

- ❌ Autenticación (login, signup, tokens)
- ❌ Networking real (Supabase Swift SDK)
- ❌ Persistencia local (no hay cache ni offline)
- ❌ Notificaciones push
- ❌ Escáner de alimentos
- ❌ HealthKit / Apple Watch
- ❌ Videollamada
- ❌ Lista de la compra
- ❌ Registro de peso / fotos corporales
- ❌ Diario/journal
- ❌ Deep linking
- ❌ Cualquier noción de "perfil nutricionista" o multi-tenant
- ❌ Modo B2C autónomo (IA genera todo sin nutricionista)

---

## 2. Diagnóstico: Qué Hay y Qué Falta

### Fortalezas (conservar)
1. **Design system maduro** — No tocar la paleta ni los componentes. Extender, no rehacer.
2. **Arquitectura MVVM limpia** — `@Observable` ViewModel + Views stateless es el patrón correcto.
3. **TabView 5 tabs** — La navegación base es sólida: Hoy / Dieta / Chat / Progreso / Perfil.
4. **Brand coherente** — El Brand Book HTML es un activo de altísimo valor. Tener esto resuelto ahorra semanas.
5. **FAB con acciones** — El floating button ya tiene las 4 acciones clave (Diario, Foto comida, Peso, Escáner).
6. **Swift moderno** — Usa Swift 5.10+, `@Observable`, structured concurrency (`async let`), `nonisolated` — correcto.

### Debilidades (arreglar)
1. **Sin SDK de Supabase** — El paquete `supabase-swift` (v2.41.1) no está instalado.
2. **Modelos no son Codable** — Los structs no implementan `Codable`, no se pueden serializar desde/hacia Supabase.
3. **Servicio mock** — `HabitOSDataService` es un fake completo.
4. **Sin autenticación** — No hay `AuthManager`, no hay persistencia de sesión.
5. **Sin estado offline** — No hay SwiftData ni cache local.
6. **Single-user hardcoded** — Todo apunta a "Micael García". No hay concepto de multi-user.
7. **`Item.swift` con SwiftData** — Archivo generado por Xcode template, SwiftData importado pero no usado.

### Lo que falta y es CRÍTICO
1. **Capa de autenticación completa** (login, signup, magic link, Sign in with Apple, refresh tokens)
2. **Capa de red real** (Supabase REST + Realtime para chat)
3. **Modelo multi-tenant** (clinic_id en todas las tablas, RLS policies)
4. **Modo dual B2C/B2B** — la feature definitoria del producto

---

## 3. Modelo de Negocio Dual — La Gran Decisión

### 3.1 Los dos modos

```
┌─────────────────────────────────────────────────────────────┐
│                      habitOS Mobile                         │
│                                                             │
│   ┌──────────────────────┐   ┌───────────────────────────┐  │
│   │    MODO AUTÓNOMO     │   │    MODO GESTIONADO        │  │
│   │      (B2C)           │   │      (B2B2C)              │  │
│   │                      │   │                           │  │
│   │ • Usuario se registra│   │ • Nutricionista compra    │  │
│   │ • Rellena assessment │   │   plan habitOS            │  │
│   │ • IA genera plan     │   │ • Invita a sus clientes   │  │
│   │ • IA es el coach     │   │ • Crea/asigna planes      │  │
│   │ • Chat con IA 24/7   │   │ • Chat humano + IA assist │  │
│   │ • Sin nutricionista  │   │ • Videollamada incluida   │  │
│   │                      │   │ • Panel de gestión web    │  │
│   │ Free / $9.99/mes     │   │ $99–$299/mes la clínica   │  │
│   └──────────────────────┘   └───────────────────────────┘  │
│                                                             │
│              ⬆ MISMA APP iOS, MISMA CODEBASE ⬆              │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Cómo conviven los dos modos

**El secreto: la app del CLIENTE es idéntica.** Lo que cambia es quién está detrás.

| Aspecto | Modo Autónomo (B2C) | Modo Gestionado (B2B) |
|---------|--------------------|-----------------------|
| **Quién genera el plan** | IA (GPT via Edge Function) | Nutricionista (con asistencia IA) |
| **Quién responde al chat** | IA siempre | Nutricionista + IA fallback |
| **Branding en app** | habitOS default | Logo/colores de la clínica (white-label) |
| **Nombre del coach** | "Mery (IA Coach)" | Nombre real del nutricionista |
| **Videollamada** | No disponible | Sí (Daily.co / Agora) |
| **Panel web** | No existe | Dashboard del nutricionista |
| **Precio para usuario** | $0–$9.99/mes directo | Gratis (lo paga la clínica) |
| **Assessment** | Formulario web existente | Formulario web + datos extra añadidos por nutricionista |

### 3.3 Decisión técnica fundamental

**UNA sola app iOS → con un flag `accountMode` que determina el comportamiento.**

```swift
enum AccountMode: String, Codable {
    case autonomous  // B2C: IA lo gestiona todo
    case managed     // B2B: nutricionista detrás
}
```

Este flag viene del backend. Cuando un usuario se registra:
- Si se registra solo → `autonomous`
- Si un nutricionista lo invita → `managed` + `clinic_id` + `nutritionist_id`

La app lee `accountMode` y adapta:
- Si `autonomous`: el chat muestra "Mery (IA)" y el botón de videollamada no aparece
- Si `managed`: el chat muestra el nombre real del nutricionista, videollamada disponible, branding custom

### 3.4 Por qué este enfoque es correcto

1. **Una sola codebase.** No mantienes dos apps.
2. **Migración sencilla.** Un usuario B2C puede "upgradear" a B2B si un nutricionista lo adopta, sin reinstalar.
3. **El nutricionista no necesita app iOS.** Su herramienta es web (Next.js existente o nueva).
4. **El usuario final no nota la diferencia.** Misma experiencia premium.
5. **Escalable.** Cada clínica es un `clinic_id`, cada nutricionista un `nutritionist_id`. RLS maneja el aislamiento.

---

## 4. Arquitectura Técnica Propuesta

### 4.1 Stack definitivo

```
┌──────────────────────────────────────────────────┐
│                   CLIENTE iOS                     │
│                                                   │
│  Swift 5.10+ / SwiftUI / iOS 17+                 │
│  Supabase Swift SDK v2.41.1                      │
│  @Observable MVVM                                │
│  SwiftData (cache offline)                       │
│  HealthKit / AVFoundation                        │
│  Swift Charts / Swift Dependencies               │
└────────────────────┬─────────────────────────────┘
                     │
                     │ HTTPS + WSS (Realtime)
                     │
┌────────────────────▼─────────────────────────────┐
│                   SUPABASE                        │
│                                                   │
│  Auth (email, magic link, Apple Sign-In)         │
│  PostgREST (API REST automática sobre Postgres)  │
│  Realtime (WebSocket para chat)                  │
│  Storage (fotos corporales, fotos comida)         │
│  Edge Functions (Deno/TS):                       │
│    • generate-plan (IA → plan nutricional)       │
│    • ai-chat-reply (IA → respuesta de chat)      │
│    • process-barcode (Open Food Facts lookup)    │
│    • send-push (vía APNs)                        │
│  Row Level Security (RLS) en todas las tablas    │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│              PANEL WEB NUTRICIONISTA              │
│                                                   │
│  Next.js (web app existente, extendida)          │
│  Supabase JS SDK                                 │
│  Dashboard de clientes, planes, chat, métricas   │
│  Solo para modo B2B                              │
└──────────────────────────────────────────────────┘
```

### 4.2 Estructura de carpetas objetivo

```
habitOS-mobile/
├── habitOS-mobile/
│   ├── App/
│   │   ├── HabitOSApp.swift              // @main, enrutamiento auth
│   │   └── AppState.swift                // Estado global: auth, account mode
│   │
│   ├── Core/
│   │   ├── Color+Brand.swift             // ✅ EXISTE — mantener
│   │   ├── Components.swift              // ✅ EXISTE — extender
│   │   ├── Typography.swift              // Nuevos helpers tipográficos
│   │   └── Haptics.swift                 // Feedback háptico brand
│   │
│   ├── Config/
│   │   ├── Config.swift                  // ⚠️ EXISTE — rellenar con env vars
│   │   ├── SupabaseClient.swift          // NUEVO: singleton del SDK
│   │   └── Constants.swift               // URLs, keys, feature flags
│   │
│   ├── Auth/
│   │   ├── AuthManager.swift             // NUEVO: sesión, tokens, estado
│   │   ├── LoginView.swift               // NUEVO: pantalla de login
│   │   ├── SignUpView.swift              // NUEVO: registro
│   │   ├── OnboardingView.swift          // NUEVO: assessment rápido
│   │   └── MagicLinkView.swift           // NUEVO: verificación magic link
│   │
│   ├── Models/                           // Todos Codable + Sendable
│   │   ├── AppUser.swift                 // NUEVO: reemplaza UserProfile
│   │   ├── Clinic.swift                  // NUEVO: datos de clínica
│   │   ├── NutritionPlan.swift           // NUEVO: plan completo
│   │   ├── MealPlan.swift                // ⚠️ EXISTE — hacer Codable
│   │   ├── DailyTask.swift               // ⚠️ EXISTE — hacer Codable
│   │   ├── ChatMessage.swift             // ⚠️ EXISTE — hacer Codable
│   │   ├── WeightLog.swift               // NUEVO
│   │   ├── BodyPhoto.swift               // NUEVO
│   │   ├── JournalEntry.swift            // NUEVO
│   │   ├── FoodScan.swift                // NUEVO
│   │   ├── ShoppingList.swift            // NUEVO
│   │   ├── Habit.swift                   // ⚠️ EXISTE — hacer Codable
│   │   ├── StreakPoint.swift              // ⚠️ EXISTE — hacer Codable
│   │   └── MacroSummary.swift            // ⚠️ EXISTE — hacer Codable
│   │
│   ├── ViewModels/
│   │   ├── DashboardViewModel.swift      // ⚠️ EXISTE — refactor con Supabase
│   │   ├── ChatViewModel.swift           // NUEVO: Realtime chat
│   │   ├── MealPlanViewModel.swift       // NUEVO
│   │   ├── ProgressViewModel.swift       // NUEVO
│   │   ├── ProfileViewModel.swift        // NUEVO
│   │   ├── ScannerViewModel.swift        // NUEVO: barcode + Open Food Facts
│   │   └── ShoppingListViewModel.swift   // NUEVO
│   │
│   ├── Services/
│   │   ├── HabitOSDataService.swift      // ⚠️ EXISTE — reescribir con SDK
│   │   ├── AuthService.swift             // NUEVO: wrapper sobre supabase.auth
│   │   ├── ChatService.swift             // NUEVO: Realtime subscription
│   │   ├── StorageService.swift          // NUEVO: subir fotos
│   │   ├── HealthKitService.swift        // NUEVO: pasos, peso, sueño
│   │   ├── NotificationService.swift     // NUEVO: APNs
│   │   └── BarcodeService.swift          // NUEVO: Open Food Facts API
│   │
│   ├── Views/
│   │   ├── Dashboard/
│   │   │   └── DashboardHomeView.swift   // ✅ EXISTE — mantener
│   │   ├── Diet/
│   │   │   ├── MealPlanView.swift        // ✅ EXISTE — mantener
│   │   │   └── ShoppingListView.swift    // NUEVO
│   │   ├── Chat/
│   │   │   ├── ChatView.swift            // ✅ EXISTE — conectar a Realtime
│   │   │   └── VideoCallView.swift       // NUEVO (solo modo managed)
│   │   ├── Progress/
│   │   │   ├── ProgressChartView.swift   // ✅ EXISTE — mantener
│   │   │   ├── WeightLogView.swift       // NUEVO
│   │   │   └── BodyPhotoView.swift       // NUEVO
│   │   ├── Profile/
│   │   │   └── ProfileView.swift         // ✅ EXISTE — extender con settings
│   │   ├── Scanner/
│   │   │   └── BarcodeScannerView.swift  // NUEVO
│   │   ├── Journal/
│   │   │   └── JournalView.swift         // NUEVO
│   │   └── Habits/
│   │       └── HabitTrackerView.swift    // ✅ EXISTE — mantener
│   │
│   └── Assets.xcassets/                  // ✅ EXISTE
│
├── Docs/
│   ├── HABITOS-IOS-APP-SPEC.md           // ✅ EXISTE
│   ├── HABITOS-APP-STRATEGY.md           // ← ESTE DOCUMENTO
│   └── brand-manual.html                 // ✅ EXISTE
│
└── habitOS-mobile.xcodeproj/
```

### 4.3 Dependencias SPM a añadir

| Paquete | Versión | Para qué |
|---------|---------|----------|
| `supabase-swift` | 2.41.1+ | Auth, Postgrest, Realtime, Storage, Functions |
| `swift-dependencies` | 1.0+ | Inyección de dependencias testable |
| `Nuke` | 12.0+ | Carga y cache de imágenes (fotos comida, avatares) |

**No añadir más.** HealthKit, AVFoundation, Charts, SwiftData son de sistema.

---

## 5. Sistema de Roles y Permisos (RBAC)

### 5.1 Roles definidos

```
┌──────────────────────────────────────────────────────┐
│ Rol                │ Ámbito        │ Privilegios      │
├────────────────────┼───────────────┼──────────────────┤
│ client_autonomous  │ Su propia     │ CRUD su data,    │
│                    │ data          │ chat con IA      │
├────────────────────┼───────────────┼──────────────────┤
│ client_managed     │ Su propia     │ CRUD su data,    │
│                    │ data          │ chat con nutri,  │
│                    │               │ videollamada     │
├────────────────────┼───────────────┼──────────────────┤
│ nutritionist       │ Sus clientes  │ CRUD plans de    │
│                    │ dentro de     │ sus clientes,    │
│                    │ su clínica    │ chat, asignar    │
│                    │               │ tareas, ver data │
├────────────────────┼───────────────┼──────────────────┤
│ clinic_admin       │ Toda la       │ Todo + gestionar │
│                    │ clínica       │ nutricionistas,  │
│                    │               │ facturación,     │
│                    │               │ branding         │
├────────────────────┼───────────────┼──────────────────┤
│ super_admin        │ Global        │ Todo (habitOS    │
│                    │               │ equipo interno)  │
└──────────────────────────────────────────────────────┘
```

### 5.2 Implementación en Supabase

El rol se almacena en `auth.users.raw_app_meta_data`:

```sql
-- Al registrar un cliente autónomo:
UPDATE auth.users SET raw_app_meta_data = 
  raw_app_meta_data || '{"role": "client_autonomous"}'::jsonb
WHERE id = NEW.id;

-- Al ser invitado por nutricionista:
UPDATE auth.users SET raw_app_meta_data = 
  raw_app_meta_data || '{
    "role": "client_managed",
    "clinic_id": "uuid-de-la-clinica",
    "nutritionist_id": "uuid-del-nutri"
  }'::jsonb
WHERE id = NEW.id;
```

### 5.3 RLS en la app (ejemplo clave)

```sql
-- Los clientes solo ven su propia data
CREATE POLICY "Clients see own data" ON nutrition_plans
  FOR SELECT USING (
    user_id = auth.uid()
  );

-- Los nutricionistas ven la data de sus clientes
CREATE POLICY "Nutritionists see client data" ON nutrition_plans
  FOR SELECT USING (
    user_id IN (
      SELECT id FROM app_users 
      WHERE nutritionist_id = auth.uid()
        AND clinic_id = (auth.jwt() -> 'app_metadata' ->> 'clinic_id')::uuid
    )
  );
```

---

## 6. Modelo de Datos — Esquema Completo

### 6.1 Tabla principal: `app_users`

```sql
CREATE TABLE app_users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Identity
  email TEXT NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  avatar_url TEXT,
  phone TEXT,
  
  -- Mode
  account_mode TEXT NOT NULL DEFAULT 'autonomous'
    CHECK (account_mode IN ('autonomous', 'managed')),
  
  -- B2B links (NULL for autonomous)
  clinic_id UUID REFERENCES clinics(id),
  nutritionist_id UUID REFERENCES app_users(id),
  
  -- Health
  sex TEXT CHECK (sex IN ('male', 'female', 'other')),
  birth_date DATE,
  height_cm NUMERIC(5,1),
  current_weight_kg NUMERIC(5,1),
  target_weight_kg NUMERIC(5,1),
  goal TEXT,
  activity_level TEXT,
  allergies TEXT[],
  intolerances TEXT[],
  medical_conditions TEXT[],
  
  -- Coach display
  coach_name TEXT DEFAULT 'Mery (IA Coach)',
  coach_avatar_url TEXT,
  
  -- System
  onboarding_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users see own profile" ON app_users
  FOR ALL USING (id = auth.uid());

CREATE POLICY "Nutritionists see their clients" ON app_users
  FOR SELECT USING (
    nutritionist_id = auth.uid()
  );
```

### 6.2 Tabla: `clinics`

```sql
CREATE TABLE clinics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  owner_user_id UUID NOT NULL REFERENCES auth.users(id),
  
  email TEXT NOT NULL,
  phone TEXT,
  
  -- Subscription
  subscription_tier TEXT NOT NULL DEFAULT 'starter'
    CHECK (subscription_tier IN ('starter', 'professional', 'enterprise', 'trial')),
  max_nutritionists INT DEFAULT 1,
  max_clients INT DEFAULT 50,
  
  -- White-label
  branding JSONB DEFAULT '{}'::jsonb,
  /* branding schema:
    {
      "primary_color": "#6F7C68",
      "background_color": "#F6F3EE",
      "logo_url": "https://...",
      "clinic_name_display": "Clínica Nutrisalud"
    }
  */
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 6.3 Tabla: `nutrition_plans`

```sql
CREATE TABLE nutrition_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  clinic_id UUID REFERENCES clinics(id),
  
  title TEXT NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('draft', 'active', 'archived')),
  
  -- Macros target
  calories_target INT,
  protein_g INT,
  carbs_g INT,
  fats_g INT,
  
  -- Generated by
  generated_by TEXT DEFAULT 'ai' CHECK (generated_by IN ('ai', 'nutritionist', 'hybrid')),
  nutritionist_id UUID REFERENCES app_users(id),
  
  -- Plan data
  meals JSONB NOT NULL DEFAULT '[]'::jsonb,
  /* meals schema:
    [
      {
        "meal_name": "Desayuno",
        "time_suggestion": "08:00",
        "items": ["Tortilla de claras (3)", "Pan integral"],
        "macros": { "calories": 450, "protein": 35, "carbs": 40, "fats": 15 }
      }
    ]
  */
  
  notes TEXT,
  valid_from DATE,
  valid_until DATE,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 6.4 Tabla: `chat_messages`

```sql
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  
  -- Sender
  sender_type TEXT NOT NULL CHECK (sender_type IN ('client', 'nutritionist', 'ai')),
  sender_id UUID, -- NULL for AI
  
  -- Content
  body TEXT NOT NULL,
  attachment_url TEXT,
  attachment_type TEXT CHECK (attachment_type IN ('image', 'pdf', 'voice')),
  
  -- Metadata
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para Realtime subscription con filtro
CREATE INDEX idx_chat_user ON chat_messages(user_id, created_at DESC);
```

### 6.5 Tabla: `daily_tasks`

```sql
CREATE TABLE daily_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  
  title TEXT NOT NULL,
  category TEXT DEFAULT 'other'
    CHECK (category IN ('nutrition', 'hydration', 'activity', 'sleep', 'supplement', 'habit', 'other')),
  
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  
  -- Recurrence
  recurrence TEXT DEFAULT 'daily' 
    CHECK (recurrence IN ('once', 'daily', 'weekdays', 'custom')),
  
  -- Source
  assigned_by TEXT DEFAULT 'system'
    CHECK (assigned_by IN ('system', 'ai', 'nutritionist', 'user')),
  
  task_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 6.6 Tablas adicionales (resumen)

| Tabla | Campos clave | Para qué |
|-------|-------------|----------|
| `weight_logs` | `user_id`, `weight_kg`, `logged_at`, `source` (manual/healthkit) | Registro de peso |
| `body_photos` | `user_id`, `photo_url`, `photo_type` (front/side/back), `taken_at` | Fotos corporales |
| `journal_entries` | `user_id`, `mood`, `energy`, `notes`, `entry_date` | Diario diario |
| `food_scans` | `user_id`, `barcode`, `product_name`, `nutriscore`, `scan_data` | Escáner |
| `shopping_lists` | `user_id`, `plan_id`, `items` (JSONB), `status` | Lista compra |
| `water_logs` | `user_id`, `amount_ml`, `logged_at` | Hidratación |
| `health_sync_log` | `user_id`, `data_type`, `value`, `source`, `synced_at` | HealthKit sync |

---

## 7. Pantalla por Pantalla — Lo que hay vs lo que debe haber

### Tab 1: Hoy (Dashboard)

| Feature | Mock actual | Producción |
|---------|-------------|------------|
| Saludo con nombre | ✅ Hardcoded "Micael" | Desde `app_users.first_name` |
| Anillo de progreso | ✅ Local | Calculado desde `daily_tasks` completadas |
| Macros del día | ✅ Hardcoded | Desde `nutrition_plans.meals[today].macros` |
| Tracker de agua | ✅ Local increment | CRUD `water_logs`, incrementos persistidos |
| Tareas del día | ✅ Local toggle | CRUD `daily_tasks` con debounce |
| Próxima comida | ✅ Hardcoded | Calculada por hora actual vs plan |
| Resumen semanal | ✅ Hardcoded | Query agregada sobre últimos 7 días |
| Último mensaje del coach | ✅ Hardcoded | Query `chat_messages` ORDER BY created_at DESC LIMIT 1 |
| FAB: Diario | ⚠️ No hace nada | → Abre `JournalView` modal |
| FAB: Foto comida | ⚠️ No hace nada | → Camera → Supabase Storage upload |
| FAB: Registrar peso | ⚠️ No hace nada | → Sheet con input → `weight_logs` INSERT |
| FAB: Escáner | ⚠️ No hace nada | → `BarcodeScannerView` → Open Food Facts |

### Tab 2: Dieta

| Feature | Mock actual | Producción |
|---------|-------------|------------|
| Selector de día (L-D) | ✅ Funcional | Debe cargar meals del día seleccionado del plan activo |
| Macros resumen | ✅ Hardcoded | Calculados desde meals del día |
| Lista de comidas | ✅ Hardcoded | Desde `nutrition_plans.meals` filtrado por día |
| Check "Seguí esta comida" | ❌ No existe | → Toggle con feedback → log de adherencia |
| Alternativas | ❌ No existe | Cada meal puede tener opciones A/B |
| Botón lista de compra | ⚠️ No hace nada | → `ShoppingListView` con items generados del plan |

### Tab 3: Chat

| Feature | Mock actual | Producción |
|---------|-------------|------------|
| Mensajes | ✅ Hardcoded (3 msgs) | Supabase Realtime subscription |
| Quick replies | ✅ Visual | Envían texto real al chat |
| Input + send | ⚠️ Visual, no envía | INSERT `chat_messages` + trigger IA si autónomo |
| Nombre coach | ✅ Hardcoded "Luis" | Desde `app_users.coach_name` |
| Indicador typing | ❌ No existe | Realtime Presence |
| Botón videollamada | ⚠️ Visual, no hace nada | Solo si `managed` → Daily.co deeplink |
| Enviar foto | ❌ No existe | Camera → Storage → attachment en mensaje |
| Mensaje de voz | ❌ No existe | AVAudioRecorder → Storage → attachment |

### Tab 4: Progreso

| Feature | Mock actual | Producción |
|---------|-------------|------------|
| Gráfico de peso | ✅ Placeholder | Swift Charts con datos reales de `weight_logs` |
| Time range selector | ✅ Visual (1S/1M/3M) | Filtra query por rango |
| Badge peso delta | ✅ Hardcoded "-0.3 kg" | Calculado última vs anterior |
| Gráfico adherencia | ✅ Con datos mock | Query `daily_tasks` agrupada por día |
| Gráfico tendencia | ✅ Con datos mock | Datos reales de adherencia o peso |
| Botón registrar peso | ⚠️ No hace nada | → Sheet → `weight_logs` INSERT |
| Fotos corporales | ❌ No existe | Timeline de fotos con comparación |
| Medidas corporales | ❌ No existe | Cintura, cadera, brazo, etc. |

### Tab 5: Perfil

| Feature | Mock actual | Producción |
|---------|-------------|------------|
| Avatar + nombre | ✅ Inicial generada | Avatar desde Storage o inicial |
| Stats (peso/altura/obj) | ✅ Hardcoded | Desde `app_users` |
| Info (email/coach) | ✅ Hardcoded | Datos reales |
| Notificaciones | ⚠️ Navrow, no navega | → Settings de push |
| Apple Health | ⚠️ Navrow, no navega | → HealthKit permissions + sync config |
| Escáner de alimentos | ⚠️ Navrow, no navega | → Scanner standalone |
| Memoria del coach | ⚠️ Navrow, no navega | → Vista de datos que el coach sabe |
| Privacidad | ⚠️ Navrow, no navega | → Delete account, export data |
| Ayuda | ⚠️ Navrow, no navega | → FAQs, contacto |
| Cerrar sesión | ⚠️ No funciona | `supabase.auth.signOut()` |
| Versión | ✅ "v1.0.0" | Dinámico desde bundle |

---

## 8. El Panel del Nutricionista — Pieza Clave B2B

### 8.1 ¿App nativa o web?

**Web. Sin discusión.** Razones:
1. El nutricionista trabaja desde escritorio (consultorio) el 90% del tiempo
2. Ya existe una app Next.js en el repo que se puede extender
3. No necesitas aprobación de App Store para el panel
4. Un solo nutricionista puede tener 50+ clientes → necesita vistas de tabla/lista → web es superior
5. Para el chat rápido desde el móvil, puede usar una PWA o la misma web responsive

### 8.2 Features del panel web nutricionista

```
Panel Nutricionista (Next.js)
│
├── Dashboard
│   ├── Clientes activos (lista + estado)
│   ├── Mensajes pendientes (inbox)
│   ├── Alertas (cliente sin registrar peso en 5 días, etc.)
│   └── Métricas agregadas (adherencia promedio, etc.)
│
├── Gestión de Clientes
│   ├── Invitar nuevo cliente (email → magic link → se crea en managed mode)
│   ├── Ficha del cliente
│   │   ├── Datos personales + assessment
│   │   ├── Plan nutricional activo (editor visual)
│   │   ├── Historial de peso + fotos
│   │   ├── Adherencia semanal
│   │   ├── Chat (mismos mensajes que ve el cliente)
│   │   └── Notas privadas del nutricionista
│   ├── Asignar/modificar plan
│   └── Asignar tareas extras
│
├── Planes
│   ├── Templates reutilizables
│   ├── Generador asistido por IA
│   │   └── "Dame un plan de 2200 kcal para pérdida de grasa
│   │       con 4 opciones por comida, estilo mediterráneo"
│   └── Clonar plan de un cliente a otro (adaptado)
│
├── Chat (vista inbox)
│   ├── Todos los clientes en un sidebar
│   ├── Respuesta rápida
│   ├── Sugerir respuesta (IA redacta, nutri aprueba)
│   └── Marcar como resuelto
│
├── Agenda
│   ├── Videollamadas programadas
│   └── Integración calendario
│
├── Configuración
│   ├── Branding (logo, colores) → white-label
│   ├── Datos de la clínica
│   └── Facturación
│
└── IA Assistant
    ├── "Analiza los logs de este cliente y sugiere ajuste"
    ├── "Genera un resumen semanal para enviar al cliente"
    └── "Redacta mensaje motivacional basado en su progreso"
```

### 8.3 Flujo de invitación (nutricionista → cliente)

```
1. Nutricionista abre "Invitar cliente" en panel web
2. Introduce email + nombre del cliente
3. Backend:
   a. Crea entry en `app_users` con account_mode='managed',
      clinic_id, nutritionist_id
   b. Envía magic link al email del cliente
4. Cliente recibe email: "Tu nutricionista te ha invitado a habitOS"
5. Cliente abre link → descarga app si no la tiene / abre app
6. Login automático con magic link → onboarding reducido
   (datos principales ya los tiene el nutricionista)
7. Cliente ve la app con branding de la clínica y nombre del nutricionista como coach
```

---

## 9. Sistema de Chat — Doble Cerebro

### 9.1 Modo Autónomo (B2C) — Chat con IA

```
Cliente escribe → INSERT chat_messages (sender_type: 'client')
                         ↓
              Supabase Realtime trigger
                         ↓
              Edge Function: ai-chat-reply
                         ↓
              GPT-4o con contexto:
                - Últimos 20 mensajes
                - Plan nutricional activo
                - coach_facts del usuario
                - Instrucciones de sistema (tono Mery)
                         ↓
              INSERT chat_messages (sender_type: 'ai')
                         ↓
              Cliente recibe respuesta via Realtime
```

### 9.2 Modo Gestionado (B2B) — Chat con Nutricionista + IA asistente

```
Cliente escribe → INSERT chat_messages (sender_type: 'client')
                         ↓
              Nutricionista ve en panel web (Realtime)
                         ↓
              Opciones del nutricionista:
              a) Responde directamente → INSERT (sender_type: 'nutritionist')
              b) Pide sugerencia a IA → IA redacta borrador → nutri edita → envía
              c) Activa "auto-reply" fuera de horario → IA responde con disclaimer
                         ↓
              Cliente recibe respuesta via Realtime
              (ve "Tu nutricionista" o "IA asistente" según sender_type)
```

### 9.3 Implementación Realtime en Swift

```swift
// ChatService.swift
func subscribeToMessages(userId: UUID) -> AsyncStream<ChatMessage> {
    let channel = supabase.channel("chat:\(userId)")
    
    let stream = channel.postgresChange(
        InsertAction.self,
        schema: "public",
        table: "chat_messages",
        filter: "user_id=eq.\(userId)"
    )
    
    await channel.subscribe()
    
    return stream.map { change in
        try change.decodeRecord(as: ChatMessage.self)
    }
}
```

---

## 10. Integraciones Técnicas

### 10.1 Supabase Auth (login)

```swift
// AuthManager.swift
class AuthManager: ObservableObject {
    @Published var session: Session?
    @Published var isAuthenticated = false
    
    func signInWithApple(idToken: String, nonce: String) async throws {
        let session = try await supabase.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )
        self.session = session
    }
    
    func signInWithMagicLink(email: String) async throws {
        try await supabase.auth.signInWithOTP(
            email: email,
            redirectTo: URL(string: "habitos://auth/callback")!
        )
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
}
```

**Métodos de login soportados (en orden de prioridad):**
1. **Sign in with Apple** — Obligatorio para App Store, mejor UX
2. **Magic Link por email** — Para invitaciones de nutricionistas
3. **Email + password** — Fallback clásico

### 10.2 Open Food Facts (escáner)

```swift
// BarcodeService.swift
struct OpenFoodFactsProduct: Codable {
    let productName: String?
    let brands: String?
    let nutriscoreGrade: String?
    let nutriments: Nutriments?
    
    struct Nutriments: Codable {
        let energyKcal100g: Double?
        let proteins100g: Double?
        let carbohydrates100g: Double?
        let fat100g: Double?
        let sugars100g: Double?
        let salt100g: Double?
    }
}

func lookupBarcode(_ code: String) async throws -> OpenFoodFactsProduct {
    let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(code).json")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(OFFResponse.self, from: data)
    return response.product
}
```

### 10.3 HealthKit

```swift
// HealthKitService.swift
let typesToRead: Set<HKObjectType> = [
    HKObjectType.quantityType(forIdentifier: .stepCount)!,
    HKObjectType.quantityType(forIdentifier: .bodyMass)!,
    HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
    HKObjectType.quantityType(forIdentifier: .heartRate)!,
]

// Sync background: cada 15 min via BGTaskScheduler
// 1. Lee nuevas muestras desde último sync
// 2. INSERT en health_sync_log via Supabse
// 3. Actualiza app_users.current_weight_kg si hay nuevo peso
```

### 10.4 Push Notifications

```
Supabase Edge Function "send-push"
  → APNs via HTTP/2
  
Triggers:
  • Nuevo mensaje de chat (sender != client)
  • Recordatorio de comida (30 min antes de la hora sugerida)
  • Recordatorio de agua (cada 2h si no ha registrado)
  • Nutricionista actualiza el plan
  • Resumen semanal los lunes a las 9:00
```

---

## 11. Monetización y Tiers

### 11.1 B2C (usuario autónomo)

| Tier | Precio | Features |
|------|--------|----------|
| **Free** | $0/mes | Dashboard, plan IA básico (1 plan), 5 msgs/día con IA |
| **Premium** | $9.99/mes | Planes ilimitados, chat IA ilimitado, escáner, HealthKit, fotos, journal |

### 11.2 B2B (clínicas)

| Tier | Precio | Features |
|------|--------|----------|
| **Starter** | $99/mes | 1 nutricionista, 50 clientes, chat, planes |
| **Professional** | $299/mes | 5 nutricionistas, 250 clientes, white-label, videollamada |
| **Enterprise** | Custom | Ilimitado, integraciones custom, soporte dedicado |

### 11.3 Revenue streams

1. **Suscripción B2C** — MRR de usuarios finales
2. **Suscripción B2B** — MRR de clínicas (mayor ticket)
3. **Upsell B2C→B2B** — "¿Quieres un nutricionista real? Conectamos contigo uno de nuestra red"
4. **Comisión marketplace** — Si habitOS conecta clientes autónomos con nutricionistas de la red

---

## 12. Hoja de Ruta por Fases

### Fase 0: Foundation (2-3 semanas)
```
- [ ] Instalar supabase-swift via SPM
- [ ] Configurar SupabaseClient singleton con URL + anon key
- [ ] Hacer todos los modelos Codable + Identifiable
- [ ] Crear AuthManager + LoginView (Apple + email/password)
- [ ] Crear AppState que determine si mostrar Login o ContentView
- [ ] Reescribir HabitOSDataService para usar Supabase real
- [ ] Crear migraciones SQL para todas las tablas
- [ ] Deep linking para magic links (habitos:// scheme)
- [ ] Eliminar Item.swift (artefacto de Xcode template)
```

### Fase 1: Core funcional (3-4 semanas)
```
- [ ] Dashboard con datos reales (macros, tareas, agua)
- [ ] Plan de dieta real desde nutrition_plans
- [ ] Chat con IA (Realtime + Edge Function ai-chat-reply)
- [ ] Registro de peso funcional
- [ ] Registro de agua persistido
- [ ] Toggle tareas del día con persistencia
- [ ] Push notifications básicas (chat + recordatorios)
- [ ] Profile con datos reales + logout funcional
```

### Fase 2: Features premium (3-4 semanas)
```
- [ ] Escáner de código de barras (AVFoundation + Open Food Facts)
- [ ] Fotos corporales (cámara → Supabase Storage)
- [ ] Lista de la compra generada desde el plan
- [ ] Diario/journal con mood + energy + notas
- [ ] HealthKit sync (pasos, peso, sueño)
- [ ] Gráficos de progreso con datos reales
- [ ] Onboarding assessment rápido in-app
```

### Fase 3: B2B - Modo gestionado (4-5 semanas)
```
- [ ] account_mode flag y adaptación UI condicional
- [ ] Chat con Realtime bidireccional (nutri ↔ cliente)
- [ ] Panel web nutricionista (Next.js):
      - Dashboard de clientes
      - Editor de planes
      - Chat inbox
      - Invitación de clientes
- [ ] White-label: branding dinámico desde clinics.branding
- [ ] RLS multi-tenant (clinic_id en policies)
- [ ] Videollamada integrada (Daily.co)
- [ ] IA asistente para el nutricionista (borrador de respuestas, análisis)
```

### Fase 4: Pulido y escalado (2-3 semanas)
```
- [ ] Modo offline (SwiftData cache)
- [ ] Background App Refresh para sync
- [ ] Accessibility audit (VoiceOver, Dynamic Type)
- [ ] Performance profiling (Instruments)
- [ ] App Store preparation (screenshots, ASO, review guidelines)
- [ ] TestFlight beta
- [ ] Monetización: StoreKit 2 para B2C premium
- [ ] Stripe Connect para facturación B2B
```

---

## 13. Riesgos y Mitigaciones

| Riesgo | Impacto | Mitigación |
|--------|---------|------------|
| **Cambio de paleta light ↔ dark** | Alto — todo rediseño | Decisión YA: el mock usa light (Vanilla), el spec anterior decía dark (#0F0F0F). **Mantener light.** Es coherente con el Brand Book y el concepto "lujo silencioso mediterráneo". |
| **Supabase Swift SDK inestable** | Medio | El SDK está en v2.41.1, es estable, 1.2k stars, mantenido activamente. Riesgo bajo. |
| **Complejidad multi-tenant** | Alto | Empezar con B2C solo (Fases 0-2). Añadir B2B en Fase 3 cuando la base sea sólida. |
| **App Store rejection** | Alto | Cumplir: Sign in with Apple obligatorio, no hardcodear API keys, privacy labels, health data handling. |
| **IA genera planes incorrectos** | Alto (salud) | Disclaimer legal obligatorio: "Este plan es orientativo y no sustituye consejo médico". En modo B2B, el nutricionista valida todo. |
| **Scope creep** | Crítico | Cada fase tiene scope cerrado. No añadir features fuera de fase. |
| **Rendimiento chat Realtime** | Medio | Paginar mensajes (50 por carga), lazy loading, desuscribir canales al salir de la vista. |

---

## 14. Decisiones Inmediatas Requeridas

### 14.1 Decisiones de DISEÑO

| # | Decisión | Recomendación | Justificación |
|---|----------|---------------|---------------|
| D1 | ¿Light mode o dark mode? | **Light (Vanilla).** | El Brand Book HTML, el mock, y el concepto "mediterráneo, cerámica, lino" son inherentemente light. El spec anterior con #0F0F0F era el viejo design system de "Personal Dashboard", no de habitOS. |
| D2 | ¿Una app o dos (cliente + nutri)? | **Una app iOS (cliente) + panel web (nutricionista).** | El nutricionista trabaja en escritorio. La app iOS es solo para el usuario final. |
| D3 | ¿Georgia o Playfair Display? | **Georgia en iOS** (nativa, no añade peso). Playfair en web/PDFs. | El mock ya usa Georgia, funciona perfecto en iOS, es la serif del sistema. |

### 14.2 Decisiones TÉCNICAS

| # | Decisión | Recomendación | Justificación |
|---|----------|---------------|---------------|
| T1 | ¿iOS mínimo? | **iOS 17.** | Permite `@Observable`, Charts nativos, StoreKit 2 completo, `Tab(value:)`. El mock ya usa API de iOS 17+. |
| T2 | ¿SwiftData para cache? | **Sí, para cache offline en Fase 4.** No priorizar ahora. | Supabase ya persiste. El cache offline es optimización, no core. |
| T3 | ¿Cómo manejar el chat IA?  | **Supabase Edge Function** que escucha inserts vía Database Webhook, llama a GPT-4o, e inserta la respuesta. | No requiere infraestructura propia. Escalable. El cliente solo escucha Realtime. |
| T4 | ¿Videollamada? | **Daily.co** — se integra embeddido en un WKWebView o con SDK nativo. | Menor complejidad que Twilio o Agora. Precios competitivos. |
| T5 | ¿Payments? | **StoreKit 2** para B2C (in-app purchases). **Stripe** para B2B (web). | Apple obliga a StoreKit para compras in-app. B2B es web, no aplica Apple cut. |

### 14.3 Decisiones de NEGOCIO

| # | Decisión | Recomendación | Justificación |
|---|----------|---------------|---------------|
| N1 | ¿Lanzar B2C o B2B primero? | **B2C primero.** | Valida producto con usuarios reales, genera feedback rápido, no depende de encontrar nutricionistas. B2B se añade cuando la app ya funciona. |
| N2 | ¿Free tier en B2C? | **Sí, con límites.** | Funnel: free → premium. Sin free tier, no hay adopción. Limitar: 1 plan IA, 5 msgs/día, sin escáner. |
| N3 | ¿Quién es "Mery"? | **Mery es la persona de marca**, no un chatbot genérico. En B2C, Mery es la IA coach. En B2B, Mery no aparece — aparece el nombre del nutricionista real. | Coherente con Brand Book. |

---

## Resumen Ejecutivo

**habitOS Mobile es un mock visual excelente que necesita tres cosas para ser un producto real:**

1. **Backend real** — Supabase Auth + PostgREST + Realtime + Storage + Edge Functions
2. **Lógica real** — Modelos Codable, servicio con SDK, ViewModels con persistencia
3. **Modo dual** — Un flag `account_mode` que determina si la IA o un nutricionista está detrás

**El plan es claro:** 
- Fase 0-1: App funcional B2C (auth + data real + chat IA)
- Fase 2: Features premium (escáner, fotos, HealthKit)
- Fase 3: B2B (panel nutricionista web + modo gestionado en app)
- Fase 4: Pulido, offline, App Store

**La arquitectura es una sola app iOS para el cliente + un panel web Next.js para el nutricionista.** No dos apps nativas. El nutricionista no necesita app — necesita un dashboard web potente donde gestionar 50+ clientes.

**El diseño está resuelto.** El Brand Book HTML + el design system Swift son coherentes y de alta calidad. No hay que rediseñar — hay que construir sobre lo que ya existe.

---

*"La tecnología calcula. El humano comprende. La arquitectura une ambas cosas."*  
— habitOS Brand Book
