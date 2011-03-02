'
' Allows append/insert/remove of specific elements from an IIS "List" type node
' i.e. ScriptMap, HttpError, ServerBindings
'
' Origin : http://blogs.msdn.com/David.Wang/archive/2004/12/02/273681.aspx
' Version: December 1 2004
'
Option Explicit
On Error Resume Next

const ERROR_SUCCESS             = 0
const ERROR_PATH_NOT_FOUND      = 3
const ERROR_INVALID_PARAMETER   = 87
const LIST_OP_FIRST             = "FIRST"
const LIST_OP_LAST              = "LAST"
const LIST_OPTION_REPLACE       = 0
const LIST_OPTION_INSERT        = 1
const LIST_OPTION_REMOVE        = 2
const LIST_OPTION_ALL           = 4
const LIST_OPTION_RECURSE       = 8

Dim CRLF
CRLF = CHR(13) & CHR(10)
Dim strHelp
strHelp = "Edit/Replace IIS metabase LIST properties" & CRLF &_
          CRLF &_
          WScript.ScriptName & " PropertyPath ExistValue NewValue [Options]" & CRLF &_
          CRLF &_
          "Where:" & CRLF &_
          "    PropertyPath IIS metabase property path whose data type is LIST." & CRLF &_
          "                 i.e. W3SVC/ScriptMaps, W3SVC/HttpErrors" & CRLF &_
          "    ExistValue   Value to case-insensitive literal match against existing" & CRLF &_
          "                 LIST elements." & CRLF &_
          "        FIRST    - matches the first LIST element." & CRLF &_
          "        LAST     - matches the last LIST element." & CRLF &_
          "    NewValue     New value that replaces the matched the LIST element." & CRLF &_
          "Options:" & CRLF &_
          "    /INSERT      Insert  before LIST element matching ." & CRLF &_
          "    /REMOVE      Remove LIST element matching ." & CRLF &_
          "    /ALL         Operate on ALL matching . Default is first match." & CRLF &_
          "    /REGEXP      Use  as RegExp to match. Default is literal." & CRLF &_
          "    /RECURSE     Recursively perform the operation underneath ." & CRLF &_
          "    /VERBOSE     Give more status/output." & CRLF &_
          "    /COMMIT      Actually perform changes. Default only shows." & CRLF &_
          ""

dim Debug
Debug = true
dim Verbose
Verbose = false
dim reMatch
reMatch = false

Dim strServer
Dim strNamespace
Dim strSchemaNamespace
Dim strNodeSyntax
Dim objNode

Dim nOperationType
Dim strNormalizedPath
Dim strPropertyPath
Dim strPropertyName
Dim strPropertyExistValue
Dim strPropertyNewValue

Dim i,j

'
' Start of script
'
strServer = "localhost"
strNamespace = "IIS://" & strServer
strSchemaNamespace = strNamespace & "/" & "Schema"

'
' Parse the commandline
'
If WScript.Arguments.Count < 3 Then
    Err.Number = ERROR_INVALID_PARAMETER
    HandleError "Insufficient number of arguments." & CRLF &_
                CRLF &_
                strHelp &_
                ""
End If

nOperationType = LIST_OPTION_REPLACE

