import Foundation
import UIKit
import SwiftSignalKit

public typealias ListViewTransaction = (@escaping () -> Void) -> Void

public final class ListViewTransactionQueue {
    private var transactions: [ListViewTransaction] = []
    public final var transactionCompleted: () -> Void = { }
    
    public init() {
    }
    
    public func addTransaction(_ transaction: @escaping ListViewTransaction) {
        precondition(Thread.isMainThread)
        let beginTransaction = self.transactions.isEmpty
        self.transactions.append(transaction)
        
        if beginTransaction {
            self.runCurrentTransaction()
        }
    }
    
    private func runCurrentTransaction() {
        guard let currentTransaction = self.transactions.first else {
            return
        }
        
        var isCompleted = false
        let onComplete: () -> Void = { [weak self] in
            precondition(Thread.isMainThread)
            guard !isCompleted else {
                return
            }
            isCompleted = true
            
            if Thread.isMainThread {
                self?.endTransaction()
            } else {
                Queue.mainQueue().async {
                    self?.endTransaction()
                }
            }
        }
        
        currentTransaction(onComplete)
    }
    
    private func endTransaction() {
        precondition(Thread.isMainThread)
        Queue.mainQueue().async { [self] in
            self.transactionCompleted()
            if !self.transactions.isEmpty {
                let _ = self.transactions.removeFirst()
            }
            
            if !self.transactions.isEmpty {
                self.runCurrentTransaction()
            }
        }
    }
}
