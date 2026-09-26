//
//  Formatting.swift
//  LalaryTracker
//

import Foundation

enum Fmt {
    static let locale = Locale(identifier: "uk_UA")

    private static let number: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    /// 12 400 ₴
    static func money(_ value: Double) -> String {
        (number.string(from: NSNumber(value: value)) ?? "0") + " ₴"
    }

    /// +12 400 ₴
    static func signedMoney(_ value: Double) -> String {
        (value > 0 ? "+" : "") + money(value)
    }

    /// 1,5 год
    static func hours(_ value: Double) -> String {
        (number.string(from: NSNumber(value: value)) ?? "0") + " год"
    }

    /// Вересень 2025 / Вересень
    static func month(_ date: Date, withYear: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = withYear ? "LLLL yyyy" : "LLLL"
        return formatter.string(from: date).capitalized(with: locale)
    }

    /// 22 вер. 2025
    static func day(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.abbreviated).year().locale(locale))
    }

    /// 1 урок / 3 уроки / 5 уроків
    static func lessons(_ count: Int) -> String {
        let mod10 = count % 10
        let mod100 = count % 100
        let word: String
        if mod10 == 1 && mod100 != 11 {
            word = "урок"
        } else if (2...4).contains(mod10) && !(12...14).contains(mod100) {
            word = "уроки"
        } else {
            word = "уроків"
        }
        return "\(count) \(word)"
    }
}

extension Date {
    func isSameMonth(as other: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: other, toGranularity: .month)
    }

    func addingMonths(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: value, to: self) ?? self
    }
}
