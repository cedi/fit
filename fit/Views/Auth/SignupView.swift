//
//  Signup.swift
//  fit
//
//  Created by Cedric Kienzler on 04.02.25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
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
            VStack(alignment: .leading, spacing: 15) {
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
                            focusedField = .firstname
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
                                        ? Color("AppIconColor") : Color.red,
                                    lineWidth: viewModel.password.isEmpty
                                        ? 0 : 1)  // Show a green border when active
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

            Spacer()

            HStack {
                Divider()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .background(Color.gray.opacity(0.5))

                Text("or")
                    .font(.footnote)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.horizontal, 8)

                Divider()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .background(Color.gray.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)

            Button(action: {}) {
                HStack {
                    Image(systemName: "apple.logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.primary)

                    Text("Sign up with Apple")
                        .font(.headline)
                        .foregroundColor(Color.primary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .systemGray5))  // Adapts to light/dark mode
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .shadow(radius: 2)
            .padding(.horizontal, 20)

            Spacer()

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
                        viewModel.agreeToTerms ? Color("AppIconColor") : .gray
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

            // Sign-Up Button
            Button(action: {
                viewModel.signup()
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AppIconColor"))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            if !viewModel.signupError.isEmpty {
                Text(viewModel.signupError)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            // Already have an account?
            HStack {
                Text("Already have an account?")
                Button(action: {
                    dismiss()
                }) {
                    Text("Log in")
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
        SignUpView()
    }
}
