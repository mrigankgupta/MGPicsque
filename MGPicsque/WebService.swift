//
//  WebService.swift
//  MGPicsque
//
//  Created by Gupta, Mrigank on 27/11/18.
//  Copyright © 2018 Gupta, Mrigank. All rights reserved.
//

import Foundation

//Key: b941d84458baafeca405fa394a7f8e94
//Secret: 4a7ee4061a83e469
fileprivate let key = "b941d84458baafeca405fa394a7f8e94"
fileprivate let format = "json"
fileprivate let extras = "url_m,url_n"
fileprivate let baseURLString = "https://api.flickr.com"
fileprivate let baseURL = URL(string: baseURLString)!

struct Resourse<T> {
    var url: URL
    var parse: (Data) -> T?
}

protocol WebResponse: class {
    func returnedResponse<T: Decodable>(_ item: PagedResponse<T>?)
}

protocol PagableService {
    func refreshPage()
    func loadNextPage(currentPage: Int)
}

class WebService {
    weak var delegate: WebResponse?
    private var parameters: [String : String] = ["api_key":"\(key)",
        "extras":"\(extras)",
        "format":"\(format)",
        "nojsoncallback":"1"]

    final func getMe<T>(res: Resourse<T>, completion: @escaping (T?) -> Void) {
        URLSession.shared.dataTask(with: res.url) { (data, response, err) in
            if let err = err {
                print("client error", err)
                return completion(nil)
            }
            guard let httpRes = response as? HTTPURLResponse, 200..<300 ~= httpRes.statusCode else {
                print("bad response")
                return completion(nil)
            }
            if let data = data {
                return completion(res.parse(data))
            }
            }.resume()
    }

    static func getURL(baseURL: URL, path: String, params: [String : String],
                       argsDict: [String : String]?) -> URL {
        var queryItems = [URLQueryItem]()
        if let argsDict = argsDict {
            for (key,value) in argsDict {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        for (key,value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems
        print(components.url)
        return components.url!
    }

    final func prepareResource<T: Decodable>(page: Int, pageSize: Int, pathForREST: String,
                                             argsDict: [String : String]? = nil) -> Resourse<T> {
        parameters["page"] = String(page)
        parameters["pageSize"] = String(pageSize)
        let completeURL = WebService.getURL(baseURL: baseURL, path: pathForREST, params: parameters, argsDict: argsDict)
        let downloadable = Resourse<T>(url: completeURL) { (raw) -> T? in
            print(raw)
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
}
