import SwiftUI

struct Splashscreen: View {
    @State private var linerOffset: CGFloat = -40 // Start position
    @State private var isActive = false // Track navigation

    var body: some View {
        NavigationStack {
            ZStack {
                Color("green")
                                   .edgesIgnoringSafeArea(.all)
                VStack {
                    Image("Logo3")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .scaledToFit()
                    
                    Image("line")
                        .resizable()
                        .padding(.leading, 2)
                        .padding(.top, -160)
                        .frame(width: 260, height: 20)
                        .offset(y: linerOffset)
                        .onAppear {
                            startAnimation()
                        }
                }
                .padding(.bottom)
            }
            .onAppear {
                navigateToOnboarding()
            }
            .navigationDestination(isPresented: $isActive) {
                OnboardingView()  
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    private func startAnimation() {
        withAnimation(Animation.linear(duration: 0.5)) {
            linerOffset = 100
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(Animation.linear(duration: 0.6)) {
                linerOffset = -40
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(Animation.linear(duration: 0.4)) {
                linerOffset = 39 // Stop in the middle
            }
        }
    }

    private func navigateToOnboarding() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Delay before transitioning
            isActive = true
        }
    }
}


#Preview {
    Splashscreen()
}
