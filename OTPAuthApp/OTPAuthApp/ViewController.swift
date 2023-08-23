//
//  ViewController.swift
//  OTPAuthApp
//
//  Created by MacMiniA1993 on 23/08/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet var continueButton: UIButton!
    

        override func viewDidLoad() {
            super.viewDidLoad()
            
            continueButton.layer.cornerRadius = 30
        }

        @IBAction func continueButtonTapped(_ sender: UIButton) {
            guard let countryCode = countryCodeTextField.text,
                  let phoneNumber = phoneNumberTextField.text else {
                return
            }

            makePhoneNumberAPICall(number: countryCode + phoneNumber) { success in
                if success {

                }
            }
        }

        // Function to make Phone number API call
    func makePhoneNumberAPICall(number: String, completion: @escaping (Bool) -> Void) {
        let baseURL = "https://app.aisle.co/V1"
        let phoneNumberAPIEndpoint = "/users/phone_number_login"

        guard let url = URL(string: baseURL + phoneNumberAPIEndpoint) else {

            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = ["number": number]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData

            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    completion(false)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // API call was successful
                    print("Success")
                    completion(true)
                } else {
                    // API call was not successful
                    print("Failure")
                    completion(false)
                }
            }

            task.resume()
        } catch {
            print("Error: \(error)")
            completion(false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toScreen2" {
            if let destinationVC = segue.destination as? Screen2ViewController {
                destinationVC.countryCode = countryCodeTextField.text // Pass countryCode
                destinationVC.phoneNumber = phoneNumberTextField.text // Pass phoneNumber
            }
        }
    }
       
}

