//
//  MagnifierRect.swift
//  
//
//  Created by Samu András on 2020. 03. 04..
//

import SwiftUI

#if os(iOS) || os(watchOS)

public struct MagnifierRect: View {
    
    static let cornerRadius: CGFloat = 12
    static let width: CGFloat = 80
    
    var valueSpecifier: String
    let padding: EdgeInsets = EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10)
    
    @Binding var x: String
    @Binding var y: Double
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    public var body: some View {
        
        ZStack {
            
            VStack {
                Text(self.x)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text("\(self.y, specifier: valueSpecifier)")
            }
            .padding(self.padding)
            .font(.system(size: 18, weight: .bold))
            .offset(x: 0, y: -110)
            .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
            
            if (self.colorScheme == .dark ) {
                RoundedRectangle(cornerRadius: MagnifierRect.cornerRadius)
                    .stroke(Color.white, lineWidth: self.colorScheme == .dark ? 2 : 0)
                    .frame(width: MagnifierRect.width, height: 260)
            } else {
                RoundedRectangle(cornerRadius: MagnifierRect.cornerRadius)
                    .frame(width: MagnifierRect.width, height: 260)
                    .foregroundColor(Color.white)
                    .shadow(color: Colors.LegendText, radius: 12, x: 0, y: 6 )
                    .blendMode(.multiply)
            }
            
        }
        
    }
    
}

#endif
