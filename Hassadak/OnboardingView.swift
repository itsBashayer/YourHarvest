import SwiftUI

struct OnboardingView: View {
    @State private var selection = 0
    @State private var isActive = false
    @State private var userName: String = ""
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some View {
        if hasSeenOnboarding {
            ContentView(userName: $userName)
                .navigationBarBackButtonHidden(true)
        } else {
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    TabView(selection: $selection) {
                        ForEach(0..<3, id: \.self) { index in
                            OnboardingScreen(
                                imageName: "onboarding\(index + 1)",
                                description: index == 2 ? NSLocalizedString("Please add your name", comment: "") : "",
                                selection: $selection,
                                isActive: $isActive,
                                userName: $userName
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .ignoresSafeArea()
                }
                .navigationDestination(isPresented: $isActive) {
                    ContentView(userName: $userName)
                        .navigationBarBackButtonHidden(true)
                        .onAppear {
                            hasSeenOnboarding = true
                        }
                }
            }
        }
    }
}

struct OnboardingScreen: View {
    var imageName: String
    var description: String
    @Binding var selection: Int
    @Binding var isActive: Bool
    @Binding var userName: String

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text(description)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                
                if imageName == "onboarding3" {
                    TextField(NSLocalizedString("Enter your name", comment: ""), text: $userName)
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .frame(height: 40)
                        .frame(width: 294)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .padding(.bottom, 170)
                        .autocapitalization(.words)
                        .disableAutocorrection(false)
                        .padding(.horizontal)
                    
                    Button(action: {
                        if !userName.isEmpty {
                            isActive = true
                        }
                    }) {
                        Text("Start")
                            .fontWeight(.bold)
                            .foregroundColor(Color("green"))
                            .frame(width: 260, height: 46)
                            .background(userName.isEmpty ? Color.white : Color.white)
                            .cornerRadius(12)
                            .padding(60)
                    }
                    .disabled(userName.isEmpty)
                } else {
                    Spacer()
                }
            }
        }
        .background(Color.clear)
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingView()
}
