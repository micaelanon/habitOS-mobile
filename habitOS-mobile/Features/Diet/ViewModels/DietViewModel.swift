import SwiftUI

/// Diet ViewModel — manages the weekly meal plan
@Observable
final class DietViewModel {
    var selectedDay: Int = Calendar.current.component(.weekday, from: Date()) // 1=Sun, 2=Mon...
    var plan: NutritionPlan?
    var isLoading: Bool = false
    var errorMessage: String?

    private let repository: DietRepositoryProtocol
    private var userId: UUID?

    init(repository: DietRepositoryProtocol = DietRepository()) {
        self.repository = repository
    }

    var todayMeals: DayMeals? {
        plan?.mealPlan.meals(for: selectedDay)
    }

    var dayName: String {
        let names = ["", "Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"]
        return names[selectedDay]
    }

    var dayInitials: [(day: Int, initial: String)] {
        return [
            (2, "L"), (3, "M"), (4, "X"), (5, "J"), (6, "V"), (7, "S"), (1, "D")
        ]
    }

    func loadPlan(userId: UUID) async {
        self.userId = userId
        isLoading = true
        defer { isLoading = false }

        // For demo mode, create a mock plan
        if plan == nil {
            plan = NutritionPlan.demoPlan(userId: userId)
        }
    }
}

// MARK: – Demo Data
extension NutritionPlan {
    static func demoPlan(userId: UUID) -> NutritionPlan {
        let breakfast = MealDetail(
            name: "Tortilla de claras con pan integral",
            time: "08:00",
            calories: 420, proteinG: 32, carbsG: 38, fatsG: 14, fiberG: 5,
            ingredients: [
                MealIngredient(name: "Clara de huevo", quantity: "3 unidades", grams: 100),
                MealIngredient(name: "Pan integral", quantity: "2 rebanadas", grams: 60),
                MealIngredient(name: "Aguacate", quantity: "1/4", grams: 40),
                MealIngredient(name: "Café con leche desnatada", quantity: "1 taza", grams: nil)
            ],
            instructions: "1. Batir las claras con una pizca de sal\n2. Cocinar a fuego medio en sartén antiadherente\n3. Tostar el pan integral\n4. Servir con el aguacate laminado",
            prepTimeMinutes: 10,
            imageUrl: nil,
            alternatives: ["Avena con frutas", "Yogur con granola"]
        )

        let midMorning = MealDetail(
            name: "Yogur griego con nueces",
            time: "11:00",
            calories: 180, proteinG: 15, carbsG: 8, fatsG: 10, fiberG: 1,
            ingredients: [
                MealIngredient(name: "Yogur griego natural", quantity: "1 unidad", grams: 170),
                MealIngredient(name: "Nueces", quantity: "15g", grams: 15)
            ],
            instructions: nil,
            prepTimeMinutes: 2,
            imageUrl: nil,
            alternatives: nil
        )

        let lunch = MealDetail(
            name: "Pechuga a la plancha con ensalada",
            time: "13:30",
            calories: 520, proteinG: 42, carbsG: 38, fatsG: 18, fiberG: 8,
            ingredients: [
                MealIngredient(name: "Pechuga de pollo", quantity: "200g", grams: 200),
                MealIngredient(name: "Arroz integral", quantity: "150g (cocido)", grams: 150),
                MealIngredient(name: "Mezcla de lechugas", quantity: "100g", grams: 100),
                MealIngredient(name: "Tomate cherry", quantity: "50g", grams: 50),
                MealIngredient(name: "AOVE", quantity: "10ml", grams: 10)
            ],
            instructions: "1. Salpimentar la pechuga\n2. Grillar a fuego medio 5-6 min por lado\n3. Cocinar el arroz integral según instrucciones\n4. Preparar la ensalada y aliñar con AOVE y limón",
            prepTimeMinutes: 20,
            imageUrl: nil,
            alternatives: ["Salmón a la plancha", "Merluza al horno"]
        )

        let snack = MealDetail(
            name: "Plátano y tortitas de arroz",
            time: "17:00",
            calories: 160, proteinG: 3, carbsG: 35, fatsG: 1, fiberG: 3,
            ingredients: [
                MealIngredient(name: "Plátano", quantity: "1 unidad", grams: 120),
                MealIngredient(name: "Tortitas de arroz", quantity: "2 unidades", grams: 20)
            ],
            instructions: nil,
            prepTimeMinutes: 1,
            imageUrl: nil,
            alternatives: ["Manzana con mantequilla de cacahuete"]
        )

        let dinner = MealDetail(
            name: "Salmón al horno con verduras",
            time: "20:30",
            calories: 480, proteinG: 38, carbsG: 28, fatsG: 22, fiberG: 6,
            ingredients: [
                MealIngredient(name: "Salmón fresco", quantity: "180g", grams: 180),
                MealIngredient(name: "Camote / boniato", quantity: "150g", grams: 150),
                MealIngredient(name: "Brócoli", quantity: "100g", grams: 100),
                MealIngredient(name: "Espárragos", quantity: "80g", grams: 80),
                MealIngredient(name: "AOVE", quantity: "5ml", grams: 5)
            ],
            instructions: "1. Precalentar horno a 200°C\n2. Cortar el boniato en rodajas\n3. Colocar salmón y verduras en bandeja\n4. Rociar con AOVE, sal y pimienta\n5. Hornear 20-25 min",
            prepTimeMinutes: 30,
            imageUrl: nil,
            alternatives: ["Merluza al horno", "Pollo al horno con verduras"]
        )

        let dayMeals = DayMeals(breakfast: breakfast, midMorning: midMorning, lunch: lunch, snack: snack, dinner: dinner)

        return NutritionPlan(
            id: UUID(),
            userId: userId,
            planName: "Plan Semanal Personalizado",
            status: "active",
            startDate: Date(),
            endDate: nil,
            dailyCalories: 2200,
            dailyProteinG: 165,
            dailyCarbsG: 220,
            dailyFatsG: 73,
            dailyFiberG: 25,
            mealCount: 5,
            guidelines: nil,
            mealPlan: MealPlanData(
                monday: dayMeals, tuesday: dayMeals, wednesday: dayMeals,
                thursday: dayMeals, friday: dayMeals, saturday: dayMeals, sunday: dayMeals
            ),
            aiGenerated: false,
            createdBy: "Coach Luis",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
