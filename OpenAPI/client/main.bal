import ballerina/io;
import ballerina/http;

public function main() {
    // Base URL of the API
    string baseUrl = "http://localhost:8080";

    // Example lecturer data for creating a new lecturer
    json newLecturer = {
        "staff_number": "12345",
        "office_number": "A101",
        "staff_name": "Jeovane Morais",
        "title": "Professor",
        "courses": [
            {
                "course_name": "Introduction to Computer Science",
                "course_code": "CS101",
                "nqf_level": 6
            }
        ]
    };

    // Create a new lecturer
    http:Request createRequest = new;
    createRequest.addHeader("Content-Type", "application/json");
    createRequest.setPayload(newLecturer.toString());
    var createResponse = http:post(baseUrl + "/leecturers", createRequest); 

    if (createResponse is http:Response) {
        io:println("Response: " + createResponse.getTextPayload());
    } else {
        io:println("Error: " + createResponse.toString());
    }
}
