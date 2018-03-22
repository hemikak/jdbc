struct Person {
    string name;
    int age;
    string address;
}

struct Student {
    string name;
    int age;
    string address;
    string class;
}

function testJsonStructConstraint() returns (json, json, json, string, int, string) {
    json<Person> j = {};
    j.name = "John Doe";
    j.age = 30;
    j.address = "London";
    var name, _ = (string) j.name;
    var age, _ = (int) j.age;
    var address, _ = (string) j.address;
    return (j.name, j.age, j.address, name, age, address);
}

function testJsonInitializationWithStructConstraint() returns (json, json, json){
    json<Person> j = {name:"John Doe", age:30, address:"London"};
    return (j.name, j.age, j.address);
}

function testGetPlainJson() returns (json) {
    json j = getPlainJson();
    return j;
}

function testGetConstraintJson() returns (json) {
    json<Person> j = getPerson();
    return j;
}

function getPersonJson() returns (json){
    json<Person> j = {name:"John Doe", age:30, address:"London"};
    return j;
}

function getPlainJson() returns (json){
    json j = {firstName:"John Doe", age:30, address:"London"};
    return j;
}

function getPersonEquivalentPlainJson() returns (json){
    json j = {name:"John Doe", age:30, address:"London"};
    return j;
}

function getPerson() returns (json<Person>){
    json<Person> j = {name:"John Doe", age:30, address:"London"};
    return j;
}

function getStudent() returns (json<Student>){
    json<Student> j = {name:"John Doe", age:30, address:"Colombo", class:"5"};
    return j;
}

struct Employee {
    string first_name;
    string last_name;
    int age;
    Address address;
}

struct Address {
    string number;
    string street;
    string city;
    PhoneNumber phoneNumber;
}

struct PhoneNumber {
    string areaCode;
    string number;
}

function testContrainingWithNestedStructs() returns (json, json, json) {
    json<Employee> e = {first_name:"John", last_name:"Doe", age:30, address:{phoneNumber:{number:"1234"}, street:"York St"}};
    return (e, e.address.phoneNumber.number, e["address"]["phoneNumber"]["number"]);
}

function testConstraintJSONToJSONCast() returns (json) {
    json<Person> j1 = getPerson();
    json j2 = (json) j1;
    return j2;
}

function testJSONToConstraintJsonUnsafeCast() returns (json, error) {
    json<Person> j;
    error err;
    j,err = (json<Person>)getPlainJson();
    return (j,err);
}

function testJSONToConstraintJsonUnsafeCastPositive() returns (json, json, json, error) {
    json<Person> j;
    var j, e = (json<Person>)getPersonEquivalentPlainJson();
    return (j.name, j.age, j.address, e);
}

function testConstraintJSONToConstraintJsonCast() returns (json) {
    json<Person> j = (json<Person>) getStudent();
    return j;
}

function testConstraintJSONToConstraintJsonUnsafePositiveCast() returns (json, error) {
    json<Person> jp = (json<Person>) getStudent();
    var js, e = (json<Student>) jp;
    return (js, e);
}

function testConstraintJSONToConstraintJsonUnsafeNegativeCast() returns (json, error) {
    json<Employee> je = {first_name:"John", last_name:"Doe", age:30, address:{phoneNumber:{number:"1234"}, street:"York St"}};
    var js, e = (json<Student>) je;
    return (js, e);
}

function testJSONArrayToConstraintJsonArrayCastPositive() returns (json<Student>[], error) {
    json j1 = [getStudent()];
    var j2, e = (json<Student>[]) j1;
    return (j2, e);
}

function testJSONArrayToConstraintJsonArrayCastNegative() returns (json<Student>[], error) {
    json j1 = [{"a":"b"}, {"c":"d"}];
    var j2, e = (json<Student>[]) j1;
    return (j2, e);
}

function testJSONArrayToCJsonArrayCast() returns (json<Student>[], error) {
    json[] j1 = [{"name":"John Doe", "age":30, "address":"London", "class":"B"}];
    json j2 = j1;
    var j3, e = (json<Student>[]) j2;
    return (j3, e);
}

function testJSONArrayToCJsonArrayCastNegative() returns (json<Student>[], error) {
    json[] j1 = [{name:"John Doe", age:30, address:"London"}]; // one field is missing
    json j2 = j1;
    var j3, e = (json<Student>[]) j2;
    return (j3, e);
}

function testCJSONArrayToJsonAssignment() returns (json) {
    json<Person> tempJ = getPerson();
    tempJ.age = 40; 
    json<Person>[] j1 = [getPerson(), tempJ];
    json j2 = j1;
    return j2;
}

function testMixedTypeJSONArrayToCJsonArrayCastNegative() returns (json<Student>[], error) {
    json[] j1 = [{name:"John Doe", age:30, address:"London", "class":"B"}, [4, 6]];
    json j2 = j1;
    var j3, e = (json<Student>[]) j2;
    return (j3, e);
}

function testConstrainedJsonWithFunctions() returns (string){
    json<Person> j = {name:"John Doe", age:30, address:"London"};
    return j.toString();
}

function testConstrainedJsonWithFunctionGetKeys() returns (string[]){
    json<Person> j = {name:"John Doe", age:30, address:"London"};
    return j.getKeys();
}
