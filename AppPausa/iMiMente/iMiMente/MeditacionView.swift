import SwiftUI

struct MeditacionView: View {
    // Configuración de la meditación
    @State private var selectedMode = "Clásico (4-7-8)"
    @State private var showModePicker = false
    let modes = ["Clásico (4-7-8)", "Rápida (3-4-5)", "Profundo (5-10-10)", "Personalizado"]
    
    // Tiempos para cada modo
    private var currentTimes: [Int] {
        switch selectedMode {
        case "Clásico (4-7-8)": return [4, 7, 8]
        case "Rápida (3-4-5)": return [3, 4, 5]
        case "Profundo (5-10-10)": return [5, 10, 10]
        default: return [customInhale, customHold, customExhale]
        }
    }
    
    // Estados
    @State private var isMeditating = false
    @State private var currentPhase = 0 // 0: Inhala, 1: Sostén, 2: Exhala
    @State private var timeRemaining = 0
    @State private var emojiPosition = 0 // 0: Inicial, 1: Derecha, 2: Abajo, 3: Izquierda
    @State private var backgroundColor = Color.blue
    
    // Personalizado
    @State private var customInhale = 4
    @State private var customHold = 7
    @State private var customExhale = 8
    
    var body: some View {
        VStack(spacing: 25) {
            // Animación del triángulo
            ZStack {
                // Fondo dinámico
                RoundedRectangle(cornerRadius: 25)
                    .fill(backgroundColor.opacity(0.3))
                    .frame(width: 350, height: 350)
                
                // Triángulo
                Triangle()
                    .stroke(Color.white, lineWidth: 10)
                    .frame(width: 280, height: 280)
                
                // Emoji animado
                Text(currentEmoji)
                    .font(.system(size: 50))
                    .offset(x: emojiOffset().x, y: emojiOffset().y)
                    .animation(.linear(duration: 1), value: emojiPosition)
                
                // Textos
                VStack {
                    Spacer().frame(height: 100)
                    Text(currentPhaseText)
                        .font(.system(size: 28, weight: .bold))
                    Text("\(timeRemaining)")
                        .font(.system(size: 48, design: .monospaced))
                }
            }
            .frame(height: 380)
            
            // Selector de modo
            VStack(alignment: .center, spacing: 10) {
                Button(action: { showModePicker.toggle() }) {
                    HStack {
                        VStack(alignment: .center, spacing: 4) {
                            Text("Tipo de respiración:")
                                .foregroundColor(.primary)
                            Text(selectedMode)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Image(systemName: showModePicker ? "chevron.up" : "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                if showModePicker {
                    VStack(spacing: 8) {
                        ForEach(modes, id: \.self) { mode in
                            Button(action: {
                                selectedMode = mode
                                showModePicker = false
                            }) {
                                Text(mode)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(10)
                            }
                        }
                    }
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 30)
            .disabled(isMeditating)
            
            // Personalizado
            if selectedMode == "Personalizado" && !isMeditating {
                VStack(spacing: 15) {
                    Stepper("Inhala: \(customInhale) seg", value: $customInhale, in: 1...10)
                    Stepper("Sostén: \(customHold) seg", value: $customHold, in: 1...15)
                    Stepper("Exhala: \(customExhale) seg", value: $customExhale, in: 1...15)
                }
                .padding(.horizontal, 40)
            }
            
            // Botón de control
            Button(action: toggleMeditation) {
                Text(isMeditating ? "Detener" : "Comenzar")
                    .frame(width: 200)
                    .padding()
                    .background(isMeditating ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .onAppear(perform: resetMeditation)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if isMeditating {
                updateMeditation()
            }
        }
    }
    
    // Variables calculadas
    private var currentEmoji: String {
        switch emojiPosition {
        case 1: return "😤" // Derecha (Inhala)
        case 2: return "😬" // Abajo (Sostén)
        case 3: return "😮‍💨" // Izquierda (Exhala)
        default: return "🧘" // Arriba (inicial)
        }
    }
    
    private var currentPhaseText: String {
        ["INHALA", "SOSTÉN", "EXHALA"][currentPhase]
    }
    
    private func emojiOffset() -> (x: CGFloat, y: CGFloat) {
        let side = 140.0
        switch emojiPosition {
        case 1: return (side - 15, -15)  // Derecha (Inhala) - Ajustado para estar justo en la arista
        case 2: return (0, side - 15)     // Abajo (Sostén)
        case 3: return (-side + 15, -15)  // Izquierda (Exhala)
        default: return (0, -side + 25)   // Arriba (inicial)
        }
    }
    
    private func toggleMeditation() {
        isMeditating ? stopMeditation() : startMeditation()
    }
    
    private func startMeditation() {
        resetMeditation()
        isMeditating = true
        // Forzar posición inicial correcta
        emojiPosition = 1 // Comenzar directamente en Inhala (derecha)
        timeRemaining = currentTimes[0]
    }
    
    private func stopMeditation() {
        isMeditating = false
    }
    
    private func resetMeditation() {
        currentPhase = 0
        emojiPosition = 0
        timeRemaining = currentTimes[0]
        backgroundColor = .blue
    }
    
    private func updateMeditation() {
        timeRemaining -= 1
        
        if timeRemaining <= 0 {
            if currentPhase == 2 { // Si es la fase de Exhala
                stopMeditation()
                resetMeditation()
                return
            }
            
            // Avanzar a la siguiente fase
            currentPhase += 1
            timeRemaining = currentTimes[currentPhase]
            
            // Actualizar posición del emoji exactamente donde debe estar
            emojiPosition = currentPhase + 1 // Esto ahora dará: 1 (Inhala), 2 (Sostén), 3 (Exhala)
            
            withAnimation(.linear(duration: 1)) {
                backgroundColor = [.blue, .purple, .pink][currentPhase]
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + 20))
        path.addLine(to: CGPoint(x: rect.maxX - 20, y: rect.maxY - 20))
        path.addLine(to: CGPoint(x: rect.minX + 20, y: rect.maxY - 20))
        path.closeSubpath()
        return path
    }
}

struct Meditacion_Previews: PreviewProvider {
    static var previews: some View {
        MeditacionView()
    }
}
