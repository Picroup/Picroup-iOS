//
//  ImageGenerator.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/7.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

public struct ImageGenerator {
    
    public static func image(char: Character, color: UIColor = .brown) -> UIImage {
        let text = String(char).uppercased() as NSString
        let width: CGFloat = 64, height: CGFloat = 64
        let size = CGSize(width: width, height: height)
        let attributes: [NSAttributedStringKey : Any] = [
            .font: UIFont.systemFont(ofSize: width / 2),
            .foregroundColor: UIColor.white
        ]
        let textSize = text.size(withAttributes: attributes)
        
        let textRect = CGRect(
            origin: CGPoint(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2
            ),
            size: textSize
        )
        
        UIGraphicsBeginImageContext(size); defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        text.draw(in: textRect, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

