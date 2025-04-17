import SwiftUI
import Foundation

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var debugPhase: Double = 0.0

    var body: some View {
        ZStack {
            SunsetSkyBackground(debugPhase: $debugPhase)

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

private struct SunsetSkyBackground: View {
    @State private var plane1X: CGFloat = -100
    @State private var plane2X: CGFloat = UIScreen.main.bounds.width + 50
    @State private var plane3X: CGFloat = -200
    @Binding var debugPhase: Double
    @State private var colorPhase: Double = 0.0
    
    // Store static star positions
    private let stars: [(x: CGFloat, y: CGFloat, size: CGFloat)] = (0..<10).map { _ in
        (x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
         y: CGFloat.random(in: 0...UIScreen.main.bounds.height), // Extend to full height
         size: CGFloat.random(in: 2...6))
    }
    
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
                LinearGradient(
                    gradient: Gradient(colors: currentGradient),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Circle()
                    .fill(colorPhase < 2.0
                          ? RadialGradient(gradient: Gradient(colors: [Color.white, Color.yellow.opacity(0.8), .clear]),
                                         center: .center,
                                         startRadius: 0,
                                         endRadius: 100)
                          : RadialGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.4), .clear]),
                                         center: .center,
                                         startRadius: 0,
                                         endRadius: 60))
                    .frame(width: colorPhase < 2.0 ? 160 : 100,
                           height: colorPhase < 2.0 ? 160 : 100)
                    .offset(x: -geo.size.width/4,
                            y: colorPhase < 2.0 ? 100 : -100)
                
                ForEach(stars.indices, id: \.self) { index in
                    let star = stars[index]
                    Circle()
                        .fill(Color.white)
                        .frame(width: star.size)
                        .position(x: star.x, y: star.y)
                        .opacity(0.8)
                        .blur(radius: 0.2)
                }
                
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
                
                Image(systemName: "airplane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.black)
                    .shadow(color: .black, radius: 2)
                    .rotationEffect(.degrees(-10))
                    .offset(x: plane1X, y: geo.size.height * 0.3)
                    .onAppear {
                        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                            plane1X = geo.size.width + 100
                        }
                    }
                
                Image(systemName: "airplane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
                    .shadow(color: .black, radius: 2)
                    .rotationEffect(.degrees(170))
                    .offset(x: plane2X, y: geo.size.height * 0.2)
                    .onAppear {
                        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                            plane2X = -50
                        }
                    }
                
                Image(systemName: "airplane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
                    .shadow(color: .black, radius: 2)
                    .rotationEffect(.degrees(-5))
                    .offset(x: plane3X, y: geo.size.height * 0.15)
                    .onAppear {
                        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                            plane3X = geo.size.width + 200
                        }
                    }
            }
            .onAppear {
                let calendar = Calendar.current
                let now = Date()
                let hour = Double(calendar.component(.hour, from: now))
                let minute = Double(calendar.component(.minute, from: now))
                let totalHours = hour + (minute / 60.0)
                let normalizedHours = (totalHours - 6).truncatingRemainder(dividingBy: 24)
                colorPhase = (normalizedHours / 12.0) * 2.0
                print("Time: \(totalHours), Normalized: \(normalizedHours), ColorPhase: \(colorPhase)")
                debugPhase = colorPhase
            }
            .onChange(of: debugPhase) { _, newValue in
                colorPhase = newValue
            }
        }
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
