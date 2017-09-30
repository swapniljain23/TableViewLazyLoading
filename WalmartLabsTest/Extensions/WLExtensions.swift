//
//  WLExtensions.swift
//  WalmartLabsTest
//
//  Created by Swapnil Jain on 9/29/17.
//  Copyright © 2017 WalmartLabs. All rights reserved.
//

import UIKit
import Foundation

extension String{
    func htmlAttributedString() -> NSAttributedString?{
        guard let data = self.data(using: String.Encoding.utf8) else{
            return nil
        }
        guard let html = try? NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else{
            return nil
        }
        return html
    }
}
