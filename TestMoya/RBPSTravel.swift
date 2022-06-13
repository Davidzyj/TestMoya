//
//  RPBSTravel.swift
//  TestMoya
//
//  Created by zhouyajie on 2022/4/30.
//

import Moya


// Target -> EndPoint
let endpointClosure = { (target: RBPSTravel) -> Endpoint in
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
    print("custom - endpointClosure");
    return defaultEndpoint;
    
    // 可以自定义请求头
//    return Endpoint(url: <#T##String#>, sampleResponseClosure: <#T##Endpoint.SampleResponseClosure##Endpoint.SampleResponseClosure##() -> EndpointSampleResponse#>, method: <#T##Method#>, task: <#T##Task#>, httpHeaderFields: <#T##[String : String]?#>)
}

// EndPoint -> URLRequest
let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        // Modify the request however you like.
        done(.success(request))
    } catch {
//        done(.failure(MoyaError.underlying(error, <#Response?#>)))
    }

}


let rbpsProvider = MoyaProvider<RBPSTravel>(endpointClosure:endpointClosure)

enum RBPSTravel {
case getMatchingRecordList(userID: String, mackey:String)
case getTest
case postTest
case putTest
}

extension RBPSTravel: TargetType {
    
    var baseURL: URL {
        URL(string: "https://httpbin.org")!
    }
    
    
    var path: String {
        switch self {
        case .getMatchingRecordList:
            return "/RBPSTravel/getMatchingRecordList_V1"
        case .getTest:
            return "/get"
        case .postTest:
            return "/post"
        case .putTest:
            return "/put"
        }
    }
    
    // 请求方法
    var method: Method {
        switch self {
        case .getMatchingRecordList:
            return .post
        case .getTest:
            return .get
        case .postTest:
            return .post
        case .putTest:
            return .put
        }
    }
    
    // 请求头
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    
    // 请求体
    var task: Task {
        switch self {
        case let .getMatchingRecordList(userID: userID, mackey: mackey):
            var paramters:[String: Any] = ["userID":userID, "mackey":mackey]
            return .requestParameters(parameters: addMoreArguments(params: &paramters), encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
        
    }
    
    
    func addMoreArguments(params: inout [String: Any]) -> [String: Any] {
        params["ts"] = 1191919919
        params["mac"] = "mac"
        return params
    }
}

