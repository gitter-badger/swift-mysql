import Foundation

public func ==(lhs: MySQLQueryBuilder, rhs: MySQLQueryBuilder) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

public class MySQLQueryBuilder: Equatable {
  var selectStatement: String?
  var insertStatement:String?
  var updateStatement:String?
  var whereStatement:String?

  /**
    select sets the select statement part of the query

    - Parameters:
      - statement: select statement

    - Returns: returns self

    ```
      var builder = MySQLQueryBuilder()
        .select("SELECT 'abc', 'cde' FROM myTable")
    ```
  */
  public func select(statement: String) -> MySQLQueryBuilder {
    selectStatement = statement
    return self
  }

  /**
    select sets the select statement part of the query

    - Parameters:
      - fields: array of fields to return
      - table: name of the table to select from

    - Returns: returns self

    ```
      var builder = MySQLQueryBuilder()
        .select(["abc", "cde"], table: "myTable")
    ```
  */
  public func select(fields: [String], table: String) -> MySQLQueryBuilder {
    selectStatement = createSelectStatement(fields, table: table)
    return self
  }

  /**
    insert sets the insert statement part of the query

    - Parameters:
      - data: dictionary containing the data to be inserted
      - table: table to insert data into

    - Returns: returns self

    ```
      var builder = MySQLQueryBuilder()
        .insert(["abc": "cde"], table: "myTable")
    ```
  */
  public func insert(data: MySQLRow, table: String) -> MySQLQueryBuilder {
    insertStatement = createInsertStatement(data, table: table)
    return self
  }

  /**
    update sets the update statement part of the query

    - Parameters:
      - data: dictionary containing the data to be inserted
      - table: table to insert data into

    - Returns: returns self

    ```
      var builder = MySQLQueryBuilder()
        .select(["abc": "cde"], table: "myTable")
    ```
  */
  public func update(data: MySQLRow, table: String) -> MySQLQueryBuilder {
    updateStatement = createUpdateStatement(data, table: table)

    return self
  }

  /**
    wheres sets the where statement part of the query, escapting the parameters
    to secure against SQL injection

    - Parameters:
      - statement: where clause to filter data by
      - parameters: list of parameters corresponding to the statement

    - Returns: returns self

    ```
      var builder = MySQLQueryBuilder()
        .select("SELECT * FROM MyTABLE")
        .wheres("WHERE abc = ? and bcd = ?", abcValue, bcdValue)
    ```
  */
  public func wheres(statement: String, parameters: String...) -> MySQLQueryBuilder {
    var i = 0
    var w = ""

    for char in statement.characters {
      if char == "?" {
        w += "'\(parameters[i])'"
        i += 1
      } else {
        w += String(char)
      }
    }

    whereStatement = w
    return self
  }

  /**
    build compiles all data and returns the SQL statement for execution

    - Returns: SQL Statement
  */
  public func build() -> String {
    var query = ""

    if selectStatement != nil {
      query += "\(selectStatement!) "
    }

    if insertStatement != nil {
      query += insertStatement!
    }

    if updateStatement != nil {
      query += "\(updateStatement!) "
    }

    if whereStatement != nil {
      query += whereStatement!
    }

    return query.trimChar(" ")
  }

  private func createSelectStatement(fields: [String], table: String) -> String {
    var statement = "SELECT "

    for field in fields {
      statement += "\(field), "
    }
    statement = statement.trimChar(" ")
    statement = statement.trimChar(",")
    statement += " FROM \(table)"

    return statement
  }

  private func createInsertStatement(data: MySQLRow, table: String) -> String {
    var statement = "INSERT INTO \(table) ("

    for (key, _) in data {
      statement += "'\(key)',"
    }
    statement = statement.trimChar(",")

    statement += ") VALUES ("

    for (_, value) in data {
      statement += "'\(value)',"
    }
    statement = statement.trimChar(",")

    statement += ")"

    return statement
  }

  private func createUpdateStatement(data: MySQLRow, table: String) -> String {
    var statement = "UPDATE \(table) SET "

    for (key, value) in data {
      statement += "\(key)='\(value)', "
    }
    statement = statement.trimChar(" ")
    statement = statement.trimChar(",")

    return statement
  }
}

extension String {
  public func trimChar(character: Character) -> String {
    if self[self.endIndex.predecessor()] == character {
      var chars = Array(self.characters)
      chars.removeLast()
      return String(chars)
    } else {
      return self
    }
  }
}
