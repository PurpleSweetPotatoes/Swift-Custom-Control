// *******************************************
//  File Name:      BQRequest.swift
//  Author:         MrBai
//  Created Date:   2021/7/28 11:39 AM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

#if canImport(Alamofire)

    import Alamofire

    /**
     网络请求对象，使用点语法配置成功和失败回调
     */
    final class BQRequest {
        var request: Alamofire.Request?
        var desc: String = ""

        private var successHandler: BQSuccessClosure?
        private var failedHandler: BQFailedClosure?

        // MARK: - Handler

        func handleResponse(response: AFDataResponse<Any>) {
            switch response.result {
            case let .failure(error):
                if let closure = failedHandler {
                    BQHudView.show(error.localizedDescription, title: desc)
                    closure(BQReqError(error.responseCode ?? 0, d: error.localizedDescription, itemD: desc))
                }
            case let .success(result):
                if let closure = successHandler {
                    closure(result)
                }
            }

            successHandler = nil
            failedHandler = nil
        }

        @discardableResult
        public func success(_ closure: @escaping BQSuccessClosure) -> Self {
            successHandler = closure
            return self
        }

        @discardableResult
        public func failed(_ closure: @escaping BQFailedClosure) -> Self {
            failedHandler = closure
            return self
        }

        func cancel() {
            request?.cancel()
        }
    }

    // MARK: - extension 部分

    extension BQRequest: Equatable {
        static func == (lhs: BQRequest, rhs: BQRequest) -> Bool {
            return lhs.request?.id == rhs.request?.id
        }
    }

#endif
