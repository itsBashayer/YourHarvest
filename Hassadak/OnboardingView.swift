import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var selection = 0 // Track the current page
    @State private var isActive = false // Control navigation

    let onboardingData = [
        ("onboarding1", ""),
        ("onboarding2", ""),
        ("onboarding3", "Please add your name")
    ]

    var body: some View {
        NavigationStack {
            if hasSeenOnboarding {
                test() // ✅ If onboarding is completed, go to the main screen
                    .navigationBarBackButtonHidden(true)
            } else {
                TabView(selection: $selection) {
                    ForEach(0..<onboardingData.count, id: \.self) { index in
                        OnboardingScreen(
                            imageName: onboardingData[index].0,
                            description: onboardingData[index].1,
                            selection: $selection,
                            isActive: $isActive
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .ignoresSafeArea()
                .navigationDestination(isPresented: $isActive) {
                    test() // ✅ Navigate to main screen
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

struct OnboardingScreen: View {
    var imageName: String
    var description: String
    @Binding var selection: Int // Track onboarding page
    @Binding var isActive: Bool // Navigation control
    @State private var name: String = "" // Store user name input
    
    // Animation States (Only for onboarding1)
    @State private var showImage1 = false
    @State private var showImage2 = false
    @State private var showImage3 = false
    @State private var showImage4 = false

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            if imageName == "onboarding1" {
                // Image 1 - Appears first
                Image("1")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(.leading, -180)
                    .padding(.top, -180)
                    .scaleEffect(showImage1 ? 1 : 0)
                    .opacity(showImage1 ? 1 : 0)
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            showImage1 = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showImage2 = true
                        }
                    }

                // Image 2 - Appears after Image 1
                Image("2")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .offset(x: -55, y: -180)
                    .scaleEffect(showImage2 ? 1 : 0)
                    .opacity(showImage2 ? 1 : 0)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                showImage3 = true
                            }
                        }
                    }

                // Image 3 - Appears after Image 2
                Image("3")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .offset(x: 58, y: -155)
                    .scaleEffect(showImage3 ? 1 : 0)
                    .opacity(showImage3 ? 1 : 0)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                showImage4 = true
                            }
                        }
                    }

                // Image 4 - Appears last
                Image("4")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .offset(x: 175, y: -180)
                    .scaleEffect(showImage4 ? 1 : 0)
                    .opacity(showImage4 ? 1 : 0)
            }

            VStack {
                if imageName == "onboarding1" {
                    Text("Count")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 620)
                        .padding(.leading, 16)

                    Text("your crops accurately track inventory with AI.")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)

                    Spacer()
                }

                Spacer()

                Text(description)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()

                if imageName == "onboarding2" {
                    Text("Easily")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 420)
                        .padding(.leading, 16)

                    Text("keep track of your harvest throughout the month.")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 19.0)
                }

                if imageName == "onboarding3" {
                    TextField("Enter your name", text: $name)
                        .font(.system(size: 16))
                        .padding(10)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .frame(height: 40)
                        .frame(width: 294)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .padding(.bottom, 140)
                        .autocapitalization(.words)
                        .disableAutocorrection(false)
                        .padding(.horizontal)

                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding") // Save state
                        isActive = true // ✅ Navigate to main screen
                    }) {
                        Text("Start")
                            .fontWeight(.bold)
                            .foregroundColor(Color("green"))
                            .font(.body)
                            .frame(width: 260, height: 46)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(60)
                    }
                } else {
                    Spacer()
                }
            }
        }
        .background(Color.clear)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true) // Prevent back navigation
    }
}

#Preview {
    OnboardingView()
}
