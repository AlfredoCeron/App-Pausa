import SwiftUI

struct PendientesView: View {
    @EnvironmentObject var taskStore: TaskStore
    @State private var showingAddTaskView = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Lista de tareas con swipe-to-delete
                List {
                    ForEach(taskStore.tasks) { task in
                        TaskRow(task: task)
                            .listRowBackground(task.isCompleted ? Color.gray.opacity(0.1) : Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteTask(task)
                                } label: {
                                    Label("Eliminar", systemImage: "trash.fill")
                                }
                            }
                    }
                }
                .listStyle(.plain) // Mantiene el estilo actual
                
                // Botón inferior (se mantiene igual)
                HStack {
                    Spacer()
                    Button(action: { showingAddTaskView = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.green)
                            .padding()
                    }
                }
            }
            .navigationTitle("Pendientes")
            .sheet(isPresented: $showingAddTaskView) {
                AddTaskView(taskStore: taskStore)
            }
        }
    }
    
    // Función para eliminar tarea
    private func deleteTask(_ task: Task) {
        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
            taskStore.tasks.remove(at: index)
            taskStore.saveTasks()
        }
    }
}
