# CHANGELOG — habitOS-mobile

## [0.1.0] — 2026-03-07 (Phase 1 MVP)

### ✅ Completado

#### `feature/project-scaffold`
- Estructura MVVM: App/, Core/, Features/, Models/, Repositories/
- Supabase Swift SDK v2.41.1 vía SPM
- `Config.swift` con credenciales de staging reales
- `AppState.swift` — estado global (@Observable)
- Modelos Codable: AppUser, NutritionPlan, CoachMessage, JournalEntry, WeightLog, DailyTaskItem, ShoppingList, FoodScan, CoachProfile, MealLog
- SupabaseManager, NetworkMonitor, SecureStorage (Keychain)
- Protocolos e implementaciones de repositorios (Auth, Diet, Journal, Tracking, Task)
- AuthViewModel, LoginView, OnboardingView

#### `feature/supabase-auth`
- Flujo de auth: splash → sesión check → LoginView → Onboarding → Dashboard
- Transiciones animadas entre estados de auth

#### `feature/notifications`
- NotificationManager con 5 tipos de recordatorios locales:
  - ☀️ Buenos días (08:00)
  - 🍽 Comidas (15 min antes)
  - 💧 Agua (cada 2h entre 09:00-21:00)
  - 📝 Diario (21:00)
  - ⚖️ Peso semanal (lunes 08:00)

#### `feature/journal`
- JournalView completo: mood (5 emojis), energía (1-5), sueño, hidratación con gotas visuales, movimiento/entrenamiento, alimentación, texto libre, "lo mejor del día"
- JournalViewModel con upsert a Supabase

#### `feature/weight-tracking`
- WeightLogView con Swift Charts (línea + área + línea objetivo)
- Stats header: peso actual / inicio / objetivo con deltas coloreados
- Historial con deltas por entrada
- WeightEntrySheet modal con input decimal grande

#### `feature/dev-mode`
- Botón "Entrar en modo demo" en LoginView
- AppUser.demoUser: Micael García (micaelanon@gmail.com)
- Manual de usuario: `Docs/manual-usuario.html`

#### `feature/diet-plan`
- DietPlanView: selector de día (L/M/X/J/V/S/D), tarjetas de comida con preview de ingredientes y macros
- MealDetailView: receta con ingredientes, pasos numerados, alternativas
- DietViewModel con datos demo

#### `feature/floating-tabbar`
- Tab bar flotante personalizado con iconos de fondo cuadrado redondeado
- Estilo Settings (fondo gris suave, sage cuando activo)
- Animación spring en cambio de tab
- Reemplaza el TabView nativo de SwiftUI

#### `feature/chat-realtime`
- ChatViewModel con suscripción Supabase Realtime (INSERT en coach_messages)
- Actualizaciones optimistas con rollback en error
- Modo demo: respuestas automáticas contextuales por keywords
- Dual mode: Supabase real o demo fallback

---

### 📊 Métricas
- **Branches mergeados**: 9
- **Archivos nuevos**: ~28
- **Líneas de código**: ~4000
- **Build**: ✅ Succeeded
- **Simulador**: iPhone 17 Pro

### ⏭ Siguiente (Fase 2)
- Lista de la compra auto-generada
- Escáner de alimentos (barcode)
- Fotos de progreso
- Integración HealthKit
- Memoria del coach
- Modo offline (SwiftData)
