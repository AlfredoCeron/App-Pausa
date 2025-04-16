import SwiftUI

struct Task: Identifiable, Codable {
    let id = UUID()
    var title: String
    var subject: String
    var dueDate: Date?
    var isCompleted = false
}

class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []
    
    // Cambiar de 'private' a 'fileprivate' o eliminar 'private'
    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "savedTasks")
        }
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func toggleCompletion(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "savedTasks"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
}
