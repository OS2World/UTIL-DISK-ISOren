/*:VRX         Main
*/
/*  Main
*/
Main:

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

/*  Process the arguments.
    Get the parent window.
*/
    parse source . calledAs .
    parent = ""
    argCount = arg()
    argOff = 0
    if( calledAs \= "COMMAND" )then do
        if argCount >= 1 then do
            parent = arg(1)
            argCount = argCount - 1
            argOff = 1
        end
    end; else do
        call VROptions 'ImplicitNames'
        call VROptions 'NoEchoQuit'
    end
    InitArgs.0 = argCount
    if( argCount > 0 )then do i = 1 to argCount
        InitArgs.i = arg( i + argOff )
    end
    drop calledAs argCount argOff

/*  Load the windows
*/
    call VRInit
    parse source . . spec
    _VREPrimaryWindowPath = ,
        VRParseFileName( spec, "dpn" ) || ".VRW"
    _VREPrimaryWindow = ,
        VRLoad( parent, _VREPrimaryWindowPath )
    drop parent spec
    if( _VREPrimaryWindow == "" )then do
        call VRMessage "", "Cannot load window:" VRError(), ,
            "Error!"
        _VREReturnValue = 32000
        signal _VRELeaveMain
    end

/*  Process events
*/
    call Init
    signal on halt
    do while( \ VRGet( _VREPrimaryWindow, "Shutdown" ) )
        _VREEvent = VREvent()
        interpret _VREEvent
    end
_VREHalt:
    _VREReturnValue = Fini()
    call VRDestroy _VREPrimaryWindow
_VRELeaveMain:
    call VRFini
exit _VREReturnValue

VRLoadSecondary:
    __vrlsWait = abbrev( 'WAIT', translate(arg(2)), 1 )
    if __vrlsWait then do
        call VRFlush
    end
    __vrlsHWnd = VRLoad( VRWindow(), VRWindowPath(), arg(1) )
    if __vrlsHWnd = '' then signal __vrlsDone
    if __vrlsWait \= 1 then signal __vrlsDone
    call VRSet __vrlsHWnd, 'WindowMode', 'Modal' 
    __vrlsTmp = __vrlsWindows.0
    if( DataType(__vrlsTmp) \= 'NUM' ) then do
        __vrlsTmp = 1
    end
    else do
        __vrlsTmp = __vrlsTmp + 1
    end
    __vrlsWindows.__vrlsTmp = VRWindow( __vrlsHWnd )
    __vrlsWindows.0 = __vrlsTmp
    do while( VRIsValidObject( VRWindow() ) = 1 )
        __vrlsEvent = VREvent()
        interpret __vrlsEvent
    end
    __vrlsTmp = __vrlsWindows.0
    __vrlsWindows.0 = __vrlsTmp - 1
    call VRWindow __vrlsWindows.__vrlsTmp 
    __vrlsHWnd = ''
__vrlsDone:
return __vrlsHWnd

/*:VRX         DDCB_2_Change
*/
DDCB_2_Change: 
value = VRGet( "DDCB_2", "Value" )
if value <> lwmerk then do
    ok = VRSet( "DDCB_2", "Enabled", 0 )
    lw = substr(value,1,2)
    ok = VRSet( "DT_3", "Caption", 'Retrieving path information, please wait...' )
    ok = SysFileTree( lw'\*.*', pfade, 'SDO' )
    ok = VRMethod( "LB_1", "Clear" )
    position = VRMethod( "LB_1", "AddString", lw"\",  )
    ok = VRMethod( "LB_1", "AddStringList", "pfade.", )
    ok = VRSet( "DT_3", "Caption", '' )
    ok = VRSet( "DDCB_2", "Enabled", 1 )
end
return
/*:VRX         DDCB_2_GotFocus
*/
DDCB_2_GotFocus: 
  lwmerk = VRGet( "DDCB_2", "Value" )
return

/*:VRX         dirs
*/
dirs: 
  Arg pattern, option, type

  Call files pattern, type
  
  If option = 'S' Then Do
    nBackSl = lastpos('\',pattern)
    cSpec = substr(pattern,nBackSl+1)

    Call SysFileTree pattern, 'dir', 'DO'option
    Do i=1 to dir.0
      if option = 'S' then do
        call files dir.i||'\'||cSpec, type
      end
    end 
  end
return
/*:VRX         files
*/
files: 
  Arg pattern, type

  Call SysFileTree pattern, 'file', 'O'
    
  Do j=1 To file.0

    base = FileSpec('Name', file.j)
    base = Translate(base, ' ', "'")
    nErw = lastpos('.',base)
    nErw1 = nErw - 1
    nErw2 = nErw + 1
    if nErw > 0 then cName = substr(base,1,nErw1)
    else cName = base
    cName = translate(cName,'_','.')

    If type = '2' Then do
      nLenNeu = length(cName)
      if nLenNeu > 28 then nLenNeu = 28
      if nErw > 0 then do
        cErw = substr(base,nErw2)
        new = substr(cName,1,nLenNeu)'.'cErw
      end
      else do
        new = substr(cName,1,nLenNeu+3)
      end
    end
    else do
      nLenNeu = length(base)
      if nLenNeu > 8 then nLenNeu = 8
      cName = translate(cName,'_',' ')
      cName = translate(cName,'_',',')
      if nErw > 0 then do
        cErw = substr(base,nErw2,3)
        new = substr(cName,1,nLenNeu)'.'cErw
      end
      else do
        new = substr(cName,1,nLenNeu)
      end

    end

    If new \= base Then do
      ok = VRSet( "DT_3", "Caption", file.j )
      '@rename "'file.j'" "'new'"'
      counter = counter +1
    end
  
  End
return
/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:
    window = VRWindow()
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window
return

/*:VRX         LB_1_Click
*/
LB_1_Click: 
selected = VRGet( "LB_1", "Selected" )
if selected <> 0 then 
ok = VRSet( "PB_1", "Enabled", 1 )
return

/*:VRX         PB_1_Click
*/
PB_1_Click:
counter=0 
drpath = VRGet( "LB_1", "SelectedString" )
filespec = VRGet( "EF_1", "Value" )
if lastpos('\',drpath) = length(drpath) then
 toren = drpath
else
 toren = drpath'\'filespec
subdirs = VRGet( "CB_1", "Set" )
level2 = VRGet( "RB_1", "Set" )
level1 = VRGet( "RB_2", "Set" )
subopt = ''
if subdirs = 1 then subopt = 'S'
if level2 = 1 then typopt = '2'
if level1 = 1 then typopt = '1'
call dirs toren, subopt, typopt
if counter=0 then ok = VRSet( "DT_3", "Caption", 'No file to rename !' )
else ok = VRSet( "DT_3", "Caption", counter' files / directories renamed.' )
return
/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

/*:VRX         Window1_Close
*/
Window1_Close:
    call Quit
return

/*:VRX         Window1_Create
*/
Window1_Create: 
    drstring = SysDriveMap( 'A:', 'USED' )
    position = VRMethod( "DDCB_2", "AddString", "",  )
    do i=1 To words(drstring)
     drives.i = word( drstring, i )
    end
    drives.0 = words(drstring)
    ok = VRMethod( "DDCB_2", "AddStringList", "drives.",  )
return

