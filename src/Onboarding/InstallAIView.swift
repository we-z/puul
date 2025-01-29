//
//  InstallAIView.swift
//  YourApp
//
//  NOTE: This file demonstrates how to automatically loaƒcheckd the model
//        immediately after writing the downloaded file. This forces
//        the llama_load_model_from_file logs to appear as soon as
//        the download/copy completes.
//

import SwiftUI
import llmfarm_core

struct InstallAIView: View {
    @State private var done: Bool = false
    @State private var modelUrl: String = "https://huggingface.co/mradermacher/Llama-3.2-1B-Instruct-Uncensored-GGUF/resolve/main/Llama-3.2-1B-Instruct-Uncensored.Q8_0.gguf"
    @State private var status: String = ""
    @State private var filename: String = "Llama-3.2-1B-Instruct-Uncensored.Q8_0.gguf"
    @State private var downloadTask: URLSessionDownloadTask?
    @State private var downloadDelegate = ModelDownloadDelegate()
        
    @State private var observation: NSKeyValueObservation?
    @State private var progress: Double = 0
    @State private var showingAlert = false
    
    // Icons to cycle through
    private let icons = ["person.crop.circle", "sparkles", "brain", "dollarsign.circle", "chart.line.uptrend.xyaxis"]
    @State private var currentIconIndex = 0
    
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
            
            // Build the final fileURL
            let fileURL = getFileURLFormPathStr(dir: "models", filename: filename)
            
            // Prepare the background config
            let config = URLSessionConfiguration.background(withIdentifier: "com.yourapp.backgroundDownload.model")
            config.timeoutIntervalForRequest = 300     // 5 minutes
            config.timeoutIntervalForResource = 3600   // 1 hour
            config.isDiscretionary = false
            config.sessionSendsLaunchEvents = true
            config.waitsForConnectivity = true
            
            // Assign the final destination to our delegate so it knows where to copy
            downloadDelegate.destinationFileURL = fileURL
            
            // Provide closures to update SwiftUI on main thread
            downloadDelegate.onProgress = { fraction in
                DispatchQueue.main.async {
                    self.progress = fraction * 100
                }
            }
            downloadDelegate.onComplete = { finalFileURL in
                DispatchQueue.main.async {
                    print("Writing to \(self.filename) completed.")
                    
                    // Mark the status to show "downloaded"
                    withAnimation(.easeInOut) {
                        self.status = "downloaded"
                    }
                    
                    // Immediately load the model in the background
                    let ephemeralAI = AI(_modelPath: finalFileURL.path,
                                         _chatName: "AutoLoadBackgroundChat")
                    
                    ephemeralAI.initModel(.LLama_gguf)
                    
                    ephemeralAI.model?.modelLoadProgressCallback = { progress in
                        print("Auto-load progress: \(progress)")
                        return true
                    }
                    
                    ephemeralAI.model?.modelLoadCompleteCallback = { loadResult in
                        print("Auto-load complete: \(loadResult)")
                    }
                    
                    ephemeralAI.loadModel()
                }
            }
            downloadDelegate.onError = { errorMsg in
                DispatchQueue.main.async {
                    print("Background download error: \(errorMsg)")
                    withAnimation(.easeInOut) {
                        self.status = ""
                    }
                }
            }
            
            // Create a URLSession with our delegate
            let customSession = URLSession(configuration: config,
                                           delegate: downloadDelegate,
                                           delegateQueue: nil)
            
            // Start the download task
            downloadTask = customSession.downloadTask(with: url)
            downloadTask?.resume()
        }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                // Large icon (animated every 3 seconds)
                ZStack {
                    Image(systemName: icons[currentIconIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding()
                        .transition(.opacity)
                        .id(currentIconIndex)
                }
                
                // Title
                Text("Welcome to Puul")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Description
                Text("Puul AI model is 1.32GB in size. Download to run the expert LLM locally on your device.")
                    .bold()
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            Spacer()
            
            Text("(Wi-Fi connection recommended)")
                .bold()
                .font(.body)
                .multilineTextAlignment(.center)
            
            // Progress Section
            if status == "downloading" {
                ProgressView()
                    .controlSize(.large)
                    .padding()
                Text("Downloading \(Int(progress))%")
                    .font(.title3)
                    .bold()
                ProgressView(value: progress, total: 100)
                    .progressViewStyle(LinearProgressViewStyle())
                    .accentColor(.primary)
                    .padding()
                    .padding(.horizontal)
                
            } else if status == "downloaded" {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
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
                    Text(status.isEmpty ? "Download AI" : "Stop Download")
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
            if status != "downloading" {
                Button {
                    exit(0)
                } label: {
                    Text("Cancel to Exit")
                        .bold()
                        .font(.title2)
                        .padding(.bottom)
                }
                .buttonStyle(HapticButtonStyle())
            }
        }
        .background(Color.primary.colorInvert().ignoresSafeArea())
        .onAppear {
            // If the file already exists, skip this screen
            let fileURL = getFileURLFormPathStr(dir: "models", filename: filename)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                done = true
            }
            // Cycle through icons every 3 seconds
            Task {
                while !done {
                    try await Task.sleep(for: .seconds(6))
                    withAnimation(.easeInOut(duration: 1.0)) {
                        currentIconIndex = (currentIconIndex + 1) % icons.count
                    }
                }
            }
        }
        .onDisappear {
            // Stop any active download when leaving this view
            downloadTask?.cancel()
        }
        .offset(x: done ? -deviceWidth : 0)
        .alert("Are you sure?",
                       isPresented: $showingAlert,
                       actions: {
                    Button("Stop", role: .destructive) {
                        withAnimation {
                            status = ""
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        // Do nothing, just dismiss
                    }
                },
                       message: {
                    Text("Puul AI is safe and will not harm your device. Downloading over Wi-Fi is recommended.")
                })
        .onChange(of: status) { newStatus in
            if newStatus == "" {
                progress = 0
                Task {
                    downloadTask?.cancel()
                }
            }
        }
    }
}

#Preview {
    InstallAIView()
}

final class ModelDownloadDelegate: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    /// Called every time progress updates.
    var onProgress: ((Double) -> Void)?
    /// Called when the file has been successfully copied to final destination.
    var onComplete: ((URL) -> Void)?
    /// Called if any error occurs or the user cancels.
    var onError: ((String) -> Void)?
    
    /// A file URL for the final destination of the model (so we know where to copy).
    var destinationFileURL: URL?
    
    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else { return }
        let fractionCompleted = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        // Report progress (0.0 - 1.0)
        onProgress?(fractionCompleted)
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
        // Once the download is done, move/copy the file from 'location' to the final destination.
        guard let finalURL = destinationFileURL else {
            onError?("Destination URL not set.")
            return
        }
        
        do {
            // Remove any existing file at that location before copying
            if FileManager.default.fileExists(atPath: finalURL.path) {
                try FileManager.default.removeItem(at: finalURL)
            }
            try FileManager.default.copyItem(at: location, to: finalURL)
            
            // Notify success
            onComplete?(finalURL)
        } catch {
            onError?("Failed to copy file: \(error.localizedDescription)")
        }
    }
    
    /// This gets called if the download was canceled or if an error occurred.
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        
        if let error = error {
            // If user cancels, error will be NSURLErrorCancelled; handle as needed
            onError?("Download error: \(error.localizedDescription)")
        }
    }
}

