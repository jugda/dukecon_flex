<%

    Set as3Imports = new TreeSet();

    for (jImport in jClass.imports) {
        if (jImport.as3Type.hasPackage()) {
            // BlazeDS uses ArrayCollections instead of ListCollectionVies
            if(jImport.as3Type.qualifiedName == "mx.collections.ListCollectionView") {
            }
            // BlazeDS uses Object instead of IMap for communicating Maps.
            // As Object needs no import, simply omit the import.
            else if(jImport.as3Type.qualifiedName == "org.granite.collections.IMap") {
            }
            // We don't need imports of the same package.
            else {
                if(jImport.as3Type.packageName != jClass.as3Type.packageName) {
                    as3Imports.add(jImport.as3Type.qualifiedName);
                }
            }
        }
    }

%>/**
 * Generated by Gas3 v${gVersion} (Granite Data Services).
 *
 * WARNING: DO NOT CHANGE THIS FILE. IT MAY BE OVERRIDDEN EACH TIME YOU USE
 * THE GENERATOR. CHANGE INSTEAD THE INHERITED CLASS (${jClass.as3Type.name}.as).
 */

package ${jClass.as3Type.packageName} {

    import flash.data.SQLConnection;
    import flash.data.SQLStatement;
    import flash.data.SQLResult;
    import flash.errors.SQLError;

    import mx.collections.ArrayCollection;

<%
///////////////////////////////////////////////////////////////////////////////
// Write Import Statements.

    for (as3Import in as3Imports) {%>
    import ${as3Import};<%
    }

///////////////////////////////////////////////////////////////////////////////
// Write Class Declaration.%>

    [Bindable]
    public class ${jClass.as3Type.name}Base<%

        if (jClass.hasSuperclass()) {
            %> extends ${jClass.superclass.as3Type.name}<%
        }

        boolean implementsWritten = false;
        for (jInterface in jClass.interfaces) {
            if (!implementsWritten) {
                %> implements ${jInterface.as3Type.name}<%

                implementsWritten = true;
            } else {
                %>, ${jInterface.as3Type.name}<%
            }
        }
    %> {

        public function ${jClass.as3Type.name}Base(obj:Object = null) {
            if(obj) {<% for (jProperty in jClass.properties) {
                if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonFormat)) {%>
                if(obj.${jProperty.name} is Date) {
                    this.${jProperty.name} = obj.${jProperty.name} as Date;
                } else {
                    this.${jProperty.name} = isoToDate(obj.${jProperty.name});
                }<%
                } else if(jProperty.name == "order") { %>
                this.order = obj._order;
                <%
                } else if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonIdentityReference) &&
                        jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonProperty)) { %>
                this.${jProperty.getAnnotation(com.fasterxml.jackson.annotation.JsonProperty).value()} = obj.${jProperty.getAnnotation(com.fasterxml.jackson.annotation.JsonProperty).value()};
                <%
                } else if("mx.collections.ListCollectionView".equals(jProperty.as3Type.qualifiedName)) { %>
                if(obj.${jProperty.name}) {
                    this.${jProperty.name} = [];
                    for each(var ${jProperty.name}Obj:Object in obj.${jProperty.name}) {
                        var ${jProperty.name}El:${jProperty.genericTypes[0].name} = new ${jProperty.genericTypes[0].name}(${jProperty.name}Obj);
                        this.${jProperty.name}.push(${jProperty.name}El);
                    }
                }<%
                } else if("org.granite.collections.IMap".equals(jProperty.as3Type.qualifiedName)) { %>
                if(obj.${jProperty.name}) {
                    this.${jProperty.name} = {};
                    for(var ${jProperty.name}Key:String in obj.${jProperty.name}) {
                        var ${jProperty.name}Value:String = obj.${jProperty.name}[${jProperty.name}Key];
                        this.${jProperty.name}[${jProperty.name}Key] = ${jProperty.name}Value;
                    }
                }<%
                } else { %>
                if(obj.${jProperty.name}) {
                    this.${jProperty.name} = new ${jProperty.as3Type.name}(obj.${jProperty.name});
                }<%
                }
            }%>
            }
        }

        private function isoToDate(value:String):Date {
            var matches:Array = value.match(/(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d)/);
            var date:Date = new Date();
            date.setUTCFullYear(int(matches[1]), int(matches[2]) - 1, int(matches[3]));
            date.setUTCHours(int(matches[4]), int(matches[5]), 0, 0);
            return date;
        }
