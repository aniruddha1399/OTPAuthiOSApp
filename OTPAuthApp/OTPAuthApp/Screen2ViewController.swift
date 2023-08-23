//
//  Screen2ViewController.swift
//  OTPAuthApp
//
//  Created by MacMiniA1993 on 23/08/23.
//

import UIKit

class Screen2ViewController: UIViewController {
    @IBOutlet weak var otpTextField: UITextField!

    @IBOutlet var countdownLabel: UILabel!
    var auth_token: String?
    var countryCode: String?
       var phoneNumber: String?
    var remainingTime = 60 // Initial remaining time in seconds
    var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCountdownLabel()
        startTimer()
    }
    func updateCountdownLabel() {
            countdownLabel.text = "\(remainingTime)s"
        }
    func startTimer() {
            // Invalidate the timer if it's already running
            timer?.invalidate()

            // Start a new timer that fires every second
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else { return }

                // Update the remaining time
                self.remainingTime -= 1

                // Update the label and check if the timer has completed
                self.updateCountdownLabel()
                if self.remainingTime == 0 {
                    self.timer?.invalidate() // Stop the timer

                }
            }
        }
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        guard let otp = otpTextField.text else {
            return
        }

        makeOTPAPIcall(number: countryCode! + phoneNumber!, otp: otp) { token in
            if let authToken = token {
                self.auth_token = authToken
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toScreen3", sender: self.auth_token)
                }
            }
        }
    }

    // Function to make OTP API call
    func makeOTPAPIcall(number: String, otp: String, completion: @escaping (String?) -> Void) {
        let baseURL = "https://app.aisle.co/V1"
        let otpAPIEndpoint = "/users/verify_otp"

        guard let url = URL(string: baseURL + otpAPIEndpoint) else {

            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = ["number": number, "otp": otp]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData

            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    completion(nil)
                    return
                }

                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        print("jsonResponse: \(jsonResponse)")
                        print("jsonResponse?auth_token \(jsonResponse?["token"])")
                        if let authToken = jsonResponse?["token"] as? String {
                            // API call was successful
                            print("jsonResponse: \(authToken) Success")

                            completion(authToken)
                        } else {
                            // API call was not successful
                            completion(nil)
                        }
                    } catch {
                        print("JSON Parsing Error: \(error)")
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }

            task.resume()
        } catch {
            print("JSON Serialization Error: \(error)")
            completion(nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "toScreen3" {
               if let destinationVC = segue.destination as? Screen3ViewController,
                  let authToken = sender as? String {
                   destinationVC.auth_token = authToken
                   print("destinationVC.auth_token >>>> \(destinationVC.auth_token)")
               }
           }
       }

}
