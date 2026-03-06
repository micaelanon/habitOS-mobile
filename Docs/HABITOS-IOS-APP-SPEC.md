# habitOS — iOS Client App: Especificación Técnica y de Producto Definitiva

> **Versión**: 1.0  
> **Fecha**: 2026-03-05  
> **Propósito**: Documento único y completo para que una IA genere la app iOS nativa de habitOS de principio a fin. Contiene absolutamente todo: visión, marca, arquitectura, pantallas, modelos de datos, integraciones, flujos, copy y criterios de aceptación.

---

## ÍNDICE

1. [Visión General del Producto](#1-visión-general-del-producto)
2. [Identidad de Marca y Sistema de Diseño](#2-identidad-de-marca-y-sistema-de-diseño)
3. [Stack Tecnológico y Arquitectura](#3-stack-tecnológico-y-arquitectura)
4. [Modelo de Datos (Core Models)](#4-modelo-de-datos-core-models)
5. [Autenticación y Seguridad](#5-autenticación-y-seguridad)
6. [Pantallas y Navegación — Mapa completo](#6-pantallas-y-navegación--mapa-completo)
7. [Pantalla a Pantalla — Especificación detallada](#7-pantalla-a-pantalla--especificación-detallada)
8. [Módulo: Chat con Coach](#8-módulo-chat-con-coach)
9. [Módulo: Dieta y Plan Nutricional](#9-módulo-dieta-y-plan-nutricional)
10. [Módulo: Diario de Hábitos (El "Modo habitOS")](#10-módulo-diario-de-hábitos-el-modo-habitos)
11. [Módulo: Seguimiento Corporal (Fotos, Peso, Medidas)](#11-módulo-seguimiento-corporal-fotos-peso-medidas)
12. [Módulo: Lista de la Compra](#12-módulo-lista-de-la-compra)
13. [Módulo: Escáner de Alimentos (Integración Yuka/Open Food Facts)](#13-módulo-escáner-de-alimentos-integración-yukaopen-food-facts)
14. [Módulo: Objetivos del Día (Daily TODO)](#14-módulo-objetivos-del-día-daily-todo)
15. [Módulo: Videollamada con Coach](#15-módulo-videollamada-con-coach)
16. [Módulo: Sincronización con Wearables (Apple Watch / HealthKit)](#16-módulo-sincronización-con-wearables-apple-watch--healthkit)
17. [Notificaciones y Recordatorios](#17-notificaciones-y-recordatorios)
18. [Integraciones Backend (Supabase)](#18-integraciones-backend-supabase)
19. [Flujos UX Clave (Diagramas)](#19-flujos-ux-clave-diagramas)
20. [Criterios de Aceptación Globales](#20-criterios-de-aceptación-globales)
21. [Fases de Desarrollo Sugeridas](#21-fases-de-desarrollo-sugeridas)

---

## 1. Visión General del Producto

### Qué es

**habitOS** es una app iOS nativa para clientes de nutricionistas y coaches de salud. No es una app genérica de hábitos. Es la herramienta diaria que un cliente real usa para:

- Ver y seguir su dieta personalizada
- Hablar con su coach por chat en tiempo real
- Registrar comidas, agua, pasos, sueño, peso, molestias
- Escanear productos del supermercado para saber si son aptos
- Tener su lista de la compra generada desde su dieta
- Ver su progreso con fotos y métricas
- Recibir recordatorios inteligentes
- Agendar videollamadas con su nutricionista
- Escribir su diario de seguimiento ("modo habitOS")

### Qué NO es

- No es una app de recetas genéricas (las recetas vienen del plan del coach)
- No es una app social (no hay comunidad, no hay feed)
- No es una app de conteo de calorías manual (el plan ya viene calculado)
- No es la web de assessment (eso es para captación, esto es para retención)

### Público objetivo

Persona que ya es cliente de un nutricionista que usa la plataforma habitOS. Ha rellenado el cuestionario web, tiene un plan nutricional asignado, y necesita una herramienta para seguirlo en el día a día.

### Propuesta de valor

"Todo lo que necesitas para seguir tu plan, en un solo sitio. Sin excusas."

---

## 2. Identidad de Marca y Sistema de Diseño

### 2.1 Filosofía visual

Modo oscuro por defecto. Limpio, funcional, profesional. Inspira disciplina sin agobiar. Cada elemento tiene un propósito claro. Espaciado generoso. Micro-interacciones suaves (150-200ms). Sin ornamentación innecesaria.

La app debe sentirse como una herramienta premium de salud, no como un juguete con gamificación excesiva.

### 2.2 Paleta de Colores

#### Modo Oscuro (por defecto)

| Token                | Hex         | Uso                                      |
|----------------------|-------------|------------------------------------------|
| `background`         | `#0F0F0F`   | Fondo principal de toda la app           |
| `surface`            | `#1A1A1A`   | Cards, sheets, modales                   |
| `surfaceSecondary`   | `#262626`   | Inputs, campos, secciones anidadas       |
| `accent`             | `#10B981`   | Botones principales, indicadores de éxito, brand color |
| `accentHover`        | `#059669`   | Estado pressed/hover del accent          |
| `secondary`          | `#3B82F6`   | Info, links, acciones secundarias        |
| `warning`            | `#F59E0B`   | Alertas moderadas, estados parciales     |
| `error`              | `#EF4444`   | Errores, eliminación, alertas críticas   |
| `textPrimary`        | `#F5F5F5`   | Texto principal (títulos, body)          |
| `textSecondary`      | `#9CA3AF`   | Texto secundario (labels, descriptions)  |
| `textTertiary`       | `#6B7280`   | Placeholders, texto deshabilitado        |
| `border`             | `#404040`   | Bordes de cards, separadores, inputs     |
| `borderAccent`       | `#10B981`   | Bordes de focus, items seleccionados     |

#### Modo Claro (opcional, fase 2)

| Token                | Hex         |
|----------------------|-------------|
| `background`         | `#FFFFFF`   |
| `surface`            | `#F9FAFB`   |
| `surfaceSecondary`   | `#F3F4F6`   |
| `accent`             | `#059669`   |
| `textPrimary`        | `#111827`   |
| `textSecondary`      | `#6B7280`   |
| `border`             | `#E5E7EB`   |

#### Gradientes

```
accentGradient:  linear-gradient(135deg, #10B981 → #059669)
darkGradient:    linear-gradient(180deg, #1A1A1A → #0F0F0F)
heroGradient:    linear-gradient(180deg, #10B981 10%, #0F0F0F 90%)  // para splash y headers
```

#### Colores semánticos para módulos

| Módulo              | Color representativo | Emoji |
|---------------------|---------------------|-------|
| Dieta/Nutrición     | `#10B981` (verde)   | 🍽    |
| Hidratación         | `#3B82F6` (azul)    | 💧    |
| Actividad/Pasos     | `#F59E0B` (amber)   | 🚶    |
| Sueño               | `#8B5CF6` (violeta) | 😴    |
| Peso/Medidas        | `#EC4899` (rosa)    | ⚖️    |
| Lesiones/Síntomas   | `#EF4444` (rojo)    | 🤕    |
| Objetivos           | `#10B981` (verde)   | 🎯    |
| Chat                | `#3B82F6` (azul)    | 💬    |

### 2.3 Tipografía

| Uso                  | Fuente       | Tamaño | Peso | Line-height |
|----------------------|-------------|--------|------|-------------|
| Título de pantalla   | SF Pro Display | 28pt | Bold (700) | 1.2 |
| Título de sección    | SF Pro Display | 22pt | Semibold (600) | 1.3 |
| Subtítulo            | SF Pro Text  | 17pt   | Medium (500) | 1.4 |
| Body                 | SF Pro Text  | 15pt   | Regular (400) | 1.6 |
| Label                | SF Pro Text  | 13pt   | Medium (500) | 1.5 |
| Caption              | SF Pro Text  | 11pt   | Regular (400) | 1.4 |
| Datos numéricos      | SF Mono      | 17pt   | Medium | 1.3 |

> Nota: Usar SF Pro (fuente nativa de iOS) por consistencia con el sistema. No cargar Inter porque añade peso al bundle y SF Pro ya es excelente. El caracter de marca viene del color y la estructura, no de la fuente.

### 2.4 Iconografía

- Usar **SF Symbols** (librería nativa de Apple) para todos los iconos
- Estilo: `regular` weight por defecto, `semibold` para tabs activos
- Color: `textSecondary` por defecto, `accent` cuando activo/seleccionado
- Tamaño mínimo: 22pt para tap targets, 17pt para inline

### 2.5 Componentes base

#### Cards
```
background: surface (#1A1A1A)
border: 1px border (#404040)
cornerRadius: 12pt
padding: 16pt
shadow: 0 1px 3px rgba(0,0,0,0.3)
hover/pressed: border → accent (#10B981), shadow más profunda
```

#### Botones
```
Primary:   bg accent (#10B981), text #0F0F0F (negro), cornerRadius 10pt, height 50pt, font semibold 16pt
Secondary: bg surfaceSecondary (#262626), border 1px #404040, text textPrimary, height 44pt
Ghost:     bg transparent, text accent (#10B981), no border
Danger:    bg error (#EF4444), text white
Disabled:  opacity 0.4, no interaction
```

#### Inputs
```
background: surfaceSecondary (#262626)
border: 1px border (#404040)
focus: 2px accent border + glow rgba(16,185,129,0.15)
cornerRadius: 8pt
height: 44pt
padding: 12pt horizontal
placeholder: textTertiary (#6B7280)
```

#### Tab Bar
```
background: surface (#1A1A1A) con blur (UIBlurEffect)
active icon: accent (#10B981)
inactive icon: textTertiary (#6B7280)
active label: accent, font medium 10pt
indicator: 3pt circle accent debajo del icono activo
```

### 2.6 Animaciones y transiciones

- Transición de pantalla: push/pop nativo de iOS (0.35s)
- Aparición de elementos: fade-in + translateY(8pt), 200ms, ease-out
- Toggle/switch: spring animation (iOS nativo)
- Progreso: animación numérica (conteo) de 0 al valor, 600ms
- Tab change: crossfade 150ms
- Pull-to-refresh: bounce nativo de UIKit/SwiftUI
- Haptic feedback: `.light` para taps, `.medium` para confirmaciones, `.success` para completar tarea

### 2.7 Espaciado

Base: 4pt

| Token | Valor |
|-------|-------|
| xs    | 4pt   |
| sm    | 8pt   |
| md    | 12pt  |
| lg    | 16pt  |
| xl    | 24pt  |
| 2xl   | 32pt  |
| 3xl   | 48pt  |

---

## 3. Stack Tecnológico y Arquitectura

### 3.1 Tech Stack

| Capa          | Tecnología                                    |
|---------------|-----------------------------------------------|
| Lenguaje      | **Swift 5.9+**                                |
| UI Framework  | **SwiftUI** (iOS 17+)                         |
| Arquitectura  | **MVVM** con Repository pattern               |
| Backend       | **Supabase** (PostgreSQL + Auth + Storage + Realtime) |
| Networking    | `supabase-swift` SDK oficial                  |
| Estado local  | `@Observable` (Observation framework, iOS 17) |
| Persistencia  | **SwiftData** para caché offline              |
| Imágenes      | **Kingfisher** o `AsyncImage` nativo          |
| Charts        | **Swift Charts** (framework nativo)           |
| Cámara        | **AVFoundation** + PhotosPicker nativo        |
| Video llamada | **Daily.co** SDK o **Twilio** SDK             |
| Health        | **HealthKit** framework                       |
| Barcode       | **AVFoundation** (barcode scanner nativo)     |
| Push          | **APNs** + Supabase Edge Functions            |
| Analytics     | **PostHog** iOS SDK (o Mixpanel)              |
| Crash report  | **Sentry** iOS SDK                            |

### 3.2 Arquitectura de carpetas

```
habitOS/
├── App/
│   ├── habitOSApp.swift           // Entry point, @main
│   ├── AppState.swift             // Global observable state
│   └── AppRouter.swift            // Navigation coordinator
├── Core/
│   ├── Network/
│   │   ├── SupabaseManager.swift  // Singleton: client, auth, realtime
│   │   ├── APIEndpoints.swift     // Typed endpoint definitions
│   │   └── NetworkMonitor.swift   // Connectivity observer
│   ├── Storage/
│   │   ├── CacheManager.swift     // SwiftData local cache
│   │   └── SecureStorage.swift    // Keychain wrapper
│   ├── Health/
│   │   └── HealthKitManager.swift // HealthKit read/write
│   └── Extensions/
│       ├── Date+Extensions.swift
│       ├── Color+Brand.swift      // habitOS color tokens
│       └── View+Modifiers.swift
├── Features/
│   ├── Auth/
│   │   ├── Views/
│   │   │   ├── LoginView.swift
│   │   │   └── OnboardingView.swift
│   │   └── ViewModels/
│   │       └── AuthViewModel.swift
│   ├── Dashboard/
│   │   ├── Views/
│   │   │   ├── DashboardView.swift
│   │   │   └── DailyProgressCard.swift
│   │   └── ViewModels/
│   │       └── DashboardViewModel.swift
│   ├── Diet/
│   │   ├── Views/
│   │   │   ├── DietPlanView.swift
│   │   │   ├── MealDetailView.swift
│   │   │   └── RecipeView.swift
│   │   └── ViewModels/
│   │       └── DietViewModel.swift
│   ├── Chat/
│   │   ├── Views/
│   │   │   ├── ChatView.swift
│   │   │   └── MessageBubble.swift
│   │   └── ViewModels/
│   │       └── ChatViewModel.swift
│   ├── Journal/
│   │   ├── Views/
│   │   │   ├── JournalView.swift
│   │   │   ├── JournalEntryView.swift
│   │   │   └── MoodSelector.swift
│   │   └── ViewModels/
│   │       └── JournalViewModel.swift
│   ├── Tracking/
│   │   ├── Views/
│   │   │   ├── WeightLogView.swift
│   │   │   ├── PhotoProgressView.swift
│   │   │   ├── BodyMeasurementsView.swift
│   │   │   └── ProgressChartsView.swift
│   │   └── ViewModels/
│   │       └── TrackingViewModel.swift
│   ├── ShoppingList/
│   │   ├── Views/
│   │   │   ├── ShoppingListView.swift
│   │   │   └── ShoppingItemRow.swift
│   │   └── ViewModels/
│   │       └── ShoppingListViewModel.swift
│   ├── FoodScanner/
│   │   ├── Views/
│   │   │   ├── ScannerView.swift
│   │   │   └── ProductResultView.swift
│   │   └── ViewModels/
│   │       └── FoodScannerViewModel.swift
│   ├── DailyTasks/
│   │   ├── Views/
│   │   │   ├── DailyTasksView.swift
│   │   │   └── TaskRow.swift
│   │   └── ViewModels/
│   │       └── DailyTasksViewModel.swift
│   ├── VideoCall/
│   │   ├── Views/
│   │   │   └── VideoCallView.swift
│   │   └── ViewModels/
│   │       └── VideoCallViewModel.swift
│   └── Profile/
│       ├── Views/
│       │   ├── ProfileView.swift
│       │   └── SettingsView.swift
│       └── ViewModels/
│           └── ProfileViewModel.swift
├── Models/
│   ├── User.swift
│   ├── NutritionPlan.swift
│   ├── Meal.swift
│   ├── Recipe.swift
│   ├── ChatMessage.swift
│   ├── JournalEntry.swift
│   ├── WeightLog.swift
│   ├── BodyPhoto.swift
│   ├── ShoppingItem.swift
│   ├── DailyTask.swift
│   ├── FoodProduct.swift
│   └── CoachProfile.swift
├── Repositories/
│   ├── AuthRepository.swift
│   ├── DietRepository.swift
│   ├── ChatRepository.swift
│   ├── JournalRepository.swift
│   ├── TrackingRepository.swift
│   ├── ShoppingRepository.swift
│   ├── TaskRepository.swift
│   └── HealthRepository.swift
├── Components/
│   ├── HBCard.swift              // Reusable card component
│   ├── HBButton.swift            // Brand-styled button
│   ├── HBTextField.swift         // Brand-styled input
│   ├── HBProgressRing.swift      // Circular progress indicator
│   ├── HBBadge.swift             // Status badges
│   ├── HBEmptyState.swift        // Empty state template
│   └── HBLoadingView.swift       // Skeleton/loading state
├── Resources/
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   ├── Colors/               // Color tokens como Named Colors
│   │   └── Images/
│   └── Localizable.xcstrings     // ES + EN
└── Preview Content/
    └── PreviewData.swift          // Mock data for SwiftUI previews
```

### 3.3 Patrones clave

**MVVM:**
- **View**: SwiftUI puro. Solo presenta estado. No tiene lógica.
- **ViewModel**: `@Observable` class. Expone propiedades y métodos. Llama a Repository.
- **Repository**: Abstrae el acceso a datos (Supabase, local cache, HealthKit).
- **Model**: Structs Codable que mapean 1:1 con las tablas de Supabase.

**Offline-first:**
- Todas las acciones de escritura se guardan en SwiftData primero
- Sync queue: cuando hay conexión, se envían los cambios pendientes
- Las lecturas priorizan caché local, con pull-to-refresh para forzar

**Realtime:**
- Chat: Supabase Realtime channel suscrito a `coach_messages` filtrado por `profile_id`
- Tareas: escuchar cambios en `coach_tasks`

---

## 4. Modelo de Datos (Core Models)

### 4.1 Tablas de Supabase existentes que la app consume

Las tablas ya existen en el backend. La app NO crea schema. Solo lee y escribe.

#### `coach_profiles`
```
id: UUID (PK)
telegram_chat_id: BigInt (unique)   — para Telegram, la app usará auth.uid()
display_name: String
coach_name: String (default: "Luis da Coruña")
coach_mode: String (default: "friend_with_tough_love")
memory_window_days: Int (default: 30)
is_active: Bool
preferences: JSONB
created_at, updated_at: Timestamp
```

#### `coach_messages`
```
id: UUID (PK)
profile_id: UUID (FK → coach_profiles)
role: "user" | "assistant" | "system"
channel: "telegram" | "app" | "web"
message_text: String
media_type: "photo" | "audio" | "video" | "document" (nullable)
media_url: String (nullable)
metadata: JSONB { event_type, fact_kind, importance, ... }
expires_at: Timestamp
created_at: Timestamp
```

#### `coach_facts` (memoria estructurada)
```
id: UUID (PK)
profile_id: UUID (FK)
fact_kind: ENUM (injury, symptom, nutrition_preference, nutrition_restriction, habit, emotion, goal, milestone, context)
importance: ENUM (critical, important, relevant, ephemeral)
title: String
fact_text: String
first_mentioned_at, last_mentioned_at: Timestamp
mention_count: Int
is_pinned: Bool
is_resolved: Bool
tags: [String]
extra: JSONB
```

#### `coach_tasks` (recordatorios)
```
id: UUID (PK)
profile_id: UUID (FK)
title: String
note: String (nullable)
schedule_type: "one_off" | "interval"
due_at: Timestamp (para one_off)
interval_minutes: Int (para interval, mínimo 15)
next_trigger_at: Timestamp
status: "active" | "done" | "canceled" | "paused"
```

#### `coach_summaries`
```
id: UUID (PK)
profile_id: UUID (FK)
period_start: Date
period_end: Date
summary_type: "biweekly" | "monthly"
summary_text: String
key_changes: JSONB
review_actions: JSONB
```

#### `assessments` (cuestionario original del cliente)
```
id: UUID (PK)
first_name, last_name, email, phone: String
goal: String
payload: JSONB (contiene TODOS los 40+ campos del assessment)
processing_status: "received" | "sent_to_n8n" | "n8n_failed"
```

### 4.2 Tablas nuevas que la app necesita

Estas tablas deben crearse como migración adicional en Supabase.

#### `app_users` (perfil de usuario en la app)
```sql
CREATE TABLE public.app_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id),
  coach_profile_id UUID REFERENCES public.coach_profiles(id),
  clinic_id UUID,  -- para white-label futuro
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  sex TEXT CHECK (sex IN ('male', 'female')),
  date_of_birth DATE,
  height_cm NUMERIC(5,1),
  current_weight_kg NUMERIC(5,1),
  goal TEXT,
  activity_level TEXT,
  food_allergies JSONB DEFAULT '[]',
  food_dislikes JSONB DEFAULT '[]',
  diet_type TEXT,
  medical_conditions JSONB DEFAULT '[]',
  timezone TEXT DEFAULT 'Europe/Madrid',
  locale TEXT DEFAULT 'es',
  notifications_enabled BOOLEAN DEFAULT true,
  healthkit_enabled BOOLEAN DEFAULT false,
  onboarding_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `nutrition_plans` (plan nutricional asignado por el coach)
```sql
CREATE TABLE public.nutrition_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
  plan_name TEXT NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('draft', 'active', 'paused', 'completed', 'archived')),
  start_date DATE NOT NULL,
  end_date DATE,
  daily_calories INT,
  daily_protein_g INT,
  daily_carbs_g INT,
  daily_fats_g INT,
  daily_fiber_g INT,
  meal_count INT DEFAULT 4,
  guidelines TEXT,
  meal_plan JSONB NOT NULL DEFAULT '{}',
  -- meal_plan structure:
  -- {
  --   "monday": { "breakfast": {...}, "mid_morning": {...}, "lunch": {...}, "snack": {...}, "dinner": {...} },
  --   "tuesday": { ... },
  --   ...
  -- }
  ai_generated BOOLEAN DEFAULT false,
  created_by TEXT,  -- nutritionist name or "ai"
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `weight_logs`
```sql
CREATE TABLE public.weight_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
  weight_kg NUMERIC(5,1) NOT NULL,
  body_fat_pct NUMERIC(4,1),
  muscle_mass_kg NUMERIC(5,1),
  waist_cm NUMERIC(5,1),
  hip_cm NUMERIC(5,1),
  notes TEXT,
  source TEXT DEFAULT 'manual' CHECK (source IN ('manual', 'healthkit', 'smart_scale')),
  logged_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `body_photos`
```sql
CREATE TABLE public.body_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
  photo_url TEXT NOT NULL,  -- Supabase Storage URL
  photo_type TEXT NOT NULL CHECK (photo_type IN ('front', 'side', 'back')),
  notes TEXT,
  taken_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `journal_entries` (diario habitOS)
```sql
CREATE TABLE public.journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
  entry_date DATE NOT NULL,
  mood TEXT CHECK (mood IN ('great', 'good', 'neutral', 'bad', 'terrible')),
  energy_level INT CHECK (energy_level BETWEEN 1 AND 5),
  sleep_hours NUMERIC(3,1),
  sleep_quality TEXT CHECK (sleep_quality IN ('great', 'good', 'fair', 'poor')),
  water_liters NUMERIC(3,1),
  steps INT,
  training_done BOOLEAN DEFAULT false,
  training_notes TEXT,
  meals_followed INT,  -- cuántas comidas del plan siguió
  meals_total INT,     -- cuántas comidas tenía en el plan
  cravings TEXT,       -- antojos del día
  symptoms TEXT,       -- molestias del día
  free_text TEXT,      -- diario libre (lo que quiera escribir)
  highlight TEXT,      -- lo mejor del día (una frase)
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, entry_date)
);
```

#### `meal_logs` (registro de comidas reales)
```sql
CREATE TABLE public.meal_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
  plan_id UUID REFERENCES public.nutrition_plans(id),
  meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'mid_morning', 'lunch', 'snack', 'dinner', 'extra')),
  planned_meal JSONB,        -- lo que debía comer según el plan
  actual_description TEXT,   -- lo que realmente comió (texto libre)
  photo_url TEXT,            -- foto de la comida (opcional)
  followed_plan BOOLEAN,    -- ¿siguió el plan?
  deviation_reason TEXT,     -- si no siguió: por qué
  logged_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `shopping_lists`
```sql
CREATE TABLE public.shopping_lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
  plan_id UUID REFERENCES public.nutrition_plans(id),
  week_start DATE NOT NULL,
  items JSONB NOT NULL DEFAULT '[]',
  -- items structure: [{ "name": "Pechuga de pollo", "quantity": "1 kg", "category": "proteína", "checked": false }, ...]
  auto_generated BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `food_scans` (historial de escaneos)
```sql
CREATE TABLE public.food_scans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
  barcode TEXT NOT NULL,
  product_name TEXT,
  brand TEXT,
  nutriscore TEXT CHECK (nutriscore IN ('a', 'b', 'c', 'd', 'e')),
  nova_group INT CHECK (nova_group BETWEEN 1 AND 4),
  calories_per_100g NUMERIC(6,1),
  allergens JSONB DEFAULT '[]',
  is_compatible BOOLEAN,  -- compatible con su plan/alergias
  incompatibility_reason TEXT,
  scan_data JSONB,        -- raw API response
  scanned_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `video_call_bookings`
```sql
CREATE TABLE public.video_call_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
  coach_name TEXT NOT NULL,
  scheduled_at TIMESTAMPTZ NOT NULL,
  duration_minutes INT DEFAULT 30,
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'no_show')),
  meeting_url TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `daily_tasks` (objetivos checklist del día)
```sql
CREATE TABLE public.daily_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
  task_date DATE NOT NULL,
  title TEXT NOT NULL,
  category TEXT CHECK (category IN ('nutrition', 'hydration', 'activity', 'sleep', 'supplement', 'habit', 'other')),
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ,
  sort_order INT DEFAULT 0,
  auto_generated BOOLEAN DEFAULT true,
  source TEXT DEFAULT 'plan',  -- 'plan', 'coach', 'user', 'system'
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 5. Autenticación y Seguridad

### 5.1 Flujo de Auth

1. **Magic Link** (preferido): el usuario recibe email con link → abre la app → está autenticado
2. **Email + Contraseña**: fallback clásico
3. **Apple Sign-In**: obligatorio para App Store si se ofrece login social

Flujo:
```
App abierta → ¿Hay sesión activa? 
  └─ SÍ → Dashboard
  └─ NO → Login Screen
          ├─ Email + Magic Link → Safari → Deep Link → App autenticada
          ├─ Email + Password → Validate → Dashboard
          └─ Sign in with Apple → OAuth → Dashboard
```

### 5.2 Seguridad

- Tokens almacenados en **iOS Keychain** (no UserDefaults)
- Supabase RLS activo en todas las tablas
- La app solo accede a datos del `auth.uid()` actual
- Fotos corporales almacenadas en Supabase Storage con **bucket privado** (signed URLs, expiración 1h)
- Datos médicos (alergias, condiciones) marcados como sensibles
- No logging de datos personales en consola
- Certificate pinning para Supabase endpoint (fase 2)
- Biometric unlock (Face ID / Touch ID) opcional para abrir la app

---

## 6. Pantallas y Navegación — Mapa completo

### 6.1 Estructura de navegación

```
TabBar (5 tabs)
├── 🏠 Hoy (Dashboard)
│   ├── Daily Progress Ring
│   ├── Objetivos del día (checklist)
│   ├── Próxima comida
│   ├── Quick actions
│   └── Resumen semanal (collapsible)
│
├── 🍽 Dieta
│   ├── Plan semanal (horizontal scroll por día)
│   ├── Detalle de comida
│   │   └── Receta expandida
│   ├── Lista de la compra
│   └── Registro de comida (log meal)
│
├── 💬 Chat
│   ├── Chat con coach (tiempo real)
│   ├── Historial
│   └── Agendar videollamada
│
├── 📊 Progreso
│   ├── Gráfica de peso (Swift Charts)
│   ├── Galería de fotos
│   ├── Medidas corporales
│   ├── Gráfica de adherencia
│   └── Resúmenes bi-semanales
│
└── 👤 Perfil
    ├── Datos personales
    ├── Alergias e intolerancias
    ├── Preferencias de notificaciones
    ├── HealthKit toggle
    ├── Escáner de alimentos
    ├── Memoria del coach (qué sabe de mí)
    └── Ajustes / Cerrar sesión
```

### 6.2 Floating Action Button (FAB)

Un botón flotante verde (accent) en la esquina inferior derecha, visible en Hoy y Dieta:

```
Tap FAB → Action Sheet:
  📝 Escribir en diario
  📸 Foto de comida
  ⚖️ Registrar peso
  🔍 Escanear producto
  💧 Registro rápido de agua (+250ml)
```

---

## 7. Pantalla a Pantalla — Especificación detallada

### 7.1 Login / Onboarding

**Pantalla: Welcome**
- Logo habitOS centrado (verde sobre negro)
- Texto: "Tu plan nutricional, siempre contigo"
- Botón primario: "Entrar con mi email"
- Botón secundario: "Continuar con Apple"
- Texto pequeño: "¿No tienes cuenta? Habla con tu nutricionista"

**Pantalla: Onboarding (solo primera vez, 3 slides)**
- Slide 1: "Tu dieta, día a día" — icono calendario + comida
- Slide 2: "Habla con tu coach" — icono chat
- Slide 3: "Ve tu progreso" — icono gráfica ascendente
- Botón: "Empezar" → Request permisos (notificaciones, HealthKit)

### 7.2 Dashboard — "Hoy"

Esta es la pantalla principal. El usuario la ve cada vez que abre la app.

**Layout (scroll vertical):**

```
┌─────────────────────────────────┐
│ Hola, {firstName} 👋            │  ← greeting, texto grande
│ {día de la semana}, {fecha}      │  ← label secondary
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │  PROGRESO DEL DÍA           │ │
│ │  ╭──────╮                   │ │
│ │  │ 65%  │ ← ring circular  │ │
│ │  ╰──────╯                   │ │
│ │  4/6 tareas · 1800/2200 kcal│ │
│ │  💧 1.5L / 2.5L  🚶 6200   │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│ ☑ OBJETIVOS DE HOY              │
│ ┌──────────────────────────────┐│
│ │ ✅ Desayuno según plan       ││
│ │ ☐  Almuerzo según plan       ││
│ │ ☐  2.5L de agua              ││
│ │ ☐  8000 pasos                ││
│ │ ☐  Tomar omega-3             ││
│ │ ☐  Cenar antes de las 21:00  ││
│ └──────────────────────────────┘│
├─────────────────────────────────┤
│ 🍽 PRÓXIMA COMIDA               │
│ ┌──────────────────────────────┐│
│ │ Almuerzo · 12:30 - 14:00     ││
│ │ Pechuga a la plancha          ││
│ │ Ensalada mixta                ││
│ │ Arroz integral (150g)         ││
│ │ [Ver receta]  [Ya comí ✓]    ││
│ └──────────────────────────────┘│
├─────────────────────────────────┤
│ 📊 ESTA SEMANA                  │
│ ┌──────────────────────────────┐│
│ │ Adherencia: 78% ■■■■■■■░░░  ││
│ │ Peso: 81.2 kg (↓ 0.3)       ││
│ │ Agua media: 2.1L             ││
│ │ Pasos media: 7200            ││
│ └──────────────────────────────┘│
├─────────────────────────────────┤
│ 💬 ÚLTIMO MENSAJE DEL COACH     │
│ ┌──────────────────────────────┐│
│ │ "Buen trabajo ayer con la     ││
│ │  cena. Hoy intenta subir..."  ││
│ │              [Ir al chat →]   ││
│ └──────────────────────────────┘│
└─────────────────────────────────┘
```

**Lógica:**
- Objetivos del día se auto-generan a las 00:00 basándose en el plan activo:
  - Una tarea por cada comida del plan
  - Objetivo de agua (configurable, default 2.5L)
  - Objetivo de pasos (desde HealthKit o manual)
  - Suplementos si tiene asignados
  - Recordatorios custom del coach
- Progress ring = (tareas completadas / total) * 100
- "Próxima comida" = la siguiente comida del plan según la hora actual
- "Esta semana" = agregación de los últimos 7 `journal_entries`

### 7.3 Dieta

**Pantalla: Plan Semanal**

```
┌─────────────────────────────────┐
│ MI DIETA                        │
│                                 │
│ [L] [M] [X] [J] [V] [S] [D]  │  ← selector de día (hoy resaltado)
│                                 │
│ Calorías: 2200 kcal             │
│ P: 165g · C: 220g · G: 73g     │  ← macros del día
├─────────────────────────────────┤
│                                 │
│ 🌅 DESAYUNO · 08:00            │
│ ┌──────────────────────────────┐│
│ │ Tortilla de claras (3)        ││
│ │ Pan integral (2 rebanadas)    ││
│ │ Aguacate (1/4)                ││
│ │ Café con leche desnatada      ││
│ │ 420 kcal · P:32g C:38g G:14g ││
│ │        [Ver detalle →]        ││
│ └──────────────────────────────┘│
│                                 │
│ 🍎 MEDIA MAÑANA · 11:00        │
│ ┌──────────────────────────────┐│
│ │ Yogur griego + nueces (15g)   ││
│ │ 180 kcal · P:15g C:8g G:10g  ││
│ └──────────────────────────────┘│
│                                 │
│ 🍽 ALMUERZO · 13:30             │
│ ┌──────────────────────────────┐│
│ │ ...                           ││
│ └──────────────────────────────┘│
│                                 │
│ ... (merienda, cena)            │
│                                 │
│ 🛒 [Lista de la compra]        │  ← botón que lleva a shopping list
└─────────────────────────────────┘
```

**Pantalla: Detalle de Comida (al pulsar una comida)**

```
┌─────────────────────────────────┐
│ ← Almuerzo                      │
│                                 │
│ ┌──────────────────────────────┐│
│ │       [FOTO DE RECETA]       ││
│ │       (si disponible)        ││
│ └──────────────────────────────┘│
│                                 │
│ Pechuga a la plancha            │
│ con ensalada mediterránea       │
│                                 │
│ ⏱ 20 min prep · 🍽 1 ración    │
│                                 │
│ MACROS                          │
│ ┌──────────────────────────────┐│
│ │ Calorías    520 kcal         ││
│ │ Proteína    42g  ■■■■■■■░░  ││
│ │ Carbos      38g  ■■■■■░░░░  ││
│ │ Grasas      18g  ■■■░░░░░░  ││
│ │ Fibra       8g               ││
│ └──────────────────────────────┘│
│                                 │
│ INGREDIENTES                    │
│ ☐ 200g pechuga de pollo         │
│ ☐ 100g mezcla de lechugas       │
│ ☐ 50g tomate cherry             │
│ ☐ 30g cebolla morada            │
│ ☐ 10ml AOVE                     │
│ ☐ Sal, pimienta, limón          │
│                                 │
│ PREPARACIÓN                     │
│ 1. Salpimentar la pechuga...    │
│ 2. Grillar a fuego medio...     │
│ 3. Mientras, preparar la...     │
│                                 │
│ ┌──────────────────────────────┐│
│ │ [✅ Seguí esta comida]       ││
│ │ [📸 Subir foto de mi comida] ││
│ │ [✏️ Comí algo diferente]     ││
│ └──────────────────────────────┘│
└─────────────────────────────────┘
```

---

## 8. Módulo: Chat con Coach

### 8.1 Diseño del chat

Interfaz tipo WhatsApp/iMessage. Burbujas a la derecha (usuario, color `surfaceSecondary`) y a la izquierda (coach, color `surface` con borde accent tenue).

```
┌─────────────────────────────────┐
│ ← Chat con {coachName}    📞   │  ← header: nombre + botón videollamada
├─────────────────────────────────┤
│                                 │
│    ┌────────────────────┐       │
│    │ Hola! Cómo te fue  │       │  ← burbuja coach (izquierda)
│    │ ayer con la cena?   │       │
│    └────────────────────┘       │
│    10:32                        │
│                                 │
│         ┌──────────────────┐    │
│         │ Bien! Seguí el   │    │  ← burbuja usuario (derecha)
│         │ plan. Pero hoy   │    │
│         │ como fuera...    │    │
│         └──────────────────┘    │
│                       10:35     │
│                                 │
│    ┌────────────────────┐       │
│    │ Perfecto 💪 Para   │       │
│    │ comer fuera:        │       │
│    │ • Elige proteína    │       │
│    │ • Evita fritos      │       │
│    │ • Ensalada > pasta  │       │
│    └────────────────────┘       │
│    10:36                        │
│                                 │
├─────────────────────────────────┤
│ ┌────────────────────┐ [📎][➤] │  ← input: texto + adjunto + enviar
│ │ Escribe un mensaje  │         │
│ └────────────────────┘          │
└─────────────────────────────────┘
```

### 8.2 Funcionalidad

- **Tiempo real**: Supabase Realtime subscription en `coach_messages` filtrado por `profile_id`
- **Canal**: `channel = 'app'` para mensajes desde la app (vs `'telegram'`)
- **Media**: poder adjuntar fotos (de comida, de productos, de etiquetas)
- **Read receipts**: campo `read_at` en metadata
- **Typing indicator**: Supabase Presence API (si se implementa coach web)
- **Mensajes del coach**: pueden venir del bot de Telegram (automáticos) o del nutricionista (manual desde panel web)
- **Quick replies**: chips pre-definidos como "Seguí el plan", "No pude cumplir", "Tengo hambre"

### 8.3 Integración con Coach Brain

Los mensajes enviados desde la app pasan por la misma clasificación que el bot de Telegram:
- Se guardan en `coach_messages` con `channel: 'app'`
- El metadata incluye `event_type`, `fact_kind`, `importance` (clasificación automática)
- Se crean/actualizan facts en `coach_facts`
- Los recordatorios se crean en `coach_tasks`

---

## 9. Módulo: Dieta y Plan Nutricional

### 9.1 Fuente de datos

El plan nutricional viene pre-generado por el nutricionista (o IA + revisión humana) y se almacena en `nutrition_plans.meal_plan` como JSONB.

Estructura del `meal_plan`:
```json
{
  "monday": {
    "breakfast": {
      "name": "Tortilla de claras con pan integral",
      "time": "08:00",
      "calories": 420,
      "protein_g": 32,
      "carbs_g": 38,
      "fats_g": 14,
      "fiber_g": 5,
      "ingredients": [
        { "name": "Clara de huevo", "quantity": "3 unidades", "grams": 100 },
        { "name": "Pan integral", "quantity": "2 rebanadas", "grams": 60 },
        { "name": "Aguacate", "quantity": "1/4", "grams": 40 }
      ],
      "instructions": "1. Batir las claras...\n2. Cocinar a fuego medio...",
      "prep_time_minutes": 10,
      "image_url": null,
      "alternatives": ["Avena con frutas", "Yogur con granola"]
    },
    "mid_morning": { ... },
    "lunch": { ... },
    "snack": { ... },
    "dinner": { ... }
  },
  "tuesday": { ... },
  ...
}
```

### 9.2 Registro de adherencia

Cada vez que el usuario marca "Seguí esta comida" o "Comí algo diferente":
- Se crea un `meal_log` con `followed_plan: true/false`
- El journal del día se actualiza: `meals_followed` / `meals_total`
- La adherencia semanal se calcula como media

### 9.3 Alternativas

Si una comida tiene `alternatives`, el usuario puede ver opciones rápidas de sustitución sin salirse del plan. No es editar el plan, es una alternativa pre-aprobada por el coach.

---

## 10. Módulo: Diario de Hábitos (El "Modo habitOS")

### 10.1 Concepto

El diario es el corazón de la experiencia habitOS. No es un diario genérico: es un check-in diario estructurado que combina datos objetivos (pasos, agua, sueño) con reflexión personal.

### 10.2 Pantalla: Journal del día

```
┌─────────────────────────────────┐
│ ← DIARIO · Miércoles 5 marzo   │
├─────────────────────────────────┤
│                                 │
│ ¿CÓMO TE SIENTES HOY?          │
│ [😊] [🙂] [😐] [😕] [😞]     │  ← mood selector (tap uno)
│                                 │
│ ENERGÍA                         │
│ [1] [2] [3] [⚡4] [5]          │  ← energy level selector
│                                 │
├─────────────────────────────────┤
│ 😴 SUEÑO                       │
│ Horas: [  7.5  ] h             │
│ Calidad: [😊 Buena  ▾]         │
│                                 │
├─────────────────────────────────┤
│ 💧 HIDRATACIÓN                  │
│ ┌──────────────────────────────┐│
│ │ 💧💧💧💧💧💧◯◯◯◯          ││  ← cada gota = 250ml
│ │ 1.5L / 2.5L                  ││     tap para añadir
│ └──────────────────────────────┘│
│         [+ 250ml]  [+ 500ml]   │
│                                 │
├─────────────────────────────────┤
│ 🚶 MOVIMIENTO                   │
│ Pasos: 6,200 (de HealthKit)    │
│ ¿Entrenaste hoy? [Sí]  [No]   │
│ Notas: [                    ]   │
│                                 │
├─────────────────────────────────┤
│ 🍽 ALIMENTACIÓN                 │
│ Comidas del plan seguidas: 3/5  │  ← auto-calculado de meal_logs
│ Antojos: [                  ]   │
│ Síntomas: [                 ]   │
│                                 │
├─────────────────────────────────┤
│ 📝 DIARIO LIBRE                 │
│ ┌──────────────────────────────┐│
│ │ Hoy me sentí bien después    ││
│ │ del almuerzo. La receta de   ││
│ │ pollo estaba buena. Pero     ││
│ │ por la tarde tuve antojo...  ││
│ └──────────────────────────────┘│
│                                 │
│ ⭐ LO MEJOR DEL DÍA            │
│ [ Aguanté sin picar entre h. ] │
│                                 │
│        [💾 Guardar diario]      │
└─────────────────────────────────┘
```

### 10.3 Historial

Vista calendario (mes) con colores que indican el mood o la adherencia de cada día:
- Verde: >80% adherencia
- Amarillo: 60-80%
- Rojo: <60%
- Gris: sin registro

Tap en un día → ver el journal de ese día en modo lectura.

### 10.4 Lógica de guardado

- Se guarda/actualiza en `journal_entries` con `UNIQUE(user_id, entry_date)`
- Upsert: si ya existe entrada para hoy, se actualiza
- El campo `water_liters` también se puede actualizar incrementalmente desde el widget de agua del dashboard
- Los `steps` se autosinccronizan desde HealthKit si está habilitado

---

## 11. Módulo: Seguimiento Corporal (Fotos, Peso, Medidas)

### 11.1 Pantalla: Progreso

**Tab "Peso":**
```
┌─────────────────────────────────┐
│ PESO                            │
│ ┌──────────────────────────────┐│
│ │   [GRÁFICA SWIFT CHARTS]     ││
│ │   Línea: peso en el tiempo   ││
│ │   Referencia: peso objetivo  ││
│ │   Rango: último mes / 3m /   ││
│ │          6m / todo           ││
│ └──────────────────────────────┘│
│                                 │
│ Actual: 81.2 kg                 │
│ Inicio: 85.0 kg                │
│ Objetivo: 78.0 kg              │
│ Progreso: ■■■■■■░░░░ 54%      │
│                                 │
│ HISTORIAL                       │
│ 05 mar · 81.2 kg (↓ 0.3)      │
│ 02 mar · 81.5 kg (↓ 0.2)      │
│ 28 feb · 81.7 kg (↓ 0.5)      │
│ ...                             │
│                                 │
│ [⚖️ Registrar peso hoy]        │
└─────────────────────────────────┘
```

**Tab "Fotos":**
```
┌─────────────────────────────────┐
│ FOTOS DE PROGRESO               │
│                                 │
│ [Semana 1]    [Semana 4]        │
│ ┌────┐┌────┐  ┌────┐┌────┐    │
│ │ F  ││ L  │  │ F  ││ L  │    │  ← Front / Lateral / Back
│ └────┘└────┘  └────┘└────┘    │
│                                 │
│ Slider comparativo:             │
│ ←  [Antes]  |  [Después]  →    │  ← swipe para comparar
│                                 │
│ [📸 Añadir foto]                │
└─────────────────────────────────┘
```

**Tab "Medidas":**
- Cintura, cadera, brazo, muslo
- Historial con gráfica de tendencia

### 11.2 Registro de peso

Modal/sheet con:
- Input numérico grande (teclado decimal)
- Fecha (default hoy, editable)
- % grasa corporal (opcional)
- Masa muscular (opcional)
- Notas (opcional)
- Fuente: manual / HealthKit / báscula inteligente

### 11.3 Fotos

- Cámara con guías de posición (silueta front/side/back)
- Fotos almacenadas en Supabase Storage (bucket privado `body-photos`)
- Compresión a 1200px max y HEIC→JPEG
- Comparador side-by-side con slider

---

## 12. Módulo: Lista de la Compra

### 12.1 Generación automática

Al activar un plan nutricional semanal, la app genera automáticamente la lista de la compra:
- Agrega ingredientes de todas las comidas de la semana
- Agrupa por categoría (proteínas, verduras, frutas, lácteos, cereales, otros)
- Consolida cantidades (si dos recetas usan pollo, suma los gramos)

### 12.2 Pantalla

```
┌─────────────────────────────────┐
│ 🛒 LISTA DE LA COMPRA           │
│ Semana del 3-9 marzo            │
│                                 │
│ PROTEÍNAS                       │
│ ☐ Pechuga de pollo · 1.2 kg    │
│ ☐ Salmón fresco · 400g         │
│ ☐ Huevos · 12 unidades         │
│ ✅ Atún en lata · 3 latas      │  ← marcado como comprado
│                                 │
│ VERDURAS                        │
│ ☐ Espinacas · 300g             │
│ ☐ Tomates cherry · 500g        │
│ ☐ Cebolla · 3 unidades         │
│ ☐ Brócoli · 500g               │
│                                 │
│ FRUTAS                          │
│ ☐ Plátano · 7 unidades         │
│ ☐ Fresas · 500g                │
│                                 │
│ LÁCTEOS                         │
│ ☐ Yogur griego natural · 6     │
│ ☐ Leche desnatada · 1L         │
│                                 │
│ CEREALES Y LEGUMBRES            │
│ ☐ Arroz integral · 500g        │
│ ☐ Pan integral · 1 barra       │
│ ☐ Avena · 500g                 │
│                                 │
│ OTROS                           │
│ ☐ Aceite de oliva virgen extra  │
│ ☐ Nueces · 150g                │
│                                 │
│ + Añadir item manual            │
│                                 │
│ [🔍 Escanear producto]          │
│ [📤 Compartir lista]            │  ← share sheet nativo
└─────────────────────────────────┘
```

### 12.3 Funcionalidad

- Tap en item → toggle checked (con animación y haptic)
- Swipe para eliminar
- "Añadir item manual" → input de texto + categoría
- Share: genera texto plano con la lista para compartir por WhatsApp, etc.
- Persistencia: `shopping_lists` tabla, items como JSONB array
- Al escanear un producto, si el producto está en la lista, se marca automáticamente como comprado

---

## 13. Módulo: Escáner de Alimentos (Integración Yuka/Open Food Facts)

### 13.1 API: Open Food Facts (gratuita, abierta)

**NO usar Yuka**: Yuka no tiene API pública. Usar **Open Food Facts** que es la fuente de datos que Yuka usa internamente.

**Endpoint**: `https://world.openfoodfacts.org/api/v2/product/{barcode}.json`

**Datos que devuelve:**
- `product_name`: nombre del producto
- `brands`: marca
- `nutriscore_grade`: a/b/c/d/e (Nutri-Score)
- `nova_group`: 1-4 (grado de procesamiento)
- `nutriments`: calorías, proteínas, grasas, carbohidratos, azúcar, sal, fibra por 100g
- `allergens_tags`: ['en:gluten', 'en:milk', ...]
- `ingredients_text`: texto de ingredientes
- `image_front_url`: foto del producto

### 13.2 Flujo del escáner

```
Tap "Escanear" → Cámara AVFoundation (barcode reader)
  → Lee código de barras (EAN-13, EAN-8, UPC-A)
  → Petición a Open Food Facts API
  → ¿Producto encontrado?
      └─ SÍ → Mostrar resultado
      └─ NO → "Producto no encontrado. Puedes buscarlo por nombre."
```

### 13.3 Pantalla: Resultado del escaneo

```
┌─────────────────────────────────┐
│ ← ESCÁNER                       │
│                                 │
│ ┌──────────────────────────────┐│
│ │     [FOTO DEL PRODUCTO]      ││
│ └──────────────────────────────┘│
│                                 │
│ Galletas Digestive              │
│ McVitie's                       │
│                                 │
│ NUTRI-SCORE                     │
│ [A] [B] [■C■] [D] [E]          │  ← highlight en C
│                                 │
│ NOVA (procesamiento)            │
│ Grupo 4 – Ultra-procesado ⚠️   │
│                                 │
│ POR 100g:                       │
│ Calorías:   480 kcal            │
│ Proteínas:  7.0g                │
│ Carbos:     62g (azúcar: 24g)  │
│ Grasas:     22g (sat: 10g)     │
│ Fibra:      3.5g               │
│ Sal:        1.1g               │
│                                 │
│ ⚠️ ALÉRGENOS                   │
│ Contiene: GLUTEN, LECHE        │
│                                 │
│ ┌──────────────────────────────┐│
│ │ ❌ NO COMPATIBLE CON TU PLAN ││
│ │                              ││
│ │ Razones:                     ││
│ │ • Ultra-procesado (NOVA 4)   ││
│ │ • Alto en azúcar (24g/100g)  ││
│ │ • Contiene GLUTEN (alergia)  ││  ← si usuario tiene alergia al gluten
│ └──────────────────────────────┘│
│                                 │
│ [Guardar escaneo]  [Escanear otro]
└─────────────────────────────────┘
```

### 13.4 Lógica de compatibilidad

El escáner cruza los datos del producto con el perfil del usuario:

1. **Alérgenos**: si `product.allergens_tags` contiene algo que está en `user.food_allergies` → ❌ INCOMPATIBLE (rojo, crítico)
2. **Nutri-Score**: D o E → ⚠️ advertencia
3. **NOVA**: 4 (ultra-procesado) → ⚠️ advertencia
4. **Azúcar**: >15g/100g → ⚠️ advertencia
5. **Grasas saturadas**: >10g/100g → ⚠️ advertencia
6. Si todo OK → ✅ "Compatible con tu plan"

Resultado guardado en `food_scans` para historial.

---

## 14. Módulo: Objetivos del Día (Daily TODO)

### 14.1 Auto-generación

Cada día a las 00:00 (local timezone del usuario), el sistema genera los tasks del día:

Desde el plan nutricional activo:
- "Desayuno según plan" (nutrition)
- "Media mañana según plan" (nutrition)
- "Almuerzo según plan" (nutrition)
- "Merienda según plan" (nutrition)
- "Cena según plan" (nutrition)

Desde el perfil:
- "Beber {target}L de agua" (hydration)
- "{target} pasos" (activity)
- "Dormir {target}h" (sleep)

Desde suplementos asignados:
- "Tomar omega-3" (supplement)
- "Tomar vitamina D" (supplement)

Desde coach_tasks activos:
- Cualquier tarea que el coach haya creado para hoy

### 14.2 Interacción

- Tap en tarea → toggle completed (con haptic `.success` y animación de check)
- Swipe right → complete
- Las tareas completadas bajan de posición con opacidad reducida
- No se pueden eliminar las auto-generadas (solo completar o ignorar)
- El usuario puede añadir tareas personales

### 14.3 Gamificación sutil (no excesiva)

- Streak counter: "7 días seguidos completando >80%"
- Al completar todas → confetti suave (una sola vez al día)
- Badge semanal: "Semana Perfecta" si 7/7 días >80%
- NO hay puntos, niveles, recompensas virtuales. Es una herramienta profesional.

---

## 15. Módulo: Videollamada con Coach

### 15.1 Concepto

El usuario puede agendar videollamadas con su nutricionista para revisiones periódicas. No es un Zoom genérico: es una videollamada integrada en la app.

### 15.2 Flujo

```
Chat → [📞 Agendar videollamada]
  → Modal: Seleccionar fecha y hora disponible
  → Confirmar
  → Se crea booking en video_call_bookings
  → Notificación push 15 min antes
  → Notification → Tap → Abrir videollamada en-app
  → Videollamada (Daily.co / Twilio embed)
  → Al terminar → "¿Cómo fue la consulta?" (rating 1-5)
```

### 15.3 Implementación

- **Fase 1 (MVP)**: Botón "Agendar llamada" → guarda booking → el coach envía link de Google Meet/Zoom por chat → el usuario abre externamente
- **Fase 2**: Integración Daily.co SDK para videollamada in-app
- **Fase 3**: Calendario con slots disponibles del coach (requiere panel web de coach)

### 15.4 Pantalla

```
┌─────────────────────────────────┐
│ PRÓXIMA CONSULTA                │
│                                 │
│ 📅 Jueves 6 marzo · 18:00      │
│ ⏱  30 minutos                  │
│ 👩‍⚕️ Dra. García                │
│                                 │
│ [Unirse a la llamada]           │  ← visible 5 min antes
│ [Reagendar]  [Cancelar]        │
│                                 │
│ CONSULTAS PASADAS               │
│ 20 feb · 30min · ⭐⭐⭐⭐⭐    │
│ 06 feb · 45min · ⭐⭐⭐⭐      │
└─────────────────────────────────┘
```

---

## 16. Módulo: Sincronización con Wearables (Apple Watch / HealthKit)

### 16.1 Datos que se leen de HealthKit

| Dato                | HealthKit Type                           | Uso en habitOS                  |
|---------------------|------------------------------------------|---------------------------------|
| Pasos diarios       | `HKQuantityTypeIdentifier.stepCount`     | Dashboard + Journal + Tasks     |
| Distancia caminada  | `.distanceWalkingRunning`                | Journal                         |
| Calorías activas    | `.activeEnergyBurned`                    | Dashboard                       |
| Frecuencia cardíaca | `.heartRate`                             | Progreso (opcional)             |
| Sueño               | `.sleepAnalysis` (categoryType)          | Journal auto-fill               |
| Peso                | `.bodyMass`                              | Weight log auto-sync            |
| Grasa corporal      | `.bodyFatPercentage`                     | Weight log (si smart scale)     |
| Agua ingerida       | `.dietaryWater`                          | Hydration tracker               |

### 16.2 Datos que se escriben a HealthKit

| Dato             | Cuándo                                  |
|------------------|-----------------------------------------|
| Peso             | Cuando el usuario registra peso en-app  |
| Agua             | Cuando registra agua en-app             |
| Calorías dieta   | (Fase 2) Al registrar comidas del plan  |

### 16.3 Flujo de permisos

```
Settings → HealthKit → Toggle ON
  → Abre modal nativo de HealthKit permissions
  → Usuario selecciona qué datos compartir
  → Al volver a la app: sync inicial
  → A partir de ahí: sync cada vez que la app se abre (background fetch también)
```

### 16.4 Complicación Apple Watch (Fase 3)

- Widget circular: progreso del día (% tareas completadas)
- Widget rectangular: pasos + agua del día
- Notificaciones haptic desde watch para recordatorios de agua

---

## 17. Notificaciones y Recordatorios

### 17.1 Tipos de notificación

| Tipo                    | Trigger                          | Hora default      | Configurable |
|-------------------------|----------------------------------|--------------------|--------------|
| Buenos días             | Cron diario                      | 08:00              | Sí           |
| Recordatorio de comida  | 15 min antes de cada comida      | Según plan         | Sí           |
| Recordatorio de agua    | Cada 2h entre 09:00-21:00       | Interval           | Sí           |
| Registro de peso        | 1x/semana (lunes 08:00)         | Lunes 08:00        | Sí           |
| Diario del día          | 21:00                            | 21:00              | Sí           |
| Mensaje del coach       | Cuando coach envía mensaje       | Inmediato          | No           |
| Videollamada próxima    | 15 min antes                     | Según booking      | No           |
| Streak en riesgo        | Si no registró ayer              | 10:00 del día sig. | No           |

### 17.2 Configuración

```
Settings → Notificaciones
  ☑ Buenos días (08:00)          [editar hora]
  ☑ Recordatorio de comidas      [15 min antes ▾]
  ☑ Recordatorio de agua         [cada 2h ▾]
  ☑ Registro de peso semanal     [Lunes ▾]
  ☑ Diario del día (21:00)      [editar hora]
  ☑ Mensajes del coach           [siempre]
```

### 17.3 Implementación

- **Local notifications** para recordatorios programados (comidas, agua, diario)
- **Push notifications (APNs)** para mensajes del coach y eventos del backend
- Backend: Supabase Edge Function que envía push via APNs cuando se inserta un `coach_message` con `role: 'assistant'`

---

## 18. Integraciones Backend (Supabase)

### 18.1 Supabase Client Config

```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://{PROJECT_ID}.supabase.co")!,
    supabaseKey: "{ANON_KEY}"  // NUNCA el service_role_key en la app
)
```

### 18.2 Auth

```swift
// Magic Link
try await supabase.auth.signInWithOTP(email: email)

// Email + Password
try await supabase.auth.signIn(email: email, password: password)

// Apple Sign-In
try await supabase.auth.signInWithIdToken(
    credentials: .init(provider: .apple, idToken: appleIdToken)
)

// Get current user
let user = try await supabase.auth.session.user
```

### 18.3 CRUD patterns

```swift
// Read: Get user's nutrition plan
let plans: [NutritionPlan] = try await supabase.database
    .from("nutrition_plans")
    .select()
    .eq("user_id", value: userId)
    .eq("status", value: "active")
    .order("created_at", ascending: false)
    .limit(1)
    .execute()
    .value

// Write: Log weight
try await supabase.database
    .from("weight_logs")
    .insert(WeightLog(userId: userId, weightKg: 81.2, source: "manual"))
    .execute()

// Realtime: Chat messages
let channel = supabase.realtime.channel("chat")
let changes = channel.postgresChange(
    InsertAction.self,
    schema: "public",
    table: "coach_messages",
    filter: "profile_id=eq.\(profileId)"
)
await channel.subscribe()
for await change in changes {
    // New message received
    await MainActor.run { messages.append(change.record) }
}
```

### 18.4 Storage (fotos)

```swift
// Upload body photo
let data = image.jpegData(compressionQuality: 0.8)!
let path = "\(userId)/body/\(UUID().uuidString).jpg"
try await supabase.storage
    .from("body-photos")
    .upload(path: path, file: data, options: .init(contentType: "image/jpeg"))

// Get signed URL (1h expiry)
let url = try await supabase.storage
    .from("body-photos")
    .createSignedURL(path: path, expiresIn: 3600)
```

### 18.5 RLS Policies necesarias

Todas las tablas nuevas deben tener RLS con:
```sql
-- El usuario solo ve sus propios datos
CREATE POLICY "Users see own data" ON {table}
  FOR ALL USING (user_id = (
    SELECT id FROM app_users WHERE auth_user_id = auth.uid()
  ));
```

---

## 19. Flujos UX Clave (Diagramas)

### 19.1 Primer uso completo

```
App Store → Descargar → Abrir
  → Welcome screen
  → Login (magic link / password / Apple)
  → Onboarding (3 slides)
  → Permisos: Notificaciones → HealthKit
  → ¿Hay plan nutricional asignado?
      SÍ → Dashboard con plan
      NO → Pantalla: "Tu nutricionista está preparando tu plan. Te avisamos."
           + Chat disponible para hablar con coach
```

### 19.2 Uso diario típico (5 minutos)

```
08:00 → Push: "Buenos días {nombre}. Tu desayuno: tortilla de claras"
  → Abre app → Dashboard "Hoy"
  → Ve objetivos del día
  → Desayuna → Tap "✅ Desayuné según plan"
  → Marca agua (+500ml)

13:00 → Push: "Hora del almuerzo: pechuga con ensalada"
  → Abre Dieta → Ve receta → Cocina
  → Tap "✅ Seguí esta comida"
  
15:00 → Push: "💧 ¿Has bebido agua?"
  → Tap en notificación → +250ml registrado

17:00 → En el supermercado
  → FAB → Escanear producto
  → Escanea galletas → "⚠️ Ultra-procesado, alto en azúcar"
  → Escanea yogur → "✅ Compatible con tu plan"

21:00 → Push: "¿Cómo fue tu día?"
  → Abre diario
  → Mood: 🙂 · Energía: 4
  → Sueño: 7h, buena calidad
  → Texto libre: "Hoy me costó no picar por la tarde..."
  → Guardar
  → Progreso: 80% del día completado 🎉
```

### 19.3 Uso semanal

```
Lunes 08:00 → Push: "¿Te pesas hoy?"
  → Registra peso: 81.0 kg
  → Ve gráfica: tendencia descendente ✅

Domingo 20:00 → Resumen semanal auto-generado
  → "Esta semana: 82% adherencia, -0.5kg, 7800 pasos/día media"
  → Compartir con coach (auto-send al chat)
```

### 19.4 Flujo de chat

```
Usuario en restaurante → Abre Chat
  → "Estoy en un italiano, ¿qué pido?"
  → Coach (bot/humano): "Proteína + verdura. Opciones:
     • Ensalada César con pollo (sin pan)
     • Salmón a la plancha con verduras
     • Evita: pasta carbonara, pizza"
  → Usuario: "Pedí el salmón 👍"
  → Coach: "Perfecto. Lo registro. Buen trabajo."
  
  → Internamente: message guardado con event_type: "food_out"
  → Fact creado/actualizado: "Comida fuera - salmón en italiano"
```

---

## 20. Criterios de Aceptación Globales

### Rendimiento
- [ ] App abre en <2 segundos (cold start)
- [ ] Transiciones de pantalla <0.35s
- [ ] Scroll suave a 60fps en todas las listas
- [ ] Imágenes con lazy loading y placeholder
- [ ] Tamaño del bundle <80MB

### UX
- [ ] Toda acción destructiva tiene confirmación
- [ ] Toda acción de éxito tiene feedback (haptic + visual)
- [ ] Empty states con ilustración + CTA en todas las pantallas
- [ ] Pull-to-refresh en todas las listas
- [ ] Offline: se muestra caché local + banner "Sin conexión"
- [ ] Accesibilidad: VoiceOver labels en todos los elementos interactivos
- [ ] Dynamic Type: la app respeta el tamaño de texto del sistema
- [ ] Mínimo tap target: 44x44pt (Apple HIG)

### Seguridad
- [ ] No hay service_role_key en la app (solo anon key)
- [ ] Tokens en Keychain
- [ ] RLS activo en todas las tablas
- [ ] Fotos en bucket privado con signed URLs
- [ ] No logging de PII en consola
- [ ] Certificate pinning para Supabase (fase 2)

### Código
- [ ] MVVM estricto: Views no contienen lógica de negocio
- [ ] Todos los Models son Codable + Identifiable
- [ ] Repositories abstraen acceso a datos (testeable con mocks)
- [ ] Previews funcionales para todas las Views
- [ ] Min deployment target: iOS 17.0
- [ ] Localización: ES (principal) + EN
- [ ] Sin force unwrap (!). Usar guard let / if let
- [ ] Async/await para todas las operaciones asíncronas (no Combine)

---

## 21. Fases de Desarrollo Sugeridas

### Fase 1 — MVP Funcional (Core)
1. Auth (login, session, profile)
2. Dashboard "Hoy" con objetivos
3. Dieta: ver plan semanal + detalle de comida
4. Chat con coach (Supabase Realtime)
5. Diario de hábitos (journal)
6. Registro de peso + gráfica
7. Notificaciones locales
8. Diseño completo con brand colors

### Fase 2 — Experiencia Completa
9. Fotos de progreso + comparador
10. Lista de la compra (auto-generada)
11. Escáner de alimentos (Open Food Facts)
12. Daily tasks auto-generados
13. HealthKit sync (pasos, sueño, peso)
14. Push notifications (APNs)
15. Meal logging (registro de comidas)

### Fase 3 — Premium
16. Videollamada integrada (Daily.co)
17. Apple Watch complication
18. Modo claro (light theme)
19. Widget de HomeScreen (pasos + agua + próxima comida)
20. Exportar datos (PDF resumen mensual)
21. Certificate pinning
22. Onboarding adaptativo (según datos del assessment)

---

## Apéndice A — Texto y Copy de la App (ES)

### Tab Bar
- Hoy, Dieta, Chat, Progreso, Perfil

### Dashboard
- "Hola, {nombre} 👋"
- "Progreso del día"
- "Objetivos de hoy"
- "Próxima comida"
- "Esta semana"
- "Último mensaje del coach"

### Empty States
- Sin plan: "Tu nutricionista está preparando tu plan personalizado. Mientras, puedes hablar con tu coach por chat."
- Sin peso registrado: "Registra tu primer peso para empezar a ver tu progreso."
- Sin fotos: "Sube tu primera foto para tener una referencia visual de tu punto de partida."
- Sin diario: "Cuéntame cómo fue tu día. Es rápido y te ayuda a mantener el rumbo."
- Chat vacío: "Escríbele a tu coach. Cualquier duda, antojo o situación vale."

### Confirmaciones
- Peso guardado: "⚖️ Peso registrado"
- Foto subida: "📸 Foto guardada"
- Diario guardado: "📝 Diario actualizado"
- Comida registrada: "🍽 Comida registrada"
- Tarea completada: "✅ ¡Hecho!"
- Agua añadida: "💧 +{cantidad}ml"

### Errores
- Sin conexión: "Sin conexión. Los datos se guardarán cuando vuelvas a conectarte."
- Error genérico: "Algo salió mal. Intenta de nuevo."
- Sesión expirada: "Tu sesión ha expirado. Inicia sesión de nuevo."

---

## Apéndice B — Open Food Facts API Reference

### Endpoint principal
```
GET https://world.openfoodfacts.org/api/v2/product/{barcode}.json
```

### Headers
```
User-Agent: habitOS-iOS/1.0 (contact@habitos.app)
```
> Open Food Facts requiere un User-Agent identificativo.

### Response relevante (simplificada)
```json
{
  "status": 1,
  "product": {
    "product_name": "Galletas Digestive",
    "brands": "McVitie's",
    "nutriscore_grade": "c",
    "nova_group": 4,
    "nutriments": {
      "energy-kcal_100g": 480,
      "proteins_100g": 7.0,
      "carbohydrates_100g": 62,
      "sugars_100g": 24,
      "fat_100g": 22,
      "saturated-fat_100g": 10,
      "fiber_100g": 3.5,
      "salt_100g": 1.1
    },
    "allergens_tags": ["en:gluten", "en:milk"],
    "ingredients_text": "Harina de trigo, azúcar, aceite...",
    "image_front_url": "https://images.openfoodfacts.org/..."
  }
}
```

### Mapeo de alérgenos
```
"en:gluten"       → Gluten
"en:milk"         → Lácteos
"en:eggs"         → Huevos
"en:nuts"         → Frutos secos
"en:peanuts"      → Cacahuetes
"en:soybeans"     → Soja
"en:fish"         → Pescado
"en:crustaceans"  → Crustáceos
"en:celery"       → Apio
"en:mustard"      → Mostaza
"en:sesame-seeds" → Sésamo
"en:sulphur-dioxide-and-sulphites" → Sulfitos
"en:lupin"        → Altramuces
"en:molluscs"     → Moluscos
```

---

## Apéndice C — Supabase Project Info

| Dato             | Valor                                           |
|------------------|-------------------------------------------------|
| URL Staging      | `https://egejjdrqnxqsmrtvvqqv.supabase.co`     |
| Región Staging   | eu-central-1                                     |
| Región Prod      | eu-west-1                                        |
| Auth method      | Magic Link + Email/Password + Apple Sign-In      |
| Storage bucket   | `body-photos` (private), `meal-photos` (private) |
| Realtime         | Habilitado para `coach_messages`                 |
| RLS              | Activo en todas las tablas                       |

---

## Apéndice D — Resumen de Decisiones Técnicas

| Decisión | Elegido | Por qué |
|----------|---------|---------|
| Framework UI | SwiftUI | Nativo Apple, declarativo, compatible iOS 17+. No React Native porque queremos HealthKit nativo + rendimiento + App Store compliance |
| Backend | Supabase | Ya es el backend del proyecto. PostgreSQL, Auth, Storage, Realtime integrados. SDK Swift oficial |
| Arquitectura | MVVM | Estándar en SwiftUI. Observable macro simplifica binding |
| Estado | @Observable | iOS 17+. Más limpio que ObservableObject+@Published |
| Offline | SwiftData | Framework nativo de Apple para persistencia local. Reemplaza CoreData con API declarativa |
| Charts | Swift Charts | Framework nativo. No necesitamos librería externa |
| Food API | Open Food Facts | Gratuita, abierta, base de datos más grande del mundo. Yuka no tiene API pública |
| Video | Daily.co (fase 2) | Más simple que Twilio para MVP. SDK iOS nativo. Gratis hasta 10K min/mes |
| Health | HealthKit | Nativo Apple. Obligatorio para datos de salud en iOS |
| Notif push | APNs + Supabase Edge | Supabase puede enviar push via Edge Functions. Sin Firebase |
| Barcode | AVFoundation | Nativo iOS. No necesitamos librería externa para scan de códigos |
| Min iOS | 17.0 | Requerido para @Observable, SwiftData, y mejoras de Swift Charts |

---

*Fin del documento. Este spec contiene todo lo necesario para que una IA genere la aplicación iOS completa de habitOS. Cualquier ambigüedad debe resolverse a favor de la simplicidad, la coherencia con el sistema de diseño, y la experiencia del usuario final (el cliente del nutricionista).*
