import Foundation
import Combine


final class DataStore: ObservableObject {
    

    @Published var teachers: [Teacher] = [] {
        didSet {
            saveTeachers()
        }
    }
    @Published var lessonTypes: [LessonType] = [] {
            didSet {
                saveTypes()
            }
    }
    
    private let saveKey = "TeacherData"
    private let typesKey = "LessonTypesData"
    
    init() {
        loadTeachers()
    }
    

    
    func saveTeachers() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(teachers)
            
            UserDefaults.standard.set(data, forKey: saveKey)
            print("Дані успішно збережено.")
        } catch {
            print("Помилка кодування та збереження даних: \(error.localizedDescription)")
        }
    }
    
    func loadTeachers() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey) {
            do {

                let decoder = JSONDecoder()
                teachers = try decoder.decode([Teacher].self, from: savedData)
                print("Дані успішно завантажено. Кількість викладачів: \(teachers.count)")
                return
            } catch {
                print("Помилка декодування та завантаження даних: \(error.localizedDescription)")
            }
        }
        
        teachers = []
    }
    
    func saveTypes() {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(lessonTypes)
                UserDefaults.standard.set(data, forKey: typesKey)
            } catch {
                print("Помилка збереження типів: \(error.localizedDescription)")
            }
        }

        func loadTypes() {
            if let savedData = UserDefaults.standard.data(forKey: typesKey) {
                do {
                    let decoder = JSONDecoder()
                    lessonTypes = try decoder.decode([LessonType].self, from: savedData)
                    return
                } catch {
                    print("Помилка завантаження типів: \(error.localizedDescription)")
                }
            }

            // Якщо типів немає, ініціалізуємо базові
            lessonTypes = [
                LessonType(name: "ПКО", defaultRate: 450.0),
                LessonType(name: "МКА", defaultRate: 330.0),
                LessonType(name: "Школа", defaultRate: 220.0)
            ]
        }
    

//    func addSampleData() {
//        let sampleLesson1 = Lesson(date: Date(), durationHours: 1.5, rateApplied: 300.0, type: "Індивідуальний", isPaid: false)
//        let sampleLesson2 = Lesson(date: Date().addingTimeInterval(-86400), durationHours: 1.0, rateApplied: 400.0, type: "Підготовка до IELTS", isPaid: true)
//        
//        var teacher1 = Teacher(name: "Олена Петрівна", lessons: [sampleLesson1])
//        var teacher2 = Teacher(name: "Іван Васильович", lessons: [sampleLesson2])
//        
//        teachers.append(teacher1)
//        teachers.append(teacher2)
//    }
}
