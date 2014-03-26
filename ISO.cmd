/* REXX: ISOren.cmd */
/* (c) Thomas Bohn <Thomas@Bohn-Stralsund.de> */
/* based on LOWER.CMD from Kai Uwe Rommel <rommel@ars.muc.de> */

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

Arg args

If args='' Then Do
  Say
  Say 'Usage: ISO [-sq21] <arg> ...'
  Say
  Say '       -s  include subdirectories'
  Say '       -q  do not print progress messages'
  Say '       -2  translate to level 2 (max. 31, one point)'
  Say '       -1  translate to level 1 (8.3)'
  Say
  Exit
End

option = ''
type = '2'
echo = 'V'

Do i=1 To Words(args)

  opt = Word(args, i)

  Select
    When Left(opt, 2) = '-Q' | Left(opt, 2) = '/Q' Then
      echo = 'Q'
    When Left(opt, 2) = '-S' | Left(opt, 2) = '/S' Then
      option = 'S'
    When Left(opt, 2) = '-2' | Left(opt, 2) = '/2' Then
      type = '2'
    When Left(opt, 2) = '-1' | Left(opt, 2) = '/1' Then
      type = '1'
    Otherwise
      Call dirs opt, option, type, echo
  End

End

Exit

dirs: Procedure 
  Arg pattern, option, type, echo

  Call files pattern, type, echo
  
  If option = 'S' Then Do
    nBackSl = lastpos('\',pattern)
    cSpec = substr(pattern,nBackSl+1)

    Call SysFileTree pattern, 'dir', 'DO'option
    Do i=1 To dir.0
    
      If option = 'S' then
      Call files dir.i'\'cSpec, type, echo

    End 
    
  End 

Return

files: Procedure
  Arg pattern, type, echo
  
  Call SysFileTree pattern, 'file', 'O'
    
  Do i=1 To file.0

    base = FileSpec('Name', file.i)
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
      If echo = 'V' Then say 'Processing: 'file.i
     '@rename "'file.i'" "'new'"'
    end
  
  End

Return
