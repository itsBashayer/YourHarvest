//
//  CloudKitHelper.swift
//  Hassadak
//
//  Created by BASHAER AZIZ on 20/08/1446 AH.
//
import CloudKit

class CloudKitHelper {
    static let shared = CloudKitHelper()
    let database = CKContainer.default().privateCloudDatabase  // Using private database

    // Sign Up Function
    func signUp(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        let predicate = NSPredicate(format: "email == %@", email)
        let query = CKQuery(recordType: "User", predicate: predicate)

        database.perform(query, inZoneWith: nil) { results, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }
                
                if results?.isEmpty == false {
                    completion(false, "Email already exists.")
                    return
                }

                // Create a new user record
                let record = CKRecord(recordType: "User")
                record["email"] = email
                record["password"] = password // Always hash passwords in real apps
                record["createdAt"] = Date()

                self.database.save(record) { _, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(false, error.localizedDescription)
                        } else {
                            completion(true, nil)
                        }
                    }
                }
            }
        }
    }

    // Login Function
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        let predicate = NSPredicate(format: "email == %@", email)
        let query = CKQuery(recordType: "User", predicate: predicate)

        database.perform(query, inZoneWith: nil) { results, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }
                
                guard let record = results?.first,
                      let storedPassword = record["password"] as? String else {
                    completion(false, "User not found.")
                    return
                }

                if storedPassword == password { // Always hash and compare passwords in real apps
                    completion(true, nil)
                } else {
                    completion(false, "Incorrect password.")
                }
            }
        }
    }
}
