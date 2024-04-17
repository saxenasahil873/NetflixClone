//
//  Extensions.swift
//  Netflix Clone
//
//  Created by Sahil Saxena on 07/03/24.
//

import Foundation

extension String {
    
    func capitalizedFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
}