<%


    ///////////////////////////////////////////////////////////////////////////
    // Write Private Fields.

    for (jProperty in jClass.properties) {
        if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonFormat)) { %>
        private var _${jProperty.name}:Date;<%
        } else if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonIdentityReference) &&
            jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonProperty)) { %>
        private var _${jProperty.getAnnotation(com.fasterxml.jackson.annotation.JsonProperty).value()}:String;<%
        } else if(jProperty.as3Type.name == "ListCollectionView") { %>
        private var _${jProperty.name}:Array;<%
        } else if(jProperty.as3Type.name == "IMap") { %>
        private var _${jProperty.name}:Object;<%
        } else { %>
        private var _${jProperty.name}:${jProperty.as3Type.name};<%
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write Public Getter/Setter.

    for (jProperty in jClass.properties) {
        if (jProperty.readable || jProperty.writable) {%>
<%
            if (jProperty.writable) {
                if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonFormat)) {%>
        public function set ${jProperty.name}(value:Date):void {
            _${jProperty.name} = value;
        }<%
                } else if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonIdentityReference) &&
                        jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonProperty)) {%>
        public function set ${jProperty.getAnnotation(com.fasterxml.jackson.annotation.JsonProperty).value()}(value:String):void {
            _${jProperty.getAnnotation(com.fasterxml.jackson.annotation.JsonProperty).value()} = value;
        }<%
                } else if(jProperty.as3Type.name == "ListCollectionView") {%>
        public function set ${jProperty.name}(value:Array):void {
            _${jProperty.name} = value;
        }<%
                } else if(jProperty.as3Type.name == "IMap") {%>
        public function set ${jProperty.name}(value:Object):void {
            _${jProperty.name} = value;
        }<%
                } else {%>
        public function set ${jProperty.name}(value:${jProperty.as3Type.name}):void {
            _${jProperty.name} = value;
        }<%
                }
            }
            if (jProperty.readable) {
                if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonFormat)) {%>
        public function get ${jProperty.name}():Date {
            return _${jProperty.name};
        }<%
            } else if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonIdentityReference) &&
                    jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonProperty)) {%>
        public function get ${jProperty.getAnnotation(com.fasterxml.jackson.annotation.JsonProperty).value()}():String {
            return _${jProperty.getAnnotation(com.fasterxml.jackson.annotation.JsonProperty).value()};
        }<%
            } else if(jProperty.as3Type.name == "ListCollectionView") {%>
        public function get ${jProperty.name}():Array {
            return _${jProperty.name};
        }<%
                } else if(jProperty.as3Type.name == "IMap") {%>
        public function get ${jProperty.name}():Object {
            return _${jProperty.name};
        }<%
                } else {%>
        public function get ${jProperty.name}():${jProperty.as3Type.name} {
            return _${jProperty.name};
        }<%
                }
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write Public Getters/Setters for Implemented Interfaces.

    if (jClass.hasInterfaces()) {
        for (jProperty in jClass.interfacesProperties) {
            if (jProperty.readable || jProperty.writable) {%>
<%
                if (jProperty.writable) {%>
        public function set ${jProperty.name}(value:${jProperty.as3Type.name}):void {
        }<%
                }
                if (jProperty.readable) {%>
        public function get ${jProperty.name}():${jProperty.as3Type.name} {
            return ${jProperty.as3Type.nullValue};
        }<%
                }
            }
        }
    }%>

        public static function createTable(conn:SQLConnection):void {
            var createTableStatement:SQLStatement = new SQLStatement();
            createTableStatement.sqlConnection = conn;
            createTableStatement.text = "CREATE TABLE IF NOT EXISTS ${jClass.as3Type.name} (<%
            boolean firstEntryWritten = false;
            for (jProperty in jClass.properties) { if(firstEntryWritten) {%>, <% } else { firstEntryWritten = true; }
    if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonFormat)) {%>${jProperty.name} DATE<%} else if(jProperty.name == "order") {%>_order TEXT<%} else if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonIdentityReference) &&
        jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonProperty)) {%>${jProperty.getAnnotation(com.fasterxml.jackson.annotation.JsonProperty).value()} TEXT<%} else {%>${jProperty.name} TEXT<%}}%>)";
            try {
                createTableStatement.execute();
            } catch(initError:SQLError) {
                throw new Error("Error creating table '${jClass.as3Type.name}': " + initError.message);
            }
        }

        public static function clearTable(conn:SQLConnection):void {
            var clearTableStatement:SQLStatement = new SQLStatement();
            clearTableStatement.sqlConnection = conn;
            clearTableStatement.text = "DELETE FROM ${jClass.as3Type.name}";
            try {
                clearTableStatement.execute();
            } catch(initError:SQLError) {
                throw new Error("Error clearing table '${jClass.as3Type.name}': " + initError.message);
            }
        }

        public static function count(conn:SQLConnection):Number {
            var countStatement:SQLStatement = new SQLStatement();
            countStatement.sqlConnection = conn;
            countStatement.text = "SELECT COUNT(*) FROM ${jClass.as3Type.name}";
            try {
                countStatement.execute();
                var sqlResult:SQLResult = countStatement.getResult();
                return Number(sqlResult.data[0]["COUNT(*)"]);
            } catch(initError:SQLError) {
                throw new Error("Error counting the rows of table '${jClass.as3Type.name}': " + initError.message);
            }
            return 0;
        }

        public static function select(conn:SQLConnection, whereClause:String = null):ArrayCollection {
            var result:ArrayCollection = new ArrayCollection();
            var selectStatement:SQLStatement = new SQLStatement();
            selectStatement.sqlConnection = conn;
            selectStatement.text = "SELECT * FROM ${jClass.as3Type.name}";
            if(whereClause) {
                selectStatement.text += " WHERE " + whereClause;
            }
            try {
                selectStatement.execute();
                var sqlResult:SQLResult = selectStatement.getResult();
                for each(var obj:Object in sqlResult.data) {
                    var item:${jClass.as3Type.name} = new ${jClass.as3Type.name}(obj);
                    result.addItem(item);
                }
            } catch(initError:SQLError) {
                throw new Error("Error selecting records from table '${jClass.as3Type.name}': " + initError.message);
            }
            return result;
        }

        public static function selectById(conn:SQLConnection, id:String):${jClass.as3Type.name} {
            var selectStatement:SQLStatement = new SQLStatement();
            selectStatement.sqlConnection = conn;
            selectStatement.text = "SELECT * FROM ${jClass.as3Type.name} WHERE id = '" + id + "'";
            try {
                selectStatement.execute();
                var sqlResult:SQLResult = selectStatement.getResult();
                for each(var obj:Object in sqlResult.data) {
                    var item:${jClass.as3Type.name} = new ${jClass.as3Type.name}(obj);
                    return item;
                }
            } catch(initError:SQLError) {
                throw new Error("Error selecting records from table '${jClass.as3Type.name}': " + initError.message);
            }
            return null;
        }

        public function persist(conn:SQLConnection):void {
            var insertStatement:SQLStatement = new SQLStatement();
            insertStatement.sqlConnection = conn;
            insertStatement.text = "INSERT INTO ${jClass.as3Type.name} (<%
            firstEntryWritten = false;
            for (jProperty in jClass.properties) { if(firstEntryWritten) {%>,<% } else { firstEntryWritten = true; }
    if(jProperty.name == "order") {%> _order<%}
    else if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonIdentityReference) &&
        jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonProperty)) {
        %> ${jProperty.getAnnotation(com.fasterxml.jackson.annotation.JsonProperty).value()}<%
    } else {
        %> ${jProperty.name}<%}
    }%>) VALUES (<%
            firstEntryWritten = false;
            for (jProperty in jClass.properties) { if(firstEntryWritten) {%>, <% } else { firstEntryWritten = true; }
    if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonIdentityReference) &&
            jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonProperty)) {
        %>:${jProperty.getAnnotation(com.fasterxml.jackson.annotation.JsonProperty).value()}<%
    } else {
        %>:${jProperty.name}<%}
    }%>)";
            <%for (jProperty in jClass.properties) {
                if(jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonIdentityReference) &&
                        jProperty.isAnnotationPresent(com.fasterxml.jackson.annotation.JsonProperty)) { %>
            insertStatement.parameters[":${jProperty.getAnnotation(com.fasterxml.jackson.annotation.JsonProperty).value()}"] = ${jProperty.getAnnotation(com.fasterxml.jackson.annotation.JsonProperty).value()};<%
                } else { %>
            insertStatement.parameters[":${jProperty.name}"] = ${jProperty.name};<%
                }
            } %>
            try {
                insertStatement.execute();
            } catch(initError:SQLError) {
                throw new Error("Error inserting record into table '${jClass.as3Type.name}': " + initError.message);
            }
        }
    }
}