import SwiftUI

// MARK: - Vista Principal del Calendario
struct DiarioCalendarioView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @State private var selectedDate = Date()
    @State private var showingDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Encabezado con mes/año y controles de navegación
            MonthHeader(selectedDate: $selectedDate)
            
            // Días de la semana (L, M, M, J, V, S, D)
            WeekdaysHeader()
            
            // Grid de días del mes
            CalendarGridView(
                selectedDate: $selectedDate,
                diaryStore: diaryStore,
                showingDetail: $showingDetail
            )
        }
        .padding()
        .sheet(isPresented: $showingDetail) {
            if let entry = diaryStore.entry(for: selectedDate) {
                DiaryEntryDetailView(entry: entry)
            }
        }
        .navigationBarTitle("Historial", displayMode: .inline)
    }
}

// MARK: - Componentes del Calendario

// Encabezado del mes (controles de navegación)
struct MonthHeader: View {
    @Binding var selectedDate: Date
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    var body: some View {
        HStack {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.headline)
            }
            
            Spacer()
            
            Text(monthFormatter.string(from: selectedDate).capitalized)
                .font(.headline)
                .bold()
            
            Spacer()
            
            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.headline)
            }
        }
        .padding(.vertical)
    }
    
    private func changeMonth(by value: Int) {
        guard let newDate = Calendar.current.date(
            byAdding: .month,
            value: value,
            to: selectedDate
        ) else { return }
        
        selectedDate = newDate
    }
}

// Encabezado de días de la semana
struct WeekdaysHeader: View {
    private let weekdays = ["D", "L", "Ma", "Mi", "J", "V", "S"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
    }
}

// Grid de días del mes
struct CalendarGridView: View {
    @Binding var selectedDate: Date
    @ObservedObject var diaryStore: DiaryStore
    @Binding var showingDetail: Bool
    
    var body: some View {
        let days = generateDaysInMonth()
        let firstWeekday = Calendar.current.component(.weekday, from: days.first!) - 1
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
            // Espacios vacíos para alinear el primer día
            ForEach(0..<firstWeekday, id: \.self) { _ in
                Text("")
                    .frame(height: 40)
            }
            
            // Días del mes
            ForEach(days, id: \.self) { date in
                DayCell(
                    date: date,
                    selectedDate: $selectedDate,
                    diaryStore: diaryStore,
                    showingDetail: $showingDetail
                )
            }
        }
    }
    
    private func generateDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        var days: [Date] = []
        
        // Obtener todos los días del mes actual
        if let range = calendar.range(of: .day, in: .month, for: selectedDate) {
            for day in range {
                if let date = calendar.date(from: DateComponents(year: year, month: currentMonth, day: day)) {
                    days.append(date)
                }
            }
        }
        
        return days
    }
}

// Celda individual para cada día
struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date
    @ObservedObject var diaryStore: DiaryStore
    @Binding var showingDetail: Bool
    
    private var entry: DiaryEntry? {
        diaryStore.entry(for: date)
    }
    
    private var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month)
    }
    
    var body: some View {
        Button(action: {
            selectedDate = date
            if entry != nil {
                showingDetail = true
            }
        }) {
            ZStack {
                // Fondo para el día seleccionado
                if isSelected {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                }
                
                // Número del día
                Text("\(Calendar.current.component(.day, from: date))")
                    .foregroundColor(isCurrentMonth ? .primary : .secondary)
                    .font(.system(size: 16))
                
                // Indicador de sentimiento (si existe entrada)
                if let entry = entry {
                    Circle()
                        .fill(entry.feeling.color)
                        .frame(width: 6, height: 6)
                        .offset(y: 12)
                }
            }
            .frame(height: 40)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Vista de Detalle (Solo Lectura)
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
            
            ScrollView {
                Text(entry.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview
struct DiarioCalendarioView_Previews: PreviewProvider {
    static var previews: some View {
        let mockStore = DiaryStore()
        mockStore.entries = [
            DiaryEntry(
                date: Date(),
                text: "Hoy fue un gran día. Aprendí mucho sobre SwiftUI.",
                feeling: .happy
            )
        ]
        
        return DiarioCalendarioView()
            .environmentObject(mockStore)
    }
}
