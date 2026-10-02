import SwiftUI

struct LoginView: View {
    let onLogin: (UserRole) -> Void

    @State private var role: UserRole = .franchise
    @State private var showPassword = false
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.primary, Color(hex: "003D24")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 40)

                VStack(spacing: 16) {
                    Image("PumaLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 168, height: 30)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 16)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 6)
                    VStack(spacing: 2) {
                        Text("FuelControl")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Gestión de red de franquicias")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.bottom, 24)

                VStack(spacing: 8) {
                    Text("MODO DE ACCESO (PROTOTIPO)")
                        .font(.system(size: 11, weight: .medium))
                        .tracking(1.2)
                        .foregroundStyle(.white.opacity(0.5))

                    HStack(spacing: 8) {
                        roleButton(.franchise, label: "Gte. Franquicia")
                        roleButton(.general, label: "Gte. General")
                    }
                    .padding(4)
                    .background(.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                VStack(spacing: 12) {
                    TextField("", text: $email, prompt: Text("Correo electrónico").foregroundStyle(.black.opacity(0.3)))
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding(14)
                        .background(Theme.subtleFill)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    ZStack(alignment: .trailing) {
                        Group {
                            if showPassword {
                                TextField("", text: $password, prompt: Text("Contraseña").foregroundStyle(.black.opacity(0.3)))
                            } else {
                                SecureField("", text: $password, prompt: Text("Contraseña").foregroundStyle(.black.opacity(0.3)))
                            }
                        }
                        .padding(14)
                        .padding(.trailing, 40)
                        .background(Theme.subtleFill)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundStyle(Theme.label2)
                        }
                        .padding(.trailing, 12)
                    }

                    Button("Iniciar sesión") {
                        onLogin(role)
                    }
                    .buttonStyle(.iosPrimary)

                    Button("¿Olvidaste tu contraseña?") { onLogin(role) }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.primary)
                }
                .padding(20)
                .iosCard()
                .padding(.horizontal, 20)

                VStack(spacing: 8) {
                    Button {
                        onLogin(role)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.white.opacity(0.1))
                                .frame(width: 56, height: 56)
                            Image(systemName: "faceid")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                        }
                    }
                    Text("Iniciar con Face ID")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.top, 24)

                Spacer(minLength: 20)
            }
        }
    }

    private func roleButton(_ r: UserRole, label: String) -> some View {
        Button {
            role = r
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(role == r ? .white : .white.opacity(0.55))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(role == r ? .white.opacity(0.2) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

#Preview {
    LoginView(onLogin: { _ in })
}
