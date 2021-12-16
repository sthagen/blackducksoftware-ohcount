class Person {
  var age  = 25

  init() { 
      print(“A new instance of this class Person is created.”) 
  } 


  /* Block
     comment */
  func sayHelloWorld() {    // Code appended with line comment
      print("Hello World") /* Code appended with block comment */
  }
}

let personObj =  Person()
print(“This person age is \(personObj.age)”)
