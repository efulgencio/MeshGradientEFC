⚡️ Reactive Mesh & Energy Flow UI
Una experiencia inmersiva desarrollada íntegramente en SwiftUI que explora las capacidades de los Mesh Gradients de iOS 18+, combinando micro-interacciones avanzadas, efectos de cristal (Glassmorphism) y una navegación orquestada basada en la anticipación del usuario.

![](video_ui_gradient.mov)

<video src="https://github.com/TU_USUARIO/TU_REPO/raw/main/video_ui_gradient.mov" width="600" autoplay loop muted playsinline>
</video>

 <div align="center">
  <video src="video_ui_gradient.mov" width="600" autoplay loop muted playsinline>
  </video>
</div>


✨ Características Principales
Interactive Mesh Gradient: Fondo generativo basado en una malla de 3x3 que reacciona en tiempo real a los gestos del usuario.

Energy Surge Effect: Animación de "sobrecarga" que altera la física y los colores del degradado al interactuar con elementos críticos.

Button Shimmer: Efecto de haz de luz dinámico (shimmer) mediante gradientes lineales animados para guiar la atención.

Advanced Glassmorphism: Uso profundo de .ultraThinMaterial y bordes con opacidad para crear jerarquía visual sin assets externos.

Orchestrated Navigation: Transición programática con un delay de 1.2s que sincroniza un anillo de carga con el estado del sistema.

🛠 Especificaciones Técnicas
El Motor de Malla (Mesh Engine)
El corazón del proyecto es un MeshGradient dinámico. A diferencia de un degradado estándar, aquí controlamos puntos individuales de una matriz:

Swift

// Lógica de distorsión orgánica
0.5 + sinInRange(isSurging ? -0.4...0.4 : -0.05...0.05, t: t, c: 0.2)
Feedback Aeroespacial
La interfaz utiliza principios de anticipación. Al pulsar "EJECUTAR", el sistema no navega inmediatamente; primero "carga" energía. Esto se logra mediante:

Aceleración de Tiempo: Incremento de la variable t en el motor de renderizado.

Sincronización de UI: Un Circle().trim() que se completa exactamente en el tiempo que tarda el DispatchQueue en disparar la navegación.

📱 Requisitos
iOS 18.0+ (Requerido para MeshGradient)

Xcode 16.0+

Swift 6.0

🚀 Instalación
Clona este repositorio.

Abre el proyecto en Xcode.

Selecciona un simulador con iOS 18 (preferiblemente iPhone 15 Pro o superior para ver los efectos OLED).

¡Haz el "Build & Run"!

🧪 Hacks de Código Incluidos
TextEditor Transparente: Uso de .scrollContentBackground(.hidden) para eliminar el fondo nativo y permitir el efecto cristalino.

Symbol Effects: Implementación de .symbolEffect(.bounce) para dar vida a los iconos de SF Symbols de forma nativa.

Sinusoidal Movement: Función sinInRange para evitar movimientos lineales y lograr una estética de fluido o "Lava Lamp".

Nota para LinkedIn: Este proyecto fue diseñado para demostrar cómo la ingeniería de software y el diseño de interacción pueden converger para crear experiencias de usuario de alta fidelidad.
