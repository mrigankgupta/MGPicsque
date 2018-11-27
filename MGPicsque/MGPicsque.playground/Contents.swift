import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

//Key: b941d84458baafeca405fa394a7f8e94
//Secret: 4a7ee4061a83e469
let method = "flickr.photos.getRecent"
let key = "b941d84458baafeca405fa394a7f8e94"
let format = "json"
let extras = "url_q"
typealias JSONDictionary = [String:Any]
let baseURLString = "https://api.flickr.com"
let baseURL = URL(string: baseURLString)!

struct Resourse<T> {
    var url: URL
    var parse: (Data) -> T?
}

protocol PagableService {
    func refreshPage()
    func loadNextPage(currentPage: Int)
}

class WebService {
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

struct PagedResponse<T: Decodable>: Decodable {
    var types: [T]
    var page: Int
    var pageSize: Int
    var totalPageCount: Int
    public enum CodingKeys: String, CodingKey {
        case types = "photo"
        case page
        case pageSize = "perpage"
        case totalPageCount = "pages"
    }
}

struct PhotoListing<T: Decodable>: Decodable {
    var photos: PagedResponse<T>
}

struct Photo: Decodable {
    var id: String
}

let service = WebService()
let resource: Resourse<PhotoListing<Photo>> = service.prepareResource(page: 1, pageSize: 10, pathForREST: "services/rest/", argsDict: ["method":"\(method)"])
service.getMe(res: resource) { (response) in
    print(response)
}
