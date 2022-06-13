//
//  ViewController.swift
//  TestMoya
//
//  Created by zhouyajie on 2022/4/30.
//

import UIKit
import Moya
import Alamofire


class RPRequest {
    var success: ((Any) -> Void)?
    var failure: ((Any) -> Void)?
    var target: RBPSTravel?
}

class ChainRequest {
    
    var requests: [RPRequest] = []
    private var lock = DispatchSemaphore(value: 1)
    let queue = DispatchQueue.global()
    
    init(_ target: RBPSTravel) {
        let model = RPRequest()
        model.target = target;
        requests.append(model)
    }

    @discardableResult
    func then(_ completion: @escaping ((Any) -> Void)) -> Self {

        let model = requests.last;
        model?.success = completion;
        
        // 信号量控制
        queue.async {
            self.lock.wait()
            if let requestModel = model {
                rbpsProvider.request(requestModel.target!) { result in
                    switch result {
                    case let .success(value):
                        self.lock.signal()
                        requestModel.success?(value)

                    case let .failure(error):
                        requestModel.failure?(error)

                    }
                }
            }
        }
        
        return self;
    }
    
    func then(_ addRequest: @escaping (() -> ChainRequest)) -> Self {
        self.requests.append(addRequest().requests[0])
        return self
    }

    
    func network(_ model: RPRequest?) {
        
        if let requestModel = model {
            
            rbpsProvider.request(requestModel.target!) { result in
                switch result {
                case let .success(value):
                    requestModel.success?(value)
                case let .failure(error):
                    requestModel.failure?(error)
                    
                }
            }
        }
    }
    
    
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChainRequest(.getTest)
        .then { rep in
            print("getTest")
            print(rep)
        }
        .then {
            return ChainRequest(.putTest)
        }.then { rep in
            print("putTest")
            print(rep)
        }.then {
            return ChainRequest(.postTest)
        }.then { rep in
            print("PostTest")
            print(rep)
        }
    }
    
    func basicUsed() {
        let cancellable = rbpsProvider.request(.getTest) { result in
            print(result)
        }
    }
    
//
//    func composite(_ f1: @escaping(TargetType) -> Cancellable, _f2: (TargetType) -> Cancellable) -> (TargetType) -> Cancellable {
//
//    }

}

