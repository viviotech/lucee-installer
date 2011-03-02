//
// Add/Remove/Enumerate global/site ISAPI Filters
//
// Origin : http://blogs.msdn.com/David.Wang
// Version: March 2 2006
//
// Documentation:
// http://blogs.msdn.com/david.wang/archive/2006/03/02/HOWTO_Add_and_Remove_an_ISAPI_Filter_using_JScript.aspx
// 
// Thank you David!
// 

String.prototype.EqualsIgnoreCase = EqualsIgnoreCase;

var ERROR_SUCCESS = 0;
var ERROR_INVALID_PARAMETER = 87;
var FILTER_OP_ADD = 1;
var FILTER_OP_REMOVE = 2;
var FILTER_OP_QUERY = 3;
var FILTER_ORDER_LAST = -1;

var CRLF = "\r\n";
var strHelp;
strHelp = "" +
    "Add/Remove/Enumerate global/site ISAPI Filters" + CRLF +
    CRLF +
    WScript.ScriptName + " [[-Parameter:Value]...]" + CRLF +
    CRLF +
    "Where:" + CRLF +
    "    Parameter  Value" + CRLF +
    "    ---------  -------------------------------------------" + CRLF +
    "    Name       Name of Filter to manipulate" + CRLF +
    "    DLL        Full DLL Pathname of Filter" + CRLF +
    "    Action     Add, Remove, or Query (Default is Query)" + CRLF +
    "    Server     Server to target (Default is localhost)" + CRLF +
    "    Site       Filter metapath - W3SVC for global," + CRLF +
    "               W3SVC/# for Site ID # (Default is W3SVC)" + CRLF +
    "    Index      [Add] Index to add filter (Default is LAST)" + CRLF +
    "";


var nReturnValue;
var nCommand;
var strServer;
var strMDPath;
var nLocation;
var strFilterName;
var strFilterPath;

nCommand = FILTER_OP_QUERY;
strServer = "localhost";
strMDPath = "W3SVC"
nLocation = FILTER_ORDER_LAST;

if ( ParseCommandline() &&
     ValidateOptions() )
{
    if ( nCommand == FILTER_OP_ADD )
    {
        nReturnValue = AddFilter( TrimSlashes( strMDPath ),
                                  nLocation,
                                  strFilterName,
                                  strFilterPath );
    }
    else if ( nCommand == FILTER_OP_REMOVE )
    {
        nReturnValue = RemoveFilter( TrimSlashes( strMDPath ),
                                     strFilterName );
    }
    else if ( nCommand == FILTER_OP_QUERY )
    {
        nReturnValue = QueryFilters( TrimSlashes( strMDPath ),
                                     strFilterName );
    }
    else
    {
        LogEcho( strHelp );
        nReturnValue = ERROR_INVALID_PARAMETER;
    }
}
else
{
    LogEcho( strHelp );
    nReturnValue = ERROR_INVALID_PARAMETER;
}

WScript.Quit( nReturnValue );

function ParseCommandline()
{
    var re = new RegExp( "-([^:]+):(.+)" );
    var arr;

    for ( var i = 0; i < WScript.Arguments.length; i++ )
    {
        arr = re.exec( WScript.Arguments( i ) );
        if ( arr == null )
        {
            LogEcho( "Invalid parameter " + WScript.Arguments( i ) )
            return false;
        }
        else
        {
            switch ( arr[ 1 ].toUpperCase() )
            {
                case "NAME":
                    strFilterName = arr[ 2 ];
                    break;
                case "DLL":
                    strFilterPath = arr[ 2 ];
                    break;
                case "ACTION":
                    nCommand =
                        arr[ 2 ].EqualsIgnoreCase( "ADD" ) ?
                            FILTER_OP_ADD :
                        arr[ 2 ].EqualsIgnoreCase( "REMOVE" ) ?
                            FILTER_OP_REMOVE :
                        arr[ 2 ].EqualsIgnoreCase( "QUERY" ) ?
                            FILTER_OP_QUERY :
                        nCommand;
                    break;
                case "SERVER":
                    strServer = arr[ 2 ];
                    break;
                case "SITE":
                    strMDPath = arr[ 2 ];
                    break;
                case "INDEX":
                    nLocation = parseInt( arr[ 2 ] );
                    break;
                default:
                    LogEcho( "Unknown parameter " + arr[ 1 ] );
                    return false;
            }
        }
    }

    return true;
}

