import SwiftUI

struct TaskRow: View {
    @EnvironmentObject var taskStore: TaskStore
    var task: Task
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd MMMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: {
                taskStore.toggleCompletion(for: task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            
            // Materia (ancho fijo)
            Text(task.subject)
                .frame(width: 100, alignment: .leading)
            
            // Espacio para fecha (siempre ocupa lugar)
            Text(task.dueDate != nil ? dateFormatter.string(from: task.dueDate!) : " ")
                .frame(width: 120, alignment: .leading)
                .font(.subheadline)
                .foregroundColor(task.dueDate != nil ? .primary : .clear) // Texto invisible si no hay fecha
            
            // Descripción (siempre alineada a la izquierda)
            Text(task.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
