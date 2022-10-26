//
//  Helper.swift
//  TestJSInterface
//
//  Created by Chetan Raina on 01/09/22.
//

import UIKit

public class Helper {
    public static func postRequest(
        url: String,
        requestHeaders: [String: String],
        body: [String: Any],
        onSuccess: @escaping ([String: Any]) -> Void
    ) {
        // create the session object
        let session = URLSession.shared

        // now create the URLRequest object using the url object
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod =  "POST"

        // add headers for the request
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        for (key, value) in requestHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        do {
        // convert parameters to Data and assign dictionary to httpBody of request
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }

        // create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request) { data, response, error in

            if let error = error {
              print("Post Request Error: \(error.localizedDescription)")
              return
            }

            // ensure there is valid response code returned from this HTTP response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
              print("Invalid Response received from the server")
              return
            }

            // ensure there is data returned
            guard let responseData = data else {
              print("nil Data received from the server")
              return
            }

            do {
              // create json object from data or use JSONDecoder to convert to Model stuct
              if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                  onSuccess(jsonResponse)
              } else {
                print("data maybe corrupted or in wrong format")
                throw URLError(.badServerResponse)
              }
            } catch let error {
              print(error.localizedDescription)
            }
        }
        
        // perform the task
        task.resume()
    }
    
    
    public static func getSessionToken(onSuccess: @escaping ([String: Any]) -> Void) {
        let requestUrl = "https://api-uat.hyperface.co/auth/sessionToken"
        
        let requestHeaders = [
            "apikey": "secretkeybasis",
        ]
        
        let body: [String: Any] = [
            "registeredMobileNumber": "7020006289",
            "customerId": "cst_HYPypDW9tF4giDhuO",
            "accountId": "acc_pp_HYPGdNz9LkmN5lac9p1",
        ]
        
//        let requestUrl = "https://uat.hyperface.co/auth/sessionToken"
//
//        let requestHeaders = [
//            "apikey": "secret_uquxemi54fg9lfnw",
//        ]
//
//        let body: [String: Any] = [
//            "registeredMobileNumber": "9899100832",
//            "customerId": "cst_HYPfboMenerSM3uIQ",
//            "accountId": "acc_ca_HYPlN4wT9YLo02FjADt",
//        ]
        
        Helper.postRequest(url: requestUrl, requestHeaders: requestHeaders, body: body, onSuccess: onSuccess)
    }
}
