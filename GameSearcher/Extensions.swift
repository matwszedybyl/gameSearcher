//
//  Extensions.swift
//  GameSearcher
//
//  Created by Mat Wszedybyl on 3/18/19.
//  Copyright © 2019 Mat Wszedybyl. All rights reserved.
//

import Foundation
import UIKit



extension UIScrollView {
        
        func extractCurrentY() -> CGFloat {
            let offset = contentOffset
            let inset = contentInset
            let y = offset.y + bounds.size.height + inset.bottom
            
            return y
        }
        
        func extractCurrentX() -> CGFloat {
            let offset = contentOffset
            let inset = contentInset
            let x = offset.x + bounds.size.width + inset.right
            
            return x
        }
        
}
