import Foundation

public enum NetworkState<Success: Equatable, Failure: Error> {
    case ready
    case loading
    case completed(Result<Success, Failure>)
}

// MARK: TCA compliance
extension NetworkState: Equatable
where Success: Equatable, Failure: Equatable {}
