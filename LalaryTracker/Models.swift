//
//  Models.swift
//  LalaryTracker
//
//  Created by Taras Buhra on 30.10.2025.
//

import Foundation

struct Lesson: Identifiable, Codable{
    let id = UUID()
    var date: Date
    var durationHours: Double
    var rateApplied: Double
    var type: String
    var isPaid: Bool = false
    
    var cost: Double{
        return durationHours * rateApplied
    }
}

struct Teacher: Identifiable, Codable{
    let id = UUID()
    var name: String
    
    var lessons: [Lesson] = []
    
    var totalUnpaidSalary: Double{
        let unpaidLessons = lessons.filter { !$0.isPaid}
        let totalCost = unpaidLessons.reduce(0.0) {sum, lesson in sum + lesson.cost}
        return totalCost
    }
    
    var totalPaidSalary: Double{
        let paidLessons = lessons.filter({ $0.isPaid })
        let totalCost = paidLessons.reduce(0.0) {sum, lesson in sum + lesson.cost}
        return totalCost
    }
}
