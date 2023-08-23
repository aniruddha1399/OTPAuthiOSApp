//
//  Screen3ViewController.swift
//  OTPAuthApp
//
//  Created by MacMiniA1993 on 23/08/23.
//

import UIKit

class Screen3ViewController: UIViewController {
    var auth_token: String = ""

    @IBOutlet var welcomeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        print("authToken \(auth_token)")
            makeNotesAPICall()

    }

    func makeNotesAPICall() {
        let baseURL = "https://app.aisle.co/V1"
        let notesAPIEndpoint = "/users/test_profile_list"

        guard let url = URL(string: baseURL + notesAPIEndpoint) else {

            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // auth token to the request header
        request.addValue("Bearer \(auth_token)", forHTTPHeaderField: "Authorization")
      
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                // error case
                print("Error")
                return
            }

            if let data = data {
                // response data
                print("Success case logged in : \(data)")
                do {
                                // Parse JSON data
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    // Update UI on the main thread
                            DispatchQueue.main.async {
                                    self.updateUI(with: jsonResponse)
                                    }
                                }
                        } catch {
                                print("JSON Parsing Error: \(error)")
                    }
            }
        }

        task.resume()
    }
    func updateUI(with response: [String: Any]) {
        if let responseData = response["data"] as? [String: Any],
           let responseMessage = responseData["message"] as? String {

            welcomeLabel.text = responseMessage
        }
    }
}
