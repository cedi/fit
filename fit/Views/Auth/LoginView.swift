//
//  Login.swift
//  fit
//
//  Created by Cedric Kienzler on 04.02.25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: FocusedField?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            AppIconView()

            Text("BirkenFit")
                .font(.custom("Outfit", size: 32))
                .fontWeight(.bold)
                .foregroundColor(Color("AppIconColor"))

            Spacer()

            // Input Fields
            VStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enter your email")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fontWeight(.medium)

                    TextField("E-Mail", text: $viewModel.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .focused($focusedField, equals: .email)
                        .disableAutocorrection(true)
                        .submitLabel(.next)
                        .foregroundColor(.primary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray5).opacity(0.3))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    viewModel.emailError.isEmpty
                                        ? Color("AppIconColor") : Color.red,
                                    lineWidth: viewModel.email.isEmpty ? 0 : 1)  // Show a green border when active
                        )
                        .onSubmit {
                            focusedField = .password
                        }

                    if !viewModel.emailError.isEmpty {
                        Text(viewModel.emailError)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enter your password")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fontWeight(.medium)

                    SecureField("Password", text: $viewModel.password)
                        .autocapitalization(.none)
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                        .disableAutocorrection(true)
                        .submitLabel(.go)
                        .foregroundColor(.primary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray5).opacity(0.3))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    viewModel.passwordError.isEmpty
                                        ? Color("AppIconColor") : Color.red,
                                    lineWidth: viewModel.password.isEmpty
                                        ? 0 : 1)  // Show a green border when active
                        )
                        .onSubmit {
                            viewModel.login()
                        }

                    if !viewModel.passwordError.isEmpty {
                        Text(viewModel.passwordError)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }

            Spacer()

            // Sign-In Button
            Button(action: {
                viewModel.login()
            }) {
                Text("Log In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AppIconColor"))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            // Already have an account?
            HStack {
                Text("Don't have an account yet?")
                NavigationLink(destination: SignUpView()) {
                    Text("Sign up")
                        .foregroundColor(Color("AppIconColor"))
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        LoginView()
    }
}
