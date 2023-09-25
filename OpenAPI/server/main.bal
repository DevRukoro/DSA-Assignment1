import ballerina/http;

public type Lecturer record {|
    readonly string staffNo;
    string officeNo;
    string name;
    string title;
    string[] courses;
|};

public type Office record {|
    readonly string officeNo;
    string name;
|};


public type ConflictingStaffNo record {|
    *http:Conflict;
    ErrorMessage body; 
|};

public type ErrorMessage record {|
    string errorMessage;   
|};

//Changing the port number
configurable int port = 9090;

//Defines inheritance
public type CreatedLecturer record {|
    *http:Created;
    Lecturer body;
|};

public type LecturerNotFound record {|
    *http:NotFound;
    ErrorMessage body;
|};

public type LecturerPart record {|
    string officeNo;
    string name;
    string title;
    string[] courses;
|};




service /staffManager on new http:Listener(9090) {
    //initialize function to declare table within the service
    private table<Lecturer> key(staffNo) lecturers;

    private table<Office> key(officeNo) offices;


    function init() {
        self.lecturers = table [];
        self.offices = table [];
    }

    //to get all the lecturers wi
    isolated resource function get all() returns Lecturer[] {

        return self.lecturers.toArray();
    }

    //using curl to get all the courses
    //curl http://localhost:9090/courses

    //posting a new course
    resource function post add_lecturer(@http:Payload Lecturer newLecturer) returns CreatedLecturer|ConflictingStaffNo {
        string[] existingCourseCodes = from var {staffNo} in self.lecturers
            where staffNo == newLecturer.staffNo
            select staffNo;

        if existingCourseCodes.length() > 0 {
            return <ConflictingStaffNo>{
                body: {
                    errorMessage: string `Error: a course with code ${newLecturer.staffNo} already exists`
                }
            };
        } else {

            self.lecturers.add(newLecturer);

            //self.offices.add({
            //                   "officeNo":newLecturer.officeNo,
            //                   "name":newLecturer.name
            //                 });


            
            return <CreatedLecturer>{body: newLecturer};
        }
    }

    resource function get getLecturer/[string StaffNo]() returns Lecturer|LecturerNotFound {
        Lecturer? theCourse = self.lecturers[StaffNo];
       
        if theCourse == () {
            return <LecturerNotFound>{
                body: {errorMessage: string `Error no lecturer with this ${StaffNo}`}
            };
        } else {
            return theCourse;
        }

    }

    resource function get getLecturers/[string theOffice]() returns string[]|LecturerNotFound {
   
         string[] lecturersOffice = from var {officeNo, name} in self.lecturers
           where officeNo == theOffice
           select name;
           
           return lecturersOffice;
       

    }



    resource function put editLecturer/[string StaffNo](@http:Payload LecturerPart lecturerPart) returns LecturerNotFound|Lecturer {
        
        Lecturer? theLecturer = self.lecturers[StaffNo];
        
        if theLecturer == (){
            return <LecturerNotFound>{
                body: {errorMessage: string `Error no course with code ${StaffNo}`}
            };
        }else{
            string? officeNo = lecturerPart?.officeNo;
            if officeNo != (){
                theLecturer.officeNo = officeNo;
            }

            string? name = lecturerPart?.name;
            if name != () {
                theLecturer.name = name;
            }

            string? title = lecturerPart?.title;
            if title != () {
                theLecturer.title = title;
            }


            string[]? courses = lecturerPart?.courses;
            if courses != (){
                theLecturer.courses = courses;
            }
            return theLecturer;
        }
    }

    resource function delete delete_lecturer/[string StaffNo] () returns LecturerNotFound|http:Ok {
        Lecturer? theLecturer = self.lecturers[StaffNo];

        if theLecturer == () {
            return <LecturerNotFound>{
                body: {errorMessage: string `Error no lecturer with this number ${StaffNo}`}
            };
        }else {
            http:Ok ok = {body: "Deleted Lecturer"};
            return ok;
        }
    }

}