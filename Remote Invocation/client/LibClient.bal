import ballerina/grpc;
import io;

function main() {
    grpc:Client libraryClient = check new grpc:Client("http://localhost:9090", {});
    var response = check libraryClient->addBook(createBookRequest("Sample Book", "Author 1", "Author 2", "Shelf 1", "1234567890", true));
    io:println("Added Book: " + response);

    var users = createUsers();
    check libraryClient->createUsers(users);

    response = check libraryClient->updateBook(createBookRequest("Sample Book", "Author 1", "Author 2", "Shelf 2", "1234567890", false));
    io:println("Updated Book: " + response);

    var removeResponse = check libraryClient->removeBook(createRemoveBookRequest("1234567890"));
    io:println("Removed Books: " + removeResponse.books);

    var availableBooks = check libraryClient->listAvailableBooks({});
    io:println("Available Books:");
    foreach var book in availableBooks {
        io:println(book);
    }

    var locationResponse = check libraryClient->locateBook(createBookRequest("", "", "", "", "1234567890", false));
    io:println("Book Location: " + locationResponse.location);

    var borrowResponse = check libraryClient->borrowBook(createBookRequest("", "", "", "", "1234567890", false));
    io:println("Borrowed: " + borrowResponse.success);
}

function createBookRequest(title, author1, author2, location, isbn, available) returns library:BookRequest {
    return {
        title: title,
        author_primary: author1,
        author_secondary: author2,
        location: location,
        isbn: isbn,
        available: available
    };
}

function createUsers() returns stream<library:User> {
    return new stream<library:User> {
        public function next() returns library:User? {
            yield { name: "User 1" };
            yield { name: "User 2" };
            close;
        }
    };
}

function createRemoveBookRequest(isbn) returns library:RemoveBookRequest {
    return { isbn: isbn };
}
