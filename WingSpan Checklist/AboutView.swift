// AboutView.swift
// Section 1: Main View
// Defines the AboutView struct, which displays the app's about page with a sunset background and app information.
import SwiftUI
import Foundation

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Replace the animated sky background with our new sunset background
            SunsetSkyBackground()

            VStack(spacing: 0) { // Use VStack to separate content and button
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

                        // About Info Box
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
                        .padding(.bottom, 20) // Added padding to ensure space before the button
                    }
                }

                // Continue Button, outside the ScrollView to pin it to the bottom
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
                                .fill(Color(hex: "3259a8"))
                        )
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 40)
            }
        }
    }
}

// AboutView.swift
// Section 2: Supporting Views
// Contains the SunsetSkyBackground struct, which creates an animated background with a gradient sky, sun/moon, stars, mountains, and moving airplanes.
private struct SunsetSkyBackground: View {
    @State private var plane1X: CGFloat = -100
    @State private var plane2X: CGFloat = UIScreen.main.bounds.width + 50
    @State private var plane3X: CGFloat = -200
    @State private var colorPhase: Double = 0.0
    
    // Colors for our sunset/sunrise transitions
    private let skyColors: [[Color]] = [
        // Sunset colors
        [Color(hex: "FF9E7A"), Color(hex: "FF5252"), Color(hex: "6E2D50"), Color(hex: "341D46")],
        // Dusk/evening colors
        [Color(hex: "F9A1BC"), Color(hex: "A277FF"), Color(hex: "5151E5"), Color(hex: "151965")],
        // Night colors with stars
        [Color(hex: "0F1A31"), Color(hex: "121A40"), Color(hex: "1A1B4B"), Color(hex: "0A0A1A")],
        // Dawn colors
        [Color(hex: "FFD4B2"), Color(hex: "FFA26B"), Color(hex: "577BC1"), Color(hex: "24407A")]
    ]
    
    private var currentGradient: [Color] {
        // Calculate which two gradients to blend between
        let segment = floor(colorPhase)
        let blendFactor = colorPhase - segment
        
        let index1 = Int(segment) % skyColors.count
        let index2 = (Int(segment) + 1) % skyColors.count
        
        // Blend between the two gradients
        return zip(skyColors[index1], skyColors[index2]).map { color1, color2 in
            blend(color1, color2, percentage: blendFactor)
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Dynamic sky gradient
                LinearGradient(
                    gradient: Gradient(colors: currentGradient),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Sun/Moon (depending on time of day)
                Circle()
                    .fill(colorPhase < 1.5 || colorPhase > 3.5
                          ? RadialGradient(gradient: Gradient(colors: [Color.white, Color.yellow.opacity(0.8), .clear]),
                                         center: .center,
                                         startRadius: 0,
                                         endRadius: 100)
                          : RadialGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.4), .clear]),
                                         center: .center,
                                         startRadius: 0,
                                         endRadius: 60))
                    .frame(width: colorPhase < 1.5 || colorPhase > 3.5 ? 160 : 100,
                           height: colorPhase < 1.5 || colorPhase > 3.5 ? 160 : 100)
                    .offset(x: -geo.size.width/4,
                            y: colorPhase < 1.5 || colorPhase > 3.5 ? 100 : -100)
                
                // Stars (only visible at night)
                ForEach(0..<30) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height/2)
                        )
                        .opacity(colorPhase > 1.5 && colorPhase < 3.5 ? min(1, (colorPhase - 1.5) * 2) : 0)
                        .blur(radius: 0.2)
                }
                
                // Mountains silhouette
                Path { path in
                    // Start at the bottom left
                    path.move(to: CGPoint(x: 0, y: geo.size.height))
                    
                    // First mountain
                    path.addLine(to: CGPoint(x: geo.size.width * 0.2, y: geo.size.height * 0.75))
                    path.addLine(to: CGPoint(x: geo.size.width * 0.4, y: geo.size.height))
                    
                    // Second mountain
                    path.addLine(to: CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.7))
                    path.addLine(to: CGPoint(x: geo.size.width * 0.7, y: geo.size.height))
                    
                    // Third mountain
                    path.addLine(to: CGPoint(x: geo.size.width * 0.9, y: geo.size.height * 0.8))
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    
                    // Close the path
                    path.closeSubpath()
                }
                .fill(Color.black.opacity(0.7))
                .offset(y: 100)
                
                // Silhouetted aircraft 1
                Image(systemName: "airplane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.black)
                    .shadow(color: .black, radius: 2)
                    .rotationEffect(.degrees(-10))
                    .offset(x: plane1X,
                            y: geo.size.height * 0.3)
                    .onAppear {
                        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                            plane1X = geo.size.width + 100
                        }
                    }
                
                // Silhouetted aircraft 2 (going the other direction)
                Image(systemName: "airplane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
                    .shadow(color: .black, radius: 2)
                    .rotationEffect(.degrees(170))
                    .offset(x: plane2X,
                            y: geo.size.height * 0.2)
                    .onAppear {
                        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                            plane2X = -50
                        }
                    }
                
                // Silhouetted aircraft 3
                Image(systemName: "airplane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
                    .shadow(color: .black, radius: 2)
                    .rotationEffect(.degrees(-5))
                    .offset(x: plane3X,
                            y: geo.size.height * 0.15)
                    .onAppear {
                        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                            plane3X = geo.size.width + 200
                        }
                    }
            }
            .onAppear {
                // Start animation cycle for time of day
                withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: false)) {
                    colorPhase = 4.0  // Complete cycle
                }
            }
        }
    }
}

// AboutView.swift
// Section 3: Helper Functions
// Includes the blend function and related logic for interpolating colors in the SunsetSkyBackground gradient.
private func blend(_ color1: Color, _ color2: Color, percentage: Double) -> Color {
    // Convert Color to RGBA
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
