import SwiftUI

class DiaryStore: ObservableObject {
    @Published var entries: [DiaryEntry] = []
    
    func saveEntry(_ entry: DiaryEntry) {
        if let index = entries.firstIndex(where: { $0.dateOnly == entry.dateOnly }) {
            entries[index] = entry // Actualiza si ya existe
        } else {
            entries.append(entry) // Añade nueva entrada
        }
    }
    
    func entry(for date: Date) -> DiaryEntry? {
        let dateOnly = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date))!
        return entries.first { $0.dateOnly == dateOnly }
    }
}

// Extensión para comparar fechas sin hora
extension DiaryEntry {
    var dateOnly: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date))!
    }
}
