//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP
import PerfectHTTPServer

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func plaintextHandler(request: HTTPRequest, response: HTTPResponse) {

	response.appendBody(string: "Hello, World!")

    setHeaders(response: response, contentType: "text/plain")

	response.completed()
}

func jsonHandler(request: HTTPRequest, response: HTTPResponse) {

    var helloDictionary: [String: String] = [:]
    helloDictionary["message"] = "Hello, World!"

    let errorPayload: [String: Any] = [
        "error": "Could not set body!"
    ]

    var responseString: String = ""
    var errorString: String = ""
    do {
        errorString = try errorPayload.jsonEncodedString()
    } catch {
        // Nothing to do here - we already have an empty value
    }

    do {
        responseString = try helloDictionary.jsonEncodedString()
    } catch {
        response.status = HTTPResponseStatus.internalServerError
        response.appendBody(string: errorString)
    }

    response.appendBody(string: responseString)

    setHeaders(response: response, contentType: "application/json")
    response.completed()
}

// Helpers

func setHeaders(response: HTTPResponse, contentType: String) {

    response.setHeader(.contentType, value: contentType)
    response.setHeader(.custom(name: "Server"), value: "Perfect")
}

var routes = Routes()
routes.add(method: .get, uri: "/json", handler: jsonHandler)
routes.add(method: .get, uri: "/plaintext", handler: plaintextHandler)
routes.add(method: .get, uri: "/**",
		   handler: StaticFileHandler(documentRoot: "./webroot", allowResponseFilters: true).handleRequest)
try HTTPServer.launch(name: "localhost",
					  port: 8080,
					  routes: routes,
					  responseFilters: [
						(PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high)])

