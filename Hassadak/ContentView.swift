//
//  ContentView.swift
//  Hassadak
//
//  Created by BASHAER AZIZ on 20/08/1446 AH.
//
import SwiftUI
import CloudKit

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLogin: Bool = true
    @State private var errorMessage: String?
    @State private var successMessage: String?

    let cloudKitHelper = CloudKitHelper.shared

    var body: some View {
        VStack {
            Text(isLogin ? "Login" : "Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if !isLogin {
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }

            if let success = successMessage {
                Text(success)
                    .foregroundColor(.green)
                    .padding()
            }

            Button(action: handleAuth) {
                Text(isLogin ? "Login" : "Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }

            Button(action: { isLogin.toggle() }) {
                Text(isLogin ? "Need an account? Sign Up" : "Already have an account? Login")
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .padding()
    }

    private func handleAuth() {
              errorMessage = nil
              successMessage = nil

              if email.isEmpty || password.isEmpty {
                  errorMessage = "Please fill in all fields."
                  return
              }

              if !isValidEmail(email) {
                  errorMessage = "Please enter a valid email address."
                  return
              }

              if !isValidPassword(password) {
                  errorMessage = "Password must be at least 8 characters long, contain an uppercase letter, a lowercase letter, a number, and a special character."
                  return
              }

              if !isLogin && password != confirmPassword {
                  errorMessage = "Passwords do not match."
                  return
              }
           if isLogin {
                    cloudKitHelper.login(email: email, password: password) { success, error in
                        DispatchQueue.main.async {
                            if success {
                                successMessage = "Login Successful!"
                            } else {
                                errorMessage = error ?? "Login failed"
                            }
                        }
                    }
                } else {
                    cloudKitHelper.signUp(email: email, password: password) { success, error in
                        DispatchQueue.main.async {
                            if success {
                                successMessage = "Signup Successful!"
                            } else {
                                errorMessage = error ?? "Signup failed"
                            }
                        }
                    }
                }
            }

            private func isValidEmail(_ email: String) -> Bool {
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}" // Simple regex for email validation
                return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
            }

            private func isValidPassword(_ password: String) -> Bool {
                let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
                return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
            }
        }



struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
