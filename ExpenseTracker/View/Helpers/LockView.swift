//
//  LockView.swift
//  ExpenseTrackerSwiftData
//
//  Created by Eren Aşkın on 15.12.2023.
//

import SwiftUI
import LocalAuthentication

// LocalAuthentication kullanılarak biyometrik kimlik doğrulama yapılıyor ve özel bir sayı kilidi (PIN) kullanıcıdan alınıyor. 

struct LockView <Content : View>: View {
    // Lock Properties
    var lockType: LockType
    var lockPin: String
    var isEnabled: Bool
    var lockWhenAppGoesBackground: Bool = true
    @ViewBuilder var content: Content
    var forgotPin: () -> () = { }
    // View Properties
    @State private var pin: String = ""
    @State private var animateField: Bool = false
    @State private var isUnlocked: Bool = false
    @State private var noBiometricAccess: Bool = false
    @Environment (\.scenePhase) private var phase
    var body: some View {
        GeometryReader{
            let size = $0.size
            
            content
                .frame(width: size.width, height: size.height)
            if isEnabled && !isUnlocked{
                ZStack{
                    Rectangle()
                        .fill(.black)
                        .ignoresSafeArea()
                    if (lockType == .both && !noBiometricAccess) || lockType == .biometric{
                        Group{
                            if noBiometricAccess{
                                Text("Enable biometric auth in Settings to unlock the view.")
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                                    .padding(50)
                            }else{
                                // Biometric/Pin Unlock
                                VStack(spacing: 12) {
                                    VStack(spacing: 6) {
                                        Image(systemName: "faceid")
                                            .font(.largeTitle)
                                        
                                        Text("Face ID")
                                            .font(.caption2)
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(.ultraThinMaterial,in:.rect(cornerRadius: 10))
                                    .contentShape(.rect)
                                    .onTapGesture {
                                        unlockView()
                                    }
                                    if lockType == .both{
                                        Text("Enter Pin")
                                            .frame(width: 100, height: 40)
                                            .background(.ultraThinMaterial,in:.rect(cornerRadius: 10))
                                            .contentShape(.rect)
                                            .onTapGesture {
                                                noBiometricAccess = true
                                        }
                                    }
                                }
                            }
                        }
                    }else{
                        // Custom number pad to type view lock pin
                        numberPadPinView()
                    }
                }
                .environment(\.colorScheme,.dark)
                .transition(.offset(y: size.height + 100))
            }
        }
        .onChange(of: isEnabled) { oldValue, newValue in
            if newValue{
                unlockView()
            }
        }
        // Locking When App Uses Background
        .onChange(of: phase) { oldValue, newValue in
            if newValue != .active && lockWhenAppGoesBackground{
                isUnlocked = false
                pin = ""
            }
            if newValue == .active && !isUnlocked && isEnabled{
                unlockView()
            }
        }
    }
    private func unlockView(){
        let context = LAContext()
        Task{
            if isBiometricAvailable && lockType != .number{
                if let result = try? await
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock The View"), result{
                    print("Unlocked")
                    withAnimation(.snappy, completionCriteria: .logicallyComplete) {
                        isUnlocked = true
                    } completion: {
                        pin = ""
                    }

                }
            }
            noBiometricAccess = !isBiometricAvailable
        }
    }
    private var isBiometricAvailable: Bool{
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
   }
 
    // NumberPad Pin View
    @ViewBuilder
    func numberPadPinView() -> some View{
        VStack(spacing:15){
            Text("Enter Pin")
                .font(.title.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    // Back button
                    if lockType == .both && isBiometricAvailable {
                        Button(action: {
                            noBiometricAccess = false
                            pin = ""
                        } ,label: {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .contentShape(.rect)
                                
                        })
                        .tint(.white)
                        .padding(.leading)
                    }
                }
            // Adding Wiggling Animation for Wrong Password With Keyframe Animator
            HStack(spacing:10){
                ForEach(0..<4,id: \.self){ index in
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 55)
                    // Showing Pin at each box with tht help of Index
                        .overlay {
                            // Safe Check
                            if pin.count > index{
                                let index = pin.index(pin.startIndex,offsetBy: index)
                                let string = String(pin[index])
                                
                                Text(string)
                                    .font(.title.bold())
                                    .foregroundStyle(.black)
                        }
                    }
                }
            }
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: animateField, content: { content, value in
                content
                    .offset(x: value)
            }, keyframes: { _ in
                KeyframeTrack{
                    CubicKeyframe(30, duration: 0.07)
                    CubicKeyframe(-30, duration: 0.07)
                    CubicKeyframe(20, duration: 0.07)
                    CubicKeyframe(-20, duration: 0.07)
                    CubicKeyframe(0, duration: 0.07)

                }
            })
                .padding(.top,15)
                .overlay(alignment: .bottomTrailing, content: {
                    Button("Forgot Pin?", action: forgotPin)
                        .foregroundStyle(.white)
                        .offset(y:40)
                })
            .frame(maxHeight: .infinity)
            // Custom Number Pad
            GeometryReader{ _ in
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3), content: {
                    ForEach(1...9,id: \.self){number in
                        Button(action: {
                            // Adding Number to Pin
                            // Max Limit - 4
                            if pin.count < 4{
                                pin.append("\(number)")
                            }
                        }, label: {
                            Text("\(number)")
                                .font(.title)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical,20)
                                .contentShape(.rect)
                        })
                        .tint(.white)
                    }
                    // 0 and Back Button
                    Button(action: {
                        if !pin.isEmpty{
                            pin.removeLast()
                        }
                    }, label: {
                        Image(systemName: "delete.backward")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical,20)
                            .contentShape(.rect)
                            .foregroundStyle(.white)
                    })
                    Button(action: {
                        if pin.count < 4{
                            pin.append("0")
                        }
                    }, label: {
                        Text("0")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical,20)
                            .contentShape(.rect)
                            .foregroundStyle(.white)
                    })
                })
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
            .onChange(of: pin) { oldValue, newValue in
                if newValue.count == 4{
                    // Validate Pin
                    if lockPin == pin{
                        //print("Unlocked")
                        withAnimation(.snappy,completionCriteria: .logicallyComplete) {
                            isUnlocked = true
                        } completion: {
                            pin = ""
                            noBiometricAccess = !isBiometricAvailable
                        }
                    }else{
                        //print("Wrong Pin")
                        pin = ""
                        animateField.toggle()
                    }
                }
            }
        }
        .padding()
        .environment(\.colorScheme, .dark)
        
    }
    
    // Lock Type
    enum LockType: String{
        case biometric = "Biometric Auth"
        case number = "Custom Number Lock"
        case both = "First preference will be biometric,and it's not available,it will go for number lock."
    }
}

#Preview {
    ContentView()
}
