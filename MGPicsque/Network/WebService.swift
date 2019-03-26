//
//  WebService.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 27/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import Foundation
import Pageable

//Key: b941d84458baafeca405fa394a7f8e94
fileprivate let key = "b941d84458baafeca405fa394a7f8e94"
fileprivate let format = "json"
fileprivate let extras = "url_m,url_n"
fileprivate let baseURL = "api.flickr.com"

struct Resourse<T> {
    var url: URL
    var parse: (Data) -> T?
}
#if swift(>=5.0)
#else
public enum Result<Success, Failure: Error> {
    case success(Success), failure(Failure)
}
#endif

enum AppError: Error {
    case invalidURL
    case parsingError
    case clientError
    case badResponse
}
class WebService {
    weak var delegate: WebResponse?
    var session = URLSession(configuration: URLSession.shared.configuration)

    private var parameters: [String : String] = ["api_key":"\(key)",
        "extras":"\(extras)",
        "format":"\(format)",
        "nojsoncallback":"1"]

    final func getMe<T>(res: Resourse<T>, completion: @escaping (Result<T, AppError>) -> Void) {
        session.dataTask(with: res.url) { (data, response, err) in
            guard err == nil else {
                print("client error")
                return completion(.failure(.clientError))
            }
            guard let httpRes = response as? HTTPURLResponse, 200..<300 ~= httpRes.statusCode,
                let data = data, data.count > 0 else {
                    print("bad response")
                    return completion(.failure(.badResponse))
            }
            guard let parsed = res.parse(data) else {
                return completion(.failure(.parsingError))
            }
            completion(.success(parsed))

            }.resume()
    }

    static func getURL(baseURL: String, path: String, params: [String : String],
                       argsDict: [String : String]?) -> URL? {
        var queryItems = [URLQueryItem]()
        if let argsDict = argsDict {
            for (key,value) in argsDict {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        for (key,value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = baseURL
        components.path = path
        components.queryItems = queryItems
        print(components.url)
        return components.url
    }


    final func prepareResource<T: Decodable>(page: Int, pageSize: Int, pathForREST: String,
                                             argsDict: [String : String]? = nil) throws -> Resourse<T> {
        parameters["page"] = String(page)
        parameters["pageSize"] = String(pageSize)

        guard let completeURL = WebService.getURL(baseURL: baseURL, path: pathForREST,
                                                  params: parameters, argsDict: argsDict) else { throw AppError.invalidURL }
        let downloadable = Resourse<T>(url: completeURL) { (raw) -> T? in
            do {
                let parsedDict = try JSONDecoder().decode(T.self, from: raw)
                return parsedDict
            } catch DecodingError.typeMismatch(let key, let context) {
                print(key, context)
            } catch let err {
                print(err)
            }
            return nil
        }
        return downloadable
    }

    func cancelAll() {
        session.invalidateAndCancel()
        session = URLSession(configuration: URLSession.shared.configuration)
    }
}
