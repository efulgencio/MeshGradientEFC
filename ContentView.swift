import SwiftUI

// MARK: - 1. MOTOR DE RENDERIZADO: InteractiveMeshView
// Esta vista actúa como un "shader" procedimental que reacciona a estados externos.
struct InteractiveMeshView: View {
    @Binding var dragOffset: CGSize
    @Binding var isSurging: Bool
    @State private var t: Float = 0.0
    
    // El Timer es el latido del fondo. 0.02s asegura fluidez sin saturar el hilo principal.
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            // MeshGradient: Una rejilla de 3x3 puntos.
            // Puntos: [0,0] es arriba-izq, [1,1] es abajo-der.
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0], // Fila 1: Estática para anclar el diseño.
                    [0, 0.5],
                    [
                        // LÓGICA DEL PUNTO CENTRAL (Índice 4):
                        // 1. Base: 0.5 (centro)
                        // 2. Interacción: dragOffset normalizado (dividiendo por el tamaño de pantalla).
                        // 3. Ruido: sinInRange añade una vibración orgánica constante.
                        // 4. Modo Surge: Si isSurging es true, multiplicamos la amplitud por 8 (0.05 a 0.4).
                        Float(0.5 + (dragOffset.width / size.width) * 0.3) + sinInRange(isSurging ? -0.4...0.4 : -0.05...0.05, t: t, c: 0.2),
                        Float(0.5 + (dragOffset.height / size.height) * 0.3) + sinInRange(isSurging ? -0.4...0.4 : -0.05...0.05, t: t, c: 0.5)
                    ],
                    [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: [
                    .black, isSurging ? .indigo : .purple, .black,
                    .indigo, isSurging ? .white : .cyan, .blue,
                    .black, .indigo, .black
                ]
            )
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                // Si estamos en 'Surge', aceleramos el tiempo t para que la malla se mueva más rápido.
                t += isSurging ? 0.08 : 0.02
            }
        }
    }
    
    // Función trigonométrica para suavizar el movimiento.
    // Transforma una progresión lineal (t) en un ciclo infinito de ida y vuelta.
    func sinInRange(_ range: ClosedRange<Float>, t: Float, c: Float) -> Float {
        let mid = (range.lowerBound + range.upperBound) / 2
        let amplitude = (range.upperBound - range.lowerBound) / 2
        return mid + amplitude * sin(t + c)
    }
}

// MARK: - 2. ESCENA PRINCIPAL (Lógica de Negocio y UI)
struct ContentView: View {
    // ESTADOS DE ANIMACIÓN
    @State private var dragOffset = CGSize.zero
    @State private var isSurging = false
    @State private var navigateToDetails = false
    @State private var lightLocation: CGFloat = -1.0 // Controla la posición del haz de luz (-1 a 1)
    
    // ESTADOS DE FEEDBACK
    @State private var chargeProgress: CGFloat = 0.0 // 0.0 a 1.0 para el anillo circular

    var body: some View {
        NavigationStack {
            ZStack {
                // FONDO: Siempre pasamos las referencias de estado
                InteractiveMeshView(dragOffset: $dragOffset, isSurging: $isSurging)
                
                VStack(spacing: 60) {
                    
                    // COMPONENTE: INDICADOR DE NÚCLEO (Core)
                    ZStack {
                        // Anillo de progreso: Solo se dibuja la parte proporcional a chargeProgress
                        Circle()
                            .trim(from: 0, to: chargeProgress)
                            .stroke(Color.cyan, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(-90)) // Empezar desde arriba
                            .blur(radius: isSurging ? 0 : 5) // Efecto de foco al activarse
                        
                        // Icono dinámico con SymbolEffect (iOS 17+)
                        Image(systemName: isSurging ? "bolt.fill" : "bolt.ring.closed")
                            .font(.system(size: 80))
                            .foregroundStyle(isSurging ? .white : .white.opacity(0.8))
                            .symbolEffect(.bounce, value: isSurging) // Animación nativa de Apple
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSurging)

                    VStack(spacing: 25) {
                        // TEXTO DE SISTEMA: Estilo monospaced para dar sensación de terminal/tecnología
                        Text(isSurging ? "INITIALIZING SURGE..." : "SYSTEM READY")
                            .font(.system(.caption, design: .monospaced))
                            .bold()
                            .foregroundStyle(isSurging ? .cyan : .white.opacity(0.5))
                        
                        // BOTÓN DE ACCIÓN CON SHIMMER
                        Button {
                            runSequence()
                        } label: {
                            Text("EJECUTAR")
                                .font(.headline)
                                .tracking(4) // Espaciado entre letras para elegancia
                                .foregroundStyle(.white)
                                .frame(width: 240, height: 60)
                                .background {
                                    ZStack {
                                        // Efecto cristalino nativo
                                        Capsule().fill(.ultraThinMaterial)
                                        
                                        // EL HAZ DE LUZ (SHIMMER)
                                        // Un gradiente pequeño que se mueve horizontalmente
                                        Capsule()
                                            .fill(LinearGradient(colors: [.clear, .white.opacity(0.5), .clear], startPoint: .leading, endPoint: .trailing))
                                            .frame(width: 100)
                                            .offset(x: lightLocation * 120) // Multiplicamos por la mitad del ancho del botón
                                    }
                                }
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 0.5))
                                .scaleEffect(isSurging ? 0.92 : 1.0)
                        }
                        .disabled(isSurging) // Evitamos que el usuario pulse dos veces durante la secuencia
                    }
                }
            }
            .onAppear {
                // Loop infinito del haz de luz: tarda 3 segundos en cruzar
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    lightLocation = 1.0
                }
            }
            // Navegación programática mediante un estado Booleano
            .navigationDestination(isPresented: $navigateToDetails) {
                FormView()
            }
            // GESTO DE ARRASTRE: Afecta a la malla de fondo en tiempo real
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        withAnimation(.interactiveSpring()) {
                            dragOffset = value.translation
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                    }
            )
        }
    }

    // MARK: - SECUENCIA DE TRANSICIÓN
    // Esta función orquestra múltiples animaciones en paralelo antes de la navegación.
    func runSequence() {
        // 1. Estado de sobrecarga
        withAnimation(.easeIn(duration: 0.2)) {
            isSurging = true
        }
        
        // 2. Carga del anillo circular (Sincronizado con el delay de navegación)
        withAnimation(.linear(duration: 1.2)) {
            chargeProgress = 1.0
        }
        
        // 3. Ejecución del salto de pantalla
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            navigateToDetails = true
            
            // Limpieza para cuando el usuario regrese
            isSurging = false
            chargeProgress = 0.0
        }
    }
}

// MARK: - VISTA DESTINO
struct FormView: View {
    var body: some View {
        ZStack {
            InteractiveMeshView(dragOffset: .constant(.zero), isSurging: .constant(false))
            Text("Entorno Cargado")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
        }
    }
}