function ValidateOptions()
{
    if ( nCommand == FILTER_OP_ADD &&
         ( strFilterName == null ||
           strFilterPath == null ) )
    {
        LogEcho( "Adding Filter requires the -Name and -DLL parameters." );
        return false;
    }

    if ( nCommand == FILTER_OP_REMOVE &&
         strFilterName == null )
    {
        LogEcho( "Removing Filter requires the -Name parameter" );
        return false;
    }

    return true;
}

function AddFilter(
    strMDPath,
    nLocation,
    strFilterName,
    strFilterPath
)
{
    var objFilters;
    var objFilter;
    var strFilterLoadOrder
    var strDelimiter;
    var i;
    var nCursor;
    var nOffset;

    try
    {
        objFilters = GetObject( "IIS://" + strServer + "/" +
                                strMDPath + "/Filters" );
    }
    catch ( e )
    {
        //
        // Failed to retrieve the Filters node for some reason.
        // Try to create it.
        //
        try
        {
            objFilters = GetObject( "IIS://" + strServer + "/" +
                                    strMDPath ).Create( "IIsFilters",
                                                        "Filters" );
            objFilters.SetInfo();
        }
        catch ( e2 )
        {
            //
            // Failed to retrieve and create the Filters node.
            // Bail.
            //
            LogEcho( FormatErrorString( e ) + CRLF +
                     "Failed to add Filter " + strFilterName +
                     " because Filters node cannot be created." );
            return e.number;
        }
    }

    try
    {
        //
        // Create the actual Filters node
        // Configure the FilterPath to point to DLL pathname
        //
        objFilter = objFilters.Create( "IIsFilter", strFilterName );
        objFilter.FilterPath = strFilterPath;
        //
        // On IIS6, if FilterEnableCache is not explicitly set to true,
        // Kernel Response Caching will be disabled for any request
        // that this filter runs on
        //
        //objFilter.FilterEnableCache = true;
        objFilter.SetInfo();
    }
    catch ( e )
    {
        if ( e.number == -2147024713 )
        {
            LogEcho( "Filter " + strFilterName + " already exists." );
        }
        else
        {
            LogEcho( FormatErrorString( e ) );
        }

        return e.number;
    }

    try
    {
        //
        // Update FilterLoadOrder so that IIS knows to load the filter
        //
        strFilterLoadOrder = objFilters.FilterLoadOrder;

        //
        // The Algorithm:
        // - Tokenize FilterLoadOrder on "," and first token index is 0.
        // - If token index matches desired index, insert filter at that
        // index.
        // - If desired index is -1 or desired index > token index, then
        // insert filter at the end.
        //
        strDelimiter = ( strFilterLoadOrder == "" ) ? "" : ",";
        i = 0;
        nCursor = 0;
        nOffset = 0;

        while ( nCursor != -1 )
        {
            if ( i == nLocation )
            {
                objFilters.FilterLoadOrder =
                    strFilterLoadOrder.substring( 0, nOffset ) +
                    strFilterName + strDelimiter +
                    strFilterLoadOrder.substr( nOffset );
                break;
            }

            nCursor = strFilterLoadOrder.substr( nOffset ).indexOf( "," );
            nOffset += nCursor + 1;
            i++;
        }

        if ( nLocation == FILTER_ORDER_LAST ||
             nCursor == -1 && i <= nLocation )
        {
            objFilters.FilterLoadOrder =
                strFilterLoadOrder + strDelimiter +
                strFilterName;
        }

        objFilters.SetInfo();
        LogEcho( "Added Filter " + strFilterName + CRLF +
                 strMDPath + "/Filters/FilterLoadOrder = " +
                 objFilters.FilterLoadOrder );
        return ERROR_SUCCESS;
    }
    catch ( e )
    {
        LogEcho( FormatErrorString( e ) );
        return e.number;
    }
}

