// AboutView.swift
import SwiftUI
import Foundation

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var debugPhase: Double = 0.0

    var body: some View {
        ZStack {
            EnhancedSkyBackground(debugPhase: $debugPhase)

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 8) {
                            Text("Welcome to")
                                .font(.system(size: 36, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 2)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)

                            Text("WingSpan Checklists")
                                .font(.system(size: 48, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 2)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 25)
                        .frame(minHeight: 150)

                        VStack(alignment: .leading, spacing: 20) {
                            Text("About the app")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.bottom, 5)

                            HStack(spacing: 15) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.9))
                                    .frame(width: 25)

                                Text("Version 1.2.0")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.9))
                            }

                            HStack(spacing: 15) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.9))
                                    .frame(width: 25)

                                Text("Developed by: Michael Surtees ©")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.9))
                            }

                            HStack(alignment: .top, spacing: 15) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.9))
                                    .frame(width: 25)
                                    .padding(.top, 3)

                                Text("Digital checklists for simulation or fun. Not for real world use.")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.9))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(25)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.7))
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(hex: "1c2e54").opacity(0.6))
                                        .blur(radius: 0.5)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    }
                }

                Button(action: {
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(hex: "FF6F61"))
                        )
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 40)
            }
        }
    }
}

private struct EnhancedSkyBackground: View {
    @State private var plane1X: CGFloat = -100
    @State private var plane2X: CGFloat = UIScreen.main.bounds.width + 50
    @State private var plane3X: CGFloat = -200
    @Binding var debugPhase: Double
    @State private var colorPhase: Double = 0.0
    @State private var cloudOffsets: [CGFloat] = [0, 100, 200, 50, 150]
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @AppStorage("useSystemTime") private var useSystemTime = true
    @AppStorage("manualTimeOfDay") private var manualTimeOfDay: TimeOfDay = .day
    
    // Store static star positions
    private let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = (0..<25).map { _ in
        (x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
         y: CGFloat.random(in: 0...UIScreen.main.bounds.height),
         size: CGFloat.random(in: 1.5...6),
         opacity: Double.random(in: 0.5...1.0))
    }
    
    // Cloud shapes
    private let cloudShapes: [UIBezierPath] = [
        cloudPath1(),
        cloudPath2(),
        cloudPath3()
    ]
    
    private let skyColors: [[Color]] = [
        [Color(hex: "FF9E7A"), Color(hex: "FF5252"), Color(hex: "F06292"), Color(hex: "AD1457")],
        [Color(hex: "F9A1BC"), Color(hex: "F06292"), Color(hex: "AB47BC"), Color(hex: "6A1B9A")],
        [Color(hex: "4A148C"), Color(hex: "311B92"), Color(hex: "4527A0"), Color(hex: "1A237E")],
        [Color(hex: "FFD4B2"), Color(hex: "FFA26B"), Color(hex: "FF8A65"), Color(hex: "F06292")]
    ]
    
    private var currentGradient: [Color] {
        let segment = floor(colorPhase)
        let blendFactor = colorPhase - segment
        let index1 = Int(segment) % skyColors.count
        let index2 = (Int(segment) + 1) % skyColors.count
        return zip(skyColors[index1], skyColors[index2]).map { color1, color2 in
            blend(color1, color2, percentage: blendFactor)
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Sky gradient background
                LinearGradient(
                    gradient: Gradient(colors: currentGradient),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Sun or moon
                celestialBody(for: geo)
                
                // Stars (visible when darker)
                starsLayer(for: geo)
                
                // Clouds
                cloudsLayer(for: geo)
                
                // Mountain silhouette
                mountainLayer(for: geo)
                
                // Airplanes
                airplanesLayer(for: geo)
            }
            .onAppear {
                initializeTimeBasedAppearance()
                startCloudAnimation()
            }
            .onChange(of: debugPhase) { _, newValue in
                colorPhase = newValue
            }
        }
    }
    
