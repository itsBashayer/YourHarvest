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
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
