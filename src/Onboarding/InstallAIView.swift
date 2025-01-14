//
//  InstallAIView.swift
//  Puul
//
//  Created by Wheezy Capowdis on 1/10/25.
//

import SwiftUI

struct InstallAIView: View {
    @State var done: Bool = false
    @State var modelUrl: String = "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q5_K_M.gguf?download=true"
    @State var status: String = ""
    @State var filename: String = "puulai.gguf"
    @State private var downloadTask: URLSessionDownloadTask?
    @State private var observation: NSKeyValueObservation?
    @State private var progress: Double = 0
    @State var showingAlert = false
    
    private func download() {
        withAnimation(.easeInOut) {
            status = "downloading"
        }
        print("Downloading model from \(modelUrl)")
        guard let url = URL(string: modelUrl) else { return }
        let fileURL = getFileURLFormPathStr(dir:"models",filename: filename)
        
        downloadTask = URLSession.shared.downloadTask(with: url) { temporaryURL, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            do {
                if let temporaryURL = temporaryURL {
                    try FileManager.default.copyItem(at: temporaryURL, to: fileURL)
                    print("Writing to \(filename) completed")
                    
                    status = "downloaded"
                    withAnimation(.easeInOut) {
                        done = true
                    }
                }
            } catch let err {
                print("Error: \(err.localizedDescription)")
            }
        }
        
        observation = downloadTask?.progress.observe(\.fractionCompleted) { progress, _ in
            self.progress = progress.fractionCompleted  * 100
        }
        
        downloadTask?.resume()
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                // Large SF Symbol icon
                ZStack{
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .cornerRadius(120)
                        .padding()
                }
                
                // Title
                Text("Welcome to Puul!")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Description
                Text("Puul AI is a locally hosted AI model < 1 GB in size and is completely private and runs on your device with no internet connection required.")
                    .bold()
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            Spacer()
            if status == "downloading" {
                ProgressView()
                    .padding()
                Text("Installing \(Int(progress))%")
                    .bold()
                ProgressView(value: progress, total: 100)
                    .progressViewStyle(LinearProgressViewStyle())
                    .accentColor(.primary)
                    .padding()
                    .padding(.horizontal)
            }
            // MARK: - Next / Rate Us Button
            Button{
                if status.isEmpty {
                    download()
                } else if status == "downloading" {
                    showingAlert = true
                }
            } label: {
                HStack{
                    Text(status.isEmpty ? "Install local AI" : "Stop Installation")
                    Image(systemName: status.isEmpty ? "icloud.and.arrow.down" : "icloud.slash")
                }
                .bold()
                .font(.title)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
                .colorInvert()
                .background(.primary)
                .cornerRadius(18)
                .padding()
            }
            .buttonStyle(HapticButtonStyle())
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("Puul AI is safe and will not harm your device. Downloading over Wi-Fi recommended"),
                    primaryButton: .destructive(Text("Stop"), action: {
                        downloadTask?.cancel()
                        withAnimation {
                            status = ""
                        }
                    }),
                    secondaryButton: .cancel(Text("cancel"))
                )
            }
        }
        .background(Color.primary.colorInvert().ignoresSafeArea())
        .onAppear {
            if FileManager.default.fileExists(atPath: getFileURLFormPathStr(dir:"models",filename: filename).path)  {
                done = true
            }
        }
        .onDisappear() {
            downloadTask?.cancel()
        }
        .offset(x: done ? -500 : 0)
    }
}

#Preview {
    InstallAIView()
}