    // MARK: - Layer Components
    
    private func celestialBody(for geo: GeometryProxy) -> some View {
        Group {
            if colorPhase < 2.0 {
                // Sun
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.yellow.opacity(0.8),
                            Color.orange.opacity(0.6),
                            .clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    ))
                    .frame(width: 160, height: 160)
                    .offset(x: -geo.size.width/4, y: 100)
                    .blur(radius: 1)
                    .overlay(
                        // Sun rays
                        sunRays()
                            .offset(x: -geo.size.width/4, y: 100)
                            .opacity(0.7)
                    )
            } else {
                // Moon
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.6),
                            .clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    ))
                    .frame(width: 100, height: 100)
                    .offset(x: -geo.size.width/3, y: -100)
                    .overlay(
                        // Moon craters
                        moonCraters()
                            .offset(x: -geo.size.width/3, y: -100)
                            .opacity(0.15)
                    )
            }
        }
    }
    
    private func starsLayer(for geo: GeometryProxy) -> some View {
        ForEach(stars.indices, id: \.self) { index in
            let star = stars[index]
            Circle()
                .fill(Color.white)
                .frame(width: star.size)
                .position(x: star.x, y: star.y)
                .opacity(colorPhase >= 1.5 ? star.opacity : 0)
                .blur(radius: 0.2)
                .animation(.easeInOut(duration: 2), value: colorPhase)
                .blendMode(.screen)
        }
    }
    
    private func cloudsLayer(for geo: GeometryProxy) -> some View {
        Group {
            // Morning/evening clouds
            ForEach(0..<3) { index in
                if colorPhase < 2.0 && colorPhase > 0.5 {
                    cloudShape(index: index % cloudShapes.count)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.7)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 150, height: 80)
                        .position(
                            x: (cloudOffsets[index].truncatingRemainder(dividingBy: geo.size.width)),
                            y: CGFloat(100 + (40 * index))
                        )
                        .opacity(colorPhase < 2.0 ? min(1.0, max(0.0, 1.0 - abs(colorPhase - 1.0))) : 0)
                }
                
                // Night clouds (dark and subtle)
                if colorPhase >= 1.5 {
                    cloudShape(index: (index + 1) % cloudShapes.count)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "1A237E").opacity(0.4),
                                    Color(hex: "0D47A1").opacity(0.2)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 180, height: 90)
                        .position(
                            x: (cloudOffsets[index + 2].truncatingRemainder(dividingBy: geo.size.width)),
                            y: CGFloat(150 + (50 * index))
                        )
                        .opacity(min(0.7, max(0.0, colorPhase - 1.5)))
                }
            }
        }
    }
    
    private func mountainLayer(for geo: GeometryProxy) -> some View {
        ZStack {
            // Far mountains (blue tint)
            Path { path in
                path.move(to: CGPoint(x: 0, y: geo.size.height))
                path.addLine(to: CGPoint(x: geo.size.width * 0.2, y: geo.size.height * 0.8))
                path.addLine(to: CGPoint(x: geo.size.width * 0.35, y: geo.size.height * 0.85))
                path.addLine(to: CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.75))
                path.addLine(to: CGPoint(x: geo.size.width * 0.7, y: geo.size.height * 0.82))
                path.addLine(to: CGPoint(x: geo.size.width * 0.85, y: geo.size.height * 0.78))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.85))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [
                        colorPhase < 2.0 ? Color(hex: "3949AB").opacity(0.8) : Color(hex: "1A237E").opacity(0.7),
                        colorPhase < 2.0 ? Color(hex: "303F9F").opacity(0.7) : Color(hex: "0D47A1").opacity(0.6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .offset(y: 30)
            
            // Near mountains (darker)
            Path { path in
                path.move(to: CGPoint(x: 0, y: geo.size.height))
                path.addLine(to: CGPoint(x: geo.size.width * 0.2, y: geo.size.height * 0.75))
                path.addLine(to: CGPoint(x: geo.size.width * 0.4, y: geo.size.height))
                path.addLine(to: CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.7))
                path.addLine(to: CGPoint(x: geo.size.width * 0.7, y: geo.size.height))
                path.addLine(to: CGPoint(x: geo.size.width * 0.9, y: geo.size.height * 0.8))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                path.closeSubpath()
            }
            .fill(Color.black.opacity(0.7))
            .offset(y: 100)
        }
    }
    
    private func airplanesLayer(for geo: GeometryProxy) -> some View {
        Group {
            // Large airplane
            Image(systemName: "airplane")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(colorPhase < 2.0 ? .black : .white.opacity(0.7))
                .shadow(color: .black, radius: 2)
                .rotationEffect(.degrees(-10))
                .offset(x: plane1X, y: geo.size.height * 0.3)
                .onAppear {
                    if animationsEnabled {
                        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                            plane1X = geo.size.width + 100
                        }
                    }
                }
            
            // Medium airplane
            Image(systemName: "airplane")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(colorPhase < 2.0 ? .black : .white.opacity(0.7))
                .shadow(color: .black, radius: 2)
                .rotationEffect(.degrees(170))
                .offset(x: plane2X, y: geo.size.height * 0.2)
                .onAppear {
                    if animationsEnabled {
                        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                            plane2X = -50
                        }
                    }
                }
            
            // Small airplane with contrail
            ZStack {
                // Contrail
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: -60, y: 0))
                }
                .stroke(style: StrokeStyle(
                    lineWidth: 2,
                    lineCap: .round,
                    lineJoin: .round,
                    dash: [4, 6]
                ))
                .foregroundColor(.white.opacity(0.7))
                
                // Airplane
                Image(systemName: "airplane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .foregroundColor(colorPhase < 2.0 ? .black : .white.opacity(0.7))
            .shadow(color: .black, radius: 1)
            .rotationEffect(.degrees(-5))
            .offset(x: plane3X, y: geo.size.height * 0.15)
            .onAppear {
                if animationsEnabled {
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                        plane3X = geo.size.width + 200
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Components
    
    private func sunRays() -> some View {
        ZStack {
            ForEach(0..<8) { i in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.7), Color.yellow.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 160, height: 3)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
        }
        .frame(width: 200, height: 200)
    }
    
    private func moonCraters() -> some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 15, height: 15)
                .offset(x: 15, y: -10)
            
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 20, height: 20)
                .offset(x: -20, y: 15)
            
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 10, height: 10)
                .offset(x: 5, y: 25)
        }
        .frame(width: 100, height: 100)
    }
    
    private func cloudShape(index: Int) -> Path {
        Path { path in
            if let cgPath = cloudShapes[index].cgPath.copy() {
                path.addPath(Path(cgPath))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func initializeTimeBasedAppearance() {
        if useSystemTime {
            let calendar = Calendar.current
            let now = Date()
            let hour = Double(calendar.component(.hour, from: now))
            let minute = Double(calendar.component(.minute, from: now))
            let totalHours = hour + (minute / 60.0)
            let normalizedHours = (totalHours - 6).truncatingRemainder(dividingBy: 24)
            colorPhase = (normalizedHours / 12.0) * 2.0
        } else {
            colorPhase = manualTimeOfDay.colorPhase
        }
        
        debugPhase = colorPhase
    }
    
    private func startCloudAnimation() {
        if animationsEnabled {
            withAnimation(.linear(duration: 120).repeatForever(autoreverses: false)) {
                for i in 0..<cloudOffsets.count {
                    cloudOffsets[i] += UIScreen.main.bounds.width + 200
                }
            }
        }
    }
    
    // MARK: - Static Helper Functions
    
    // Generate cloud paths
    private static func cloudPath1() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 50))
        path.addCurve(to: CGPoint(x: 40, y: 30), controlPoint1: CGPoint(x: 10, y: 30), controlPoint2: CGPoint(x: 25, y: 20))
        path.addCurve(to: CGPoint(x: 80, y: 20), controlPoint1: CGPoint(x: 55, y: 10), controlPoint2: CGPoint(x: 65, y: 5))
        path.addCurve(to: CGPoint(x: 120, y: 40), controlPoint1: CGPoint(x: 95, y: 10), controlPoint2: CGPoint(x: 110, y: 20))
        path.addCurve(to: CGPoint(x: 150, y: 50), controlPoint1: CGPoint(x: 135, y: 35), controlPoint2: CGPoint(x: 145, y: 45))
        path.addCurve(to: CGPoint(x: 0, y: 50), controlPoint1: CGPoint(x: 120, y: 80), controlPoint2: CGPoint(x: 30, y: 80))
        path.close()
        return path
    }
    
    private static func cloudPath2() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 40))
        path.addCurve(to: CGPoint(x: 30, y: 20), controlPoint1: CGPoint(x: 5, y: 25), controlPoint2: CGPoint(x: 15, y: 15))
        path.addCurve(to: CGPoint(x: 70, y: 15), controlPoint1: CGPoint(x: 45, y: 5), controlPoint2: CGPoint(x: 55, y: 0))
        path.addCurve(to: CGPoint(x: 100, y: 30), controlPoint1: CGPoint(x: 85, y: 5), controlPoint2: CGPoint(x: 95, y: 15))
        path.addCurve(to: CGPoint(x: 130, y: 40), controlPoint1: CGPoint(x: 110, y: 25), controlPoint2: CGPoint(x: 125, y: 35))
        path.addCurve(to: CGPoint(x: 0, y: 40), controlPoint1: CGPoint(x: 100, y: 70), controlPoint2: CGPoint(x: 30, y: 70))
        path.close()
        return path
    }
    
    private static func cloudPath3() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 10, y: 45))
        path.addCurve(to: CGPoint(x: 50, y: 25), controlPoint1: CGPoint(x: 20, y: 35), controlPoint2: CGPoint(x: 35, y: 25))
        path.addCurve(to: CGPoint(x: 90, y: 15), controlPoint1: CGPoint(x: 65, y: 15), controlPoint2: CGPoint(x: 75, y: 5))
        path.addCurve(to: CGPoint(x: 130, y: 35), controlPoint1: CGPoint(x: 105, y: 15), controlPoint2: CGPoint(x: 120, y: 25))
        path.addCurve(to: CGPoint(x: 160, y: 45), controlPoint1: CGPoint(x: 145, y: 30), controlPoint2: CGPoint(x: 155, y: 40))
        path.addCurve(to: CGPoint(x: 10, y: 45), controlPoint1: CGPoint(x: 120, y: 75), controlPoint2: CGPoint(x: 50, y: 75))
        path.close()
        return path
    }
}

private func blend(_ color1: Color, _ color2: Color, percentage: Double) -> Color {
    func toRGBA(_ color: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard let cgColor = color.cgColor else { return (0, 0, 0, 1) }
        guard let components = cgColor.components else { return (0, 0, 0, 1) }
        
        if components.count >= 3 {
            r = components[0]
            g = components[1]
            b = components[2]
            a = components.count >= 4 ? components[3] : 1
        }
        
        return (Double(r), Double(g), Double(b), Double(a))
    }
    
    let rgba1 = toRGBA(color1)
    let rgba2 = toRGBA(color2)
    
    let r = rgba1.r + (rgba2.r - rgba1.r) * percentage
    let g = rgba1.g + (rgba2.g - rgba1.g) * percentage
    let b = rgba1.b + (rgba2.b - rgba1.b) * percentage
    let a = rgba1.a + (rgba2.a - rgba1.a) * percentage
    
    return Color(.displayP3, red: r, green: g, blue: b, opacity: a)
}
