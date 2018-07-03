// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
// This is client implementation for server streaming scenario
import ballerina/grpc;
import ballerina/io;
import ballerina/runtime;

string[] responses;
int total = 0;
function testServerStreaming(string name) returns (string[]) {
    // Client endpoint configuration
    endpoint HelloWorldClient helloWorldEp {
        url:"http://localhost:9090"
    };
    // Executing unary non-blocking call registering server message listener.
    error? result = helloWorldEp->lotsOfReplies(name, HelloWorldMessageListener);
    match result {
        error payloadError => {
            io:println("Error occured while sending event " + payloadError.message);
            responses[total] = "Error occured while sending event " + payloadError.message;
            return responses;
        }
        () => {
            io:println("Connected successfully");
        }
    }

    int wait = 0;
    while(total < 4) {
        runtime:sleep(1000);
        io:println("msg count: " + total);
        if (wait > 10) {
            break;
        }
        wait++;
    }
    io:println("Client got response successfully.");
    return responses;
}

// Server Message Listener.
service<grpc:Service> HelloWorldMessageListener {

    // Resource registered to receive server messages
    onMessage(string message) {
        io:println("Response received from server: " + message);
        responses[total] = message;
        total = total + 1;
    }

    // Resource registered to receive server error messages
    onError(error err) {
        if (err != ()) {
            io:println("Error reported from server: " + err.message);
        }
    }

    // Resource registered to receive server completed message.
    onComplete() {
        io:println("Server Complete Sending Response.");
        responses[total] = "Server Complete Sending Response.";
        total = total + 1;
    }
}

// Non-blocking client
public type HelloWorldStub object {

    public grpc:Client clientEndpoint;
    public grpc:Stub stub;

    function initStub(grpc:Client ep) {
        grpc:Stub navStub = new;
        navStub.initStub(ep, "non-blocking", DESCRIPTOR_KEY, descriptorMap);
        self.stub = navStub;
    }

    function lotsOfReplies(string req, typedesc listener, grpc:Headers? headers = ()) returns (error?) {
        return self.stub.nonBlockingExecute("HelloWorld/lotsOfReplies", req, listener, headers = headers);
    }
};


// Non-blocking client endpoint
public type HelloWorldClient object {

    public grpc:Client client;
    public HelloWorldStub stub;


    public function init(grpc:ClientEndpointConfig config) {
        // initialize client endpoint.
        grpc:Client c = new;
        c.init(config);
        self.client = c;
        // initialize service stub.
        HelloWorldStub s = new;
        s.initStub(c);
        self.stub = s;
    }

    public function getCallerActions() returns (HelloWorldStub) {
        return self.stub;
    }
};

@final string DESCRIPTOR_KEY = "HelloWorld.proto";
map descriptorMap =
{
    "HelloWorld.proto":
    "0A1048656C6C6F576F726C642E70726F746F1A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F325B0A0A48656C6C6F576F726C64124D0A0D6C6F74734F665265706C696573121B676F6F676C652E70726F746F6275662E537472696E6756616C75651A1B676F6F676C652E70726F746F6275662E537472696E6756616C756528003001620670726F746F33"
    ,

    "google.protobuf.google/protobuf/wrappers.proto":
    "0A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F120F676F6F676C652E70726F746F627566221C0A0B446F75626C6556616C7565120D0A0576616C7565180120012801221B0A0A466C6F617456616C7565120D0A0576616C7565180120012802221B0A0A496E74363456616C7565120D0A0576616C7565180120012803221C0A0B55496E74363456616C7565120D0A0576616C7565180120012804221B0A0A496E74333256616C7565120D0A0576616C7565180120012805221C0A0B55496E74333256616C7565120D0A0576616C756518012001280D221A0A09426F6F6C56616C7565120D0A0576616C7565180120012808221C0A0B537472696E6756616C7565120D0A0576616C7565180120012809221B0A0A427974657356616C7565120D0A0576616C756518012001280C427C0A13636F6D2E676F6F676C652E70726F746F627566420D577261707065727350726F746F50015A2A6769746875622E636F6D2F676F6C616E672F70726F746F6275662F7074797065732F7772617070657273F80101A20203475042AA021E476F6F676C652E50726F746F6275662E57656C6C4B6E6F776E5479706573620670726F746F33"

};

