//
//  ContentView.swift
//  Shared
//
//  Created by H Chan on 2020/10/20.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var repository = AuthRepository()
    
    @State var fallbackWithPasscode = false
    @State var checkBeforeExecute = false
    
    var body: some View {
        NavigationView {
            ScrollViewReader { reader in
                List {
                    Section(header: Text("Configuration")) {
                        Toggle(isOn: $fallbackWithPasscode, label: {
                            Text("Fallback with passcode when failed few times")
                        })
                        
                        Toggle(isOn: $checkBeforeExecute, label: {
                            Text("Fallback when biometry not available")
                        })
                    }
                    
                    Section(header: Text("Process")) {
                        Button(action: { repository.login(fallbackWithPasscode: fallbackWithPasscode, checkBeforeExecute: checkBeforeExecute) }, label: {
                            Text("Request FaceId Auth")
                        })
                        
                        Button(action: { repository.resetBiometry() }, label: {
                            Text("Reset biometry using passcode")
                        })
                        
                        Button(action: { repository.clearHistory() }, label: {
                            Text("Clear History")
                        })
                    }
                    
                    Section(header: Text("History")) {
                        ForEach(repository.results, id: \.self) { result in
                            Text(result)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .onReceive(repository.$results, perform: { _ in
                    reader.scrollTo(repository.results.last)
                })
                .navigationTitle("FaceID Demo")
            }
        }
        .alert(isPresented: $repository.showDialog, content: {
            Alert(title: Text(repository.dialogMessage))
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
