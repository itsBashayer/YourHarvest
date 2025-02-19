//
//  CloudKitUBC.swift
//  Hassadak
//
//  Created by BASHAER AZIZ on 20/08/1446 AH.
//
import SwiftUI
import CloudKit


class CloudKitBCViewM: ObservableObject {
    @Published var isSignedInToiCloud: Bool = false
    @Published var error: String = ""
    
    init() {
        getiCloudStatus()
    }
    //CKC is cloud kit container , the user need to sign in to his icloud acc in his devaice
    private func getiCloudStatus() {
        CKContainer.default().accountStatus { [weak self] returnedStatus, reuturendError in
            DispatchQueue.main.async {
                switch returnedStatus{
                case .available:
                    self?.isSignedInToiCloud=true
                case .noAccount:
                    self?.error = CloudkitError.iCloudAccountNotFound.rawValue
                case .couldNotDetermine:
                    self?.error = CloudkitError.iCloudAccountNotDetermined.rawValue
                case .restricted:
                    self?.error = CloudkitError.iCloudAccountRestriced.rawValue
                default:
                    self?.error = CloudkitError.iCloudAccountUnknown.rawValue
                    
                }
            }
        }
    }

                
enum CloudkitError: String, LocalizedError{
                    
    case iCloudAccountNotFound
    case iCloudAccountNotDetermined
    case iCloudAccountRestriced
    case iCloudAccountUnknown
                }
            
    }

struct CloudKitUBC: View {
    @StateObject private var vm = CloudKitBCViewM()
    var body: some View {
        VStack{
        Text("Is SIGNED IN: \(vm.isSignedInToiCloud.description.uppercased())")
             Text(vm.error)
    }
}
             }

#Preview {
    CloudKitUBC()
}
