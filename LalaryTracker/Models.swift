//
//  Models.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 29.10.2025.
//

import Foundation

// MARK: Тип платежу
enum PaymentType: String, Codable, CaseIterable, Identifiable {
    case card = "Картка"
    case cash = "Готівка"
    case other = "Інше"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .card:
            return "creditcard.fill"
        case .cash:
            return "banknote.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
}

// MARK: Платіж (Транзакція)
struct Payment: Codable, Identifiable, Hashable {
    let id: UUID
    var date: Date
    var amount: Double
    var type: PaymentType
    var note: String
    
    init(id: UUID = UUID(), date: Date, amount: Double, type: PaymentType, note: String = "") {
        self.id = id
        self.date = date
        self.amount = amount
        self.type = type
        self.note = note
    }
}

// MARK: - Урок
struct Lesson: Codable, Identifiable, Hashable {
    let id: UUID
    var date: Date
    var durationHours: Double
    var type: LessonType
    var rateApplied: Double

    var cost: Double {
        durationHours * rateApplied
    }
    
    init(id: UUID = UUID(), date: Date, durationHours: Double, type: LessonType, rateApplied: Double) {
        self.id = id
        self.date = date
        self.durationHours = durationHours
        self.type = type
        self.rateApplied = rateApplied
    }
}

// MARK: - Тип Уроку
struct LessonType: Codable, Hashable, Identifiable {
    let id: UUID
    var name: String
    var defaultRate: Double
    
    init(id: UUID = UUID(), name: String, defaultRate: Double) {
        self.id = id
        self.name = name
        self.defaultRate = defaultRate
    }
}

// MARK: - Викладач
struct Teacher: Codable, Identifiable {
    let id: UUID
    var name: String
    var lessons: [Lesson]
    var payments: [Payment]
    
    init(id: UUID = UUID(), name: String, lessons: [Lesson] = [], payments: [Payment] = []) {
        self.id = id
        self.name = name
        self.lessons = lessons
        self.payments = payments
    }
    
    var totalEarned: Double {
        lessons.reduce(0) { $0 + $1.cost }
    }
    
    var totalPaid: Double {
        payments.reduce(0) { $0 + $1.amount }
    }
    
    var currentBalance: Double {
        totalEarned - totalPaid
    }
    
    func totalPayments(for date: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        
        return payments
            .filter { payment in
                let paymentComponents = calendar.dateComponents([.year, .month], from: payment.date)
                return paymentComponents.year == components.year && paymentComponents.month == components.month
            }
            .reduce(0) { $0 + $1.amount }
    }

    func totalEarned(for date: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        
        return lessons
            .filter { lesson in
                let lessonComponents = calendar.dateComponents([.year, .month], from: lesson.date)
                return lessonComponents.year == components.year && lessonComponents.month == components.month
            }
            .reduce(0) { $0 + $1.cost }
    }
}
