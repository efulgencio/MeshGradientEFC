import SwiftUI

// MARK: - 1. MOTOR DE DISEÑO GENERATIVO (MESH GRADIENT)
// Usamos una estructura separada para que el fondo sea independiente del contenido.
struct AnimatedMeshView: View {
    @State private var t: Float = 0.0
    // Un timer de 0.02s nos da unos 50-60 FPS, ideal para animaciones suaves sin drenar la batería.
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    var body: some View {
        // El MeshGradient requiere un tamaño de rejilla (3x3 en este caso = 9 puntos).
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0], // Fila superior (Fija)
                [0, 0.5],
                [
                    // PUNTO CENTRAL DINÁMICO:
                    // Aquí aplicamos matemáticas para que el color "fluya".
                    0.5 + sinInRange(-0.1...0.1, t: t, c: 0.2),
                    0.5 + sinInRange(-0.1...0.1, t: t, c: 0.5)
                ],
                [1, 0.5], // Fila media (Laterales fijos)
                [0, 1], [0.5, 1], [1, 1]  // Fila inferior (Fija)
            ],
            colors: [
                .indigo, .purple, .black,
                .blue, .cyan, .teal, // Los colores del medio se mezclan al moverse el punto.
                .black, .indigo, .blue
            ]
        )
        .ignoresSafeArea()
        .onReceive(timer) { _ in t += 0.02 } // El motor de la animación.
    }
    
    // Función de ayuda para crear oscilaciones orgánicas (Efecto "Lava Lamp").
    func sinInRange(_ range: ClosedRange<Float>, t: Float, c: Float) -> Float {
        let mid = (range.lowerBound + range.upperBound) / 2
        let amplitude = (range.upperBound - range.lowerBound) / 2
        return mid + amplitude * sin(t + c)
    }
}

// MARK: - 2. VISTA DE INICIO (MICRO-ANIMACIONES)
struct ContentView: View {
    // Estados para controlar el movimiento de los elementos de la UI.
    @State private var isFloating = false
    @State private var isPulsing = false

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshView() // Capa de fondo
                
                VStack(spacing: 35) {
                    // ICONO DINÁMICO
                    Image(systemName: "wand.and.stars.inverse")
                        .font(.system(size: 90))
                        .foregroundStyle(.white)
                        // Combinamos sombra con escala para un efecto de "respiración".
                        .shadow(color: .cyan.opacity(isPulsing ? 0.7 : 0.2), radius: isPulsing ? 25 : 10)
                        .scaleEffect(isPulsing ? 1.1 : 1.0)
                    
                    VStack(spacing: 12) {
                        Text("Dynamic UI")
                            .font(.system(size: 45, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text("Explorando el futuro de SwiftUI")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    // OFFSET: Crea un movimiento de flotación vertical.
                    .offset(y: isFloating ? -12 : 12)

                    NavigationLink(destination: FormView()) {
                        HStack {
                            Text("Comenzar Experiencia")
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .background(.white)
                        .foregroundStyle(.indigo)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.3), radius: 15, y: 10)
                    }
                    .offset(y: isFloating ? -6 : 6) // Movimiento desfasado para efecto parallax.
                }
            }
            .onAppear {
                // Definimos animaciones infinitas con autoreverse.
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    isFloating = true
                }
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
        .tint(.white)
    }
}

// MARK: - 3. VISTA DE DETALLE (GLASSMORPHISM & TRANSICIONES)
struct FormView: View {
    @State private var nombre: String = ""
    @State private var bio: String = ""
    @State private var showElements = false // Control para la entrada suave.
    
    var body: some View {
        ZStack {
            AnimatedMeshView()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    // TITULAR CON ANIMACIÓN DE ENTRADA LATERAL
                    Text("Configuración")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .offset(x: showElements ? 0 : -30)
                        .opacity(showElements ? 1 : 0)

                    VStack(spacing: 20) {
                        // INPUT CON EFECTO CRISTAL
                        customInput(label: "NOMBRE", text: $nombre, icon: "person.fill")
                        
                        // TEXTEDITOR CON TRUCO DE SISTEMA
                        VStack(alignment: .leading, spacing: 10) {
                            Label("BIOGRAFÍA", systemImage: "text.alignleft")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.6))
                            
                            TextEditor(text: $bio)
                                .frame(height: 150)
                                // IMPORTANTE: .scrollContentBackground(.hidden) permite ver el material de cristal.
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .background(.ultraThinMaterial.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .foregroundStyle(.white)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.2), lineWidth: 0.5))
                        }
                    }
                    // La entrada desde abajo añade un toque de calidad (UX).
                    .offset(y: showElements ? 0 : 40)
                    .opacity(showElements ? 1 : 0)

                    // BOTÓN CON GRADIENTE NATIVO
                    Button(action: {}) {
                        Text("Guardar Cambios")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.gradient) // Uso de .gradient (iOS 16+).
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .shadow(color: .blue.opacity(0.4), radius: 15, y: 8)
                    }
                    .scaleEffect(showElements ? 1 : 0.9)
                    .opacity(showElements ? 1 : 0)
                }
                .padding(25)
            }
        }
        .onAppear {
            // Animación tipo muelle (Spring) para una entrada más física y menos lineal.
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                showElements = true
            }
        }
    }

    // Función para evitar la repetición de código en los inputs.
    @ViewBuilder
    func customInput(label: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(label, systemImage: icon)
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.6))
            
            TextField("", text: text, prompt: Text("Escribe aquí...").foregroundStyle(.white.opacity(0.3)))
                .padding()
                .background(.ultraThinMaterial.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .foregroundStyle(.white)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(.white.opacity(0.2), lineWidth: 0.5))
        }
    }
}