function RemoveFilter(
    strMDPath,
    strFilterName
)
{
    var objFilters;
    var strFilterLoadOrder;
    var strNewFilterLoadOrder;

    try
    {
        objFilters = GetObject( "IIS://" + strServer + "/" +
                                strMDPath + "/Filters" );
    }
    catch ( e )
    {
        //
        // Failed to retrieve the Filters node for some reason.
        // Cannot delete filters
        //
        LogEcho( FormatErrorString( e ) + CRLF +
                 "Failed to remove Filter " + strFilterName +
                 " because Filters node cannot be read." );
        return e.number;
    }

    try
    {
        strFilterLoadOrder = objFilters.FilterLoadOrder;
        strNewFilterLoadOrder = "";

        nOffset = 0;
        nCursor = strFilterLoadOrder.substr( nOffset ).indexOf( "," );
        while ( nCursor != -1 )
        {
            if ( !strFilterName.EqualsIgnoreCase(
                 strFilterLoadOrder.substr( nOffset, nCursor ) ) )
            {
                strNewFilterLoadOrder +=
                    strFilterLoadOrder.substr( nOffset, nCursor + 1 );
            }

            nOffset += nCursor + 1;
            nCursor = strFilterLoadOrder.substr( nOffset ).indexOf( "," );
        }

        if ( !strFilterName.EqualsIgnoreCase(
             strFilterLoadOrder.substr( nOffset ) ) )
        {
            strNewFilterLoadOrder += strFilterLoadOrder.substr( nOffset );
        }

        objFilters.FilterLoadOrder = TrimCommas( strNewFilterLoadOrder );
        objFilters.SetInfo();
    }
    catch ( e )
    {
        LogEcho( FormatErrorString( e ) );
        return e.number;
    }

    try
    {
        objFilters.Delete( "IIsFilter", strFilterName );
        LogEcho( "Removed Filter " + strFilterName + CRLF +
                 strMDPath + "/Filters/FilterLoadOrder = " +
                 objFilters.FilterLoadOrder );
        return ERROR_SUCCESS;
    }
    catch ( e )
    {
        if ( e.number == -2147024893 )
        {
            LogEcho( "Filter " + strFilterName + " does not exist." );
        }
        else
        {
            LogEcho( FormatErrorString( e ) );
        }

        return e.number;
    }
}

