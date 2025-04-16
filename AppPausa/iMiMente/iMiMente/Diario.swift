import SwiftUI

// Modelo de datos para una entrada del diario
struct DiaryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let text: String
    let feeling: Feeling
}

enum Feeling: String, CaseIterable {
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

let randomPhrases = [
    "¿En qué estás pensando hoy?",
    "¿Hoy fue un buen día?",
    "¿Qué aprendiste hoy?",
    "Escríbelo aquí antes de contárselo al grupo de WhatsApp",
    "No te preocupes, este diario ha leído cosas peores",
    "Cuéntale a tu diario. No interrumpe, no te juzga y no manda audios de 10 minutos",
    "Tu diario sí te escucha, a diferencia de tus amigos en el grupo de WhatsApp",
    "Si hoy fue un desastre, tendrás algo divertido para leer después"
]

struct Diario: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @State private var diaryText = ""
    @State private var selectedFeeling: Feeling?
    @State private var entries: [DiaryEntry] = []
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
                // Contenido principal
                VStack(alignment: .leading, spacing: 16) {
                    // Barra superior
                    HStack {
                        // Botón menú
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showSideMenu.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Botón calendario
                        NavigationLink(destination: DiarioCalendarioView()) {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Contenido del diario
                    Text(currentPhrase)
                        .font(.title3)
                        .italic()
                        .padding(.horizontal)
                    
                    Text(dateFormatter.string(from: Date()))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    TextEditor(text: $diaryText)
                        .frame(minHeight: 200)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    // Selector de sentimientos
                    Button(action: {
                        withAnimation {
                            showFeelingsList.toggle()
                        }
                    }) {
                        HStack {
                            Text(selectedFeeling?.rawValue ?? "Sentimiento predominante")
                                .foregroundColor(selectedFeeling != nil ? .white : .gray)
                            Spacer()
                            Image(systemName: showFeelingsList ? "chevron.up" : "chevron.down")
                        }
                        .padding()
                        .background(selectedFeeling?.color ?? Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    if showFeelingsList {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(Feeling.allCases, id: \.self) { feeling in
                                    Button(action: {
                                        selectedFeeling = feeling
                                        showFeelingsList = false
                                    }) {
                                        Text(feeling.rawValue)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                            .background(feeling.color)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .frame(maxHeight: 200) // Altura máxima para el scroll
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    
                    Button(action: saveEntry) {
                        Text("Guardar")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(diaryText.isEmpty || selectedFeeling == nil)
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
                
                // Menú lateral
                if showSideMenu {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showSideMenu = false
                            }
                        }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 25) {
                            Text("iMiMente")
                                .font(.title2)
                                .bold()
                                .padding(.top, 40)
                                .padding(.bottom, 20)
                            
                            NavigationLink(destination: PendientesView()) {
                                MenuItemView(icon: "checklist", text: "Pendientes") // Ya existe
                            }
                            
                            NavigationLink(destination: MeditacionView()) {
                                MenuItemView(icon: "brain.head.profile", text: "Meditación")
                            }
                            
                            NavigationLink(destination: DiarioCalendarioView()) {
                                MenuItemView(icon: "clock.arrow.circlepath", text: "Historial")
                            }
                            
                            Spacer()
                        }
                        .padding(.leading, 25)
                        .frame(width: UIScreen.main.bounds.width * 0.55)
                        .background(Color(.systemBackground))
                        .transition(.move(edge: .leading))
                        .shadow(radius: 5)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func saveEntry() {
        guard let feeling = selectedFeeling else { return }
        let newEntry = DiaryEntry(date: Date(), text: diaryText, feeling: feeling)
        diaryStore.saveEntry(newEntry)
        diaryText = ""
        selectedFeeling = nil
        currentPhrase = randomPhrases.randomElement() ?? "¿En qué estás pensando hoy?"
    }
}

// ... (El resto del código se mantiene igual: MenuItemView, PendientesView, MeditacionView, DiarioCalendarioView, y Diario_Previews)

struct MenuItemView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .frame(width: 24)
            Text(text)
                .font(.headline)
        }
        .foregroundColor(.primary)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}


struct Diario_Previews: PreviewProvider {
    static var previews: some View {
        Diario()
    }
}

/*      ORIGINAL CODE
import SwiftUI

struct Diario: View {
    var body: some View {
        Text(/@START_MENU_TOKEN@/"Hello, World!"/@END_MENU_TOKEN@/)
    }
}

struct Diario_Previews: PreviewProvider {
    static var previews: some View {
        Diario()
    }
}

 kinup-sw para presentar (en mac como ipad)
 presentacion para 5 min maximo.
 Aterrizar bien idea principal 

*/
