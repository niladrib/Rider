//
//  OAuthController.swift
//  Hiker
//
//  Created by Niladri Bora on 9/27/24.
//

import AuthenticationServices

/**
 Attribution: https://luomein.medium.com/generic-swift-oauth-2-0-in-async-way-ba53f686263f
 */
class OAuthController : NSObject, ASWebAuthenticationPresentationContextProviding {
  
  public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }
  
  func webAuth(url: URL, callbackURLScheme: String, prefersEphemeralWebBrowserSession: Bool,
               completion: @escaping (Result<URL, Error>) -> Void){
    let authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { (url, error) in
      if let error = error {
        completion(.failure(error))
      } else if let url = url {
        completion(.success(url))
      }
    }
    DispatchQueue.main.async { [weak self] in
      guard let self = self else{
        return
      }
      authSession.presentationContextProvider = self
      authSession.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
      authSession.start()
    }
  }
  
  func webAuth(url: URL, callbackURLScheme: String, prefersEphemeralWebBrowserSession: Bool) async throws -> URL{
    return try await withCheckedThrowingContinuation {continuation in
      webAuth(url: url, callbackURLScheme: callbackURLScheme, prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession) { result in
        switch result {
        case .success(let url):
          continuation.resume(returning: url)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
