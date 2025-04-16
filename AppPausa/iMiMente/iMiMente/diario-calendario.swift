import SwiftUI

// Modelo de datos para una entrada del diario (actualizado)
struct DiaryEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let text: String
    let feeling: Feeling
    
    // Función para obtener solo la fecha (sin hora)
    var dateOnly: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
}

// Enum actualizado para ser Codable
enum Feeling: String, CaseIterable, Codable {
    case happy = "Alegre"
    case worried = "Preocupado"
    case sad = "Triste"
    case angry = "Enojado"
    case anxious = "Ansioso"
    case relaxed = "Relajado"
    
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .worried: return .purple
        case .sad: return .blue
        case .angry: return .red
        case .anxious: return .green
        case .relaxed: return .cyan
        }
    }
}

// Clase para manejar los datos del diario
class DiaryData: ObservableObject {
    @Published var entries: [DiaryEntry] = []
    
    init() {
        loadEntries()
    }
    
    func saveEntry(_ entry: DiaryEntry) {
        if let index = entries.firstIndex(where: { $0.dateOnly == entry.dateOnly }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        saveEntries()
    }
    
    func entry(for date: Date) -> DiaryEntry? {
        let dateOnly = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date))!
        return entries.first { $0.dateOnly == dateOnly }
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "diaryEntries")
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "diaryEntries"),
           let decoded = try? JSONDecoder().decode([DiaryEntry].self, from: data) {
            entries = decoded
        }
    }
}

// Vista del Calendario
struct DiarioCalendarioView: View {
    @EnvironmentObject var diaryData: DiaryData
    @State private var selectedDate: Date = Date()
    @State private var showingDetail = false
    
    var body: some View {
        VStack {
            // Encabezado con mes/año y botones de navegación
            MonthHeader(selectedDate: $selectedDate)
            
            // Días de la semana
            WeekdaysHeader()
            
            // Grid de días del mes
            CalendarGridView(selectedDate: $selectedDate, diaryData: diaryData, showingDetail: $showingDetail)
        }
        .padding()
        .sheet(isPresented: $showingDetail) {
            if let entry = diaryData.entry(for: selectedDate) {
                DiaryEntryDetailView(entry: entry)
            }
        }
        .navigationBarTitle("Historial", displayMode: .inline)
    }
}

// Vista de detalle de una entrada (solo lectura)
struct DiaryEntryDetailView: View {
    let entry: DiaryEntry
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(dateFormatter.string(from: entry.date))
                .font(.headline)
            
            Text(entry.text)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            HStack {
                Text("Sentimiento:")
                Text(entry.feeling.rawValue)
                    .padding(8)
                    .background(entry.feeling.color)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Detalle", displayMode: .inline)
    }
}

// Componentes del calendario
struct MonthHeader: View {
    @Binding var selectedDate: Date
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }
    
    var body: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            Text(monthFormatter.string(from: selectedDate).capitalized)
                .font(.title2)
                .bold()
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.vertical)
    }
    
    private func previousMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
    }
}

struct WeekdaysHeader: View {
    private let weekdays = ["D", "L", "M", "M", "J", "V", "S"]
    
    var body: some View {
        HStack {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .font(.caption)
            }
        }
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    @ObservedObject var diaryData: DiaryData
    @Binding var showingDetail: Bool
    
    var body: some View {
        let daysInMonth = daysForMonth()
        let firstDayOfWeek = firstWeekdayOfMonth()
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            // Espacios vacíos para alinear el primer día
            ForEach(0..<firstDayOfWeek, id: \.self) { _ in
                Text("")
            }
            
            // Días del mes
            ForEach(daysInMonth, id: \.self) { date in
                DayView(date: date,
                       selectedDate: $selectedDate,
                       diaryData: diaryData,
                       showingDetail: $showingDetail)
            }
        }
    }
    
    private func daysForMonth() -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        
        return range.compactMap { day -> Date? in
            let components = DateComponents(year: calendar.component(.year, from: selectedDate),
                                           month: calendar.component(.month, from: selectedDate),
                                           day: day)
            return calendar.date(from: components)
        }
    }
    
    private func firstWeekdayOfMonth() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: components)!
        
        return calendar.component(.weekday, from: firstDay) - 1 // Ajuste para que Domingo = 0
    }
}

struct DayView: View {
    let date: Date
    @Binding var selectedDate: Date
    @ObservedObject var diaryData: DiaryData
    @Binding var showingDetail: Bool
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var entry: DiaryEntry? {
        diaryData.entry(for: date)
    }
    
    var body: some View {
        let day = Calendar.current.component(.day, from: date)
        let hasEntry = entry != nil
        
        Button(action: {
            selectedDate = date
            if hasEntry {
                showingDetail = true
            }
        }) {
            ZStack {
                // Fondo para días con entrada
                if hasEntry {
                    Circle()
                        .fill(entry!.feeling.color.opacity(0.3))
                }
                
                // Número del día
                Text("\(day)")
                    .foregroundColor(textColor())
                    .fontWeight(isToday ? .bold : .regular)
                    .frame(width: 30, height: 30)
                
                // Indicador de entrada
                if hasEntry {
                    Circle()
                        .fill(entry!.feeling.color)
                        .frame(width: 8, height: 8)
                        .offset(y: 12)
                }
            }
            .frame(height: 40)
        }
        .overlay(
            isSelected ? Circle().stroke(Color.blue, lineWidth: 2) : nil
        )
    }
    
    private func textColor() -> Color {
        let isCurrentMonth = Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month)
        return isCurrentMonth ? .primary : .secondary
    }
}

// Modifica la vista Diario para usar DiaryData
struct Diario: View {
    @EnvironmentObject var diaryData: DiaryData
    @State private var diaryText = ""
    @State private var selectedFeeling: Feeling?
    @State private var currentPhrase = randomPhrases.randomElement() ?? "¿En qué estás pensando hoy?"
    @State private var showFeelingsList = false
    @State private var showSideMenu = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Contenido principal (igual que antes)
                // ...
                
                // Al guardar la entrada, ahora usa diaryData
                private func saveEntry() {
                    guard let feeling = selectedFeeling else { return }
                    let newEntry = DiaryEntry(date: Date(), text: diaryText, feeling: feeling)
                    diaryData.saveEntry(newEntry)
                    diaryText = ""
                    selectedFeeling = nil
                    currentPhrase = randomPhrases.randomElement() ?? "¿En qué estás pensando hoy?"
                }
            }
        }
    }
}

// En tu App principal, asegúrate de proporcionar el EnvironmentObject
@main
struct iMiMenteApp: App {
    @StateObject private var diaryData = DiaryData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(diaryData)
        }
    }
}

/* ORIGINAL
 struct diario_calendario: View {
 var body: some View {
 Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
 }
 }
 
 struct diario_calendario_Previews: PreviewProvider {
 static var previews: some View {
 diario_calendario()
 }
 }
 */