For i = 0 To WScript.Arguments.Count - 1
    Select Case UCase( WScript.Arguments( i ) )
        Case "/INSERT"
            nOperationType = nOperationType Or LIST_OPTION_INSERT
        Case "/REMOVE"
            nOperationType = nOperationType Or LIST_OPTION_REMOVE
        Case "/ALL"
            nOperationType = nOperationType Or LIST_OPTION_ALL
        Case "/RECURSE"
            nOperationType = nOperationType Or LIST_OPTION_RECURSE
        Case "/COMMIT"
            Debug = false
        Case "/VERBOSE"
            Verbose = true
        Case "/REGEXP"
            reMatch = true
        Case Else
            If ( i = 0 ) Then
                '
                ' Split out PropertyName and its ParentPath from PropertyPath
                '
                Err.Clear
                strNormalizedPath = NormalizePath( WScript.Arguments( 0 ) )
                HandleError "Failed to normalize PropertyPath."

                j = InstrRev( strNormalizedPath, "/", -1, 0 )

                If ( j = 0 Or j = 1 ) Then
                    Err.Number = ERROR_PATH_NOT_FOUND
                    HandleError "Invalid PropertyPath."
                End If

                Err.Clear
                strPropertyPath = NormalizePath( Mid( strNormalizedPath, 1, j - 1 ) )
                HandleError "Failed to retrieve/normalize PropertyPath."

                Err.Clear
                strPropertyName = NormalizePath( Mid( strNormalizedPath, j + 1 ) )
                HandleError "Failed to retrieve/normalize PropertyName."
            ElseIf ( i = 1 ) Then
                '
                ' The existing match value
                '
                strPropertyExistValue = Replace( UCase( WScript.Arguments( 1 ) ), "``", """" )
            ElseIf ( i = 2 ) Then
                '
                ' The new replace value
                '
                strPropertyNewValue = Replace( WScript.Arguments( 2 ), "``", """" )
            Else
                Err.Number = ERROR_INVALID_PARAMETER
                HandleError "Unknown parameter " & WScript.Arguments( i ) & CRLF &_
                            CRLF &_
                            strHelp &_
                            ""
            End If
    End Select
Next

LogVerbose "OpType       = " & nOperationType
LogVerbose "PropertyPath = " & strPropertyPath
LogVerbose "PropertyName = " & strPropertyName
LogVerbose "ExistValue   = " & strPropertyExistValue
LogVerbose "NewValue     = " & strPropertyNewValue

'
' Check the data type for the given property
' If it is not LIST, do not process any further
'
Err.Clear
Set objNode = GetObject( strSchemaNamespace & "/" & strPropertyName )
HandleError "Cannot read schema for property " & strPropertyName
strNodeSyntax = UCase( objNode.Syntax )

LogVerbose "Syntax       = " & strNodeSyntax
LogVerbose ""

Select Case strNodeSyntax
    Case "LIST"
        '
        ' Finally, we are ready to do some real work
        '
        Err.Clear
        Err.Number = HandleListOps( nOperationType, strPropertyPath, strPropertyName, strPropertyExistValue, strPropertyNewValue, ( nOperationType And LIST_OPTION_RECURSE ) <> 0 )
        HandleError ""
    Case Else
        Err.Clear
        Err.Number = ERROR_PATH_NOT_FOUND
        HandleError "Cannot handle " & strPropertyPath & "/" & strPropertyName & " with type " & strNodeSyntax
End Select

'
' End of script
'

'
' Sub routines and functions
'
Sub HandleError( errorDescription )
    If ( Err.Number <> 0 ) Then
        If ( IsEmpty( errorDescription ) ) Then
            LogEcho Err.Description
        Else
            LogEcho errorDescription
        End If

        WScript.Quit Err.Number
    End If
End Sub

Function NormalizePath( strInput )
    '
    ' Replace all \ with /
    '
    strInput = Replace( strInput, "\", "/", 1, -1 )

    '
    ' Replace all // with /
    '
    Do
        strInput = Replace( strInput, "//", "/", 1, -1 )
    Loop While ( Instr( strInput, "//" ) <> 0 )

    '
    ' Removing leading and trailing /
    '
    If ( Left( strInput, 1 ) = "/" ) Then
        strInput = Right( strInput, Len( strInput ) - 1 )
    End If

    If ( Right( strInput, 1 ) = "/" ) Then
        strInput = Left( strInput, Len( strInput ) - 1 )
    End If

    NormalizePath = strInput
End Function

Function HandleListOps( OpType, strPropertyPath, strPropertyName, strPropertyExistValue, strPropertyNewValue, bRecurse )
    On Error Resume Next
    Dim objNode, objNodeAttribute
    Dim objList
    Dim objElement
    Dim objNewArray
    Dim PerformedOperation
    Dim Operation
    Dim re
    Dim reMatched
    Dim i, j

    Err.Clear
    Set objNode = GetObject( strNamespace & "/" & strPropertyPath )
    objList = objNode.Get( strPropertyName )

    If ( Err.Number <> 0 Or IsEmpty( objList ) ) Then
        LogEcho "Failed to retrieve " & strPropertyPath & "/" & strPropertyName
        HandleListOps = Err.Number
        Exit Function
    End If


    Err.Clear
    Set objNodeAttribute = objNode.GetPropertyAttribObj(strPropertyName)
    HandleError "Failed to retrieve Attributes for " & strPropertyPath & "/" & strPropertyName

    If ( objNodeAttribute.IsInherit = true ) Then
        LogEcho strPropertyPath & "/" & strPropertyName & " (Inherited)"

        If ( bRecurse = true ) Then
            LogEcho( "Ignoring inherited property for Recursive Modification" )
            Exit Function
        End If
    Else
        LogEcho strPropertyPath & "/" & strPropertyName
    End If


    '
    ' j is the count of elements in objNewArray
    ' So that we can resize it to the right size in the end
    '
    j = 0

    '
    ' Size objNewArray to maximum possible size up-front, later shrink it
    '
    Redim objNewArray( UBound( objList ) + UBound( objList ) + 1 )

    '
    ' PerformedOperation indicates whether something has matched and already
    ' operated upon, in this session.  Start with 'not yet' = 0
    '
    PerformedOperation = 0

    '
    ' Setup the RegExp match based on the existing value to search for
    '
    Set re = new RegExp
    re.Pattern = strPropertyExistValue
    re.IgnoreCase = true
    re.Global = true

    '
    ' Do this test outside of IF conditional because on error resume next
    ' turns off failures due to incorrect Pattern
    '
    Err.Clear
    reMatched = re.Test( objElement )
    If ( Err.Number <> 0 Or reMatch = false ) Then
        reMatched = false
    End If

    LogVerbose "Original:"

    For i = LBound( objList ) To UBound( objList )
        objElement = objList( i )
        'LogVerbose i & "(" & j & ")" & ": " & objElement

        If ( ( ( ( strPropertyExistValue = LIST_OP_FIRST ) And ( i = LBound( objList ) ) ) Or _
               ( ( strPropertyExistValue = LIST_OP_LAST  ) And ( i = UBound( objList ) ) ) Or _
               ( ( reMatch = false ) And ( Instr( UCase( objElement ), strPropertyExistValue ) > 0 ) ) Or _
               ( reMatched = true ) _
             ) _
             And _
             ( ( ( OpType And LIST_OPTION_ALL ) <> 0 ) Or ( PerformedOperation = 0 ) ) _
           ) Then
            Operation = "Replace "

            If ( ( OpType And LIST_OPTION_REMOVE ) <> 0 ) Then
                'Don't copy this element for deletion
                Operation = "Remove "
            Else
                objNewArray( j ) = strPropertyNewValue
                j = j + 1

                If ( ( OpType And LIST_OPTION_INSERT ) <> 0 ) Then
                    Operation = "Insert "
                    objNewArray( j ) = objElement
                    j = j + 1
                End If
            End If

            PerformedOperation = 1
        Else
            Operation = ""
            objNewArray( j ) = objElement
            j = j + 1
        End If

        LogVerbose Operation & objElement
    Next

    '
    ' Resize the final array to the correct size prior to SetInfo
    '
    ReDim Preserve objNewArray( j - 1 )

    LogVerbose "New:"

    For i = LBound( objNewArray ) To UBound( objNewArray )
        LogDebug i & ": " & objNewArray( i )
    Next

    If ( Debug = false ) Then
        If ( PerformedOperation = 1 ) Then
            Err.Clear
            objNode.Put strPropertyName, objNewArray
            objNode.SetInfo
            HandleError "Failed to SetInfo " & strPropertyPath & "/" & strPropertyName
            LogEcho "SUCCESS: Updated " & strPropertyPath & "/" & strPropertyName
        Else
            LogEcho "SUCCESS: Nothing to update"
        End If
    Else
        If ( PerformedOperation = 1 ) Then
            LogEcho "DEBUG: Matched. Did not SetInfo"
        Else
            LogEcho "SUCCESS: No Match. Did not SetInfo"
        End If
    End If

    If ( bRecurse = true ) Then
        For Each objElement In objNode
            LogEcho ""
            HandleListOps = HandleListOps( OpType, NormalizePath( Mid( objElement.AdsPath, Len( strNamespace ) + 1 ) ), strPropertyName, strPropertyExistValue, strPropertyNewValue, bRecurse )
        Next
    End If

    HandleListOps = 0
End Function

Sub LogEcho( str )
    WScript.Echo str
End Sub

Sub LogDebug( str )
    If ( Debug = true ) Then
        LogEcho str
    End If
End Sub

Sub LogVerbose( str )
    If ( Verbose = true ) Then
        LogEcho str
    End If
End Sub
