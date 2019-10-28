//
//  HomeworkViewModel.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/10/28.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

protocol HomeworkViewModelDelegate: class {
    func binding(to input: HomeworkViewModel.Input)
}

class HomeworkViewModel {
    
    struct Input {
        
        var acceptFriend: Observable<InviteCellViewModel> = Observable()
        var inacceptFriend: Observable<InviteCellViewModel> = Observable()
        var friendsCounts: Observable<Int> = Observable()
        var friendsSearch: Observable<String> = Observable()
    }
    
    struct Output {
        var inviteCellViewModels: [InviteCellViewModel] = []
        var transferCellViewModels: [TransferCellViewModel] = []
        
    }
    
    private var input = Input()
    private var output = Output()
    
    init(delegate: HomeworkViewModelDelegate) {
        
        delegate.binding(to: input)
        
        input.acceptFriend.binding { (viewModel) in
            // on acceptfriend, handle with self.cellViewModels
            
        }
        
        input.inacceptFriend.binding { (viewModel) in
            // ...
        }
        
        
    }
    
    func getOutput() -> Output {
        return self.output
    }
    
}
