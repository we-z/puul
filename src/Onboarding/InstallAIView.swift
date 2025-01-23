//
//  InstallAIView.swift
//  YourApp
//
//  NOTE: This file demonstrates how to automatically load the model
//        immediately after writing the downloaded file. This forces
//        the llama_load_model_from_file logs to appear as soon as
//        the download/copy completes.
//

import SwiftUI
import llmfarm_core

struct InstallAIView: View {
    @State private var done: Bool = false
    @State private var modelUrl: String = "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q5_K_M.gguf?download=true"
    @State private var status: String = ""
    @State private var filename: String = "Llama-3.2-1B-Instruct-Q5_K_M.gguf"
    @State private var downloadTask: URLSessionDownloadTask?
    @State private var observation: NSKeyValueObservation?
    @State private var progress: Double = 0
    @State private var showingAlert = false
    
    /// Initiates the download and handles the copy/move on completion.
    private func download() {
        withAnimation(.easeInOut) {
            status = "downloading"
        }
        
        print("Downloading model from \(modelUrl)")
        guard let url = URL(string: modelUrl) else { return }
        
        // Create the directory before writing the file:
        do {
            try createDirectoryIfNeeded(dir: "models")
        } catch {
            print("Failed to create 'models' directory: \(error.localizedDescription)")
            return
        }
        
        let fileURL = getFileURLFormPathStr(dir: "models", filename: filename)
        
        // Start the download task
        downloadTask = URLSession.shared.downloadTask(with: url) { temporaryURL, response, error in
            // Handle any network or server errors
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.status = ""
                    }
                }
                return
            }
            
            // Ensure the HTTP status code is acceptable
            guard
                let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode)
            else {
                print("Server error!")
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.status = ""
                    }
                }
                return
            }
            
            // Attempt to move/copy from the temp location to your destination
            guard let temporaryURL = temporaryURL else {
                print("No valid temporary URL!")
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.status = ""
                    }
                }
                return
            }
            
            do {
                // Move or copy the file to your destination
                try FileManager.default.copyItem(at: temporaryURL, to: fileURL)
                
                print("Writing to \(self.filename) completed.")
                
                // ---------------------------------------------------------------
                // ADDED: Immediately load the model in the background so that
                //        the same llama_load_model_from_file logs appear now.
                // ---------------------------------------------------------------
                DispatchQueue.main.async {
                    // After hooking everything up, set the status to "downloaded"
                    // so that UI can proceed.
                    withAnimation(.easeInOut) {
                        self.status = "downloaded"
                    }
                    
                    // Create an ephemeral AI object:
                    let ephemeralAI = AI(_modelPath: fileURL.path,
                                         _chatName: "AutoLoadBackgroundChat")
                    
                    // We tell the ephemeral AI to use LLaMa_gguf or whichever
                    // is appropriate for your model. (You can pass a custom
                    // ModelAndContextParams if needed.)
                    ephemeralAI.initModel(.LLama_gguf)
                    
                    // Hook progress callback to see progress in the logs:
                    ephemeralAI.model?.modelLoadProgressCallback = { progress in
                        print("Auto-load progress: \(progress)")
                        return true
                    }
                    
                    // Hook completion callback to see final logs:
                    ephemeralAI.model?.modelLoadCompleteCallback = { loadResult in
                        print("Auto-load complete: \(loadResult)")
                    }
                    
                    // Actually load the model now:
                    ephemeralAI.loadModel()
                    
                    
                }
            } catch {
                print("Problem writing to \(self.filename)")
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.status = ""
                    }
                }
            }
        }
        
        // Observe progress via KVO
        observation = downloadTask?.progress.observe(\.fractionCompleted) { progressObj, _ in
            DispatchQueue.main.async {
                self.progress = progressObj.fractionCompleted * 100
            }
        }
        
        downloadTask?.resume()
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                // Large icon or logo
                ZStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
//                        .cornerRadius(120)
                        .padding()
                }
                
                // Title
                Text("Welcome to Puul")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Description
                Text("The private AI financial advisor running on your phone. Install once and get started!")
                    .bold()
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            Spacer()
            
            // Progress Section
            if status == "downloading" {
                ProgressView()
                    .controlSize(.large)
                    .padding()
                Text("Installing \(Int(progress))%")
                    .font(.title3)
                    .bold()
                ProgressView(value: progress, total: 100)
                    .progressViewStyle(LinearProgressViewStyle())
                    .accentColor(.primary)
                    .padding()
                    .padding(.horizontal)
                
            } else if status == "downloaded" {
                Image(systemName: "checkmark.circle.fill")
                    .padding()
                Text("Installation Complete")
                    .bold()
                    .padding()
                    .onAppear {
                        // After a short delay, animate offscreen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeInOut) {
                                done = true
                            }
                        }
                    }
            }
            
            // Download / Stop Button
            Button {
                if status.isEmpty {
                    download()
                } else if status == "downloading" {
                    showingAlert = true
                }
            } label: {
                HStack {
                    Text(status.isEmpty ? "Install AI" : "Stop Installation")
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
                    message: Text("Puul AI is safe and will not harm your device. Downloading over Wi-Fi is recommended."),
                    primaryButton: .destructive(Text("Stop"), action: {
                        // Cancel the ongoing download
                        downloadTask?.cancel()
                        withAnimation {
                            status = ""
                            progress = 0
                        }
                    }),
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        }
        .background(Color.primary.colorInvert().ignoresSafeArea())
        .onAppear {
            // If the file already exists, skip this screen
            let fileURL = getFileURLFormPathStr(dir: "models", filename: filename)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                done = true
            }
        }
        .onDisappear {
            // Stop any active download when leaving this view
            downloadTask?.cancel()
        }
        // Slide offscreen if `done` is true
        .offset(x: done ? -deviceWidth : 0)
    }
}

#Preview {
    InstallAIView()
}