function QueryFilters(
    strMDPath,
    strFilterName
)
{
    //
    // JScript version of the original script from
    // http://blogs.msdn.com/david.wang/archive/2006/02/11/HOWTO_Retrieve_and_Interpret_ISAPI_Filter_Status.aspx
    //
    // Adapted to query filter status
    //
    // Format of ISAPI Filters stored in IIS metabase
    //
    // IIS://localhost/W3SVC/Filters = Global Filters
    // IIS://localhost/W3SVC/#/Filters = Site Filters
    //
    // .../Filters/FilterLoadOrder = Order of Filters to load
    // .../Filters/Filter1
    //    .FilterPath = DLL location of Filter1
    //    .FilterState = Status of last filter load
    //    .FilterDescription = description set by filter
    //    .FilterFlags = events registered by filter
    //    .Win32Error = (IIS6 Only) Win32 Errorcode of last load
    //    .FilterEnableCache = (IIS6 Only) Hint that filter is cache friendly
    //
    // TODO:
    // Warn about Filters not in FilterLoadOrder
    //
    //

    var objFilters;
    var arr, i;

    if ( strFilterName != null )
    {
        return QueryFilter( strFilterName );
    }

    //
    // Check if there is a Filters node
    //
    try
    {
        objFilters = GetObject( "IIS://" + strServer + "/" +
                                strMDPath + "/Filters" );
    }
    catch ( e )
    {
        LogEcho( Site2String( strMDPath ) + " on server " +
                 strServer + " were not found." );
        return e.number;
    }

    arr = objFilters.FilterLoadOrder.split( "," );
    LogEcho( Site2String( strMDPath ) + " on server " + strServer );

    for ( i = 0; i < arr.length; i++ )
    {
        QueryFilter( arr[ i ] )
    }

    function QueryFilter(
        strFilterName
    )
    {
        var objFilter;

        try
        {
            objFilter = GetObject( "IIS://" + strServer + "/" +
                                   strMDPath + "/Filters/" + strFilterName );
            LogEcho(
                "+ Filter " + strFilterName + " - " +
                "\"" + objFilter.FilterDescription + "\"" + CRLF +
                "  Filter File = " + objFilter.FilterPath + CRLF +
                "  " + FilterState2String( objFilter.FilterState ) +
                CRLF +
                "  " + FilterFlags2String( objFilter.FilterFlags ) +
                "" );
        }
        catch ( e )
        {
            LogEcho( "+ Filter " + strFilterName + " does not exist!" + CRLF +
                     "  " + FormatErrorString( e ) );
        }
    }

    function Site2String(
        Site
    )
    {
        if ( Site.EqualsIgnoreCase( "W3SVC" ) )
        {
            return "Global Filters";
        }
        else
        {
            return "Filters for website " + Site;
        }
    }

    function FilterState2String(
        FilterState
    )
    {
        var strRetVal = "FilterState = " & FilterState;

        switch ( FilterState )
        {
            case 1:
                strRetVal += " (Loaded OK)";
                break;
            default:
                strRetVal += " (**ERROR**)";
                break;
        }

        return strRetVal;
    }

    function FilterFlags2String(
        FilterFlags
    )
    {
        var strRetVal = "FilterFlags = " + FilterFlags + CRLF;
        strRetVal += "  FilterEvent =";

        if ( FilterFlags & 32768 )      strRetVal += " ReadRawData";
        if ( FilterFlags & 16384 )      strRetVal += " PreprocHeaders";
        if ( FilterFlags & 8192 )       strRetVal += " Authentication";
        if ( FilterFlags & 4096 )       strRetVal += " UrlMap";
        if ( FilterFlags & 2048 )       strRetVal += " AccessDenied";
        if ( FilterFlags & 64 )         strRetVal += " SendResponse";
        if ( FilterFlags & 1024 )       strRetVal += " SendRawData";
        if ( FilterFlags & 512 )        strRetVal += " Log";
        if ( FilterFlags & 128 )        strRetVal += " EndOfRequest";
        if ( FilterFlags & 256 )        strRetVal += " EndOfNetSession";
        if ( FilterFlags & 67108864 )   strRetVal += " AuthComplete";
        strRetVal += CRLF;
        if ( FilterFlags & 1 )
        {
            strRetVal += "    Listens on SecurePort" + CRLF;
        }
        if ( FilterFlags & 2 )
        {
            strRetVal += "    Listens on NonSecurePort" + CRLF;
        }
        if ( FilterFlags & 524288 )
        {
            strRetVal += "    Runs as High Priority" + CRLF;
        }
        if ( FilterFlags & 262144 )
        {
            strRetVal += "    Runs as Medium" + CRLF;
        }
        if ( FilterFlags & 131072 )
        {
            strRetVal += "    Runs as Low Priority" + CRLF;
        }

        return strRetVal;
    }

    return ERROR_SUCCESS;
}

function TrimSlashes(
    strInput
)
{
    return strInput.replace( new RegExp( "^/+|/+$", "g" ), "" );
}

function TrimCommas(
    strInput
)
{
    return strInput.replace( new RegExp( "^,+|,+$", "g" ), "" );
}

function LogEcho(
    strText
)
{
    WScript.Echo( strText );
}

function EqualsIgnoreCase(
    strOther
)
{
    return this.toString().toUpperCase() ==
           strOther.toString().toUpperCase();
}

function Int32ToHRESULT( num ) {
    if ( num < 0 )
    {
        return "0x" + new Number( 0x100000000 + num ).toString( 16 );
    }
    else
    {
        return "0x" + num.toString( 16 );
    }
}

function FormatErrorString(
    objError
)
{
    return "(" + Int32ToHRESULT( objError.number) + ")" + ": " +
           objError.description;
}

