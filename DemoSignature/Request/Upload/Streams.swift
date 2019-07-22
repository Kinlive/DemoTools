//
//  Streams.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/19.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

struct Streams {
    let input: InputStream
    let output: OutputStream
}


class StreamsHandler: NSObject {
    
    var session: URLSession!

    var boundStreams: Streams?

    private var canWrite: Bool = false
    
    private var data: Data = Data()
    private var currentSendSizes = 0
    
    var uploadTask: URLSessionUploadTask!
    
    
    override init() {
        super.init()
        
        // prepare big data
        var bigStrs: String = ""
        
        for i in 0...Int(1e6) {
            bigStrs += "A big data with very more count: \(i), \n"
        }
        let bigData = bigStrs.data(using: .utf8)
        guard let newData = bigData else { return }
        self.data = newData
    }
    
    
    deinit {
        guard let streams = boundStreams else { return }
        
        if streams.output.streamStatus == .open {
            streams.output.close()
        }
        if streams.input.streamStatus == .open {
            streams.input.close()
        }
        
    }
   
    func uploadData() {
        
        if boundStreams == nil {
            boundStreams = getNewStreams()
        }
        
        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        }
        
        guard let stream = boundStreams, let session = session else { return }
        
        let url = URL(string: "http://localhost:3000/uploadStream")! //"https://httpbin.org/anything")!
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.addValue("uploadImage", forHTTPHeaderField: "fileName")
        request.httpBodyStream = stream.input
        
        uploadTask = session.uploadTask(withStreamedRequest: request)
    
        uploadTask.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.beginWriteData(stream: stream)
        }
        
    }
    
    func getNewStreams() -> Streams {
        
        var inputStreamOrNil: InputStream?
        var outputStreamOrNil: OutputStream?
        
        // bufferSize: byte, ex: size = image(1024*1024) / 8
        Stream.getBoundStreams(withBufferSize: self.data.count, inputStream: &inputStreamOrNil, outputStream: &outputStreamOrNil)
        
        guard let input = inputStreamOrNil, let output = outputStreamOrNil else {
            fatalError("On return of `getBoundStreams`, both `inputStream` and `outputStream` will contain non-nil streams.")
            
        }
        
        output.delegate = self
        output.schedule(in: .current, forMode: .default)
        output.open()
        
        
        return Streams(input: input, output: output)
    }
    
    
    private func beginWriteData(stream: Streams) {
        guard canWrite else { return }
        
        // here will run all data transfer from input to output
        let bytesWritten: Int = self.data.withUnsafeBytes() { dataBytes in
            self.canWrite = false
            let buffer: UnsafePointer<UInt8> = dataBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
        
            return stream.output.write(buffer, maxLength: self.data.count)
        }
        
        printLog(logs: ["bytesWritten: \(bytesWritten)", "dataCount: \(self.data.count)"], title: "Size display")
        
        if bytesWritten < self.data.count {
            // Handle writing less data than expected.
            printLog(logs: ["bytesWritten < messageData.count", "bytyesWritte: \(bytesWritten), dataCount: \(self.data.count)"], title: "Handle writing less data than expected.")
            
        }
    }
    
}

extension StreamsHandler: URLSessionStreamDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        // provide input stream
        printLog(logs: [task.currentRequest?.url?.absoluteString ?? ""], title: "needNewBodyStream completionHandler")
        guard let stream = boundStreams else { return }
        completionHandler(stream.input)
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        // FIXME: - upload process
        
        if Int(totalBytesSent) == data.count {
            printLog(logs: ["bytesSent:\(bytesSent)","totalBytesSent: \(totalBytesSent)","totalBytesExpectedToSend: \(totalBytesExpectedToSend)"], title: "didSendBodyData")
            
            if boundStreams!.input.streamStatus == .atEnd {
                boundStreams?.input.close()
            }
            
            if boundStreams!.output.streamStatus != .writing {
                boundStreams?.output.close()
            }
            
            boundStreams = nil
            session.finishTasksAndInvalidate()
            self.session = nil
        }
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        printLog(logs: [error?.localizedDescription ?? ""], title: "CompleteWithError")
    }
}

extension StreamsHandler: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard aStream == boundStreams!.output else {
            printLog(logs: ["aStream == boundStreams.output"], title: "handle eventCode")
            return }
  
        let title = "handleEventCode"

        switch eventCode {
        case Stream.Event.hasSpaceAvailable:
            canWrite = true
            
        case Stream.Event.errorOccurred:
            // Close the streams and alert the user that the upload failed.
            aStream.close()
            boundStreams?.input.close()
            session.finishTasksAndInvalidate()
            printLog(logs: ["\(String(describing: aStream.streamError?.localizedDescription))"], title: "Upload stream error")
            
        case Stream.Event.openCompleted:
            printLog(logs: ["Stream.Event.openCompleted: \(eventCode.rawValue)"], title: title)
        
        case Stream.Event.hasBytesAvailable:
            printLog(logs: ["Stream.Event.hasBytesAvailable: \(eventCode.rawValue)"], title: title)
       
        case Stream.Event.endEncountered:
            printLog(logs: ["Stream.Event.endEncountered: \(eventCode.rawValue)"], title: title)

        default:
            break
        }
    
    }
}
