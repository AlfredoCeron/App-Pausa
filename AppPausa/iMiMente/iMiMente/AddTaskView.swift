import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var taskStore: TaskStore
    
    // Campos del formulario
    @State private var title = ""
    @State private var subject = ""
    @State private var dueDate: Date? = nil
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                // Campo: Materia
                Section(header: Text("Materia")) {
                    TextField("Ej: Matemáticas", text: $subject)
                }
                
                // Campo: Fecha (con selector)
                Section(header: Text("Fecha")) {
                    Button(action: { showDatePicker.toggle() }) {
                        HStack {
                            Text(dueDate?.formatted(date: .abbreviated, time: .omitted) ?? "Seleccionar fecha")
                            Spacer()
                            Image(systemName: "calendar")
                        }
                    }
                    if showDatePicker {
                        DatePicker(
                            "",
                            selection: Binding(get: { dueDate ?? Date() }, set: { dueDate = $0 }),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                }
                
                // Campo: Descripción
                Section(header: Text("Tarea")) {
                    TextField("Ej: Hacer ejercicios de álgebra", text: $title)
                }
            }
            .navigationTitle("Nueva Tarea")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Guardar") {
                    let newTask = Task(
                        title: title,
                        subject: subject,
                        dueDate: dueDate,
                        isCompleted: false
                    )
                    taskStore.addTask(newTask)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty || subject.isEmpty)
            )
        }
    }
}
