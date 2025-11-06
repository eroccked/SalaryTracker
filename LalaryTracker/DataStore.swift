import Foundation
import Combine


final class DataStore: ObservableObject {
    

    @Published var teachers: [Teacher] = [] {
        didSet {
            saveTeachers()
            loadTypes()
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

            lessonTypes = [
                LessonType(name: "ПКО", defaultRate: 450.0),
                LessonType(name: "МКА", defaultRate: 330.0),
                LessonType(name: "Школа", defaultRate: 220.0)
            ]
        }
}
