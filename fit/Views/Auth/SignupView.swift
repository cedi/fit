//
//  Signup.swift
//  fit
//
//  Created by Cedric Kienzler on 04.02.25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignupViewModel()
    @State var agreeToTerms: Bool = false

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
                                        ? Color.accentColor : Color.red,
                                    lineWidth: viewModel.email.isEmpty ? 0 : 2)  // Show a green border when active
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
                        .submitLabel(.next)
                        .foregroundColor(.primary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray5).opacity(0.3))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    viewModel.passwordError.isEmpty
                                        ? Color.accentColor : Color.red,
                                    lineWidth: viewModel.password.isEmpty
                                        ? 0 : 2)  // Show a green border when active
                        )
                        .onSubmit {
                            viewModel.signup()
                        }

                    if !viewModel.passwordError.isEmpty {
                        Text(viewModel.passwordError)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }

            // Terms and Conditions
            Button(action: {
                viewModel.agreeToTerms.toggle()
            }) {
                HStack {
                    Image(
                        systemName: viewModel.agreeToTerms
                            ? "checkmark.square.fill" : "square"
                    )
                    .foregroundColor(
                        viewModel.agreeToTerms ? Color.accentColor : .gray
                    )
                    .font(.system(size: 20))

                    Text("I agree to the Terms & Conditions")
                        .font(.footnote)
                        .foregroundColor(
                            viewModel.agreeToTermsError ? Color.red : .primary)
                }
                .font(.footnote)
            }
            .buttonStyle(.plain)  // Ensures it looks like a native checkbox
            .padding(.horizontal)

            Spacer()

            // Sign-Up Button
            Button(action: {
                viewModel.signup()
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            // Already have an account?
            HStack {
                Text("Already have an account?")
                NavigationLink(destination: LoginView()) {
                    Text("Log in")
                        .foregroundColor(Color.accentColor)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        SignUpView()
    }
}
