import ballerina/grpc;
import io;

type Book {
    string title;
    string author_primary;
    string author_secondary;
    string location;
    string isbn;
    boolean available;
}

// In-memory data structures
map<string, Book> bookStore = {};
stream<Book> availableBooks = [];

service LibraryService on new grpc:Listener(9090) {
    remote function AddBook(library:BookRequest req) returns library:Empty {
        Book newBook = {
            title: req.title,
            author_primary: req.author_primary,
            author_secondary: req.author_secondary,
            location: req.location,
            isbn: req.isbn,
            available: req.available
        };
        bookStore[req.isbn] = newBook;
        if (newBook.available) {
            availableBooks <- newBook;
        }
        return {};
    }

    remote function CreateUsers(stream<library:User> users) returns library:Empty {
        foreach var user in users {
            // Implement user creation logic here
            // You can store users in a similar map if needed
            io:println("User created: " + user.name);
        }
        return {};
    }

    remote function UpdateBook(library:BookRequest req) returns library:Empty {
        if (bookStore.exists(req.isbn)) {
            Book updatedBook = bookStore[req.isbn];
            updatedBook.title = req.title;
            updatedBook.author_primary = req.author_primary;
            updatedBook.author_secondary = req.author_secondary;
            updatedBook.location = req.location;
            updatedBook.available = req.available;
            bookStore[req.isbn] = updatedBook;
            if (updatedBook.available) {
                availableBooks <- updatedBook;
            } else {
                availableBooks.remove(updatedBook);
            }
        }
        return {};
    }

    remote function RemoveBook(library:RemoveBookRequest req) returns library:RemovedBooks {
        Book[] removedBooks;
        if (bookStore.exists(req.isbn)) {
            removedBooks = [bookStore[req.isbn]];
            bookStore.remove(req.isbn);
            availableBooks.remove(bookStore[req.isbn]);
        }
        return { books: removedBooks };
    }

    remote function ListAvailableBooks(library:Empty req) returns stream<library:Book> {
        return availableBooks;
    }

    remote function LocateBook(library:BookRequest req) returns library:Location {
        if (bookStore.exists(req.isbn)) {
            return { location: bookStore[req.isbn].location };
        }
        return { location: "Book not found" };
    }

    remote function BorrowBook(library:BookRequest req) returns library:BorrowResponse {
        if (bookStore.exists(req.isbn) && bookStore[req.isbn].available) {
            bookStore[req.isbn].available = false;
            availableBooks.remove(bookStore[req.isbn]);
            return { success: true };
        }
        return { success: false };
    }
}

public function main() {
    grpc:start(new grpc:Listener(9090));
    io:println("Server started.");
    io:println("Listening on port 9090...");
}
